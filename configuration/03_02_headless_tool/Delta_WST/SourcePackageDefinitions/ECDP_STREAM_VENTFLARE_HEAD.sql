CREATE OR REPLACE PACKAGE EcDp_Stream_VentFlare IS
/****************************************************************
** Package        :  EcDp_Stream_VentFlare
**
** $Revision: 1.5 $
**
** Purpose        :  This package is responsible for supporting business functions
**                         related to Daily Gas Stream - Vent and Flare.
**
** Documentation  :  www.energy-components.com
**
** Created  : 17.03.2010  Sarojini Rajaretnam
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
** 17.03.2010 rajarsar	ECPD-4828:Initial version
** 31.05.2010 rajarsar	ECPD-14746: Added Procedure insertWell
** 31.05.2010 rajarsar	ECPD-14622: Updated Procedure updateSource
** 02.02.2011 farhaann  ECPD-16411: Changed updateSource parameter to use p_grs_vol instead of p_net_vol
** 25.05.2011 rajarsar  ECPD-17408: Added a new procedure delEqpmWellChildEvent
** 19.07.2016 shindani  ECPD-30991: Modified AddEqpmEvent procedure to support object group connection check.
*****************************************************************/

Procedure updateSource(p_object_id VARCHAR2, p_daytime DATE,  p_user VARCHAR2, p_grs_vol VARCHAR2);

PROCEDURE updateEndDateForChildEvent(p_object_id VARCHAR2, p_class_name VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_start_daytime DATE,p_end_daytime DATE,p_user VARCHAR2);

PROCEDURE addEqpmEvent(p_object_id VARCHAR2, p_daytime DATE,  p_user VARCHAR2);

PROCEDURE createChildEvent(p_object_id VARCHAR2, p_class_name VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_start_daytime DATE,p_end_daytime DATE,p_user VARCHAR2);

PROCEDURE createEqpmWellChildEvent(p_object_id VARCHAR2, p_class_name VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_well_id VARCHAR2, p_start_daytime DATE, p_user VARCHAR2);

PROCEDURE insertWell(p_object_id VARCHAR2, p_class_name VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_start_daytime DATE,p_end_daytime DATE,p_user VARCHAR2);

PROCEDURE delEqpmWellChildEvent(p_object_id VARCHAR2, p_class_name VARCHAR2, p_daytime DATE, p_asset_id VARCHAR2, p_start_daytime DATE);

END EcDp_Stream_VentFlare;