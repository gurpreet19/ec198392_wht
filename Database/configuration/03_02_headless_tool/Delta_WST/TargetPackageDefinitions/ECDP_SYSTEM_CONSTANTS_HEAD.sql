CREATE OR REPLACE PACKAGE EcDp_System_Constants IS

/**************************************************************

** Package	:  EcDp_System_Constants

**

** $Revision: 1.1.1.1 $

**

** Purpose	:  Energy Components HARE project

**   This package groups together constant functions for the system

**

** General Logic:

**

**

** Assumptions

**

**

**

** Created:   	01.05.03  Arild Vervik, TE

**

**

** Modification history:

**

**

** Date:     Whom:  Change description:

** --------  ----- --------------------------------------------

**

**************************************************************/

--

--



-- Constant functions used by basis Insert/Update packages like Objects, Node etc.

pb_comp_number NUMBER(18,6); -- Define a number type to accomplish PB internal number format





FUNCTION EARLIEST_DATE RETURN DATE;



PRAGMA RESTRICT_REFERENCES (EARLIEST_DATE, RNPS ,WNPS, WNDS);





FUNCTION FUTURE_DATE   RETURN DATE;



PRAGMA RESTRICT_REFERENCES (FUTURE_DATE, RNPS ,WNPS, WNDS);







END;
