CREATE OR REPLACE PACKAGE ue_RevenueCodes IS
/****************************************************************
** Package        :  ue_RevenueCodes, header part
**
** $Revision: 1.3 $
**
** Purpose        :  Provide functions to get codes for revenue
**
** Documentation  :  www.energy-components.com
**
** Created  : 09.11.2006 Sigve Ravndal
**
** Modification history:
**
** Version  Date         Whom   Change description:
** -------  ------       -----  --------------------------------------
**  1.1     01.11.2006   SRA         Initial version
******************************************************************/

FUNCTION GetCodeForClass(
   p_object_id VARCHAR2, -- The id to create the code for
   p_daytime   DATE, -- The date to create the code for
   p_class     VARCHAR2 -- The class to generate the code for
)
RETURN VARCHAR2; -- new code

PROCEDURE UpdateCodeForClass(
   p_object_id VARCHAR2, -- The id to create the code for
   p_daytime   DATE, -- The date to create the code for
   p_class     VARCHAR2 -- The class to generate the code for
);

END ue_RevenueCodes;