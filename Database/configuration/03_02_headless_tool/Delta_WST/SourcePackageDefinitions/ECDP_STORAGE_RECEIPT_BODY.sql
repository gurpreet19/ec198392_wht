CREATE OR REPLACE PACKAGE BODY EcDp_Storage_Receipt IS
/****************************************************************
** Package        :  EcDp_Storage_Receipt; body part
**
** $Revision: 1.5 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created        :  05.09.2006	Kari Sandvik
**
** Modification history:
**
** Date        Whom  	Change description:
** ----------  ----- 	-------------------------------------------
** 15-Jul-2016 vaidyman Modified calcLiftAccOfficial for ECPD-37456
******************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getPlannedDayCompany
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : stor_day_pc_forecast, profit_centre, commercial_entity, equity_share
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getPlannedDayCompany(p_storage_id VARCHAR2,
								p_pc_id VARCHAR2,
								p_company_id VARCHAR2,
								p_daytime DATE)

RETURN NUMBER
--</EC-DOC>
IS
CURSOR c_classes IS
	SELECT  m.db_object_name, m.db_object_attribute
	FROM    class_dependency_cnfg d, class_cnfg m
	WHERE   d.child_class = m.class_name
         AND d.parent_class = 'PROFIT_CENTRE'
         AND d.dependency_type = 'IMPLEMENTS';

	lv_from		VARCHAR2(240);
	lv_where	VARCHAR2(1000);
	ln_plan		NUMBER;
	lv_sql		VARCHAR2(1000);

BEGIN
	FOR curClasses IN c_classes LOOP
		lv_from := curClasses.db_object_name||', '||curClasses.db_object_attribute;
		lv_where := 'AND r.profit_centre_id = '||curClasses.db_object_name||'.object_id';
		lv_where := lv_where || ' AND '||curClasses.db_object_name||'.object_id = '||curClasses.db_object_attribute||'.object_id';
		lv_where := lv_where || ' AND '||curClasses.db_object_attribute||'.daytime <= r.daytime';
		lv_where := lv_where || ' AND Nvl('||curClasses.db_object_attribute||'.end_date, r.daytime+1) > r.daytime';
		IF curClasses.db_object_name = 'COMMERCIAL_ENTITY' then
				lv_where := lv_where || ' AND '||curClasses.db_object_attribute||'.object_id = c.object_id';
		ELSE
				lv_where := lv_where || ' AND '||curClasses.db_object_attribute||'.commercial_entity_id = c.object_id';
		END IF;
	END LOOP;

	lv_sql := 'SELECT (r.grs_vol * e.eco_share)/100';
	lv_sql := lv_sql || ' FROM stor_day_pc_forecast r, commercial_entity c, equity_share e, company o,'||lv_from;
	lv_sql := lv_sql || ' WHERE r.object_id = '''|| p_storage_id || ''' AND r.profit_centre_id ='''|| p_pc_id || ''' AND r.daytime = '''||p_daytime||'''';
	lv_sql := lv_sql || ' '||lv_where;
	lv_sql := lv_sql || ' AND c.object_id = e.object_id';
    lv_sql := lv_sql || '  AND e.daytime <= r.daytime';
    lv_sql := lv_sql || ' AND Nvl(e.end_date, r.daytime+1) > r.daytime';
    lv_sql := lv_sql || ' AND e.company_id = o.object_id';
    lv_sql := lv_sql || ' AND o.object_id ='''|| p_company_id||'''';

	EXECUTE IMMEDIATE lv_sql INTO ln_plan;

	RETURN ln_plan;

END getPlannedDayCompany;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : aggrOfficial
-- Description    :
--
-- Preconditions  :
-- Postconditions : Uncommited changes
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE aggrOfficial(p_object_id VARCHAR2,
						p_daytime DATE,
						p_type VARCHAR2,
						p_old_qty NUMBER,
						p_new_qty NUMBER,
						p_user VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS

CURSOR c_official (cp_object_id VARCHAR2, cp_daytime DATE) IS
	SELECT	official_qty, official_type
	FROM	stor_day_official
	WHERE	object_id = cp_object_id
	      	AND daytime = cp_daytime;

	lv_exists       VARCHAR2(1):='N';

BEGIN

	IF Nvl(p_old_qty,-1) <> Nvl(p_new_qty,-1) THEN

		FOR curOff IN c_official (p_object_id,p_daytime)  LOOP
			lv_exists := 'Y';
		END LOOP;

		IF lv_exists = 'Y' THEN
			UPDATE stor_day_official SET official_qty = Nvl(official_qty, 0) - Nvl(p_old_qty,0) + Nvl(p_new_qty,0), official_type = p_type
			WHERE object_id = p_object_id AND daytime = p_daytime;
		ELSE
			INSERT INTO stor_day_official (object_id, daytime, official_type, official_qty, created_by)
			VALUES (p_object_id, p_daytime, p_type, p_new_qty, p_user);
		END IF;

	END IF;
END aggrOfficial;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : calcLiftAccOfficial
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE calcLiftAccOfficial(p_object_id VARCHAR2,
							p_pc_id VARCHAR2,
							p_company_id VARCHAR2,
							p_daytime DATE,
							p_type VARCHAR2,
							p_old_qty NUMBER,
							p_new_qty NUMBER,
							p_user VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS

CURSOR c_official (cp_object_id VARCHAR2, cp_daytime DATE) IS
	SELECT	official_qty, official_type
	FROM	lift_acc_day_official
	WHERE	object_id = cp_object_id
	      	AND daytime = cp_daytime;

	lv_exists       VARCHAR2(1):='N';
	lv_lift_acc_id	VARCHAR2(32);

    lv_pc_ind       VARCHAR2(1):='Y';
    ln_lift_acc_qty NUMBER;
BEGIN
	lv_lift_acc_id := ecbp_lifting_account.getLiftingAccountCpyPc(p_object_id, p_company_id, p_pc_id, p_daytime);

	IF lv_lift_acc_id IS NULL THEN
		lv_lift_acc_id := ecbp_lifting_account.getLiftingAccountCpy(p_object_id, p_company_id, p_daytime);
		lv_pc_ind := 'N';
	END IF;

	-- may have to remove this. But for old version the lifting account was mandatory. New customers should not use this table
	IF lv_lift_acc_id IS NULL THEN
		Raise_Application_Error(-20000,'No lifting account configured for the storage, company (and profit centre)');
	END IF;

	-- check if an official number already exist
	FOR curOff IN c_official (lv_lift_acc_id,p_daytime)  LOOP
		lv_exists := 'Y';
	END LOOP;

	IF lv_exists = 'Y' THEN
	IF lv_pc_ind = 'Y' THEN
	 ln_lift_acc_qty := p_new_qty;
	ELSE
		SELECT SUM(grs_vol) INTO ln_lift_acc_qty
		FROM STOR_DAY_PC_CPY_RECEIPT
		WHERE object_id = p_object_id AND daytime = p_daytime AND company_id = p_company_id AND receipt_type = p_type;
	END IF;
		UPDATE lift_acc_day_official SET official_qty = ln_lift_acc_qty, official_type = p_type
		WHERE object_id = lv_lift_acc_id AND daytime = p_daytime;
	ELSE
		INSERT INTO lift_acc_day_official (object_id, daytime, official_type, official_qty, created_by)
		VALUES (lv_lift_acc_id, p_daytime, p_type, p_new_qty, p_user);
	END IF;

END calcLiftAccOfficial;

END EcDp_Storage_Receipt;