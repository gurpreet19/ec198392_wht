CREATE OR REPLACE PACKAGE BODY EcBp_Stream_TruckTicket IS
/******************************************************************************
** Package        :  EcBp_Stream_TruckTicket, body part
**
** $Revision: 1.25.2.3 $
**
** Purpose        :  This package contains functions and procedures for Truck Ticket
**           business functions
**
** Documentation  :  www.energy-components.com
**
** Created  : 16.10.2006 OTTERMAG
**
** Modification history:
**
** Version  Date         Whom           Change description:
** -------  ------       -----          -------------------------------------------
**          16.10.2006   OTTERMAG       First version
**          06.11.2006   SEONGKOK       Added functions find_*_by_pc()
**          10.11.2006   SEONGKOK       Moved functions find_*_by_pc() to package EcBp_Stream_Fluid
**          15.05.2007   kaurrjes       ECPD-5487 - Added last_updated_by=p_user in the UPDATE statement in calcGrsMass Procedure
**          23.07.2007   ismaiime       ECPD-6148 - Added last_updated_by = p_user and last_updated_date=currentSysdate to verifyTicket procedure
**          26.07.2007   siah           Added getCalcGrsMass
**          30.08.2007   rahmanaz       ECPD-5724: Added getNetMass
**          10.04.2009   oonnnng        ECPD-6067: Add new cursor c_ste() to retrieve object_id and local lock checking (withinLockedMonth) in verifyTicket() function.
**          04.02.2010   leongsei       ECPD-13197: Added function findNetStdVol, getBswVolFrac, findGrsStdVol, findWatVol,
**                                                                 findNetStdMass, getBswWeightFrac, findGrsStdMass, findWatMass
**                                                  for truck ticket calculation
**          01.09.2010   rajarsar       ECPD-13213:Added checking for ZERO method in getBswVolFrac.
**          06.02.2012   rajarsar       ECPD-19740:Updated findNetStdVol,getBswVolFrac ,findGrsStdVol and findWatVol.
**          03.01.2013   musthram	    ECPD-22996:Updated findNetStdVol,getBswVolFrac,findGrsStdVol and findWatVol.
**			14.05.2014   dhavaalo	    ECPD-27437:EcBp_Stream_TruckTicket doesn't account for Well to Facility tickets (Object_Transport_event)
********************************************************************/

 -- Public type declarations


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getNetVol
-- Description    : Returns the sum of net vols on all truck ticket unload that is linked to given
--                  truck ticket. If non linked unloads, then return grs volume. It also support net_vol
--                  on a single unload event.
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : STRM_TRANSPORT_EVENT
--
-- Using functions:
-- Configuration  :
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

FUNCTION getNetVol(p_unique strm_transport_event.event_no%TYPE) RETURN NUMBER
--<EC-DOC>
IS

ln_net_vol NUMBER;
ln_grs_vol NUMBER;
ln_number_of_linked NUMBER;
lv_class_name strm_transport_event.data_class_name%TYPE;

BEGIN
   SELECT COUNT(ste.event_no) INTO ln_number_of_linked FROM strm_transport_event ste WHERE ste.link_load_unique = p_unique;
   SELECT ste.data_class_name INTO lv_class_name FROM strm_transport_event ste WHERE ste.event_no = p_unique;

   -- Net vol from a load event (sum of unload events or grs vol if non are linked)
   IF ln_number_of_linked < 1 AND lv_class_name = 'STRM_TRUCK_LOAD_VOL' THEN
      SELECT ste.grs_vol INTO ln_grs_vol FROM strm_transport_event ste WHERE ste.event_no = p_unique;
      RETURN ln_grs_vol;
   ELSIF lv_class_name = 'STRM_TRUCK_LOAD_VOL' THEN
      SELECT SUM(ste.net_vol) INTO ln_net_vol FROM strm_transport_event ste WHERE ste.link_load_unique = p_unique;
      RETURN ln_net_vol;
   END IF;

   --Net vol from a unload event
   SELECT ste.net_vol INTO ln_net_vol FROM strm_transport_event ste WHERE ste.event_no = p_unique;

   RETURN ln_net_vol;

END getNetVol;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getWaterVol
-- Description    : Returns the water volume on given truck ticket load, either on a load or a unload
--                  If Load event, then it sum all linked unloads. If Unload, then returning
--                  water vol on given record.
--
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : STRM_TRANSPORT_EVENT
--
-- Using functions: getNetVol
-- Configuration  :
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

FUNCTION getWaterVol(p_unique strm_transport_event.event_no%TYPE) RETURN NUMBER
--<EC-DOC>
IS

ln_water_vol NUMBER;
ln_grs_vol NUMBER;
ln_number_of_linked NUMBER;
lv_class_name strm_transport_event.data_class_name%TYPE;

BEGIN
   SELECT COUNT(ste.event_no) INTO ln_number_of_linked FROM strm_transport_event ste WHERE ste.link_load_unique = p_unique;
   SELECT ste.grs_vol INTO ln_grs_vol FROM strm_transport_event ste WHERE ste.event_no = p_unique;
   SELECT ste.data_class_name INTO lv_class_name FROM strm_transport_event ste WHERE ste.event_no = p_unique;

   -- Load event
   IF ln_number_of_linked < 1 AND ln_grs_vol IS NOT NULL AND lv_class_name = 'STRM_TRUCK_LOAD_VOL' THEN
      RETURN 0;
   ELSIF ln_grs_vol IS NULL AND lv_class_name = 'STRM_TRUCK_LOAD_VOL' THEN
      RETURN NULL;
   ELSIF lv_class_name = 'STRM_TRUCK_LOAD_VOL' THEN
      SELECT SUM(ste.water_vol) INTO ln_water_vol FROM strm_transport_event ste WHERE ste.link_load_unique = p_unique;
      RETURN ln_water_vol;

   -- Unload event
   ELSE
      SELECT ste.water_vol INTO ln_water_vol FROM strm_transport_event ste WHERE ste.event_no = p_unique;
      RETURN ln_water_vol;
   END IF;

END getWaterVol;

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
     p_event_no STRM_TRANSPORT_EVENT.EVENT_NO%TYPE,
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
     LAST_UPDATED_DATE = Ecdp_Date_Time.getCurrentSysdate
   WHERE EVENT_NO = p_event_no;

   -- Call to user_exit
   UE_STREAM_TRUCKTICKET.verifyTicket(p_event_no, p_user);

END verifyTicket;


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
-- Function       : getNetMass
-- Description    : Returns the sum of net mass on all truck ticket unload that is linked to given
--                  truck ticket. If non linked unloads, then calculate a mass from the gross volume
--                  and retur it. It also support net_mass on a single unload event.
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : STRM_TRANSPORT_EVENT
--
-- Using functions:
-- Configuration  :
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

FUNCTION getNetMass(p_unique strm_transport_event.event_no%TYPE) RETURN NUMBER
--<EC-DOC>
IS

ln_net_mass NUMBER;
ln_std_density NUMBER;
ln_number_of_linked NUMBER;

l_event STRM_TRANSPORT_EVENT%ROWTYPE;

CURSOR c_std_density (p_object_id VARCHAR2, p_profit_centre_id VARCHAR2, p_daytime date) is
  select u.std_density
   from strm_transport_event l, strm_transport_event u
   where l.event_no = u.link_load_unique
     and l.object_id = p_object_id
     and l.daytime < p_daytime
     and u.std_density is not null
     and ((l.profit_centre_id = nvl(p_profit_centre_id, l.profit_centre_id))
      or  (l.profit_centre_id is null and p_profit_centre_id is null))
order by u.daytime desc;

BEGIN
   SELECT COUNT(ste.event_no) INTO ln_number_of_linked FROM strm_transport_event ste WHERE ste.link_load_unique = p_unique;

   l_event := ec_strm_transport_event.row_by_pk(p_unique);

   -- Net mass from a load event (sum of unload events or grs vol if non are linked)
   IF ln_number_of_linked < 1 AND l_event.data_class_name = 'STRM_TRUCK_LOAD_VOL' THEN
      -- Find the previous used density for the object and profit centre.
      FOR c_res in c_std_density(l_event.object_id, l_event.profit_centre_id, l_event.daytime) LOOP
          ln_std_density := c_res.std_density;
          RETURN l_event.grs_vol * ln_std_density;
      END LOOP;
      Return null;
   ELSIF l_event.data_class_name = 'STRM_TRUCK_LOAD_VOL' THEN
      SELECT SUM(ste.net_vol * ste.std_density) INTO ln_net_mass FROM strm_transport_event ste WHERE ste.link_load_unique = p_unique;
      RETURN ln_net_mass;
   END IF;

   --Net vol from a unload event
   ln_net_mass := l_event.net_vol * l_event.std_density;

   RETURN ln_net_mass;

END getNetMass;



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
  CURSOR c_strm_transport_event_single(cp_event_no NUMBER) IS
  SELECT object_id,daytime,net_vol,event_no,vcf
  FROM strm_transport_event
  WHERE event_no = cp_event_no
  UNION ALL
  SELECT object_id,daytime,net_vol,event_no,vcf
  FROM object_transport_event ote
  WHERE event_no = cp_event_no;

  lv2_object_id               VARCHAR2(32);
  ld_daytime                  DATE;
  lv2_method                  VARCHAR2(32);
  lv2_grs_method              VARCHAR2(32);
  ln_bsw                      NUMBER;
  ln_grs_vol                  NUMBER;
  ln_return_val               NUMBER;
  lv2_strm_meter_method       VARCHAR2(300);
  ld_today                    DATE;
  lv2_object_type             VARCHAR2(32);

BEGIN

   FOR curEvent IN c_strm_transport_event_single(p_event_no)  LOOP
     lv2_object_id := curEvent.object_id;
     ld_daytime    :=  curEvent.daytime;
   END LOOP;

   lv2_object_type := ec_object_transport_event.object_type(p_event_no);

   IF lv2_object_type IN ('EXTERNAL_LOCATION') THEN
      lv2_object_id := ec_object_transport_event.to_object_id(p_event_no);
   END IF;

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
          FOR curEvent IN c_strm_transport_event_single (p_event_no) LOOP
            ln_bsw := getBswVolFrac(curEvent.event_no);
            ln_grs_vol := EcBp_Stream_TruckTicket.findGrsStdVol (curEvent.event_no);
            ln_return_val :=  ln_grs_vol * (1 - ln_bsw)* nvl(curEvent.vcf,1);
          END LOOP;

        ELSE -- looking for sum of event values over a given period
          NULL; -- this is not possible, use EcBp_Stream_Fluid.findNetStdVol() instead

        END IF;

      -- Find net volume for a truck load by summarize all the unload net volumes
      -- See Ecbp_Stream_Truckticket.getNetVol
      ELSIF(lv2_grs_method = EcDp_Calc_Method.MEASURED_TRUCKED_LOAD) THEN
        ln_return_val := 0;

        -- test if it is a single record or sum over production days to be returned
        IF ld_today IS NULL THEN
          -- Loop over single event record.
          FOR curEvent IN c_strm_transport_event_single (p_event_no) LOOP
            ln_return_val := Ecbp_Stream_Truckticket.getNetVol(curEvent.Event_No);
          END LOOP;

        ELSE -- looking for sum of event values over a given period
          NULL; -- this is not possible, use EcBp_Stream_Fluid.findNetStdVol() instead

        END IF;

      -- Find net volume for a truck unload. Value is calculated in screen and stored in NET_VOL col
      ELSIF(lv2_grs_method = EcDp_Calc_Method.MEASURED_TRUCKED_UNLOAD) THEN
        ln_return_val := 0;
        -- test if it is a single record or sum over production days to be returned
        IF ld_today IS NULL THEN
          -- Loop over single event record.
          FOR curEvent IN c_strm_transport_event_single (p_event_no) LOOP
            ln_return_val := curEvent.Net_Vol;
          END LOOP;

        ELSE -- looking for sum of event values over a given period
          NULL; -- this is not possible, use EcBp_Stream_Fluid.findNetStdVol() instead

        END IF;

      END IF;
    END IF;
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
  CURSOR c_strm_transport_event_single(cp_event_no NUMBER) IS
  SELECT object_id,daytime, bs_w
  FROM strm_transport_event
  WHERE event_no = cp_event_no
  UNION ALL
  SELECT object_id,daytime,bs_w
  FROM object_transport_event ote
  WHERE event_no = cp_event_no;

  lv2_object_id          VARCHAR2(32);
  ld_daytime             DATE;
  lv2_method             VARCHAR2(32);
  lv2_grs_method         VARCHAR2(32);
  ln_return_val          NUMBER;
  lv2_strm_meter_method  VARCHAR2(300);
  lv2_object_type        VARCHAR2(32);


BEGIN

   FOR curEvent IN c_strm_transport_event_single(p_event_no)  LOOP
     lv2_object_id := curEvent.object_id;
     ld_daytime    :=  curEvent.daytime;
   END LOOP;

   lv2_object_type := ec_object_transport_event.object_type(p_event_no);

   IF lv2_object_type IN ('EXTERNAL_LOCATION','WELL') THEN
      lv2_object_id := ec_object_transport_event.to_object_id(p_event_no);
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
         FOR curBsw IN c_strm_transport_event_single(p_event_no)  LOOP
           ln_return_val := curBsw.bs_w;
         END LOOP;

       ELSE
         NULL; -- this is not possible, use EcBp_Stream_Fluid.getBswVolFrac() instead

       END IF;
     END IF;
   ELSIF (lv2_method = EcDp_Calc_Method.ZERO) THEN
     ln_return_val := 0;
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
  CURSOR c_strm_transport_event_single(cp_event_no NUMBER) IS
  SELECT object_id,daytime,grs_vol,grs_vol_adj
  FROM strm_transport_event
  WHERE event_no = cp_event_no
  UNION ALL
  SELECT object_id,daytime,grs_vol,grs_vol_adj
  FROM object_transport_event ote
  WHERE event_no = cp_event_no;

  lv2_object_id               VARCHAR2(32);
  ld_daytime                  DATE;
  Lv2_method                  VARCHAR2(32);
  ln_return_val               NUMBER;
  ld_today                    DATE;
  lv2_object_type             VARCHAR2(32);

BEGIN

   FOR curEvent IN c_strm_transport_event_single(p_event_no)  LOOP
     lv2_object_id := curEvent.object_id;
     ld_daytime    :=  curEvent.daytime;
   END LOOP;

   lv2_object_type := ec_object_transport_event.object_type(p_event_no);

   IF lv2_object_type IN ('EXTERNAL_LOCATION','WELL') THEN
      lv2_object_id := ec_object_transport_event.to_object_id(p_event_no);
   END IF;

  lv2_method := Nvl(ec_strm_version.GRS_VOL_METHOD(
                  lv2_object_id,
                  ld_daytime,
                        '<='), '');

  IF (lv2_method = EcDp_Calc_Method.MEASURED_TRUCKED) THEN
    ln_return_val := 0;

    IF ld_today IS NULL THEN -- indicates we are looking for single event value
      FOR curEvent IN c_strm_transport_event_single (p_event_no) LOOP
        ln_return_val :=  curEvent.grs_vol_adj;
      END LOOP;

    ELSE -- looking for sum of event values over a given period
      NULL; -- this is not possible, use EcBp_Stream_Fluid.findGrsStdVol() instead

    END IF;

  ELSIF (lv2_method = EcDp_Calc_Method.MEASURED_TRUCKED_LOAD) THEN
    ln_return_val := 0;

    IF ld_today IS NULL THEN -- indicates we are looking for single event value
      FOR curEvent IN c_strm_transport_event_single (p_event_no) LOOP
        ln_return_val :=  curEvent.grs_vol;
      END LOOP;

    ELSE -- looking for sum of event values over a given period
      NULL; -- this is not possible, use EcBp_Stream_Fluid.findGrsStdVol() instead

    END IF;

  ELSIF (lv2_method = EcDp_Calc_Method.MEASURED_TRUCKED_UNLOAD) THEN
    ln_return_val := 0;

    IF ld_today IS NULL THEN -- indicates we are looking for single event value
      FOR curEvent IN c_strm_transport_event_single (p_event_no) LOOP
        ln_return_val :=  curEvent.grs_vol;
      END LOOP;

    ELSE -- looking for sum of event values over a given period
      NULL; -- this is not possible, use EcBp_Stream_Fluid.findGrsStdVol() instead

    END IF;

  ELSE -- undefined
    ln_return_val := NULL;

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
  CURSOR c_strm_transport_event_single(cp_event_no NUMBER) IS
  SELECT object_id,daytime,water_vol,event_no
  FROM strm_transport_event
  WHERE event_no = cp_event_no
  UNION ALL
  SELECT object_id,daytime,water_vol,event_no
  FROM object_transport_event ote
  WHERE event_no = cp_event_no;

  lv2_object_id           VARCHAR2(32);
  ld_daytime              DATE;
  lv2_method              VARCHAR2(30);
  lv2_grs_method          VARCHAR2(32);
  ln_bsw                  NUMBER;
  ln_grs_vol              NUMBER;
  ln_return_val           NUMBER;
  lv2_strm_meter_method   VARCHAR2(300);
  ld_today                DATE;
  lr_strm_version         strm_version%ROWTYPE;
  lv2_object_type         VARCHAR2(32);

BEGIN

  FOR curEvent IN c_strm_transport_event_single(p_event_no)  LOOP
    lv2_object_id := curEvent.object_id;
    ld_daytime    :=  curEvent.daytime;
  END LOOP;

   lv2_object_type := ec_object_transport_event.object_type(p_event_no);

   IF lv2_object_type IN ('EXTERNAL_LOCATION') THEN
      lv2_object_id := ec_object_transport_event.to_object_id(p_event_no);
   END IF;

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
          FOR curEvent IN c_strm_transport_event_single (p_event_no) LOOP
            ln_bsw := getBswVolFrac(curEvent.event_no);
            ln_grs_vol := EcBp_Stream_TruckTicket.findGrsStdVol(curEvent.event_no);
            ln_return_val :=  ln_grs_vol * ln_bsw;

          END LOOP;

        ELSE -- looking for sum of event values over a given period
          NULL; -- this is not possible, use EcBp_Stream_Fluid.findWatVol() instead

        END IF;

      -- Finding water vol by summarize all unload water vols linked to given load.
      ELSIF(lv2_grs_method = EcDp_Calc_Method.MEASURED_TRUCKED_LOAD) THEN
        ln_return_val := 0;

        IF ld_today IS NULL THEN -- test if it is a single event record value to be returned
          -- Loop over single event record.
          FOR curEvent IN c_strm_transport_event_single (p_event_no) LOOP
            ln_return_val :=  ecbp_stream_truckticket.getWaterVol(curEvent.Event_No);

          END LOOP;

        ELSE -- looking for sum of event values over a given period
          NULL; -- this is not possible, use EcBp_Stream_Fluid.findWatVol() instead

        END IF;

      -- Water vol for a truck unload is calculated in screen and hence stored in WATER_VOL column.
      ELSIF(lv2_grs_method = EcDp_Calc_Method.MEASURED_TRUCKED_UNLOAD) THEN
        ln_return_val := 0;

        IF ld_today IS NULL THEN -- test if it is a single event record value to be returned
          -- Loop over single event record.
          FOR curEvent IN c_strm_transport_event_single (p_event_no) LOOP
            ln_return_val :=  nvl(curEvent.Water_Vol,0);

          END LOOP;

        ELSE -- looking for sum of event values over a given period
          NULL; -- this is not possible, use EcBp_Stream_Fluid.findWatVol() instead

        END IF;

      ELSE -- Only event streams based on truck transports supported
        ln_return_val := EcBp_Stream_Fluid.findGrsStdVol(lv2_object_id,ld_daytime,NULL)
                         - EcBp_Stream_Fluid.findNetStdVol(lv2_object_id,ld_daytime,NULL);

      END IF;
    END IF;

  ELSE
    ln_return_val := NULL;

  END IF;

  RETURN ln_return_val;

END findWatVol;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findNetStdMass
-- Description    : Returns the net standard mass in kg for given event no
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions: EC_STRM_VERSION....
--                  ECBP_STREAM_FLUID.FINDNETSTDVOL
--
-- Configuration
-- required       :
--
-- Behaviour      : Alternative STRM_VERSION.... (NET_MASS_METHOD):
--
--                1. 'GROSS_BSW' : Calculate net mass based on gross mass and BSW weight frac
---------------------------------------------------------------------------------------------------
FUNCTION findNetStdMass (
  p_event_no     NUMBER)
RETURN NUMBER
--</EC-DOC>
IS
  CURSOR c_strm_transport_event_single(cp_event_no NUMBER) IS
  SELECT *
  FROM strm_transport_event
  WHERE event_no = cp_event_no;

  lv2_object_id         VARCHAR2(32);
  ld_daytime            DATE;
  lv2_method            VARCHAR2(30);
  lv2_grs_method        VARCHAR2(32);
  ln_bsw_wt             NUMBER;
  ln_grs_mass           NUMBER;
  ln_return_val         NUMBER;
  ld_today              DATE;
  lv2_strm_meter_method VARCHAR2(300);

BEGIN
  lv2_object_id := ec_strm_transport_event.object_id(p_event_no);
  ld_daytime := ec_strm_transport_event.daytime(p_event_no);

  lv2_strm_meter_method := NVL(ec_strm_version.strm_meter_method(lv2_object_id, ld_daytime, '<='),'');

  -- Determine which method to use
  lv2_method := Nvl(ec_strm_version.NET_MASS_METHOD(
                    lv2_object_id,
                    ld_daytime,
                    '<='), '');

  -- Calculate based on grs_mass and BSW_wt
  IF (lv2_method = EcDp_Calc_Method.GROSS_BSW) THEN
    IF lv2_strm_meter_method = 'EVENT' THEN
      lv2_grs_method := NVL(ec_strm_version.GRS_MASS_METHOD(
                                                            lv2_object_id,
                                                            ld_daytime,
                                                            '<='), ''
                             );

      -- Find net_vol using event based gross volume and bsw from truck transport data
      IF(lv2_grs_method = EcDp_Calc_Method.MEASURED_TRUCKED) THEN
        ln_return_val := 0;

        -- test if it is a single record or sum over production days to be returned
        IF ld_today IS NULL THEN
          -- Loop over single event record.
          FOR curEvent IN c_strm_transport_event_single (p_event_no) LOOP
            ln_bsw_wt := getBswWeightFrac(curEvent.event_no);
            ln_grs_mass := EcBp_Stream_TruckTicket.findGrsStdMass (curEvent.event_no);
            ln_return_val :=  ln_grs_mass * (1 - ln_bsw_wt);

          END LOOP;

        ELSE -- looking for sum of event values over a given period
          NULL; -- this is not possible, use EcBp_Stream_Fluid.findNetStdMass() instead

        END IF;-- end ld_today IS NULL

      END IF; -- END  IF(lv2_grs_method = EcDp_Calc_Method.MEASURED_TRUCKED)
    END IF;

  ELSE -- Default
    ln_return_val := NULL;

  END IF;

  RETURN ln_return_val;

END findNetStdMass;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getBswWeightFrac
-- Description    : Returns the bsw weight fraction of a given event no.
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions: ec_strm_version....,
--                  EcDp_Calc_Method.MEASURED,
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getBswWeightFrac(
  p_event_no     NUMBER)
RETURN NUMBER
--</EC-DOC>
IS
  CURSOR c_strm_transport_event_single(cp_event_no NUMBER) IS
  SELECT *
  FROM strm_transport_event
  WHERE event_no = cp_event_no;

  lv2_object_id          VARCHAR2(32);
  ld_daytime             DATE;
  lv2_method             VARCHAR2(32);
  lv2_grs_method         VARCHAR2(32);
  ln_return_val          NUMBER;
  lv2_strm_meter_method  VARCHAR2(300);

BEGIN

  lv2_object_id := ec_strm_transport_event.object_id(p_event_no);
  ld_daytime := ec_strm_transport_event.daytime(p_event_no);

  -- Find this streams meter method
  lv2_strm_meter_method := NVL(ec_strm_version.strm_meter_method(lv2_object_id, ld_daytime, '<='),'');

  -- Determine which method to use
  lv2_method := NVL(ec_strm_version.BSW_WT_METHOD(lv2_object_id,
                                                  ld_daytime,
                                                  '<='),'');

  -- Find bs_w wt using data from strm_day_stream only.
  IF (lv2_method = EcDp_Calc_Method.MEASURED) THEN
    IF lv2_strm_meter_method = 'EVENT' THEN
      lv2_grs_method := NVL(ec_strm_version.GRS_MASS_METHOD(lv2_object_id,
                                                            ld_daytime,
                                                            '<='), ''
                                                           );

      IF (lv2_grs_method = EcDp_Calc_Method.MEASURED_TRUCKED) THEN
        FOR curBsw IN c_strm_transport_event_single(p_event_no)  LOOP
          ln_return_val := curBsw.bs_w_wt;
        END LOOP;

      ELSE
        NULL; -- this is not possible, use EcBp_Stream_Fluid.getBswWeightFrac() instead

      END IF;
    END IF;

  ELSE
    ln_return_val := NULL;

  END IF;

  RETURN ln_return_val;

END getBswWeightFrac;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findGrsStdMass
-- Description    : Returns the gross standard mass in kg for a given event no
-- Preconditions  :
-- Postcondition  : All input data to calucations must have a defined value or else
--                  the funtion will return null
-- Using Tables   :
--
-- Using functions: EC_STRM_VERSION....
--
-- Configuration
-- required       :
--
-- Behaviour      : Alternative STRM_VERSION.... (GRS_MASS_METHOD):
--
--                1. 'MEASURED_TRUCKED'
---------------------------------------------------------------------------------------------------
FUNCTION findGrsStdMass (
  p_event_no     NUMBER)
RETURN NUMBER
--</EC-DOC>
IS
  CURSOR c_strm_transport_event_single(cp_event_no NUMBER) IS
  SELECT *
  FROM strm_transport_event
  WHERE event_no = cp_event_no;

  lv2_method             VARCHAR2(30);
  ln_return_val          NUMBER;
  lv2_object_id          VARCHAR2(32);
  ld_daytime             DATE;
  ld_today               DATE;
  lv2_strm_meter_method  VARCHAR2(300);

BEGIN

  lv2_object_id := ec_strm_transport_event.object_id(p_event_no);
  ld_daytime := ec_strm_transport_event.daytime(p_event_no);

  -- Find this streams meter method
  lv2_strm_meter_method := NVL(ec_strm_version.strm_meter_method(lv2_object_id, ld_daytime, '<='),'');

  -- Determine which method to use
  lv2_method := Nvl(ec_strm_version.GRS_MASS_METHOD(
                      lv2_object_id,
                      ld_daytime,
                      '<=' ), '');

  IF (lv2_method = EcDp_Calc_Method.MEASURED_TRUCKED) THEN
    ln_return_val := 0;

    IF ld_today IS NULL THEN -- indicates we are looking for single event value
      FOR curEvent IN c_strm_transport_event_single (p_event_no) LOOP
        ln_return_val :=  curEvent.grs_mass_adj;
      END LOOP;

    ELSE -- looking for sum of event values over a given period
      NULL; -- this is not possible, use EcBp_Stream_Fluid.findGrsStdMass() instead

    END IF;

  ELSE
    ln_return_val := NULL;

  END IF;

  RETURN ln_return_val;

END findGrsStdMass;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findWatMass
-- Description    : Returns the water mass for a given event no
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions: EC_STRM_VERSION....
--
-- Configuration
-- required       :
--
-- Behaviour      : Alternative STRM_VERSION....:
--      (EcDp_Stream_Attribute.WAT_MASS_METHOD):
--                 1. 'GROSS_BSW'
--
---------------------------------------------------------------------------------------------------
FUNCTION findWatMass (
  p_event_no     NUMBER)
RETURN NUMBER
--</EC-DOC>
IS
  CURSOR c_strm_transport_event_single(cp_event_no NUMBER) IS
  SELECT *
  FROM strm_transport_event
  WHERE event_no = cp_event_no;

  lv2_object_id         VARCHAR2(32);
  ld_daytime            DATE;
  ln_grs_mass           NUMBER;
  ln_bsw_wt             NUMBER;
  ln_return_val         NUMBER;
  lv2_method            VARCHAR2(32);
  lv2_strm_meter_method VARCHAR2(300);
  ld_today              DATE;
  lv2_grs_method        VARCHAR2(32);

BEGIN
  lv2_object_id := ec_strm_transport_event.object_id(p_event_no);
  ld_daytime := ec_strm_transport_event.daytime(p_event_no);

  lv2_method := Nvl(ec_strm_version.water_mass_method(
                                                lv2_object_id,
                                                ld_daytime,
                                                '<='), '');

  -- Find this streams meter method
  lv2_strm_meter_method := NVL(ec_strm_version.strm_meter_method(lv2_object_id, ld_daytime, '<='),'');

  IF (lv2_method = EcDp_Calc_Method.GROSS_BSW) THEN
    IF lv2_strm_meter_method = 'EVENT' THEN
      lv2_grs_method := NVL( ec_strm_version.GRS_MASS_METHOD(
                                lv2_object_id,
                                ld_daytime,
                                '<='), '');

      -- Find net_vol using event based gross volume and bsw from truck transport data
      IF (lv2_grs_method = EcDp_Calc_Method.MEASURED_TRUCKED) THEN
        IF ld_today IS NULL THEN -- test if it is a single event record value to be returned
          -- Loop over single event record.
          FOR curEvent IN c_strm_transport_event_single (p_event_no) LOOP
            ln_bsw_wt := getBswWeightFrac(curEvent.event_no);
            ln_grs_mass := EcBp_Stream_TruckTicket.findGrsStdMass (curEvent.event_no);
            ln_return_val :=  ln_grs_mass * ln_bsw_wt;
          END LOOP;

        ELSE -- looking for sum of event values over a given period
          NULL; -- this is not possible, use EcBp_Stream_Fluid.findWatMass() instead

        END IF;
      END IF; -- IF (lv2_grs_method = EcDp_Calc_Method.MEASURED_TRUCKED)
    END IF;

  ELSE -- Default
      ln_return_val := NULL;

  END IF;

  RETURN ln_return_val;

END findWatMass;


END EcBp_Stream_TruckTicket;