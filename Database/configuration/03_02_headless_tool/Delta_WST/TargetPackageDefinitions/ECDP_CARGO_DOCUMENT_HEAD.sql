CREATE OR REPLACE PACKAGE EcDp_Cargo_Document IS
/**************************************************************************************************
** Package  :  EcDp_Cargo_Document
**
** $Revision: 1.5.26.1 $
**
** Purpose  :  This package handles the triggered updating of Cargo Document views
**
** Created:     28.05.2007 Nik Eizwan
**
** Modification history:
**
** Date:        Whom:       Rev.  Change description:
** ----------  	-----       ----  ------------------------------------------------------------------------
** 28.05.2007   Nik Eizwan  0.1   First version
** 03.12.2012   muhammah          ECPD-22515:
                                  add procedures: useDocTemplate, updateCPYDocSet, instCPYInstructionReceiver, instCPYInstructionDoc, updateDocTemplate
                                  add funtion: getTemplateName
**************************************************************************************************/

PROCEDURE useTemplate(p_parcel_no NUMBER, p_template_code VARCHAR2);

PROCEDURE useDocTemplate(p_parcel_no NUMBER, p_template_code VARCHAR2, p_la_cpy_id VARCHAR2);

PROCEDURE updateDocSet(p_object_id VARCHAR2, p_template_code VARCHAR2, p_old_cargo_temp_code VARCHAR2, p_new_cargo_temp_code VARCHAR2);

PROCEDURE instInstructionReceiver(p_parcel_no NUMBER, p_company_contact_id VARCHAR2);

PROCEDURE instInstructionDoc(p_parcel_no NUMBER, p_doc_code VARCHAR2);

PROCEDURE instLAInstructionReceiver(p_lift_acc_id VARCHAR2, p_template_code VARCHAR2, p_company_contact_id VARCHAR2);

PROCEDURE instLAInstructionDoc(p_lift_acc_id VARCHAR2, p_template_code VARCHAR2, p_doc_code VARCHAR2);

PROCEDURE updateCPYDocSet(p_object_id VARCHAR2, p_template_code VARCHAR2, p_old_cargo_temp_code VARCHAR2, p_new_cargo_temp_code VARCHAR2);

PROCEDURE instCPYInstructionReceiver(p_company_id VARCHAR2, p_template_code VARCHAR2, p_company_contact_id VARCHAR2);

PROCEDURE instCPYInstructionDoc(p_company_id VARCHAR2, p_template_code VARCHAR2, p_doc_code VARCHAR2);

PROCEDURE updateDocTemplate(p_parcel_no NUMBER, p_template_code VARCHAR2, p_la_cpy_id VARCHAR2);

FUNCTION getTemplateName( p_template_code VARCHAR2, p_la_cpy_id VARCHAR2)RETURN VARCHAR2;

END EcDp_Cargo_Document;