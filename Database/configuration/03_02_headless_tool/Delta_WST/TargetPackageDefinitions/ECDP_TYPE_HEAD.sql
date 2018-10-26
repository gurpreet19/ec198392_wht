CREATE OR REPLACE PACKAGE EcDp_Type IS

/****************************************************************
** Package        :  EcDp_Type, header part
**
** $Revision: 1.2 $
**
** Purpose        :  This package is for defining EC package types
**
** Documentation  :  www.energy-components.com
**
** Created  : 12.01.2000  Carl-Fredrik Sørensen
**
** Modification history:
**
** Version  Date     	Whom  Change description:
** -------  ------   	----- -----------------------------------
** 3.1      09.05.2000  CFS   Added constants IS_TRUE, IS_FALSE
*****************************************************************/

pb_comp_number NUMBER; -- Define a number type to accomplish PB internal number format

--

--

FUNCTION IS_TRUE
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(IS_TRUE, WNDS, WNPS, RNPS);

--

FUNCTION IS_FALSE
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(IS_FALSE, WNDS, WNPS, RNPS);


END;