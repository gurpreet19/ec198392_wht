CREATE OR REPLACE PACKAGE ue_Capacity_Release IS
/****************************************************************
** Package        :  ue_Capacity_Release; head part
**
** $Revision: 1.17 $
**
** Purpose        :  Handles capacity release operations
**
** Documentation  :  www.energy-components.com
**
** Created        :  28.04.2008 Kari Sandvik
**
** Modification history:
**
** Date        Whom  	Change description:
** ----------  -------- -------------------------------------------
   24-12-2008  kaurrjes ECPD-10643: Added a new procedure withdrawBid.
   23-10-2009  oonnnng  ECPD-13056: Rename P_RELEASE_NO to P_RECALL_NO in reputRelease() and recallRelease() functions' arguement.
   18-02-2010  ismaiime	ECPD-13844: Rename argument P_RECALL_NO to P_REPUT_NO in function reputRelease()
   12-06-2012  farhaann	ECPD-19488: Added function generateRequestId;
   26-06-2012  leeeewei ECPD-21294: Added function getAwardedQty
   29-06-2012  muhammah	ECPD-21292: Added procedure validateCapBidRange
   11-09-2012  chooysie	ECPD-21292: Added procedure validateLocEventDateRange
******************************************************************************************************/

PROCEDURE generateReleaseName(p_release_no NUMBER);
PROCEDURE genBidName(p_bid_no NUMBER);

PROCEDURE submitRelease(p_release_no NUMBER);
PROCEDURE withdrawRelease(p_release_no NUMBER);
PROCEDURE awardRelease(p_release_no NUMBER);
PROCEDURE resetAwardedReleasingContract(p_release_no NUMBER);
PROCEDURE cancelRelease(p_release_no NUMBER);

PROCEDURE submitBid(p_bid_no NUMBER);
PROCEDURE withdrawBid(p_bid_no NUMBER);
PROCEDURE confirmBid(p_bid_no NUMBER);
PROCEDURE rejectBid(p_bid_no NUMBER);
PROCEDURE matchBid(p_bid_no NUMBER);

PROCEDURE reputRelease(p_reput_no NUMBER,p_reput_note varchar2,p_daytime date);
PROCEDURE recallRelease(p_recall_no NUMBER, p_start_date date, p_end_date date,p_recall_note varchar2);

PROCEDURE validateCapBidRange(n_bid_no NUMBER, p_daytime date);

FUNCTION generateRequestId RETURN VARCHAR2;
FUNCTION getAwardedQty(p_release_no NUMBER) RETURN NUMBER;
PROCEDURE validateLocEventDateRange(p_rel_no number, p_startdate date, p_end_date date);

END ue_Capacity_Release;