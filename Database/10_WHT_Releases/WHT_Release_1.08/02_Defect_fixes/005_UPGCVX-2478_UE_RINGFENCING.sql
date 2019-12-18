create or replace PACKAGE BODY ue_ringfencing IS

/* ***************************************************************
** Package        :  ue_ringfencing, body part
**
** $Revision:  $
**
** Purpose        :  Used by EcDp_Context package to determine if access to global context ringfencing information should be allowed.
**
** Documentation  :  www.energy-components.com
**
** Created  : 2016-Oct-20
**
** Modification history:
**
**  Date     Whom  Change description:
**  ------   ----- --------------------------------------
** 18.10.16 HUS    ECPD-xxxxx Ringfencing user exit package
** 18.12.19 dhavaalo Chevron Bulk Upgrade	WST wanted the function allowAccessToGlobalContext to return TRUE as default.
**									They are restricting their external DB user access through DB Grants and DB Privileges 
*************************************************************** */

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : allowAccessToGlobalContext
--
-- Description    : If this function returns FALSE, access to ringfencing information held in the
--                  global context will be blocked for DB users other than "ECKERNEL" and "ENERGYX".
--                  The reason for blocking such access is that any DB user can call
--                  dbms_session.set_identifier(...), and thereby impersonate any app user.
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
FUNCTION allowAccessToGlobalContext
RETURN BOOLEAN
IS
--</EC-DOC>
BEGIN
   RETURN TRUE;
END allowAccessToGlobalContext;

END ue_ringfencing;
/