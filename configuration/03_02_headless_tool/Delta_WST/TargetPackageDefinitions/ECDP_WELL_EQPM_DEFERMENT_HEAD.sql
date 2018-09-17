CREATE OR REPLACE PACKAGE EcDp_Well_Eqpm_Deferment IS

/****************************************************************
** Package        :  EcDp_Well_Eqpm_Deferment, header part
**
** $Revision: 1.11.2.3 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to Equipment and Well Deferment.
** Documentation  :  www.energy-components.com
**
** Created  : 11.07.2007  Sarojini Rajaretnam
**
** Modification history:
**
** Version  Date     	Whom  	 Change description:
** -------  ----------  -------- --------------------------------------
**	        14-04-2008	rajarsar ECPD-7828: Modified updateEndDateForChildEvent procedure.
**          21-05-2008  oonnnng  ECPD-7878: Add updateReasonCodeFOrChildEvent procedure.
**          22-12-2008  leongwen ECPD-7847: New BF: "Well Downtime - by Well" under Equipment and Well Deferment
**          28-12-2009  leongwen ECPD-13176 Enhancement to Equipment Off deferment screen
**          28-10-2011  rajarsar ECPD-17942: Updated approveWellEqpmDeferment,approveWellEqpmDefermentbyWell,verifyWellEqpmDeferment, verifyWellEqpmDefermentbyWell, setLossRate,allocateGroupRateToWells, sumFromWells, updateEndDateForChildEvent, updateReasonCodeForChildEvent to support new PK which is EVENT_NO.
**          27-02-2012  syazwnur ECPD-17956: Modified approveWellEqpmDefermentbyWell and verifyWellEqpmDefermentbyWell to pass parameter 'downtime_categ'.
**          09-01-2013  wonggkai ECPD-23079: new last_updated_date parameter for updateEndDateForChildEvent, last_updated_date and p_child_object_id for updateReasonCodeForChildEvent
**          03-01-2014  kumarsur ECPD-26357: Add updateStartDateForChildEvent procedure.
**          15-04-2014  leongwen ECPD-27376: Add TYPE to support the procedure insertAffectedWells to hold the cursor records and check for multiple well versions involved.
*****************************************************************/

TYPE t_object_id                    IS TABLE OF WELL_EQUIP_DOWNTIME.OBJECT_ID%TYPE;
TYPE t_object_type                  IS TABLE OF WELL_EQUIP_DOWNTIME.OBJECT_TYPE%TYPE;
TYPE t_parent_event_no              IS TABLE OF WELL_EQUIP_DOWNTIME.PARENT_EVENT_NO%TYPE;
TYPE t_parent_object_id             IS TABLE OF WELL_EQUIP_DOWNTIME.PARENT_OBJECT_ID%TYPE;
TYPE t_parent_daytime               IS TABLE OF WELL_EQUIP_DOWNTIME.PARENT_DAYTIME%TYPE;
TYPE t_daytime                      IS TABLE OF WELL_EQUIP_DOWNTIME.DAYTIME%TYPE;
TYPE t_end_date                     IS TABLE OF WELL_EQUIP_DOWNTIME.END_DATE%TYPE;
TYPE t_downtime_type                IS TABLE OF WELL_EQUIP_DOWNTIME.DOWNTIME_TYPE%TYPE;
TYPE t_downtime_categ               IS TABLE OF WELL_EQUIP_DOWNTIME.DOWNTIME_CATEG%TYPE;
TYPE t_downtime_class_type          IS TABLE OF WELL_EQUIP_DOWNTIME.DOWNTIME_CLASS_TYPE%TYPE;
TYPE t_created_by                   IS TABLE OF WELL_EQUIP_DOWNTIME.CREATED_BY%TYPE;

PROCEDURE approveWellEqpmDeferment(p_event_no NUMBER,
                         p_user_name VARCHAR2);

PROCEDURE approveWellEqpmDefermentbyWell(p_event_no NUMBER,
                         p_user_name VARCHAR2,downtime_categ VARCHAR2);

PROCEDURE verifyWellEqpmDeferment(p_event_no NUMBER,
                         p_user_name VARCHAR2);

PROCEDURE verifyWellEqpmDefermentbyWell(p_event_no NUMBER,
                         p_user_name VARCHAR2,downtime_categ VARCHAR2);

PROCEDURE setLossRate(p_event_no NUMBER, p_user VARCHAR2);

PROCEDURE allocateGroupRateToWells(p_event_no NUMBER, p_user_name VARCHAR2);

PROCEDURE sumFromWells(p_event_no NUMBER, p_user_name VARCHAR2);

PROCEDURE updateEndDateForChildEvent(p_event_no NUMBER, p_o_end_date DATE,  p_user VARCHAR2, p_last_updated_date DATE);

PROCEDURE updateReasonCodeForChildEvent(p_event_no NUMBER, p_user VARCHAR2, p_last_updated_date DATE);

PROCEDURE insertAffectedWells(p_type VARCHAR2, p_object_id VARCHAR2, p_daytime DATE, p_end_date DATE DEFAULT NULL, p_username VARCHAR2);

PROCEDURE updateStartDateForChildEvent(p_event_no NUMBER, p_o_start_date DATE,  p_user VARCHAR2, p_last_updated_date DATE);

END  EcDp_Well_Eqpm_Deferment;