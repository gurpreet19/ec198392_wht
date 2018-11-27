CREATE OR REPLACE PACKAGE ue_cargo_analysis IS
/******************************************************************************
** Package        :  ue_cargo_analysis, header part
**
** $Revision: 1.2 $
**
** Purpose        :  License specific package to provide cargo analysis as the customer expects in reporting
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
	p_analysis_no NUMBER,
	p_analysis_item_code VARCHAR2)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcExpUnload, WNDS, WNPS, RNPS);

END ue_cargo_analysis;