CREATE OR REPLACE PACKAGE BODY UE_VCF_CALCULATION IS
/******************************************************************************
** Package        :  UE_VCF_CALCULATION, body part
**
** $Revision: 1.3 $
**
** Purpose        :  Includes user-exit functionality for Shrinkage calculation on Batch Oil Tank Export - Tank Dip (PO.0023)
**
** Documentation  :  www.energy-components.com
**
** Created  : 12.09.2007 Nazlihasri Rahman
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- -----------------------------------------------------------------------------------------------
** 1.0   12.09.2007  Rahmanaz	Initial version
**       01.07.2011  sharawan ECPD-17865: Modified GetVcf and GetApi to add new parameter p_daytime.
*/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetVcf
-- Description    : If function returns NULL, then call the VCF calculations else skip the VCF call.

---------------------------------------------------------------------------------------------------
FUNCTION GetVcf(p_object_id VARCHAR2, p_avg_Temp NUMBER, p_corr_Api NUMBER, p_run_Temp NUMBER, p_line_Temp NUMBER, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
       RETURN NULL;
END GetVcf;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetApi
-- Description    : If function returns NULL, then call the API calculations else skip the API call.

---------------------------------------------------------------------------------------------------
FUNCTION GetApi(p_object_id VARCHAR2, p_Api NUMBER, p_avg_Temp NUMBER, p_daytime DATE)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN
       RETURN NULL;
END GetApi;

END UE_VCF_CALCULATION;