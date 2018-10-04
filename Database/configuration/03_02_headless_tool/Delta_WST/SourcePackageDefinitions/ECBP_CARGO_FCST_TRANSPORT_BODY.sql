CREATE OR REPLACE PACKAGE BODY EcBp_Cargo_Fcst_Transport IS
/******************************************************************************
** Package        :  EcBp_Cargo_Fcst_Transport, body part
**
** $Revision: 1.14 $
**
** Purpose        :  Business logic for cargo transport
**
** Documentation  :  www.energy-components.com
**
** Created  : 04.06.2008 Kari Sandvik
**
** Modification history:
**
** Version  Date       Whom     Change description:
** -------  ---------  ----- -----------------------------------------------------------------------------------------------
** 10.0     27-01-10   lauuufus Modify getCarrierName to pass p_forecast_id as condition
** 10.2     05-10-10   Leongwen ECPD-15638 Forecast - Generate Cargo does not copy Carrier
** 10.4     29-06-12   meisihil  ECPD-20651: Add getCarrierLaytime function.
** 10.4     27-03-13   leeeewei  ECPD-7256: Added parameter forecast_id to getCargoName
** 10.4		13-05-13   leeeewei	 ECPD-24134: Added missing forecast_id in checkValidNom
** 11.0     18.11.13   leeeewei	 ECPD-25903: Added missing forecast_id in connectNomToCargo
**          11.02.2016 sharawan  ECPD-33109: Add new function getCargoNameByBerth for Berth Overview Chart
            25.05.2017 xxwaghmp  ECPD-45663: Added new forecast_id in CleanLonesomeCargoes.
**          03.07.2017 asareswi  ECPD-45818: Replaced sysdate with Ecdp_Timestamp.getCurrentSysdate
**		    18.07.2017 baratmah  ECPD-45870 Modified getCargoNameByBerth to Fix filtering on cargo status.
********************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLiftingAccount
-- Description    : Returns a string containg lifting accounts names for a cargo
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--                                                                                                                        --
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getLiftingAccount(p_cargo_no  NUMBER, p_forecast_id VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS

CURSOR c_company(p_cargo_no NUMBER)IS
SELECT DISTINCT ecdp_objects.GETOBJNAME(lifting_account_id, requested_date) name
FROM stor_fcst_lift_nom pa
WHERE pa.cargo_no = p_cargo_no
AND pa.forecast_id =  p_forecast_id;

ls_lift_string  VARCHAR2(1000);
ln_count        NUMBER := 1;

BEGIN

FOR CompanyCur IN c_company(p_cargo_no) LOOP
  IF ln_count = 1 THEN
    ls_lift_string := CompanyCur.name;
  ELSE
    ls_lift_string :=  ls_lift_string || ' \ ' || CompanyCur.name;
  END IF;
  ln_count := ln_count + 1;
END LOOP;

RETURN ls_lift_string;

END getLiftingAccount;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getStorages
-- Description    : Returns a string containg Storage names for a cargo
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getStorages(p_cargo_no  NUMBER, p_forecast_id VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS

CURSOR c_storage(p_cargo_no NUMBER)IS
SELECT DISTINCT ecdp_objects.GETOBJNAME(object_id, nom_firm_date) name
FROM stor_fcst_lift_nom pa
WHERE pa.cargo_no = p_cargo_no
AND pa.forecast_id = p_forecast_id;

ls_stor_string  VARCHAR2(255);
ln_count        NUMBER := 1;

BEGIN

FOR StorageCur IN c_storage(p_cargo_no) LOOP
  IF ln_count = 1 THEN
    ls_stor_string := StorageCur.name;
  ELSE
    ls_stor_string :=  ls_stor_string || ' \ ' || StorageCur.name;
  END IF;
  ln_count := ln_count + 1;
END LOOP;

RETURN ls_stor_string;

END getStorages;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCargoNo
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getCargoNo(p_cargo_name VARCHAR2, p_forecast_id VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS
CURSOR c_cargo(cp_cargo_name VARCHAR2)
IS
SELECT	cargo_no
FROM	cargo_fcst_transport
WHERE	cargo_name = cp_cargo_name
AND forecast_id = p_forecast_id;

ln_cargoNo	NUMBER;

BEGIN
	FOR curNo IN c_cargo(p_cargo_name) LOOP
		ln_cargoNo := curNo.cargo_no;
	END LOOP;

	RETURN ln_cargoNo;

END getCargoNo;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getFirstNomDate                                  	  		                 --
-- Description    : Returns the first date in the range for all parcels			                 --
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--                                                                                                                        --
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getFirstNomDate(p_cargo_no NUMBER, p_forecast_id VARCHAR2)
RETURN DATE
--</EC-DOC>
IS

CURSOR c_date(p_cargo_no NUMBER)IS
SELECT MIN(nom_firm_date) min_nom_date
FROM stor_fcst_lift_nom t
WHERE t.cargo_no = p_cargo_no
AND t.forecast_id =  p_forecast_id;

ld_min_nom_date	DATE;

BEGIN

	FOR dateCur IN c_date(p_cargo_no) LOOP
		ld_min_nom_date := dateCur.min_nom_date;
	END LOOP;

	RETURN ld_min_nom_date;

END getFirstNomDate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLastNomDate                                  	  		                 --
-- Description    : Returns the last date in the range for all parcels				             --
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--                                                                                                                        --
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getLastNomDate(p_cargo_no NUMBER, p_forecast_id VARCHAR2)
RETURN DATE
--</EC-DOC>
IS
CURSOR c_date(p_cargo_no NUMBER)IS
SELECT MAX(nom_firm_date) max_nom_date
FROM stor_fcst_lift_nom t
WHERE t.cargo_no = p_cargo_no
AND t.forecast_id = p_forecast_id;

ld_max_nom_date	DATE;

BEGIN

	FOR dateCur IN c_date(p_cargo_no) LOOP
		ld_max_nom_date := dateCur.max_nom_date;
	END LOOP;

	RETURN ld_max_nom_date;
END getLastNomDate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : cleanLonesomeCargoes                                  	                 --
-- Description    : Deletes all cargos that are not connected to any parcels 		             --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
PROCEDURE cleanLonesomeCargoes (p_forecast_id varchar2)
--</EC-DOC>
IS
CURSOR c_lonesome_cargo
IS
SELECT cargo_no
FROM cargo_fcst_transport c
WHERE  c.forecast_id= p_forecast_id and not exists (SELECT 'X' FROM stor_fcst_lift_nom s
                  WHERE s.cargo_no = c.cargo_no AND s.forecast_id = p_forecast_id);
BEGIN
	FOR curLonesomeCargo IN c_lonesome_cargo LOOP
		DELETE FROM cargo_fcst_transport
		WHERE cargo_no = curLonesomeCargo.cargo_no AND forecast_id = p_forecast_id;
	END LOOP;

END cleanLonesomeCargoes;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : auCargoTransport
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
PROCEDURE auCargoTransport(p_cargo_no NUMBER,
							p_old_cargo_status VARCHAR2,
							p_new_cargo_status VARCHAR2)
--</EC-DOC>
IS

BEGIN

   NULL;
	-- if status has changed
	/*IF  Nvl(p_old_cargo_status,'XXX') <> Nvl(p_new_cargo_status,'XXX') THEN
		EcBp_Cargo_Status.updateCargoStatus(p_cargo_no, p_old_cargo_status, p_new_cargo_status, ecdp_context.getAppUser);
	END IF;*/

END auCargoTransport;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : (LOCAL) isNomSingleCarrier
-- Description    : To check nominations using single carrier. If different carriers are used, error.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : storage_lift_nomination
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION isNomSingleCarrier(p_parcels VARCHAR2, p_forecast_id VARCHAR2 )
RETURN BOOLEAN
--</EC-DOC>
IS

lv_sql2       VARCHAR2(1000);
ln_carrierNum VARCHAR2(100);
lb_result     BOOLEAN;

BEGIN
  lb_result := TRUE;

  IF Instr(p_parcels, ',', 1) <> 0  THEN -- If parcels contains many items, worth checking
    lv_sql2 := 'SELECT COUNT(DISTINCT carrier_id) FROM stor_fcst_lift_nom WHERE forecast_id = '''|| p_forecast_id || ''' AND parcel_no IN ' || p_parcels;
    EXECUTE IMMEDIATE lv_sql2 INTO ln_carrierNum;
    IF ln_carrierNum > 1 THEN
      lb_result := false;
    END IF;
  END IF;

  RETURN lb_result;
END isNomSingleCarrier;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : (LOCAL) checkValidNom
-- Description    : To validate nomination entry
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : cargo_fcst_transport
--
-- Using functions: isNomSingleCarrier
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE checkValidNom(p_parcels         IN VARCHAR2,
                        p_cargo_no        IN NUMBER,
                        p_forecast_id     VARCHAR2,
                        p_fin_carrier_id  OUT VARCHAR2)
--</EC-DOC>
IS
  lv_prv_carrier_id VARCHAR2(32);
  lv_sql            VARCHAR2(1000);
  lv_nom_carrier_id VARCHAR2(32);
  TYPE cur_typ      IS REF CURSOR;
  cur cur_typ;
BEGIN

  -- validate distinct nominated carrier from given parcels
  IF NOT isNomSingleCarrier(p_parcels, p_forecast_id) THEN
    Raise_Application_Error(-20327,'It is not allowed to nominate same cargo for different carrier.');
  END IF;

  -- get distinct nom_carrier_id shared by all parcels/nominations

  -- Commented the two lines below by Leongwen as encountered the problem of ORA-01422 'exact fetch returns more than requested number of rows
  -- Svein Helge agreed to use a cursor should do the trick, just select the first one in the cursor loop.
  -- It was found in the development works for ECPD-15638 [Forecast - Generate Cargo does not copy Carrier]
  -- lv_sql := 'SELECT DISTINCT carrier_id FROM storage_lift_nomination WHERE parcel_no IN ' || p_parcels;
  -- EXECUTE IMMEDIATE lv_sql INTO lv_nom_carrier_id;

  lv_sql := 'SELECT DISTINCT carrier_id FROM stor_fcst_lift_nom WHERE forecast_id = '''|| p_forecast_id || ''' AND parcel_no IN ' || p_parcels;
  OPEN cur FOR lv_sql;
  LOOP
    FETCH cur INTO lv_nom_carrier_id;
    EXIT WHEN cur%NOTFOUND;
    EXIT; -- exit loop to take the first one in the loop
  END LOOP;

  -- get prev_carrier_id if cargo_no is given
  IF p_cargo_no IS NOT NULL THEN
    SELECT ct.carrier_id INTO lv_prv_carrier_id
      FROM cargo_fcst_transport ct
     WHERE ct.cargo_no = p_cargo_no
	   AND ct.forecast_id = p_forecast_id;

    -- if existing cargo's carrier has been removed, take the nominated carrier
    IF lv_prv_carrier_id IS NULL THEN
      lv_prv_carrier_id := lv_nom_carrier_id;
    END IF;

    IF lv_prv_carrier_id <> lv_nom_carrier_id THEN
      Raise_Application_Error(-20327,'It is not allowed to nominate same cargo for different carrier.');
    END IF;

    -- since it's a valid prev_carrier_id, take that as final_carrier_id
    p_fin_carrier_id := lv_prv_carrier_id;

  ELSE
    -- since no need to get prev_carrier_id, send back nom_carrier_id as final_carrier_id
    p_fin_carrier_id := lv_nom_carrier_id;
  END IF;

END checkValidNom;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : (LOCAL) copyFwdNominatedCarrier
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : cargo_fcst_transport
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

PROCEDURE copyFwdNominatedCarrier(p_copy_method   VARCHAR2,
                                  p_forecast_id   VARCHAR2,
                                  p_cargo_no      NUMBER,
                                  p_carrier_id    VARCHAR2,
                                  p_cargo_name    VARCHAR2,
                                  p_user          VARCHAR2)
--</EC-DOC>
IS
  lv_cargo_carrier_id VARCHAR2(32);
  lv_laytime VARCHAR2(32);

  CURSOR c_status IS
	SELECT	m.cargo_status
	FROM	cargo_status_mapping m
	WHERE	m.ec_cargo_status = 'T'
	ORDER BY m.sort_order DESC;

  lv_cargo_status	VARCHAR2(32);
BEGIN
  IF p_copy_method = 'INSERT' THEN
  	-- get the cargo status for EC Tentatvie that have the lowest sort order
  	FOR curStatus IN c_status LOOP
  		lv_cargo_status := curStatus.cargo_status;
 	END LOOP;

 	IF lv_cargo_status IS NULL THEN
 		Raise_Application_Error(-20332,'There is no cargo status mapping for EC Cargo Status ''Tentative''. Please update Cargo Status Mapping configuration');
 	END IF;

 	lv_laytime := EcBp_Cargo_Transport.getCarrierLaytimeDate(p_carrier_id, trunc(Ecdp_Timestamp.getCurrentSysdate));

    -- nominating to new cargo_no
    INSERT INTO cargo_fcst_transport (FORECAST_ID,CARGO_NO, CARGO_STATUS, CARGO_NAME, CARRIER_ID, LAYTIME, created_by)
    VALUES (p_forecast_id, p_cargo_no, lv_cargo_status, p_cargo_name, p_carrier_id, lv_laytime, p_user);

  ELSE
    -- nominating to existing cargo_no
    SELECT ct.carrier_id INTO lv_cargo_carrier_id
      FROM cargo_fcst_transport ct WHERE ct.forecast_id=p_forecast_id AND ct.cargo_no = p_cargo_no;

    IF lv_cargo_carrier_id IS NULL THEN
     -- only updating NULL cargo's carrier id and laytime
 	 lv_laytime := getCarrierLaytime(p_carrier_id, p_cargo_no, p_forecast_id);
      UPDATE cargo_fcst_transport ct
        SET ct.carrier_id = p_carrier_id,
            ct.laytime = lv_laytime,
            ct.last_updated_by = p_user
        WHERE ct.forecast_id = p_forecast_id
        AND ct.cargo_no = p_cargo_no;
    END IF;

  END IF;
END copyFwdNominatedCarrier;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : connectNomToCargo
-- Description    :
--
-- Preconditions  :
-- Postconditions : Uncommited changes
--
-- Using tables   : cargo_fcst_transport , storage_lift_nomination
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE connectNomToCargo(p_cargo_no NUMBER,
							p_parcels VARCHAR2,
              p_forecast_id VARCHAR2)
--</EC-DOC>
IS

ln_assign_id  NUMBER;
ls_cargoName  VARCHAR2(100);
lv_sql		    VARCHAR2(1000);
lv_cargo_fcst_transport_sql VARCHAR2(1000);
ln_validate	  VARCHAR2(100);
lv_carrier_id VARCHAR2(32);

BEGIN
	-- validate nominations
	lv_sql := 'SELECT count(s.parcel_no) FROM stor_fcst_lift_nom s, cargo_fcst_transport c WHERE s.forecast_id = ''' || p_forecast_id || ''' AND s.cargo_no = c.cargo_no AND c.cargo_status in (''C'', ''A'') AND parcel_no IN ' || p_parcels;
    EXECUTE IMMEDIATE lv_sql INTO ln_validate;
    IF ln_validate > 0 THEN
    	Raise_Application_Error(-20318,'It is not allowed to move a nominations from a cargo that is closed or approved.');
    END IF;

  checkValidNom(p_parcels,p_cargo_no, p_forecast_id,lv_carrier_id);

	-- create new cargo if cargo no is empty
	IF p_cargo_no IS null THEN
		EcDp_System_Key.assignNextNumber('CARGO_TRANSPORT', ln_assign_id);

		-- get cargo name
		ls_cargoName := EcBp_Cargo_Transport.getCargoName(ln_assign_id, p_parcels,p_forecast_id);


	   INSERT INTO cargo_fcst_transport (CARGO_NO,FORECAST_ID,CARGO_STATUS, CARGO_NAME, created_by)
	    VALUES (ln_assign_id,p_forecast_id,'T',ls_cargoName,ecdp_context.getAppUser);

	ELSE
		ln_assign_id := p_cargo_no;
	END IF;

  Copyfwdnominatedcarrier('UPDATE',p_forecast_id,ln_assign_id,lv_carrier_id,NULL,ecdp_context.getAppUser);

	-- connect nominations to cargo
	lv_sql := 'UPDATE stor_fcst_lift_nom SET cargo_no = ' || ln_assign_id ||', LAST_UPDATED_BY = '''||ecdp_context.getAppUser||''' WHERE parcel_no IN ' || p_parcels ||' AND forecast_id  = '''||p_forecast_id||'''';
	EXECUTE IMMEDIATE lv_sql;

	-- clean cargos that no longer have nominations
	cleanLonesomeCargoes(p_forecast_id);

END connectNomToCargo;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : copyBwdNominatedCarrier
-- Description    : Set all nomination which have the cargo_no as given to have same carrier id (as given carrier_id)
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
PROCEDURE copyBwdNominatedCarrier(p_cargo_no    NUMBER,
                                  p_carrier_id  VARCHAR2,
                                  p_forecast_id VARCHAR2,
                                  p_user        VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS

BEGIN
  IF p_carrier_id IS NOT NULL THEN
    UPDATE stor_fcst_lift_nom sln
    SET sln.carrier_id = p_carrier_id,
        sln.last_updated_by = p_user
    WHERE sln.forecast_id=p_forecast_id
    AND sln.cargo_no = p_cargo_no;

  END IF;
END copyBwdNominatedCarrier;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCarrierName
-- Description    : Retrieve carrier name based on available date
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : cargo_fcst_transport
--
-- Using functions: Ecbp_cargo_fcst_transport.getLastNomDate,ecdp_objects.GetObjName
--
-- Configuration
-- required       :
--
-- Behaviour      : Data lookup sequence:- ETA_ARRIVAL > TO_NOM_DATE > CURRENT_DATE
--
---------------------------------------------------------------------------------------------------
FUNCTION getCarrierName(p_carrier_id VARCHAR2, p_cargo_no NUMBER, p_forecast_id VARCHAR2)
RETURN VARCHAR2
--<EC-DOC>
IS
  ld_est_arrival  DATE;
  ld_to_nom_date  DATE;

BEGIN
  SELECT ct.est_arrival INTO ld_est_arrival
    FROM cargo_fcst_transport ct
    WHERE ct.cargo_no = p_cargo_no
    AND forecast_id = p_forecast_id;

  ld_to_nom_date := getLastNomDate(p_cargo_no, p_forecast_id);

  IF ld_est_arrival IS NOT NULL THEN
    RETURN ecdp_objects.GetObjName(p_carrier_id,ld_est_arrival);
  ELSIF ld_to_nom_date IS NOT NULL THEN
    RETURN ecdp_objects.GetObjName(p_carrier_id,ld_to_nom_date);
  ELSE
    RETURN ecdp_objects.GetObjName(p_carrier_id,Ecdp_Timestamp.getCurrentSysdate);
  END IF;

END getCarrierName;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCarrierLaytime
-- Description    : Retrieve carrier laytime and returns if only one
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : cargo_transport
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getCarrierLaytime(p_carrier_id VARCHAR2, p_cargo_no NUMBER, p_forecast_id VARCHAR2)
RETURN VARCHAR2
--<EC-DOC>
IS
	ld_daytime DATE;
	lv_result VARCHAR2(32);

BEGIN
	ld_daytime := EcBp_Cargo_Fcst_Transport.getFirstNomDate(p_cargo_no, p_forecast_id);
	lv_result := EcBp_Cargo_Transport.getCarrierLaytimeDate(p_carrier_id, NVL(ld_daytime, trunc(Ecdp_Timestamp.getCurrentSysdate)));
	RETURN lv_result;

END getCarrierLaytime;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCargoNameByBerth
-- Description    : Retrieve cargo name for the daytime and for cargos planned on the berth.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : stor_fcst_lift_nom, cargo_fcst_transport, stor_fcst_sub_day_lift_nom, cargo_status_mapping
--
-- Using functions: ec_cargo_fcst_transport.cargo_name
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getCargoNameByBerth(p_forecast_id VARCHAR2, p_berth_id VARCHAR2, p_daytime DATE, p_product_group VARCHAR2)
RETURN VARCHAR2
--<EC-DOC>
IS
  CURSOR c_fcst_sub_day(cp_forecast_id VARCHAR2, cp_berth_id VARCHAR2, cp_daytime DATE)
   	IS
      SELECT n.cargo_no, sn.forecast_id
      FROM stor_fcst_lift_nom n, cargo_fcst_transport c, stor_fcst_sub_day_lift_nom sn, cargo_status_mapping csm
      WHERE n.forecast_id = c.forecast_id
        AND n.parcel_no = sn.parcel_no
        AND n.forecast_id = sn.forecast_id
        AND nvl(n.deleted_ind, 'N') <> 'Y'
        AND c.cargo_no = n.cargo_no
		AND c.cargo_status= csm.cargo_status
        AND csm.ec_cargo_status <> 'D'
        AND sn.production_day = cp_daytime
        AND c.berth_id = cp_berth_id
        AND sn.forecast_id = cp_forecast_id;

  ls_cargo_name VARCHAR2(100) := '';
  ln_count        NUMBER := 1;

BEGIN
  FOR curGetCargoName IN c_fcst_sub_day(p_forecast_id, p_berth_id, p_daytime) LOOP
    IF ln_count = 1 THEN
      ls_cargo_name := ec_cargo_fcst_transport.cargo_name(curGetCargoName.cargo_no, curGetCargoName.forecast_id);
    ELSE
      ls_cargo_name :=  ls_cargo_name || ' , ' || ec_cargo_fcst_transport.cargo_name(curGetCargoName.cargo_no, curGetCargoName.forecast_id);
    END IF;
    ln_count := ln_count + 1;
	END LOOP;

  RETURN ls_cargo_name;

END getCargoNameByBerth;

END EcBp_Cargo_Fcst_Transport;