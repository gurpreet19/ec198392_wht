CREATE OR REPLACE PACKAGE BODY EcDp_Calc_Meta IS
/****************************************************************
** Package        :  EcDp_Calc_Meta, body part
**
** $Revision: 1.33 $
**
** Purpose        :  Supports extraction of allocation specific metadata from classes.
**
** Documentation  :  www.energy-components.com
**
** Created  : 04.03.2005  Hanne Austad
**
** Modification history:
**
** Date        Who  Change description:
** ----------  ---- --------------------------------------
** 2005-03-04  HUS  Initial version
** 2005-03-04  JBE  Added function for retrieving data sets
** 2006-03-17  HLH  Added function getDimIsSetByTrigger
** 2006-04-03  HLH  Added function getAlwaysInsert
** 2006-03-17  HLH  Added function getDimIsSetByTrigger
** 2006-04-03  HLH  Added function getAlwaysInsert
** 2006-04-28  HLH  Added support for Production Day
** 2006-0-02   HUS  Added data set qualifier functions
** 2006-10-17  LAU  TI# 4631: Modified function getDateHandlingProperties.
** 2006-10-24  HUS  Added isCalcType and isSeqNo
** 2006-11-17  HUS  Replaced isCalcType and isSeqNo with isCalcRuleCode and isCalcSeqNo
** 2007-05-10  HUS  Added getEngineParamName
*****************************************************************/



--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Procedure      : getDateHandlingProperties                                                      --
-- Description    : Finds the date handling relevant properties for the given class.               --
--                                                                                                 --
-- Preconditions  :                                                                                --
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : class_attribute,class_attr_db_mapping                                          --
-- Using functions:                                                                                --
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      : Returns a comma-separated list of all properties from the following list       --
--                  that the given class exposes: DAYTIME, FROM_DATE, START_DATE, END_DATE         --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
FUNCTION getDateHandlingProperties(
  p_class_name   VARCHAR2
)
RETURN VARCHAR2
--<EC-DOC>
IS
   lv_return_val  VARCHAR2(200);
   CURSOR c_cols IS
      SELECT a.ATTRIBUTE_NAME
      FROM class_attribute a, class_attr_db_mapping ad
      WHERE a.class_name = ad.class_name AND a.attribute_name = ad.attribute_name
      AND a.CLASS_NAME=p_class_name
      AND a.ATTRIBUTE_NAME IN ('DAYTIME','START_DATE','FROM_DATE','END_DATE', 'PRODUCTION_DAY')
      ORDER BY ad.sort_order;
BEGIN
   lv_return_val:='';
   FOR cur_row IN c_cols LOOP
      lv_return_val := lv_return_val||','||cur_row.attribute_name;
   END LOOP;
   RETURN lv_return_val;
END getDateHandlingProperties;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Procedure      : getCalcDataType                                                                --
-- Description    : Converts the input EC data type to the basic types NUMBER, DATE and STRING,    --
--                  that are understood by the calculation engine.                                 --
-- Preconditions  :                                                                                --
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :                                                                                --
-- Using functions: getCalcDataType                                                                     --
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
FUNCTION getCalcDataType(
  p_data_type   VARCHAR2
)
RETURN VARCHAR2
--<EC-DOC>
IS
  lv_return_val  VARCHAR2(10);
BEGIN
   lv_return_val:=NVL(p_data_type, '');
   IF p_data_type='INTEGER' THEN
      lv_return_val:='NUMBER';
   ELSIF p_data_type='DOUBLE' THEN
      lv_return_val:='NUMBER';
   ELSIF p_data_type='FLOAT' THEN
      lv_return_val:='NUMBER';
   ELSIF p_data_type='DATE' THEN
      lv_return_val:='DATE';
   ELSIF p_data_type='NUMBER' THEN
      lv_return_val:='NUMBER';
   ELSE
      lv_return_val:='STRING';
   END IF;
   RETURN lv_return_val;
END getCalcDataType;

END EcDp_Calc_Meta;