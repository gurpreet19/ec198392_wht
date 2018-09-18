CREATE OR REPLACE PACKAGE Ecbp_Webo_Press_Test IS
/**************************************************************
** Package:    Ecbp_Webo_Press_Test
**
** $Revision: 1.0 $
**
** Filename:   Ecbp_Webo_Press_Test.sql
**
** Part of :   EC Kernel
**
** Purpose:
**
** General Logic:
**
** Document References:
**
**
** Created:   	26.08.2016  Gourav Jain
**
**
** Modification history:
**
**
** Date:      Whom:      Change description:
** --------   -----      --------------------------------------------
** 26-08-2016 jainngou   ECPD-36895: Added getDatumDepth and getInitDatumPress to get datum depth and datum init press of RBF.
**************************************************************/

FUNCTION getDatumDepth(p_object_id webo_bore.object_id%TYPE,p_daytime DATE, p_measdepth NUMBER)
RETURN NUMBER;

FUNCTION getInitDatumPress(p_object_id webo_bore.object_id%TYPE,p_daytime DATE, p_measdepth NUMBER)
RETURN NUMBER;

END Ecbp_Webo_Press_Test;