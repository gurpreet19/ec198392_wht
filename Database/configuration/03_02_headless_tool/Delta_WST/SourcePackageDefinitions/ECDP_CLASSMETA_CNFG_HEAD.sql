CREATE OR REPLACE PACKAGE EcDp_ClassMeta_cnfg IS
/**************************************************************
** Package:    EcDp_ClassMeta_cnfg
**
** $Revision: 1.39 $
**
** Filename:   EcDp_ClassMeta_cnfg.sql
**
** Part of :   EC Kernel
**
** Purpose:
**
** General Logic:
**
** Document References:
**
**
** Created:     02.11.2015  Arild Vervik, EC
**
**
** Modification history:
**
**
** Date:        Whom:  Change description:
** --------    ----- --------------------------------------------
** 02.11.2015   AV    Needed separate package to reswolve dependency building Materialized Views
**************************************************************/

PROCEDURE SetClassAttrProperty(
    p_class_name VARCHAR2,
    p_attribute_name VARCHAR2,
    p_presentation_cntx VARCHAR2,
    p_owner_cntx  NUMBER,
    p_property_type VARCHAR2,
    p_property_code VARCHAR2,
    p_property_value VARCHAR2);


PROCEDURE SetClassAttrDisabledInd(
    p_class_name VARCHAR2,
    p_attribute_name VARCHAR2,
    p_presentation_cntx VARCHAR2,
    p_owner_cntx  NUMBER,
    p_property_value VARCHAR2);

PROCEDURE SetClassRelDisabledInd(
    p_from_class_name VARCHAR2,
    p_to_class_name VARCHAR2,
    p_role_name VARCHAR2,
    p_presentation_cntx VARCHAR2,
    p_owner_cntx  NUMBER,
    p_property_value VARCHAR2);

PROCEDURE AssertValidProperty(
    p_property_table_name VARCHAR2,
    p_property_type VARCHAR2,
    p_property_code VARCHAR2,
    p_property_value VARCHAR2,
    p_presentation_cntx VARCHAR2 DEFAULT NULL);

FUNCTION getClassViewName(p_class_name IN VARCHAR2, p_class_type IN VARCHAR2) RETURN VARCHAR2;

PROCEDURE flushCache;

FUNCTION getCacheSize RETURN NUMBER;

FUNCTION CLASS_PROPERTY_CNFG RETURN VARCHAR2;
FUNCTION CLASS_ATTR_PROPERTY_CNFG RETURN VARCHAR2;
FUNCTION CLASS_REL_PROPERTY_CNFG RETURN VARCHAR2;
FUNCTION CLASS_TRA_PROPERTY_CNFG RETURN VARCHAR2;

FUNCTION isViewlayerProperty(p_property_table_name IN VARCHAR2, p_property_code IN VARCHAR2) RETURN VARCHAR2;

/**
 * Class property functions
 */
FUNCTION isReadOnly(p_class_name IN VARCHAR2) RETURN VARCHAR2;
FUNCTION skipTriggerCheck(p_class_name IN VARCHAR2) RETURN VARCHAR2;
FUNCTION getCreateEventInd(p_class_name IN VARCHAR2) RETURN VARCHAR2;
FUNCTION getApprovalInd(p_class_name IN VARCHAR2) RETURN VARCHAR2;
FUNCTION getLockInd(p_class_name IN VARCHAR2) RETURN VARCHAR2;
FUNCTION getLockRule(p_class_name IN VARCHAR2) RETURN VARCHAR2;
FUNCTION getAccessControlInd(p_class_name IN VARCHAR2) RETURN VARCHAR2;
FUNCTION getJournalRuleDbSyntax(p_class_name IN VARCHAR2) RETURN VARCHAR2;
FUNCTION getEnsureRevTextOnUpdate(p_class_name IN VARCHAR2) RETURN VARCHAR2;
FUNCTION getLabel(p_class_name IN VARCHAR2) RETURN VARCHAR2;
FUNCTION getDescription(p_class_name IN VARCHAR2) RETURN VARCHAR2;
FUNCTION getClassShortCode(p_class_name IN VARCHAR2) RETURN VARCHAR2;
FUNCTION includeInValidation(p_class_name IN VARCHAR2) RETURN VARCHAR2;
FUNCTION includeInWebservice(p_class_name IN VARCHAR2) RETURN VARCHAR2;
FUNCTION includeInMapping(p_class_name IN VARCHAR2) RETURN VARCHAR2;

/**
 * Class attribute property functions
 */
FUNCTION isMandatory(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2) RETURN VARCHAR2;
FUNCTION isDisabled(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2) RETURN VARCHAR2;
FUNCTION isReportOnly(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2) RETURN VARCHAR2;
FUNCTION getDbSortOrder(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2) RETURN NUMBER;
FUNCTION getScreenSortOrder(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2) RETURN NUMBER;
FUNCTION getLabel(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2) RETURN VARCHAR2;
FUNCTION isReadOnly(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2) RETURN VARCHAR2;
FUNCTION getUomCode(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2) RETURN VARCHAR2;
FUNCTION getDbPresSyntax(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2) RETURN VARCHAR2;
FUNCTION getStaticViewlabelhead(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2) RETURN VARCHAR2;
FUNCTION getStaticViewhidden(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2) RETURN VARCHAR2;
FUNCTION getStaticPresentationSyntax(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2) RETURN VARCHAR2;
FUNCTION getDynamicPresentationSyntax(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2) RETURN VARCHAR2;
FUNCTION getDescription(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2) RETURN VARCHAR2;
FUNCTION getName(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2) RETURN VARCHAR2;
FUNCTION getMaxStaticPresProperty(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2, p_property_code IN VARCHAR2) RETURN VARCHAR2;

/**
 * Class relation property functions
 */
FUNCTION isMandatory(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2) RETURN VARCHAR2; /* NOT USED*/
FUNCTION isDisabled(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2) RETURN VARCHAR2;
FUNCTION isReportOnly(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2) RETURN VARCHAR2;
FUNCTION getLabel(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2) RETURN VARCHAR2; /* NOT USED*/
FUNCTION getDbSortOrder(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2) RETURN NUMBER;
FUNCTION getAllocPriority(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2) RETURN NUMBER;
FUNCTION getAccessControlMethod(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2) RETURN VARCHAR2; /* NOT USED*/
FUNCTION getApprovalInd(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2) RETURN VARCHAR2; /* NOT USED*/
FUNCTION getReverseApprovalInd(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2) RETURN VARCHAR2; /* NOT USED*/
FUNCTION getDbPresSyntax(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2) RETURN VARCHAR2;
FUNCTION getStaticPresentationSyntax(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2) RETURN VARCHAR2;
FUNCTION getDynamicPresentationSyntax(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2) RETURN VARCHAR2;
FUNCTION getDescription(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2) RETURN VARCHAR2;
FUNCTION getName(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2) RETURN VARCHAR2;
FUNCTION getMaxStaticPresProperty(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2, p_property_code IN VARCHAR2) RETURN VARCHAR2;

/**
 * Class trigger action property functions
 */
FUNCTION isDisabled(p_class_name IN VARCHAR2, p_triggering_event IN VARCHAR2, p_trigger_type IN VARCHAR2, p_sort_order IN NUMBER) RETURN VARCHAR2;
FUNCTION getDescription(p_class_name IN VARCHAR2, p_triggering_event IN VARCHAR2, p_trigger_type IN VARCHAR2, p_sort_order IN NUMBER) RETURN VARCHAR2;

END;