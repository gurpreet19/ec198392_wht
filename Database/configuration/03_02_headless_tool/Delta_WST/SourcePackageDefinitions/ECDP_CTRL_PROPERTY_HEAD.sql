CREATE OR REPLACE PACKAGE EcDp_ctrl_property IS
/******************************************************************************
** Package        :  EcBp_ctrl_property, head part
**
**
**
** Purpose        : Basic Functions for ctrl_property
**
** Documentation  :  www.energy-components.com
**
** Created        :  31.08.2006 Siah Chio Hwi
**
** Modification history:
**
** Date         Whom  	 		      Change description:
** ----------   ----- 			      --------------------------------------
** 2011.02.22   Dagfinn Rosnes    Added function getUserProperty to support user/role level properties
******************************************************************/

FUNCTION getSystemProperty(p_key VARCHAR2, p_daytime DATE DEFAULT NULL) RETURN VARCHAR2;

FUNCTION getUserProperty(p_key VARCHAR2, p_user_id VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

END EcDp_ctrl_property;