CREATE OR REPLACE PACKAGE BODY EcDp_TruckTicket_Partition IS

/****************************************************************
** Package        :  EcDp_TruckTIcket_Partition, body part
**
** $Revision: 1.8 $
**
** Purpose        :  Provide basic functions on objects
**
** Documentation  :  www.energy-components.com
**
** Created        : 05.04.2018  shindani
**
** Modification history:
**
**  Date        Whom  		Change description:
**  ------      ----- 		--------------------------------------
**  05.04.2018  shindani 	      Initial Version.
****************************************************************/


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : finderObjectPartition
-- Description    : Check if object is part of a partition for user
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

FUNCTION finderObjectPartition(
  p_daytime     DATE,
  p_object_id	VARCHAR2,
  p_class_name  VARCHAR2,
  p_user	    VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS
  	lv2_pref_key	        VARCHAR2(300);
  	lv2_sql             	VARCHAR2(4000);
  	lv2_groupmodel   		VARCHAR(1000);
  	lv2_groupmodel_prefix   VARCHAR(8) := 'OP_'; -- set prefix as default OP for groupmodel
  	lb_partOfPartition   	NUMBER := 1;
  	ln_partitionhits		NUMBER;
    lv2_table	            VARCHAR2(100);
	lv2_datetype	        VARCHAR2(100);
    lv2_condition           VARCHAR2(4000); -- condition of object partition, join in and not in condition
    lv2_condition_in        VARCHAR2(4000); -- in condition of object partition
    lv2_condition_not_in    VARCHAR2(4000); -- not in condition of object partition

   	CURSOR c_role(cp_user VARCHAR2) IS
    SELECT role_id
    FROM t_basis_userrole
    WHERE user_id = cp_user;

   	CURSOR c_op(cp_role VARCHAR2) IS
    SELECT attribute_text, operator
    FROM t_basis_object_partition x, t_basis_access y
    WHERE x.t_basis_access_id = y.t_basis_access_id
    AND y.role_id = cp_role
    AND (x.operator = 'NOT IN' or x.operator = 'IN' or x.operator = 'ALL');


BEGIN
  --get the group model type, operation or geographical
	lv2_pref_key := '/com/ec/eccommon/genericmodel/navigator/' || p_class_name;
	lv2_sql := 'select nvl((select value_string from ctrl_property where key = ''' || lv2_pref_key || ''' and user_id = ''' || p_user || '''),(select default_value_string from ctrl_property_meta where key = ''' || lv2_pref_key || ''')) from dual';
	lv2_groupmodel := EcDp_Utilities.executeSinglerowString(lv2_sql);

    IF lv2_groupmodel = 'geographical' THEN
      lv2_groupmodel_prefix := 'GEO_';
    END IF;

    --check the user
    FOR cur_role IN c_role(p_user) LOOP
      --check the role of user
      FOR cur_op IN c_op(cur_role.role_id) LOOP
        IF p_class_name IN ('WELL') THEN
          lv2_table := 'well_version';
		  lv2_datetype := 'daytime';
          IF cur_op.operator = 'IN' THEN
             lv2_condition_in := lv2_condition_in || ' (' || lv2_groupmodel_prefix || 'PU_ID ' || cur_op.operator || ' ' || cur_op.attribute_text || ' or ' || lv2_groupmodel_prefix || 'SUB_PU_ID ' || cur_op.operator || ' ' || cur_op.attribute_text || ' or ' || lv2_groupmodel_prefix || 'AREA_ID ' || cur_op.operator || ' ' || cur_op.attribute_text || ' or ' || lv2_groupmodel_prefix || 'SUB_AREA_ID ' || cur_op.operator || ' ' || cur_op.attribute_text || ' or ' || lv2_groupmodel_prefix || 'FCTY_CLASS_2_ID ' || cur_op.operator || ' ' || cur_op.attribute_text || ' or ' || lv2_groupmodel_prefix || 'FCTY_CLASS_1_ID ' || cur_op.operator || ' ' || cur_op.attribute_text || ' or ' || lv2_groupmodel_prefix || 'WELL_HOOKUP_ID ' || cur_op.operator || ' ' || cur_op.attribute_text || ' or OBJECT_ID ' || cur_op.operator || ' ' || cur_op.attribute_text || ') OR';
          END IF;
          IF cur_op.operator = 'NOT IN' THEN
             lv2_condition_not_in := lv2_condition_not_in || ' (' || lv2_groupmodel_prefix || 'PU_ID in ' || cur_op.attribute_text || ' or ' || lv2_groupmodel_prefix || 'SUB_PU_ID in ' || cur_op.attribute_text || ' or ' || lv2_groupmodel_prefix || 'AREA_ID in ' || cur_op.attribute_text || ' or ' || lv2_groupmodel_prefix || 'SUB_AREA_ID in ' || cur_op.attribute_text || ' or ' || lv2_groupmodel_prefix || 'FCTY_CLASS_2_ID in ' || cur_op.attribute_text || ' or ' || lv2_groupmodel_prefix || 'FCTY_CLASS_1_ID in ' || cur_op.attribute_text || ' or ' || lv2_groupmodel_prefix || 'WELL_HOOKUP_ID in ' || cur_op.attribute_text || ' or OBJECT_ID in ' || cur_op.attribute_text || ') OR';
          END IF;
        END IF;
        IF p_class_name IN ('STREAM') THEN
          lv2_table := 'strm_version';
		  lv2_datetype := 'daytime';
          IF cur_op.operator = 'IN' THEN
             lv2_condition_in := lv2_condition_in || ' (' || lv2_groupmodel_prefix || 'PU_ID ' || cur_op.operator || ' ' || cur_op.attribute_text || ' or ' || lv2_groupmodel_prefix || 'SUB_PU_ID ' || cur_op.operator || ' ' || cur_op.attribute_text || ' or ' || lv2_groupmodel_prefix || 'AREA_ID ' || cur_op.operator || ' ' || cur_op.attribute_text || ' or ' || lv2_groupmodel_prefix || 'SUB_AREA_ID ' || cur_op.operator || ' ' || cur_op.attribute_text || ' or ' || lv2_groupmodel_prefix || 'FCTY_CLASS_2_ID ' || cur_op.operator || ' ' || cur_op.attribute_text || ' or ' || lv2_groupmodel_prefix || 'FCTY_CLASS_1_ID ' || cur_op.operator || ' ' || cur_op.attribute_text || ' or OBJECT_ID ' || cur_op.operator || ' ' || cur_op.attribute_text || ') OR';
          END IF;
          IF cur_op.operator = 'NOT IN' THEN
             lv2_condition_not_in := lv2_condition_not_in || ' (' || lv2_groupmodel_prefix || 'PU_ID in ' || cur_op.attribute_text || ' or ' || lv2_groupmodel_prefix || 'SUB_PU_ID in ' || cur_op.attribute_text || ' or ' || lv2_groupmodel_prefix || 'AREA_ID in ' || cur_op.attribute_text || ' or ' || lv2_groupmodel_prefix || 'SUB_AREA_ID in ' || cur_op.attribute_text || ' or ' || lv2_groupmodel_prefix || 'FCTY_CLASS_2_ID in ' || cur_op.attribute_text || ' or ' || lv2_groupmodel_prefix || 'FCTY_CLASS_1_ID in ' || cur_op.attribute_text || ' or OBJECT_ID in ' || cur_op.attribute_text || ') OR';
          END IF;
        END IF;
        IF p_class_name IN ('TANK') THEN
          lv2_table := 'tank_version';
		  lv2_datetype := 'daytime';
          IF cur_op.operator = 'IN' THEN
             lv2_condition_in := lv2_condition_in || ' (' || lv2_groupmodel_prefix || 'PU_ID ' || cur_op.operator || ' ' || cur_op.attribute_text || ' or ' || lv2_groupmodel_prefix || 'SUB_PU_ID ' || cur_op.operator || ' ' || cur_op.attribute_text || ' or ' || lv2_groupmodel_prefix || 'AREA_ID ' || cur_op.operator || ' ' || cur_op.attribute_text || ' or ' || lv2_groupmodel_prefix || 'SUB_AREA_ID ' || cur_op.operator || ' ' || cur_op.attribute_text || ' or ' || lv2_groupmodel_prefix || 'FCTY_CLASS_2_ID ' || cur_op.operator || ' ' || cur_op.attribute_text || ' or ' || lv2_groupmodel_prefix || 'FCTY_CLASS_1_ID ' || cur_op.operator || ' ' || cur_op.attribute_text || ' or OBJECT_ID ' || cur_op.operator || ' ' || cur_op.attribute_text || ') OR';
          END IF;
          IF cur_op.operator = 'NOT IN' THEN
             lv2_condition_not_in := lv2_condition_not_in || ' (' || lv2_groupmodel_prefix || 'PU_ID in ' || cur_op.attribute_text || ' or ' || lv2_groupmodel_prefix || 'SUB_PU_ID in ' || cur_op.attribute_text || ' or ' || lv2_groupmodel_prefix || 'AREA_ID in ' || cur_op.attribute_text || ' or ' || lv2_groupmodel_prefix || 'SUB_AREA_ID in ' || cur_op.attribute_text || ' or ' || lv2_groupmodel_prefix || 'FCTY_CLASS_2_ID in ' || cur_op.attribute_text || ' or ' || lv2_groupmodel_prefix || 'FCTY_CLASS_1_ID in ' || cur_op.attribute_text || ' or OBJECT_ID in ' || cur_op.attribute_text || ') OR';
          END IF;
        END IF;
        IF p_class_name IN ('EXTERNAL_LOCATION') THEN
          lv2_table := 'FCTY_EXT_LOCATION_CONN';
		  lv2_datetype := 'start_date';
          IF cur_op.operator = 'IN' THEN
             lv2_condition_in := lv2_condition_in || ' (FCTY_OBJECT_ID ' || cur_op.operator || ' ' || cur_op.attribute_text || ' or OBJECT_ID ' || cur_op.operator || ' ' || cur_op.attribute_text || ') OR';
          END IF;
          IF cur_op.operator = 'NOT IN' THEN
             lv2_condition_not_in := lv2_condition_not_in || ' (FCTY_OBJECT_ID in ' || cur_op.attribute_text || ' or OBJECT_ID in ' || cur_op.attribute_text || ') OR';
          END IF;
        END IF;
      END LOOP;
    END LOOP;

    IF lv2_condition_in IS NOT NULL THEN
	   --remove the OR in the end of string
       lv2_condition_in := substr(lv2_condition_in,0,length(lv2_condition_in)-3);
    ELSE
      --if no partition, then set 1=1
       lv2_condition_in := '1=1';
    END IF;

    IF lv2_condition_not_in IS NOT NULL THEN
	   --remove the OR in the end of string
       lv2_condition_not_in := substr(lv2_condition_not_in,0,length(lv2_condition_not_in)-3);
	   --to check is it exists in the object partition requirement of not-in condition
	   lv2_sql := 'select count(*) from '||lv2_table||' where to_date('''||to_char(p_daytime,'yyyy-mm-dd')||''',''yyyy-mm-dd'') >= ' || lv2_datetype || ' and to_date('''||to_char(p_daytime,'yyyy-mm-dd')||''',''yyyy-mm-dd'') < nvl(end_date,to_date('''||to_char(p_daytime+1,'yyyy-mm-dd')||''',''yyyy-mm-dd'')) and object_id = ''' || p_object_id || ''' and (' || lv2_condition_not_in ||')';
       ln_partitionhits := EcDp_Utilities.executeSinglerowNumber(lv2_sql);
	   --if yes, return false, if not, return true
        IF ln_partitionhits <> 0 THEN
          lv2_condition_not_in := '1=0';
        ELSE
          lv2_condition_not_in := '1=1';
        END IF;
    ELSE
      --if no partition, then set 1=1
       lv2_condition_not_in := '1=1';
    END IF;

    --join the in and not in to 1 condition string
    lv2_condition := '(' || lv2_condition_in || ') AND (' || lv2_condition_not_in ||')';
    lv2_sql := 'select count(*) from ' || lv2_table || ' where to_date('''||to_char(p_daytime,'yyyy-mm-dd')||''',''yyyy-mm-dd'') >= ' || lv2_datetype || ' and to_date('''||to_char(p_daytime,'yyyy-mm-dd')||''',''yyyy-mm-dd'') < nvl(end_date,to_date('''||to_char(p_daytime+1,'yyyy-mm-dd')||''',''yyyy-mm-dd'')) and object_id = ''' || p_object_id || ''' and (' || lv2_condition ||')';
    ln_partitionhits := EcDp_Utilities.executeSinglerowNumber(lv2_sql);
        IF ln_partitionhits <> 0 THEN
          lb_partOfPartition := 1;
		ELSIF ln_partitionhits IS NULL THEN
          lb_partOfPartition := 1;
        ELSE
          lb_partOfPartition := 0;
        END IF;
    IF p_object_id is null THEN
      lb_partOfPartition := 0;
    END IF;
	RETURN lb_partOfPartition;
END;

END EcDp_TruckTicket_Partition;