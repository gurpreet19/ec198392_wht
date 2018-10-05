CREATE OR REPLACE PACKAGE BODY EcBp_Truck_Ticket IS

/****************************************************************
** Package        :  EcBp_Truck_Ticket; body part
**
** $Revision: 1.13.12.6 $
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
**          30.07.2012  limmmchu	 ECPD-21588: Added findLiqGrsMass, findSandMass, findSandVol and calcDensity. Modified findGrsStdVol and findWatVol.
**          07.08.2012  limmmchu	 ECPD-21588: Modified findLiqGrsMass to remove IF statement
**          13.09.2012  rajarsar	 ECPD-21588: Updated findNetStdVol,findGrsStdVol, findWatVol,findSandVol and calcDensity.
**          03.01.2013  musthram	 ECPD-22996: Updated getBswVolFrac.
**          18.04.2013  kumarsur	 ECPD-23972: Updated findWatVol.
**			14.05.2014	dhavaalo	 ECPD-27434: EcBp_Stream_TruckTicket doesn't account for Well to Facility tickets (Object_Transport_event)
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
ld_production_day           DATE;


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

       ln_strm_net_vol := EcBp_Stream_TruckTicket.findnetstdvol(mycur.event_no);
       ln_strm_net_mass := EcBp_Stream_TruckTicket.findnetstdmass(mycur.event_no);
       ln_total_received_water := EcBp_Stream_TruckTicket.findWatVol(mycur.event_no)+ mycur.freeWater;
       ln_total_received_watermass := EcBp_Stream_TruckTicket.findWatMass(mycur.event_no)+ mycur.freeWaterMass;

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

            COMMIT;

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

            COMMIT;

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
    ln_strm_netvol := EcBp_Stream_TruckTicket.findnetstdvol(mycur.event_no);
    ln_strm_water_vol := EcBp_Stream_TruckTicket.findWatVol(mycur.event_no);
    ln_strm_netmass := EcBp_Stream_TruckTicket.findnetstdMass(mycur.event_no);
    ln_strm_water_mass := EcBp_Stream_TruckTicket.findWatMass(mycur.event_no);

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

        COMMIT;

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

        COMMIT;

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
     p_event_no OBJECT_TRANSPORT_EVENT.EVENT_NO%TYPE,
     p_user VARCHAR2 DEFAULT USER)
--</EC-DOC>
IS

  CURSOR c_ste (event_no NUMBER) IS
  SELECT ste.object_id
  FROM OBJECT_TRANSPORT_EVENT ste
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
     LAST_UPDATED_DATE = Ecdp_Date_Time.getCurrentSysdate
   WHERE EVENT_NO = p_event_no;

   -- Call to user_exit
   UE_STREAM_TRUCKTICKET.verifyTicket(p_event_no, p_user);

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
FUNCTION findNetStdVol (
  p_event_no     NUMBER)
RETURN NUMBER
--</EC-DOC>
IS
  CURSOR c_object_transport_event(cp_event_no NUMBER) IS
  SELECT *
  FROM object_transport_event
  WHERE event_no = cp_event_no;

  lv2_object_id               VARCHAR2(32);
  lv2_object_type               VARCHAR2(32);
  ld_daytime                  DATE;
  lv2_method                  VARCHAR2(32);
  lv2_grs_method              VARCHAR2(32);
  ln_bsw                      NUMBER;
  ln_grs_vol                  NUMBER;
  ln_return_val               NUMBER;
  lv2_strm_meter_method       VARCHAR2(300);
  ld_today                    DATE;

BEGIN

  lv2_object_id := ec_object_transport_event.object_id(p_event_no);
  lv2_object_type := ec_object_transport_event.object_type(p_event_no);
  ld_daytime := ec_object_transport_event.daytime(p_event_no);


 IF lv2_object_type = 'STREAM' THEN
  -- Find this streams meter method
  lv2_strm_meter_method := NVL(ec_strm_version.strm_meter_method(lv2_object_id, ld_daytime, '<='),'');
  lv2_method := NVL(ec_strm_version.NET_VOL_METHOD(lv2_object_id,
                                                   ld_daytime,
                                                   '<='), '') ;

  IF (lv2_method = EcDp_Calc_Method.GROSS_BSW) THEN
    IF lv2_strm_meter_method = 'EVENT' THEN
      lv2_grs_method := NVL(ec_strm_version.GRS_VOL_METHOD(lv2_object_id,
                                                           ld_daytime,
                                                           '<='), '');

      -- Find net_vol using event based gross volume and bsw from truck transport data
      IF (lv2_grs_method = EcDp_Calc_Method.MEASURED_TRUCKED) THEN
        ln_return_val := 0;

        -- test if it is a single record or sum over production days to be returned
        IF ld_today IS NULL THEN
          -- Loop over single event record.
          FOR curEvent IN c_object_transport_event (p_event_no) LOOP
            ln_bsw := getBswVolFrac(curEvent.event_no);
            ln_grs_vol := EcBp_Truck_Ticket.findGrsStdVol (curEvent.event_no);
            ln_return_val :=  ln_grs_vol * (1 - ln_bsw);
          END LOOP;

        ELSE -- looking for sum of event values over a given period
          NULL; -- this is not possible, use EcBp_Stream_Fluid.findNetStdVol() instead

        END IF;
      END IF;
    END IF;
  END IF;
ELSIF lv2_object_type = 'WELL' THEN

  FOR curEvent IN c_object_transport_event (p_event_no) LOOP
    ln_bsw := curEvent.Bs_w;
    ln_grs_vol := curEvent.grs_vol_adj;
    ln_return_val :=  ln_grs_vol * (1 - ln_bsw);
  END LOOP;

ELSIF lv2_object_type IN ('EXTERNAL_LOCATION') THEN
 FOR curEvent IN c_object_transport_event (p_event_no) LOOP
    ln_bsw := curEvent.Bs_w;
    ln_grs_vol := EcBp_Truck_Ticket.findGrsStdVol (curEvent.event_no);
    ln_return_val :=  ln_grs_vol * (1 - ln_bsw);
  END LOOP;

ELSE  -- Undefined
    ln_return_val := NULL;
END IF;

  RETURN ln_return_val;

END findNetStdVol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getBswVolFrac
-- Description    : Returns the bsw volume fraction of a given event no.
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--                  EC_STRM_VERSION....
--                  ECBP_STREAM.FINDREFANALYSISSTREAM
--                  ECBP_STREAM_FLUID.GETBSWVOLFRAC
--
-- Configuration
-- required       :
--
-- Behaviour      : Alternative STRM_VERSION.... (BSW_VOL_METHOD):
--
--                 1. 'MEASURED': Find bsw based on measured figures.
--
---------------------------------------------------------------------------------------------------
FUNCTION getBswVolFrac(
  p_event_no     NUMBER)
RETURN NUMBER
--</EC-DOC>
IS
  CURSOR c_object_transport_event(cp_event_no NUMBER) IS
  SELECT *
  FROM object_transport_event
  WHERE event_no = cp_event_no;

  lv2_object_id          VARCHAR2(32);
  ld_daytime             DATE;
  lv2_method             VARCHAR2(32);
  lv2_grs_method         VARCHAR2(32);
  ln_return_val          NUMBER;
  lv2_strm_meter_method  VARCHAR2(300);
  lv2_object_type        VARCHAR2(32);

BEGIN

  lv2_object_type := ec_object_transport_event.object_type(p_event_no);
  ld_daytime := ec_object_transport_event.daytime(p_event_no);

  IF lv2_object_type IN ('EXTERNAL_LOCATION') THEN
    lv2_object_id := ec_object_transport_event.to_object_id(p_event_no);
  ELSE
    lv2_object_id := ec_object_transport_event.object_id(p_event_no);
  END IF;

   -- Find this streams meter method
  lv2_strm_meter_method := NVL(ec_strm_version.strm_meter_method(lv2_object_id, ld_daytime, '<='),'');

   -- Determine which method to use
  lv2_method := NVL(ec_strm_version.BSW_VOL_METHOD(lv2_object_id,
                                                   ld_daytime,
                                                   '<='), '');

   -- Find bsw using measured values
   IF (lv2_method = EcDp_Calc_Method.MEASURED) THEN

     IF lv2_strm_meter_method = 'EVENT' THEN
       lv2_grs_method := NVL(ec_strm_version.GRS_VOL_METHOD( lv2_object_id,
                                                             ld_daytime,
                                                             '<='), ''
                                                           );

       IF (lv2_grs_method = EcDp_Calc_Method.MEASURED_TRUCKED) THEN
         FOR curBsw IN c_object_transport_event(p_event_no)  LOOP
           ln_return_val := curBsw.bs_w;
         END LOOP;

       ELSE
         NULL; -- this is not possible, use EcBp_Stream_Fluid.getBswVolFrac() instead

       END IF;
     END IF;

   ELSE
     ln_return_val := NULL;

   END IF;

   RETURN ln_return_val;

END getBswVolFrac;


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
FUNCTION findGrsStdVol (
  p_event_no     NUMBER)
RETURN NUMBER
--</EC-DOC>
IS
  CURSOR c_object_transport_event(cp_event_no NUMBER) IS
  SELECT *
  FROM object_transport_event
  WHERE event_no = cp_event_no;

  lv2_object_id               VARCHAR2(32);
  ld_daytime                  DATE;
  Lv2_method                  VARCHAR2(32);
  ln_return_val               NUMBER;
  ln_grs_mass                 NUMBER;
  ln_grs_vol_adj              NUMBER;
  ln_density                  NUMBER;
  ld_today                    DATE;
  lv2_ticket_type             VARCHAR2(32);
  lv2_object_type             VARCHAR2(32);

BEGIN

  lv2_object_id := ec_object_transport_event.object_id(p_event_no);
  ld_daytime := ec_object_transport_event.daytime(p_event_no);
  lv2_object_type := ec_object_transport_event.object_type(p_event_no);

  lv2_method := Nvl(ec_strm_version.GRS_VOL_METHOD(
                  lv2_object_id,
                  ld_daytime,
                        '<='), '');

  IF lv2_object_type = 'STREAM' THEN

    IF (lv2_method = EcDp_Calc_Method.MEASURED_TRUCKED) THEN
     --   ln_return_val := 0;

      IF ld_today IS NULL THEN -- indicates we are looking for single event value
        FOR curEvent IN c_object_transport_event (p_event_no) LOOP
          ln_grs_vol_adj :=  curEvent.grs_vol_adj;
          lv2_ticket_type :=  curEvent.ticket_type;
        END LOOP;
        IF lv2_ticket_type = 'SCALE' THEN
          ln_grs_mass := findLiqGrsMass(p_event_no);
          ln_density :=  calcDensity(p_event_no);
          IF ln_density > 0 THEN
            ln_return_val := ln_grs_mass / ln_density;
          ELSIF ln_density = 0 THEN
            ln_return_val := 0;
          END IF;
        ELSE
          ln_return_val :=   ln_grs_vol_adj;
        END IF;

      ELSE -- looking for sum of event values over a given period
        NULL; -- this is not possible, use EcBp_Stream_Fluid.findGrsStdVol() instead
      END IF;

    ELSE -- undefined
      ln_return_val := NULL;
    END IF;

  ELSIF   lv2_object_type = 'EXTERNAL_LOCATION' THEN
    FOR curEvent IN c_object_transport_event (p_event_no) LOOP
      ln_grs_vol_adj :=  curEvent.grs_vol_adj;
      lv2_ticket_type :=  curEvent.ticket_type;
    END LOOP;
    IF lv2_ticket_type = 'SCALE' THEN
      ln_grs_mass := findLiqGrsMass(p_event_no);
      ln_density :=  calcDensity(p_event_no);
      IF ln_density > 0 THEN
        ln_return_val := ln_grs_mass / ln_density;
      ELSIF ln_density = 0 THEN
        ln_return_val := 0;
      END IF;
    ELSE
      ln_return_val :=   ln_grs_vol_adj;
    END IF;
  END IF;

  RETURN ln_return_val;

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
FUNCTION findWatVol (
  p_event_no     NUMBER)
RETURN NUMBER
--</EC-DOC>
IS
  CURSOR c_object_transport_event(cp_event_no NUMBER) IS
  SELECT *
  FROM object_transport_event
  WHERE event_no = cp_event_no;

  lv2_object_id           VARCHAR2(32);
  ld_daytime              DATE;
  lv2_method              VARCHAR2(30);
  lv2_object_type         VARCHAR2(32);
  lv2_grs_method          VARCHAR2(32);
  ln_bsw                  NUMBER;
  ln_sand_cut             NUMBER;
  ln_grs_vol              NUMBER;
  ln_return_val           NUMBER;
  lv2_strm_meter_method   VARCHAR2(300);
  ld_today                DATE;
  lr_strm_version         strm_version%ROWTYPE;
  ln_water_vol             NUMBER;

BEGIN

  lv2_object_id := ec_object_transport_event.object_id(p_event_no);
  ld_daytime := ec_object_transport_event.daytime(p_event_no);
  lv2_object_type := ec_object_transport_event.object_type(p_event_no);

  IF lv2_object_type = 'STREAM' THEN

    lr_strm_version := ec_strm_version.row_by_pk(lv2_object_id, ld_daytime, '<=');

    -- Determine which method to use
    lv2_method := Nvl(lr_strm_version.WATER_VOL_METHOD, '');

    -- Find this streams meter method
    lv2_strm_meter_method := NVL(lr_strm_version.strm_meter_method, '');

    -- Find water vol using the diff between gross and net oil (the bsw is all considered as water)
    IF (lv2_method = EcDp_Calc_Method.GROSS_BSW) THEN

      IF lv2_strm_meter_method = 'EVENT' THEN
        lv2_grs_method := NVL(ec_strm_version.GRS_VOL_METHOD(
                            lv2_object_id,
                            ld_daytime,
                            '<='), '');

       -- Find net_vol using event based gross volume and bsw from truck transport data
        IF(lv2_grs_method = EcDp_Calc_Method.MEASURED_TRUCKED) THEN
          IF ld_today IS NULL THEN -- test if it is a single event record value to be returned
            -- Loop over single event record.
            FOR curEvent IN c_object_transport_event (p_event_no) LOOP
              ln_bsw := getBswVolFrac(curEvent.event_no);
              ln_sand_cut := curEvent.sand_cut;
              ln_water_vol := curEvent.water_vol;
              ln_grs_vol := EcBp_Truck_Ticket.findGrsStdVol(curEvent.event_no);
              ln_return_val :=  (ln_grs_vol * (nvl(ln_bsw,0) - nvl(ln_sand_cut,0))) + nvl(ln_water_vol,0) ;
            END LOOP;
          ELSE -- looking for sum of event values over a given period
            NULL; -- this is not possible, use EcBp_Stream_Fluid.findWatVol() instead
          END IF;
        END IF;
      END IF;
    END IF;
  ELSIF lv2_object_type = 'EXTERNAL_LOCATION' THEN
    FOR curEvent IN c_object_transport_event (p_event_no) LOOP
              ln_bsw := curEvent.Bs_w;
              ln_sand_cut := curEvent.sand_cut;
              ln_water_vol := curEvent.water_vol;
              ln_grs_vol := EcBp_Truck_Ticket.findGrsStdVol(curEvent.event_no);
              ln_return_val :=  (ln_grs_vol * (nvl(ln_bsw,0) - nvl(ln_sand_cut,0))) + nvl(ln_water_vol,0) ;
    END LOOP;


  ELSE
    ln_return_val := NULL;

  END IF;

  RETURN ln_return_val;

END findWatVol;

---------------------------------------------------------------------------------------------------
-- Function       : findLiqGrsMass
-- Description    : Returns the Liquid Grs Mass for a given event no
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--                  EC_STRM_VERSION....
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findLiqGrsMass (
  p_event_no     NUMBER)
RETURN NUMBER
--</EC-DOC>
IS

  ln_grs_mass                 NUMBER;
  ln_tare_mass                NUMBER;
  ln_return_val               NUMBER;

BEGIN

  ln_grs_mass := ec_object_transport_event.grs_mass(p_event_no);
  ln_tare_mass := ec_object_transport_event.tare_mass(p_event_no);

  ln_return_val := ln_grs_mass - ln_tare_mass;


RETURN ln_return_val;

END findLiqGrsMass;
---------------------------------------------------------------------------------------------------
-- Function       : findWaterMass
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
FUNCTION findSandMass (
  p_event_no     NUMBER)
RETURN NUMBER
--</EC-DOC>
IS

  ln_liq_grs_mass NUMBER;
  ln_bs_w         NUMBER;
  ln_return_val   NUMBER;
  ln_sand_cut     NUMBER;

BEGIN

  ln_liq_grs_mass := findLiqGrsMass(p_event_no);
  ln_sand_cut     := ec_object_transport_event.sand_cut(p_event_no);

  ln_return_val := ln_liq_grs_mass * (ln_sand_cut);

RETURN ln_return_val;

END findSandMass;

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
  p_event_no     NUMBER)
RETURN NUMBER
--</EC-DOC>
IS

  CURSOR c_object_transport_event(cp_event_no NUMBER) IS
  SELECT *
  FROM object_transport_event
  WHERE event_no = cp_event_no;

  ln_sand_mass NUMBER;
  ln_density   NUMBER;
  ln_return_val   NUMBER;

BEGIN

   FOR curEvent IN c_object_transport_event (p_event_no) LOOP
     IF curEvent.ticket_type = 'SCALE' THEN
       ln_sand_mass := findSandMass(p_event_no);
       ln_density   := calcDensity(p_event_no);

       IF ln_density > 0 THEN
         ln_return_val := ln_sand_mass / ln_density;
       ELSIF ln_density = 0 THEN
         ln_return_val := 0;
       END IF;
     ELSE
       ln_return_val := findGrsStdVol(p_event_no) * curEvent.Sand_Cut;
     END IF;
   END LOOP;

RETURN ln_return_val;

END findSandVol;

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
  p_event_no     NUMBER)
RETURN NUMBER
--</EC-DOC>
IS

  CURSOR c_object_transport_event(cp_event_no NUMBER) IS
  SELECT *
  FROM object_transport_event
  WHERE event_no = cp_event_no;

  ln_oil_density NUMBER;
  ln_water_density NUMBER;
  ln_sand_density NUMBER;
  ln_bs_w         NUMBER;
  ln_sand_cut     NUMBER;
  ln_return_val   NUMBER;


BEGIN
    FOR cur_truck_event IN c_object_transport_event(p_event_no) LOOP

      IF cur_truck_event.ticket_type = 'SCALE' THEN

        IF cur_truck_event.object_type = 'STREAM' THEN
          ln_oil_density := nvl(ec_strm_reference_value.oil_density(cur_truck_event.object_id, cur_truck_event.daytime,'<='),0);
          ln_water_density := nvl(ec_strm_reference_value.wat_density(cur_truck_event.object_id, cur_truck_event.daytime,'<='),0);
          ln_sand_density := nvl(ec_strm_reference_value.sand_density(cur_truck_event.object_id, cur_truck_event.daytime,'<='),0);
        ElSIF  cur_truck_event.object_type = 'EXTERNAL_LOCATION' THEN
          ln_oil_density := nvl(ec_ext_loc_reference_value.oil_density(cur_truck_event.object_id, cur_truck_event.daytime,'<='),0);
          ln_water_density := nvl(ec_ext_loc_reference_value.water_density(cur_truck_event.object_id, cur_truck_event.daytime,'<='),0);
          ln_sand_density := nvl(ec_ext_loc_reference_value.sand_density(cur_truck_event.object_id, cur_truck_event.daytime,'<='),0);
        END IF;
        ln_bs_w:= nvl(cur_truck_event.bs_w,0);
        ln_sand_cut := nvl(cur_truck_event.sand_cut,0);
      END IF;
    END LOOP;
    ln_return_val := ((ln_oil_density * (1-ln_bs_w)) + (ln_water_density * (ln_bs_w-ln_sand_cut)) + (ln_sand_density * ln_sand_cut));

RETURN ln_return_val;

END calcDensity;

END EcBp_Truck_Ticket;