CREATE OR REPLACE PACKAGE BODY EcBp_CalculateAPI IS
/****************************************************************
** Package        :  EcBp_CalculateAPI, body part
**
**
** Modification history:
**
**  Date        Whom      Change description:
** ----------  --------  --------------------------------------
** 13.12.10		madondin	ECPD-16071: Added new parameter to pass the event type
**
** 24.01.2011 	madondin  	ECPD-16193: Modified function to enable Daily Tank Status - VCF Calc Screen to get Corrected density from Strm sample analysis
** 01.07.2011	sharawan	ECPD-17865: Modified calcApiNotApprVal and calcApiVal to add new parameter p_daytime for ue_vcf_calculation.
** 06.12.2011	mdondin		ECPD-19240: Added new function calcApiTruckTicket,calcApiNotApprovedTruckTicket and calcApiSinglePWEL
**										to provide VCF calculation from the package to screens Truck Ticket Single Transfer, Truck Ticket Single Load Multiple Offload and Single Production Well Test Result
** 23.12.2011   madondin	ECPD-19605:	Added new function getVCFForTruckTicket and getStdDensityForTruckTicket
** 07.11.2012   rajarsar	ECPD-20359: Modified the function of calcApiTruckTicket, calcApiNotApprovedTruckTicket, getVCFForTruckTicket and getStdDensityForTruckTicket.
                                        Added 2 new procedures calcNetVol and calcNetVolNotApproved
** 01.12.2013   wonggkai	ECPD-26240: Updated procedures calcApiVal and calcApiNotApprVal to support units correctly.
** 02.04.2014   musthram	ECPD-27161: Updated procedure calcApiNotApprVal to support additional bf_usage for event tank status screen.
** 27.03.2014	dhavaalo	ECPD-27208: ECBP_CalculateApi.CalcApiVal does not consider measurement_event_type for VCF calc
*****************************************************************/

---------------------------------------------------------------------------------------------------
-- Procedure      : CalculateApiVal
-- Description    : Calculates what the observed API gravity would have been given the
--                  corrected API gravity and the sample temperature whem click Calculate Selected button
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
PROCEDURE calcApiVal(
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_event_type  VARCHAR2,
   p_user VARCHAR2)

IS

   lv2_class_name               VARCHAR2(24);
   lv2_vcf_method               VARCHAR2(32);
   lv2_OBS_Dens_method          VARCHAR2(32);
   ln_temp                      NUMBER;
   ln_VCF_temp                  NUMBER;
   ln_API_obs                   NUMBER;
   ln_corr_API                  NUMBER;
   ln_VCF                       NUMBER;
   ln_Dens_obs                  NUMBER;
   ln_corr_Dens                 NUMBER;
   lr_measurement_type          tank_measurement%ROWTYPE;
   lr_strm_measurement_type     strm_event%ROWTYPE;
   lv_temp_unit                 VARCHAR2(16);
   lv_corr_gravity_method       VARCHAR2(32);
   lv_corr_density_method       VARCHAR2(32);
   lv_event_type                VARCHAR2(32);
   lv_density_unit              VARCHAR2(16);


BEGIN

   lv2_class_name := ecdp_objects.GetObjClassName(p_object_id);
   lv_event_type := p_event_type;
   IF lv2_class_name = 'TANK' THEN
     lr_measurement_type := ec_tank_measurement.row_by_pk(p_object_id,lv_event_type,p_daytime);
     lv2_vcf_method := ec_tank_version.vcf_method(p_object_id, p_daytime,'<=');
     lv2_OBS_Dens_method := ec_tank_version.obs_dens_method(p_object_id, p_daytime,'<=');
     ln_API_obs := lr_measurement_type.api;
     ln_Dens_obs := lr_measurement_type.obs_density;
     --to get the corrected gravity and density method whether measured or not
     lv_corr_gravity_method := ec_tank_version.corr_gravity_method(p_object_id, p_daytime ,'<=');
     lv_corr_density_method := ec_tank_version.corr_density_method(p_object_id, p_daytime ,'<=');
     --temperature to calculate corrected Gravity and Density
     ln_temp := lr_measurement_type.temp;
     --temperature to calculate VCF priority run_temp,line_temp,temp
     ln_VCF_temp := NVL(NVL(lr_measurement_type.run_temp,lr_measurement_type.line_temp),lr_measurement_type.temp);
     --temperature unit in db
     lv_temp_unit := ecdp_unit.GetUnitFromLogical('TEMP');
     lv_density_unit := ecdp_unit.GetUnitFromLogical('OIL_DENS');
     IF (lv2_vcf_method = 'API')  AND (substr(lv2_OBS_Dens_method,1,3) = 'API') THEN
       IF (lv_corr_gravity_method != 'MEASURED' OR lv_corr_gravity_method is null) THEN
         ln_corr_API := Ecbp_Vcf.calcAPIGravityCorr(ln_API_obs, ln_temp);
         ln_VCF := Ecbp_Vcf.calcVCFstdAPI(ln_corr_API, ln_VCF_temp);
         UPDATE tank_measurement
         SET corr_api         = ln_corr_API,
         vcf                  = ln_VCF,
	     last_updated_by      = p_user
         WHERE object_id = p_object_id
         AND daytime = p_daytime
         AND measurement_event_type = p_event_type;
       ELSE
         ln_VCF := Ecbp_Vcf.calcVCFstdAPI(lr_measurement_type.corr_api, ln_VCF_temp);
         UPDATE tank_measurement
         SET vcf              = ln_VCF,
	     last_updated_by      = p_user
         WHERE object_id      = p_object_id
         AND daytime          = p_daytime
         AND measurement_event_type = p_event_type;
       END IF;
     ELSIF (lv2_vcf_method = 'API') AND (substr(lv2_OBS_Dens_method,1,3) != 'API') THEN
       IF (lv_corr_density_method = 'CALCULATED' OR lv_corr_density_method is null) THEN
         IF lv_temp_unit = 'C' AND lv_density_unit = 'KGPERM3' THEN
           ln_corr_Dens := Ecbp_Vcf.calcDensityCorr_SI(ln_Dens_obs, ln_temp);
           ln_VCF := Ecbp_Vcf.calcVCFstdDensity_SI(ln_corr_Dens, ln_VCF_temp);
         ELSIF lv_temp_unit ='F' THEN
         ln_corr_Dens := Ecbp_Vcf.calcDensityCorr(ln_Dens_obs, ln_temp);
         ln_VCF := Ecbp_Vcf.calcVCFstdDensity(ln_corr_Dens, ln_VCF_temp);
         END IF;
         UPDATE tank_measurement
         SET corr_density     = ln_corr_Dens,
         vcf                  = ln_VCF,
		 last_updated_by      = p_user
         WHERE object_id = p_object_id
         AND daytime = p_daytime
         AND measurement_event_type = p_event_type;
	   ELSIF (lv_corr_density_method = 'STREAM_SAMPLE_ANALYSIS') THEN
       IF lv_temp_unit = 'C' AND lv_density_unit = 'KGPERM3' THEN
         ln_corr_Dens := Ecbp_Vcf.calcDensityCorr_SI(ln_Dens_obs, ln_temp);
         ln_VCF := Ecbp_Vcf.calcVCFstdDensity_SI(ln_corr_Dens, ln_VCF_temp);
       ELSIF lv_temp_unit ='F' THEN
         ln_corr_Dens := Ecbp_Vcf.calcDensityCorr(ln_Dens_obs, ln_temp);
         ln_VCF := Ecbp_Vcf.calcVCFstdDensity(ln_corr_Dens, ln_VCF_temp);
       END IF;
         UPDATE tank_measurement
         SET vcf              = ln_VCF,
		 last_updated_by      = p_user
         WHERE object_id      = p_object_id
         AND daytime          = p_daytime
         AND measurement_event_type = p_event_type;
       ELSE
         IF lv_temp_unit = 'C' AND lv_density_unit = 'KGPERM3' THEN
           ln_VCF := Ecbp_Vcf.calcVCFstdDensity_SI(lr_measurement_type.corr_density, ln_VCF_temp);
         ELSIF lv_temp_unit ='F' THEN
         ln_VCF := Ecbp_Vcf.calcVCFstdDensity(lr_measurement_type.corr_density, ln_VCF_temp);
         END IF;
         UPDATE tank_measurement
         SET vcf              = ln_VCF,
		 last_updated_by      = p_user
         WHERE object_id      = p_object_id
         AND daytime          = p_daytime
         AND measurement_event_type = p_event_type;
       END IF;
     ELSIF (lv2_vcf_method = 'USER_EXIT') THEN
       ln_corr_API := ue_vcf_calculation.GetApi(p_object_id, lr_measurement_type.api, lr_measurement_type.temp, p_daytime);
       ln_VCF := ue_vcf_calculation.GetVcf(p_object_id, lr_measurement_type.temp, ln_corr_API, lr_measurement_type.run_temp, lr_measurement_type.line_temp, p_daytime);
       UPDATE tank_measurement
       SET corr_api         = ln_corr_API,
       vcf                  = ln_VCF,
	   last_updated_by      = p_user
       WHERE object_id = p_object_id
       AND daytime = p_daytime
	   AND measurement_event_type = p_event_type;
     ELSIF (lv2_vcf_method = 'NO_VCF') THEN
            UPDATE tank_measurement
            SET vcf              = 1,
			last_updated_by      = p_user
            WHERE object_id      = p_object_id
            AND daytime          = p_daytime
            AND measurement_event_type = p_event_type;
     END IF;
   ELSIF lv2_class_name = 'STREAM' THEN
      lv2_vcf_method := ec_strm_version.vcf_method(p_object_id, p_daytime,'<=');
      lr_strm_measurement_type := ec_strm_event.row_by_pk(p_object_id,p_event_type,p_daytime);
      ln_API_obs := lr_strm_measurement_type.api;
      --temperature to calculate corrected Gravity and Density
      ln_temp := lr_strm_measurement_type.avg_temp;
      --temperature to calculate VCF priority run_temp,line_temp,temp
      ln_VCF_temp := NVL(lr_strm_measurement_type.run_temp,lr_strm_measurement_type.avg_temp);
      --temperature unit in db
      lv_temp_unit := ecdp_unit.GetUnitFromLogical('TEMP');
      --to convert the temperature to C if in F
      IF lv_temp_unit = 'C' THEN
        ln_temp := ecdp_unit.convertValue(ln_temp,'C','F');
        ln_VCF_temp := ecdp_unit.convertValue(ln_VCF_temp,'C','F');
      END IF;
      ln_corr_API := Ecbp_Vcf.calcAPIGravityCorr(ln_API_obs, ln_temp);
      ln_VCF := Ecbp_Vcf.calcVCFstdAPI(ln_corr_API, ln_VCF_temp);
        UPDATE strm_event
        SET corr_api         = ln_corr_API,
        vcf                  = ln_VCF,
		last_updated_by      = p_user
        WHERE object_id      = p_object_id
        AND daytime          = p_daytime
        AND event_type       = p_event_type;
   END IF;

END calcApiVal;


--<EC-DOC>

---------------------------------------------------------------------------------------------------
-- Procedure      : calcApiNotApprVal
-- Description    : Calculate the VCF when click the Calculate All Not Approved button
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
--  b.obs_dens_method, a.api, a.corr_api, a.corr_density, a.temp
---------------------------------------------------------------------------------------------------
PROCEDURE calcApiNotApprVal(
   p_daytime           DATE,
   p_fcty_class_1_id   VARCHAR2,
   p_event_type  VARCHAR2,
   p_user VARCHAR2)

IS
-- this cursor is to select all records with status is not approve
  CURSOR c_calc_not_appr(cp_event_type varchar2) is
  SELECT a.object_id,a.vcf_method, a.obs_dens_method,
  b.temp, b.run_temp, b.line_temp,
  b.api, b.corr_api, b.obs_density, b.corr_density
  FROM tank_version a, tank_measurement b
  WHERE a.object_id = b.object_id
  AND b.daytime = p_daytime
  AND b.measurement_event_type = cp_event_type
  AND a.bf_usage IN ('PO.0005.02', 'PO.0082')
  AND a.op_fcty_class_1_id = p_fcty_class_1_id
  --AND a.vcf_method = 'API'
  AND b.record_status != 'A';

   ln_corr_API                  NUMBER;
   ln_corr_Dens                 NUMBER;
   ln_VCF                       NUMBER;
   lv_temp_unit                 VARCHAR2(16);
   lv_density_unit              VARCHAR2(16);
   ln_temp                      NUMBER;
   ln_VCF_temp                  NUMBER;
   lv_corr_gravity_method       VARCHAR2(32);
   lv_corr_density_method       VARCHAR2(32);
   lv_event_type                VARCHAR2(32);

BEGIN

   lv_event_type := p_event_type;
   --temperature unit in db
   lv_temp_unit := ecdp_unit.GetUnitFromLogical('TEMP');
   lv_density_unit := ecdp_unit.GetUnitFromLogical('OIL_DENS');
   FOR cur_rec IN c_calc_not_appr(lv_event_type) LOOP
       --temperature to calculate corrected Gravity and Density
       ln_temp := cur_rec.temp;
       --temperature to calculate VCF priority run_temp,line_temp,temp
       ln_VCF_temp := nvl(nvl(cur_rec.run_temp,cur_rec.line_temp),cur_rec.temp);
       --to get the corrected gravity and density method whether measured or not
       lv_corr_gravity_method := ec_tank_version.corr_gravity_method(cur_rec.object_id, p_daytime ,'<=');
       lv_corr_density_method := ec_tank_version.corr_density_method(cur_rec.object_id, p_daytime ,'<=');
       -- if vcf method=API and obs substr(density method,1,2) = API
       IF (cur_rec.vcf_method = 'API') AND (substr(cur_rec.obs_dens_method,1,3)='API') THEN
         IF (lv_corr_gravity_method != 'MEASURED' OR lv_corr_gravity_method is null) THEN
           ln_corr_API := Ecbp_Vcf.calcAPIGravityCorr(cur_rec.api, ln_temp);
           ln_VCF := Ecbp_Vcf.calcVCFstdAPI(ln_corr_API, ln_VCF_temp);
           UPDATE tank_measurement
           SET corr_api         = ln_corr_API,
           vcf                  = ln_VCF,
		   last_updated_by      = p_user
           WHERE object_id      = cur_rec.object_id
           AND daytime          = p_daytime
           AND measurement_event_type = p_event_type;
         ELSE
           ln_VCF := Ecbp_Vcf.calcVCFstdAPI(cur_rec.corr_api, ln_VCF_temp);
           UPDATE tank_measurement
           SET vcf              = ln_VCF,
		   last_updated_by      = p_user
           WHERE object_id      = cur_rec.object_id
           AND daytime          = p_daytime
           AND measurement_event_type = p_event_type;
         END IF;
       ELSIF (cur_rec.vcf_method = 'API') AND (substr(cur_rec.obs_dens_method,1,3) != 'API') THEN
         IF (lv_corr_density_method = 'CALCULATED' OR lv_corr_density_method is null) THEN
         IF lv_temp_unit = 'C' AND lv_density_unit = 'KGPERM3' THEN
           ln_corr_Dens := Ecbp_Vcf.calcDensityCorr_SI(cur_rec.obs_density, ln_temp);
           ln_VCF := Ecbp_Vcf.calcVCFstdDensity_SI(ln_corr_Dens, ln_VCF_temp);
         ELSIF lv_temp_unit ='F' THEN
           ln_corr_Dens := Ecbp_Vcf.calcDensityCorr(cur_rec.obs_density, ln_temp);
           ln_VCF := Ecbp_Vcf.calcVCFstdDensity(ln_corr_Dens,ln_VCF_temp);
         END IF;
           UPDATE tank_measurement
           SET corr_density     = ln_corr_Dens,
           vcf                  = ln_VCF,
		   last_updated_by      = p_user
           WHERE object_id      = cur_rec.object_id
           AND daytime          = p_daytime
           AND measurement_event_type = p_event_type;
		 ELSIF (lv_corr_density_method = 'STREAM_SAMPLE_ANALYSIS') THEN
         IF lv_temp_unit = 'C' AND lv_density_unit = 'KGPERM3' THEN
           ln_VCF := Ecbp_Vcf.calcVCFstdDensity_SI(ecbp_tank.findStdDens(cur_rec.object_id,p_event_type,p_daytime,lv_corr_density_method),ln_VCF_temp);
         ELSIF lv_temp_unit ='F' THEN
           ln_VCF := Ecbp_Vcf.calcVCFstdDensity(ecbp_tank.findStdDens(cur_rec.object_id,p_event_type,p_daytime,lv_corr_density_method),ln_VCF_temp);
         END IF;
           UPDATE tank_measurement
           SET vcf              = ln_VCF,
		   last_updated_by      = p_user
           WHERE object_id      = cur_rec.object_id
           AND daytime          = p_daytime
           AND measurement_event_type = p_event_type;
         ELSE
         IF lv_temp_unit = 'C' AND lv_density_unit = 'KGPERM3' THEN
           ln_VCF := Ecbp_Vcf.calcVCFstdDensity_SI(cur_rec.corr_density, ln_VCF_temp);
         ELSIF lv_temp_unit ='F' THEN
           ln_VCF := Ecbp_Vcf.calcVCFstdDensity(cur_rec.corr_density,ln_VCF_temp);
         END IF;
           UPDATE tank_measurement
           SET vcf              = ln_VCF,
		   last_updated_by      = p_user
           WHERE object_id      = cur_rec.object_id
           AND daytime          = p_daytime
           AND measurement_event_type = p_event_type;
         END IF;
       ELSIF (cur_rec.vcf_method = 'USER_EXIT') THEN
         ln_corr_API := ue_vcf_calculation.GetApi(cur_rec.object_id, cur_rec.api, ln_temp, p_daytime);
         ln_VCF := ue_vcf_calculation.GetVcf(cur_rec.object_id, cur_rec.temp, cur_rec.corr_api, cur_rec.run_temp, cur_rec.line_temp, p_daytime);
         UPDATE tank_measurement
         SET corr_api         = ln_corr_API,
         vcf                  = ln_VCF,
		 last_updated_by      = p_user
         WHERE object_id = cur_rec.object_id
         AND daytime = p_daytime
		 AND measurement_event_type = p_event_type;
       END IF;
   END LOOP;

END calcApiNotApprVal;

---------------------------------------------------------------------------------------------------
-- Procedure      : calcApiTruckTicket
-- Description    : Calculates what the observed API gravity would have been, given the
--                  corrected API gravity and sample temperature.
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
PROCEDURE calcApiTruckTicket(
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_event_no  VARCHAR2,
   p_user VARCHAR2)
IS
   ln_obs_temp                  NUMBER;
   ln_run_temp                  NUMBER;
   ln_VCF_temp                  NUMBER;
   ln_obs_density               NUMBER;
   ln_API_obs                   NUMBER;
   ln_VCF                       NUMBER;
   ln_temp                      NUMBER;
   ln_corr_Dens                 NUMBER;
   ln_corr_API                  NUMBER;
   lv_temp_unit                 VARCHAR2(16);
   lv_density_unit              VARCHAR2(16);
   lr_strm_trans_event          strm_transport_event%ROWTYPE;

BEGIN
	lr_strm_trans_event := ec_strm_transport_event.row_by_pk(p_event_no);
	ln_obs_density := lr_strm_trans_event.obs_density;
	ln_run_temp := lr_strm_trans_event.run_temp;
	ln_API_obs := lr_strm_trans_event.api;
	--temperature to calculate corrected Gravity and Density
	ln_obs_temp := lr_strm_trans_event.obs_temp;
    --get the run temp if exists to calculate the VCF
	ln_VCF_temp := NVL(ln_run_temp,ln_obs_temp);
	ln_temp := ln_obs_temp;
    --temperature unit in db
	lv_temp_unit := ecdp_unit.GetUnitFromLogical('TEMP');
    --density unit in db
	lv_density_unit := ecdp_unit.GetUnitFromLogical('OIL_DENS');
    --to convert the temperature to C if in F
	IF lv_temp_unit = 'C' AND lv_density_unit = 'KGPERM3' THEN
	  ln_corr_Dens := Ecbp_Vcf.calcDensityCorr_SI(ln_obs_density, ln_temp);
	  ln_VCF := Ecbp_Vcf.calcVCFstdDensity_SI(ln_corr_Dens, ln_VCF_temp);
	ELSIF lv_temp_unit ='F' THEN
      ln_corr_API := Ecbp_Vcf.calcAPIGravityCorr(ln_API_obs, ln_temp);
      ln_corr_Dens := Ecbp_Vcf.getDensityFromAPI(ln_corr_API);
      ln_VCF := Ecbp_Vcf.calcVCFobsAPI(ln_corr_API, ln_VCF_temp);
  END IF;

  UPDATE strm_transport_event
  SET corr_api         = ln_corr_API,
  std_density          = ln_corr_Dens,
  vcf                  = ln_VCF,
  last_updated_by      = p_user
  WHERE event_no       = p_event_no;

END calcApiTruckTicket;

---------------------------------------------------------------------------------------------------
-- Procedure      : calcApiNotApprovedTruckTicket
-- Description    : Calculates what the observed API gravity would have been given the
--                  corrected API gravity and the sample temperature when click Calculate All Not Approved button
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
PROCEDURE calcApiNotApprovedTruckTicket(
   p_start_date        DATE,
   p_end_date          DATE,
   p_data_class_name   VARCHAR2,
   p_user VARCHAR2)
IS
  CURSOR c_calc_not_appr is
  SELECT a.object_id, a.daytime, a.event_no, a.data_class_name,
  a.obs_density, a.api, a.obs_temp, a.run_temp, a.corr_api, a.std_density
  FROM strm_transport_event a
  WHERE a.daytime between p_start_date and p_end_date
  AND a.data_class_name = p_data_class_name
  AND a.record_status != 'A';

   ln_obs_temp                  NUMBER;
   ln_run_temp                  NUMBER;
   ln_VCF_temp                  NUMBER;
   ln_obs_density               NUMBER;
   ln_API_obs                   NUMBER;
   ln_VCF                       NUMBER;
   ln_temp                      NUMBER;
   ln_corr_Dens                 NUMBER;
   ln_corr_API                  NUMBER;
   lv_temp_unit                 VARCHAR2(16);
   lv_density_unit              VARCHAR2(16);

BEGIN
   FOR cur_rec IN c_calc_not_appr LOOP
     ln_obs_density := cur_rec.obs_density;
     ln_run_temp := cur_rec.run_temp;
     ln_API_obs := cur_rec.api;
     --temperature to calculate corrected Gravity and Density
     ln_obs_temp := cur_rec.obs_temp;
     --get the run temp if exists to calculate the VCF
     ln_VCF_temp := NVL(ln_run_temp,ln_obs_temp);
     ln_temp := ln_obs_temp;
     --temperature unit in db
     lv_temp_unit := ecdp_unit.GetUnitFromLogical('TEMP');
     --density unit in db
     lv_density_unit := ecdp_unit.GetUnitFromLogical('OIL_DENS');
     IF lv_temp_unit = 'C' AND lv_density_unit = 'KGPERM3' THEN
       ln_corr_Dens := Ecbp_Vcf.calcDensityCorr_SI(ln_obs_density, ln_temp);
       ln_VCF := Ecbp_Vcf.calcVCFstdDensity_SI(ln_corr_Dens, ln_VCF_temp);
     ELSIF lv_temp_unit ='F' THEN
       ln_corr_API := Ecbp_Vcf.calcAPIGravityCorr(ln_API_obs, ln_temp);
       ln_corr_Dens := Ecbp_Vcf.getDensityFromAPI(ln_corr_API);
       ln_VCF := Ecbp_Vcf.calcVCFobsAPI(ln_corr_API, ln_VCF_temp);
     END IF;
	 UPDATE strm_transport_event
	 SET corr_api         = ln_corr_API,
	 std_density          = ln_corr_Dens,
	 vcf                  = ln_VCF,
	 last_updated_by      = p_user
	 WHERE event_no       = cur_rec.event_no;
   END LOOP;

END calcApiNotApprovedTruckTicket;

---------------------------------------------------------------------------------------------------
-- Procedure      : calcApiSinglePWEL
-- Description    : Calculates what the observed API gravity would have been given the
--                  corrected API gravity and the  temperature
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
PROCEDURE calcApiSinglePWEL(
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_result_no   VARCHAR2,
   p_class_name  VARCHAR2,
   p_user VARCHAR2)
IS
   ln_obs_temp                  NUMBER;
   ln_run_temp                  NUMBER;
   ln_VCF_temp                  NUMBER;
   ln_API_obs                   NUMBER;
   ln_VCF                       NUMBER;
   ln_temp                      NUMBER;
   ln_corr_API                  NUMBER;
   lv_temp_unit                 VARCHAR2(16);
   lr_eqpm_result               eqpm_result%ROWTYPE;

BEGIN
	lr_eqpm_result := ec_eqpm_result.row_by_pk(p_object_id,p_result_no);
	ln_API_obs := lr_eqpm_result.observed_gravity;
	ln_run_temp := lr_eqpm_result.run_temp;
    --temperature to calculate corrected Gravity and Density
	ln_obs_temp := lr_eqpm_result.observed_temp;
    --get the run temp if exists to calculate the VCF
	ln_VCF_temp := NVL(ln_run_temp,ln_obs_temp);
	ln_temp := ln_obs_temp;
    --temperature unit in db
	lv_temp_unit := ecdp_unit.GetUnitFromLogical('TEMP');
    --to convert the temperature to C if in F
	IF lv_temp_unit = 'C' THEN
	  ln_temp := ecdp_unit.convertValue(ln_obs_temp,'C','F');
	  ln_VCF_temp := ecdp_unit.convertValue(ln_VCF_temp,'C','F');
	END IF;
	IF ec_eqpm_version.grs_liq_vol_method(p_object_id,p_daytime,'<=') = 'TOTALIZER' or ec_eqpm_version.grs_water_vol_method(p_object_id,p_daytime,'<=') =  'TOTALIZER' THEN
	  ln_corr_API := Ecbp_Vcf.calcAPIGravityCorr(ln_API_obs, ln_temp);
	  ln_VCF := Ecbp_Vcf.calcVCFobsAPI(ln_corr_API, ln_VCF_temp);

	  UPDATE eqpm_result
	  SET corr_gravity     = ln_corr_API,
	  vcf                  = ln_VCF,
	  last_updated_by      = p_user
	  WHERE object_id      = p_object_id
	  --AND daytime          = p_daytime
	  AND result_no        = p_result_no;
	  --AND data_class_name  = p_class_name;
	END IF;

END calcApiSinglePWEL;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getVCFForTruckTicket
-- Description    : Returns VCF
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
FUNCTION getVCFForTruckTicket(
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_event_no  VARCHAR2)

RETURN NUMBER
--</EC-DOC>
IS
   ln_obs_temp                  NUMBER;
   ln_run_temp                  NUMBER;
   ln_VCF_temp                  NUMBER;
   ln_obs_density               NUMBER;
   ln_API_obs                   NUMBER;
   ln_VCF                       NUMBER;
   ln_temp                      NUMBER;
   ln_corr_Dens                 NUMBER;
   ln_corr_API                  NUMBER;
   lv_temp_unit                 VARCHAR2(16);
   lv_density_unit              VARCHAR2(16);
   lr_strm_trans_event          strm_transport_event%ROWTYPE;

BEGIN
	lr_strm_trans_event := ec_strm_transport_event.row_by_pk(p_event_no);
	ln_obs_density := lr_strm_trans_event.obs_density;
	ln_run_temp := lr_strm_trans_event.run_temp;
	ln_API_obs := lr_strm_trans_event.api;
	--temperature to calculate corrected Gravity and Density
	ln_obs_temp := lr_strm_trans_event.obs_temp;
    --get the run temp if exists to calculate the VCF
	ln_VCF_temp := NVL(ln_run_temp,ln_obs_temp);
	ln_temp := ln_obs_temp;
    --temperature unit in db
	lv_temp_unit := ecdp_unit.GetUnitFromLogical('TEMP');
    --density unit in db
	lv_density_unit := ecdp_unit.GetUnitFromLogical('OIL_DENS');
    --to convert the temperature to C if in F
	IF lv_temp_unit = 'C' AND lv_density_unit = 'KGPERM3' THEN
	  ln_corr_Dens := Ecbp_Vcf.calcDensityCorr_SI(ln_obs_density, ln_temp);
	  ln_VCF := Ecbp_Vcf.calcVCFstdDensity_SI(ln_corr_Dens, ln_VCF_temp);
	ELSIF lv_temp_unit ='F' THEN
      ln_corr_API := Ecbp_Vcf.calcAPIGravityCorr(ln_API_obs, ln_temp);
      ln_corr_Dens := Ecbp_Vcf.getDensityFromAPI(ln_corr_API);
      ln_VCF := Ecbp_Vcf.calcVCFobsAPI(ln_corr_API, ln_VCF_temp);
  END IF;

  RETURN ln_VCF;

END getVCFForTruckTicket;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getStdDensityForTruckTicket
-- Description    : Returns Corrected Density
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
FUNCTION getStdDensityForTruckTicket(
   p_object_id   VARCHAR2,
   p_daytime     DATE,
   p_event_no  VARCHAR2)

RETURN NUMBER
--</EC-DOC>
IS
   ln_obs_temp                  NUMBER;
   ln_run_temp                  NUMBER;
   ln_VCF_temp                  NUMBER;
   ln_obs_density               NUMBER;
   ln_API_obs                   NUMBER;
   ln_VCF                       NUMBER;
   ln_temp                      NUMBER;
   ln_corr_Dens                 NUMBER;
   ln_corr_API                  NUMBER;
   lv_temp_unit                 VARCHAR2(16);
   lv_density_unit              VARCHAR2(16);
   lr_strm_trans_event          strm_transport_event%ROWTYPE;

BEGIN
	lr_strm_trans_event := ec_strm_transport_event.row_by_pk(p_event_no);
	ln_obs_density := lr_strm_trans_event.obs_density;
	ln_run_temp := lr_strm_trans_event.run_temp;
	ln_API_obs := lr_strm_trans_event.api;
	--temperature to calculate corrected Gravity and Density
	ln_obs_temp := lr_strm_trans_event.obs_temp;
    --get the run temp if exists to calculate the VCF
	ln_VCF_temp := NVL(ln_run_temp,ln_obs_temp);
	ln_temp := ln_obs_temp;
    --temperature unit in db
	lv_temp_unit := ecdp_unit.GetUnitFromLogical('TEMP');
    --density unit in db
	lv_density_unit := ecdp_unit.GetUnitFromLogical('OIL_DENS');
    --to convert the temperature to C if in F
	IF lv_temp_unit = 'C' AND lv_density_unit = 'KGPERM3' THEN
      ln_corr_Dens := Ecbp_Vcf.calcDensityCorr_SI(ln_obs_density, ln_temp);
	    ln_VCF := Ecbp_Vcf.calcVCFstdDensity_SI(ln_corr_Dens, ln_VCF_temp);
	ELSIF lv_temp_unit ='F' THEN
      ln_corr_API := Ecbp_Vcf.calcAPIGravityCorr(ln_API_obs, ln_temp);
      ln_corr_Dens := Ecbp_Vcf.getDensityFromAPI(ln_corr_API);
      ln_VCF := Ecbp_Vcf.calcVCFobsAPI(ln_corr_API, ln_VCF_temp);
  END IF;

  RETURN ln_corr_Dens;

END getStdDensityForTruckTicket;

---------------------------------------------------------------------------------------------------
-- Procedure      : calcNetVol
-- Description    : Calculates net vol for the selected record.
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
PROCEDURE calcNetVol(
   p_object_id  VARCHAR2,
   p_daytime    DATE,
   p_event_no   VARCHAR2,
   p_class_name  VARCHAR2,
   p_user VARCHAR2)

IS
   ln_grs_vol                  NUMBER;
   ln_grs_mass                 NUMBER;
   ln_net_vol                  NUMBER;
   ln_vcf                      NUMBER;
   ln_density                  NUMBER;
   ln_bs_w                     NUMBER;
   ln_bs_w_wt                  NUMBER;
   lr_strm_trans_event         strm_transport_event%ROWTYPE;

BEGIN
	lr_strm_trans_event := ec_strm_transport_event.row_by_pk(p_event_no);

  IF p_class_name = 'STRM_TRUCK_UNLOAD_VOL' THEN
    ln_grs_vol := lr_strm_trans_event.grs_vol;
	  ln_bs_w := lr_strm_trans_event.bs_w;
    ln_vcf := EcBp_CalculateAPI.getVCFForTruckTicket(p_object_id,p_daytime,p_event_no);
    ln_net_vol :=  ln_grs_vol * (1-ln_bs_w) * ln_vcf;
  ELSIF p_class_name = 'STRM_TRUCK_UNLOAD_MASS' THEN
    ln_grs_mass := lr_strm_trans_event.grs_mass;
    ln_bs_w_wt := lr_strm_trans_event.bs_w_wt;
    ln_density := EcBp_CalculateAPI.getStdDensityForTruckTicket(p_object_id, p_daytime, p_event_no);
    IF ln_density != 0 THEN
      ln_net_vol :=  ln_grs_mass * (1-ln_bs_w_wt) /ln_density;
    END IF;
  END IF;

 UPDATE strm_transport_event
  SET net_vol          = ln_net_vol,
  last_updated_by      = p_user
  WHERE event_no       = p_event_no
  AND daytime          = p_daytime
  AND object_id        = p_object_id ;

END  calcNetVol;

---------------------------------------------------------------------------------------------------
-- Procedure      : calcNetVolNotApproved
-- Description    : Calculates net vol for the all non-approved records.
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
PROCEDURE calcNetVolNotApproved(
   p_start_date  DATE,
   p_end_date    DATE,
   p_data_class_name  VARCHAR2,
   p_user VARCHAR2)

IS
   ln_grs_vol                  NUMBER;
   ln_grs_mass                 NUMBER;
   ln_net_vol                  NUMBER;
   ln_vcf                      NUMBER;
   ln_density                  NUMBER;
   ln_bs_w                     NUMBER;
   ln_bs_w_wt                  NUMBER;

  CURSOR c_calc_not_appr is
  SELECT a.object_id, a.daytime, a.event_no, a.data_class_name,
  grs_vol, grs_mass, bs_w, bs_w_wt
  FROM strm_transport_event a
  WHERE a.daytime between p_start_date and p_end_date
  AND a.data_class_name = p_data_class_name
  AND a.record_status != 'A';

BEGIN

  FOR cur_rec IN c_calc_not_appr LOOP
    IF cur_rec.data_class_name = 'STRM_TRUCK_UNLOAD_VOL' THEN
      ln_grs_vol := cur_rec.grs_vol;
	    ln_bs_w    := cur_rec.bs_w;
      ln_vcf     := EcBp_CalculateAPI.getVCFForTruckTicket(cur_rec.object_id,cur_rec.daytime,cur_rec.event_no);
      ln_net_vol :=  ln_grs_vol * (1-ln_bs_w) * ln_vcf;
    ELSIF cur_rec.data_class_name = 'STRM_TRUCK_UNLOAD_MASS' THEN
      ln_grs_mass := cur_rec.grs_mass;
      ln_bs_w_wt  := cur_rec.bs_w_wt;
      ln_density  := EcBp_CalculateAPI.getStdDensityForTruckTicket(cur_rec.object_id,cur_rec.daytime,cur_rec.event_no);
      IF ln_density != 0 THEN
        ln_net_vol :=  ln_grs_mass * (1-ln_bs_w_wt) /ln_density;
      END IF;
    END IF;

    UPDATE strm_transport_event
    SET net_vol          = ln_net_vol,
    last_updated_by      = p_user
    WHERE event_no       = cur_rec.event_no
    AND daytime          = cur_rec.daytime
    AND object_id        =  cur_rec.object_id;

  END LOOP;

END calcNetVolNotApproved;

END EcBp_CalculateAPI;