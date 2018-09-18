CREATE OR REPLACE PACKAGE BODY EcBp_Facility_Analysis IS
/****************************************************************
** Package        :  EcBp_Facility_Analysis, body part
**
** $Revision: 1.1 $
**
** Purpose        :  This package is responsible for supporting the new business function related to facility analysis
**
** Documentation  :  www.energy-components.com
**
** Created  : 08/02/2013  Lim Chun Guan
**
** Modification history:
**
** Date          Whom         Change description:
** ----------    --------     --------------------------------------
** 08.02.2013    limmmchu     ECPD-23143: Initial version
** 18.07.2017 kashisag ECPD-45817: Replaced sysdate with Ecdp_Timestamp.getCurrentSysdate
*****************************************************************/


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : checkIfPeriodOverlaps
-- Description    :  This procedure checks validity period.
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   : FCTY_ANALYSIS_ITEM
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
--
---------------------------------------------------------------------------------------------------
--</EC-DOC>
PROCEDURE checkIfPeriodOverlaps(p_asset_id VARCHAR2,p_start_date DATE, p_end_date DATE, p_fcty_object_id VARCHAR2, p_analysis_item VARCHAR2)

IS
  CURSOR c_validate3 IS
    SELECT asset_id, start_date, end_date, fcty_object_id, analysis_item
      FROM FCTY_ANALYSIS_ITEM
     WHERE asset_id = p_asset_id
	   AND fcty_object_id = p_fcty_object_id
	   AND analysis_item = p_analysis_item
       AND (p_start_date BETWEEN start_date AND Nvl(end_date, Ecdp_Timestamp.getCurrentSysdate)
       OR  p_start_date < (select max(g1.start_date)
                                    FROM FCTY_ANALYSIS_ITEM g1
                                   WHERE g1.asset_id = p_asset_id))
       AND start_date <> p_start_date;

BEGIN

  IF p_asset_id IS NOT NULL THEN
    FOR cur_Validate3 IN c_validate3 LOOP
      Raise_Application_Error(-20121,'Start Date overlaps with another object group period.');
      Exit;
    END LOOP;

  END IF;

END checkIfPeriodOverlaps;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getAnalysisFreq
-- Description    :  This function is use to get the analysis freq from table FCTY_ANALYSIS_ITEM
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   : FCTY_ANALYSIS_ITEM
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
--
---------------------------------------------------------------------------------------------------
--</EC-DOC>
FUNCTION getAnalysisFreq(
         p_fcty_object_id VARCHAR2,
         p_start_date DATE,
         p_asset_id VARCHAR2,
         p_analysis_item VARCHAR2)
RETURN VARCHAR2

IS

lv2_analysis_freq  VARCHAR2(32);

  CURSOR c_col_val IS
   SELECT analysis_freq col
   FROM FCTY_ANALYSIS_ITEM
   WHERE fcty_object_id = p_fcty_object_id
   AND start_date <= p_start_date
   AND Nvl(end_date,p_start_date) >= p_start_date
   AND asset_id = p_asset_id
   AND analysis_item = p_analysis_item;

BEGIN
   FOR cur_row IN c_col_val LOOP
      lv2_analysis_freq := cur_row.col;
   END LOOP;

   RETURN lv2_analysis_freq;

END getAnalysisFreq;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getAnalysisTarget
-- Description    :  This function is use to get the analysis target from table FCTY_ANALYSIS_ITEM
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   : FCTY_ANALYSIS_ITEM
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
--
---------------------------------------------------------------------------------------------------
--</EC-DOC>
FUNCTION getAnalysisTarget(
         p_fcty_object_id VARCHAR2,
         p_start_date DATE,
         p_asset_id VARCHAR2,
         p_analysis_item VARCHAR2)
RETURN VARCHAR2

IS

lv2_analysis_target  VARCHAR2(32);

  CURSOR c_col_val IS
   SELECT analysis_target col
   FROM FCTY_ANALYSIS_ITEM
   WHERE fcty_object_id = p_fcty_object_id
   AND start_date <= p_start_date
   AND Nvl(end_date,p_start_date) >= p_start_date
   AND asset_id = p_asset_id
   AND analysis_item = p_analysis_item;

BEGIN
   FOR cur_row IN c_col_val LOOP
      lv2_analysis_target := cur_row.col;
   END LOOP;

   RETURN lv2_analysis_target;

END getAnalysisTarget;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : checkManualDaytime
-- Description    :  This function is use to get the analysis target from table FCTY_ANALYSIS_ITEM
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   : FCTY_ANALYSIS_ITEM
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
--
---------------------------------------------------------------------------------------------------
--</EC-DOC>
PROCEDURE checkManualDaytime(p_daytime DATE)

IS

		lv_daytimeCompare   VARCHAR2(6);

BEGIN

	lv_daytimeCompare := to_char(p_daytime, 'HH24MI');

	IF lv_daytimeCompare = '0000' THEN
		Raise_Application_Error(-20647,'Sample daytime which is manual insert cannot set to 00:00');
	END IF;

END checkManualDaytime;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getAvgValue
-- Description    : to get average VALUE from DAYS inserted from table DV_FCTY_ASSET_ANALYSIS
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   : DV_FCTY_ASSET_ANALYSIS
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
--
---------------------------------------------------------------------------------------------------
--</EC-DOC>
FUNCTION getAvgValue(
         p_fcty_object_id VARCHAR2,
         p_daytime DATE,
         p_asset_id VARCHAR2,
         p_analysis_item VARCHAR2,
         P_days NUMBER)
RETURN NUMBER

IS

    lv_number   number;
    lv_analysis_freq varchar2(32);

BEGIN

  lv_analysis_freq := getAnalysisFreq(p_fcty_object_id,p_daytime,p_asset_id,p_analysis_item);

  SELECT nvl(sum(value)/P_days, 0) INTO lv_number
  FROM DV_FCTY_ASSET_ANALYSIS
  WHERE FCTY_OBJECT_ID = p_fcty_object_id
  AND ASSET_ID = p_asset_id
  AND ANALYSIS_ITEM = p_analysis_item
  AND ANALYSIS_FREQ = lv_analysis_freq
  AND trunc(daytime) > p_daytime - P_days
  AND trunc(daytime) <= p_daytime;

  RETURN lv_number;

END getAvgValue;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : checkDelete
-- Description    :  This function is use to check the record which cannot delete for instantiated record
--
-- Preconditions  :
--
-- Postconditions :
-- Using tables   : FCTY_ANALYSIS_ITEM
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
--
---------------------------------------------------------------------------------------------------
--</EC-DOC>
PROCEDURE checkDelete(p_fcty_object_id VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_analysis_item VARCHAR2)

IS

    lv_daytimeCheck   VARCHAR2(6);
    lv_count   VARCHAR2(6);

BEGIN

	SELECT count(1) INTO lv_count
        FROM FCTY_ASSET_ANALYSIS
        WHERE FCTY_OBJECT_ID = p_fcty_object_id
        AND DAYTIME = p_daytime
        AND ASSET_ID = p_asset_id
        AND ANALYSIS_ITEM = p_analysis_item;

  IF lv_count > 0 THEN

      lv_daytimeCheck := to_char(p_daytime, 'HH24MI');

	   IF lv_daytimeCheck = '0000' THEN
		    Raise_Application_Error(-20648,'Instantiated record cannot be delete');
	   END IF;
  END IF;

END checkDelete;

END EcBp_Facility_Analysis;