CREATE OR REPLACE PACKAGE EcBp_Well_Blowdown IS

/****************************************************************
** Package        :  EcBp_Well_Blowdown, header part
**
** $Revision: 1.0 $
**
** Purpose        :  This package is responsible for supporting business function
**                   related to Well Blowdown Event.
** Documentation  :  www.energy-components.com
**
** Created  : 20.04.2017  Gaurav Chaudhary
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
********************************************************************/

PROCEDURE deletechildevent(p_event_no NUMBER);

PROCEDURE insertblowdowndata(p_parent_event_no NUMBER
                            ,p_object_id       VARCHAR2
                            ,p_start_date      DATE
                            ,p_end_date        DATE
                            ,p_blowdown_freq   VARCHAR2
                            ,p_username        VARCHAR2);

FUNCTION validateblowdowntime(p_daytime         DATE
                             ,p_parent_event_no NUMBER)
RETURN NUMBER;

FUNCTION countChildEvent(p_parent_event_no NUMBER)
RETURN NUMBER;

END EcBp_Well_Blowdown;