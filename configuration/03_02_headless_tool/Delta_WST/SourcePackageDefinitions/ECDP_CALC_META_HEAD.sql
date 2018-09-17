CREATE OR REPLACE PACKAGE EcDp_Calc_Meta IS
/****************************************************************
** Package        :  EcDp_Calc_Meta, header part
**
** $Revision: 1.22 $
**
** Purpose        :  Supports extraction of calculation specific metadata from classes.
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
** 2006-10-24  HUS  Added isCalcType and isSeqNo
** 2006-11-17  HUS  Replaced isCalcType and isSeqNo with isCalcRuleCode and isCalcSeqNo
** 2007-05-10  HUS  Added getEngineParamName
*****************************************************************/


FUNCTION getDateHandlingProperties(
  p_class_name   VARCHAR2
)
RETURN VARCHAR2;

--

FUNCTION getCalcDataType(
  p_data_type	VARCHAR2
)
RETURN VARCHAR2;



END EcDp_Calc_Meta;