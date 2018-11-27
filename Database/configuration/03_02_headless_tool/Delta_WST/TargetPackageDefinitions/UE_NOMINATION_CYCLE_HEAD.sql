CREATE OR REPLACE PACKAGE ue_Nomination_Cycle IS
/******************************************************************************
** Package        :  ue_Nomination_Cycle, head part
**
** $Revision: 1.1 $
**
** Purpose        :  Business logic for nomination cycle handlings
**
** Documentation  :  www.energy-components.com
**
** Created        :  18.02.2008 Kari Sandvik
**
** Modification history:
**
** Date        Whom           Change description:
** --------    --------       -----------------------------------------------------------------------------------------------
**
********************************************************************/
FUNCTION getCurrentNomCycle(p_daytime DATE DEFAULT NULL) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(getCurrentNomCycle, WNDS, WNPS, RNPS);


END ue_Nomination_Cycle;