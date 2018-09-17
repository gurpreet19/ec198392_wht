CREATE OR REPLACE PACKAGE EcBp_perforation IS

/****************************************************************
** Package        :  EcBp_perforation, header part
**
** $Revision: 1.1 $
**
** Purpose        :  Data validation on perforation interval active status.
**
** Documentation  :  www.energy-components.com
**
** Created        :  13.05.2013  Leong Weng Onn
**
** Modification history:
**
** Version  Date        Whom      Change description:
** -------  ----------  ----      --------------------------------------
** 1.0      13.05.2013  leongwen  Initial version
** 2.0      16.08.2016  jainngou  Added Sum_kHproductWBI method for sum of kH-product for all perforations within a given well bore interval for the day specified.
*****************************************************************/

PROCEDURE IUAllowPerfClosedLT(p_object_id VARCHAR2, p_daytime DATE, p_summer_time VARCHAR2, p_status VARCHAR2);

PROCEDURE AllowPerfClosedLT(p_object_id VARCHAR2, p_daytime DATE, p_summer_time VARCHAR2, p_status VARCHAR2);

PROCEDURE DelAllowPerfClosedLT(p_object_id VARCHAR2, p_daytime DATE, p_summer_time VARCHAR2, p_status VARCHAR2);

FUNCTION Sum_kHproductWBI(p_object_id VARCHAR2, p_daytime DATE)
RETURN NUMBER;

END EcBp_perforation;