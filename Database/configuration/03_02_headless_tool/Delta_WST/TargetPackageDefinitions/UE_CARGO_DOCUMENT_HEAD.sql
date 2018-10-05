CREATE OR REPLACE PACKAGE ue_cargo_document IS
/******************************************************************************
** Package        :  ue_cargo_document, head part
**
** $Revision: 1.1.2.2 $
**
** Purpose        :  Handles functinality around cargo document
**
** Documentation  :  www.energy-components.com
**
** Created  	  :  20.09.2012 	Chooy Siew Meng
**
** Modification history:
**
** Date        	Whom  			Change description:
** ------      	----- 			-----------------------------------------------------------------------------------------------
**05.12.2012    muhammah    ECPD-22515: Add procedures useDocTemplate and updateDocTemplate
********************************************************************************************************************************/

PROCEDURE useTemplate(p_parcel_no NUMBER, p_template_code VARCHAR2);

PROCEDURE useDocTemplate(p_parcel_no NUMBER, p_template_code VARCHAR2, p_la_cpy_id VARCHAR2);

PROCEDURE updateDocTemplate(p_parcel_no NUMBER, p_template_code VARCHAR2, p_la_cpy_id VARCHAR2);

END ue_cargo_document;