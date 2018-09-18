CREATE OR REPLACE PACKAGE EcDp_Capacity_Release IS
/****************************************************************
** Package        :  EcDp_Capacity_Release; head part
**
** $Revision: 1.8 $
**
** Purpose        :  Handles capacity release operations
**
** Documentation  :  www.energy-components.com
**
** Created        :  28.04.2008 Kari Sandvik
**
** Modification history:
**
** Date        Whom      Change description:
** ----------  -----     -------------------------------------------
** 19.05.2009  oonnnng   ECPD-11850: Removed getAwardedCapacity() and getAvailableCapacity() functions.
** 10.07.2009  lauuufus Add new function getMatchBidRate()
** 26.06.2012  leeeewei Add new function getMinMaxDaytime()
**************************************************************************************************/


PROCEDURE instantiateReleaseForm(p_release_no NUMBER);
PROCEDURE instantiateBidForm(p_bid_no NUMBER);
PROCEDURE validateReleaseUpdate(p_release_no NUMBER);
PROCEDURE validateBidUpdate(p_bid_no VARCHAR2);
PROCEDURE deleteRelease(p_release_no NUMBER);
PROCEDURE deleteBid(p_bid_no NUMBER);

FUNCTION getRecalledCapacity(p_awarded_cap INTEGER, p_available_cap INTEGER) RETURN INTEGER;

FUNCTION getMatchBidRate(p_bid_no NUMBER) RETURN NUMBER;

FUNCTION getMinMaxDaytime(p_bid_no NUMBER,p_cntr_cap_id VARCHAR2, p_min_or_max VARCHAR2) RETURN DATE;

END EcDp_Capacity_Release;