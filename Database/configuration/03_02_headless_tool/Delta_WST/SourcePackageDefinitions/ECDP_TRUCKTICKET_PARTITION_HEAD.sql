CREATE OR REPLACE PACKAGE EcDp_TruckTicket_Partition IS

/****************************************************************
** Package        :  EcDp_TruckTIcket_Object_Partition, head part
**
** $Revision: 1.5 $
**
** Purpose        :  Provide basic functions on Truck Ticket Objects
**
** Documentation  :  www.energy-components.com
**
** Created  : 05.04.2018  shindani
**
** Modification history:
**
**  Date        Whom                Change description:
**  ------      -----             --------------------------------------
**  05.04.2018  shindani 	      Initial Version.
****************************************************************/

FUNCTION finderObjectPartition(
  p_daytime     DATE,
  p_object_id	VARCHAR2,
  p_class_name  VARCHAR2,
  p_user	    VARCHAR2)
RETURN NUMBER;

END EcDp_TruckTicket_Partition;