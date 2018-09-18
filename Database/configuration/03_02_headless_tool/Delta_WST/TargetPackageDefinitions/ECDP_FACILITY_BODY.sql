CREATE OR REPLACE PACKAGE BODY EcDp_Facility IS
/****************************************************************
** Package        :  EcDp_Facility, header part
**
** $Revision: 1.26 $
**
** Purpose        :  Finds facility properties.
**
** Documentation  :  www.energy-components.com
**
** Created  : 17.01.2000  Carl-Fredrik Sørensen
**
** Modification history:
**
** Version  Date       Whom  Change description:
** -------  ---------  ----- --------------------------------------
** 3.0      20.05.2000  CFS  Added functions getTotalInjectedVol and
**			                    getTotalWatSourceVol
** 3.2      14.09.2000  FBa  Added function getExportStream
** 3.3      29.11.2000  TeJ  Added procedures setAttributeText and setAttributeValue
** 3.4      29.03.2001  KEJ  Documented functions and procedures.
** 3.5      01.11.2001  FBa  Added procedure getFacility
** 3.6      14.12.2001  FBa  Added alternative implementation of getFacility. Use object_id
** 3.7      2002-02-13	FBa  Added function getInterest
** 3.8      2002-02-27	FBa  Added function getInterestVol
** 3.9      2002-03-19  DN   getExportStream: Added support for derived stream. Added getOilToStockStream.
** 3.10     2002-04-10  FBa  Moved logic to local function getInterestFromWellProd, added support for other ways of calculating interest.
** 3.11     2002-05-16	FBa  Changed logic to find ownership fraction in function getInterestFromWellProd
** 3.12     2002-05-16  HNE  Added getAttributeTextById
** 3.13     2002-07-09  FBa  Added time_span as optional argument to function getInterestFromWellProd
** 3.14     2002-07-11  DN   Removed parameter p_sysnam from getFacility function where p_object_id is input.
**          2002-07-24  MTa  Changed object_id references to objects.object_id%TYPE
**          2004-05-28  FBa  Added functions getProductionDayStart and getProductionDay
**          2004-06-02  DN   Renamed production day attributes.
**          2004-06-02  DN   Added getProductionDayOffset.
**          2004-08-10  Toha Removed references to sysnam. Signatures now make use of object_id instead of old pk sysnam + facility.
**                           Make changes as necessary to reflect changes on database.
**                           *WARNING* There are two functions with same name but different signatures, getFacility. Call to these
**                           must be correct. Changes are necessary.
**          2004-08-10  Toha Replaced facility.
**          2004-10-07  DN   Bug fix in getExportStream: stream.Object_ID must be returned.
**          2004-11-26  ROV  Tracker #1821: Modified method getProductionDayOffset to support production day start
**                           prior to calender day start
**          2005-02-23  kaurrnar     Removed setAttributeText, setAttributeValue, getAttributeText, getAttributeTextById and getAttributeValue function.
**                                   Changed fcty_attribute to fcty_version
**          2005-02-28  Darren Change from_date to start_date in getExportStream
**	    2005-03-04 kaurrnar	Removed getOilToStockStream function
**          2005-06-28 SHN     Tracker 2385. Updated getExportStream because stream_category is moved from table STREAM to STRM_VERSION.
**          2005-08-16 Toha    Fixed getProductionDayStart to return correct facility day
**          2005-09.21 DN    TI#2673: Removed redundant code from EcDp_Facility.getProductionDayOffset.
**          2005-11-01 DN    objects.object_id replaced with  production_facility.object_id.
**          2005-11-23 DN     Moved getParentFacility to EC_PROD EcDp_Facility.
**          2006-08-28 seongkok Added functions calcSumPersonnel and calcBedsAvailable.
**          2010-05-14 rajarsar ECPD-14498:Updated getParentFacility to support all equipment sub classes
**          2010-05-31 rajarsar ECPD-14498:Updated getParentFacility to support well Hookup correctly
**	    2010-08-11 madondin	ECPD-15493:Modified getParentFacility to improve performance
*****************************************************************/

CURSOR c_facility_by_id (p_object_id IN production_facility.object_id%TYPE) IS
SELECT *
FROM production_facility
WHERE object_id = p_object_id;

--<EC-DOC>
-----------------------------------------------------------------
-- Function     : getFacility
-- Description  : Returns the facility (entire row) for a given object_id or facility
--
-- Preconditions:
-- Postcondition:
-- Using Tables:  production_facility
--
-- Using functions:
--
-- Configuration
-- required:
--
-- Behaviour
--
-----------------------------------------------------------------
FUNCTION getFacility (
   p_object_id   production_facility.object_id%TYPE,
   p_daytime     DATE)
RETURN PRODUCTION_FACILITY%ROWTYPE
--<EC-DOC>
IS

lr_facility production_facility%ROWTYPE;

BEGIN

	OPEN c_facility_by_id(p_object_id);
	FETCH c_facility_by_id INTO lr_facility;
	CLOSE c_facility_by_id;

	RETURN lr_facility;

END getFacility;

--


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getExportStream                                                                --
-- Description    : Returns the stream_code for oil/gas export stream                              --
--                                                                                                 --
-- Preconditions  :                                                                                --
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : stream                                                                         --
--                                                                                                 --
-- Using functions: EcDp_Phase.GAS,                                                                --
--                  EcDp_Stream_Type.GAS_EXPORT,                                                   --
--                  EcDp_Phase.OIL,                                                                --
--                  EcDp_Stream_Type.OIL_EXPORT                                                    --
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
FUNCTION getExportStream(
          p_object_id      production_facility.object_id%TYPE,
          p_daytime        DATE,
	       p_phase          VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS

CURSOR c_stream (cp_stream_category VARCHAR2) IS
SELECT s.object_id
FROM strm_version v, stream s
WHERE v.object_id = s.object_id
AND s.prod_fcty_id = p_object_id
AND v.stream_category = cp_stream_category
AND Nvl(v.daytime,p_daytime) <= p_daytime
AND Nvl(v.end_date,p_daytime) >= p_daytime
AND v.stream_type <> EcDp_Stream_Type.DERIVED;

CURSOR c_der_stream (cp_stream_category VARCHAR2) IS
SELECT s.object_id
FROM strm_version v, stream s
WHERE v.object_id = s.object_id
AND s.prod_fcty_id = p_object_id
AND v.stream_category = cp_stream_category
AND Nvl(v.daytime,p_daytime) <= p_daytime
AND Nvl(v.end_date,p_daytime) >= p_daytime
AND v.stream_type = EcDp_Stream_Type.DERIVED;

lv2_retval stream.object_id%TYPE;
lv2_stream_categ VARCHAR2(32);

BEGIN

	IF p_phase = EcDp_Phase.GAS THEN
		lv2_stream_categ := EcDp_Stream_Type.GAS_EXPORT;
	ELSIF p_phase = EcDp_Phase.OIL THEN
		lv2_stream_categ := EcDp_Stream_Type.OIL_EXPORT;
	END IF;

	OPEN c_stream(lv2_stream_categ);

	IF c_stream%ROWCOUNT <> 1 THEN

		OPEN c_der_stream(lv2_stream_categ);
		IF c_der_stream%ROWCOUNT = 1 THEN

		   FETCH c_stream INTO lv2_retval;

		ELSE

		   lv2_retval := NULL;

		END IF;

      CLOSE c_der_stream;

	ELSE
		FETCH c_stream INTO lv2_retval;
	END IF;

	CLOSE c_stream;

   RETURN lv2_retval;

END getExportStream;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getParentFacility
-- Description    : Finds the current parent facilty for a given object at a given date.
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
FUNCTION getParentFacility(p_object_id VARCHAR2, p_daytime DATE, p_class_name VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
--</EC-DOC>
IS

lv2_class_name  VARCHAR2(32);
lv_facility_id VARCHAR2(32) NULL;

CURSOR c_class_dependency  IS
  SELECT a.child_class
  FROM class_dependency a
  WHERE a.parent_class = 'EQUIPMENT';

BEGIN

   IF(p_class_name IS NULL) THEN
      lv2_class_name := ecdp_objects.GetObjClassName(p_object_id);
   ELSE
      lv2_class_name := p_class_name;
   END IF;

   CASE lv2_class_name
     WHEN 'WELL'
        THEN lv_facility_id := Nvl(ec_well_version.op_fcty_class_1_id(p_object_id, p_daytime, '<='),ec_well_version.op_fcty_class_2_id(p_object_id, p_daytime, '<='));

     WHEN 'FLOWLINE'
        THEN lv_facility_id := Nvl(ec_flwl_version.op_fcty_class_1_id(p_object_id, p_daytime, '<='),ec_flwl_version.op_fcty_class_2_id(p_object_id, p_daytime, '<='));

     WHEN 'STREAM'
        THEN lv_facility_id := Nvl(ec_strm_version.op_fcty_class_1_id(p_object_id, p_daytime, '<='),ec_strm_version.op_fcty_class_2_id(p_object_id, p_daytime, '<='));

     WHEN 'COMPRESSOR'
        THEN lv_facility_id := Nvl(ec_eqpm_version.op_fcty_class_1_id(p_object_id, p_daytime, '<='),ec_eqpm_version.op_fcty_class_2_id(p_object_id, p_daytime, '<='));

     WHEN 'CTRL_SAFETY_SYSTEM'
        THEN lv_facility_id := Nvl(ec_eqpm_version.op_fcty_class_1_id(p_object_id, p_daytime, '<='),ec_eqpm_version.op_fcty_class_2_id(p_object_id, p_daytime, '<='));

     WHEN 'EQUIPMENT_OTHER'
        THEN lv_facility_id := Nvl(ec_eqpm_version.op_fcty_class_1_id(p_object_id, p_daytime, '<='),ec_eqpm_version.op_fcty_class_2_id(p_object_id, p_daytime, '<='));

     WHEN 'GAS_PROC_EQPM'
        THEN lv_facility_id := Nvl(ec_eqpm_version.op_fcty_class_1_id(p_object_id, p_daytime, '<='),ec_eqpm_version.op_fcty_class_2_id(p_object_id, p_daytime, '<='));

     WHEN 'GENERATOR'
        THEN lv_facility_id := Nvl(ec_eqpm_version.op_fcty_class_1_id(p_object_id, p_daytime, '<='),ec_eqpm_version.op_fcty_class_2_id(p_object_id, p_daytime, '<='));

     WHEN 'POWER_DISTRIBUTION_EQPM'
        THEN lv_facility_id := Nvl(ec_eqpm_version.op_fcty_class_1_id(p_object_id, p_daytime, '<='),ec_eqpm_version.op_fcty_class_2_id(p_object_id, p_daytime, '<='));

     WHEN 'PUMP'
        THEN lv_facility_id := Nvl(ec_eqpm_version.op_fcty_class_1_id(p_object_id, p_daytime, '<='),ec_eqpm_version.op_fcty_class_2_id(p_object_id, p_daytime, '<='));

     WHEN 'TEST_DEVICE'
        THEN lv_facility_id := Nvl(ec_eqpm_version.op_fcty_class_1_id(p_object_id, p_daytime, '<='),ec_eqpm_version.op_fcty_class_2_id(p_object_id, p_daytime, '<='));

     WHEN 'UTILITY_EQPM'
        THEN lv_facility_id := Nvl(ec_eqpm_version.op_fcty_class_1_id(p_object_id, p_daytime, '<='),ec_eqpm_version.op_fcty_class_2_id(p_object_id, p_daytime, '<='));

     WHEN 'STORAGE'
        THEN lv_facility_id := Nvl(ec_stor_version.op_fcty_class_1_id(p_object_id, p_daytime, '<='),ec_stor_version.op_fcty_class_2_id(p_object_id, p_daytime, '<='));

     WHEN 'TANK'
        THEN lv_facility_id := Nvl(ec_tank_version.op_fcty_class_1_id(p_object_id, p_daytime, '<='),ec_tank_version.op_fcty_class_2_id(p_object_id, p_daytime, '<='));

     WHEN 'WELL_HOOKUP'
        THEN lv_facility_id := Nvl(ec_well_hookup_version.op_fcty_class_1_id(p_object_id, p_daytime, '<='),ec_well_hookup_version.op_fcty_class_2_id(p_object_id, p_daytime, '<='));

     WHEN 'TESTSEPARATOR'
        THEN lv_facility_id := Nvl(ec_sepa_version.op_fcty_class_1_id(p_object_id, p_daytime, '<='),ec_sepa_version.op_fcty_class_2_id(p_object_id, p_daytime, '<='));

     WHEN 'PRODSEPARATOR'
        THEN lv_facility_id := Nvl(ec_sepa_version.op_fcty_class_1_id(p_object_id, p_daytime, '<='),ec_sepa_version.op_fcty_class_2_id(p_object_id, p_daytime, '<='));

     WHEN 'CHEM_TANK'
        THEN lv_facility_id := Nvl(ec_chem_tank_version.op_fcty_class_1_id(p_object_id, p_daytime, '<='),ec_chem_tank_version.op_fcty_class_2_id(p_object_id, p_daytime, '<='));

     ELSE
        FOR cur_class_dependency IN c_class_dependency LOOP

     	  IF lv2_class_name = cur_class_dependency.child_class THEN
       	     lv_facility_id := Nvl(ec_eqpm_version.op_fcty_class_1_id(p_object_id, p_daytime, '<='),ec_eqpm_version.op_fcty_class_2_id(p_object_id, p_daytime, '<='));
       	  END IF;

        END LOOP;

   END CASE;

   RETURN lv_facility_id;

END getParentFacility;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcSumPersonnel
-- Description    : Returns the total of head counts of different categories on the specified date
--
-- Preconditions  : There are instantiated rows for each categories
--
-- Postconditions :
--
-- Using tables   : FCTY_DAY_POB
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION calcSumPersonnel(
  p_object_id production_facility.object_id%TYPE,
  p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_head_count_sum(cp_object_id VARCHAR2, cp_day DATE) IS
SELECT SUM(head_count) sum_head_count
FROM fcty_day_pob
WHERE object_id = cp_object_id
AND daytime=cp_day
;

ln_return_val NUMBER;

BEGIN

   FOR cur_rec IN c_head_count_sum(p_object_id, p_daytime) LOOP

      ln_return_val := cur_rec.sum_head_count;

   END LOOP;

   RETURN ln_return_val;

END calcSumPersonnel;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcBedsAvailable
-- Description    : Returns the beds available on the platform
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION calcBedsAvailable(
  p_object_id production_facility.object_id%TYPE,
  p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS

ln_return_val NUMBER;

BEGIN

   ln_return_val := ec_fcty_version.total_beds(p_object_id, p_daytime, '<=') - calcSumPersonnel(p_object_id,p_daytime);

   RETURN ln_return_val;

END calcBedsAvailable;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : copyPrTrRecFactorRecord
-- Description    : Copies a record in dv_prtr_pc_cp_rec_fac
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
PROCEDURE copyPrTrRecFactorRecord (
			p_object_id 						VARCHAR2,
			p_daytime 							DATE,
			p_new_date 							DATE,
			p_end_date 							DATE,
			p_profit_centre_id 			VARCHAR2,
			p_hydrocarbon_component VARCHAR2
                         	)
--</EC-DOC>
IS

BEGIN

	update PRTR_PC_CP_EVENT set end_date = p_new_date where object_id = p_object_id and daytime = p_daytime and profit_centre_id = p_profit_centre_id and component_no = p_hydrocarbon_component;

	insert into PRTR_PC_CP_EVENT (object_id,daytime,end_date,profit_centre_id,component_no) values (p_object_id, p_new_date, p_end_date, p_profit_centre_id, p_hydrocarbon_component);

END copyPrTrRecFactorRecord;


END EcDp_Facility;