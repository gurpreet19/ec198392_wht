CREATE OR REPLACE PACKAGE BODY ue_cargo_analysis IS
/******************************************************************************
** Package        :  ue_cargo_analysis, body part
**
** $Revision: 1.2 $
**
** Purpose        :  License spesific package to provide cargo numbering as the customer expects in reporting
**
** Documentation  :  www.energy-components.com
**
** Created  : 06.10.2004 Kari Sandvik
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- -------------------------------------------
** #.#   DD.MM.YYYY  <initials>
********************************************************************/

FUNCTION calcExpUnload(
	p_analysis_no		NUMBER,
	p_analysis_item_code	VARCHAR2)

RETURN NUMBER

IS

  -- insert cursor here

  -- declare variables here

BEGIN
    -- insert code here
   RETURN null;

END;

END ue_cargo_analysis;