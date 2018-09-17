CREATE OR REPLACE PACKAGE EcBp_Stream_Well_Conn IS

/****************************************************************
** Package        :  EcBp_Stream_Well_Conn, header part
**
** $Revision: 1.4 $
**
** Purpose        :  Provide basic functions on stream well connection
**
** Documentation  :  www.energy-components.com
**
** Created  : 06.06.2008  Siti Azura Alias
**
** Modification history:
**
**  Date     Whom  Change description:
**  ------   ----- --------------------------------------
**  11.08.2010 amirrasn ECPD-14747 add new function to find Well Facility ID

****************************************************************/

FUNCTION findWellFcty (
         p_object_id well.object_id%TYPE,
         p_daytime DATE)
RETURN VARCHAR2;

FUNCTION findWellFctyId (
         p_object_id well.object_id%TYPE,
         p_daytime DATE)
RETURN VARCHAR2;

PROCEDURE checkIfEventOverlaps(p_object_id VARCHAR2, p_daytime DATE, p_child_object_id VARCHAR2,  p_end_date DATE);

END EcBp_Stream_Well_Conn;