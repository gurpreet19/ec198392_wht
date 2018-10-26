CREATE OR REPLACE PACKAGE BODY EcBp_Cargo_Transport IS
/******************************************************************************
** Package        :  EcBp_Cargo_Transport, body part
**
** $Revision: 1.35 $
**
** Purpose        :  Business logic for cargo transport
**
** Documentation  :  www.energy-components.com
**
** Created  : 03.09.2004 Kari Sandvik
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- -----------------------------------------------------------------------------------------------
** #.#   DD.MM.YYYY  <initials>
**       22.06.2006   zakiiari  TI#1955: Added isNomSingleCarrier,checkValidNom,copyFwdNominatedCarrier,copyBwdNominatedCarrier.
**                                       Updated connectNomToCargo.
**                                       Added getCarrierName.
**       18.08.2006   rahmanaz  TI#4358: Modified getLiftngAccount(): increase variable ls_lift_string from 255 to 1000
**       19.12.2006   kaurrnar  ECPD-4691: Changed Trunc to Round to get number of minutes in getDateDiff function.
**       03.09.2008   masamken  ECPD-9495: Update condition statement in getLiftingAccount function.
**       31.05.2010   oonnnng   ECPD-10367: Update getDateDiff() function.
**       29.06.2012   meisihil  ECPD-21412: Add getCarrierLaytime + getCarrierLaytimeDate functions.
**       27.03.2013   leeeewei  ECPD-7256: Renamed Ecbp_Cargo_Numbering to ue_cargo_numbering
**       15.04.2015   muhammah  ECPD-29411: Updated PROCEDURE bdCargoTransport to delete from cargo_protest_list and cargo_protest
**       03.07.2017   asareswi  ECPD-45818: Replaced sysdate with Ecdp_Timestamp.getCurrentSysdate
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
FUNCTION getLiftingAccount(p_cargo_no  NUMBER)
RETURN VARCHAR2
--</EC-DOC>
IS

CURSOR c_company(p_cargo_no NUMBER)IS
SELECT DISTINCT ecdp_objects.GETOBJNAME(lifting_account_id, requested_date) name
FROM storage_lift_nomination pa
WHERE pa.cargo_no = p_cargo_no;

ls_lift_string  VARCHAR2(1000);
ln_count        NUMBER := 1;

BEGIN

FOR CompanyCur IN c_company(p_cargo_no) LOOP
  IF ln_count = 1 THEN
    ls_lift_string := CompanyCur.name;
  ELSIF CompanyCur.name IS NOT NULL THEN
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
FUNCTION getStorages(p_cargo_no  NUMBER)
RETURN VARCHAR2
--</EC-DOC>
IS

CURSOR c_storage(p_cargo_no NUMBER)IS
SELECT DISTINCT ecdp_objects.GETOBJNAME(object_id, nom_firm_date) name
FROM storage_lift_nomination pa
WHERE pa.cargo_no = p_cargo_no;

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
-- Function       : getCargoName
-- Description    : Returns a string containg Cargo Name
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: ue_Cargo_Numbering.getCargoName
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getCargoName(p_cargo_no NUMBER,
					p_parcels VARCHAR2,
					p_forecast_id VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
--</EC-DOC>
IS

ls_cargo_name  VARCHAR2(100);

BEGIN
	-- product specific cargo name
	ls_cargo_name := '';

	-- customer specific cargo name
	 ls_cargo_name := ls_cargo_name || ue_Cargo_Numbering.getCargoName(p_cargo_no, p_parcels, Ecdp_Timestamp.getCurrentSysdate,p_forecast_id);

RETURN ls_cargo_name;

END getCargoName;

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
FUNCTION getCargoNo(p_cargo_name VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS
CURSOR c_cargo(cp_cargo_name VARCHAR2)
IS
SELECT	cargo_no
FROM	cargo_transport
WHERE	cargo_name = cp_cargo_name;

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
FUNCTION getFirstNomDate(p_cargo_no NUMBER)
RETURN DATE
--</EC-DOC>
IS

CURSOR c_date(p_cargo_no NUMBER)IS
SELECT MIN(nom_firm_date) min_nom_date
FROM storage_lift_nomination t
WHERE t.cargo_no = p_cargo_no;

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
FUNCTION getLastNomDate(p_cargo_no NUMBER)
RETURN DATE
--</EC-DOC>
IS
CURSOR c_date(p_cargo_no NUMBER)IS
SELECT MAX(nom_firm_date) max_nom_date
FROM storage_lift_nomination t
WHERE t.cargo_no = p_cargo_no;

ld_max_nom_date	DATE;

BEGIN

	FOR dateCur IN c_date(p_cargo_no) LOOP
		ld_max_nom_date := dateCur.max_nom_date;
	END LOOP;

	RETURN ld_max_nom_date;
END getLastNomDate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDateDiff
-- Description    : returns the elapsed time (in hh:mm:ss format) between two dates
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
FUNCTION getDateDiff(p_from_date IN DATE,
					p_to_date IN DATE)
RETURN VARCHAR2
--</EC-DOC>
IS

ls_date_range VARCHAR2(100);

BEGIN
  ls_date_range:=nvl(ecdp_client_presentation.GetDuration(p_from_date,p_to_date),'');

  RETURN ls_date_range;

END getDateDiff;

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
PROCEDURE cleanLonesomeCargoes
--</EC-DOC>
IS
CURSOR c_lonesome_cargo
IS
SELECT cargo_no
FROM cargo_transport c
WHERE not exists (SELECT 'X' FROM storage_lift_nomination s
                  WHERE s.cargo_no = c.cargo_no);
BEGIN
	FOR curLonesomeCargo IN c_lonesome_cargo LOOP
		-- cleanup
		bdCargoTransport(curLonesomeCargo.cargo_no);

		DELETE FROM cargo_transport
		WHERE cargo_no = curLonesomeCargo.cargo_no;
	END LOOP;

END cleanLonesomeCargoes;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : moveCargo                                  	                                 --
-- Description    : move cargo offset number of days (plus or minus)                             --
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
PROCEDURE moveCargo(p_cargo_no NUMBER, p_day_offset NUMBER, p_fcast_id VARCHAR2)
--</EC-DOC>
IS
CURSOR c_lifting_yes (cp_cargo_no NUMBER)
IS
SELECT 	s.parcel_no
FROM 	storage_lift_nomination s, storage_lifting a
WHERE 	s.parcel_no = a.parcel_no
      AND a.load_value IS NOT NULL
      AND s.cargo_no = cp_cargo_no;
BEGIN
  --DEBUG
  /*
  insert into t_temptext t (id,line_number,text)
  values (
  'MOVE_CARGO',
  (select nvl(max(line_number),0)+1 from t_temptext where id = 'MOVE_CARGO'),
  to_Char(Ecdp_Timestamp.getCurrentSysdate(),'dd-mm-yyyy hh24:mi:ss')|| '. cargo_no=' || p_cargo_no || ' / offset=' || p_day_offset || ' / fcast=' || p_fcast_id );
  */

  --validate BL_numbers
  FOR curLifting IN c_lifting_yes (p_cargo_no) LOOP
        Raise_Application_Error(-20553,'Moving cargo not allowed, Load/unload quantity exists for Cargo Name: ' || ec_cargo_transport.cargo_name(p_cargo_no));
				return;
	END LOOP;

  if p_cargo_no is null or p_cargo_no <=0 then
     Raise_Application_Error(-20000,'Action not allowed. Cargo_No is ' || p_cargo_no);
     return;
  end if;

  if p_day_offset is null or p_day_offset = 0 then
     Raise_Application_Error(-20000,'Action not allowed. Offset is ' || p_day_offset);
     return;
  end if;

  --do updates, either in official tables or in forecast/scenario tables.
  if p_fcast_id is null or p_fcast_id = 'null' or p_fcast_id = 'undefined' then
    update storage_lift_nomination
    set
      requested_date = requested_date + p_day_offset,
      nom_firm_date = nom_firm_date + p_day_offset
    where cargo_no = p_cargo_no;
  else
    update stor_fcst_lift_nom
      set
      requested_date = requested_date + p_day_offset,
      nom_firm_date = nom_firm_date + p_day_offset
    where cargo_no = p_cargo_no
    and forecast_id = p_fcast_id;
  end if;

END moveCargo;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : bdCargoTransport
-- Description    : Instead of using triggers on tables this procedure should be run by
--					instead of triggers on the view layer
--					The trigger deletes tables with constraint to storage_lift_nomination.
--                  See 'using tables'
-- Preconditions  :
-- Postconditions : Uncommited changes
--
-- Using tables   : lifting_activity, cargo_analysis_item, cargo_analysis                                                                                                                          --
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE bdCargoTransport(p_cargo_no NUMBER)
--</EC-DOC>
IS
CURSOR c_analysis (cp_cargo_no NUMBER)
IS
SELECT 	analysis_no
FROM 	cargo_analysis a
WHERE 	cargo_no = cp_cargo_no;

BEGIN
	-- delete lifting activity
	DELETE lifting_activity
	WHERE cargo_no = p_cargo_no;

	-- delete cargo_analysis_item
	FOR curAnalysis IN c_analysis (p_cargo_no) LOOP
		DELETE cargo_analysis_item
		WHERE analysis_no = curAnalysis.analysis_no;
	END LOOP;

	-- delete cargo analysis
	DELETE cargo_analysis
	WHERE cargo_no = p_cargo_no;

	-- delete stor batch
	DELETE cargo_stor_batch_lifting
	WHERE cargo_batch_no in(select cargo_batch_no from cargo_stor_batch WHERE cargo_no = p_cargo_no);

	DELETE cargo_stor_batch
	WHERE cargo_no = p_cargo_no;

	-- exported not lifted
	DELETE stor_period_export_status
	WHERE cargo_no = p_cargo_no;

	-- demurrage
	DELETE cargo_demurrage
	WHERE cargo_no = p_cargo_no;

	-- delay
	DELETE cargo_lifting_delay
	WHERE cargo_no = p_cargo_no;

	-- carrier inspection / ship info and ullage
	DELETE carrier_inspection
	WHERE cargo_no = p_cargo_no;

	-- product carrier figures / ship info and ullage
	DELETE prod_carrier_figures
	WHERE cargo_no = p_cargo_no;

	 --cargo_protest_list
	DELETE cargo_protest_list
	WHERE cargo_no = p_cargo_no;

	-- cargo_protest
	DELETE cargo_protest
	WHERE cargo_no = p_cargo_no;

END bdCargoTransport;

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
							p_new_cargo_status VARCHAR2,
							p_user VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS

BEGIN
	-- if status has changed
	IF  Nvl(p_old_cargo_status,'XXX') <> Nvl(p_new_cargo_status,'XXX') THEN
		EcBp_Cargo_Status.updateCargoStatus(p_cargo_no, p_old_cargo_status, p_new_cargo_status, p_user);
	END IF;

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
FUNCTION isNomSingleCarrier(p_parcels VARCHAR2)
RETURN BOOLEAN
--</EC-DOC>
IS

lv_sql2       VARCHAR2(1000);
ln_carrierNum VARCHAR2(100);
lb_result     BOOLEAN;

BEGIN
  lb_result := TRUE;

  IF Instr(p_parcels, ',', 1) <> 0  THEN -- If parcels contains many items, worth checking
    lv_sql2 := 'SELECT COUNT(DISTINCT carrier_id) FROM storage_lift_nomination WHERE parcel_no IN ' || p_parcels;
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
-- Using tables   : cargo_transport
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
                        p_fin_carrier_id  OUT VARCHAR2)
--</EC-DOC>
IS
  lv_prv_carrier_id VARCHAR2(32);
  lv_sql            VARCHAR2(1000);
  lv_nom_carrier_id VARCHAR2(32);
BEGIN

  -- validate distinct nominated carrier from given parcels
  IF NOT isNomSingleCarrier(p_parcels) THEN
    Raise_Application_Error(-20327,'It is not allowed to nominate same cargo for different carrier.');
  END IF;

  -- get distinct nom_carrier_id shared by all parcels/nominations
  lv_sql := 'SELECT DISTINCT carrier_id FROM storage_lift_nomination WHERE parcel_no IN ' || p_parcels;
  EXECUTE IMMEDIATE lv_sql INTO lv_nom_carrier_id;

  -- get prev_carrier_id if cargo_no is given
  IF p_cargo_no IS NOT NULL THEN
    SELECT ct.carrier_id INTO lv_prv_carrier_id
    FROM cargo_transport ct
    WHERE ct.cargo_no = p_cargo_no;

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
-- Using tables   : cargo_transport
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE copyFwdNominatedCarrier(p_copy_method   VARCHAR2,
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

 	lv_laytime := getCarrierLaytimeDate(p_carrier_id, trunc(Ecdp_Timestamp.getCurrentSysdate));

    -- nominating to new cargo_no
    INSERT INTO cargo_transport (CARGO_NO, CARGO_STATUS, CARGO_NAME, CARRIER_ID, LAYTIME, created_by)
    VALUES (p_cargo_no, lv_cargo_status, p_cargo_name, p_carrier_id, lv_laytime, p_user);

  ELSE
    -- nominating to existing cargo_no
    SELECT ct.carrier_id INTO lv_cargo_carrier_id
      FROM cargo_transport ct WHERE ct.cargo_no = p_cargo_no;

    IF lv_cargo_carrier_id IS NULL THEN
      -- only updating NULL cargo's carrier id and laytime
	  lv_laytime := getCarrierLaytime(p_carrier_id, p_cargo_no);
      UPDATE cargo_transport ct
        SET ct.carrier_id = p_carrier_id,
            ct.laytime = lv_laytime,
            ct.last_updated_by = p_user,
			ct.last_updated_date = Ecdp_Timestamp.getCurrentSysdate
        WHERE ct.cargo_no = p_cargo_no;
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
-- Using tables   : cargo_transport , storage_lift_nomination
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
							p_user VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS

ln_assign_id  NUMBER;
ls_cargoName  VARCHAR2(100);
lv_sql		    VARCHAR2(1000);
ln_validate	  VARCHAR2(100);
lv_carrier_id VARCHAR2(32);

BEGIN
	-- validate nominations
	lv_sql := 'SELECT count(s.parcel_no) FROM storage_lift_nomination s, cargo_transport c WHERE s.cargo_no = c.cargo_no AND c.cargo_status in (select cargo_status from cargo_status_mapping m where m.cargo_status = c.cargo_status and ec_cargo_status in (''C'', ''A'')) AND parcel_no IN ' || p_parcels;
    EXECUTE IMMEDIATE lv_sql INTO ln_validate;
    IF ln_validate > 0 THEN
    	Raise_Application_Error(-20318,'It is not allowed to move a nominations from a cargo that is closed or approved.');
    END IF;

  checkValidNom(p_parcels,p_cargo_no,lv_carrier_id);

	-- create new cargo if cargo no is empty
	IF p_cargo_no IS null THEN
		EcDp_System_Key.assignNextNumber('CARGO_TRANSPORT', ln_assign_id);

		-- get cargo name
		ls_cargoName := getCargoName(ln_assign_id, p_parcels);

  		Copyfwdnominatedcarrier('INSERT',ln_assign_id,lv_carrier_id,ls_cargoName,p_user);

	ELSE
		ln_assign_id := p_cargo_no;
    	Copyfwdnominatedcarrier('UPDATE',ln_assign_id,lv_carrier_id,NULL,p_user);
	END IF;

	-- connect nominations to cargo
	lv_sql := 'UPDATE storage_lift_nomination SET cargo_no = ' || ln_assign_id ||', LAST_UPDATED_BY = '''||p_user||''', LAST_UPDATED_DATE = '''||Ecdp_Timestamp.getCurrentSysdate||''' WHERE parcel_no IN ' || p_parcels;
	EXECUTE IMMEDIATE lv_sql;

	-- clean cargos that no longer have nominations
	cleanLonesomeCargoes;

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
                                  p_user        VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS

BEGIN
   UPDATE storage_lift_nomination sln
   SET sln.carrier_id = p_carrier_id,
       sln.last_updated_by = p_user,
	   sln.last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
	   sln.rev_no = sln.rev_no+1
   WHERE sln.cargo_no = p_cargo_no;

END copyBwdNominatedCarrier;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCarrierName
-- Description    : Retrieve carrier name based on available date
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : cargo_transport
--
-- Using functions: Ecbp_cargo_transport.getLastNomDate,ecdp_objects.GetObjName
--
-- Configuration
-- required       :
--
-- Behaviour      : Data lookup sequence:- ETA_ARRIVAL > TO_NOM_DATE > CURRENT_DATE
--
---------------------------------------------------------------------------------------------------
FUNCTION getCarrierName(p_carrier_id VARCHAR2, p_cargo_no NUMBER)
RETURN VARCHAR2
--<EC-DOC>
IS
  ld_est_arrival  DATE;
  ld_to_nom_date  DATE;

BEGIN
  SELECT ct.est_arrival INTO ld_est_arrival
    FROM cargo_transport ct
    WHERE ct.cargo_no = p_cargo_no;

  ld_to_nom_date := getLastNomDate(p_cargo_no);

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
FUNCTION getCarrierLaytime(p_carrier_id VARCHAR2, p_cargo_no NUMBER)
RETURN VARCHAR2
--<EC-DOC>
IS
	ld_daytime DATE;
	lv_result VARCHAR2(32);

BEGIN
	ld_daytime := ecbp_cargo_transport.getFirstNomDate(p_cargo_no);
	lv_result := getCarrierLaytimeDate(p_carrier_id, NVL(ld_daytime, trunc(Ecdp_Timestamp.getCurrentSysdate)));
	RETURN lv_result;

END getCarrierLaytime;

---------------------------------------------------------------------------------------------------
-- Function       : getCarrierLaytimeDate
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
FUNCTION getCarrierLaytimeDate(p_carrier_id VARCHAR2, p_daytime DATE)
RETURN VARCHAR2
--<EC-DOC>
IS
	ln_capacity_vol NUMBER;
	ln_capacity_mass NUMBER;
	lb_found BOOLEAN := false;
	lv_result VARCHAR2(32);

	CURSOR c_laytime(cp_capacity_vol NUMBER, cp_capacity_mass NUMBER)
	IS
		SELECT laytime
		  FROM laytime_limit
		 WHERE cp_capacity_vol BETWEEN min_vol AND nvl(max_vol, cp_capacity_vol + 1)
		    OR cp_capacity_mass BETWEEN min_vol AND nvl(max_vol, cp_capacity_mass + 1);
BEGIN
	ln_capacity_vol := ec_carrier_version.capacity_vol(p_carrier_id, p_daytime, '<=');
	ln_capacity_mass := ec_carrier_version.capacity_mass(p_carrier_id, p_daytime, '<=');

	FOR c_cur IN c_laytime(ln_capacity_vol, ln_capacity_mass) LOOP
		IF NOT lb_found THEN
			lv_result := c_cur.laytime;
		ELSE
			lv_result := NULL;
		END IF;
		lb_found := true;
	END LOOP;

	RETURN lv_result;

END getCarrierLaytimeDate;

END EcBp_Cargo_Transport;