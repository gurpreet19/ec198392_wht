CREATE OR REPLACE PACKAGE ue_ringfencing IS

/****************************************************************
** Package        :  ue_ringfencing, header part
**
** $Revision: $
**
** Purpose        :  Used by EcDp_Context package to determine if access to global context ringfencing information should be allowed.
**
** Documentation  :  www.energy-components.com
**
** Created  : 2016-Oct-20
**
** Modification history:
**
** Date     Whom   description:
** -------  ------ --------------------------------------
** 18.10.16 HUS    ECPD-xxxxx Ringfencing user exit package
*****************************************************************/

-- Indicate whether access to ringfencing information held in global context is allowed
--
FUNCTION allowAccessToGlobalContext RETURN BOOLEAN;

END ue_ringfencing;