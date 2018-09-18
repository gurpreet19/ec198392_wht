CREATE OR REPLACE PACKAGE EcDp_Delivery_Point_Nomination IS
/******************************************************************************
** Package        :  EcDp_Delivery_Point_Nomination, head part
**
** $Revision: 1.7 $
**
** Purpose        :  Find and work with delivery point nominations
**
** Documentation  :  www.energy-components.com
**
** Created        :  24.03.2006 Kristin Eide
**
** Modification history:
**
** Date        Whom      Change description:
** ------      -----     -----------------------------------------------------------------------------------------------
** 24.03.2006  EIDEEKRI  Initial version
**
**
********************************************************************/

FUNCTION getDeliveryPointProductionDay(
  p_date        DATE
)
RETURN DATE;
--

FUNCTION getDayDelptUpstreamNom(
  p_delivery_point_id   VARCHAR2,
  p_date        DATE
)
RETURN INTEGER;

--

FUNCTION getDayDelptDownstreamNom(
  p_delivery_point_id   VARCHAR2,
  p_date        DATE
)
RETURN INTEGER;

--

FUNCTION getDayDeliveryPointNomination(
  p_delivery_point_id   VARCHAR2,
  p_date        DATE
)
RETURN INTEGER;

--

FUNCTION getSubDayDelpntNomination(
  p_delivery_point_id   VARCHAR2,
  p_date        			DATE,
  p_class_name VARCHAR2
)
RETURN INTEGER;

--
FUNCTION getDayDeliveryPointTarget(
  p_delivery_point_id   VARCHAR2,
  p_date        DATE
)
RETURN INTEGER;

--

END EcDp_Delivery_Point_Nomination;