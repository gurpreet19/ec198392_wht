CREATE OR REPLACE PACKAGE UE_VCF_CALCULATION IS

/******************************************************************************
** Package        :  UE_VCF_CALCULATION, header part
**
** $Revision: 1.3 $
**
** Purpose        :  Includes user-exit functionality
**
** Documentation  :  www.energy-components.com
**
** Created  : 12.09.2007 Nazlihasri Rahman
**
** Modification history:
**
** Date        Whom     Change description:
** -------     ------   -----------------------------------------------
** 1.0   12.09.2007  Rahmanaz	Initial version
**       01.07.2011  sharawan ECPD-17865: Modified GetVcf and GetApi to add new parameter p_daytime.
*/


  -- Public function declarations
FUNCTION GetVcf(p_object_id VARCHAR2, p_avg_Temp NUMBER, p_corr_Api NUMBER, p_run_Temp NUMBER, p_line_Temp NUMBER, p_daytime DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (GetVcf, WNDS, WNPS, RNPS);

FUNCTION GetApi(p_object_id VARCHAR2, p_Api NUMBER, p_avg_Temp NUMBER, p_daytime DATE) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (GetApi, WNDS, WNPS, RNPS);

END UE_VCF_CALCULATION;