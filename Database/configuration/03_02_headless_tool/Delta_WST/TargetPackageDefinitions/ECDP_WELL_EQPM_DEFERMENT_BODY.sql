CREATE OR REPLACE PACKAGE BODY EcDp_Well_Eqpm_Deferment IS

/****************************************************************
** Package        :  EcDp_Well_Eqpm_Deferment, header part
**
** $Revision: 1.23.2.12 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to Equipment and Well Deferment.
** Documentation  :  www.energy-components.com
**
** Created  : 11.07.2007  Sarojini Rajaretnam
**
** Modification history:
**
** Version  Date       Whom     Change description:
** -------  ----------  -------- --------------------------------------
**          14-04-2008  rajarsar ECPD-7828: Modified updateEndDateForChildEvent procedure.
**          15-04-2008  oonnnng  ECPD-7825: Add SteamInj in setLossRate, allocateGroupRateToWells, sumFromWells functions.
**          22-04-2008  rajarsar ECPD-7828: Modified updateEndDateForChildEvent procedure.
**          21-05-2008  oonnnng  ECPD-7878: Add updateReasonCodeFOrChildEvent procedure.
**          11-06-2008  oonnnng  ECPD-8621: Add checking of ecdp_well.isWellPhaseActiveStatus() in setLossRate, allocateGroupRateToWells, sumFromWells functions.
**          22-12-2008  leongwen ECPD-7847: New BF: "Well Downtime - by Well" under Equipment and Well Deferment
**          16-02-2009  lauuufus ECPD-11005: Set last_updated_date = last_updated_date in some of the procedures.
**          28-12-2009  leongwen ECPD-13176 Enhancement to Equipment Off deferment screen
**          29-04-2010  rajarsar ECPD-14460: Updated setLossRate to remove update loss rate for parents when child is updated
**          07-05-2010  oonnnng  ECPD-14657: Remove dv_ and ov_ view in insertAffectedWells() function.
**          25-06-2010  farhaann ECPD-14337: Modify allocateGroupRateToWells function
**          19-01-2011  kumarsur ECPD-16603: Modify allocateGroupRateToWells function
**          28-10-2011  rajarsar ECPD-17942: Updated approveWellEqpmDeferment,approveWellEqpmDefermentbyWell,verifyWellEqpmDeferment, verifyWellEqpmDefermentbyWell, setLossRate,allocateGroupRateToWells, sumFromWells, updateEndDateForChildEvent, updateReasonCodeForChildEvent to support new PK which is EVENT_NO.
**          27-02-2012  syazwnur ECPD-17956: Modified approveWellEqpmDefermentbyWell and verifyWellEqpmDefermentbyWell to pass parameter 'downtime_categ' and updated error messange in both procedures.
**          14-05-2012  Genasdev ECPD-20946: Modify set loss rate and sum from well function
**          09-01-2013  wonggkai ECPD-23079: Modified last_updated_date in approveWellEqpmDeferment, approveWellEqpmDefermentbyWell, verifyWellEqpmDeferment, verifyWellEqpmDefermentbyWell,
**                                           allocateGroupRateToWells, updateEndDateForChildEvent, updateReasonCodeForChildEvent.
**                                           Modified updateReasonCodeForChildEvent
**          25-02-2013  leongwen ECPD-23416: Modified sumFromWells
**          11-07-2013  leongwen ECPD-24671: Modified sumFromWells
**          03-01-2014  kumarsur ECPD-26357: Add updateStartDateForChildEvent procedure.
**          15-04-2014  leongwen ECPD-27376: Modified the procedure insertAffectedWells to scan each queried cursor record and check for multiple well versions effect, only take the nearest well version record to the deferment date range.
**          14-04-2014  dhavaalo ECPD-27361: Well Equpment Downtime Event doen't include water loss rate
**          09-06-2014  leongwen ECPD-27376: Modified the procedure insertAffectedWells to include the check with FCTY_CLASS_2_ID, select max object_id from alloc network list in cursor c1_network,
**                                           check the well object with ecdp_well.IsWellOpen function in the loop to speed up the performance.
**          04-09-2014  kumarsur ECPD-28577: Modified the procedure insertAffectedWells apply class trigger action.
****************************************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : approveWellEqpmDeferment
-- Description    : The Procedure approve the records for the selected object within the specified period.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : well_equip_downtime
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : -
--
---------------------------------------------------------------------------------------------------
PROCEDURE approveWellEqpmDeferment(p_event_no NUMBER,
                                   p_user_name VARCHAR2)
--</EC-DOC>
IS

  lv2_last_update_date VARCHAR2(20);

BEGIN
  lv2_last_update_date := to_char(EcDp_Date_Time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')  ;

  -- update parent
  UPDATE well_equip_downtime
     SET record_status='A',
         last_updated_by = p_user_name,
         last_updated_date = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
         rev_text = 'Approved at ' ||  lv2_last_update_date
  WHERE event_no = p_event_no;

  -- update child
  UPDATE well_equip_downtime  wed_child
     SET wed_child.record_status='A',
         last_updated_by = p_user_name,
         last_updated_date = to_date (lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
         rev_text = 'Approved at ' ||   lv2_last_update_date
  WHERE wed_child.parent_event_no = p_event_no;

END approveWellEqpmDeferment;

---------------------------------------------------------------------------------------------------
-- Procedure      : approveWellEqpmDefermentbyWell
-- Description    : The Procedure approve the records for the selected object within the specified period.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : well_equip_downtime
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : -
--
---------------------------------------------------------------------------------------------------
PROCEDURE approveWellEqpmDefermentbyWell(p_event_no NUMBER,
                         p_user_name VARCHAR2,downtime_categ VARCHAR2)
--</EC-DOC>
IS

  lv2_last_update_date VARCHAR2(20);
  lv_Parent_ID                VARCHAR2(32);

BEGIN

  lv_Parent_ID := ec_well_equip_downtime.parent_object_id(p_event_no);

  IF lv_Parent_ID IS NOT NULL then
    IF downtime_categ = 'WELL_OFF' THEN
       RAISE_APPLICATION_ERROR('-20608','Group Child Records cannot be approved here. It should be done at Well Downtime screen.');
    ELSIF downtime_categ = 'WELL_LOW' THEN
       RAISE_APPLICATION_ERROR('-20637','Group Child Records cannot be approved here. It should be done at Well Constraints screen.');
    END IF;

  ELSE
    lv2_last_update_date := to_char(EcDp_Date_Time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')  ;

    -- update parent
    UPDATE well_equip_downtime
       SET record_status='A',
           last_updated_by = p_user_name,
           last_updated_date = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
          rev_text = 'Approved at ' ||  lv2_last_update_date
    WHERE event_no = p_event_no;


    -- update child
    UPDATE well_equip_downtime  wed_child
       SET wed_child.record_status='A',
           last_updated_by = p_user_name,
           last_updated_date = to_date (lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
           rev_text = 'Approved at ' ||   lv2_last_update_date
    WHERE wed_child.parent_event_no = p_event_no;

END IF;

END approveWellEqpmDefermentbyWell;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : verifyWellEqpmDeferment
-- Description    : The Procedure verifies the records for the selected object within the specified period.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : well_equip_downtime
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : -
--
---------------------------------------------------------------------------------------------------
PROCEDURE verifyWellEqpmDeferment(p_event_no NUMBER,
                         p_user_name VARCHAR2)
--</EC-DOC>
IS

  ln_exists NUMBER;
  lv2_last_update_date VARCHAR2(20);

BEGIN
  lv2_last_update_date := to_char(EcDp_Date_Time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')  ;

  SELECT COUNT(*) INTO ln_exists FROM  well_equip_downtime WHERE event_no  = p_event_no
  AND record_status='A';

  IF ln_exists = 0 THEN
  -- Update parent
    UPDATE  well_equip_downtime
       SET record_status='V',
           last_updated_by = p_user_name,
           last_updated_date = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
           rev_text = 'Verified at ' ||  lv2_last_update_date
    WHERE event_no = p_event_no;

  -- update child
    UPDATE well_equip_downtime  wed_child
       SET wed_child.record_status='V',
           last_updated_by = p_user_name,
           last_updated_date = to_date (lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
           rev_text = 'Verified at ' ||  lv2_last_update_date
    WHERE wed_child.parent_event_no = p_event_no;


  ELSE
    RAISE_APPLICATION_ERROR('-20223','Record with Approved status cannot be Verified again.');
  END IF;

END verifyWellEqpmDeferment;

---------------------------------------------------------------------------------------------------
-- Procedure      : verifyWellEqpmDefermentbyWell
-- Description    : The Procedure verifies the records for the selected object within the specified period
--                            for Single Well records only. Group Child records will be rejected.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : well_equip_downtime
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : -
--
---------------------------------------------------------------------------------------------------------
PROCEDURE verifyWellEqpmDefermentbyWell(p_event_no NUMBER,
                         p_user_name VARCHAR2,downtime_categ VARCHAR2)
--</EC-DOC>
IS

  ln_exists NUMBER;
  lv2_last_update_date VARCHAR2(20);
  lv_Parent_ID                VARCHAR2(32);

BEGIN

  lv_Parent_ID := ec_well_equip_downtime.parent_object_id(p_event_no);

  IF lv_Parent_ID IS NOT NULL then
    IF downtime_categ = 'WELL_OFF' THEN
       RAISE_APPLICATION_ERROR('-20607','Group Child Records cannot be verified here. It should be done at Well Downtime screen.');
    ELSIF downtime_categ = 'WELL_LOW' THEN
       RAISE_APPLICATION_ERROR('-20638','Group Child Records cannot be verified here. It should be done at Well Constraints screen.');
    END IF;
  ELSE
    lv2_last_update_date := to_char(EcDp_Date_Time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')  ;

    SELECT COUNT(*) INTO ln_exists FROM  well_equip_downtime WHERE event_no  = p_event_no AND record_status='A';

    IF ln_exists = 0 THEN
    -- Update parent
      UPDATE  well_equip_downtime
         SET record_status='V',
             last_updated_by = p_user_name,
             last_updated_date = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
             rev_text = 'Verified at ' ||  lv2_last_update_date
      WHERE event_no = p_event_no;

    -- update child
      UPDATE well_equip_downtime  wed_child
         SET wed_child.record_status='V',
             last_updated_by = p_user_name,
             last_updated_date = to_date (lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
             rev_text = 'Verified at ' ||  lv2_last_update_date
      WHERE wed_child.parent_event_no = p_event_no;

    ELSE
      RAISE_APPLICATION_ERROR('-20223','Record with Approved status cannot be Verified again.');
   END IF;
END IF;

END verifyWellEqpmDefermentbyWell;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : setLossRate                                                   --
-- Description    : Updates Loss Rates
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : well_equip_downtime
--                                                                                                 --
-- Using functions:
--
--                                                                                                 --
-- Configuration                                                                           --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
PROCEDURE setLossRate (
  p_event_no        NUMBER,
  p_user VARCHAR2)
--</EC-DOC>
IS

  CURSOR c_wed IS
    SELECT *
    FROM well_equip_downtime
    WHERE event_no  = p_event_no;


  CURSOR  c_group_loss  IS
    SELECT sum(wed.oil_loss_rate) tot_oil_loss_rate,
    sum(wed.gas_loss_rate) tot_gas_loss_rate,
    sum(wed.cond_loss_rate) tot_cond_loss_rate,
	sum(wed.water_loss_rate) tot_wat_loss_rate,
    sum(wed.water_inj_loss_rate) tot_wat_inj_loss_rate,
  sum(wed.steam_inj_loss_rate) tot_steam_inj_loss_rate,
    sum(wed.gas_inj_loss_rate) tot_gas_inj_loss_rate
    FROM well_equip_downtime wed
    WHERE wed.parent_event_no = p_event_no
    AND wed.downtime_class_type = 'GROUP_CHILD';

  ln_oil_loss_rate NUMBER := null;
  ln_gas_loss_rate NUMBER := null;
  ln_gas_inj_loss_rate NUMBER := null;
  ln_cond_loss_rate NUMBER := null;
  ln_wat_loss_rate NUMBER := null;
  ln_wat_inj_loss_rate NUMBER := null;
  ln_steam_inj_loss_rate NUMBER := null;
  ln_parent_oil_loss_rate NUMBER ;
  ln_parent_gas_loss_rate NUMBER ;
  ln_parent_gas_inj_loss_rate NUMBER ;
  ln_parent_cond_loss_rate NUMBER ;
  ln_parent_wat_loss_rate NUMBER ;
  ln_parent_wat_inj_loss_rate NUMBER ;
  ln_parent_steam_inj_loss_rate NUMBER ;
  ln_tot_oil_loss_rate NUMBER := null;
  ln_tot_gas_loss_rate NUMBER := null;
  ln_tot_wat_loss_rate NUMBER := null;
  ln_tot_gas_inj_loss_rate NUMBER := null;
  ln_tot_cond_loss_rate NUMBER := null;
  ln_tot_wat_inj_loss_rate NUMBER := null;
  ln_tot_steam_inj_loss_rate NUMBER := null;
  ln_event_loss_oil NUMBER := null;
  ln_event_loss_gas NUMBER := null;
  ln_event_loss_cond NUMBER := null;
  ln_event_loss_water NUMBER := null;
  ln_event_loss_water_inj NUMBER := null;
  ln_event_loss_steam_inj NUMBER := null;
  ln_event_loss_gas_inj NUMBER := null;
  ln_diff     NUMBER := null;
  ln_chk_child NUMBER := null;

  lv2_downtime_type VARCHAR2(32);
  lv2_object_id VARCHAR(32);
  ld_daytime  DATE;

BEGIN

  lv2_object_id := ec_well_equip_downtime.object_id(p_event_no);
  ld_daytime   := ec_well_equip_downtime.daytime(p_event_no);
  FOR c_wed_loss IN c_wed LOOP
    ln_oil_loss_rate := c_wed_loss.oil_loss_rate;
    ln_gas_loss_rate := c_wed_loss.gas_loss_rate;
    ln_gas_inj_loss_rate := c_wed_loss.gas_inj_loss_rate;
    ln_cond_loss_rate := c_wed_loss.cond_loss_rate;
	ln_wat_loss_rate := c_wed_loss.water_loss_rate;
    ln_wat_inj_loss_rate := c_wed_loss.water_inj_loss_rate;
    ln_steam_inj_loss_rate := c_wed_loss.steam_inj_loss_rate;
    lv2_downtime_type := c_wed_loss.downtime_type;
    ln_event_loss_oil := EcBp_Well_Eqpm_Deferment.getParentEventLossRate(p_event_no, 'OIL',c_wed_loss.downtime_type);
    ln_event_loss_gas := EcBp_Well_Eqpm_Deferment.getParentEventLossRate(p_event_no, 'GAS',c_wed_loss.downtime_type);
    ln_event_loss_cond := EcBp_Well_Eqpm_Deferment.getParentEventLossRate(p_event_no, 'COND',c_wed_loss.downtime_type);
	ln_event_loss_water := EcBp_Well_Eqpm_Deferment.getParentEventLossRate(p_event_no, 'WATER',c_wed_loss.downtime_type);
    ln_event_loss_water_inj := EcBp_Well_Eqpm_Deferment.getParentEventLossRate(p_event_no, 'WAT_INJ',c_wed_loss.downtime_type);
    ln_event_loss_steam_inj := EcBp_Well_Eqpm_Deferment.getParentEventLossRate(p_event_no, 'STEAM_INJ',c_wed_loss.downtime_type);
    ln_event_loss_gas_inj := EcBp_Well_Eqpm_Deferment.getParentEventLossRate(p_event_no, 'GAS_INJ',c_wed_loss.downtime_type);
    ln_diff := abs((c_wed_loss.end_date- c_wed_loss.daytime)*24);
   -- lv2_parent_object_id := c_wed_loss.parent_object_id;
   -- ld_parent_daytime := c_wed_loss.parent_daytime;
   SELECT count(1) into ln_chk_child FROM well_equip_downtime WHERE parent_event_no  = p_event_no and (daytime <> c_wed_loss.daytime or end_date <> c_wed_loss.end_date);
  END LOOP;

  IF lv2_downtime_type ='WELL_DT' THEN

  -- This is to check that when the well is NOT INJECTOR and ISPRODCUCER is closed, then Oil, Gas, and Cond's loss rate value will be set to null
    IF ecdp_well.isWellPhaseActiveStatus(lv2_object_id,null,'OPEN',ld_daytime) = 'N' then
       ln_oil_loss_rate := NULL;
       ln_gas_loss_rate := NULL;
       ln_cond_loss_rate := NULL;
	   ln_wat_loss_rate :=NULL;
    END IF;

  -- This is to check that when the well is Gas Injector is closed, then the Gas Injector's loss rate value will be set to null
    IF ecdp_well.isWellPhaseActiveStatus(lv2_object_id,'GI','OPEN',ld_daytime) = 'N' then
       ln_gas_inj_loss_rate := NULL;
    END IF;

  -- This is to check that when the well is Water Injector is closed, then the Water Injector's loss rate value will be set to null
    IF ecdp_well.isWellPhaseActiveStatus(lv2_object_id,'WI','OPEN',ld_daytime) = 'N' then
       ln_wat_inj_loss_rate := NULL;
    END IF;

  -- This is to check that when the well is Steam Injector is closed, then the Steam Injector's loss rate value will be set to null
    IF ecdp_well.isWellPhaseActiveStatus(lv2_object_id,'SI','OPEN',ld_daytime) = 'N' then
       ln_steam_inj_loss_rate := NULL;
    END IF;

    UPDATE well_equip_downtime SET oil_loss_rate = nvl(ln_oil_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(lv2_object_id,null,'OPEN',ld_daytime), 'Y', ecbp_well_potential.findOilProductionPotential(lv2_object_id,ld_daytime),null)),
    gas_loss_rate = nvl(ln_gas_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(lv2_object_id,null,'OPEN',ld_daytime), 'Y', ecbp_well_potential.findGasProductionPotential(lv2_object_id,ld_daytime), null)),
    gas_inj_loss_rate =  nvl(ln_gas_inj_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(lv2_object_id,'GI','OPEN',ld_daytime), 'Y', ecbp_well_potential.findGasInjectionPotential(lv2_object_id,ld_daytime), null)),
    cond_loss_rate = nvl(ln_cond_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(lv2_object_id,null,'OPEN',ld_daytime), 'Y', ecbp_well_potential.findConProductionPotential(lv2_object_id,ld_daytime), null)),
	water_loss_rate = nvl(ln_wat_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(lv2_object_id,null,'OPEN',ld_daytime), 'Y', ecbp_well_potential.findWatProductionPotential(lv2_object_id,ld_daytime), null)),
    water_inj_loss_rate = nvl(ln_wat_inj_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(lv2_object_id,'WI','OPEN',ld_daytime), 'Y', ecbp_well_potential.findWatInjectionPotential(lv2_object_id,ld_daytime), null)),
  steam_inj_loss_rate = nvl(ln_steam_inj_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(lv2_object_id,'SI','OPEN',ld_daytime), 'Y', ecbp_well_potential.findSteamInjectionPotential(lv2_object_id,ld_daytime), null)),
    last_updated_by = p_user
    WHERE event_no  = p_event_no;

  ELSIF (lv2_downtime_type ='GROUP_DT') THEN

    FOR c_wed_parent_loss IN c_wed LOOP
        ln_parent_oil_loss_rate := c_wed_parent_loss.oil_loss_rate;
        ln_parent_gas_loss_rate  := c_wed_parent_loss.gas_loss_rate;
        ln_parent_gas_inj_loss_rate  := c_wed_parent_loss.gas_inj_loss_rate;
        ln_parent_cond_loss_rate := c_wed_parent_loss.cond_loss_rate;
		ln_parent_wat_loss_rate  := c_wed_parent_loss.water_loss_rate;
        ln_parent_wat_inj_loss_rate  := c_wed_parent_loss.water_inj_loss_rate;
    ln_parent_steam_inj_loss_rate  := c_wed_parent_loss.steam_inj_loss_rate;
      END LOOP;

      -- Check total loss rates of all child with the same parent
      FOR  c_group_tot_loss IN c_group_loss LOOP
        IF (ln_chk_child > 0) THEN
            ln_tot_oil_loss_rate := (ln_event_loss_oil * 24/ln_diff);
            ln_tot_gas_loss_rate := (ln_event_loss_gas * 24/ln_diff);
            ln_tot_gas_inj_loss_rate := (ln_event_loss_gas_inj * 24/ln_diff);
            ln_tot_cond_loss_rate := (ln_event_loss_cond * 24/ln_diff);
			ln_tot_wat_loss_rate := (ln_event_loss_water * 24/ln_diff);
            ln_tot_wat_inj_loss_rate := (ln_event_loss_water_inj * 24/ln_diff);
            ln_tot_steam_inj_loss_rate := (ln_event_loss_steam_inj * 24/ln_diff);
        ELSE
           ln_tot_oil_loss_rate     :=  c_group_tot_loss.tot_oil_loss_rate;
           ln_tot_gas_loss_rate     :=  c_group_tot_loss.tot_gas_loss_rate;
           ln_tot_gas_inj_loss_rate :=  c_group_tot_loss.tot_gas_inj_loss_rate;
           ln_tot_cond_loss_rate    :=  c_group_tot_loss.tot_cond_loss_rate;
		   ln_tot_wat_loss_rate     :=  c_group_tot_loss.tot_wat_loss_rate;
           ln_tot_wat_inj_loss_rate :=  c_group_tot_loss.tot_wat_inj_loss_rate;
           ln_tot_steam_inj_loss_rate :=  c_group_tot_loss.tot_steam_inj_loss_rate;
        END IF;
      END LOOP;

      -- Update parent with the value if it's value is not null.
      UPDATE well_equip_downtime
      SET oil_loss_rate =  nvl(ln_parent_oil_loss_rate, ln_tot_oil_loss_rate),
      gas_loss_rate = nvl(ln_parent_gas_loss_rate, ln_tot_gas_loss_rate),
      gas_inj_loss_rate = nvl(ln_parent_gas_inj_loss_rate, ln_tot_gas_inj_loss_rate),
      cond_loss_rate = nvl(ln_parent_cond_loss_rate, ln_tot_cond_loss_rate),
	  water_loss_rate = nvl(ln_parent_wat_loss_rate, ln_tot_wat_loss_rate),
      water_inj_loss_rate = nvl(ln_parent_wat_inj_loss_rate, ln_tot_wat_inj_loss_rate),
    steam_inj_loss_rate = nvl(ln_parent_steam_inj_loss_rate, ln_tot_steam_inj_loss_rate),
      last_updated_by = p_user
      WHERE event_no = p_event_no;

  END IF;

END setLossRate;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : allocateGroupRateToWells
-- Description    : Allocates the group event deferment rate to all affected wells.
--
--
--
--
-- Preconditions  : Loss rate values from parent are allocated to child wells.
--
-- Postconditions : The loss rates of the child wells are updated.
--
-- Using tables   : well_equip_downtime
--
--
--
-- Using functions:
--
-- Configuration
-- required       : -
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE allocateGroupRateToWells(p_event_no NUMBER,
                                   p_user_name VARCHAR2)
--</EC-DOC>
IS
  -- loss rates of parent
  CURSOR c_parent IS
    SELECT * from well_equip_downtime w_parent where w_parent.event_no  = p_event_no;
  -- total loss rates of all child that belongs to that parent
  CURSOR c_dt_potential_total IS

    SELECT sum(OilProductionPotential) as TotalOilProductionPotential,
           sum(GasProductionPotential) as TotalGasProductionPotential,
           sum(GasInjectionPotential) as TotalGasInjectionPotential,
           sum(ConProductionPotential) as TotalConProductionPotential,
		   sum(WaterProductionPotential) as TotalWaterProductionPotential,
           sum(WatInjectionPotential)  as TotalWatInjectionPotential,
           sum(SteamInjectionPotential)  as TotalSteamInjectionPotential

    FROM (
      SELECT well_e_dt.object_id, well_e_dt.daytime,
            nvl(well_e_dt.oil_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_e_dt.object_id,null,'OPEN',well_e_dt.daytime), 'Y', ecbp_well_potential.findOilProductionPotential(well_e_dt.object_id, well_e_dt.daytime), null)) as OilProductionPotential,
            nvl(well_e_dt.gas_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_e_dt.object_id,null,'OPEN',well_e_dt.daytime), 'Y', ecbp_well_potential.findGasProductionPotential(well_e_dt.object_id, well_e_dt.daytime), null)) as GasProductionPotential,
            nvl(well_e_dt.gas_inj_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_e_dt.object_id,'GI','OPEN',well_e_dt.daytime), 'Y', ecbp_well_potential.findGasInjectionPotential(well_e_dt.object_id, well_e_dt.daytime), null)) as GasInjectionPotential,
            nvl(well_e_dt.cond_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_e_dt.object_id,null,'OPEN',well_e_dt.daytime), 'Y', ecbp_well_potential.findConProductionPotential(well_e_dt.object_id, well_e_dt.daytime), null)) as ConProductionPotential,
			nvl(well_e_dt.water_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_e_dt.object_id,null,'OPEN',well_e_dt.daytime), 'Y', ecbp_well_potential.findWatProductionPotential(well_e_dt.object_id, well_e_dt.daytime), null)) as WaterProductionPotential,
            nvl(well_e_dt.water_inj_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_e_dt.object_id,'WI','OPEN',well_e_dt.daytime), 'Y', ecbp_well_potential.findWatInjectionPotential(well_e_dt.object_id, well_e_dt.daytime), null)) as WatInjectionPotential,
            nvl(well_e_dt.steam_inj_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_e_dt.object_id,'SI','OPEN',well_e_dt.daytime), 'Y', ecbp_well_potential.findSteamInjectionPotential(well_e_dt.object_id, well_e_dt.daytime), null)) as SteamInjectionPotential
      FROM well_equip_downtime well_e_dt
      WHERE well_e_dt.parent_event_no = p_event_no);

  -- Loss rate of each child that belongs to that parent
  CURSOR c_dt_potential IS
    SELECT w_epm_dt.object_id, w_epm_dt.daytime, w_epm_dt.end_date,
           nvl(w_epm_dt.oil_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(w_epm_dt.object_id,null,'OPEN',w_epm_dt.daytime), 'Y', ecbp_well_potential.findOilProductionPotential(w_epm_dt.object_id, w_epm_dt.daytime), null)) as OilProductionPotential,
           nvl(w_epm_dt.gas_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(w_epm_dt.object_id,null,'OPEN',w_epm_dt.daytime), 'Y', ecbp_well_potential.findGasProductionPotential(w_epm_dt.object_id, w_epm_dt.daytime), null)) as GasProductionPotential,
           nvl(w_epm_dt.gas_inj_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(w_epm_dt.object_id,'GI','OPEN',w_epm_dt.daytime), 'Y', ecbp_well_potential.findGasInjectionPotential(w_epm_dt.object_id, w_epm_dt.daytime), null)) as GasInjectionPotential,
           nvl(w_epm_dt.cond_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(w_epm_dt.object_id,null,'OPEN',w_epm_dt.daytime), 'Y', ecbp_well_potential.findConProductionPotential(w_epm_dt.object_id, w_epm_dt.daytime), null)) as ConProductionPotential,
		   nvl(w_epm_dt.water_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(w_epm_dt.object_id,null,'OPEN',w_epm_dt.daytime), 'Y', ecbp_well_potential.findWatProductionPotential(w_epm_dt.object_id, w_epm_dt.daytime), null)) as WaterProductionPotential,
           nvl(w_epm_dt.water_inj_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(w_epm_dt.object_id,'WI','OPEN',w_epm_dt.daytime), 'Y', ecbp_well_potential.findWatInjectionPotential(w_epm_dt.object_id, w_epm_dt.daytime), null)) as WatInjectionPotential,
           nvl(w_epm_dt.steam_inj_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(w_epm_dt.object_id,'SI','OPEN',w_epm_dt.daytime), 'Y', ecbp_well_potential.findSteamInjectionPotential(w_epm_dt.object_id, w_epm_dt.daytime), null)) as SteamInjectionPotential
    FROM well_equip_downtime w_epm_dt
    WHERE w_epm_dt.parent_event_no = p_event_no;

  ln_well_oil_rate NUMBER;
  ln_well_gas_rate NUMBER;
  ln_well_cond_rate NUMBER;
  ln_well_water_rate NUMBER;
  ln_well_gas_inj_rate NUMBER;
  ln_well_water_inj_rate NUMBER;
  ln_well_steam_inj_rate NUMBER;
  lv2_object_id VARCHAR(32);
  ld_daytime  DATE;
  lv2_last_update_date VARCHAR2(20);

BEGIN

  lv2_last_update_date := to_char(EcDp_Date_Time.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS');
  ln_well_oil_rate := NULL;
  ln_well_gas_rate := NULL;
  ln_well_gas_inj_rate := NULL;
  ln_well_cond_rate := NULL;
  ln_well_water_rate :=NULL;
  ln_well_water_inj_rate := NULL;
  ln_well_steam_inj_rate := NULL;

  lv2_object_id := ec_well_equip_downtime.object_id(p_event_no);
  ld_daytime   := ec_well_equip_downtime.daytime(p_event_no);
  -- ECPD 13176, Enhancement to Equip Off Deferment, 08.JAN.2010, Leongwen
  -- Followed Henk's comment to check for both Loss Volume and End Date and if one of them is missing, use Loss Rate.
  FOR cur_parent IN c_parent LOOP
    FOR cur_total IN c_dt_potential_total LOOP
      FOR cur_potential IN c_dt_potential LOOP
        IF cur_total.TotalOilProductionPotential IS NOT NULL AND cur_total.TotalOilProductionPotential != 0 THEN
          IF cur_parent.oil_loss_volume  IS NULL OR cur_parent.end_date  IS NULL THEN
            ln_well_oil_rate := cur_parent.oil_loss_rate  * cur_potential.OilProductionPotential/cur_total.TotalOilProductionPotential;
          ELSE
            ln_well_oil_rate := (cur_parent.oil_loss_volume/((cur_potential.end_date - cur_potential.daytime) * 24) * EcDp_Date_Time.getNumHours('WELL',  lv2_object_id, ld_daytime)) * cur_potential.OilProductionPotential/cur_total.TotalOilProductionPotential;
          END IF;
		ELSIF cur_total.TotalOilProductionPotential = 0 THEN
			ln_well_oil_rate := 0;
        END IF;
        IF cur_total.TotalGasProductionPotential IS NOT NULL AND cur_total.TotalGasProductionPotential != 0 THEN
          IF cur_parent.gas_loss_volume  IS NULL OR cur_parent.end_date  IS NULL THEN
            ln_well_gas_rate := cur_parent.gas_loss_rate  * cur_potential.GasProductionPotential/cur_total.TotalGasProductionPotential;
          ELSE
            ln_well_gas_rate := (cur_parent.gas_loss_volume/((cur_potential.end_date - cur_potential.daytime) * 24) * EcDp_Date_Time.getNumHours('WELL',lv2_object_id, ld_daytime)) * cur_potential.GasProductionPotential/cur_total.TotalGasProductionPotential;
          END IF;
		ELSIF cur_total.TotalGasProductionPotential = 0 THEN
			ln_well_gas_rate := 0;
        END IF;
        IF cur_total.TotalGasInjectionPotential IS NOT NULL AND cur_total.TotalGasInjectionPotential != 0 THEN
          IF cur_parent.gas_inj_loss_volume  IS NULL OR cur_parent.end_date  IS NULL THEN
            ln_well_gas_inj_rate := cur_parent.gas_inj_loss_rate  * cur_potential.GasInjectionPotential/cur_total.TotalGasInjectionPotential;
          ELSE
            ln_well_gas_inj_rate := (cur_parent.gas_inj_loss_volume/((cur_potential.end_date - cur_potential.daytime) * 24) * EcDp_Date_Time.getNumHours('WELL',lv2_object_id, ld_daytime)) * cur_potential.GasInjectionPotential/cur_total.TotalGasInjectionPotential;
          END IF;
		ELSIF cur_total.TotalGasInjectionPotential = 0 THEN
			ln_well_gas_inj_rate := 0;
        END IF;
        IF cur_total.TotalConProductionPotential IS NOT NULL AND cur_total.TotalConProductionPotential != 0 THEN
          IF cur_parent.cond_loss_volume  IS NULL OR cur_parent.end_date  IS NULL THEN
            ln_well_cond_rate:= cur_parent.cond_loss_rate  * cur_potential.ConProductionPotential/cur_total.TotalConProductionPotential;
          ELSE
            ln_well_cond_rate:= (cur_parent.cond_loss_volume/((cur_potential.end_date - cur_potential.daytime) * 24) * EcDp_Date_Time.getNumHours('WELL',lv2_object_id, ld_daytime)) * cur_potential.ConProductionPotential/cur_total.TotalConProductionPotential;
          END IF;
		ELSIF cur_total.TotalConProductionPotential = 0 THEN
			ln_well_cond_rate := 0;
        END IF;
		IF cur_total.TotalWaterProductionPotential IS NOT NULL AND cur_total.TotalWaterProductionPotential != 0 THEN
          IF cur_parent.water_loss_volume  IS NULL OR cur_parent.end_date  IS NULL THEN
            ln_well_water_rate:= cur_parent.water_loss_rate  * cur_potential.WaterProductionPotential/cur_total.TotalWaterProductionPotential;
          ELSE
            ln_well_water_rate:= (cur_parent.water_loss_volume/((cur_potential.end_date - cur_potential.daytime) * 24) * EcDp_Date_Time.getNumHours('WELL',lv2_object_id, ld_daytime)) * cur_potential.WaterProductionPotential/cur_total.TotalWaterProductionPotential;
          END IF;
		ELSIF cur_total.TotalWaterProductionPotential = 0 THEN
			ln_well_water_rate := 0;
        END IF;
        IF cur_total.TotalWatInjectionPotential IS NOT NULL AND cur_total.TotalWatInjectionPotential != 0 THEN
          IF cur_parent.water_inj_loss_volume  IS NULL OR cur_parent.end_date  IS NULL THEN
            ln_well_water_inj_rate := cur_parent.water_inj_loss_rate  * cur_potential.WatInjectionPotential/cur_total.TotalWatInjectionPotential;
          ELSE
            ln_well_water_inj_rate := (cur_parent.water_inj_loss_volume/((cur_potential.end_date - cur_potential.daytime) * 24) * EcDp_Date_Time.getNumHours('WELL',lv2_object_id, ld_daytime)) * cur_potential.WatInjectionPotential/cur_total.TotalWatInjectionPotential;
          END IF;
		ELSIF cur_total.TotalWatInjectionPotential = 0 THEN
			ln_well_water_inj_rate := 0;
        END IF;
        IF cur_total.TotalSteamInjectionPotential IS NOT NULL AND cur_total.TotalSteamInjectionPotential != 0 THEN
          IF cur_parent.steam_inj_loss_volume  IS NULL OR cur_parent.end_date  IS NULL THEN
            ln_well_steam_inj_rate := cur_parent.steam_inj_loss_rate  * cur_potential.SteamInjectionPotential/cur_total.TotalSteamInjectionPotential;
          ELSE
            ln_well_steam_inj_rate := (cur_parent.steam_inj_loss_volume/((cur_potential.end_date - cur_potential.daytime) * 24) * EcDp_Date_Time.getNumHours('WELL',lv2_object_id, ld_daytime)) * cur_potential.SteamInjectionPotential/cur_total.TotalSteamInjectionPotential;
          END IF;
		ELSIF cur_total.TotalSteamInjectionPotential = 0 THEN
			ln_well_steam_inj_rate := 0;
        END IF;

        UPDATE well_equip_downtime w
        SET w.oil_loss_rate       = ln_well_oil_rate,
            w.gas_loss_rate       = ln_well_gas_rate,
            w.gas_inj_loss_rate   = ln_well_gas_inj_rate,
            w.cond_loss_rate      = ln_well_cond_rate,
			w.water_loss_rate     = ln_well_water_rate,
            w.water_inj_loss_rate = ln_well_water_inj_rate,
            w.steam_inj_loss_rate = ln_well_steam_inj_rate,
            w.last_updated_by     = p_user_name,
            w.last_updated_date   = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS')
        WHERE w.parent_event_no = p_event_no
        AND w.parent_object_id =  lv2_object_id
        AND w.parent_daytime = ld_daytime
        AND w.object_id = cur_potential.object_id
        AND w.daytime = cur_potential.daytime;

      END LOOP;
    END LOOP;
  END LOOP;

END allocateGroupRateToWells;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : sumFromWells
-- Description    : Sums the loss rates from child events and updates the parent.
--
--
--
-- Preconditions  : --
--
-- Postconditions : Loss rates for parent are updated.
--
-- Using tables   : well_equip_downtime
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE sumFromWells(p_event_no NUMBER, p_user_name VARCHAR2)
--</EC-DOC>
IS

  CURSOR c_wed IS
    SELECT *
    FROM well_equip_downtime
    WHERE event_no  = p_event_no;

  CURSOR c_dt_potential_total IS

    SELECT sum(OilProductionPotential) as TotalOilProductionPotential,
           sum(GasProductionPotential) as TotalGasProductionPotential,
           sum(GasInjectionPotential) as TotalGasInjectionPotential,
           sum(ConProductionPotential) as TotalConProductionPotential,
		   sum(WaterProductionPotential) as TotalWaterProductionPotential,
           sum(WatInjectionPotential)  as TotalWatInjectionPotential,
           sum(SteamInjectionPotential)  as TotalSteamInjectionPotential

    FROM (
      SELECT well_e_dt.object_id, well_e_dt.daytime,
           nvl(well_e_dt.oil_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_e_dt.object_id,null,'OPEN',well_e_dt.daytime), 'Y', ecbp_well_potential.findOilProductionPotential(well_e_dt.object_id, well_e_dt.daytime), null)) as OilProductionPotential,
           nvl(well_e_dt.gas_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_e_dt.object_id,null,'OPEN',well_e_dt.daytime), 'Y', ecbp_well_potential.findGasProductionPotential(well_e_dt.object_id, well_e_dt.daytime), null)) as GasProductionPotential,
           nvl(well_e_dt.gas_inj_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_e_dt.object_id,'GI','OPEN',well_e_dt.daytime), 'Y', ecbp_well_potential.findGasInjectionPotential(well_e_dt.object_id, well_e_dt.daytime), null)) as GasInjectionPotential,
           nvl(well_e_dt.cond_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_e_dt.object_id,null,'OPEN',well_e_dt.daytime), 'Y', ecbp_well_potential.findConProductionPotential(well_e_dt.object_id, well_e_dt.daytime), null)) as ConProductionPotential,
		   nvl(well_e_dt.water_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_e_dt.object_id,null,'OPEN',well_e_dt.daytime), 'Y', ecbp_well_potential.findWatProductionPotential(well_e_dt.object_id, well_e_dt.daytime), null)) as WaterProductionPotential,
           nvl(well_e_dt.water_inj_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_e_dt.object_id,'WI','OPEN',well_e_dt.daytime), 'Y', ecbp_well_potential.findWatInjectionPotential(well_e_dt.object_id, well_e_dt.daytime), null)) as WatInjectionPotential,
           nvl(well_e_dt.steam_inj_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_e_dt.object_id,'SI','OPEN',well_e_dt.daytime), 'Y', ecbp_well_potential.findSteamInjectionPotential(well_e_dt.object_id, well_e_dt.daytime), null)) as SteamInjectionPotential
      FROM well_equip_downtime well_e_dt
      WHERE well_e_dt.parent_event_no = p_event_no
      AND  well_e_dt.downtime_class_type = 'GROUP_CHILD');

  ln_well_oil_rate NUMBER;
  ln_well_gas_rate NUMBER;
  ln_well_cond_rate NUMBER;
  ln_well_water_rate NUMBER;
  ln_well_gas_inj_rate NUMBER;
  ln_well_water_inj_rate NUMBER;
  ln_well_steam_inj_rate NUMBER;
  lv2_object_id VARCHAR(32);
  ld_daytime  DATE;
  ln_event_loss_oil NUMBER := null;
  ln_event_loss_gas NUMBER := null;
  ln_event_loss_cond NUMBER := null;
  ln_event_loss_water NUMBER := null;
  ln_event_loss_water_inj NUMBER := null;
  ln_event_loss_steam_inj NUMBER := null;
  ln_event_loss_gas_inj NUMBER := null;
  ln_diff     NUMBER := null;
  ln_chk_child NUMBER := null;
  ld_chk_parent_end_date DATE;

BEGIN

  FOR c_wed_loss IN c_wed LOOP
    ln_event_loss_oil := EcBp_Well_Eqpm_Deferment.getParentEventLossRate(p_event_no, 'OIL',c_wed_loss.downtime_type);
    ln_event_loss_gas := EcBp_Well_Eqpm_Deferment.getParentEventLossRate(p_event_no, 'GAS',c_wed_loss.downtime_type);
    ln_event_loss_cond := EcBp_Well_Eqpm_Deferment.getParentEventLossRate(p_event_no, 'COND',c_wed_loss.downtime_type);
	ln_event_loss_water := EcBp_Well_Eqpm_Deferment.getParentEventLossRate(p_event_no, 'WATER',c_wed_loss.downtime_type);
    ln_event_loss_water_inj := EcBp_Well_Eqpm_Deferment.getParentEventLossRate(p_event_no, 'WAT_INJ',c_wed_loss.downtime_type);
    ln_event_loss_steam_inj := EcBp_Well_Eqpm_Deferment.getParentEventLossRate(p_event_no, 'STEAM_INJ',c_wed_loss.downtime_type);
    ln_event_loss_gas_inj := EcBp_Well_Eqpm_Deferment.getParentEventLossRate(p_event_no, 'GAS_INJ',c_wed_loss.downtime_type);
    ln_diff := abs((c_wed_loss.end_date- c_wed_loss.daytime)*24);
    ld_chk_parent_end_date := c_wed_loss.end_date;

    SELECT count(1) into ln_chk_child
    FROM well_equip_downtime
    WHERE parent_event_no = p_event_no
    AND parent_daytime = c_wed_loss.daytime
    AND downtime_class_type = 'GROUP_CHILD'
    AND (daytime >= c_wed_loss.daytime OR (end_date < c_wed_loss.end_date OR (c_wed_loss.end_date IS NULL AND end_date IS NOT NULL)));
    -- c_wed_loss.daytime and c_wed_loss.end_date are the parent event start and end daytime

  END LOOP;

  FOR cur_potential IN c_dt_potential_total LOOP
    IF (ln_chk_child > 0) AND
        ld_chk_parent_end_date IS NOT NULL THEN

        ln_well_oil_rate := (ln_event_loss_oil * 24/ln_diff);
        ln_well_gas_rate := (ln_event_loss_gas * 24/ln_diff);
        ln_well_gas_inj_rate := (ln_event_loss_gas_inj * 24/ln_diff);
        ln_well_cond_rate := (ln_event_loss_cond * 24/ln_diff);
        ln_well_water_inj_rate := (ln_event_loss_water_inj * 24/ln_diff);
        ln_well_steam_inj_rate := (ln_event_loss_steam_inj * 24/ln_diff);

     ELSE
        ln_well_oil_rate := cur_potential.totaloilproductionpotential;
        ln_well_gas_rate := cur_potential.totalgasproductionpotential;
        ln_well_gas_inj_rate :=  cur_potential.totalgasinjectionpotential;
        ln_well_cond_rate :=cur_potential.totalconproductionpotential;
		ln_well_water_rate      := cur_potential.totalwaterproductionpotential;
        ln_well_water_inj_rate := cur_potential.totalwatinjectionpotential;
        ln_well_steam_inj_rate := cur_potential.totalsteaminjectionpotential;
     END IF;
  END LOOP;

  UPDATE well_equip_downtime w
  SET w.oil_loss_rate   = ln_well_oil_rate,
  w.gas_loss_rate       = ln_well_gas_rate,
  w.gas_inj_loss_rate   = ln_well_gas_inj_rate,
  w.cond_loss_rate      = ln_well_cond_rate,
  w.water_loss_rate     = ln_well_water_rate,
  w.water_inj_loss_rate = ln_well_water_inj_rate,
  w.steam_inj_loss_rate = ln_well_steam_inj_rate,
  w.last_updated_by = p_user_name
  WHERE w.event_no = p_event_no;

  Ue_Well_Eqpm_Deferment.sumFromWells(p_event_no, p_user_name);

END sumFromWells;

--<EC-DOC>
---------------------------------------------------------------------------------------------------------
-- Procedure      : updateEndDateForWellDeferment
-- Description    : Update end date of chilf if it is null or empty
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : well_equip_downtime
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------------
PROCEDURE updateEndDateForChildEvent(p_event_no NUMBER,
                          p_o_end_date DATE,
                         p_user VARCHAR2 ,
                         p_last_updated_date DATE )
--</EC-DOC>
IS
  CURSOR c_end_date IS
  SELECT wed.end_date
  FROM well_equip_downtime wed
  WHERE wed.event_no = p_event_no;

  ld_parent_end_date DATE;


BEGIN

     FOR cur_end_date IN c_end_date LOOP
        ld_parent_end_date := cur_end_date.end_date;
     END LOOP;

     UPDATE well_equip_downtime
     SET end_date = ld_parent_end_date, last_updated_by =  p_user, last_updated_date = p_last_updated_date
     WHERE parent_event_no = p_event_no
        AND (end_date is null or end_date = '' or end_date = p_o_end_date );


END updateEndDateForChildEvent;

--<EC-DOC>
---------------------------------------------------------------------------------------------------------
-- Procedure      : updateReasonCodeForChildEvent
-- Description    : Update Reason Code of child to be same as parent.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : well_equip_downtime
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------------
PROCEDURE updateReasonCodeForChildEvent(p_event_no NUMBER,
                                        p_user VARCHAR2,
                         p_last_updated_date DATE)
--</EC-DOC>
IS
  CURSOR c_reason_code IS
  SELECT wed.reason_code_1, wed.reason_code_2, wed.reason_code_3, wed.reason_code_4
  FROM well_equip_downtime wed
  WHERE wed.event_no = p_event_no;


 BEGIN

   FOR cur_reason_code IN c_reason_code LOOP
       UPDATE well_equip_downtime
       SET reason_code_1 = cur_reason_code.reason_code_1,
           reason_code_2 = cur_reason_code.reason_code_2,
           reason_code_3 = cur_reason_code.reason_code_3,
           reason_code_4 = cur_reason_code.reason_code_4,
           last_updated_by =  p_user,
       last_updated_date = p_last_updated_date
       WHERE downtime_class_type = 'GROUP_CHILD'
       AND parent_event_no = p_event_no
       AND (nvl(reason_code_1,'null') <> nvl(cur_reason_code.reason_code_1,'null') or
          nvl(reason_code_2,'null') <> nvl(cur_reason_code.reason_code_2,'null') or
          nvl(reason_code_3,'null') <> nvl(cur_reason_code.reason_code_3,'null') or
          nvl(reason_code_4,'null') <> nvl(cur_reason_code.reason_code_4,'null'));

   END LOOP;

END updateReasonCodeForChildEvent;

--<EC-DOC>
---------------------------------------------------------------------------------------------------------
-- Procedure      : insertAffectedWells
-- Description    : Insert the affected Wells to Well Equipment Downtime.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : well_equip_downtime
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------------
PROCEDURE insertAffectedWells(p_type VARCHAR2, p_object_id VARCHAR2, p_daytime DATE, p_end_date DATE DEFAULT NULL, p_username VARCHAR2)
--</EC-DOC>
IS

  CURSOR c1_network IS
  SELECT max(cce.object_id) AS object_id
  FROM calc_collection_element cce, calc_collection c
  WHERE c.object_id = cce.object_id
  AND c.class_name= 'ALLOC_NETWORK'
  AND cce.element_id = p_object_id;

  CURSOR c2_getAllWells (cp2_group_event_no VARCHAR2, cp2_object_id VARCHAR2, cp2_daytime DATE, cp2_end_date DATE, cp2_downtime_categ VARCHAR2, cp2_username VARCHAR2, cp2_alloc_network_id VARCHAR2) IS
  SELECT w.object_id, 'WELL', cp2_group_event_no, cp2_object_id, cp2_daytime, GREATEST(w.start_date, cp2_daytime), LEAST(nvl(w.end_date, cp2_end_date), cp2_end_date), 'WELL_DT',  cp2_downtime_categ, 'GROUP_CHILD', cp2_username
  FROM well w, well_version wv
  WHERE w.object_id = wv.object_id
  AND wv.alloc_flag = 'Y' -- only include wells that are part of allocation network
  AND wv.daytime BETWEEN ec_well_version.prev_equal_daytime(wv.object_id, cp2_daytime)
  AND ec_well_version.prev_equal_daytime(wv.object_id, nvl(cp2_end_date, ecdp_date_time.getCurrentSysdate))
  AND ( wv.OP_FCTY_CLASS_1_ID       = cp2_object_id or
        wv.OP_FCTY_CLASS_2_ID       = cp2_object_id or
        wv.OP_WELL_HOOKUP_ID  = cp2_object_id or
        wv.OP_AREA_ID         = cp2_object_id )
  AND EXISTS (SELECT NULL
              FROM calc_collection_element cce, calc_collection c
              WHERE c.object_id = cce.object_id
              AND c.class_name= 'ALLOC_NETWORK'
              AND (wv.op_well_hookup_id = cce.element_id OR wv.op_fcty_class_1_id = cce.element_id OR wv.op_fcty_class_2_id = cce.element_id)
              AND cce.element_id in (SELECT DISTINCT from_node_id FROM ov_stream START WITH from_node_id = cp2_object_id
                                     CONNECT BY NOCYCLE PRIOR from_node_id=to_node_id)
              AND cce.object_id = cp2_alloc_network_id) -- Alloc network id
  AND NOT EXISTS (SELECT wed.object_id  -- exclude wells already down
                  FROM well_equip_downtime wed
                  WHERE wed.object_id = w.object_id
                  AND   wed.downtime_categ in ('WELL_OFF', 'WELL_LOW')
                  AND   wed.downtime_type in ('WELL_DT', 'GROUP_DT')
                  AND   wed.downtime_class_type in ('SINGLE', 'GROUP_CHILD')
                  AND   wed.daytime >= cp2_daytime AND Nvl(wed.end_date,ecdp_date_time.getCurrentSysdate) <= Nvl(cp2_end_date, ecdp_date_time.getCurrentSysdate))
  ORDER BY w.object_id;

  CURSOR c3_getWellVersions (cp_object_id VARCHAR2, cp3_object_id VARCHAR2, cp3_daytime DATE, cp3_end_date DATE) IS
  SELECT a.daytime, a.end_date
  FROM well_version a
  WHERE a.object_id = cp3_object_id
  AND a.daytime BETWEEN ec_well_version.prev_equal_daytime(a.object_id, cp3_daytime)
  AND ec_well_version.prev_equal_daytime(a.object_id, nvl(cp3_end_date, ecdp_date_time.getCurrentSysdate))
  AND ( a.OP_FCTY_CLASS_1_ID = cp_object_id or
        a.OP_FCTY_CLASS_2_ID = cp_object_id or
        a.OP_WELL_HOOKUP_ID  = cp_object_id or
        a.OP_AREA_ID         = cp_object_id )
  ORDER BY a.daytime;

  CURSOR c4_getChildEvents(cp_group_event_no NUMBER) IS
  SELECT event_no
    FROM WELL_EQUIP_DOWNTIME d
   WHERE d.parent_event_no = cp_group_event_no;

  lv2_downtime_categ            VARCHAR2(32);
  ln_group_event_no             NUMBER;
  ln_WellVersions_cnt           NUMBER;
  ln_Rowcnt                     NUMBER;

  lv2_alloc_netwk_id_c1         VARCHAR2(32);                                   -- Variable  used for holding "c1_..." cursor value

  lv2_object_id_c2              WELL_EQUIP_DOWNTIME.OBJECT_ID%TYPE;             -- Variables used for holding "c2_..." cursor value
  lv2_object_type_c2            WELL_EQUIP_DOWNTIME.OBJECT_TYPE%TYPE;
  ln_parent_event_no_c2         WELL_EQUIP_DOWNTIME.PARENT_EVENT_NO%TYPE;
  lv2_parent_object_id_c2       WELL_EQUIP_DOWNTIME.PARENT_OBJECT_ID%TYPE;
  ld_parent_daytime_c2          WELL_EQUIP_DOWNTIME.PARENT_DAYTIME%TYPE;
  ld_daytime_c2                 WELL_EQUIP_DOWNTIME.DAYTIME%TYPE;
  ld_end_date_c2                WELL_EQUIP_DOWNTIME.END_DATE%TYPE;
  lv2_downtime_type_c2          WELL_EQUIP_DOWNTIME.DOWNTIME_TYPE%TYPE;
  lv2_downtime_categ_c2         WELL_EQUIP_DOWNTIME.DOWNTIME_CATEG%TYPE;
  lv2_downtime_class_type_c2    WELL_EQUIP_DOWNTIME.DOWNTIME_CLASS_TYPE%TYPE;
  lv2_created_by_c2             WELL_EQUIP_DOWNTIME.CREATED_BY%TYPE;

  ld_daytime_c3                 DATE;                                           -- Variables used for holding "c3_..." cursor value
  ld_end_date_c3                DATE;
  lv2_prev_object_id            VARCHAR2(32);
  ln_tmp_event_no               WELL_EQUIP_DOWNTIME.EVENT_NO%TYPE;

  typ_object_id                 t_object_id                   := t_object_id();
  typ_object_type               t_object_type                 := t_object_type();
  typ_parent_event_no           t_parent_event_no             := t_parent_event_no();
  typ_parent_object_id          t_parent_object_id            := t_parent_object_id();
  typ_parent_daytime            t_parent_daytime              := t_parent_daytime();
  typ_daytime                   t_daytime                     := t_daytime();
  typ_end_date                  t_end_date                    := t_end_date();
  typ_downtime_type             t_downtime_type               := t_downtime_type();
  typ_downtime_categ            t_downtime_categ              := t_downtime_categ();
  typ_downtime_class_type       t_downtime_class_type         := t_downtime_class_type();
  typ_created_by                t_created_by                  := t_created_by();

BEGIN

  BEGIN
    SELECT event_no into ln_group_event_no  -- Fetch parent event number to map to CHILD_GROUP records
    FROM well_equip_downtime
    WHERE object_id = p_object_id
    AND   downtime_categ in ('WELL_OFF', 'WELL_LOW')
    AND   downtime_type in ('WELL_DT', 'GROUP_DT')
    AND   downtime_class_type in ('SINGLE', 'GROUP')
    AND   daytime = p_daytime AND Nvl(end_date,ecdp_date_time.getCurrentSysdate) = Nvl(p_end_date, ecdp_date_time.getCurrentSysdate);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN ln_group_event_no := NULL;
  END;

  FOR mycur IN c1_network LOOP
    lv2_alloc_netwk_id_c1 := mycur.object_id;
  END LOOP;

  If p_type = 'WELL_CONSTRAINTS' then
    lv2_downtime_categ := 'WELL_LOW';
  Elsif p_type = 'WELL_DOWNTIME' then
    lv2_downtime_categ := 'WELL_OFF';
  End if;

  ln_Rowcnt := 0;
  OPEN c2_getAllWells(ln_group_event_no, p_object_id,  p_daytime,   p_end_date, lv2_downtime_categ, p_username, lv2_alloc_netwk_id_c1);

  LOOP
    FETCH c2_getAllWells INTO
      lv2_object_id_c2,
      lv2_object_type_c2,
      ln_parent_event_no_c2,
      lv2_parent_object_id_c2,
      ld_parent_daytime_c2,
      ld_daytime_c2,
      ld_end_date_c2,
      lv2_downtime_type_c2,
      lv2_downtime_categ_c2,
      lv2_downtime_class_type_c2,
      lv2_created_by_c2;
    EXIT WHEN c2_getAllWells%NOTFOUND;

    IF lv2_downtime_categ = 'WELL_OFF' THEN
      EcDp_System_Key.assignNextNumber('WELL_EQUIP_DOWNTIME', ln_tmp_event_no);
      EcBp_Well_Eqpm_Deferment.checkIfEventOverlaps(lv2_object_id_c2, ld_daytime_c2, ld_end_date_c2, lv2_downtime_categ_c2, ln_tmp_event_no);
    END IF;

    IF ecdp_well.IsWellOpen(lv2_object_id_c2, p_daytime) = 'Y' THEN -- Only include wells that are open

      IF lv2_prev_object_id IS NULL THEN
        lv2_prev_object_id := lv2_object_id_c2;
      ELSE
        IF lv2_prev_object_id = lv2_object_id_c2 THEN
          goto SKIP_LOOP_A; -- skip the same well object id in the loop when the same well object has multiple versions within the date range.
        ELSE
          lv2_prev_object_id := lv2_object_id_c2;
        END IF;
      END IF;
      ln_Rowcnt := ln_Rowcnt + 1;

      ln_WellVersions_cnt := 0;
      OPEN c3_getWellVersions (p_object_id, lv2_object_id_c2, ld_daytime_c2, ld_end_date_c2);
      LOOP
        FETCH c3_getWellVersions INTO ld_daytime_c3, ld_end_date_c3;
        EXIT WHEN c3_getWellVersions%NOTFOUND;

        ln_WellVersions_cnt := ln_WellVersions_cnt + 1;

        -- Check the correct Well Version's start and end date that related to the Deferment's start and end date
        IF c3_getWellVersions%ROWCOUNT > 1 AND ln_WellVersions_cnt > 1 THEN
          goto SKIP_LOOP_B; -- Skip the remaining rows of the well version, because it needs to avoid the same row to insert and hit the UK constraint violation in the DB commit.
        ELSE
          IF ld_end_date_c3 IS NOT NULL THEN
            IF ld_end_date_c3 <=  p_end_date THEN
              ld_end_date_c2 := ld_end_date_c3;
            END IF;
          END IF;
          IF ld_daytime_c3 >=  p_daytime THEN
            ld_daytime_c2 := ld_daytime_c3;
          END IF;
        END IF;
        <<SKIP_LOOP_B>> NULL;

      END LOOP;
      CLOSE c3_getWellVersions;

      typ_object_id.EXTEND;
      typ_object_type.EXTEND;
      typ_parent_event_no.EXTEND;
      typ_parent_object_id.EXTEND;
      typ_parent_daytime.EXTEND;
      typ_daytime.EXTEND;
      typ_end_date.EXTEND;
      typ_downtime_type.EXTEND;
      typ_downtime_categ.EXTEND;
      typ_downtime_class_type.EXTEND;
      typ_created_by.EXTEND;

      typ_object_id(ln_Rowcnt) :=  lv2_object_id_c2;
      typ_object_type(ln_Rowcnt) := lv2_object_type_c2;
      typ_parent_event_no(ln_Rowcnt) := ln_parent_event_no_c2;
      typ_parent_object_id(ln_Rowcnt) := lv2_parent_object_id_c2;
      typ_parent_daytime(ln_Rowcnt) := ld_parent_daytime_c2;
      typ_daytime(ln_Rowcnt) := ld_daytime_c2;
      typ_end_date(ln_Rowcnt) := ld_end_date_c2;
      typ_downtime_type(ln_Rowcnt) := lv2_downtime_type_c2;
      typ_downtime_categ(ln_Rowcnt) := lv2_downtime_categ_c2;
      typ_downtime_class_type(ln_Rowcnt) := lv2_downtime_class_type_c2;
      typ_created_by(ln_Rowcnt) := lv2_created_by_c2;
      <<SKIP_LOOP_A>> NULL;

    END IF;

  END LOOP;
  CLOSE c2_getAllWells;

  FORALL k IN 1..typ_object_id.COUNT
  INSERT INTO WELL_EQUIP_DOWNTIME
  (object_id, object_type, parent_event_no, parent_object_id, parent_daytime, daytime, end_date,
   downtime_type, downtime_categ, downtime_class_type, created_by)
  VALUES
  (typ_object_id(k), typ_object_type(k), typ_parent_event_no(k), typ_parent_object_id(k), typ_parent_daytime(k), typ_daytime(k), typ_end_date(k),
   typ_downtime_type(k), typ_downtime_categ(k), typ_downtime_class_type(k), typ_created_by(k) );

   FOR lc_getChildEvents IN c4_getChildEvents(ln_parent_event_no_c2) LOOP
     ecdp_Well_Eqpm_Deferment.setLossRate(lc_getChildEvents.Event_No, p_username);
   END LOOP;

END insertAffectedWells;


--<EC-DOC>
---------------------------------------------------------------------------------------------------------
-- Procedure      : updateStartDateForChildEvent
-- Description    : Update start date of child
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : well_equip_downtime
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------------
PROCEDURE updateStartDateForChildEvent(p_event_no NUMBER,
                          p_o_start_date DATE,
                         p_user VARCHAR2 ,
                         p_last_updated_date DATE )
--</EC-DOC>
IS
  CURSOR c_start_date IS
  SELECT wed.daytime
  FROM well_equip_downtime wed
  WHERE wed.event_no = p_event_no;

  ld_parent_start_date DATE;


BEGIN

     FOR cur_start_date IN c_start_date LOOP
        ld_parent_start_date := cur_start_date.daytime;
     END LOOP;

     UPDATE well_equip_downtime
     SET daytime = ld_parent_start_date, last_updated_by =  p_user, last_updated_date = p_last_updated_date
     WHERE parent_event_no = p_event_no
        AND (daytime < p_o_start_date);


END updateStartDateForChildEvent;

END  EcDp_Well_Eqpm_Deferment;