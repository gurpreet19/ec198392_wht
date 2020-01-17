create or replace PACKAGE EcBp_Cargo_Status IS
/**************************************************************************************************
** Package  :  EcBp_Cargo_Status
**
** $Revision: 1.11 $
**
** Purpose  :  This package handles the business logic for changing the cargo status
**
**
**
** General Logic:
**
** Created:     25.10.2004 Kari Sandvik
**
** Modification history:
**
** Date:       Whom: Rev.  Change description:
** ----------  ----- ----  ------------------------------------------------------------------------
** 08.12.2011 leeeewei    ECPD-9104:Cargo Analysis instantiation on insert
** 25.10.2013 leeeewei	  ECPD-6072: Added procedure approvedtoClosed
**************************************************************************************************/

PROCEDURE validate(p_cargo_no VARCHAR2,p_old_cargo_status VARCHAR2,p_new_cargo_status VARCHAR2);

PROCEDURE insertCargoAnalysisItems(p_cargo_no VARCHAR2, p_user VARCHAR2, p_product_id VARCHAR2, p_lifting_event VARCHAR2);

FUNCTION getEcCargoStatus(p_project_cargo_status VARCHAR2) RETURN VARCHAR2;

PROCEDURE updateCargoStatus(p_cargo_no VARCHAR2, p_old_cargo_status VARCHAR2, p_new_cargo_status VARCHAR2, p_user VARCHAR2 DEFAULT NULL);

PROCEDURE approvedToClosed(p_cargo_no VARCHAR2, p_user VARCHAR2);

END EcBp_Cargo_Status;
/

create or replace PACKAGE BODY EcBp_Cargo_Status IS
/**************************************************************************************************
** Package  :  EcBp_Cargo_Status
**
** $Revision: 1.44 $
**
** Purpose  :  This package handles the business logic for changing the cargo status
**
**
**
** General Logic:
**
** Created:     25.10.2004 Kari Sandvik
**
** Modification history:
**
** Date:       Whom:    Rev.  Change description:
** ----------  -----    ----  ------------------------------------------------------------------------
** 01.03.2005  kaurrnar  1.1   Removed references to ec_xxx_attribute packages
** 28.06.2006  zakiiari        TI#4093: Changed several error messages. Refer tracker for full details
** 07.11.2006  kaurrjes  1.3   TI#4706: The word distinct is added to the select statement and where-clause also uses la.instantiate_ind in it's filter in the tentativeToOfficial function
** 15.05.2007  kaurrnar  1.4   ECPD5388: Added curLiftAccAnalItem and checking for Lifting Account Analysis Item record in tentativeToOfficial procedure
** 04.07.2007  kaurrnar  1.5   ECPD4733: Removed c_nom_first_date in tentativeToOfficial procedure and replaced with EcBp_Cargo_Transport.getLastNomDate function call
** 27.10.2011  Jimmy     1.6   ECPD10505: Include update of record status for lifting_activity
** 15.12.2011  Jimmy     1.7   ECPD9104: Cargo Analysis instantiation of items after insert
** 29.08.2013  leeeewei        ECPD-6031: Insert Lifting_Event to Lifting Activity
** 25.10.2013  leeeewei	       ECPD-6072: Added procedure approvedtoClosed
** 25-10-2016  thotesan        ECPD-37786: Modified update statements in officialToClosed,closedToOfficial,closedToApproved,approvedToClosed so that last_updated_date will be populated when function is triggered.
** 02-03-2017  baratmah        ECPD-42732: Added update statment for table storage_lift_nom_split  in officialToClosed,closedToOfficial,closedToApproved,approvedToClosed so that it will update the record status.
** 02.06.2017  asareswi        ECPD-41986: Modified tentativeToOfficial procedure to instantiate port resource usage.
** 11.07.2017  asareswi        ECPD-47288: Added cargo_no in ue_port_resource pkg getPlannedStartTime, getPlannedDuration procedure.
** 19.07.2017  asareswi        ECPD-47474: Modifed getPlannedEndDate input parameter.
** 28-09-2017  baratmah        ECPD-48426 :Modified tentativeToOfficial procedure to call ue package for instantiating port resource usage.
**************************************************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : validate
-- Description    :
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
PROCEDURE validate(p_cargo_no VARCHAR2,
          p_old_cargo_status VARCHAR2,
          p_new_cargo_status VARCHAR2)
--</EC-DOC>
IS

-- cursor to test if there are storage liftings
CURSOR c_lifting_yes (cp_cargo_no NUMBER)
IS
SELECT   s.parcel_no
FROM   storage_lift_nomination s, storage_lifting a
WHERE   s.parcel_no = a.parcel_no
      AND a.load_value IS NOT NULL
      AND s.cargo_no = cp_cargo_no;

-- cursor to test if storage lifting is missing
CURSOR c_lifting_no (cp_cargo_no NUMBER)
IS
SELECT   s.parcel_no
FROM   storage_lift_nomination s, storage_lifting a, product_meas_setup p
WHERE   s.parcel_no = a.parcel_no
      AND a.product_meas_no = p.product_meas_no
      AND p.nom_unit_ind = 'Y'
      AND a.load_value IS NULL
      AND p.LIFTING_EVENT = 'LOAD'
      AND s.cargo_no = cp_cargo_no;

-- cursor used to test if lifting account is closed
CURSOR c_nominations (p_cargo_no NUMBER)
IS
SELECT  lifting_account_id, bl_date
FROM  storage_lift_nomination
WHERE   cargo_no = p_cargo_no;

BEGIN

   IF p_old_cargo_status = 'T' THEN

   IF p_new_cargo_status IN ('C', 'A') THEN
      Raise_Application_Error(-20300,'The Cargo Status cannot change from Tentative or Official to Closed or Approved');
    END IF;

  ELSIF p_old_cargo_status = 'O' THEN

    IF p_new_cargo_status IN ('C', 'A') THEN
      Raise_Application_Error(-20301,'The Cargo Status cannot change from Official to Closed or Approved');
    END IF;

  ELSIF p_old_cargo_status = 'R' THEN

    IF p_new_cargo_status IN ('A') THEN
      Raise_Application_Error(-20321,'The Cargo Status cannot change from Ready for Harbour to Approved');
    ELSIF p_new_cargo_status IN ('T', 'O') THEN
      FOR curLifting IN c_lifting_yes (p_cargo_no) LOOP
        Raise_Application_Error(-20305,'The Cargo Status cannot change to Tentative or Official if nominated lifted value is different than null for one of the nominations');
      END LOOP;
    ELSIF p_new_cargo_status = 'C' THEN
      FOR curLiftingNo IN c_lifting_no (p_cargo_no) LOOP
        Raise_Application_Error(-20306,'The Cargo Status cannot change to Closed if nominated lifted value is empty for one of the nominations');
      END LOOP;
    END IF;

  ELSIF p_old_cargo_status = 'C' THEN
    IF p_new_cargo_status IN ('T', 'D', 'O') THEN
      Raise_Application_Error(-20302,'The Cargo Status cannot change from Closed to Tentative, Official or Cancelled');
    END IF;

    IF p_new_cargo_status = 'R' THEN
      FOR curNom IN c_nominations (p_cargo_no) LOOP
        IF EcBp_Lift_Acc_Balance.isLiftingAccountClosed(curNom.lifting_account_id, curNom.bl_date) = 'Y' THEN
          Raise_Application_Error(-20322,'The Cargo Status cannot change to Ready for Harbour if the lifting account on nomination is closed');
        END IF;
      END LOOP;
    END IF;
  ELSIF p_old_cargo_status = 'A' THEN
    IF p_new_cargo_status IN ('T', 'O', 'D', 'R','C') THEN
      Raise_Application_Error(-20303,'The Cargo Status cannot change from Approved to Tentative, Official, Closed, Ready for Harbour or Cancelled');
    END IF;
  ELSIF p_old_cargo_status = 'D' THEN
    IF p_new_cargo_status IN ('T', 'O', 'C', 'A', 'R') THEN
      Raise_Application_Error(-20304,'The Cargo Status cannot change from Cancelled to Tentative, Official, Ready for Harbour, Closed or Approved');
    END IF;
  END IF;

END validate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : setStorageLifting
-- Description    : Instantiate storage_lifting based on lift_acc_meas_setup and product_meas_setup
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : storage_lifting, product_meas_setup, lift_acc_meas_setup
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE setStorageLifting(p_cargo_no VARCHAR2, p_user VARCHAR2)
--</EC-DOC>
IS

   CURSOR  c_nom (cp_cargo_no NUMBER) IS
SELECT n.parcel_no, n.object_id, v.product_id, n.lifting_account_id
FROM storage_lift_nomination n,
storage s,
stor_version v
WHERE n.cargo_no = cp_cargo_no
      AND n.object_id = s.object_id
AND    s.object_id = v.object_id
AND     v.daytime <= Ecdp_Timestamp.getCurrentSysdate
AND     nvl(v.end_date, Ecdp_Timestamp.getCurrentSysdate+1) > Ecdp_Timestamp.getCurrentSysdate
ORDER BY n.parcel_no;

CURSOR  c_lift_acc_meas (cp_lift_acc_id VARCHAR2, cp_lifting_event VARCHAR2) IS
  SELECT   lm.product_meas_no
  FROM   lift_acc_meas_setup lm,
      product_meas_setup pm
  WHERE lm.object_id = cp_lift_acc_id
  AND lm.product_meas_no = pm.product_meas_no
  AND pm.lifting_event = cp_lifting_event;

CURSOR c_prod_meas (cp_product_id VARCHAR2, cp_lifting_event VARCHAR2)  IS
  SELECT   pm.product_meas_no
  FROM product_meas_setup pm
  WHERE pm.object_id = cp_product_id
  AND pm.lifting_event = cp_lifting_event;

CURSOR c_nom_unit (cp_product_id VARCHAR2, cp_lifting_event VARCHAR2)  IS
  SELECT   pm.product_meas_no
  FROM product_meas_setup pm
  WHERE pm.object_id = cp_product_id
  AND pm.lifting_event = cp_lifting_event
  AND pm.nom_unit_ind = 'Y';

  lv_la_exist  VARCHAR2(1);
  lv_product_meas_no NUMBER;

BEGIN
  -- loop nominaitons
  FOR curNom IN c_nom (p_cargo_no) LOOP
    IF curNom.lifting_account_id IS NULL THEN
      Raise_Application_Error(-20333,'A nomination on the cargo is missing Lifting Account. Lifting Account is mandatory');
    END IF;

    -- Handle LOAD
    lv_la_exist := 'N';
    FOR curLiftAccMeas IN c_lift_acc_meas (curNom.lifting_account_id, 'LOAD') LOOP
      lv_la_exist := 'Y';

      IF(ec_storage_lifting.record_status(curNom.parcel_no, curLiftAccMeas.product_meas_no) IS NULL) THEN
        INSERT INTO storage_lifting (parcel_no, product_meas_no, created_by)
        VALUES (curNom.parcel_no, curLiftAccMeas.product_meas_no, p_user);
      END IF;
    END LOOP;

    IF lv_la_exist = 'N' THEN
      FOR curProdMeas IN c_prod_meas (curNom.product_id, 'LOAD') LOOP
        IF(ec_storage_lifting.record_status(curNom.parcel_no, curProdMeas.product_meas_no) IS NULL) THEN
          INSERT INTO storage_lifting (parcel_no, product_meas_no, created_by)
          VALUES (curNom.parcel_no, curProdMeas.product_meas_no, p_user);
        END IF;
      END LOOP;
    END IF;

    -- verify that nomination unit is present on
    IF lv_la_exist <> 'N' THEN -- antisipate that a product meas always got nomination unit, meaning this test needs only to be done on lift acc
      FOR curProdMeas IN c_nom_unit (curNom.product_id, 'LOAD') LOOP
        lv_product_meas_no := curProdMeas.product_meas_no;
      END LOOP;
      IF(ec_storage_lifting.record_status(curNom.parcel_no, lv_product_meas_no) IS NULL) THEN
        INSERT INTO storage_lifting (parcel_no, product_meas_no, created_by)
        VALUES (curNom.parcel_no, lv_product_meas_no, p_user);
      END IF;
    END IF;

    -- Handle UNLOAD
    lv_la_exist := 'N';
    FOR curLiftAccMeas IN c_lift_acc_meas (curNom.lifting_account_id, 'UNLOAD') LOOP
      lv_la_exist := 'Y';

      IF(ec_storage_lifting.record_status(curNom.parcel_no, curLiftAccMeas.product_meas_no) IS NULL) THEN
        INSERT INTO storage_lifting (parcel_no, product_meas_no, created_by)
        VALUES (curNom.parcel_no, curLiftAccMeas.product_meas_no, p_user);
      END IF;
    END LOOP;

    IF lv_la_exist = 'N' THEN
      FOR curProdMeas IN c_prod_meas (curNom.product_id, 'UNLOAD') LOOP
        IF(ec_storage_lifting.record_status(curNom.parcel_no, curProdMeas.product_meas_no) IS NULL) THEN
          INSERT INTO storage_lifting (parcel_no, product_meas_no, created_by)
          VALUES (curNom.parcel_no, curProdMeas.product_meas_no, p_user);
        END IF;
      END LOOP;
    END IF;

    -- verify that nomination unit is present on
    IF lv_la_exist <> 'N' THEN -- antisipate that a product meas always got nomination unit, meaning this test needs only to be done on lift acc
      FOR curProdMeas IN c_nom_unit (curNom.product_id, 'UNLOAD') LOOP
        lv_product_meas_no := curProdMeas.product_meas_no;
      END LOOP;
      IF(ec_storage_lifting.record_status(curNom.parcel_no, lv_product_meas_no) IS NULL) THEN
        INSERT INTO storage_lifting (parcel_no, product_meas_no, created_by)
        VALUES (curNom.parcel_no, lv_product_meas_no, p_user);
      END IF;
    END IF;

  END LOOP;

END setStorageLifting;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : insertCargoAnalysisItems
-- Description    :
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : cargo_analysis_item
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

PROCEDURE insertCargoAnalysisItems(p_cargo_no VARCHAR2, p_user VARCHAR2, p_product_id VARCHAR2, p_lifting_event VARCHAR2)
IS
     CURSOR  c_analysis_item (cp_product_id VARCHAR2, cp_cargo_no NUMBER, cp_lifting_event VARCHAR2)
     IS
     SELECT   a.analysis_item_code, b.analysis_no
     FROM   product_analysis_item a, cargo_analysis b
     WHERE   a.daytime <= Ecdp_Timestamp.getCurrentSysdate
             AND nvl(a.end_date, Ecdp_Timestamp.getCurrentSysdate + 1) > Ecdp_Timestamp.getCurrentSysdate
             AND a.object_id = cp_product_id
             AND a.lifting_event = cp_lifting_event
             AND b.product_id = cp_product_id
             AND b.lifting_event = cp_lifting_event
             AND b.cargo_no = cp_cargo_no;

     CURSOR  c_lift_acc_analysis_item (cp_product_id VARCHAR2, cp_cargo_no NUMBER, cp_lifting_event VARCHAR2, cp_lifting_account_id VARCHAR2)
     IS
     SELECT  b.analysis_item_code, c.analysis_no
     FROM    lift_acc_analysis_item a, product_analysis_item b, cargo_analysis c
     WHERE   b.daytime <= Ecdp_Timestamp.getCurrentSysdate
             AND nvl(b.end_date, Ecdp_Timestamp.getCurrentSysdate + 1) > Ecdp_Timestamp.getCurrentSysdate
             AND a.object_id = cp_lifting_account_id
             AND a.pai_no = b.pai_no
             AND b.object_id = cp_product_id
             AND b.lifting_event = cp_lifting_event
             AND c.product_id = cp_product_id
             AND c.lifting_event = cp_lifting_event
             AND c.cargo_no = cp_cargo_no;

     CURSOR  c_lift_acc (cp_product_id VARCHAR2, cp_cargo_no NUMBER) IS
     SELECT  n.lifting_account_id
     FROM  storage_lift_nomination n, stor_version s
     WHERE  cargo_no = cp_cargo_no
             AND n.object_id = s.object_id
             AND s.product_id = cp_product_id
             AND s.daytime <= Ecdp_Timestamp.getCurrentSysdate
             AND nvl(s.end_date, Ecdp_Timestamp.getCurrentSysdate+1) > Ecdp_Timestamp.getCurrentSysdate
             GROUP BY n.lifting_account_id;

    lv_lift_event_test VARCHAR2(1);

BEGIN

    -- loop over lifting accounts since they can have different setup.
    -- The items in cargo_analysis item should be a union

    FOR curLiftAcc IN c_lift_acc(p_product_id, p_cargo_no) LOOP
      IF curLiftAcc.lifting_account_id IS NULL THEN
        Raise_Application_Error(-20333,'A nomination on the cargo is missing Lifting Account. Lifting Account is mandatory');
      END IF;

      --check if row exist in Lift_Acc_Analysis_Item table for 'LOAD' or 'UNLOAD' lifting_event
      lv_lift_event_test := 'N';
          FOR curLiftAccAnalItem IN c_lift_acc_analysis_item (p_product_id, p_cargo_no, p_lifting_event, curLiftAcc.lifting_account_id) LOOP
              lv_lift_event_test := 'Y';
              -- Uses ec package instead of cursor. THe hole test antisipate that record_status is always set in insert
              IF (ec_cargo_analysis_item.record_status(curLiftAccAnalItem.analysis_no, curLiftAccAnalItem.analysis_item_code) IS NULL) THEN
                INSERT INTO cargo_analysis_item (analysis_no, analysis_item_code, created_by)
                VALUES (curLiftAccAnalItem.analysis_no, curLiftAccAnalItem.analysis_item_code, p_user);
              END IF;
          END LOOP;

          --if row doesn't exist
          IF lv_lift_event_test = 'N' THEN
              FOR curAnalysisItem IN c_analysis_item (p_product_id, p_cargo_no, p_lifting_event) LOOP
                IF (ec_cargo_analysis_item.record_status(curAnalysisItem.analysis_no, curAnalysisItem.analysis_item_code) IS NULL) THEN
                    INSERT INTO cargo_analysis_item (analysis_no, analysis_item_code, created_by)
                    VALUES (curAnalysisItem.analysis_no, curAnalysisItem.analysis_item_code, p_user);
                  END IF;
              END LOOP;
          END IF;
     END LOOP;
END insertCargoAnalysisItems;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : tentativeToOfficial
-- Description    :
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : lifting_activity, cargo_analysis
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE tentativeToOfficial(p_cargo_no VARCHAR2, p_user VARCHAR2)
--</EC-DOC>
IS

CURSOR c_activity(cp_cargo_no NUMBER)
IS
SELECT activity_code, lifting_event, sort_order
FROM lifting_activity_code
WHERE   start_date <= Ecdp_Timestamp.getCurrentSysdate
        AND nvl(end_date, Ecdp_Timestamp.getCurrentSysdate + 1) > Ecdp_Timestamp.getCurrentSysdate
        AND instantiate_ind = 'Y'
        AND product_id IS NULL
        AND activity_code not in (select activity_code from lifting_activity where cargo_no=cp_cargo_no)
        ORDER BY sort_order;

CURSOR c_activity_prod(cp_cargo_no NUMBER)
IS
SELECT distinct la.activity_code, la.sort_order, la.lifting_event
FROM storage_lift_nomination sln,
storage s,
stor_version sv,
product p,
lifting_activity_code la
WHERE   sln.cargo_no = cp_cargo_no
        AND sln.object_id = s.object_id
        AND s.object_id = sv.object_id
        AND sv.daytime <= Ecdp_Timestamp.getCurrentSysdate
        AND nvl(sv.end_date, Ecdp_Timestamp.getCurrentSysdate+1) > Ecdp_Timestamp.getCurrentSysdate
        AND sv.product_id = p.object_id
        AND p.object_id = la.product_id
        AND la.instantiate_ind = 'Y'
        AND activity_code not in (select activity_code from lifting_activity where cargo_no=cp_cargo_no)
        ORDER BY la.sort_order;

CURSOR c_lifting_event IS
SELECT p.code lifting_event
FROM prosty_codes p
WHERE  p.code_type = 'LIFTING_EVENT';

CURSOR c_analysis_exists (cp_cargo_no NUMBER, cp_lifting_event VARCHAR2) IS
SELECT p.object_id product_id, sln.object_id storage_id
FROM storage_lift_nomination sln,
storage s,
stor_version sv,
product p
WHERE sln.object_id = s.object_id
      AND s.object_id = sv.object_id
      AND sv.daytime <= Ecdp_Timestamp.getCurrentSysdate
      AND nvl(sv.end_date, Ecdp_Timestamp.getCurrentSysdate+1) > Ecdp_Timestamp.getCurrentSysdate
      AND sv.product_id = p.object_id
      AND sln.cargo_no = cp_cargo_no
      AND sln.cargo_no not in (SELECT cargo_no FROM cargo_analysis where cargo_no = cp_cargo_no and lifting_event  = cp_lifting_event)
      GROUP BY p.object_id, sln.object_id;


BEGIN
  -- instantiate storage lifting
  EcBp_Cargo_Status.setStorageLifting(p_cargo_no, p_user);

  -- instantiate lifting activity
  FOR curActivity IN c_activity(p_cargo_no) LOOP
    INSERT INTO lifting_activity (cargo_no, activity_code, lifting_event, run_no, event_no, created_by)
    VALUES (p_cargo_no, curActivity.activity_code, curActivity.lifting_event, 1, curActivity.sort_order, p_user);
  END LOOP;

  -- instantiate lifting activity product
  FOR curActivity_prod IN c_activity_prod (p_cargo_no) LOOP
    INSERT INTO lifting_activity (cargo_no, activity_code, lifting_event, run_no, event_no, created_by)
    VALUES (p_cargo_no, curActivity_prod.activity_code, curActivity_prod.lifting_event, 1, curActivity_prod.sort_order, p_user);
  END LOOP;

  FOR curLifting_event IN c_lifting_event LOOP
    FOR curExists IN c_analysis_exists (p_cargo_no, curLifting_event.lifting_event)LOOP
    INSERT INTO cargo_analysis (cargo_no, daytime, product_id, lifting_event, official_ind, created_by)
         VALUES (p_cargo_no, EcBp_Cargo_Transport.getLastNomDate(p_cargo_no), curExists.product_id, curLifting_event.lifting_event, 'Y', p_user);
    insertCargoAnalysisItems(p_cargo_no, p_user, curExists.Product_Id, curLifting_event.lifting_event);
    END LOOP;
  END LOOP;

  -- instantiate port resource usage template
  ue_port_resource.instantiatePortResTemplate(p_cargo_no, p_user);

END tentativeToOfficial;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : officialToTentative
-- Description    :
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
PROCEDURE officialToTentative(p_cargo_no VARCHAR2)
--</EC-DOC>
IS

CURSOR c_lifting (cp_cargo_no VARCHAR2)
IS
SELECT   parcel_no
FROM  storage_lift_nomination
WHERE  cargo_no = cp_cargo_no;

BEGIN
  -- run before delete trigger.
  EcBp_Cargo_Transport.bdCargoTransport(p_cargo_no);

  -- delete storage lifting
  FOR curLifting IN c_lifting (p_cargo_no) LOOP
    DELETE storage_lifting
    WHERE parcel_no = curLifting.parcel_no;
  END LOOP;

END officialToTentative;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : officialToClosed
-- Description    :  Update record status on tables
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CARGO_TRANSPORT, STORAGE_LIFT_NOMINATION, STORAGE_LIFTING
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE officialToClosed(p_cargo_no VARCHAR2,
            p_user VARCHAR2)
--</EC-DOC>
IS

BEGIN
  UPDATE  cargo_transport
  SET    record_status = 'V', last_updated_by = p_user, last_updated_date = Ecdp_Timestamp.getCurrentSysdate
  WHERE  cargo_no = p_cargo_no;

  UPDATE  storage_lift_nomination
  SET    record_status = 'V', last_updated_by = p_user, last_updated_date = Ecdp_Timestamp.getCurrentSysdate,rev_no = rev_no+1
  WHERE  cargo_no = p_cargo_no;

  UPDATE  storage_lifting
  SET    record_status = 'V', last_updated_by = p_user, last_updated_date = Ecdp_Timestamp.getCurrentSysdate
  WHERE  parcel_no IN (SELECT parcel_no FROM storage_lift_nomination WHERE cargo_no = p_cargo_no) ;

  UPDATE  lifting_activity
  SET   record_status = 'V', last_updated_by = p_user, last_updated_date = Ecdp_Timestamp.getCurrentSysdate
  WHERE  cargo_no = p_cargo_no;

  UPDATE  storage_lift_nom_split
  SET   record_status = 'V', last_updated_by = p_user, last_updated_date = Ecdp_Timestamp.getCurrentSysdate
  WHERE  parcel_no IN (SELECT parcel_no FROM storage_lift_nomination WHERE cargo_no = p_cargo_no);

END officialToClosed;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : closedToOfficial
-- Description    : Update record status on tables
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CARGO_TRANSPORT, STORAGE_LIFT_NOMINATION, STORAGE_LIFTING
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE closedToOfficial(p_cargo_no VARCHAR2, p_user VARCHAR2)
--</EC-DOC>
IS

BEGIN
  UPDATE  cargo_transport
  SET    record_status = 'P', last_updated_by = p_user, last_updated_date = Ecdp_Timestamp.getCurrentSysdate
  WHERE  cargo_no = p_cargo_no;

  UPDATE  storage_lift_nomination
  SET    record_status = 'P', last_updated_by = p_user, last_updated_date = Ecdp_Timestamp.getCurrentSysdate,rev_no = rev_no+1
  WHERE  cargo_no = p_cargo_no;

  UPDATE  storage_lifting
  SET    record_status = 'P', last_updated_by = p_user, last_updated_date = Ecdp_Timestamp.getCurrentSysdate
  WHERE  parcel_no IN (SELECT parcel_no FROM storage_lift_nomination WHERE cargo_no = p_cargo_no) ;

  UPDATE  lifting_activity
  SET   record_status = 'P', last_updated_by = p_user, last_updated_date = Ecdp_Timestamp.getCurrentSysdate
  WHERE   cargo_no = p_cargo_no;

  UPDATE  storage_lift_nom_split
  SET   record_status = 'P', last_updated_by = p_user, last_updated_date = Ecdp_Timestamp.getCurrentSysdate
  WHERE  parcel_no IN (SELECT parcel_no FROM storage_lift_nomination WHERE cargo_no = p_cargo_no);

END closedToOfficial;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : closedToApproved
-- Description    : Update record status on tables
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CARGO_TRANSPORT, STORAGE_LIFT_NOMINATION, STORAGE_LIFTING, CARGO_ACTIVITY
--          : CARGO_ANALYSIS, CARGO_ANALYSIS_ITEM, CARGO_LIFTING_DELAY, CARRIER_INSPECTION
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE closedToApproved(p_cargo_no VARCHAR2, p_user VARCHAR2)
--</EC-DOC>
IS

BEGIN
  UPDATE  cargo_transport
  SET    record_status = 'A', last_updated_by = p_user, last_updated_date = Ecdp_Timestamp.getCurrentSysdate
  WHERE  cargo_no = p_cargo_no;

  UPDATE  storage_lift_nomination
  SET    record_status = 'A', last_updated_by = p_user, last_updated_date = Ecdp_Timestamp.getCurrentSysdate,rev_no = rev_no+1
  WHERE  cargo_no = p_cargo_no;

  UPDATE  storage_lifting
  SET    record_status = 'A', last_updated_by = p_user, last_updated_date = Ecdp_Timestamp.getCurrentSysdate
  WHERE  parcel_no IN (SELECT parcel_no FROM storage_lift_nomination WHERE cargo_no = p_cargo_no) ;

  UPDATE  cargo_activity
  SET    record_status = 'A', last_updated_by = p_user, last_updated_date = Ecdp_Timestamp.getCurrentSysdate
  WHERE  cargo_no = p_cargo_no;

  UPDATE  cargo_analysis
  SET    record_status = 'A', last_updated_by = p_user, last_updated_date = Ecdp_Timestamp.getCurrentSysdate
  WHERE  cargo_no = p_cargo_no;

  UPDATE  cargo_analysis_item
  SET    record_status = 'A', last_updated_by = p_user, last_updated_date = Ecdp_Timestamp.getCurrentSysdate
  WHERE  analysis_no IN (SELECT analysis_no FROM cargo_analysis WHERE cargo_no = p_cargo_no);

  UPDATE  cargo_lifting_delay
  SET    record_status = 'A', last_updated_by = p_user, last_updated_date = Ecdp_Timestamp.getCurrentSysdate
  WHERE  cargo_no = p_cargo_no;

  UPDATE  carrier_inspection
  SET    record_status = 'A', last_updated_by = p_user, last_updated_date = Ecdp_Timestamp.getCurrentSysdate
  WHERE  cargo_no = p_cargo_no;

  UPDATE   lifting_activity
  SET   record_status = 'A', last_updated_by = p_user, last_updated_date = Ecdp_Timestamp.getCurrentSysdate
  WHERE   cargo_no = p_cargo_no;

  UPDATE  storage_lift_nom_split
  SET   record_status = 'A', last_updated_by = p_user, last_updated_date = Ecdp_Timestamp.getCurrentSysdate
  WHERE  parcel_no IN (SELECT parcel_no FROM storage_lift_nomination WHERE cargo_no = p_cargo_no);

END closedToApproved;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getEcCargoStatus
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
FUNCTION getEcCargoStatus(p_project_cargo_status VARCHAR2)

RETURN VARCHAR2
--</EC-DOC>
IS
CURSOR c_status (p_cargo_status VARCHAR2  ) IS
  SELECT ec_cargo_status
  FROM cargo_status_mapping
  WHERE cargo_status = p_cargo_status;

  lv_ec_cargo_status VARCHAR2(1);

BEGIN

  -- get the EC cargo status
  FOR curStatus IN c_status (p_project_cargo_status) LOOP
    lv_ec_cargo_status := curStatus.ec_cargo_status;
  END LOOP;
  RETURN lv_ec_cargo_status;
END getEcCargoStatus;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : updateCargoStatus
-- Description    :
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
PROCEDURE updateCargoStatus(p_cargo_no VARCHAR2,
              p_old_cargo_status VARCHAR2,
              p_new_cargo_status VARCHAR2,
              p_user VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS

  lv_old_cargo_status VARCHAR2(1);
  lv_new_cargo_status VARCHAR2(1);

BEGIN

  -- get the EC cargo status
  lv_old_cargo_status := getEcCargoStatus(p_old_cargo_status);
  lv_new_cargo_status := getEcCargoStatus(p_new_cargo_status);

  -- validate
  validate(p_cargo_no, lv_old_cargo_status, lv_new_cargo_status);

  -- instantiate data
  IF lv_old_cargo_status IN ('T', 'O') AND lv_new_cargo_status = 'R' THEN
    tentativeToOfficial(p_cargo_no, p_user);
  END IF;
  -- delete data
  IF lv_old_cargo_status = 'R' AND lv_new_cargo_status IN ('T', 'O') THEN
    --officialToTentative(p_cargo_no);
    null;
  END IF;

  -- set recordstatus
  IF lv_old_cargo_status = 'R' AND lv_new_cargo_status = 'C' THEN
    officialToClosed(p_cargo_no, p_user);
  END IF;

  IF lv_old_cargo_status = 'C' AND lv_new_cargo_status = 'R' THEN
    closedToOfficial(p_cargo_no, p_user);
  END IF;

  IF lv_old_cargo_status = 'C' AND lv_new_cargo_status = 'A' THEN
    closedToApproved(p_cargo_no, p_user);
  END IF;

  IF lv_old_cargo_status = 'A' AND lv_new_cargo_status = 'C' THEN
    approvedToClosed(p_cargo_no, p_user);
  END IF;

  -- Check if a transfer to EC Revenu should be done
  -- Use cudstomer cargo status and not EC. Transfer data is connected to customer cargo status
  ---ue_Replicate_CargoValues.updateFromCargoStatus(p_cargo_no, p_old_cargo_status, p_new_cargo_status, p_user);
     ue_Replicate_CargoValues.insertFromCargoStatus(p_cargo_no, p_new_cargo_status, p_user);
  
END updateCargoStatus;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : approvedToClosed
-- Description    : Update record status on tables
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CARGO_TRANSPORT, STORAGE_LIFT_NOMINATION, STORAGE_LIFTING, CARGO_ACTIVITY
--          : CARGO_ANALYSIS, CARGO_ANALYSIS_ITEM, CARGO_LIFTING_DELAY, CARRIER_INSPECTION
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE approvedToClosed(p_cargo_no VARCHAR2, p_user VARCHAR2)
--</EC-DOC>
IS

BEGIN
  UPDATE  cargo_transport
  SET    record_status = 'V', last_updated_by = p_user, last_updated_date = Ecdp_Timestamp.getCurrentSysdate
  WHERE  cargo_no = p_cargo_no;

  UPDATE  storage_lift_nomination
  SET    record_status = 'V', last_updated_by = p_user, last_updated_date = Ecdp_Timestamp.getCurrentSysdate
  WHERE  cargo_no = p_cargo_no;

  UPDATE  storage_lifting
  SET    record_status = 'V', last_updated_by = p_user, last_updated_date = Ecdp_Timestamp.getCurrentSysdate
  WHERE  parcel_no IN (SELECT parcel_no FROM storage_lift_nomination WHERE cargo_no = p_cargo_no) ;

  UPDATE  cargo_activity
  SET    record_status = 'V', last_updated_by = p_user, last_updated_date = Ecdp_Timestamp.getCurrentSysdate
  WHERE  cargo_no = p_cargo_no;

  UPDATE  cargo_analysis
  SET    record_status = 'V', last_updated_by = p_user, last_updated_date = Ecdp_Timestamp.getCurrentSysdate
  WHERE  cargo_no = p_cargo_no;

  UPDATE  cargo_analysis_item
  SET    record_status = 'V', last_updated_by = p_user, last_updated_date = Ecdp_Timestamp.getCurrentSysdate
  WHERE  analysis_no IN (SELECT analysis_no FROM cargo_analysis WHERE cargo_no = p_cargo_no);

  UPDATE  cargo_lifting_delay
  SET    record_status = 'V', last_updated_by = p_user, last_updated_date = Ecdp_Timestamp.getCurrentSysdate
  WHERE  cargo_no = p_cargo_no;

  UPDATE  carrier_inspection
  SET    record_status = 'V', last_updated_by = p_user, last_updated_date = Ecdp_Timestamp.getCurrentSysdate
  WHERE  cargo_no = p_cargo_no;

  UPDATE   lifting_activity
  SET   record_status = 'V', last_updated_by = p_user, last_updated_date = Ecdp_Timestamp.getCurrentSysdate
  WHERE   cargo_no = p_cargo_no;

  UPDATE  storage_lift_nom_split
  SET   record_status = 'V', last_updated_by = p_user, last_updated_date = Ecdp_Timestamp.getCurrentSysdate
  WHERE  parcel_no IN (SELECT parcel_no FROM storage_lift_nomination WHERE cargo_no = p_cargo_no);

END approvedToClosed;

END EcBp_Cargo_Status;
/