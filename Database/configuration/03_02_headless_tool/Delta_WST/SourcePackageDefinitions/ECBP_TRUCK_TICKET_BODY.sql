CREATE OR REPLACE PACKAGE BODY EcBp_Truck_Ticket IS

/****************************************************************
** Package        :  EcBp_Truck_Ticket; body part
**
** $Revision: 1.26 $
**
** Purpose        :  This package is responsible for calculations directly related
**                   to truck ticket operations, consisting of single transfer and
**                   stream-to/from-well transfer events.
**
** Documentation  :  www.energy-components.com
**
** Created        :  28.03.2006  Nik Eizwan Nik Sufian
**
** Modification history:
**
** Version  Date        Whom         Change description:
** -------  ----------  --------     --------------------------------------
** 1.0      28.03.2006  eizwanik     First version
** 2.0      04.04.2006  chongjer     Minor bug fix
** 3.0      10.05.2006  vikaaroa     Small fix
** 4.0      10.05.2006  vikaaroa     Fix in cursor for method prorateTruckedWellLoadOil
** 5.0      04.09.2007  Lau          Modified prorateTruckedWellProd and prorateTruckedWellLoadOil
** 6.0      12.02.2008  kaurrjes     ECPD-7121: Modified function: prorateTruckedWellProd and prorateTruckedWellLoadOil.
**          06.01.2010  embonhaf     ECPD-13470: Added call to Ue_Truck_Ticket package to modify proration calculations
**          04.02.2010  leongsei     ECPD-13197: Modified function prorateTruckedWellProd and prorateTruckedWellLoadOil to EcBp_Stream_TruckTicket
**          01.09.2010  rajarsar     ECPD-13213: Modified function: prorateTruckedWellProd and prorateTruckedWellLoadOil
**          07.10.2010  sharawan     ECPD-14895: Add deleteChildEvent procedure and countChildEvent function.
**          11.02.2011  farhaann	 ECPD-13292: Added verifyTicket, findNetStdVol, getBswVolFrac, findGrsStdVol and findWatVol
**          30.07.2012  kumarsur	 ECPD-21449: Added findLiqGrsMass, findSandMass, findSandVol and calcDensity. Modified findGrsStdVol and findWatVol.
**          07.08.2012  limmmchu	 ECPD-21449: Modified findLiqGrsMass to remove IF statement
**          13.09.2012  limmmchu	 ECPD-21449: Updated findNetStdVol,findGrsStdVol, findWatVol,findSandVol and calcDensity.
**          04.01.2013  musthram	 ECPD-22805: Updated getBswVolFrac.
**          29.05.2013	rajarsar 	 ECPD-21876: Updated all existing functions and added findOilDensity,findWaterDensity, findSandDensity, findBSWVolFrac, findBswWtFrac and volumeCorrFactor.
**          20.06.2013	rajarsar 	 ECPD-21876: Added findWellStdVol, findWellWaterVol,findWellNetStdMass and findWellGrsStdMass.
**          17.09.2013	rajarsar 	 ECPD-24491: Updated findOilDensity so that density for stream is supported correctly.
**          03.10.2014  kumarsur	 ECPD-28882: Remove commit in functions.
**          31.03.2016	shindani	 ECPD-31221: Added findWellGrsStdVol,findWellBSWVolFrac. Modified findWellStdVol,findWellWaterVol.
*****************************************************************/


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : prorateTruckedWellProd
-- Description    : Calculates well prorated gross, net and water volumes for trucked well oil production.
--                  The result is that the well volumes will sum up to the
--                  gross, net and water volume on the receiving stream (target stream).
--                  This function is used by PO.0046
--
-- Preconditions  : Stream volumes and well volumes have been registered
-- Postcondition  :
-- Using Tables   : well_transport_event, strm_transport_event, strm_version
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE prorateTruckedWellProd(
                p_startdate       DATE,
                p_end_date        DATE,
                p_facility_id     VARCHAR2)

IS

ln_well_grs_oil_adj         NUMBER;
ln_well_net_oil_adj         NUMBER;
ln_well_water_adj           NUMBER;
ln_tot_batch_well_netvol    NUMBER;
ln_tot_batch_well_water     NUMBER;
ln_tot_batch_well_grs       NUMBER;
ln_strm_net_vol             NUMBER;
ln_strm_net_mass            NUMBER;
ln_total_received_water     NUMBER;
ln_total_received_watermass NUMBER;
ln_well_grs_mass_adj        NUMBER;
ln_well_net_mass_adj        NUMBER;
ln_well_water_mass_adj      NUMBER;
ln_tot_batch_well_grsmass   NUMBER;
ln_tot_batch_well_netmass   NUMBER;
ln_tot_batch_well_watermass NUMBER;



CURSOR c_batch IS
   SELECT
   se.event_no,
   se.daytime,
   se.object_id,
   se.grs_vol_adj as strm_grsvol,
   NVL(se.water_vol,0) as freeWater,
   we.object_id as well_id,
   we.daytime as well_event_daytime,
   we.grs_vol as well_grsvol,
   we.grs_vol * (1-we.bs_w) as well_netvol,
   we.grs_vol * we.bs_w well_water,
   se.grs_mass_adj as strm_grsmass,
   NVL(se.water_mass,0) as freeWaterMass,
   we.grs_mass as well_grsmass,
   we.grs_mass * (1-we.bs_w_wt) as well_netmass,
   we.grs_mass * we.bs_w_wt well_watermass
   FROM well_transport_event we, strm_transport_event se, strm_version sv
   where we.event_no = se.event_no
   and se.production_day between p_startdate and p_end_date
   and sv.object_id = se.object_id
   and sv.daytime <= p_end_date
   and (sv.end_date > p_end_date OR sv.end_date IS NULL)
   and se.data_class_name = 'STRM_LOAD_FROM_WELLS'
   and we.data_class_name = 'WELL_LOAD_TO_STRM'
   and sv.op_fcty_class_1_id = p_facility_id;


CURSOR c_batch_totals IS
   SELECT
   se.event_no,
   sum(we.grs_vol) as total_grs_vol,
   sum(we.grs_vol * (1-we.bs_w)) as total_well_netvol,
   sum(we.grs_vol * we.bs_w) as total_well_water,
   sum(we.grs_mass) as total_grs_mass,
   sum(we.grs_mass * (1-we.bs_w_wt)) as total_well_netmass,
   sum(we.grs_mass * we.bs_w_wt) as total_well_watermass
   FROM well_transport_event we, strm_transport_event se, strm_version sv
   where we.event_no = se.event_no
   and sv.object_id = se.object_id
   and sv.daytime <= p_end_date
   and (sv.end_date > p_end_date OR sv.end_date IS NULL)
   and se.production_day between p_startdate and p_end_date
   and se.data_class_name = 'STRM_LOAD_FROM_WELLS'
   and we.data_class_name = 'WELL_LOAD_TO_STRM'
   and sv.op_fcty_class_1_id = p_facility_id
   group by se.event_no;


BEGIN

   FOR mycur IN c_batch LOOP

       ln_strm_net_vol :=  findnetstdvol(mycur.event_no);
       ln_strm_net_mass :=  findnetstdmass(mycur.event_no);
       ln_total_received_water :=  findWatVol(mycur.event_no)+ mycur.freeWater;
-- replace       ln_total_received_watermass := EcBp_Truck_Ticket.findWatMass(mycur.event_no)+ mycur.freeWaterMass;
       ln_total_received_watermass := EcBp_Truck_Ticket.findWatMass(mycur.event_no);

       IF (ln_strm_net_vol >= 0) THEN

         ln_well_grs_oil_adj := NULL;
         ln_well_net_oil_adj := NULL;
         ln_well_water_adj := NULL;

          FOR mycur2 IN c_batch_totals LOOP
            IF(mycur2.event_no = mycur.event_no) THEN
               ln_tot_batch_well_grs := mycur2.total_grs_vol;
               ln_tot_batch_well_netvol := mycur2.total_well_netvol;
               ln_tot_batch_well_water := mycur2.total_well_water;
               EXIT;
            END IF;
          END LOOP;

          -- Calculate prorated well gross volume
          IF( ln_tot_batch_well_grs > 0) THEN
            ln_well_grs_oil_adj := (mycur.well_grsvol/ln_tot_batch_well_grs) * mycur.strm_grsvol;
          ELSIF (ln_tot_batch_well_grs = 0) THEN
            ln_well_grs_oil_adj :=0;
          END IF;

          -- Calculate prorated well net oil volume
          IF( ln_tot_batch_well_netvol > 0) THEN
            ln_well_net_oil_adj := (mycur.well_netvol/ln_tot_batch_well_netvol) * ln_strm_net_vol;
          ELSIF (ln_tot_batch_well_netvol = 0) THEN
            ln_well_net_oil_adj :=0;
          END IF;

          -- Calculate prorated well water volume
          IF(ln_tot_batch_well_water > 0) THEN
            ln_well_water_adj := (mycur.well_water/ln_tot_batch_well_water) * ln_total_received_water;
          ELSIF (ln_tot_batch_well_water = 0) THEN
            ln_well_water_adj :=0;
          END IF;


          IF( ln_well_grs_oil_adj IS NOT NULL OR ln_well_net_oil_adj IS NOT NULL OR ln_well_water_adj IS NOT NULL) THEN

            UPDATE well_transport_event w
            SET w.grs_vol_adj = ln_well_grs_oil_adj,
                w.net_vol_adj = ln_well_net_oil_adj,
                w.water_vol_adj = ln_well_water_adj
            WHERE w.object_id = mycur.well_id
            AND w.event_no = mycur.event_no
            AND w.daytime = mycur.well_event_daytime;


          END IF;

       END IF;

       IF (ln_strm_net_mass >= 0) THEN

         ln_well_grs_mass_adj := NULL;
         ln_well_net_mass_adj := NULL;
         ln_well_water_mass_adj := NULL;

          FOR mycur2 IN c_batch_totals LOOP
            IF(mycur2.event_no = mycur.event_no) THEN
               ln_tot_batch_well_grsmass := mycur2.total_grs_mass;
               ln_tot_batch_well_netmass := mycur2.total_well_netmass;
               ln_tot_batch_well_watermass := mycur2.total_well_watermass;
               EXIT;
            END IF;
          END LOOP;

          -- Calculate prorated well gross mass
          IF( ln_tot_batch_well_grsmass > 0) THEN
            ln_well_grs_mass_adj := (mycur.well_grsmass/ln_tot_batch_well_grsmass) * mycur.strm_grsmass;
          ELSIF (ln_tot_batch_well_grsmass = 0)THEN
            ln_well_grs_mass_adj := 0;
          END IF;

          -- Calculate prorated well net oil msss either from mass input or from volume input.
          IF( ln_tot_batch_well_netmass > 0) THEN
            ln_well_net_mass_adj := (mycur.well_netmass/ln_tot_batch_well_netmass) * ln_strm_net_mass;
          ELSIF (ln_tot_batch_well_netmass = 0)THEN
            ln_well_net_mass_adj := 0;
          END IF;

          -- If the result is null, then calculate net_mass from net_vol.
          IF( ln_well_net_mass_adj is null AND ln_tot_batch_well_netvol > 0) THEN
            ln_well_net_mass_adj := (mycur.well_netvol/ln_tot_batch_well_netvol) * ln_strm_net_mass;
          ELSIF (ln_tot_batch_well_netvol = 0) THEN
             ln_well_net_mass_adj := 0;
          END IF;

          -- Calculate prorated well water mass
          IF(ln_tot_batch_well_watermass > 0) THEN
            ln_well_water_mass_adj := (mycur.well_watermass/ln_tot_batch_well_watermass) * ln_total_received_watermass;
          ELSIF (ln_tot_batch_well_watermass = 0) THEN
            ln_well_water_mass_adj := 0;
          END IF;


          IF( ln_well_grs_mass_adj IS NOT NULL OR ln_well_net_mass_adj IS NOT NULL OR ln_well_water_mass_adj IS NOT NULL) THEN

            UPDATE well_transport_event w
            SET w.grs_mass_adj = ln_well_grs_mass_adj,
                w.net_mass_adj = ln_well_net_mass_adj,
                w.water_mass_adj = ln_well_water_mass_adj
            WHERE w.object_id = mycur.well_id
            AND w.event_no = mycur.event_no
            AND w.daytime = mycur.well_event_daytime;


          END IF;

       END IF;

    END LOOP;

    -- Finally call user exit functionality --
    Ue_Truck_Ticket.prorateTruckedWellProd(p_startdate, p_end_date, p_facility_id);

END prorateTruckedWellProd;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : prorateTruckedWellLoadOil
-- Description    : Calculates well prorated gross, net and water volumes for trucked well oil production.
--                  The result is that the well prorated volumes will sum up to the
--                  gross, net and water volume on the source stream.
--                  This function is used by PO.0045
--
-- Preconditions  : Stream volumes and well volumes have been registered
-- Postcondition  :
-- Using Tables   : well_transport_event, strm_transport_event, strm_version
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE prorateTruckedWellLoadOil(
                p_facility_id     VARCHAR2,
                p_startday        DATE,
                p_endday         DATE)
IS

ln_well_grs_oil_adj         NUMBER;
ln_well_net_oil_adj         NUMBER;
ln_well_water_adj           NUMBER;
ln_tot_batch_well_netvol    NUMBER;
ln_tot_batch_well_water     NUMBER;
ln_tot_batch_well_grs       NUMBER;
ln_strm_netvol              NUMBER;
ln_strm_water_vol           NUMBER;
ln_well_grs_mass_adj         NUMBER;
ln_well_net_mass_adj         NUMBER;
ln_well_water_mass_adj       NUMBER;
ln_tot_batch_well_netmass    NUMBER;
ln_tot_batch_well_watermass  NUMBER;
ln_tot_batch_well_grsmass    NUMBER;
ln_strm_netmass              NUMBER;
ln_strm_water_mass           NUMBER;

CURSOR c_batch(
                cp_facility_id     VARCHAR2,
                cp_startday        DATE,
                cp_endday          DATE)
IS
   SELECT
   se.event_no,
   se.object_id,
   se.daytime,
   se.grs_vol_adj as strm_grsvol,
   we.object_id as well_id,
   we.daytime as well_event_daytime,
   we.grs_vol as well_grsvol,
   we.grs_vol * (1-se.bs_w) as well_netvol,
   we.grs_vol * se.bs_w well_water,
   se.grs_mass_adj as strm_grsmass,
   we.grs_mass as well_grsmass,
   we.grs_mass * (1-se.bs_w_wt) as well_netmass,
   we.grs_mass * se.bs_w_wt well_watermass
   FROM well_transport_event we, strm_transport_event se, strm_version sv
   where we.event_no = se.event_no
   and se.production_day between cp_startday and cp_endday
   and sv.object_id = se.object_id
   and sv.daytime <= cp_endday
   and (sv.end_date > cp_endday OR sv.end_date IS NULL)
   and se.data_class_name = 'STRM_LOAD_TO_WELLS'
   and we.data_class_name = 'WELL_LOADED_FROM_TRUCK'
   and sv.op_fcty_class_1_id = cp_facility_id;


CURSOR c_batch_totals(cp_event_no NUMBER) IS
   SELECT
   sum(we.grs_vol) as total_grs_vol,
   sum(we.grs_vol * (1- se.bs_w)) as total_well_netvol,
   sum(we.grs_vol * se.bs_w) as total_well_water,
   sum(we.grs_mass) as total_grs_mass,
   sum(we.grs_mass * (1- se.bs_w_wt)) as total_well_netmass,
   sum(we.grs_mass * se.bs_w_wt) as total_well_watermass
   FROM well_transport_event we, strm_transport_event se
   where we.event_no = se.event_no
   and we.event_no = cp_event_no
   group by se.event_no;


BEGIN


  FOR mycur IN c_batch(p_facility_id, p_startday,p_endday) LOOP
    ln_strm_netvol     :=  findnetstdvol(mycur.event_no);
    ln_strm_water_vol  :=  findWatVol(mycur.event_no);
    ln_strm_netmass    :=  findnetstdMass(mycur.event_no);
    ln_strm_water_mass :=  findWatMass(mycur.event_no);

    IF (ln_strm_netvol >= 0) THEN

     ln_well_grs_oil_adj := NULL;
     ln_well_net_oil_adj := NULL;
     ln_well_water_adj := NULL;

      FOR mycur2 IN c_batch_totals(mycur.event_no) LOOP
        ln_tot_batch_well_grs := mycur2.total_grs_vol;
        ln_tot_batch_well_netvol := mycur2.total_well_netvol;
        ln_tot_batch_well_water := mycur2.total_well_water;
        EXIT;
      END LOOP;

      -- Calculate prorated well gross volume
      IF( ln_tot_batch_well_grs > 0) THEN
        ln_well_grs_oil_adj := (mycur.well_grsvol/ln_tot_batch_well_grs) * mycur.strm_grsvol;
      ELSIF (ln_tot_batch_well_grs = 0) THEN
        ln_well_grs_oil_adj := 0;
      END IF;

      -- Calculate prorated well net oil volume
      IF( ln_tot_batch_well_netvol > 0) THEN
        ln_well_net_oil_adj := (mycur.well_netvol/ln_tot_batch_well_netvol) * ln_strm_netvol;
      ELSIF (ln_tot_batch_well_netvol = 0) THEN
        ln_well_net_oil_adj :=0;
      END IF;

      -- Calculate prorated well water volume
      IF(ln_tot_batch_well_water > 0) THEN
        ln_well_water_adj := (mycur.well_water/ln_tot_batch_well_water) * ln_strm_water_vol;
      ELSIF (ln_tot_batch_well_water = 0) THEN
        ln_well_water_adj := 0;
      END IF;


      IF( ln_well_grs_oil_adj IS NOT NULL OR ln_well_net_oil_adj IS NOT NULL OR ln_well_water_adj IS NOT NULL) THEN

        UPDATE well_transport_event w
        SET w.grs_vol_adj = ln_well_grs_oil_adj,
        w.net_vol_adj = ln_well_net_oil_adj,
        w.water_vol_adj = ln_well_water_adj
        WHERE w.object_id = mycur.well_id
        AND w.event_no = mycur.event_no
        AND w.daytime = mycur.well_event_daytime;


      END IF;

    END IF;

    IF (ln_strm_netmass >= 0) THEN

     ln_well_grs_mass_adj := NULL;
     ln_well_net_mass_adj := NULL;
     ln_well_water_mass_adj := NULL;

      FOR mycur2 IN c_batch_totals(mycur.event_no) LOOP
        ln_tot_batch_well_grsmass := mycur2.total_grs_mass;
        ln_tot_batch_well_netmass := mycur2.total_well_netmass;
        ln_tot_batch_well_watermass:= mycur2.total_well_watermass;
        EXIT;
      END LOOP;

      -- Calculate prorated well gross mass
      IF( ln_tot_batch_well_grsmass > 0) THEN
        ln_well_grs_mass_adj := (mycur.well_grsmass/ln_tot_batch_well_grsmass) * mycur.strm_grsmass;
      ELSIF ( ln_tot_batch_well_grsmass = 0) THEN
        ln_well_grs_mass_adj := 0;
      END IF;

      -- Calculate prorated well net oil mass either from mass input or from volume input.
      IF( ln_tot_batch_well_netmass > 0) THEN
        ln_well_net_mass_adj := (mycur.well_netmass/ln_tot_batch_well_netmass) * ln_strm_netmass;
      ELSIF ( ln_tot_batch_well_netmass = 0) THEN
        ln_well_net_mass_adj := 0;
      END IF;

      -- If the result is null, then calculate net_mass from net_vol.
      IF( ln_well_net_mass_adj is null AND ln_tot_batch_well_netvol > 0) THEN
        ln_well_net_mass_adj := (mycur.well_netvol/ln_tot_batch_well_netvol) * ln_strm_netmass;
      ELSIF (ln_tot_batch_well_netvol = 0) THEN
        ln_well_net_mass_adj := 0;
      END IF;

      -- Calculate prorated well water mass
      IF(ln_tot_batch_well_watermass > 0) THEN
        ln_well_water_mass_adj := (mycur.well_watermass/ln_tot_batch_well_watermass) * ln_strm_water_mass;
      ELSIF ((ln_tot_batch_well_watermass = 0)) THEN
        ln_well_water_mass_adj := 0;
      END IF;


      IF( ln_well_grs_mass_adj IS NOT NULL OR ln_well_net_mass_adj IS NOT NULL OR ln_well_water_mass_adj IS NOT NULL) THEN

        UPDATE well_transport_event w
        SET w.grs_mass_adj = ln_well_grs_mass_adj,
        w.net_mass_adj = ln_well_net_mass_adj,
        w.water_mass_adj = ln_well_water_mass_adj
        WHERE w.object_id = mycur.well_id
        AND w.event_no = mycur.event_no
        AND w.daytime = mycur.well_event_daytime;


      END IF;

    END IF;

  END LOOP;

  -- Finally call user exit functionality --
  Ue_Truck_Ticket.prorateTruckedWellLoadOil(p_facility_id, p_startday, p_endday);

END prorateTruckedWellLoadOil;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : deleteChildEvent
-- Description    : Delete child events. Child table is WELL_TRANSPORT_EVENT, parent table is STRM_TRANSPORT_EVENT.
--
--
-- Preconditions  :
-- Postconditions : .
--
-- Using tables   : well_transport_event
--
--
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE deleteChildEvent(p_event_no NUMBER, p_daytime DATE)
--</EC-DOC>
IS

BEGIN

DELETE FROM well_transport_event
WHERE event_no = p_event_no
AND daytime = p_daytime;

END deleteChildEvent;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : countChildEvent
-- Description    : Count child events exist for the parent event id. Child table is WELL_TRANSPORT_EVENT, parent table is STRM_TRANSPORT_EVENT.
--
--
-- Preconditions  :
-- Postconditions : .
--
-- Using tables   : well_transport_event
--
--
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
FUNCTION countChildEvent(p_event_no NUMBER, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS

  CURSOR c_child_event  IS
    SELECT count(object_id) totalrecord
    FROM well_transport_event wte
    WHERE event_no = p_event_no
    AND daytime = p_daytime;

 ln_child_record NUMBER;

BEGIN
   ln_child_record := 0;

  FOR cur_child_event IN c_child_event LOOP
    ln_child_record := cur_child_event.totalrecord ;
  END LOOP;

  return ln_child_record;

END countChildEvent;

--<EC-DOC>
-----------------------------------------------------------------
-- Function     : verifyTicket
-- Description  : Update given Load/Unload ticket to verify
--
-- Preconditions:
-- Postcondition:
-- Using Tables:  STRM_TRANSPORT_EVENT
--
-- Using functions: none
--
-- Configuration required:
--
-- Behaviour:
--
-----------------------------------------------------------------
PROCEDURE verifyTicket(
     p_event_no NUMBER,
     p_user VARCHAR2 DEFAULT USER)
--</EC-DOC>
IS

  CURSOR c_ste (event_no NUMBER) IS
  SELECT ste.object_id
  FROM STRM_TRANSPORT_EVENT ste
  WHERE ste.event_no = event_no;

  ld_daytime STRM_TRANSPORT_EVENT.DAYTIME%TYPE;
  lv2_obj_id   VARCHAR2(32);

BEGIN
   SELECT daytime INTO ld_daytime FROM STRM_TRANSPORT_EVENT WHERE event_no = p_event_no;
   -- lock check
   IF EcDp_Month_lock.withinLockedMonth(ld_daytime) IS NOT NULL THEN

      EcDp_Month_lock.raiseValidationError('PROCEDURE', ld_daytime, ld_daytime, trunc(ld_daytime,'MONTH'), 'EcBp_Stream.verifyTicket: Can not do this in a locked month');

   END IF;

    FOR curEvt IN c_ste(p_event_no) LOOP
        lv2_obj_id := curEvt.object_id;
    END LOOP;

    EcDp_Month_Lock.localLockCheck('withinLockedMonth', lv2_obj_id,
                                   ld_daytime, ld_daytime,
                                   'PROCEDURE', 'EcBp_Stream.verifyTicket: Can not do this in a local locked month');

   -- Update STRM_TRANSPORT_EVENT record with V status
   UPDATE STRM_TRANSPORT_EVENT
   SET RECORD_STATUS       = 'V',
     LAST_UPDATED_BY = p_user,
     LAST_UPDATED_DATE = Ecdp_Timestamp.getCurrentSysdate
   WHERE EVENT_NO = p_event_no;

   -- Call to user_exit
   UE_Truck_Ticket.verifyTicket(p_event_no, p_user);

END verifyTicket;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findNetStdVol
-- Description    : Returns the net standard volume in Sm3 for given
--                  event no.
-- Preconditions  : All input variables to calculations must have a defined value, or else
--                  the function call will return null.
-- Postcondition  :
-- Using Tables   :
--
-- Using functions: EC_STRM_VERSION....
--
-- Configuration
-- required       :
--
-- Behaviour      : Alternative STRM_VERSION.... (NET_VOL_METHOD):
--
--                 1.  'GROSS_BSW': Find net_vol using data from gross volume and bsw
---------------------------------------------------------------------------------------------------
FUNCTION findNetStdVol (p_event_no NUMBER, p_resolve_loop VARCHAR2 DEFAULT NULL) RETURN NUMBER
--</EC-DOC>
IS
  -- event_no is the PK for both tables. The same sequence_number generator is used to aviod same event_no in both tables
  -- there should therefore only be max one row returned from this cursor
  CURSOR c_object_transport_event(cp_event_no NUMBER) IS
  SELECT ste.net_vol_adj, ste.net_vol, ste.data_class_name, ste.grs_vol
  FROM strm_transport_event ste
  WHERE ste.event_no = cp_event_no
  UNION ALL
  SELECT ote.net_vol_adj, ote.net_vol, ote.data_class_name, ote.grs_vol
  FROM object_transport_event ote
  WHERE ote.event_no = cp_event_no;

  ln_gross_vol NUMBER;
  ln_bsw_frac  NUMBER;
  ln_net_mass  NUMBER;
  ln_density   NUMBER;
  ln_return    NUMBER;
  ln_nbr_linked NUMBER;
  lv2_resolve_loop VARCHAR2(2000);

BEGIN
  IF InStr(p_resolve_loop,'findNetStdVol')>0 THEN
    RETURN NULL; -- loop detected, impossible to calcute.
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findNetStdVol';
  END IF;
  -- can always only be max one record
  FOR curEvent IN c_object_transport_event (p_event_no) LOOP
    -- priority 1-user exit
    ln_return := Ue_Truck_Ticket.findNetStdVol(p_event_no,p_resolve_loop);
    IF ln_return IS NULL THEN
      -- priority 2 - spesial handling of class STRM_TRUCK_LOAD_VOL (screen Truck Ticket - Singel Load Multi Offfload)
      IF curEvent.data_class_name = 'STRM_TRUCK_LOAD_VOL' THEN
        SELECT COUNT(ste.event_no) INTO ln_nbr_linked FROM strm_transport_event ste WHERE ste.link_load_unique = p_event_no;
        IF ln_nbr_linked < 1 THEN
          ln_return := curEvent.Grs_Vol;
        ELSE
          SELECT SUM(ste.net_vol) INTO ln_return FROM strm_transport_event ste WHERE ste.link_load_unique = p_event_no;
				END IF;
      END IF;
      IF ln_return IS NULL THEN
        -- priority 3 - net_vol_adjusted, do not need any shrinakge, is already shrunk.
        IF curEvent.net_vol_adj IS NOT NULL THEN
          ln_return := curEvent.net_vol_adj;
        -- priority 4 - net_vol * shrinakge factor
        ELSIF curEvent.net_vol IS NOT NULL THEN
          ln_return := curEvent.net_vol * nvl(VolumeCorrFactor(p_event_no),1);
        -- priority 5 - gross volume, bsw_fraction and shrinkage factor
        ELSE
  	      ln_gross_vol := findGrsStdVol(p_event_no,lv2_resolve_loop);
    	    ln_bsw_frac  := findBswVolFrac(p_event_no,lv2_resolve_loop);
          ln_return    := ln_gross_vol * (1-ln_bsw_frac) * nvl(VolumeCorrFactor(p_event_no),1);
          -- priority 6 - net mass and density
          IF ln_return IS NULL THEN
            ln_net_mass := findNetStdMass(p_event_no,lv2_resolve_loop);
            ln_density  := calcDensity(p_event_no,lv2_resolve_loop);
            IF ln_net_mass=0 THEN
              ln_return := 0;
            ELSIF ln_density > 0 THEN
              ln_return := ln_net_mass/ln_density;
            ELSIF (ln_density=0 OR ln_density IS NULL) THEN
              ln_return := NULL;
            END IF;
          END IF;
        END IF;
      END IF;
    END IF;
  END LOOP;
  RETURN ln_return;
END findNetStdVol;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findGrsStdVol
-- Description    : Returns the gross standard volume in Sm3 for a given event no
-- Preconditions  : All input values to calculation must have a defined value or else
--                  the function call will return null.
-- Postcondition  :
-- Using Tables   :
--
-- Using functions: EC_STRM_VERSION....
-- Configuration
-- required       :
--
-- Behaviour      : Alternative STRM_VERSION.... (GRS_VOL_METHOD):
--
--                 1.'MEASURED_TRUCKED' Get grs_vol from truck ticket data
---------------------------------------------------------------------------------------------------
FUNCTION findGrsStdVol (p_event_no NUMBER, p_resolve_loop VARCHAR2 DEFAULT NULL) RETURN NUMBER
--</EC-DOC>
IS
  -- event_no is the PK for both tables. The same sequence_number generator is used to aviod same event_no in both tables
  -- there should therefore only be max one row returned from this cursor
  CURSOR c_object_transport_event(cp_event_no NUMBER) IS
  SELECT ste.grs_vol_adj, ste.grs_vol
  FROM strm_transport_event ste
  WHERE ste.event_no = cp_event_no
  UNION ALL
  SELECT ote.grs_vol_adj, ote.grs_vol
  FROM object_transport_event ote
  WHERE ote.event_no = cp_event_no;

  ln_return    NUMBER;
  ln_grs_mass  NUMBER;
  ln_density   NUMBER;
  lv2_resolve_loop VARCHAR2(2000);

BEGIN
  IF InStr(p_resolve_loop,'findGrsStdVol')>0 THEN
    RETURN NULL; -- loop detected, impossible to calcute.
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findGrsStdVol';
  END IF;
  -- can always only be max one record
  FOR curEvent IN c_object_transport_event (p_event_no) LOOP
    -- priority 1-user exit
    ln_return := Ue_Truck_Ticket.findGrsStdVol(p_event_no,p_resolve_loop);
    IF ln_return IS NULL THEN
			-- priority 2 - gross volume adjusted
      IF curEvent.grs_vol_adj IS NOT NULL THEN
    		ln_return := curEvent.grs_vol_adj;
			-- priority 3 - gross volume
      ELSIF curEvent.grs_vol IS NOT NULL THEN
    		ln_return := curEvent.grs_vol;
			-- priority 2 - gross mass / gross density
    	ELSE
        ln_grs_mass := findGrsStdMass(p_event_no,lv2_resolve_loop);
        ln_density  := calcDensity(p_event_no,lv2_resolve_loop);
    	  IF ln_grs_mass=0 THEN
    	    ln_return := 0;
    	  ELSIF ln_density > 0 THEN
    	    ln_return := ln_grs_mass/ln_density;
    	  ELSIF (ln_density=0 OR ln_density IS NULL) THEN
    	    ln_return := NULL;
        END IF;
    	END IF;
    END IF;
  END LOOP;

  RETURN ln_return;

END findGrsStdVol;

---------------------------------------------------------------------------------------------------
-- Function       : findWatVol
-- Description    : Returns the water volume for a given event no
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--                  EC_STRM_VERSION....
--                  ECBP_STREAM_FLUID.FINDGRSSTDVOL
--
-- Configuration
-- required       :
--
-- Behaviour      : Alternative STRM_VERSION....
--                  (EcDp_Stream_Attribute.WAT_VOL_METHOD):
--                 1. 'GROSS_BSW':  Find water vol using the diff between gross and net oil
--                                    (the bsw is all considered as water).
--
---------------------------------------------------------------------------------------------------
FUNCTION findWatVol(p_event_no NUMBER, p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS

  CURSOR c_object_transport_event(cp_event_no NUMBER) IS
  SELECT ste.water_vol, ste.sand_cut, ste.data_class_name, ste.grs_vol
  FROM strm_transport_event ste
  WHERE ste.event_no = cp_event_no
  UNION ALL
  SELECT ote.water_vol, ote.sand_cut, ote.data_class_name, ote.grs_vol
  FROM object_transport_event ote
  WHERE ote.event_no = cp_event_no;

  ln_return   NUMBER;
  ln_grs_vol  NUMBER;
  ln_bsw_cut  NUMBER;
  ln_nbr_linked NUMBER;
  lv_class_name VARCHAR2(32);
  lv2_resolve_loop VARCHAR2(2000);

BEGIN
  IF InStr(p_resolve_loop,'findWatVol')>0 THEN
    RETURN NULL; -- loop detected, impossible to calcute.
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findWatVol';
  END IF;
  -- always only one record
  FOR curEvent IN c_object_transport_event(p_event_no) LOOP
    ln_return := Ue_Truck_Ticket.findWatVol(p_event_no, lv2_resolve_loop);
    IF ln_return IS NULL THEN
      -- spesical handling of class STRM_TRUCK_LOAD_VOL
      IF curEvent.data_class_name = 'STRM_TRUCK_LOAD_VOL' THEN
        SELECT COUNT(ste.event_no) INTO ln_nbr_linked FROM strm_transport_event ste WHERE ste.link_load_unique = p_event_no;
        ln_grs_vol := curEvent.grs_vol;
        IF ln_nbr_linked < 1 AND ln_grs_vol IS NOT NULL THEN
          ln_return := 0;
        ELSIF ln_grs_vol IS NULL THEN
          ln_return := NULL;
        ELSE
          SELECT SUM(ste.water_vol) INTO ln_return FROM strm_transport_event ste WHERE ste.link_load_unique = p_event_no;
        END IF;
      -- default logic
      ELSE
        IF ln_return IS NULL THEN
          ln_grs_vol := findGrsStdVol(p_event_no);
          ln_bsw_cut := findBSWVolFrac(p_event_no);
          ln_return := (ln_grs_vol * (ln_bsw_cut - nvl(curEvent.sand_cut,0)) + nvl(curEvent.water_vol,0));
        END IF;
        IF ln_return IS NULL THEN
          ln_return := curEvent.water_vol;
        END IF;
      END IF;
    END IF;
  END LOOP;
  RETURN ln_return;
END findWatVol;

---------------------------------------------------------------------------------------------------
-- Function       : findSandVol
-- Description    : Returns the Sand Vol for a given event no
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findSandVol (
  p_event_no     NUMBER, p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  -- event_no is the PK for both tables. The same sequence_number generator is used to aviod same event_no in both tables
  -- there should therefore only be max one row returned from this cursor
  CURSOR c_object_transport_event(cp_event_no NUMBER) IS
  SELECT ste.sand_cut -- need to add new column to table
  FROM strm_transport_event ste
  WHERE ste.event_no = cp_event_no
  UNION ALL
  SELECT ote.sand_cut
  FROM object_transport_event ote
  WHERE ote.event_no = cp_event_no;

  ln_return    NUMBER;
  ln_sand_mass NUMBER;
  ln_grs_vol NUMBER;
  ln_density NUMBER;
  lv2_resolve_loop VARCHAR2(2000);

BEGIN
  IF InStr(p_resolve_loop,'findSandVol')>0 THEN
    RETURN NULL; -- loop detected, impossible to calcute.
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findSandVol';
  END IF;
  -- can always only be max one record
  FOR curEvent IN c_object_transport_event (p_event_no) LOOP
    -- priority 1-user exit, then 2 etc until a value is found.
    ln_return := Ue_Truck_Ticket.findSandVol(p_event_no,lv2_resolve_loop);
    IF ln_return IS NULL THEN
       ln_grs_vol := findGrsStdVol(p_event_no);
       ln_return := ln_grs_vol * nvl(curEvent.sand_cut,0);
    ELSIF ln_grs_vol IS NULL THEN
      ln_sand_mass := findSandMass(p_event_no, lv2_resolve_loop);
      ln_density := calcDensity(p_event_no);
      IF ln_sand_mass=0 THEN
    		ln_return := 0;
    	ELSIF ln_sand_mass>0 and ln_density>0 THEN
    	  ln_return := ln_sand_mass/ln_density;
    	ELSE
    	  ln_return := NULL;
    	END IF;
    END IF;
  END LOOP;

  RETURN ln_return;

END findSandVol;

---------------------------------------------------------------------------------------------------
-- Function       : findWellStdVol
-- Description    : Returns the net standard volume in Sm3 for given
--                  event no.
-- Preconditions  : All input variables to calculations must have a defined value, or else
--                  the function call will return null.
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
--
---------------------------------------------------------------------------------------------------
FUNCTION findWellStdVol (p_event_no NUMBER, p_object_id VARCHAR2, p_resolve_loop VARCHAR2 DEFAULT NULL) RETURN NUMBER
--</EC-DOC>
IS

  CURSOR c_transport_event(cp_event_no NUMBER, cp_object_id VARCHAR2) IS
  SELECT wte.net_vol_adj, wte.grs_vol,wte.bs_w
  FROM well_transport_event wte
  WHERE wte.event_no = cp_event_no
  AND wte.object_id = cp_object_id
  UNION ALL
  SELECT ote.net_vol_adj, ote.grs_vol,ote.bs_w
  FROM object_transport_event ote
  WHERE ote.event_no = cp_event_no;

  ln_gross_vol     NUMBER;
  ln_bsw_frac      NUMBER;
  ln_return        NUMBER;
  lv2_resolve_loop VARCHAR2(2000);

BEGIN
  IF InStr(p_resolve_loop,'findWellStdVol')>0 THEN
    RETURN NULL; -- loop detected, impossible to calcute.
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findWellStdVol';
  END IF;
  -- can always only be max one record
  FOR curEvent IN c_transport_event (p_event_no, p_object_id) LOOP
  -- priority 1-user exit
    ln_return := Ue_Truck_Ticket.findWellStdVol(p_event_no,p_object_id,p_resolve_loop);
    IF ln_return IS NULL THEN
    -- priority 3 - net_vol_adjusted, do not need any shrinkage, is already shrunk.
      IF curEvent.net_vol_adj IS NOT NULL THEN
        ln_return := curEvent.net_vol_adj;
        -- priority 4 - net_vol * shrinakge factor
      ELSIF ln_return IS NULL THEN
          ln_gross_vol := findWellGrsStdVol(p_event_no, lv2_resolve_loop);
          ln_bsw_frac  := findWellBswVolFrac(p_event_no, lv2_resolve_loop);
          ln_return    := ln_gross_vol * (1 - ln_bsw_frac);
      ELSE
        ln_return    := curEvent.grs_vol * (1-curEvent.bs_w);
      END IF;
    END IF;
  END LOOP;

  RETURN ln_return;
END findWellStdVol;

--<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Function       : findWellGrsStdVol
  -- Description    : Returns the gross standard volume in Sm3 for a given event no
  -- Preconditions  : All input values to calculation must have a defined value or else
  --                  the function call will return null.
  -- Postcondition  :
  -- Using Tables   :
  --
  -- Using functions: EC_WELL_VERSION....
  -- Configuration
  -- required       :
  --
  -- Behaviour      : Alternative WELL_VERSION.... (GRS_VOL_METHOD):
  --
  --                 1.'MEASURED_TRUCKED' Get grs_vol from truck ticket data
  ---------------------------------------------------------------------------------------------------
  FUNCTION findWellGrsStdVol(p_event_no     NUMBER
                            ,p_resolve_loop VARCHAR2 DEFAULT NULL)
    RETURN NUMBER
  --</EC-DOC>
   IS
    -- event_no is the PK for both the tables. The same sequence object is used to generate event_no in both the tables therefore only one row will be returned from this cursor
    CURSOR c_object_transport_event(cp_event_no NUMBER) IS
      SELECT wte.grs_vol_adj, wte.grs_vol
        FROM well_transport_event wte
       WHERE wte.event_no = cp_event_no
      UNION ALL
      SELECT ote.grs_vol_adj, ote.grs_vol
        FROM object_transport_event ote
       WHERE ote.event_no = cp_event_no;

    ln_return        NUMBER;
    lv2_resolve_loop VARCHAR2(2000);

  BEGIN
    IF InStr(p_resolve_loop, 'findWellGrsStdVol') > 0 THEN
      RETURN NULL; -- loop detected, impossible to calculate.
    ELSE
      -- Call the next function with the argument to this function, or this function name if no argument
      lv2_resolve_loop := NVL(p_resolve_loop, '') || 'findWellGrsStdVol';
    END IF;
    FOR curEvent IN c_object_transport_event(p_event_no) LOOP

      ln_return := Ue_Truck_Ticket.findWellGrsStdVol(p_event_no,
                                                     p_resolve_loop);-- priority 1-user exit
      IF ln_return IS NULL THEN
        -- priority 2 - gross volume adjusted
        IF curEvent.grs_vol_adj IS NOT NULL THEN
          ln_return := curEvent.grs_vol_adj;
          -- priority 3 - gross volume
        ELSIF curEvent.grs_vol IS NOT NULL THEN
          ln_return := curEvent.grs_vol;
        ELSE
          ln_return := NULL;
        END IF;
      END IF;
    END LOOP;

    RETURN ln_return;

  END findWellGrsStdVol;

---------------------------------------------------------------------------------------------------
-- Function       : findWellWaterVol
-- Description    : Returns the water volume for given
--                  event no.
-- Preconditions  : All input variables to calculations must have a defined value, or else
--                  the function call will return null.
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
--
---------------------------------------------------------------------------------------------------
FUNCTION findWellWaterVol (p_event_no NUMBER, p_object_id VARCHAR2, p_resolve_loop VARCHAR2 DEFAULT NULL) RETURN NUMBER
--</EC-DOC>
IS

  CURSOR c_transport_event(cp_event_no NUMBER, cp_object_id VARCHAR2) IS
  SELECT wte.water_vol_adj, wte.grs_vol, wte.bs_w, null sand_cut, null water_vol
  FROM well_transport_event wte
  WHERE wte.event_no = cp_event_no
  AND wte.object_id = cp_object_id
  UNION ALL
  SELECT ote.water_vol_adj, ote.grs_vol, ote.bs_w,ote.sand_cut, ote.water_vol
  FROM object_transport_event ote
  WHERE ote.event_no = cp_event_no;

  ln_grs_vol  NUMBER;
  ln_bsw_cut  NUMBER;
  ln_return    NUMBER;
  lv2_resolve_loop VARCHAR2(2000);

BEGIN
  IF InStr(p_resolve_loop,'findWellStdVol')>0 THEN
    RETURN NULL; -- loop detected, impossible to calcute.
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findWellStdVol';
  END IF;
  -- can always only be max one record
  FOR curEvent IN c_transport_event (p_event_no,p_object_id) LOOP
  -- priority 1-user exit
    ln_return := Ue_Truck_Ticket.findWellWaterVol(p_event_no,p_object_id,p_resolve_loop);
    IF ln_return IS NULL THEN
    -- priority 3 - net_vol_adjusted, do not need any shrinakge, is already shrunk.
      IF curEvent.water_vol_adj IS NOT NULL THEN
        ln_return := curEvent.water_vol_adj;
        -- priority 4 - net_vol * shrinakge factor
      ELSIF ln_return IS NULL THEN
          ln_grs_vol := findWellGrsStdVol(p_event_no);
          ln_bsw_cut := findWellBSWVolFrac(p_event_no);
          ln_return  := (ln_grs_vol * (ln_bsw_cut - nvl(curEvent.sand_cut, 0)) + nvl(curEvent.water_vol, 0));
      ELSE
          ln_return  := (curEvent.grs_vol * (curEvent.bs_w - nvl(curEvent.sand_cut,0)) + nvl(curEvent.water_vol,0));
      END IF;
    END IF;
  END LOOP;

  RETURN ln_return;
END findWellWaterVol;

--------------------------------------------------------------------------------------------------
-- Function       : findGrsStdMass
-- Description    :
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findGrsStdMass (p_event_no NUMBER, p_resolve_loop VARCHAR2 DEFAULT NULL) RETURN NUMBER
--</EC-DOC>
IS
  -- event_no is the PK for both tables. The same sequence_number generator is used to aviod same event_no in both tables
  -- there should therefore only be max one row returned from this cursor
  CURSOR c_object_transport_event(cp_event_no NUMBER) IS
  SELECT ste.grs_mass_adj, ste.grs_mass, ste.tare_mass, ste.data_class_name -- tare_mass must be added as column to strm_transport_event
  FROM strm_transport_event ste
  WHERE ste.event_no = cp_event_no
  UNION ALL
  SELECT ote.grs_mass_adj, ote.grs_mass, ote.tare_mass, ote.data_class_name -- grs_mass_adj must be added as column to object_transport_event
  FROM object_transport_event ote
  WHERE ote.event_no = cp_event_no;

  ln_return    NUMBER;
  lv2_resolve_loop VARCHAR2(2000);

BEGIN
  IF InStr(p_resolve_loop,'findGrsStdMass')>0 THEN
    RETURN NULL; -- loop detected, impossible to calcute.
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findGrsStdMass';
  END IF;
  -- can always only be max one record
  FOR curEvent IN c_object_transport_event (p_event_no) LOOP
    -- priority 1-user exit, then 2 etc until a value is found.
    ln_return := Ue_Truck_Ticket.findGrsStdMass(p_event_no,lv2_resolve_loop);
    IF ln_return IS NULL THEN
      IF curEvent.grs_mass_adj IS NOT NULL THEN
    		ln_return := curEvent.grs_mass_adj;
      -- spesial handling of one class which stores the "net" grs_mass on trailers, no need to deduct tare weight.
      ELSIF (curEvent.grs_mass IS NOT NULL AND curEvent.data_class_name IN ('STRM_TRUCK_LOAD_VOL','STRM_TRUCK_UNLOAD_MASS')) THEN
    		ln_return := curEvent.grs_mass;
      ELSIF (curEvent.grs_mass IS NOT NULL AND curEvent.tare_mass IS NOT NULL) THEN
    		ln_return := curEvent.grs_mass - curEvent.tare_mass;
    	ELSE
    	  ln_return := NULL;
    	END IF;
    END IF;
  END LOOP;

  RETURN ln_return;

END findGrsStdMass;

---------------------------------------------------------------------------------------------------
-- Function       : findNetStdMass
-- Description    :
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findNetStdMass (p_event_no NUMBER, p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  CURSOR c_strm_transport_event_single(cp_event_no NUMBER) IS
  SELECT ste.data_class_name, ste.net_mass, ste.std_density, ste.object_id, ste.profit_centre_id, ste.daytime, ste.grs_vol
  FROM strm_transport_event ste
  WHERE event_no = cp_event_no
  UNION ALL
  SELECT ote.data_class_name, ote.net_mass, ote.std_density, ote.object_id, NULL profit_centre_id, ote.daytime, ote.grs_vol -- ote.std_density must be added
  FROM object_transport_event ote
  WHERE ote.event_no = cp_event_no;

  CURSOR c_prev_density (p_object_id VARCHAR2, p_profit_centre_id VARCHAR2, p_daytime date) is
  select u.std_density
  from strm_transport_event l, strm_transport_event u
  where l.event_no = u.link_load_unique
    and l.object_id = p_object_id
    and l.daytime =
    	(select max(ste.daytime) from strm_transport_event ste where ste.object_id = p_object_id and ste.daytime < p_daytime)
    and u.std_density is not null
    and ((l.profit_centre_id = nvl(p_profit_centre_id, l.profit_centre_id))
     or  (l.profit_centre_id is null and p_profit_centre_id is null));

  ln_return  NUMBER;
  ln_net_vol NUMBER;
  ln_nbr_linked NUMBER;
  ln_bsw_wt NUMBER;
  lv2_resolve_loop VARCHAR2(2000);
  ln_grs_mass NUMBER;

BEGIN
  IF InStr(p_resolve_loop,'findNetStdMass')>0 THEN
    RETURN NULL; -- loop detected, impossible to calcute.
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findNetStdMass';
  END IF;

  -- can always only be max one record
  FOR curEvent IN c_strm_transport_event_single(p_event_no) LOOP
    -- priority 1-user exit
    ln_return := Ue_Truck_Ticket.findNetStdMass(p_event_no, p_resolve_loop);
    IF ln_return IS NULL THEN
      -- priority 2 -spesial handling for one class only
      IF (curEvent.data_class_name='STRM_TRUCK_LOAD_VOL') THEN
        SELECT COUNT(ste.event_no) INTO ln_nbr_linked FROM strm_transport_event ste WHERE ste.link_load_unique = p_event_no;
			  IF ln_nbr_linked < 1 THEN
			    -- Find the previous used density for the object and profit centre. Max one row is returned.
  		    FOR curDensity in c_prev_density(CurEvent.object_id, CurEvent.profit_centre_id, CurEvent.daytime) LOOP
			      ln_return := curEvent.grs_vol * curDensity.std_density;
			    END LOOP;
			  ELSE
			    SELECT SUM(ste.net_vol * ste.std_density) INTO ln_return FROM strm_transport_event ste WHERE ste.link_load_unique = p_event_no;
			  END IF;
    	END IF;
      -- priority 3 - net_mass directly, then net_vol*density, then gross_mass*(1-bsw wt)
      IF ln_return IS NULL THEN
          ln_return := curEvent.net_mass;
			END IF;
      IF ln_return IS NULL THEN
        ln_grs_mass := findGrsStdMass(p_event_no, lv2_resolve_loop);
        IF ln_grs_mass = 0 THEN
          ln_return := 0;
        ELSE
          ln_bsw_wt := findBswWtFrac(p_event_no, lv2_resolve_loop);
          ln_return :=  ln_grs_mass*(1-ln_bsw_wt);
        END IF;
      END IF;
      IF ln_return IS NULL THEN
        ln_net_vol := findNetStdVol(p_event_no, lv2_resolve_loop);
        IF ln_net_vol > 0 THEN
          ln_return := ln_net_vol * nvl(curEvent.std_density, calcDensity(p_event_no, lv2_resolve_loop));
        ELSIF ln_net_vol = 0 THEN
          ln_return := 0;
        ELSE
          ln_return := NULL;
        END IF;
      END IF;
    END IF;
  END LOOP;
  RETURN ln_return;
END findNetStdMass;

---------------------------------------------------------------------------------------------------
-- Function       : findWatMass
-- Description    : Returns the water mass for a given event no
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--                  EC_STRM_VERSION....
--                  ECBP_STREAM_FLUID.FINDGRSSTDVOL
--
-- Configuration
-- required       :
--
-- Behaviour      : Alternative STRM_VERSION....
--                  (EcDp_Stream_Attribute.WAT_VOL_METHOD):
--                 1. 'GROSS_BSW':  Find water vol using the diff between gross and net oil
--                                    (the bsw is all considered as water).
--
---------------------------------------------------------------------------------------------------
FUNCTION findWatMass(p_event_no NUMBER, p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS

  CURSOR c_object_transport_event(cp_event_no NUMBER) IS
  SELECT ste.water_mass
  FROM strm_transport_event ste
  WHERE ste.event_no = cp_event_no
  UNION ALL
  SELECT ote.water_mass
  FROM object_transport_event ote
  WHERE ote.event_no = cp_event_no;

  ln_return   NUMBER;
  ln_grs_mass  NUMBER;
  ln_bsw_cut_wt  NUMBER;
  lv2_resolve_loop VARCHAR2(2000);

BEGIN
  IF InStr(p_resolve_loop,'findWatMass')>0 THEN
    RETURN NULL; -- loop detected, impossible to calcute.
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findWatMass';
  END IF;
  -- always only one record
  FOR curEvent IN c_object_transport_event(p_event_no) LOOP
    ln_return := Ue_Truck_Ticket.findWatMass(p_event_no,lv2_resolve_loop);
    IF ln_return IS NULL THEN
      ln_grs_mass    := findGrsStdMass(p_event_no);
      ln_bsw_cut_wt  := findBswWtFrac(p_event_no);
      ln_return      := ( ln_grs_mass * ln_bsw_cut_wt)  +  nvl(curEvent.water_mass,0);
    END IF;
    IF ln_return IS NULL THEN
      ln_return := curEvent.water_mass;
    END IF;
  END LOOP;
  RETURN ln_return;
END findWatMass;
---------------------------------------------------------------------------------------------------
-- Function       : findSandMass
-- Description    : Returns the Water Mass for a given event no
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findSandMass(p_event_no NUMBER, p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS
  -- event_no is the PK for both tables. The same sequence_number generator is used to aviod same event_no in both tables
  -- there should therefore only be max one row returned from this cursor
  CURSOR c_object_transport_event(cp_event_no NUMBER) IS
  SELECT ste.sand_cut -- need to add new column to table
  FROM strm_transport_event ste
  WHERE ste.event_no = cp_event_no
  UNION ALL
  SELECT ote.sand_cut
  FROM object_transport_event ote
  WHERE ote.event_no = cp_event_no;

  ln_return    NUMBER;
  ln_grs_mass  NUMBER;
  lv2_resolve_loop VARCHAR2(2000);

BEGIN
  IF InStr(p_resolve_loop,'findSandMass')>0 THEN
    RETURN NULL; -- loop detected, impossible to calcute.
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findSandMass';
  END IF;
  -- can always only be max one record
  FOR curEvent IN c_object_transport_event (p_event_no) LOOP
    -- priority 1-user exit, then 2 etc until a value is found.
    ln_return := Ue_Truck_Ticket.findSandMass(p_event_no,lv2_resolve_loop);
    IF ln_return IS NULL THEN
      ln_grs_mass := findGrsStdMass(p_event_no);
      IF ln_grs_mass>0 AND curEvent.sand_cut IS NOT NULL THEN
    		ln_return := ln_grs_mass * curEvent.sand_cut;
    	ELSIF ln_grs_mass=0 THEN
    	  ln_return := 0;
    	ELSE
    	  ln_return := NULL;
    	END IF;
    END IF;
  END LOOP;

  RETURN ln_return;

END findSandMass;

---------------------------------------------------------------------------------------------------
-- Function       : findWellGrsStdMass
-- Description    :
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findWellGrsStdMass (p_event_no NUMBER,p_object_id VARCHAR2,  p_resolve_loop VARCHAR2 DEFAULT NULL) RETURN NUMBER
--</EC-DOC>
IS
  -- event_no is the PK for both tables. The same sequence_number generator is used to aviod same event_no in both tables
  -- there should therefore only be max one row returned from this cursor
  CURSOR c_transport_event(cp_event_no NUMBER, cp_object_id VARCHAR2) IS
  SELECT wte.grs_mass_adj
  FROM well_transport_event wte
  WHERE wte.event_no = cp_event_no
  AND wte.object_id = cp_object_id
  UNION ALL
  SELECT nvl(ote.grs_mass_adj, ote.grs_mass - ote.tare_mass) grs_mass_adj
  FROM object_transport_event ote
  WHERE ote.event_no = cp_event_no;

  ln_return    NUMBER;
  lv2_resolve_loop VARCHAR2(2000);

BEGIN
  IF InStr(p_resolve_loop,'findWellGrsStdMass')>0 THEN
    RETURN NULL; -- loop detected, impossible to calcute.
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findWellGrsStdMass';
  END IF;
  -- can always only be max one record
  FOR curEvent IN c_transport_event (p_event_no, p_object_id) LOOP
    -- priority 1-user exit, then 2 etc until a value is found.
    ln_return := Ue_Truck_Ticket.findWellGrsStdMass(p_event_no,p_object_id, lv2_resolve_loop);
    IF ln_return IS NULL THEN
      IF curEvent.grs_mass_adj IS NOT NULL THEN
    		ln_return := curEvent.grs_mass_adj;
      ELSE
    	  ln_return := NULL;
    	END IF;
    END IF;
  END LOOP;

  RETURN ln_return;

END findWellGrsStdMass;

---------------------------------------------------------------------------------------------------
-- Function       : findWellNetStdMass
-- Description    :
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findWellNetStdMass (p_event_no NUMBER,p_object_id VARCHAR2,  p_resolve_loop VARCHAR2 DEFAULT NULL) RETURN NUMBER
--</EC-DOC>
IS
  -- event_no is the PK for both tables. The same sequence_number generator is used to aviod same event_no in both tables
  -- there should therefore only be max one row returned from this cursor
  CURSOR c_transport_event(cp_event_no NUMBER, cp_object_id VARCHAR2) IS
  SELECT wte.net_mass_adj
  FROM well_transport_event wte
  WHERE wte.event_no = cp_event_no
  AND wte.object_id = cp_object_id;

  ln_return    NUMBER;
  lv2_resolve_loop VARCHAR2(2000);

BEGIN
  IF InStr(p_resolve_loop,'findWellNetStdMass')>0 THEN
    RETURN NULL; -- loop detected, impossible to calcute.
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findWellNetStdMass';
  END IF;
  ln_return := Ue_Truck_Ticket.findWellNetStdMass(p_event_no,p_object_id,lv2_resolve_loop);
  IF ln_return IS NULL THEN
    FOR curEvent IN c_transport_event (p_event_no, p_object_id) LOOP
      ln_return := curEvent.net_mass_adj;
    END LOOP;
    IF ln_return IS NULL THEN -- try if the event exists in object transport event
      ln_return := findNetStdMass(p_event_no,lv2_resolve_loop);
    END IF;
  END IF;
 RETURN ln_return;

END findWellNetStdMass;

---------------------------------------------------------------------------------------------------
-- Function       : calcDensity
-- Description    : Returns the density for the liquid
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION calcDensity (
  p_event_no     NUMBER, p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS

  CURSOR c_object_transport_event(cp_event_no NUMBER) IS
  SELECT ste.object_id, ste.daytime, ste.sand_cut
  FROM strm_transport_event ste
  WHERE ste.event_no = cp_event_no
  UNION ALL
  SELECT ote.object_id, ote.daytime, ote.sand_cut
  FROM object_transport_event ote
  WHERE ote.event_no = cp_event_no;

  ln_return  NUMBER;
  ln_oil_density NUMBER;
  ln_water_density NUMBER;
  ln_sand_density NUMBER;
  ln_bs_w  NUMBER;
  ln_sand_cut NUMBER;
  lv2_resolve_loop VARCHAR2(2000);

BEGIN
  IF InStr(p_resolve_loop,'calcDensity')>0 THEN
    RETURN NULL; -- loop detected, impossible to calcute.
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'calcDensity';
  END IF;
  -- always only one record
  FOR curEvent IN c_object_transport_event(p_event_no) LOOP
    ln_return := Ue_Truck_Ticket.calcDensity(p_event_no, p_resolve_loop);
    IF ln_return IS NULL THEN
      ln_oil_density := nvl(findOilDensity(p_event_no, lv2_resolve_loop),0);
      ln_water_density := nvl(findWaterDensity(p_event_no, lv2_resolve_loop),0);
      ln_sand_density := nvl(findSandDensity(p_event_no, lv2_resolve_loop),0);
      ln_bs_w:= nvl(findBswVolFrac(p_event_no),0);
      ln_sand_cut := nvl(curEvent.sand_cut,0);
      ln_return := ((ln_oil_density * (1-ln_bs_w)) + (ln_water_density * (ln_bs_w-ln_sand_cut)) + (ln_sand_density * ln_sand_cut));
    END IF;
  END LOOP;
RETURN ln_return;
END calcDensity;

---------------------------------------------------------------------------------------------------
-- Function       : findOilDensity
-- Description    : Returns the density for the liquid
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findOilDensity (p_event_no NUMBER, p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS

  CURSOR c_object_transport_event(cp_event_no NUMBER) IS
  SELECT ste.object_id, ste.daytime
  FROM strm_transport_event ste
  WHERE ste.event_no = cp_event_no
  UNION ALL
  SELECT ote.object_id, ote.daytime
  FROM object_transport_event ote
  WHERE ote.event_no = cp_event_no;

  ln_return  NUMBER;
  lv2_object_type VARCHAR2(32);
  lv2_resolve_loop VARCHAR2(2000);

BEGIN
  IF InStr(p_resolve_loop,'findOilDensity')>0 THEN
    RETURN NULL; -- loop detected, impossible to calcute.
  ELSE
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findOilDensity';
  END IF;
  -- always only one record
  FOR curEvent IN c_object_transport_event(p_event_no) LOOP
    ln_return := Ue_Truck_Ticket.findOilDensity(p_event_no, lv2_resolve_loop);
    IF ln_return IS NULL THEN
      lv2_object_type := EcDp_Objects.GetObjClassName(curEvent.object_id);
      IF lv2_object_type = 'STREAM' THEN
        ln_return := nvl(EcBp_Stream_Fluid.findStdDens(curEvent.object_id, curEvent.daytime),ec_strm_reference_value.oil_density(curEvent.object_id, curEvent.daytime,'<='));
      ELSIF lv2_object_type = 'WELL' THEN
        ln_return := EcBp_Well_Theoretical.findOilStdDensity(curEvent.object_id, curEvent.daytime);
      ELSIF lv2_object_type = 'EXTERNAL_LOCATION' THEN
        ln_return := ec_ext_loc_reference_value.oil_density(curEvent.object_id, curEvent.daytime,'<=');
      END IF;
    END IF;
  END LOOP;
RETURN ln_return;

END findOilDensity;

---------------------------------------------------------------------------------------------------
-- Function       : findWaterDensity
-- Description    : Returns the density for the liquid
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findWaterDensity (p_event_no NUMBER, p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS

  CURSOR c_object_transport_event(cp_event_no NUMBER) IS
  SELECT ste.object_id, ste.daytime
  FROM strm_transport_event ste
  WHERE ste.event_no = cp_event_no
  UNION ALL
  SELECT ote.object_id, ote.daytime
  FROM object_transport_event ote
  WHERE ote.event_no = cp_event_no;

  ln_return  NUMBER;
  lv2_object_type VARCHAR2(32);
  lv2_resolve_loop VARCHAR2(2000);

BEGIN
  IF InStr(p_resolve_loop,'findWaterDensity')>0 THEN
    RETURN NULL; -- loop detected, impossible to calcute.
  ELSE
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findWaterDensity';
  END IF;
  -- always only one record
  FOR curEvent IN c_object_transport_event(p_event_no) LOOP
    ln_return := Ue_Truck_Ticket.findWaterDensity(p_event_no, lv2_resolve_loop);
    IF ln_return IS NULL THEN
      lv2_object_type := EcDp_Objects.GetObjClassName(curEvent.object_id);
      IF lv2_object_type = 'STREAM' THEN
        ln_return := ec_strm_reference_value.wat_density(curEvent.object_id, curEvent.daytime,'<=');
      ELSIF lv2_object_type = 'WELL' THEN
        ln_return := EcBp_Well_Theoretical.findWatStdDensity(curEvent.object_id, curEvent.daytime);
      ELSIF lv2_object_type = 'EXTERNAL_LOCATION' THEN
        ln_return := ec_ext_loc_reference_value.water_density(curEvent.object_id, curEvent.daytime,'<=');
      END IF;
    END IF;
  END LOOP;
RETURN ln_return;

END findWaterDensity;

---------------------------------------------------------------------------------------------------
-- Function       : findSandDensity
-- Description    : Returns the density for the sand
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findSandDensity (p_event_no NUMBER, p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS

  CURSOR c_object_transport_event(cp_event_no NUMBER) IS
  SELECT ste.object_id, ste.daytime
  FROM strm_transport_event ste
  WHERE ste.event_no = cp_event_no
  UNION ALL
  SELECT ote.object_id, ote.daytime
  FROM object_transport_event ote
  WHERE ote.event_no = cp_event_no;

  ln_return  NUMBER;
  lv2_object_type VARCHAR2(32);
  lv2_resolve_loop VARCHAR2(2000);

BEGIN
  IF InStr(p_resolve_loop,'findSandDensity')>0 THEN
    RETURN NULL; -- loop detected, impossible to calcute.
  ELSE
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findSandDensity';
  END IF;
  -- always only one record
  FOR curEvent IN c_object_transport_event(p_event_no) LOOP
    ln_return := Ue_Truck_Ticket.findSandDensity(p_event_no, lv2_resolve_loop);
    IF ln_return IS NULL THEN
      lv2_object_type := EcDp_Objects.GetObjClassName(curEvent.object_id);
      IF lv2_object_type = 'STREAM' THEN
        ln_return := ec_strm_reference_value.sand_density(curEvent.object_id, curEvent.daytime,'<=');
      ELSIF lv2_object_type = 'WELL' THEN
        ln_return := NULL; -- not supported
      ELSIF lv2_object_type = 'EXTERNAL_LOCATION' THEN
        ln_return := ec_ext_loc_reference_value.sand_density(curEvent.object_id, curEvent.daytime,'<=');
      END IF;
    END IF;
  END LOOP;
RETURN ln_return;

END findSandDensity;

---------------------------------------------------------------------------------------------------
-- Function       : findBSWVolFrac
-- Description    :
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findBSWVolFrac (p_event_no NUMBER, p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS

  CURSOR c_object_transport_event(cp_event_no NUMBER) IS
  SELECT ste.bs_w
  FROM strm_transport_event ste
  WHERE ste.event_no = cp_event_no
  UNION ALL
  SELECT ote.bs_w
  FROM object_transport_event ote
  WHERE ote.event_no = cp_event_no;

  ln_return   NUMBER;
  lv2_resolve_loop VARCHAR2(2000);

BEGIN
  IF InStr(p_resolve_loop,'findBSWVolFrac')>0 THEN
    RETURN NULL; -- loop detected, impossible to calcute.
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findBSWVolFrac';
  END IF;
  -- always only one record
  FOR curEvent IN c_object_transport_event(p_event_no) LOOP
    ln_return := Ue_Truck_Ticket.findBswVolFrac(p_event_no,lv2_resolve_loop);
    IF ln_return IS NULL THEN
      ln_return:= curEvent.bs_w;
    END IF;
  END LOOP;

RETURN ln_return;

END findBSWVolFrac;

---------------------------------------------------------------------------------------------------
  -- Function       : findWellBSWVolFrac
  -- Description    :
  -- Preconditions  :
  -- Postcondition  :
  -- Using Tables   :
  --
  -- Using functions:
  --
  --
  --
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  --
  ---------------------------------------------------------------------------------------------------
  FUNCTION findWellBSWVolFrac(p_event_no     NUMBER
                             ,p_resolve_loop VARCHAR2 DEFAULT NULL)
    RETURN NUMBER
  --</EC-DOC>
   IS

    CURSOR c_object_transport_event(cp_event_no NUMBER) IS
      SELECT wte.bs_w
        FROM well_transport_event wte
       WHERE wte.event_no = cp_event_no
      UNION ALL
      SELECT ote.bs_w
        FROM object_transport_event ote
       WHERE ote.event_no = cp_event_no;

    ln_return        NUMBER;
    lv2_resolve_loop VARCHAR2(2000);

  BEGIN
    IF InStr(p_resolve_loop, 'findWellBSWVolFrac') > 0 THEN
      RETURN NULL; -- loop detected, impossible to calcute.
    ELSE
      -- Call the next function with the argument to this function, or this function name if no argument
      lv2_resolve_loop := NVL(p_resolve_loop, '') || 'findWellBSWVolFrac';
    END IF;
    FOR curEvent IN c_object_transport_event(p_event_no) LOOP
      ln_return := Ue_Truck_Ticket.findWellBswVolFrac(p_event_no,
                                                      lv2_resolve_loop);
      IF ln_return IS NULL THEN
        ln_return := curEvent.bs_w;
      END IF;
    END LOOP;

    RETURN ln_return;

  END findWellBSWVolFrac;

---------------------------------------------------------------------------------------------------
-- Function       : findBswWtFrac
-- Description    :
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findBswWtFrac (p_event_no NUMBER, p_resolve_loop VARCHAR2 DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS

  CURSOR c_object_transport_event(cp_event_no NUMBER) IS
  SELECT ste.bs_w_wt
  FROM strm_transport_event ste
  WHERE ste.event_no = cp_event_no
  UNION ALL
  SELECT ote.bs_w_wt
  FROM object_transport_event ote
  WHERE ote.event_no = cp_event_no;

  ln_return   NUMBER;
  lv2_resolve_loop VARCHAR2(2000);

BEGIN
  IF InStr(p_resolve_loop,'findBswWtFrac')>0 THEN
    RETURN NULL; -- loop detected, impossible to calcute.
  ELSE  -- Call the next function with the argument to this function, or this function name if no argument
    lv2_resolve_loop := Nvl(p_resolve_loop,'') || 'findBswWtFrac';
  END IF;
  -- always only one record
  FOR curEvent IN c_object_transport_event(p_event_no) LOOP
    ln_return := Ue_Truck_Ticket.findBswWtFrac(p_event_no,lv2_resolve_loop);
    IF ln_return IS NULL THEN
      ln_return:= curEvent.bs_w_wt;
    END IF;
  END LOOP;

RETURN ln_return;

END findBswWtFrac;

---------------------------------------------------------------------------------------------------
-- Function       : VolumeCorrFactor
-- Description    :
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION volumeCorrFactor (p_event_no NUMBER)
RETURN NUMBER
--</EC-DOC>
IS

  CURSOR c_object_transport_event(cp_event_no NUMBER) IS
  SELECT ste.vcf
  FROM strm_transport_event ste
  WHERE ste.event_no = cp_event_no
  UNION ALL
  SELECT ote.vcf
  FROM object_transport_event ote
  WHERE ote.event_no = cp_event_no;

  ln_return   NUMBER;


BEGIN
   ln_return := Ue_Truck_Ticket.VolumeCorrFactor(p_event_no);
   IF ln_return IS NULL THEN
     FOR curEvent IN c_object_transport_event(p_event_no) LOOP
       ln_return:= curEvent.vcf;
     END LOOP;
   END IF;

RETURN ln_return;

END volumeCorrFactor;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getFacility
-- Description    : Returns the facility name that the given stream is connected to
--
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions: ec_strm_version, ecdp_objects
-- Configuration  :
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

FUNCTION getFacility(
         p_object_id strm_transport_event.object_id%TYPE,
         p_daytime strm_transport_event.daytime%TYPE
) RETURN VARCHAR2
--<EC-DOC>
IS

lv_fcty_class_1_id strm_version.op_fcty_class_1_id%TYPE;
lv_fcty_class_2_id strm_version.op_fcty_class_2_id%TYPE;


BEGIN
   lv_fcty_class_1_id := ec_strm_version.op_fcty_class_1_id(p_object_id,p_daytime,'<=');
   lv_fcty_class_2_id := ec_strm_version.op_fcty_class_2_id(p_object_id,p_daytime,'<=');

   IF lv_fcty_class_1_id IS NOT NULL THEN
      RETURN ecdp_objects.GetObjName(lv_fcty_class_1_id,p_daytime);
   ELSIF lv_fcty_class_2_id IS NOT NULL THEN
      RETURN ecdp_objects.GetObjName(lv_fcty_class_2_id,p_daytime);
   END IF;

   RETURN '';

END getFacility;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCalcGrsMass
-- Description    : Returns the Gross Mass value
--
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration  :
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

FUNCTION getCalcGrsMass(
         p_stream_id strm_transport_event.stream_id%TYPE,
         p_start_meter_reading strm_transport_event.start_meter_reading%TYPE,
         p_end_meter_reading strm_transport_event.end_meter_reading%TYPE,
         p_daytime strm_transport_event.daytime%TYPE
         )
RETURN NUMBER
IS

ln_TOTALIZER_MAX_COUNT   NUMBER;
ln_METER_FACTOR NUMBER;
ln_grs_mass NUMBER;

BEGIN
      -- Need to find meter factor. If null then using 1.
      ln_METER_FACTOR := nvl(ec_strm_reference_value.meter_factor(p_stream_id,p_daytime,'<='),1);

      IF p_end_meter_reading IS NULL OR p_start_meter_reading IS NULL THEN
         ln_grs_mass := null;
      ELSIF p_end_meter_reading  >= p_start_meter_reading THEN  -- Normal case
         ln_grs_mass := p_end_meter_reading  * ln_METER_FACTOR - p_start_meter_reading * ln_METER_FACTOR;
      ELSE  -- Tip-over
         -- Need to find max totalizer count
         ln_TOTALIZER_MAX_COUNT := ec_strm_reference_value.totalizer_max_count(p_stream_id,p_daytime,'<=');

         IF ln_TOTALIZER_MAX_COUNT IS NOT NULL THEN
            ln_grs_mass := p_end_meter_reading * ln_METER_FACTOR + (ln_TOTALIZER_MAX_COUNT - p_start_meter_reading) * ln_METER_FACTOR;
         --ELSE  -- NO logic on this if the max counter number is not given.

         END IF;
      END IF;

return ln_grs_mass;

END getCalcGrsMass;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcGrsMass
-- Description    : Calculates and insert the gross mass for a given truck ticket
--
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : STRM_TRANSPORT_EVENT
--
-- Using functions: ec_strm_reference_value.totalizer_max_count,ec_strm_reference_value.meter_factor
-- Configuration  :
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

PROCEDURE calcGrsMass(p_unique strm_transport_event.event_no%TYPE,
                             p_start_meter_reading strm_transport_event.start_meter_reading%TYPE,
                             p_end_meter_reading strm_transport_event.end_meter_reading%TYPE,
                             p_user VARCHAR2 DEFAULT USER)
--<EC-DOC>
IS

CURSOR c_strm_transport_event(p_event_no NUMBER) IS
SELECT *
FROM strm_transport_event
WHERE event_no = p_event_no;

ln_TOTALIZER_MAX_COUNT   NUMBER;
ln_METER_FACTOR NUMBER;
ln_grs_mass NUMBER;

BEGIN

    FOR curEvent IN c_strm_transport_event(p_unique) LOOP

        -- Need to find meter factor. If null then using 1.
        ln_METER_FACTOR := nvl(ec_strm_reference_value.meter_factor(curEvent.object_id,curEvent.daytime,'<='),1);

        IF p_end_meter_reading IS NULL OR p_start_meter_reading IS NULL THEN
           RETURN;
        ELSIF p_end_meter_reading  >= p_start_meter_reading THEN  -- Normal case
           ln_grs_mass := p_end_meter_reading  * ln_METER_FACTOR - p_start_meter_reading * ln_METER_FACTOR;
        ELSE  -- Tip-over
           -- Need to find max totalizer count
           ln_TOTALIZER_MAX_COUNT := ec_strm_reference_value.totalizer_max_count(curEvent.object_id,curEvent.daytime,'<=');

           IF ln_TOTALIZER_MAX_COUNT IS NOT NULL THEN

              ln_grs_mass := p_end_meter_reading * ln_METER_FACTOR + (ln_TOTALIZER_MAX_COUNT - p_start_meter_reading) * ln_METER_FACTOR;

           ELSE  -- NO logic on this if the max counter number is not given.
              RETURN;
           END IF;
        END IF;
    END LOOP;

    UPDATE strm_transport_event ste SET ste.grs_mass = ln_grs_mass, last_updated_by=p_user WHERE ste.event_no = p_unique;

END calcGrsMass;

END EcBp_Truck_Ticket;