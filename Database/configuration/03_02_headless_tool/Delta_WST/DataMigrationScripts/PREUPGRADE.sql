CREATE OR REPLACE FUNCTION check_sequence ( p_seq_name varchar2)
RETURN boolean 
IS 

cnt NUMBER;

BEGIN

  SELECT COUNT(*)
  INTO cnt
  FROM user_sequences
  WHERE sequence_name = p_seq_name;
  
  IF cnt > 0 THEN
   RETURN FALSE ;
  ELSE
   RETURN TRUE;
  END IF ; 

END check_sequence; 
--~^UTDELIM^~--	


BEGIN

	IF NOT check_sequence('HIBERNATE_SEQUENCE') THEN
		EXECUTE IMMEDIATE 'DROP SEQUENCE HIBERNATE_SEQUENCE' ;
	END IF ;	

	IF check_sequence('ATTACHMENT_ID_SEQ') THEN
		EXECUTE IMMEDIATE 'CREATE SEQUENCE ATTACHMENT_ID_SEQ';
	END IF ;


	IF check_sequence('AUDIT_ID_SEQ') THEN
		EXECUTE IMMEDIATE 'CREATE SEQUENCE AUDIT_ID_SEQ';
	END IF ;

	IF check_sequence('BAM_TASK_ID_SEQ') THEN
		EXECUTE IMMEDIATE 'CREATE SEQUENCE BAM_TASK_ID_SEQ';
	END IF ;

	IF check_sequence('BOOLEANEXPR_ID_SEQ') THEN
		EXECUTE IMMEDIATE 'CREATE SEQUENCE BOOLEANEXPR_ID_SEQ';
	END IF ;

	IF check_sequence('COMMENT_ID_SEQ') THEN
		EXECUTE IMMEDIATE 'CREATE SEQUENCE COMMENT_ID_SEQ';
	END IF ;
	IF check_sequence('CONTENT_ID_SEQ') THEN
		EXECUTE IMMEDIATE 'CREATE SEQUENCE CONTENT_ID_SEQ';
	END IF ;

	IF check_sequence('CONTEXT_MAPPING_INFO_ID_SEQ') THEN
		EXECUTE IMMEDIATE 'CREATE SEQUENCE CONTEXT_MAPPING_INFO_ID_SEQ';
	END IF ;

	IF check_sequence('CORRELATION_KEY_ID_SEQ') THEN
		EXECUTE IMMEDIATE 'CREATE SEQUENCE CORRELATION_KEY_ID_SEQ';
	END IF ;	

	IF check_sequence('CORRELATION_PROP_ID_SEQ') THEN
		EXECUTE IMMEDIATE 'CREATE SEQUENCE CORRELATION_PROP_ID_SEQ' ;
	END IF ;	

	IF check_sequence('DEADLINE_ID_SEQ') THEN
		EXECUTE IMMEDIATE 'CREATE SEQUENCE DEADLINE_ID_SEQ' ;
	END IF ;	

	IF check_sequence('EMAILNOTIFHEAD_ID_SEQ') THEN
		EXECUTE IMMEDIATE 'CREATE SEQUENCE EMAILNOTIFHEAD_ID_SEQ' ;
	END IF ;	

	IF check_sequence('ERROR_INFO_ID_SEQ') THEN
		EXECUTE IMMEDIATE 'CREATE SEQUENCE  ERROR_INFO_ID_SEQ';
	END IF ;	

	IF check_sequence('ESCALATION_ID_SEQ') THEN
		EXECUTE IMMEDIATE 'CREATE SEQUENCE ESCALATION_ID_SEQ' ;
	END IF ;	

	IF check_sequence('I18NTEXT_ID_SEQ') THEN
		EXECUTE IMMEDIATE 'CREATE SEQUENCE I18NTEXT_ID_SEQ' ;
	END IF ;	

	IF check_sequence('NODE_INST_LOG_ID_SEQ') THEN
		EXECUTE IMMEDIATE 'CREATE SEQUENCE NODE_INST_LOG_ID_SEQ' ;
	END IF ;	

	IF check_sequence('NOTIFICATION_ID_SEQ') THEN
		EXECUTE IMMEDIATE 'CREATE SEQUENCE NOTIFICATION_ID_SEQ' ;
	END IF ;	

	IF check_sequence('PROCESS_INSTANCE_INFO_ID_SEQ') THEN
		EXECUTE IMMEDIATE 'CREATE SEQUENCE PROCESS_INSTANCE_INFO_ID_SEQ' ;
	END IF ;	

	IF check_sequence('PROC_INST_LOG_ID_SEQ') THEN
		EXECUTE IMMEDIATE 'CREATE SEQUENCE PROC_INST_LOG_ID_SEQ' ;
	END IF ;	

	IF check_sequence('REASSIGNMENT_ID_SEQ') THEN
		EXECUTE IMMEDIATE 'CREATE SEQUENCE REASSIGNMENT_ID_SEQ' ;
	END IF ;	

	IF check_sequence('REQUEST_INFO_ID_SEQ') THEN
		EXECUTE IMMEDIATE 'CREATE SEQUENCE REQUEST_INFO_ID_SEQ' ;
	END IF ;	

	IF check_sequence('SESSIONINFO_ID_SEQ') THEN
		EXECUTE IMMEDIATE 'CREATE SEQUENCE SESSIONINFO_ID_SEQ' ;
	END IF ;	

	IF check_sequence('TASK_DEF_ID_SEQ') THEN
		EXECUTE IMMEDIATE 'CREATE SEQUENCE TASK_DEF_ID_SEQ' ;
	END IF ;	

	IF check_sequence('TASK_EVENT_ID_SEQ') THEN
		EXECUTE IMMEDIATE 'CREATE SEQUENCE TASK_EVENT_ID_SEQ' ;
	END IF ;	

	IF check_sequence('VAR_INST_LOG_ID_SEQ') THEN
		EXECUTE IMMEDIATE 'CREATE SEQUENCE VAR_INST_LOG_ID_SEQ' ;
	END IF ;	

	IF check_sequence('WORKITEMINFO_ID_SEQ') THEN
		EXECUTE IMMEDIATE 'CREATE SEQUENCE WORKITEMINFO_ID_SEQ' ;
	END IF ;	

	IF check_sequence('PROCESS_LOG_ID_SEQ') THEN
		EXECUTE IMMEDIATE 'CREATE SEQUENCE PROCESS_LOG_ID_SEQ' ;
	END IF ;	

	IF check_sequence('NODE_PARAM_LOG_ID_SEQ') THEN
		EXECUTE IMMEDIATE 'CREATE SEQUENCE NODE_PARAM_LOG_ID_SEQ' ;
	END IF ;	

	IF check_sequence('HIBERNATE_SEQUENCE') THEN
		EXECUTE IMMEDIATE 'CREATE SEQUENCE HIBERNATE_SEQUENCE' ;
	END IF ;	
	
	IF check_sequence('TASK_ID_SEQ') THEN
		EXECUTE IMMEDIATE 'CREATE SEQUENCE TASK_ID_SEQ';
	END IF ;

END;
--~^UTDELIM^~--	

DROP FUNCTION check_sequence
--~^UTDELIM^~--	
DECLARE
    seqs NUMBER;
BEGIN
    SELECT COUNT(*) INTO seqs FROM user_sequences WHERE sequence_name = 'DEPLOY_STORE_ID_SEQ';
    IF seqs = 0 THEN
        EXECUTE IMMEDIATE 'create sequence DEPLOY_STORE_ID_SEQ';
    END IF;
END;
--~^UTDELIM^~--

DECLARE
    seqs NUMBER;
BEGIN
    SELECT COUNT(*) INTO seqs FROM user_sequences WHERE sequence_name = 'BPM_DATA_SET_USAGE_SEQ';
    IF seqs = 0 THEN
        EXECUTE IMMEDIATE 'create sequence BPM_DATA_SET_USAGE_SEQ';
    END IF;
END;
--~^UTDELIM^~--
DECLARE
    seqs NUMBER;
BEGIN
    SELECT COUNT(*) INTO seqs FROM user_sequences WHERE sequence_name = 'BPM_NODE_INSTANCE_STATE_SEQ';
    IF seqs = 0 THEN
        EXECUTE IMMEDIATE 'create sequence BPM_NODE_INSTANCE_STATE_SEQ';
    END IF;
END;
--~^UTDELIM^~--

DECLARE
    seqs NUMBER;
BEGIN
    SELECT COUNT(*) INTO seqs FROM user_sequences WHERE sequence_name = 'BPM_PROCESS_INSTANCE_STATE_SEQ';
    IF seqs = 0 THEN
        EXECUTE IMMEDIATE 'create sequence BPM_PROCESS_INSTANCE_STATE_SEQ';
    END IF;
END;
--~^UTDELIM^~--
DECLARE
    seqs NUMBER;
BEGIN
    SELECT COUNT(*) INTO seqs FROM user_sequences WHERE sequence_name = 'BPM_RELATION_STORE_SEQ';
    IF seqs = 0 THEN
        EXECUTE IMMEDIATE 'create sequence BPM_RELATION_STORE_SEQ';
    END IF;
END;
--~^UTDELIM^~--
BEGIN
  EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW MV_OBJECTS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -12003 THEN
      RAISE;
    END IF;
END;
--~^UTDELIM^~--

BEGIN
  EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW MV_OBJECTS_VERSION';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -12003 THEN
      RAISE;
    END IF;
END;
--~^UTDELIM^~--
	
DROP VIEW GROUPS
--~^UTDELIM^~--
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
    p_property_value VARCHAR2);

FUNCTION getClassViewName(p_class_name IN VARCHAR2, p_class_type IN VARCHAR2) RETURN VARCHAR2;

PROCEDURE flushCache;

FUNCTION getCacheSize RETURN NUMBER;

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
--~^UTDELIM^~--

CREATE OR REPLACE PACKAGE BODY EcDp_ClassMeta_cnfg IS
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
/*
 * Propperty code prefixes:
 *
 *   CP - class-level property
 *   AP - attribute-level property
 *   RP - Relation-level property
 *   TP - Trigger action property
 */

/* VIEWLAYER properties */
CP_ENSURE_REV_TEXT_ON_UPD CONSTANT VARCHAR2(100) := 'ENSURE_REV_TEXT_ON_UPD';
CP_JOURNAL_RULE_DB_SYNTAX CONSTANT VARCHAR2(100) := 'JOURNAL_RULE_DB_SYNTAX';
CP_REV_TEXT_DB_SYNTAX     CONSTANT VARCHAR2(100) := 'REV_TEXT_DB_SYNTAX';
CP_LOCK_IND               CONSTANT VARCHAR2(100) := 'LOCK_IND';
CP_LOCK_RULE              CONSTANT VARCHAR2(100) := 'LOCK_RULE';
CP_CLASS_SHORT_CODE       CONSTANT VARCHAR2(100) := 'CLASS_SHORT_CODE';
CP_ACCESS_CONTROL_IND     CONSTANT VARCHAR2(100) := 'ACCESS_CONTROL_IND';
CP_APPROVAL_IND           CONSTANT VARCHAR2(100) := 'APPROVAL_IND';
CP_SKIP_TRG_CHECK_IND     CONSTANT VARCHAR2(100) := 'SKIP_TRG_CHECK_IND';
CP_INCLUDE_WEBSERVICE     CONSTANT VARCHAR2(100) := 'INCLUDE_WEBSERVICE';
CP_CREATE_EV_IND          CONSTANT VARCHAR2(100) := 'CREATE_EV_IND';
CP_READ_ONLY_IND          CONSTANT VARCHAR2(100) := 'READ_ONLY_IND';
CP_INCLUDE_IN_MAPPING_IND CONSTANT VARCHAR2(100) := 'INCLUDE_IN_MAPPING_IND';

AP_READ_ONLY_IND          CONSTANT VARCHAR2(100) := 'READ_ONLY_IND';
AP_DB_SORT_ORDER          CONSTANT VARCHAR2(100) := 'DB_SORT_ORDER';
AP_DISABLED_IND           CONSTANT VARCHAR2(100) := 'DISABLED_IND';
AP_IS_MANDATORY           CONSTANT VARCHAR2(100) := 'IS_MANDATORY';
AP_REPORT_ONLY_IND        CONSTANT VARCHAR2(100) := 'REPORT_ONLY_IND';
AP_UOM_CODE               CONSTANT VARCHAR2(100) := 'UOM_CODE';
AP_PRESENTATION_SYNTAX    CONSTANT VARCHAR2(100) := 'PresentationSyntax';

RP_ALLOC_PRIORITY         CONSTANT VARCHAR2(100) := 'ALLOC_PRIORITY';
RP_DB_SORT_ORDER          CONSTANT VARCHAR2(100) := 'DB_SORT_ORDER';
RP_DISABLED_IND           CONSTANT VARCHAR2(100) := 'DISABLED_IND';
RP_IS_MANDATORY           CONSTANT VARCHAR2(100) := 'IS_MANDATORY';
RP_REPORT_ONLY_IND        CONSTANT VARCHAR2(100) := 'REPORT_ONLY_IND';
RP_ACCESS_CONTROL_METHOD  CONSTANT VARCHAR2(100) := 'ACCESS_CONTROL_METHOD';
RP_APPROVAL_IND           CONSTANT VARCHAR2(100) := 'APPROVAL_IND';
RP_REVERSE_APPROVAL_IND   CONSTANT VARCHAR2(100) := 'REVERSE_APPROVAL_IND';
RP_PRESENTATION_SYNTAX    CONSTANT VARCHAR2(100) := 'PresentationSyntax';

TP_DISABLED_IND           CONSTANT VARCHAR2(100) := 'DISABLED_IND';

/* APPLICATION properties */
CP_LABEL                  CONSTANT VARCHAR2(100) := 'LABEL';
AP_LABEL                  CONSTANT VARCHAR2(100) := 'LABEL';
RP_LABEL                  CONSTANT VARCHAR2(100) := 'LABEL';
AP_LABEL_ID               CONSTANT VARCHAR2(100) := 'LABEL_ID';
CP_INCLUDE_IN_VALIDATION  CONSTANT VARCHAR2(100) := 'INCLUDE_IN_VALIDATION';
CP_DESCRIPTION            CONSTANT VARCHAR2(100) := 'DESCRIPTION';
AP_DESCRIPTION            CONSTANT VARCHAR2(100) := 'DESCRIPTION';
RP_DESCRIPTION            CONSTANT VARCHAR2(100) := 'DESCRIPTION';
TP_DESCRIPTION            CONSTANT VARCHAR2(100) := 'DESCRIPTION';
AP_NAME                   CONSTANT VARCHAR2(100) := 'NAME';
RP_NAME                   CONSTANT VARCHAR2(100) := 'NAME';
AP_DB_PRES_SYNTAX         CONSTANT VARCHAR2(100) := 'DB_PRES_SYNTAX';
RP_DB_PRES_SYNTAX         CONSTANT VARCHAR2(100) := 'DB_PRES_SYNTAX';
AP_SCREEN_SORT_ORDER      CONSTANT VARCHAR2(100) := 'SCREEN_SORT_ORDER';
RP_SCREEN_SORT_ORDER      CONSTANT VARCHAR2(100) := 'SCREEN_SORT_ORDER';

/* *_PRESENTATION properties */
PP_VIEWLABELHEAD          CONSTANT VARCHAR2(100) := 'viewlabelhead';

TYPE PropertyValueCache1_t IS TABLE OF VARCHAR2(4000) INDEX BY VARCHAR2(250);
TYPE PropertyValueCache2_t IS TABLE OF PropertyValueCache1_t INDEX BY VARCHAR2(250);
TYPE PropertyValueCache3_t IS TABLE OF PropertyValueCache2_t INDEX BY VARCHAR2(250);
TYPE PropertyValueCache4_t IS TABLE OF PropertyValueCache3_t INDEX BY VARCHAR2(250);
TYPE PropertyValueCache5_t IS TABLE OF PropertyValueCache4_t INDEX BY VARCHAR2(250);

/**
 * Class property caches
 * =====================
 * VIEWLAYER property caches for a single class
 */
VL_CLASS_PROPERTY_CACHE    PropertyValueCache2_t;
VL_ATTR_PROPERTY_CACHE     PropertyValueCache3_t;
VL_REL_PROPERTY_CACHE      PropertyValueCache4_t;
VL_TRA_PROPERTY_CACHE      PropertyValueCache5_t;

/**
 * Class property caches
 * =====================
 * APPLICATION property caches for a single class
 */
AP_CLASS_PROPERTY_CACHE    PropertyValueCache2_t;
AP_ATTR_PROPERTY_CACHE     PropertyValueCache3_t;
AP_REL_PROPERTY_CACHE      PropertyValueCache4_t;
AP_TRA_PROPERTY_CACHE      PropertyValueCache5_t;

CACHING_MODE VARCHAR2(32) := 'SESSION';

CURSOR c_class_property_max(
       p_class_name IN VARCHAR2,
       p_property_code IN VARCHAR2,
       p_property_type IN VARCHAR2,
       p_presentation_cntx IN VARCHAR2) IS
  SELECT p.class_name, p.property_code, p.property_value
  FROM class_property_cnfg p
  WHERE p.class_name = p_class_name
  AND p.property_code = Nvl(p_property_code, p.property_code)
  AND p.presentation_cntx = p_presentation_cntx
  AND p.property_type = p_property_type
  AND p.owner_cntx = (
        SELECT MAX(owner_cntx)
        FROM class_property_cnfg x
        WHERE p.class_name = x.class_name AND p.property_code = x.property_code AND p.presentation_cntx = x.presentation_cntx
  );

CURSOR c_class_rel_property_max(
       p_from_class_name IN VARCHAR2,
       p_to_class_name IN VARCHAR2,
       p_role_name IN VARCHAR2,
       p_property_code IN VARCHAR2,
       p_property_type IN VARCHAR2,
       p_presentation_cntx IN VARCHAR2) IS
  SELECT p.from_class_name, p.to_class_name, p.role_name, p.property_code, p.property_value
  FROM class_rel_property_cnfg p
  WHERE p.from_class_name = Nvl(p_from_class_name, p.from_class_name)
  AND p.to_class_name = p_to_class_name
  AND p.role_name = Nvl(p_role_name, p.role_name)
  AND p.property_code = Nvl(p_property_code, p.property_code)
  AND p.presentation_cntx = p_presentation_cntx
  AND p.property_type = p_property_type
  AND p.owner_cntx = (
        SELECT MAX(owner_cntx)
        FROM class_rel_property_cnfg x
        WHERE p.from_class_name = x.from_class_name
        AND p.to_class_name = x.to_class_name
        AND p.role_name = x.role_name
        AND p.property_code = x.property_code
        AND p.presentation_cntx = x.presentation_cntx
  );

CURSOR c_class_tra_property_max(
       p_class_name IN VARCHAR2,
       p_triggering_event IN VARCHAR2,
       p_trigger_type IN VARCHAR2,
       p_sort_order IN NUMBER,
       p_property_code IN VARCHAR2,
       p_property_type IN VARCHAR2) IS
  SELECT p.class_name, p.triggering_event, p.trigger_type, p.sort_order, p.property_code, p.property_value
  FROM class_tra_property_cnfg p
  WHERE p.class_name = p_class_name
  AND p.triggering_event = Nvl(p_triggering_event, p.triggering_event)
  AND p.trigger_type = Nvl(p_trigger_type, p.trigger_type)
  AND p.sort_order = Nvl(p_sort_order, p.sort_order)
  AND p.property_code = Nvl(p_property_code, p.property_code)
  AND p.property_type = p_property_type
  AND p.owner_cntx = (
        SELECT MAX(owner_cntx)
        FROM class_tra_property_cnfg x
        WHERE p.class_name = x.class_name
        AND p.triggering_event = x.triggering_event
        AND p.trigger_type = x.trigger_type
        AND p.sort_order = x.sort_order
        AND p.property_code = x.property_code
  );

CURSOR c_class_attr_property_max(
       p_class_name IN VARCHAR2,
       p_attribute_name IN VARCHAR2,
       p_property_code IN VARCHAR2,
       p_property_type IN VARCHAR2,
       p_presentation_cntx IN VARCHAR2) IS
  SELECT p.class_name, p.attribute_name, p.property_code, p.property_value
  FROM class_attr_property_cnfg p
  WHERE p.class_name = p_class_name
  AND p.attribute_name = Nvl(p_attribute_name, p.attribute_name)
  AND p.property_code = Nvl(p_property_code, p.property_code)
  AND p.presentation_cntx = p_presentation_cntx
  AND p.property_type = p_property_type
  AND p.owner_cntx = (
        SELECT MAX(owner_cntx)
        FROM class_attr_property_cnfg x
        WHERE p.class_name = x.class_name
        AND p.attribute_name = x.attribute_name
        AND p.property_code = x.property_code
        AND p.presentation_cntx = x.presentation_cntx
  );

CURSOR c_attr_presentation_syntax_max(
       p_class_name IN VARCHAR2,
       p_attribute_name IN VARCHAR2,
       p_property_type IN VARCHAR2,
       p_presentation_cntx IN VARCHAR2) IS
  SELECT class_name, attribute_name, property_type, presentation_cntx,
       CASE WHEN p_property_type = 'STATIC_PRESENTATION' THEN 
                 LISTAGG(property_code||'='||property_value, ';') WITHIN GROUP (ORDER BY property_code) 
            WHEN p_property_type = 'DYNAMIC_PRESENTATION' THEN 
                 LISTAGG(chr(39)||property_code||'='||chr(39)||'||'||property_value, '|| '';'' ||') WITHIN GROUP (ORDER BY property_code) 
       END AS presentation_syntax       
  FROM (
    SELECT x.*, p.property_value FROM (
      SELECT class_name, attribute_name, property_type, presentation_cntx, property_code, max(owner_cntx) AS owner_cntx, count(*)
      FROM class_attr_property_cnfg
      GROUP BY class_name, attribute_name, property_type, presentation_cntx, property_code
    ) x
    INNER JOIN class_attr_property_cnfg p ON p.class_name = x.class_name
                                         AND p.attribute_name = x.attribute_name
                                         AND p.presentation_cntx = x.presentation_cntx
                                         AND p.property_code = x.property_code
                                         AND p.property_type = x.property_type
    WHERE p.class_name = p_class_name
    AND   p.attribute_name = p_attribute_name
    AND   p.property_type = p_property_type
    AND   p.presentation_cntx = p_presentation_cntx
    AND   p.property_code<>AP_PRESENTATION_SYNTAX
  )
  GROUP BY class_name, attribute_name, property_type, presentation_cntx;

CURSOR c_rel_presentation_syntax_max(
       p_from_class_name IN VARCHAR2,
       p_to_class_name IN VARCHAR2,
       p_role_name IN VARCHAR2,
       p_property_type IN VARCHAR2,
       p_presentation_cntx IN VARCHAR2) IS
  SELECT from_class_name, to_class_name, role_name, property_type, presentation_cntx,
         CASE WHEN p_property_type = 'STATIC_PRESENTATION' THEN 
                   LISTAGG(property_code||'='||property_value, ';') WITHIN GROUP (ORDER BY property_code)
              WHEN p_property_type = 'DYNAMIC_PRESENTATION' THEN 
                   LISTAGG(chr(39)||property_code||'='||chr(39)||'||'||property_value, '|| '';'' ||') WITHIN GROUP (ORDER BY property_code) 
         END AS presentation_syntax       
  FROM (
    SELECT x.*, p.property_value FROM (
      SELECT from_class_name, to_class_name, role_name, property_type, presentation_cntx, property_code, max(owner_cntx) AS owner_cntx, count(*)
      FROM class_rel_property_cnfg
      GROUP BY from_class_name, to_class_name, role_name, property_type, presentation_cntx, property_code
    ) x
    INNER JOIN class_rel_property_cnfg p ON p.from_class_name = x.from_class_name
                                        AND p.to_class_name = x.to_class_name
                                        AND p.role_name = x.role_name
                                        AND p.presentation_cntx = x.presentation_cntx
                                        AND p.property_code = x.property_code
                                        AND p.property_type = x.property_type
    WHERE p.from_class_name = p_from_class_name
    AND   p.to_class_name = p_to_class_name
    AND   p.role_name = p_role_name
    AND   p.property_type = p_property_type
    AND   p.presentation_cntx = p_presentation_cntx
    AND   p.property_code<>RP_PRESENTATION_SYNTAX
  )
  GROUP BY from_class_name, to_class_name, role_name, property_type, presentation_cntx;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : SetClassAttrProperty
-- Description    : Updates or inserts into class_attr_property_cnfg
--                  This procedure should only be used by more specific procedures in this package
--
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CLASS_ATTR_PROPERTY_CNFG
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE SetClassAttrProperty(
    p_class_name VARCHAR2,
    p_attribute_name VARCHAR2,
    p_presentation_cntx VARCHAR2,
    p_owner_cntx  NUMBER,
    p_property_type VARCHAR2,
    p_property_code VARCHAR2,
    p_property_value VARCHAR2)
--</EC-DOC>
IS
 HASENTRY NUMBER;
BEGIN

  -- TODO: Should NULL mean all pres cntx? What about when it is not existing for owner context
SELECT COUNT(*)
    INTO HASENTRY
    FROM USER_TRIGGERS
   WHERE TRIGGER_NAME = 'IU_CLASS_ATTR_PROPERTY_CNFG';
   
   IF HASENTRY > 0 THEN
    EXECUTE IMMEDIATE 'ALTER TRIGGER IU_CLASS_ATTR_PROPERTY_CNFG DISABLE';
  END IF;
  
  UPDATE class_attr_property_cnfg
    SET
      property_value = p_property_value
    WHERE class_name = p_class_name
      AND attribute_name = p_attribute_name
      AND presentation_cntx = p_presentation_cntx
      AND owner_cntx = p_owner_cntx
      AND property_type = p_property_type
      AND property_code = p_property_code;

	  IF HASENTRY > 0 THEN
    EXECUTE IMMEDIATE 'ALTER TRIGGER IU_CLASS_ATTR_PROPERTY_CNFG ENABLE';
  END IF;
  
  INSERT INTO class_attr_property_cnfg (class_name, attribute_name, presentation_cntx, owner_cntx, property_type, property_code, property_value)
  SELECT p_class_name, p_attribute_name, p_presentation_cntx, p_owner_cntx, p_property_type, p_property_code, p_property_value
  FROM DUAL
  WHERE NOT EXISTS(
    SELECT 'X'
      FROM class_attr_property_cnfg
      WHERE class_name = p_class_name
        AND attribute_name = p_attribute_name
        AND presentation_cntx = p_presentation_cntx
        AND owner_cntx = p_owner_cntx
        AND property_type = p_property_type
        AND property_code = p_property_code
    );
EXCEPTION
WHEN OTHERS THEN 	
	IF HASENTRY > 0 THEN 
        EXECUTE IMMEDIATE 'ALTER TRIGGER IU_CLASS_ATTR_PROPERTY_CNFG ENABLE';
    END IF;    
        raise_application_error(-20000,'ERROR: Some Other fatal error occured :- '||SQLERRM);
END SetClassAttrProperty;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : SetClassRelProperty
-- Description    : Updates or inserts into class_rel_property_cnfg
--                  This procedure should only be used by more specific procedures in this package
--
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CLASS_REL_PROPERTY_CNFG
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE SetClassRelProperty(
    p_from_class_name VARCHAR2,
    p_to_class_name VARCHAR2,
    p_role_name VARCHAR2,
    p_presentation_cntx VARCHAR2,
    p_owner_cntx  NUMBER,
    p_property_type VARCHAR2,
    p_property_code VARCHAR2,
    p_property_value VARCHAR2)
--</EC-DOC>
IS
HASENTRY NUMBER;
BEGIN
SELECT COUNT(*)
    INTO HASENTRY
    FROM USER_TRIGGERS
   WHERE TRIGGER_NAME = 'IU_CLAS_REL_PROPERTY_CNFG';
  IF HASENTRY > 0 THEN
    EXECUTE IMMEDIATE 'ALTER TRIGGER IU_CLAS_REL_PROPERTY_CNFG DISABLE';
  END IF;
  
  UPDATE  class_rel_property_cnfg
    SET   property_value = p_property_value
    WHERE from_class_name = p_from_class_name
      AND to_class_name = p_to_class_name
      AND role_name = p_role_name
      AND presentation_cntx = p_presentation_cntx
      AND owner_cntx = p_owner_cntx
      AND property_type = p_property_type
      AND property_code = p_property_code;

  IF SQL%ROWCOUNT < 1 THEN
     INSERT INTO class_rel_property_cnfg (from_class_name, to_class_name, role_name, presentation_cntx, owner_cntx, property_type, property_code, property_value)
     VALUES (p_from_class_name, p_to_class_name, p_role_name, p_presentation_cntx, p_owner_cntx, p_property_type, p_property_code, p_property_value);
  END IF;
  
   IF HASENTRY > 0 THEN
    EXECUTE IMMEDIATE 'ALTER TRIGGER IU_CLAS_REL_PROPERTY_CNFG ENABLE';
  END IF;
EXCEPTION
WHEN OTHERS THEN 	
	IF HASENTRY > 0 THEN 
        EXECUTE IMMEDIATE 'ALTER TRIGGER IU_CLAS_REL_PROPERTY_CNFG ENABLE';
    END IF;    
        raise_application_error(-20000,'ERROR: Some Other fatal error occured :- '||SQLERRM);
END SetClassRelProperty;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : SetClassAttrDisabledInd
-- Description    : Updates or inserts the disabled indicator for a class.
--
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CLASS_ATTR_PROPERTY_CNFG
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE SetClassAttrDisabledInd(
    p_class_name VARCHAR2,
    p_attribute_name VARCHAR2,
    p_presentation_cntx VARCHAR2, -- Should NULL mean all pres cntx? What about when it is not existing for owner context
    p_owner_cntx  NUMBER,
    p_property_value VARCHAR2)
--</EC-DOC>
IS
BEGIN
  SetClassAttrProperty(p_class_name, p_attribute_name, p_presentation_cntx, p_owner_cntx, 'VIEWLAYER', 'DISABLED_IND', p_property_value);
END SetClassAttrDisabledInd;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : SetClassRelDisabledInd
-- Description    : Updates or inserts the disabled indicator for a class relation.
--
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CLASS_REL_PROPERTY_CNFG
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE SetClassRelDisabledInd(
    p_from_class_name VARCHAR2,
    p_to_class_name VARCHAR2,
    p_role_name VARCHAR2,
    p_presentation_cntx VARCHAR2,
    p_owner_cntx  NUMBER,
    p_property_value VARCHAR2)
--</EC-DOC>
IS
BEGIN
  SetClassRelProperty(p_from_class_name, p_to_class_name, p_role_name, p_presentation_cntx, p_owner_cntx, 'VIEWLAYER', 'DISABLED_IND', p_property_value);
END SetClassRelDisabledInd;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : AssertValidProperty
-- Description    : Raises exception if the given property value is not valid for the given table.
--
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : CLASS_PROPERTY_CNFG,
--                  CLASS_ATTR_PROPERTY_CNFG,
--                  CLASS_REL_PROPERTY_CNFG,
--                  CLASS_TRA_PROPERTY_CNFG
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE AssertValidProperty(
    p_property_table_name VARCHAR2,
    p_property_type VARCHAR2,
    p_property_code VARCHAR2,
    p_property_value VARCHAR2)
--</EC-DOC>
IS
  CURSOR c_property_codes(cp_property_table_name VARCHAR2, cp_property_type VARCHAR2, cp_property_code VARCHAR2) IS
    SELECT property_table_name, property_type, property_code, data_type
    FROM   class_property_codes
    WHERE  property_table_name = upper(cp_property_table_name)
    AND    property_type = upper(cp_property_type)
    AND    property_code = cp_property_code;

  ln_number NUMBER;
BEGIN
  IF p_property_table_name IS NULL THEN
    RAISE_APPLICATION_ERROR(-20103, 'Invalid call to EcDp_ClassMeta_cnfg.AssertValidProperty(...) - property_table_name is null.');
  END IF;
  IF p_property_code IS NULL THEN
    RAISE_APPLICATION_ERROR(-20103, 'Invalid call to EcDp_ClassMeta_cnfg.AssertValidProperty(...) - property_code is null.');
  END IF;
  IF p_property_type IS NULL THEN
    RAISE_APPLICATION_ERROR(-20103, 'Invalid call to EcDp_ClassMeta_cnfg.AssertValidProperty(...) - property_type is null.');
  END IF;

  FOR cur IN c_property_codes(p_property_table_name, p_property_type, p_property_code) LOOP
    IF cur.data_type = 'NUMBER' AND p_property_value IS NOT NULL THEN
      BEGIN
         ln_number := TO_NUMBER(p_property_value);
      EXCEPTION
      WHEN VALUE_ERROR THEN
        RAISE_APPLICATION_ERROR(
          -20103,
          'Expected a numeric value for '||p_property_table_name||' with '||
          'property_type="'||p_property_type||'" and '||
          'property_code="'||p_property_code||'" (property_value="'||p_property_value||'"). ');
      END;
    END IF;
    IF cur.data_type = 'BOOLEAN' AND p_property_value IS NOT NULL THEN
      IF p_property_type = 'STATIC_PRESENTATION' AND p_property_value NOT IN ('true', 'false') THEN
        RAISE_APPLICATION_ERROR(
          -20103,
          'Expected a value of "true" or "false" for '||p_property_table_name||' with '||
          'property_type="'||p_property_type||'" and '||
          'property_code="'||p_property_code||'" (property_value="'||p_property_value||'"). ');
      END IF;
      IF p_property_type IN ('VIEWLAYER', 'APPLICATION') AND p_property_value NOT IN ('Y', 'N') THEN
        RAISE_APPLICATION_ERROR(
          -20103,
          'Expected a value of "Y" or "N" for '||p_property_table_name||' with '||
          'property_type="'||p_property_type||'" and '||
          'property_code="'||p_property_code||'" (property_value="'||p_property_value||'"). ');
      END IF;
    END IF;
    RETURN;
  END LOOP;

  -- TODO: Should we rely on constraints in the property cnfg tables instead?
  --
  RAISE_APPLICATION_ERROR(
          -20103,
          'No class_property_codes where '||
          'property_table_name='||CHR(39)||p_property_table_name||CHR(39)||' and '||
          'property_type='||CHR(39)||p_property_type||CHR(39)||' and '||
          'property_code='||CHR(39)||p_property_code||CHR(39)||'.');
END AssertValidProperty;

FUNCTION getClassViewName(p_class_name IN VARCHAR2, p_class_type IN VARCHAR2) RETURN VARCHAR2
IS
  lv2_pfx VARCHAR2(32);
BEGIN
  lv2_pfx := CASE p_class_type
               WHEN 'OBJECT' THEN 'OV_'
               WHEN 'DATA' THEN 'DV_'
               WHEN 'SUB_CLASS' THEN 'OSV_'
               WHEN 'INTERFACE' THEN 'IV_'
               WHEN 'TABLE' THEN 'TV_'
               ELSE NULL
             END;
  IF lv2_pfx IS NOT NULL THEN
    RETURN lv2_pfx||p_class_name;
  END IF;
  RAISE_APPLICATION_ERROR(-20104, 'Unknown class_type '||p_class_type||' for class_name '||p_class_name||'.');
END getClassViewName;

PROCEDURE flushCache
IS
BEGIN
  VL_CLASS_PROPERTY_CACHE.DELETE;
  VL_ATTR_PROPERTY_CACHE.DELETE;
  VL_REL_PROPERTY_CACHE.DELETE;
  VL_TRA_PROPERTY_CACHE.DELETE;
  AP_CLASS_PROPERTY_CACHE.DELETE;
  AP_ATTR_PROPERTY_CACHE.DELETE;
  AP_REL_PROPERTY_CACHE.DELETE;
  AP_TRA_PROPERTY_CACHE.DELETE;
END flushCache;

FUNCTION getCacheSize(p_cache IN PropertyValueCache1_t)
RETURN NUMBER
IS
  ln_size NUMBER := 0;
  ln_idx VARCHAR2(250);
BEGIN
  ln_idx := p_cache.FIRST;
  WHILE (ln_idx IS NOT NULL)
  LOOP
    ln_size := ln_size + LENGTH(ln_idx) + LENGTH(Nvl(p_cache(ln_idx), 0));
    ln_idx := p_cache.NEXT(ln_idx);
  END LOOP;
  RETURN ln_size;
END getCacheSize;

FUNCTION getCacheSize(p_cache IN PropertyValueCache2_t)
RETURN NUMBER
IS
  ln_size NUMBER := 0;
  ln_idx VARCHAR2(250);
BEGIN
  ln_idx := p_cache.FIRST;
  WHILE (ln_idx IS NOT NULL)
  LOOP
    ln_size := ln_size + LENGTH(ln_idx) + getCacheSize(p_cache(ln_idx));
    ln_idx := p_cache.NEXT(ln_idx);
  END LOOP;
  RETURN ln_size;
END getCacheSize;

FUNCTION getCacheSize(p_cache IN PropertyValueCache3_t)
RETURN NUMBER
IS
  ln_size NUMBER := 0;
  ln_idx VARCHAR2(250);
BEGIN
  ln_idx := p_cache.FIRST;
  WHILE (ln_idx IS NOT NULL)
  LOOP
    ln_size := ln_size + LENGTH(ln_idx) + getCacheSize(p_cache(ln_idx));
    ln_idx := p_cache.NEXT(ln_idx);
  END LOOP;
  RETURN ln_size;
END getCacheSize;

FUNCTION getCacheSize(p_cache IN PropertyValueCache4_t)
RETURN NUMBER
IS
  ln_size NUMBER := 0;
  ln_idx VARCHAR2(250);
BEGIN
  ln_idx := p_cache.FIRST;
  WHILE (ln_idx IS NOT NULL)
  LOOP
    ln_size := ln_size + LENGTH(ln_idx) + getCacheSize(p_cache(ln_idx));
    ln_idx := p_cache.NEXT(ln_idx);
  END LOOP;
  RETURN ln_size;
END getCacheSize;

FUNCTION getCacheSize(p_cache IN PropertyValueCache5_t)
RETURN NUMBER
IS
  ln_size NUMBER := 0;
  ln_idx VARCHAR2(250);
BEGIN
  ln_idx := p_cache.FIRST;
  WHILE (ln_idx IS NOT NULL)
  LOOP
    ln_size := ln_size + LENGTH(ln_idx) + getCacheSize(p_cache(ln_idx));
    ln_idx := p_cache.NEXT(ln_idx);
  END LOOP;
  RETURN ln_size;
END getCacheSize;

FUNCTION getCacheSize
RETURN NUMBER
IS
BEGIN
  RETURN getCacheSize(VL_CLASS_PROPERTY_CACHE)
       + getCacheSize(VL_ATTR_PROPERTY_CACHE)
       + getCacheSize(VL_REL_PROPERTY_CACHE)
       + getCacheSize(VL_TRA_PROPERTY_CACHE)
       + getCacheSize(AP_CLASS_PROPERTY_CACHE)
       + getCacheSize(AP_ATTR_PROPERTY_CACHE)
       + getCacheSize(AP_REL_PROPERTY_CACHE)
       + getCacheSize(AP_TRA_PROPERTY_CACHE);

END getCacheSize;

---------------------------------------------------------------------------------------------------
-- Function       : cacheClass *** INTERNAL ***
-- Description    : Cache all VIEWLAYER propertes for the given class to improve performance
---------------------------------------------------------------------------------------------------
PROCEDURE cacheClassProperties(p_class_name IN VARCHAR2)
IS
BEGIN
  IF VL_CLASS_PROPERTY_CACHE.COUNT > 0 AND VL_CLASS_PROPERTY_CACHE.FIRST <> p_class_name THEN
    flushCache;
  END IF;
  IF VL_CLASS_PROPERTY_CACHE.COUNT = 0 THEN
    VL_CLASS_PROPERTY_CACHE(p_class_name)('__FLAG__') := 'Y';

    FOR cur IN c_class_property_max(p_class_name, NULL, 'VIEWLAYER', '/EC') LOOP
      VL_CLASS_PROPERTY_CACHE(cur.class_name)(cur.property_code) := cur.property_value;
    END LOOP;

    FOR cur IN c_class_property_max(p_class_name, NULL, 'APPLICATION', '/EC') LOOP
      AP_CLASS_PROPERTY_CACHE(cur.class_name)(cur.property_code) := cur.property_value;
    END LOOP;

    FOR cur IN c_class_attr_property_max(p_class_name, NULL, NULL, 'VIEWLAYER', '/EC') LOOP
      VL_ATTR_PROPERTY_CACHE(cur.class_name)(cur.attribute_name)(cur.property_code) := cur.property_value;
    END LOOP;

    FOR cur IN c_class_attr_property_max(p_class_name, NULL, NULL, 'APPLICATION', '/EC') LOOP
      AP_ATTR_PROPERTY_CACHE(cur.class_name)(cur.attribute_name)(cur.property_code) := cur.property_value;
    END LOOP;

    FOR cur IN c_class_rel_property_max(NULL, p_class_name, NULL, NULL, 'VIEWLAYER', '/EC') LOOP
      VL_REL_PROPERTY_CACHE(cur.from_class_name)(cur.to_class_name)(cur.role_name)(cur.property_code) := cur.property_value;
    END LOOP;

    FOR cur IN c_class_rel_property_max(NULL, p_class_name, NULL, NULL, 'APPLICATION', '/EC') LOOP
      AP_REL_PROPERTY_CACHE(cur.from_class_name)(cur.to_class_name)(cur.role_name)(cur.property_code) := cur.property_value;
    END LOOP;

    FOR cur IN c_class_tra_property_max(p_class_name, NULL, NULL, NULL, 'VIEWLAYER', '/EC') LOOP
      VL_TRA_PROPERTY_CACHE(cur.class_name)(cur.triggering_event)(cur.trigger_type)(cur.sort_order)(cur.property_code) := cur.property_value;
    END LOOP;

    FOR cur IN c_class_tra_property_max(p_class_name, NULL, NULL, NULL, 'APPLICATION', '/EC') LOOP
      AP_TRA_PROPERTY_CACHE(cur.class_name)(cur.triggering_event)(cur.trigger_type)(cur.sort_order)(cur.property_code) := cur.property_value;
    END LOOP;
  END IF;
END cacheClassProperties;

---------------------------------------------------------------------------------------------------
-- Function       : getMaxViewlayerProperty *** INTERNAL ***
-- Description    : Return property_value with the highest owner_cntx for the given and VIEWLAYER
--                  trigger action property_code
---------------------------------------------------------------------------------------------------
FUNCTION getMaxViewlayerProperty(p_class_name IN VARCHAR2, p_triggering_event IN VARCHAR2, p_trigger_type IN VARCHAR2, p_sort_order IN NUMBER, p_property_code IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
  IF p_class_name IS NOT NULL AND p_triggering_event IS NOT NULL AND p_trigger_type IS NOT NULL AND p_sort_order IS NOT NULL THEN
    IF VL_TRA_PROPERTY_CACHE.EXISTS(p_class_name) AND
       VL_TRA_PROPERTY_CACHE(p_class_name).EXISTS(p_triggering_event) AND
       VL_TRA_PROPERTY_CACHE(p_class_name)(p_triggering_event).EXISTS(p_trigger_type) AND
       VL_TRA_PROPERTY_CACHE(p_class_name)(p_triggering_event)(p_trigger_type).EXISTS(p_sort_order) AND
       VL_TRA_PROPERTY_CACHE(p_class_name)(p_triggering_event)(p_trigger_type)(p_sort_order).EXISTS(p_property_code) THEN
      RETURN VL_TRA_PROPERTY_CACHE(p_class_name)(p_triggering_event)(p_trigger_type)(p_sort_order)(p_property_code);
    END IF;

    IF Nvl(CACHING_MODE, 'NONE') = 'SESSION' THEN
     VL_TRA_PROPERTY_CACHE(p_class_name)(p_triggering_event)(p_trigger_type)(p_sort_order)(p_property_code) := NULL;
    END IF;

    FOR cur IN c_class_tra_property_max(p_class_name, p_triggering_event, p_trigger_type, p_sort_order, p_property_code, 'VIEWLAYER') LOOP
      IF Nvl(CACHING_MODE, 'NONE') != 'NONE' THEN
        VL_TRA_PROPERTY_CACHE(p_class_name)(p_triggering_event)(p_trigger_type)(p_sort_order)(p_property_code) := cur.property_value;
      END IF;
      RETURN cur.property_value;
    END LOOP;
  END IF;

  RETURN NULL;
END getMaxViewlayerProperty;

---------------------------------------------------------------------------------------------------
-- Function       : getMaxViewlayerProperty *** INTERNAL ***
-- Description    : Return property_value with the highest owner_cntx for the given and VIEWLAYER
--                  relation property_code
---------------------------------------------------------------------------------------------------
FUNCTION getMaxViewlayerProperty(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2, p_property_code IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
  IF p_from_class_name IS NOT NULL AND p_to_class_name IS NOT NULL AND p_role_name IS NOT NULL THEN
    IF VL_REL_PROPERTY_CACHE.EXISTS(p_from_class_name) AND
       VL_REL_PROPERTY_CACHE(p_from_class_name).EXISTS(p_to_class_name) AND
       VL_REL_PROPERTY_CACHE(p_from_class_name)(p_to_class_name).EXISTS(p_role_name) AND
       VL_REL_PROPERTY_CACHE(p_from_class_name)(p_to_class_name)(p_role_name).EXISTS(p_property_code) THEN
      RETURN VL_REL_PROPERTY_CACHE(p_from_class_name)(p_to_class_name)(p_role_name)(p_property_code);
    END IF;

    IF Nvl(CACHING_MODE, 'NONE') = 'SESSION' THEN
      VL_REL_PROPERTY_CACHE(p_from_class_name)(p_to_class_name)(p_role_name)(p_property_code) := NULL;
    END IF;

    FOR cur IN c_class_rel_property_max(p_from_class_name, p_to_class_name, p_role_name, p_property_code, 'VIEWLAYER', '/EC') LOOP
      IF Nvl(CACHING_MODE, 'NONE') != 'NONE' THEN
        VL_REL_PROPERTY_CACHE(p_from_class_name)(p_to_class_name)(p_role_name)(p_property_code) := cur.property_value;
      END IF;
      RETURN cur.property_value;
    END LOOP;
  END IF;

  RETURN NULL;
END getMaxViewlayerProperty;

---------------------------------------------------------------------------------------------------
-- Function       : getMaxViewlayerProperty *** INTERNAL ***
-- Description    : Return property_value with the highest owner_cntx for the given and VIEWLAYER
--                  attribute property_code
---------------------------------------------------------------------------------------------------
FUNCTION getMaxViewlayerProperty(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2, p_property_code IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
  IF p_class_name IS NOT NULL AND p_attribute_name IS NOT NULL THEN
    IF VL_ATTR_PROPERTY_CACHE.EXISTS(p_class_name) AND
       VL_ATTR_PROPERTY_CACHE(p_class_name).EXISTS(p_attribute_name) AND
       VL_ATTR_PROPERTY_CACHE(p_class_name)(p_attribute_name).EXISTS(p_property_code) THEN
      RETURN VL_ATTR_PROPERTY_CACHE(p_class_name)(p_attribute_name)(p_property_code);
    END IF;

    IF Nvl(CACHING_MODE, 'NONE') = 'SESSION' THEN
      VL_ATTR_PROPERTY_CACHE(p_class_name)(p_attribute_name)(p_property_code) := NULL;
    END IF;

    FOR cur IN c_class_attr_property_max(p_class_name, p_attribute_name, p_property_code, 'VIEWLAYER', '/EC') LOOP
      IF Nvl(CACHING_MODE, 'NONE') != 'NONE' THEN
        VL_ATTR_PROPERTY_CACHE(p_class_name)(p_attribute_name)(p_property_code) := cur.property_value;
      END IF;
      RETURN cur.property_value;
    END LOOP;
  END IF;

  RETURN NULL;
END getMaxViewlayerProperty;

---------------------------------------------------------------------------------------------------
-- Function       : getMaxViewlayerProperty *** INTERNAL ***
-- Description    : Return property_value with the highest owner_cntx for the given and VIEWLAYER
--                  attribute property_code
---------------------------------------------------------------------------------------------------
FUNCTION getMaxStaticPresProperty(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2, p_property_code IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
  FOR cur IN c_class_attr_property_max(p_class_name, p_attribute_name, p_property_code, 'STATIC_PRESENTATION', '/EC') LOOP
    RETURN cur.property_value;
  END LOOP;
  RETURN NULL;
END getMaxStaticPresProperty;


---------------------------------------------------------------------------------------------------
-- Function       : getMaxViewlayerProperty *** INTERNAL ***
-- Description    : Return property_value with the highest owner_cntx for the given and VIEWLAYER
--                  relation property_code
---------------------------------------------------------------------------------------------------
FUNCTION getMaxStaticPresProperty(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2, p_property_code IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
  FOR cur IN c_class_rel_property_max(p_from_class_name, p_to_class_name, p_role_name, p_property_code, 'STATIC_PRESENTATION', '/EC') LOOP
    RETURN cur.property_value;
  END LOOP;
  RETURN NULL;
END getMaxStaticPresProperty;

---------------------------------------------------------------------------------------------------
-- Function       : getMaxViewlayerProperty *** INTERNAL ***
-- Description    : Return property_value with the highest owner_cntx for the given and VIEWLAYER
--                  class property_code
---------------------------------------------------------------------------------------------------
FUNCTION getMaxViewlayerProperty(p_class_name IN VARCHAR2, p_property_code IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
  IF p_class_name IS NOT NULL THEN
    IF VL_CLASS_PROPERTY_CACHE.EXISTS(p_class_name) AND
       VL_CLASS_PROPERTY_CACHE(p_class_name).EXISTS(p_property_code) THEN
      RETURN VL_CLASS_PROPERTY_CACHE(p_class_name)(p_property_code);
    END IF;

    IF Nvl(CACHING_MODE, 'NONE') = 'SESSION' THEN
      VL_CLASS_PROPERTY_CACHE(p_class_name)(p_property_code) := NULL;
    END IF;

    FOR cur IN c_class_property_max(p_class_name, p_property_code, 'VIEWLAYER', '/EC') LOOP
      IF Nvl(CACHING_MODE, 'NONE') != 'NONE' THEN
        VL_CLASS_PROPERTY_CACHE(p_class_name)(p_property_code) := cur.property_value;
      END IF;
      RETURN cur.property_value;
    END LOOP;
  END IF;

  RETURN NULL;
END getMaxViewlayerProperty;

---------------------------------------------------------------------------------------------------
-- Function       : getMaxApplicationProperty *** INTERNAL ***
-- Description    : Return property_value with the highest owner_cntx for the given and APPLICATION
--                  relation property_code
---------------------------------------------------------------------------------------------------
FUNCTION getMaxApplicationProperty(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2, p_property_code IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
  IF p_from_class_name IS NOT NULL AND p_to_class_name IS NOT NULL AND p_role_name IS NOT NULL THEN
    IF AP_REL_PROPERTY_CACHE.EXISTS(p_from_class_name) AND
       AP_REL_PROPERTY_CACHE(p_from_class_name).EXISTS(p_to_class_name) AND
       AP_REL_PROPERTY_CACHE(p_from_class_name)(p_to_class_name).EXISTS(p_role_name) AND
       AP_REL_PROPERTY_CACHE(p_from_class_name)(p_to_class_name)(p_role_name).EXISTS(p_property_code) THEN
      RETURN AP_REL_PROPERTY_CACHE(p_from_class_name)(p_to_class_name)(p_role_name)(p_property_code);
    END IF;

    IF Nvl(CACHING_MODE, 'NONE') = 'SESSION' THEN
      AP_REL_PROPERTY_CACHE(p_from_class_name)(p_to_class_name)(p_role_name)(p_property_code) := NULL;
    END IF;

    FOR cur IN c_class_rel_property_max(p_from_class_name, p_to_class_name, p_role_name, p_property_code, 'APPLICATION', '/EC') LOOP
      IF Nvl(CACHING_MODE, 'NONE') != 'NONE' THEN
        AP_REL_PROPERTY_CACHE(p_from_class_name)(p_to_class_name)(p_role_name)(p_property_code) := cur.property_value;
      END IF;
      RETURN cur.property_value;
    END LOOP;
  END IF;

  RETURN NULL;
END getMaxApplicationProperty;

---------------------------------------------------------------------------------------------------
-- Function       : getMaxApplicationProperty *** INTERNAL ***
-- Description    : Return property_value with the highest owner_cntx for the given and APPLICATION
--                  attribute property_code
---------------------------------------------------------------------------------------------------
FUNCTION getMaxApplicationProperty(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2, p_property_code IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
  IF p_class_name IS NOT NULL AND p_attribute_name IS NOT NULL THEN
    IF AP_ATTR_PROPERTY_CACHE.EXISTS(p_class_name) AND
       AP_ATTR_PROPERTY_CACHE(p_class_name).EXISTS(p_attribute_name) AND
       AP_ATTR_PROPERTY_CACHE(p_class_name)(p_attribute_name).EXISTS(p_property_code) THEN
      RETURN AP_ATTR_PROPERTY_CACHE(p_class_name)(p_attribute_name)(p_property_code);
    END IF;

    IF Nvl(CACHING_MODE, 'NONE') = 'SESSION' THEN
      AP_ATTR_PROPERTY_CACHE(p_class_name)(p_attribute_name)(p_property_code) := NULL;
    END IF;

    FOR cur IN c_class_attr_property_max(p_class_name, p_attribute_name, p_property_code, 'APPLICATION', '/EC') LOOP
      IF Nvl(CACHING_MODE, 'NONE') != 'NONE' THEN
        AP_ATTR_PROPERTY_CACHE(p_class_name)(p_attribute_name)(p_property_code) := cur.property_value;
      END IF;
      RETURN cur.property_value;
    END LOOP;
  END IF;

  RETURN NULL;
END getMaxApplicationProperty;

---------------------------------------------------------------------------------------------------
-- Function       : getMaxApplicationProperty *** INTERNAL ***
-- Description    : Return property_value with the highest owner_cntx for the given and APPLICATION
--                  class property_code
---------------------------------------------------------------------------------------------------
FUNCTION getMaxApplicationProperty(p_class_name IN VARCHAR2, p_property_code IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
  IF p_class_name IS NOT NULL THEN
    IF AP_CLASS_PROPERTY_CACHE.EXISTS(p_class_name) AND
       AP_CLASS_PROPERTY_CACHE(p_class_name).EXISTS(p_property_code) THEN
      RETURN AP_CLASS_PROPERTY_CACHE(p_class_name)(p_property_code);
    END IF;

    IF Nvl(CACHING_MODE, 'NONE') = 'SESSION' THEN
      AP_CLASS_PROPERTY_CACHE(p_class_name)(p_property_code) := NULL;
    END IF;

    FOR cur IN c_class_property_max(p_class_name, p_property_code, 'APPLICATION', '/EC') LOOP
      IF Nvl(CACHING_MODE, 'NONE') != 'NONE' THEN
        AP_CLASS_PROPERTY_CACHE(p_class_name)(p_property_code) := cur.property_value;
      END IF;
      RETURN cur.property_value;
    END LOOP;
  END IF;

  RETURN NULL;
END getMaxApplicationProperty;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getClassShortCode
-- Description    : Returns the CLASS_SHORT_CODE property with the highest owner_cntx for the given class.
---------------------------------------------------------------------------------------------------
FUNCTION getClassShortCode(p_class_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN getMaxViewlayerProperty(p_class_name, CP_CLASS_SHORT_CODE);
END getClassShortCode;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isReadOnly
-- Description    : Returns the READ_ONLY_IND property with the highest owner_cntx for the given class.
--                  Defaults to 'N'.
---------------------------------------------------------------------------------------------------
FUNCTION isReadOnly(p_class_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
   RETURN Nvl(getMaxViewlayerProperty(p_class_name, CP_READ_ONLY_IND), 'N');
END isReadOnly;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : skipTriggerCheck
-- Description    : Returns the SKIP_TRG_CHECK_IND property with the highest owner_cntx for the given class.
--                  Defaults to 'N'.
---------------------------------------------------------------------------------------------------
FUNCTION skipTriggerCheck(p_class_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN Nvl(getMaxViewlayerProperty(p_class_name, CP_SKIP_TRG_CHECK_IND), 'N');
END skipTriggerCheck;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getCreateEventInd
-- Description    : Returns the CREATE_EV_IND property with the highest owner_cntx for the given class.
--                  Defaults to 'N'.
---------------------------------------------------------------------------------------------------
FUNCTION getCreateEventInd(p_class_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN Nvl(getMaxViewlayerProperty(p_class_name, CP_CREATE_EV_IND), 'N');
END getCreateEventInd;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getApprovalInd
-- Description    : Returns the APPROVAL_IND property with the highest owner_cntx for the given class.
--                  Defaults to 'N'.
---------------------------------------------------------------------------------------------------
FUNCTION getApprovalInd(p_class_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN Nvl(getMaxViewlayerProperty(p_class_name, CP_APPROVAL_IND), 'N');
END getApprovalInd;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : includeInWebservice
-- Description    : Returns the INCLUDE_WEBSERVICE property with the highest owner_cntx for the given class.
--                  Defaults to 'N'.
---------------------------------------------------------------------------------------------------
FUNCTION includeInWebservice(p_class_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN Nvl(getMaxViewlayerProperty(p_class_name, CP_INCLUDE_WEBSERVICE), 'N');
END includeInWebservice;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : includeInMapping
-- Description    : Returns the INCLUDE_IN_MAPPING_IND property with the highest owner_cntx for the given class.
--                  Defaults to 'Y'.
---------------------------------------------------------------------------------------------------
FUNCTION includeInMapping(p_class_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN Nvl(getMaxViewlayerProperty(p_class_name, CP_INCLUDE_IN_MAPPING_IND), 'Y');
END includeInMapping;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : includeInValidation
-- Description    : Returns the INCLUDE_IN_VALIDATION property with the highest owner_cntx for the given class.
--                  Defaults to 'N'.
---------------------------------------------------------------------------------------------------
FUNCTION includeInValidation(p_class_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN Nvl(getMaxApplicationProperty(p_class_name, CP_INCLUDE_IN_VALIDATION), 'N');
END includeInValidation;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLockInd
-- Description    : Returns the LOCK_IND property with the highest owner_cntx for the given class.
--                  Defaults to 'N'.
---------------------------------------------------------------------------------------------------
FUNCTION getLockInd(p_class_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN Nvl(getMaxViewlayerProperty(p_class_name, CP_LOCK_IND), 'N');
END getLockInd;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLockRule
-- Description    : Returns the LOCK_RULE property with the highest owner_cntx for the given class.
---------------------------------------------------------------------------------------------------
FUNCTION getLockRule(p_class_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN getMaxViewlayerProperty(p_class_name, CP_LOCK_RULE);
END getLockRule;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getEnsureRevTextOnUpdate
-- Description    : Returns the ENSURE_REV_TEXT_ON_UPD property with the highest owner_cntx for the given class.
--                  Defaults to 'N'.
---------------------------------------------------------------------------------------------------
FUNCTION getEnsureRevTextOnUpdate(p_class_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN Nvl(getMaxViewlayerProperty(p_class_name, CP_ENSURE_REV_TEXT_ON_UPD), 'N');
END getEnsureRevTextOnUpdate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getAccessControlInd
-- Description    : Returns the ACCESS_CONTROL_IND property with the highest owner_cntx for the given class.
--                  Defaults to 'N'.
---------------------------------------------------------------------------------------------------
FUNCTION getAccessControlInd(p_class_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN Nvl(getMaxViewlayerProperty(p_class_name, CP_ACCESS_CONTROL_IND), 'N');
END getAccessControlInd;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLabel
-- Description    : Returns the LABEL property with the highest owner_cntx for the given class.
---------------------------------------------------------------------------------------------------
FUNCTION getLabel(p_class_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN getMaxApplicationProperty(p_class_name, CP_LABEL);
END getLabel;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDescription
-- Description    : Returns the DESCRIPTION property with the highest owner_cntx for the given class.
---------------------------------------------------------------------------------------------------
FUNCTION getDescription(p_class_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN getMaxApplicationProperty(p_class_name, CP_DESCRIPTION);
END getDescription;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getScreenSortOrder
-- Description    : Returns the SCREEN_SORT_ORDER property with the highest owner_cntx for the given attribute.
--                  Defaults to 0.
---------------------------------------------------------------------------------------------------
FUNCTION getScreenSortOrder(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS
BEGIN
  RETURN to_number(Nvl(getMaxApplicationProperty(p_class_name, p_attribute_name, AP_SCREEN_SORT_ORDER), '0'));
EXCEPTION
  WHEN VALUE_ERROR THEN
    RAISE_APPLICATION_ERROR(
       -20000,
       AP_SCREEN_SORT_ORDER||' property for class attribute '||p_class_name||'.'||p_attribute_name||' is not a number. '||CHR(10)||SQLERRM);
END getScreenSortOrder;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getScreenSortOrder
-- Description    : Returns the SCREEN_SORT_ORDER property with the highest owner_cntx for the given relation.
--                  Defaults to 0.
---------------------------------------------------------------------------------------------------
FUNCTION getScreenSortOrder(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS
BEGIN
  RETURN to_number(Nvl(getMaxApplicationProperty(p_from_class_name, p_to_class_name, p_role_name, RP_SCREEN_SORT_ORDER), '0'));
EXCEPTION
  WHEN VALUE_ERROR THEN
    RAISE_APPLICATION_ERROR(
       -20000,
       RP_SCREEN_SORT_ORDER||' property for class relation '||p_from_class_name||'.'||p_to_class_name||'.'||p_role_name||' is not a number. '||CHR(10)||SQLERRM);
END getScreenSortOrder;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getJournalRuleDbSyntax
-- Description    : Returns the JOURNAL_RULE_DB_SYNTAX property with the highest owner_cntx for the given class.
---------------------------------------------------------------------------------------------------
FUNCTION getJournalRuleDbSyntax(p_class_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN getMaxViewlayerProperty(p_class_name, CP_JOURNAL_RULE_DB_SYNTAX);
END getJournalRuleDbSyntax;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isReadOnly
-- Description    : Returns the IS_MANDATORY property with the highest owner_cntx for the given attribute.
--                  Defaults to 'N'.
---------------------------------------------------------------------------------------------------
FUNCTION isReadOnly(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN Nvl(getMaxApplicationProperty(p_class_name, p_attribute_name, AP_READ_ONLY_IND), 'N');
END isReadOnly;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDbPresSyntax
-- Description    : Returns the DB_PRES_SYNTAX property with the highest owner_cntx for the given attribute.
---------------------------------------------------------------------------------------------------
FUNCTION getDbPresSyntax(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN getMaxApplicationProperty(p_class_name, p_attribute_name, AP_DB_PRES_SYNTAX);
END getDbPresSyntax;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isMandatory
-- Description    : Returns the IS_MANDATORY property with the highest owner_cntx for the given attribute.
--                  Defaults to 'N'.
---------------------------------------------------------------------------------------------------
FUNCTION isMandatory(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN Nvl(getMaxViewlayerProperty(p_class_name, p_attribute_name, AP_IS_MANDATORY), 'N');
END isMandatory;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDbSortOrder
-- Description    : Returns the DB_SORT_ORDER property with the highest owner_cntx for the given attribute.
--                  Defaults to 0.
---------------------------------------------------------------------------------------------------
FUNCTION getDbSortOrder(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS
BEGIN
  RETURN to_number(Nvl(getMaxViewlayerProperty(p_class_name, p_attribute_name, AP_DB_SORT_ORDER), '0'));
EXCEPTION
  WHEN VALUE_ERROR THEN
    RAISE_APPLICATION_ERROR(
       -20000,
       AP_DB_SORT_ORDER||' property for class attribude '||p_class_name||'.'||p_attribute_name||' is not a number. '||CHR(10)||SQLERRM);
END getDbSortOrder;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getUomCode
-- Description    : Returns the UOM_CODE property with the highest owner_cntx for the given attribute.
---------------------------------------------------------------------------------------------------
FUNCTION getUomCode(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN getMaxViewlayerProperty(p_class_name, p_attribute_name, AP_UOM_CODE);
END getUomCode;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isDisabled
-- Description    : Returns the DISABLED_IND property with the highest owner_cntx for the given attribute.
--                  Defaults to 'N'.
---------------------------------------------------------------------------------------------------
FUNCTION isDisabled(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN Nvl(getMaxViewlayerProperty(p_class_name, p_attribute_name, AP_DISABLED_IND), 'N');
END isDisabled;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getStaticPresentationSyntax
-- Description    : Returns STATIC_PRESENTATION properties with the highest owner_cntx for the given
--                  attribute as comma-separated list of property_code/value pairs. I.e. Same as
--                  pre-11.2 static_presentation_syntax.
---------------------------------------------------------------------------------------------------
FUNCTION getStaticPresentationSyntax(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
  lv2_presentation_syntax VARCHAR2(4000);
BEGIN
  FOR cur IN c_attr_presentation_syntax_max(p_class_name, p_attribute_name, 'STATIC_PRESENTATION', '/EC') LOOP
    lv2_presentation_syntax := cur.presentation_syntax;
    EXIT;
  END LOOP;
  RETURN lv2_presentation_syntax;
END getStaticPresentationSyntax;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDynamicPresentationSyntax
-- Description    : Returns DYNAMIC_PRESENTATION properties with the highest owner_cntx for the given
--                  attribute as comma-separated list of property_code/value pairs. I.e. Same as
--                  pre-11.2 presentation_syntax.
---------------------------------------------------------------------------------------------------
FUNCTION getDynamicPresentationSyntax(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
  lv2_presentation_syntax VARCHAR2(4000);
BEGIN
  FOR cur IN c_class_attr_property_max(p_class_name, p_attribute_name, RP_PRESENTATION_SYNTAX, 'DYNAMIC_PRESENTATION', '/EC') LOOP
    lv2_presentation_syntax := cur.property_value;
    EXIT;
  END LOOP;

  -- TODO: If an attribute has a PresentationSyntax property, should we ignore the individual DYNAMIC_PRESENTATION properties?
  --
  /*
  IF lv2_presentation_syntax IS NOT NULL THEN
    RETURN lv2_presentation_syntax;
  END IF;
  */

  FOR cur IN c_attr_presentation_syntax_max(p_class_name, p_attribute_name, 'DYNAMIC_PRESENTATION', '/EC') LOOP
    IF lv2_presentation_syntax IS NOT NULL THEN
      lv2_presentation_syntax := lv2_presentation_syntax || ';' || cur.presentation_syntax;
    ELSE
      lv2_presentation_syntax := cur.presentation_syntax;
    END IF;
    EXIT;
  END LOOP;
  RETURN lv2_presentation_syntax;
END getDynamicPresentationSyntax;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isReportOnly
-- Description    : Returns the REPORT_ONLY_IND property with the highest owner_cntx for the given relation.
--                  Defaults to 'N'.
---------------------------------------------------------------------------------------------------
FUNCTION isReportOnly(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN Nvl(getMaxViewlayerProperty(p_class_name, p_attribute_name, AP_REPORT_ONLY_IND), 'N');
END isReportOnly;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLabel
-- Description    : Returns the viewlabelhead property with the highest owner_cntx for the given attribute.
---------------------------------------------------------------------------------------------------
FUNCTION getStaticViewlabelhead(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN getMaxStaticPresProperty(p_class_name, p_attribute_name, PP_VIEWLABELHEAD);
END getStaticViewlabelhead;
--FUNCTION getStaticViewhidden(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2) RETURN VARCHAR2;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLabel
-- Description    : Returns the viewhidden property with the highest owner_cntx for the given attribute.
--                  Defaults to 'false'.
---------------------------------------------------------------------------------------------------
FUNCTION getStaticViewhidden(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN Nvl(getMaxStaticPresProperty(p_class_name, p_attribute_name, PP_VIEWLABELHEAD), 'false');
END getStaticViewhidden;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLabel
-- Description    : Returns the LABEL property with the highest owner_cntx for the given attribute.
---------------------------------------------------------------------------------------------------
FUNCTION getLabel(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN getMaxApplicationProperty(p_class_name, p_attribute_name, AP_LABEL);
END getLabel;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDescription
-- Description    : Returns the DESCRIPTION property with the highest owner_cntx for the given attribute.
---------------------------------------------------------------------------------------------------
FUNCTION getDescription(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN getMaxApplicationProperty(p_class_name, p_attribute_name, AP_DESCRIPTION);
END getDescription;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getName
-- Description    : Returns the NAME property with the highest owner_cntx for the given attribute.
---------------------------------------------------------------------------------------------------
FUNCTION getName(p_class_name IN VARCHAR2, p_attribute_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN getMaxApplicationProperty(p_class_name, p_attribute_name, AP_NAME);
END getName;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDbSortOrder
-- Description    : Returns the DB_SORT_ORDER property with the highest owner_cntx for the given relation.
--                  Defaults to 0.
---------------------------------------------------------------------------------------------------
FUNCTION getDbSortOrder(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS
BEGIN
  RETURN to_number(Nvl(getMaxViewlayerProperty(p_from_class_name, p_to_class_name, p_role_name, RP_DB_SORT_ORDER), '0'));
END getDbSortOrder;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getAllocPriority
-- Description    : Returns the ALLOC_PRIORITY property with the highest owner_cntx for the given relation.
---------------------------------------------------------------------------------------------------
FUNCTION getAllocPriority(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS
  lv2_property_value VARCHAR2(4000);
BEGIN
  lv2_property_value := getMaxViewlayerProperty(p_from_class_name, p_to_class_name, p_role_name, RP_ALLOC_PRIORITY);
  RETURN CASE WHEN lv2_property_value IS NULL THEN NULL ELSE to_number(lv2_property_value) END;
END getAllocPriority;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDbPresSyntax
-- Description    : Returns the DB_PRES_SYNTAX property with the highest owner_cntx for the given relation.
---------------------------------------------------------------------------------------------------
FUNCTION getDbPresSyntax(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN getMaxApplicationProperty(p_from_class_name, p_to_class_name, p_role_name, RP_DB_PRES_SYNTAX);
END getDbPresSyntax;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getLabel
-- Description    : Returns the LABEL property with the highest owner_cntx for the given relation.
---------------------------------------------------------------------------------------------------
FUNCTION getLabel(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN getMaxApplicationProperty(p_from_class_name, p_to_class_name, p_role_name, RP_LABEL);
END getLabel;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDescription
-- Description    : Returns the DESCRIPTION property with the highest owner_cntx for the given relation.
---------------------------------------------------------------------------------------------------
FUNCTION getDescription(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN getMaxApplicationProperty(p_from_class_name, p_to_class_name, p_role_name, RP_DESCRIPTION);
END getDescription;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getName
-- Description    : Returns the NAME property with the highest owner_cntx for the given relation.
---------------------------------------------------------------------------------------------------
FUNCTION getName(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN getMaxApplicationProperty(p_from_class_name, p_to_class_name, p_role_name, RP_NAME);
END getName;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getApprovalInd
-- Description    : Returns the APPROVAL_IND property with the highest owner_cntx for the given relation.
--                  Defaults to 'N'.
---------------------------------------------------------------------------------------------------
FUNCTION getApprovalInd(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN Nvl(getMaxViewlayerProperty(p_from_class_name, p_to_class_name, p_role_name, RP_APPROVAL_IND), 'N');
END getApprovalInd;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getReverseApprovalInd
-- Description    : Returns the REVERSE_APPROVAL_IND property with the highest owner_cntx for the given relation.
--                  Defaults to 'N'.
---------------------------------------------------------------------------------------------------
FUNCTION getReverseApprovalInd(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN Nvl(getMaxViewlayerProperty(p_from_class_name, p_to_class_name, p_role_name, RP_REVERSE_APPROVAL_IND), 'N');
END getReverseApprovalInd;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isMandatory
-- Description    : Returns the IS_MANDATORY property with the highest owner_cntx for the given relation.
--                  Defaults to 'N'.
---------------------------------------------------------------------------------------------------
FUNCTION isMandatory(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN Nvl(getMaxViewlayerProperty(p_from_class_name, p_to_class_name, p_role_name, RP_IS_MANDATORY), 'N');
END isMandatory;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getAccessControlMethod
-- Description    : Returns the ACCESS_CONTROL_METHOD property with the highest owner_cntx for the given relation.
---------------------------------------------------------------------------------------------------
FUNCTION getAccessControlMethod(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN getMaxViewlayerProperty(p_from_class_name, p_to_class_name, p_role_name, RP_ACCESS_CONTROL_METHOD);
END getAccessControlMethod;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isReportOnly
-- Description    : Returns the REPORT_ONLY_IND property with the highest owner_cntx for the given relation.
--                  Defaults to 'N'.
---------------------------------------------------------------------------------------------------
FUNCTION isReportOnly(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN Nvl(getMaxViewlayerProperty(p_from_class_name, p_to_class_name, p_role_name, RP_REPORT_ONLY_IND), 'N');
END isReportOnly;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isDisabled
-- Description    : Returns the DISABLED_IND property with the highest owner_cntx for the given relation.
--                  Defaults to 'N'.
---------------------------------------------------------------------------------------------------
FUNCTION isDisabled(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN Nvl(getMaxViewlayerProperty(p_from_class_name, p_to_class_name, p_role_name, RP_DISABLED_IND), 'N');
END isDisabled;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getStaticPresentationSyntax
-- Description    : Returns STATIC_PRESENTATION properties with the highest owner_cntx for the given
--                  relation as comma-separated list of property_code/value pairs. I.e. Same as
--                  pre-11.2 static_presentation_syntax.
---------------------------------------------------------------------------------------------------
FUNCTION getStaticPresentationSyntax(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
  lv2_presentation_syntax VARCHAR2(4000);
BEGIN
  FOR cur IN c_rel_presentation_syntax_max(p_from_class_name, p_to_class_name, p_role_name, 'STATIC_PRESENTATION', '/EC') LOOP
    lv2_presentation_syntax := cur.presentation_syntax;
    EXIT;
  END LOOP;
  RETURN lv2_presentation_syntax;
END getStaticPresentationSyntax;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDynamicPresentationSyntax
-- Description    : Returns DYNAMIC_PRESENTATION properties with the highest owner_cntx for the given
--                  relation as comma-separated list of property_code/value pairs. I.e. Same as
--                  pre-11.2 presentation_syntax.
---------------------------------------------------------------------------------------------------
FUNCTION getDynamicPresentationSyntax(p_from_class_name IN VARCHAR2, p_to_class_name IN VARCHAR2, p_role_name IN VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
  lv2_presentation_syntax VARCHAR2(4000);
BEGIN
  FOR cur IN c_class_rel_property_max(p_from_class_name, p_to_class_name, p_role_name, RP_PRESENTATION_SYNTAX, 'DYNAMIC_PRESENTATION', '/EC') LOOP
    lv2_presentation_syntax := cur.property_value;
    EXIT;
  END LOOP;

  -- TODO: If a relation has a PresentationSyntax property, should individual DYNAMIC_PRESENTATION properties be ignored?
  --
  /*
  IF lv2_presentation_syntax IS NOT NULL THEN
    RETURN lv2_presentation_syntax;
  END IF;
  */

  FOR cur IN c_rel_presentation_syntax_max(p_from_class_name, p_to_class_name, p_role_name, 'DYNAMIC_PRESENTATION', '/EC') LOOP
    IF lv2_presentation_syntax IS NOT NULL THEN
      lv2_presentation_syntax := lv2_presentation_syntax || ';' || cur.presentation_syntax;
    ELSE
      lv2_presentation_syntax := cur.presentation_syntax;
    END IF;
    EXIT;
  END LOOP;
  RETURN lv2_presentation_syntax;
END getDynamicPresentationSyntax;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : isDisabled
-- Description    : Returns the DISABLED_IND property with the highest owner_cntx for the given trigger action.
--                  Defaults to 'N'.
---------------------------------------------------------------------------------------------------
FUNCTION isDisabled(p_class_name IN VARCHAR2, p_triggering_event IN VARCHAR2, p_trigger_type IN VARCHAR2, p_sort_order IN NUMBER)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN Nvl(getMaxViewlayerProperty(p_class_name, p_triggering_event, p_trigger_type, p_sort_order, TP_DISABLED_IND), 'N');
END isDisabled;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getDescription
-- Description    : Returns the DESCRIPTION property with the highest owner_cntx for the given trigger action.
---------------------------------------------------------------------------------------------------
FUNCTION getDescription(p_class_name IN VARCHAR2, p_triggering_event IN VARCHAR2, p_trigger_type IN VARCHAR2, p_sort_order IN NUMBER)
RETURN VARCHAR2
--</EC-DOC>
IS
BEGIN
  RETURN getMaxViewlayerProperty(p_class_name, p_triggering_event, p_trigger_type, p_sort_order, TP_DESCRIPTION);
END getDescription;

END EcDp_ClassMeta_cnfg;
--~^UTDELIM^~--

DECLARE 
 	 column_exists exception;  
 	 pragma exception_init (column_exists , -01430);  
	 sqlQuery clob:='ALTER TABLE ctrl_object ADD pinc_trigger_ind VARCHAR2(1)';
BEGIN 
	 EXECUTE IMMEDIATE sqlQuery; 
	 dbms_output.put_line('SUCCESS: ' || sqlQuery); 
	 EXCEPTION 
	 	  when column_exists  then 
  	 	 	 dbms_output.put_line('WARNING: ' || sqlQuery); 
  	 	 	 dbms_output.put_line('ORA-01430: column being added already exists in table'); 
  	 	 WHEN OTHERS THEN 
	 	 	 --UPDATE_MILESTONE_WITH_ERROR('AddTableColumn'); 
	 	 	 raise_application_error(-20000, 'ERROR: Some Other fatal error occured'); 
END;
--~^UTDELIM^~--
--Dropping all AP triggers

BEGIN
    for obj in (SELECT object_name, OBJECT_TYPE FROM user_objects WHERE object_name LIKE 'AP/_%' ESCAPE '/' AND object_type='TRIGGER')
      loop
      EXECUTE IMMEDIATE 'DROP ' || obj.object_type || ' ' || obj.object_name;
    end loop;            
END;
--~^UTDELIM^~--


CREATE OR REPLACE PACKAGE EcDp_Generate IS
/** 
* Generate table triggers and EC packages (replaces the <var>ec_generate</var> package).
 * <br/><br/>
 * This package defines a number of bitmask functions and a single generate procedure. 
 * The bitmasks are used as inputs to the generate procedure to indicate which object
 * types to generate. Bitmasks can be added together to trigger generation of multiple
 * object types. See examples below.
 * <br/><br/>
 * NOTE: Bit mask functions cannot be included/added multiple times in a bit mask expression.
 * @headcom
 */
 
/**
 * Bitmask to generate EC packages
 */
FUNCTION  PACKAGES       RETURN INTEGER;

/**
 * Bitmask to generate PInC triggers
 */
FUNCTION  AP_TRIGGERS    RETURN INTEGER;

/**
 * Bitmask to generate IUR triggers
 */
FUNCTION  IUR_TRIGGERS   RETURN INTEGER;

/**
 * Bitmask to generate JN triggers
 */
FUNCTION  JN_TRIGGERS    RETURN INTEGER;

/**
 * Bitmask to generate IU triggers
 */
FUNCTION  IU_TRIGGERS    RETURN INTEGER;

/**
 * Bitmask to generate AUT triggers
 */
FUNCTION  AUT_TRIGGERS   RETURN INTEGER;

/**
 * Bitmask to generate AIUDT triggers
 */
FUNCTION  AIUDT_TRIGGERS RETURN INTEGER;

/**
 * Bitmask to generate basic table triggers. 
 * <br/><br/>
 * NOTE: <var>BASIC_TRIGGERS</var> is the same as <var>AUT_TRIGGERS + AIUDT_TRIGGERS + IU_TRIGGERS</var>.
 */
FUNCTION  BASIC_TRIGGERS RETURN INTEGER;

/**
 * Bitmask to generate all table triggers
 * <br/><br/>
 * NOTE: <var>ALL_TRIGGERS</var> is the same as <var>AP_TRIGGERS + AUT_TRIGGERS + AIUDT_TRIGGERS + IUR_TRIGGERS + IU_TRIGGERS + JN_TRIGGERS</var>.
 */
FUNCTION  ALL_TRIGGERS   RETURN INTEGER;

/**
 * Generate EC table triggers and/or packages for a given table (or all tables if <var>p_table_name</var> is <var>null</var>). 
 * Triggers and packages can be generated individually or together as indicated by <var>p_target_mask</var>.
 * <br/><br/>
 * <u>Examples:</u>
 *
 * <pre class="sql">
 * SQL> -- Generate EC packages for all tables. 
 * SQL> execute EcDp_Generate.generate(NULL, EcDp_Generate.PACKAGES);
 * </pre>
 *
 * <pre class="sql">
 * SQL> -- Generate EC package for the BERTH table.  
 * SQL> execute EcDp_Generate.generate('BERTH', EcDp_Generate.PACKAGES);
 * </pre>
 *
 * <pre class="sql">
 * SQL> -- Generate all triggers for BERTH table.
 * SQL> execute EcDp_Generate.generate('BERTH', EcDp_Generate.ALL_TRIGGERS);
 * </pre>
 *
 * <pre class="sql">
 * SQL> -- Generate IU, AUT and AIUDT triggers for all tables.
 * SQL> execute EcDp_Generate.generate(NULL, EcDp_Generate.IU + EcDp_Generate.AUT + EcDp_Generate.AIUDT);
 * </pre>
 *
 * <pre class="sql">
 * SQL> -- Generate EC package and all triggers except JN for BERTH table. 
 * SQL> execute EcDp_Generate.generate('BERTH', EcDp_Generate.PACKAGES + EcDp_Generate.ALL_TRIGGERS - EcDp_Generate.JN_TRIGGERS);
 * </pre>
 *
 * @param p_table_name Name of table, or <var>null</var> for all tables
 * @param p_target_mask Indicates what to generate 
 * @param p_missing_ind 
 */
 PROCEDURE generate(
          p_table_name IN VARCHAR2,
          p_target_mask IN INTEGER,
          p_missing_ind IN VARCHAR2 DEFAULT NULL)
;

END EcDp_Generate;
--~^UTDELIM^~--

CREATE OR REPLACE PACKAGE BODY EcDp_Generate IS
/**************************************************************
** Package :               EcDp_Generate, body part
**
** Purpose :               code generation for ec packages
**
** Documentation :         www.energy-components.no
**
** Created :               23.01.2017
**
** Modification history:
**
** Date:    Whom: Change description:
** -------- ----- --------------------------------------------
**
***********************************************************************************************/
CURSOR c_table_columns (p_table_name IN VARCHAR2) IS
   SELECT table_name, column_name, data_type, nullable, column_id
   FROM user_tab_columns
   WHERE  table_name = p_table_name
   ORDER BY table_name, column_id;

CURSOR c_table_key_columns (p_table_name IN VARCHAR2) IS
   SELECT   uc.constraint_type, uc.constraint_name, uc.table_name, ucc.column_name, NULL AS data_type
   FROM     user_constraints uc, user_cons_columns ucc
   WHERE    uc.table_name = p_table_name
   AND      uc.constraint_type IN ('P','R','U')
   AND      ucc.owner = uc.owner
   AND      ucc.constraint_name = uc.constraint_name
   AND      ucc.table_name = uc.table_name
   -- We are only referring to FK column OBJECT_ID in the code, so we don't have to read the other FK columns
   AND     (uc.constraint_type <> 'R' OR ucc.column_name = 'OBJECT_ID')
   ORDER BY uc.constraint_name, decode(ucc.column_name, 'SUMMER_TIME',1,0), position;

CURSOR c_ctrl_object(cp_table VARCHAR2) IS
   SELECT Nvl(o.view_pk_table_name, o.object_name) AS table_name, 
          o.object_name, 
          o.view_pk_table_name, 
          o.math, 
          nvl(o.ec_package, 'Y') AS ec_package, 
          nvl(o.pinc_trigger_ind, 'Y') AS pinc_trigger_ind
   FROM   ctrl_object o
   WHERE  o.object_name = Nvl(cp_table, o.object_name);

CURSOR c_ctrl_gen_functions(p_table VARCHAR2) IS
   SELECT table_name, column_name, alias_name, calc_type, mtd_average, mtd_cumulative, ytd_average, ytd_cumulative, ttd_average, ttd_cumulative, calc_formula,
          CASE WHEN calc_type != 'COLUMN' THEN Nvl(calc_formula, column_name) ELSE column_name END AS formula
   FROM   ctrl_gen_function
   WHERE  table_name = p_table
   AND    calc_type IN ('COLUMN','CALC');

TYPE t_table_columns IS TABLE OF c_table_columns%ROWTYPE;
TYPE t_table_key_columns IS TABLE OF c_table_key_columns%ROWTYPE;
TYPE t_ctrl_gen_function_rows IS TABLE OF c_ctrl_gen_functions%ROWTYPE;

TYPE t_alias_map IS TABLE OF VARCHAR2(30) INDEX BY VARCHAR2(30);
TYPE Varchar_30_M IS TABLE OF VARCHAR(30) INDEX BY VARCHAR2(30);
TYPE t_flush_tables IS TABLE OF VARCHAR2(30);

TYPE r_table_data IS RECORD (
   table_name VARCHAR2(30),
   cols       t_table_columns,
   jn_cols    t_table_columns,
   pk_cols    t_table_key_columns,
   uk_cols    t_table_key_columns,
   fk_cols    t_table_key_columns,
   ctrlObj    c_ctrl_object%ROWTYPE,
   genFns     t_ctrl_gen_function_rows,
   alias      t_alias_map,
   jnDataType Varchar_30_M,
   dataType   Varchar_30_M,
   isNullable Varchar_30_M,
   pday_buffer BOOLEAN
);

pv_package_header DBMS_SQL.varchar2a;
pv_package_body   DBMS_SQL.varchar2a;

-- Package variable that holds metadata for the "current table"
--
tbl  r_table_data;

-- Dashed line used in generated code
--
P_DASHED_LINE CONSTANT VARCHAR2(100) := '------------------------------------------------------------------------------------' || CHR(10);

-- IUR trigger body
--
IUR_TRIGGER_CODE CONSTANT VARCHAR2(1000) := q'[
DECLARE
o_rec_id          VARCHAR2(32) := :OLD.rec_id;
BEGIN
    IF Inserting THEN
      IF :new.rec_id IS NULL THEN
         :new.rec_id := SYS_GUID();
      END IF;
    ELSE
         IF o_rec_id is null THEN
            o_rec_id := SYS_GUID();
          END IF;
          IF NOT UPDATING('REC_ID') THEN
            :new.rec_id := o_rec_id;
          END IF;
     END IF;
END;
]';

lt_flush_tables t_flush_tables := t_flush_tables('WELL_VERSION', 'STOR_VERSION', 'TANK_VERSION', 'WELL_HOOKUP_VERSION', 'CHEM_TANK_VERSION', 'FCTY_VERSION', 
                                    'PIPE_VERSION', 'SEPA_VERSION', 'FLWL_VERSION', 'STRM_VERSION', 'EQPM_VERSION', 'TEST_DEVICE_VERSION');

-- Bitmasks values used to indicate which objects to generate.
--
I_PCK_MASK   CONSTANT INTEGER := Power(2, 0);
I_AP_MASK    CONSTANT INTEGER := Power(2, 1);
I_IUR_MASK   CONSTANT INTEGER := Power(2, 2);
I_JN_MASK    CONSTANT INTEGER := Power(2, 3);
I_IU_MASK    CONSTANT INTEGER := Power(2, 4);
I_AUT_MASK   CONSTANT INTEGER := Power(2, 5);
I_AIUDT_MASK CONSTANT INTEGER := Power(2, 6);

----------------------------------------------------------------------------------------
-- Return inpot string surrounded by single quotes
----------------------------------------------------------------------------------------
FUNCTION squote(p_string IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
   RETURN CHR(39) || p_string || CHR(39);
END squote;

----------------------------------------------------------------------------------------
-- Bitwise OR
----------------------------------------------------------------------------------------
FUNCTION bitor(x IN NUMBER, y IN NUMBER)
RETURN NUMBER
IS
BEGIN
    RETURN x + y - bitand(x,y);
END bitor;

----------------------------------------------------------------------------------------
-- Clear internal structure that holds the table meta data
----------------------------------------------------------------------------------------
PROCEDURE clearTbl
IS
BEGIN
   tbl.table_name := NULL;
   IF tbl.cols IS NOT NULL THEN
      tbl.cols.DELETE;
   END IF;
   IF tbl.jn_cols IS NOT NULL THEN
      tbl.jn_cols.DELETE;
   END IF;
   IF tbl.pk_cols IS NOT NULL THEN
      tbl.pk_cols.DELETE;
   END IF;
   IF tbl.uk_cols IS NOT NULL THEN
      tbl.uk_cols.DELETE;
   END IF;
   IF tbl.fk_cols IS NOT NULL THEN
      tbl.fk_cols.DELETE;
   END IF;
   IF tbl.genFns IS NOT NULL THEN
      tbl.genFns.DELETE;
   END IF;
   tbl.cols := t_table_columns();
   tbl.jn_cols := t_table_columns();
   tbl.pk_cols := t_table_key_columns();
   tbl.uk_cols := t_table_key_columns();
   tbl.fk_cols := t_table_key_columns();
   tbl.genFns := t_ctrl_gen_function_rows();
   tbl.dataType.DELETE;
   tbl.jnDataType.DELETE;
   tbl.isNullable.DELETE;
   tbl.alias.DELETE;
   tbl.ctrlObj := NULL;
END clearTbl;

----------------------------------------------------------------------------------------
-- Add input text as line in header buffer
----------------------------------------------------------------------------------------
PROCEDURE addHeaderLine(p_text VARCHAR2)
IS
BEGIN
   EcDp_DynSql.AddSqlLineNoWrap(pv_package_header, p_text);
END addHeaderLine;

----------------------------------------------------------------------------------------
-- Add input text as line in body buffer
----------------------------------------------------------------------------------------
PROCEDURE addBodyLine(p_text VARCHAR2)
IS
BEGIN
   EcDp_DynSql.AddSqlLineNoWrap(pv_package_body, p_text);
END addBodyLine;

----------------------------------------------------------------------------------------
-- Build package header (and clear header afterwards)
----------------------------------------------------------------------------------------
PROCEDURE buildPackageHeader(p_package_name IN VARCHAR2)
IS
BEGIN
  Ecdp_Dynsql.SafeBuildSupressErrors(p_package_name, 'PACKAGE', pv_package_header, 'EC_PACKAGE_HEADER');

  pv_package_header.DELETE;

END buildPackageHeader;

----------------------------------------------------------------------------------------
-- Build package body (and clear buffer afterwards)
----------------------------------------------------------------------------------------
PROCEDURE buildPackageBody(p_package_name IN VARCHAR2)
IS
BEGIN

  Ecdp_Dynsql.SafeBuildSupressErrors(p_package_name, 'PACKAGE', pv_package_body, 'EC_PACKAGE_BODY');

  pv_package_body.DELETE;

END buildPackageBody;

----------------------------------------------------------------------------------------
-- Build package view (and clear buffer afterwards)
----------------------------------------------------------------------------------------
PROCEDURE buildPackageView(p_view_name IN VARCHAR2, p_col_list IN VARCHAR2, p_table_name IN VARCHAR2)
IS
   lv_view DBMS_SQL.varchar2a;
BEGIN
  EcDp_DynSql.AddSqlLineNoWrap(lv_view,
              'CREATE OR REPLACE FORCE VIEW ' || p_view_name || ' AS' || CHR(10)||
              '----------------------------------------------------------------------------' || CHR(10) ||
              '-- View name: ' || p_view_name || CHR(10) ||
              '-- Generated by EC_GENERATE.' || CHR(10) ||
              '----------------------------------------------------------------------------' || CHR(10) ||
              'SELECT ' || p_col_list || CHR(10) || 'FROM ' || p_table_name);

  Ecdp_Dynsql.SafeBuildSupressErrors(p_view_name, 'VIEW', lv_view, 'EC_PACKAGE_VIEWS');
  lv_view.DELETE;
END buildPackageView;

----------------------------------------------------------------------------------------
-- Build package view (and clear buffer afterwards)
----------------------------------------------------------------------------------------
PROCEDURE buildTrigger(p_trigger_name IN VARCHAR2, p_trigger_code IN VARCHAR2)
IS
   lv_code DBMS_SQL.varchar2a;
BEGIN
   EcDp_DynSql.AddSqlLineNoWrap(lv_code, p_trigger_code);
   Ecdp_Dynsql.SafeBuildSupressErrors(p_trigger_name, 'TRIGGER', lv_code, 'EC_TRIGGERS');
   lv_code.DELETE;
END buildTrigger;

----------------------------------------------------------------------------------------
-- Build function signature from given parameters
----------------------------------------------------------------------------------------
FUNCTION getFnSignature(p_fn_name IN VARCHAR2, p_parameter_list IN VARCHAR2, p_fn_type IN VARCHAR2, p_separator IN VARCHAR2 DEFAULT ' ')
RETURN VARCHAR2
IS
BEGIN
   RETURN P_DASHED_LINE||'FUNCTION '||p_fn_name||p_parameter_list||p_separator||'RETURN '||p_fn_type;
END getFnSignature;

----------------------------------------------------------------------------------------
-- Return package header declaration and comments
----------------------------------------------------------------------------------------
FUNCTION getPackageHeadHeader(p_package_name IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
   RETURN 'CREATE OR REPLACE PACKAGE ec_'||p_package_name||' IS '||CHR(10)||
          P_DASHED_LINE||
          '-- Package: ec_'||p_package_name||CHR(10)||
          '-- Generated by EC_GENERATE.'||CHR(10)||
          CHR(10)||
          '-- DO NOT MODIFY THIS PACKAGE! Changes will be lost when the package is regenerated.'||CHR(10)||
          '-- Packages named pck_<component> will hold all manual written common code.'||CHR(10)||
          '-- Packages named <sysnam>_<component> will hold all code not beeing common.'||CHR(10)||
          P_DASHED_LINE||CHR(10);
END getPackageHeadHeader;

----------------------------------------------------------------------------------------
-- Return package body declaration and comments
----------------------------------------------------------------------------------------
FUNCTION getPackageBodyHeader(p_package_name IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
   RETURN 'CREATE OR REPLACE PACKAGE BODY ec_'||p_package_name||' IS'||CHR(10)||
          P_DASHED_LINE||
          '-- Package body: ec_'||p_package_name||CHR(10)||
          '-- Generated by EC_GENERATE.'||CHR(10)||
          P_DASHED_LINE||CHR(10);
END getPackageBodyHeader;

----------------------------------------------------------------------------------------
-- Return "cumulative" function body text
----------------------------------------------------------------------------------------
FUNCTION getCumFnBody(
         p_row IN c_ctrl_gen_functions%ROWTYPE,
         p_where_clause IN VARCHAR2,
         p_fn_name IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
   RETURN q'[IS
CURSOR c_calculate IS
   SELECT Sum(]'||Lower(p_row.formula)||q'[) result
   FROM ]'||p_row.table_name||CHR(10)||
   p_where_clause||q'[;

ln_return_val NUMBER := NULL;
BEGIN
   FOR mycur IN c_calculate LOOP
       ln_return_val := mycur.result;
   END LOOP;
   RETURN ln_return_val;
END ]'||p_fn_name||';'||CHR(10);
END getCumFnBody;

----------------------------------------------------------------------------------------
-- Return "average" function body text
----------------------------------------------------------------------------------------
FUNCTION getAveFnBody(
         p_row IN c_ctrl_gen_functions%ROWTYPE,
         p_where_clause IN VARCHAR2,
         p_fn_name IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
   RETURN q'[IS
CURSOR c_calculate IS
   SELECT Avg(]'||Lower(p_row.formula)||q'[) result
   FROM ]'||p_row.table_name||q'[
   ]'||p_where_clause||q'[;

ln_return_val NUMBER := NULL;
BEGIN
   FOR mycur IN c_calculate LOOP
       ln_return_val := mycur.result;
   END LOOP;
   RETURN ln_return_val;
END ]'||p_fn_name||q'[;
]';
END getAveFnBody;

----------------------------------------------------------------------------------------
-- Return "math" function body text
----------------------------------------------------------------------------------------
FUNCTION getMathFnBody(
         p_table_name IN VARCHAR2,
         p_column_name IN VARCHAR2,
         p_fn_name IN VARCHAR2,
         p_where_clause IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
   RETURN q'[IS

CURSOR c_calculate IS
   SELECT Decode(Upper(p_method),
              'SUM', Sum(]'||Lower(p_column_name)||q'[),
              'AVG', Avg(]'||Lower(p_column_name)||q'[),
              'MIN', Min(]'||Lower(p_column_name)||q'[),
              'MAX', Max(]'||Lower(p_column_name)||q'[),
              'COUNT', Count(]'||Lower(p_column_name)||q'[),
              NULL) result
   FROM ]'||p_table_name||q'[
   ]'||p_where_clause||q'[;

ln_return_val NUMBER := NULL;

BEGIN
   FOR mycur IN c_calculate LOOP
      ln_return_val := mycur.result;
   END LOOP;
   RETURN ln_return_val;
END ]'||p_fn_name||q'[;
]';
END getMathFnBody;

----------------------------------------------------------------------------------------
-- Return "count" function body text
----------------------------------------------------------------------------------------
FUNCTION getCountFnBody(p_table_name IN VARCHAR2, p_where_clause IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
    RETURN q'[ IS

CURSOR c_calculate IS
   SELECT Count(*) result
   FROM ]'||p_table_name||q'[
   ]'||p_where_clause||q'[;
ln_return_val NUMBER := NULL;

BEGIN
   FOR mycur IN c_calculate LOOP
      ln_return_val := mycur.result;
   END LOOP;
   RETURN ln_return_val;
END count_rows ;

]';
END getCountFnBody;

----------------------------------------------------------------------------------------
-- Return column function body text
----------------------------------------------------------------------------------------
FUNCTION getColumnFnBody(
  p_table_name IN VARCHAR2,
  p_column_name IN VARCHAR2,
  p_where_clause IN VARCHAR2,
  p_fn_name IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
   RETURN q'[IS
   v_return_val ]'||p_table_name||'.'||p_column_name||q'[%TYPE;
CURSOR c_col_val IS
   SELECT ]'||lower(p_column_name)||' col '||CHR(10)||
   'FROM '||p_table_name||q'[
   ]'||p_where_clause||q'[;
BEGIN
   FOR cur_row IN c_col_val LOOP
      v_return_val := cur_row.col;
   END LOOP;
   RETURN v_return_val;
END ]'||p_fn_name||';'||CHR(10);

END getColumnFnBody;

----------------------------------------------------------------------------------------
-- Return date column function body text
----------------------------------------------------------------------------------------
FUNCTION getColumnFunctionDtBody(
  p_is_version_table IN BOOLEAN,
  p_table_name IN VARCHAR2,
  p_column_name IN VARCHAR2,
  p_where_clause_eq IN VARCHAR2,
  p_where_clause_le IN VARCHAR2,
  p_where_clause_lt IN VARCHAR2,
  p_where_clause_ge IN VARCHAR2,
  p_where_clause_gt IN VARCHAR2,
  p_where_clause_sub IN VARCHAR2,
  p_fn_name IN VARCHAR2)
RETURN VARCHAR2
IS
  lv2_where_clause_eq VARCHAR2(1000) :=
    '      ' || REPLACE(p_where_clause_eq, CHR(10), CHR(10) || '      ');

  lv2_where_clause_le VARCHAR2(1000) :=
    CASE WHEN p_is_version_table THEN
      '      WHERE object_id = p_object_id' || CHR(10) ||
      '      AND p_daytime >= daytime AND p_daytime < nvl(end_date, p_daytime + 1)'
    ELSE
      '      ' || REPLACE(p_where_clause_sub, CHR(10), CHR(10) || '      ') || CHR(10) ||
      '         (SELECT max(daytime) FROM ' || p_table_name || CHR(10) ||
      '         ' || REPLACE(p_where_clause_le, CHR(10), CHR(10) || '         ') || ')'
    END;

  lv2_where_clause_lt VARCHAR2(1000) :=
    CASE WHEN p_is_version_table THEN
      '      WHERE object_id = p_object_id' || CHR(10) ||
      '      AND daytime < p_daytime AND nvl(end_date, p_daytime) >= p_daytime'
    ELSE
      '      ' || REPLACE(p_where_clause_sub, CHR(10), CHR(10) || '      ') || CHR(10) ||
      '         (SELECT max(daytime) FROM ' || p_table_name || CHR(10) ||
      '         ' || REPLACE(p_where_clause_lt, CHR(10), CHR(10) || '         ') || ')'
    END;

  lv2_where_clause_ge VARCHAR2(1000) :=
    '      ' || REPLACE(p_where_clause_sub, CHR(10), CHR(10) || '      ') || CHR(10) ||
    '         (SELECT min(daytime) FROM ' || p_table_name || CHR(10) ||
    '         ' || REPLACE(p_where_clause_ge, CHR(10), CHR(10) || '         ') || ')';

  lv2_where_clause_gt VARCHAR2(1000) :=
    '      ' || REPLACE(p_where_clause_sub, CHR(10), CHR(10) || '      ') || CHR(10) ||
    '         (SELECT min(daytime) FROM ' || p_table_name || CHR(10) ||
    '         ' || REPLACE(p_where_clause_gt, CHR(10), CHR(10) || '         ') || ')';
BEGIN
  RETURN 'IS ' || CHR(10) ||
  '   lr_field ' || p_table_name || '.' || p_column_name || '%TYPE;' || CHR(10) ||
  'BEGIN ' || CHR(10) ||
  '   IF p_compare_oper = ''='' THEN ' || CHR(10) ||
  '      SELECT ' || p_column_name || ' INTO lr_field FROM ' || p_table_name || CHR(10) || CHR(10) || lv2_where_clause_eq || ';' || CHR(10) ||
  '   ELSIF p_compare_oper IN (''<='',''=<'') THEN ' || CHR(10) ||
  '      SELECT ' || p_column_name || ' INTO lr_field FROM ' || p_table_name || CHR(10) || CHR(10) || lv2_where_clause_le || ';' || CHR(10) ||
  '   ELSIF p_compare_oper = ''<'' THEN ' || CHR(10) ||
  '      SELECT ' || p_column_name || ' INTO lr_field FROM ' || p_table_name || CHR(10) || CHR(10) || lv2_where_clause_lt || ';' || CHR(10) ||
  '   ELSIF p_compare_oper IN (''>='',''=>'') THEN ' || CHR(10) ||
  '      SELECT ' || p_column_name || ' INTO lr_field FROM ' || p_table_name || CHR(10) || CHR(10) || lv2_where_clause_ge || ';' || CHR(10) ||
  '   ELSIF p_compare_oper = ''>'' THEN ' || CHR(10) ||
  '      SELECT ' || p_column_name || ' INTO lr_field FROM ' || p_table_name || CHR(10) || lv2_where_clause_gt || ';' || CHR(10) ||
  '   END IF;' || CHR(10) ||
  '   RETURN lr_field;' || CHR(10) ||
  '   EXCEPTION WHEN NO_DATA_FOUND THEN RETURN lr_field;' || CHR(10) ||
  'END ' || p_fn_name || ';' || CHR(10);
END getColumnFunctionDtBody;

----------------------------------------------------------------------------------------
-- Return row_by_pk function body text
----------------------------------------------------------------------------------------
FUNCTION getRowByPkFnBody(
  p_table_name IN VARCHAR2,
  p_row_cache_key IN VARCHAR2,
  p_where_clause IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
    RETURN q'[IS
   v_return_rec ]'||p_table_name||q'[%ROWTYPE;
   lv2_sc_key VARCHAR2(4000) := ]'||p_row_cache_key||q'[;
   CURSOR c_read_row IS
   SELECT *
   FROM ]'||p_table_name||q'[
   ]'||p_where_clause||q'[;
BEGIN
   IF NOT sg_row_cache.EXISTS(lv2_sc_key) THEN
      sg_row_cache.DELETE;
   FOR cur_rec IN c_read_row LOOP
      v_return_rec := cur_rec;
   END LOOP;
      sg_row_cache(lv2_sc_key) := v_return_rec;
   END IF;
   RETURN sg_row_cache(lv2_sc_key);
END row_by_pk;
]';
END getRowByPkFnBody;

----------------------------------------------------------------------------------------
-- Return row_by_pk function body text
----------------------------------------------------------------------------------------
FUNCTION getRowByPkFunctionDtBody(
  p_parameter_list_cursor IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
   RETURN 'IS ' || CHR(10) ||
           'BEGIN ' || CHR(10) ||
           '   RETURN row_by_rel_operator' || p_parameter_list_cursor || ';' || CHR(10) ||
           'END row_by_pk' || ';' || CHR(10);
END getRowByPkFunctionDtBody;

----------------------------------------------------------------------------------------
-- Return row_by_object_id function body text
----------------------------------------------------------------------------------------
FUNCTION getRowByObjectIdFnBody(
  p_table_name IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
    RETURN q'[IS
   v_return_rec ]'||p_table_name||q'[%ROWTYPE;
   lv2_sc_key VARCHAR2(33) := 'x'||p_object_id;
   CURSOR c_read_row IS
   SELECT *
   FROM ]'||p_table_name||q'[
   WHERE object_id = p_object_id;
BEGIN
   IF NOT sg_row_cache.EXISTS(lv2_sc_key) THEN
      sg_row_cache.DELETE;
   FOR cur_rec IN c_read_row LOOP
      v_return_rec := cur_rec;
   END LOOP;
      sg_row_cache(lv2_sc_key) := v_return_rec;
   END IF;
   RETURN sg_row_cache(lv2_sc_key);
END row_by_object_id;
]';
END getRowByObjectIdFnBody;

----------------------------------------------------------------------------------------
-- Return "row by relational operator" function body text
----------------------------------------------------------------------------------------
FUNCTION getRowByRelOpFnBody(
  p_table_name IN VARCHAR2,
  p_row_cache_key IN VARCHAR2,
  p_parameter_list_cursor IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
   RETURN ' IS' || CHR(10) ||
          '   lr_return_rec '||p_table_name||'%ROWTYPE;'|| CHR(10) ||
          '   lv2_sc_key VARCHAR2(4000) := '||p_row_cache_key||';'|| CHR(10) ||
          'BEGIN'|| CHR(10) ||
          '   IF NOT sg_row_cache.EXISTS(lv2_sc_key) THEN'|| CHR(10) ||
          '      sg_row_cache.DELETE;'|| CHR(10) ||
          '   IF p_compare_oper = '||squote('=')||' THEN'|| CHR(10) ||
          '      FOR cur_row IN c_equal'||p_parameter_list_cursor||' LOOP'|| CHR(10) ||
          '         lr_return_rec := cur_row;'|| CHR(10) ||
          '      END LOOP;'|| CHR(10) ||
          '   ELSIF p_compare_oper IN ('||squote('<=')||','||squote('=<')||') THEN'|| CHR(10) ||
          '      FOR cur_row IN c_less_equal'||p_parameter_list_cursor||' LOOP'|| CHR(10) ||
          '         lr_return_rec := cur_row;'|| CHR(10) ||
          '      END LOOP;'|| CHR(10) ||
          '   ELSIF p_compare_oper = '||squote('<')||' THEN'|| CHR(10) ||
          '      FOR cur_row IN c_less'||p_parameter_list_cursor||' LOOP'|| CHR(10) ||
          '         lr_return_rec := cur_row;'|| CHR(10) ||
          '      END LOOP;'|| CHR(10) ||
          '   ELSIF p_compare_oper IN ('||squote('>=')||','||squote('=>')||') THEN'|| CHR(10) ||
          '      FOR cur_row IN c_greater_equal'||p_parameter_list_cursor||' LOOP'|| CHR(10) ||
          '         lr_return_rec := cur_row;'|| CHR(10) ||
          '      END LOOP;'|| CHR(10) ||
          '   ELSIF p_compare_oper = '||squote('>')||' THEN'|| CHR(10) ||
          '      FOR cur_row IN c_greater'||p_parameter_list_cursor||' LOOP'|| CHR(10) ||
          '         lr_return_rec := cur_row;'|| CHR(10) ||
          '      END LOOP;'|| CHR(10) ||
          '   END IF;'|| CHR(10) ||
          '      sg_row_cache(lv2_sc_key) := lr_return_rec;'|| CHR(10) ||
          '   END IF;'|| CHR(10) ||
          '   RETURN sg_row_cache(lv2_sc_key);'|| CHR(10) ||
          'END row_by_rel_operator;'|| CHR(10);
END getRowByRelOpFnBody;

----------------------------------------------------------------------------------------
-- Return "prev/next daytime" function body text
----------------------------------------------------------------------------------------
FUNCTION getDaytimeFnBody(
  p_table_name IN VARCHAR2,
  p_sort_order IN VARCHAR2,
  p_where_clause IN VARCHAR2,
  p_fn_name IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
   RETURN q'[IS
CURSOR c_compute IS
   SELECT daytime
   FROM ]'||lower(p_table_name)||q'[
   ]'||p_where_clause||q'[
   ORDER BY daytime ]'||p_sort_order||q'[;
ld_return_val DATE := NULL;
BEGIN
   IF p_num_rows >= 1 THEN
      FOR cur_rec IN c_compute LOOP
         ld_return_val := cur_rec.daytime;
         IF c_compute%ROWCOUNT = p_num_rows THEN
            EXIT;
         END IF;
      END LOOP;
   END IF;
   RETURN ld_return_val;
END ]'||p_fn_name||q'[;
]';
END getDaytimeFnBody;

----------------------------------------------------------------------------------------
-- Return 'Y' if p_key_columns contains a column with the given name. Otherwise return 'N'.
----------------------------------------------------------------------------------------
FUNCTION hasKeyColumn(p_key_columns t_table_key_columns, p_column_name VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
  FOR i IN 1..p_key_columns.COUNT LOOP
    IF Upper(p_key_columns(i).column_name) = Upper(p_column_name) THEN
      RETURN 'Y';
    END IF;
  END LOOP;
  RETURN 'N';
END hasKeyColumn;

----------------------------------------------------------------------------------------
-- Return 'Y' if the "current table" has a unique key column with the given name.
-- Otherwise return 'N'.
----------------------------------------------------------------------------------------
FUNCTION hasUkColumn(p_column_name VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
  RETURN hasKeyColumn(tbl.uk_cols, p_column_name);
END hasUkColumn;

----------------------------------------------------------------------------------------
-- Return 'Y' if the "current table" has a primary key column with the given name.
-- Otherwise return 'N'.
----------------------------------------------------------------------------------------
FUNCTION hasPkColumn(p_column_name VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
  RETURN hasKeyColumn(tbl.pk_cols, p_column_name);
END hasPkColumn;

----------------------------------------------------------------------------------------
-- Return 'Y' if the "current table" has a foreign key column with the given name.
-- Otherwise return 'N'.
----------------------------------------------------------------------------------------
FUNCTION hasFkColumn(p_column_name VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
  RETURN hasKeyColumn(tbl.fk_cols, p_column_name);
END hasFkColumn;

----------------------------------------------------------------------------------------
-- Return 'Y' if the "current table" has a column with the given name. Otherwise return 'N'.
----------------------------------------------------------------------------------------
FUNCTION hasColumn(p_column_name VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
  IF tbl.dataType.EXISTS(p_column_name) THEN
     RETURN 'Y';
  END IF;
  RETURN 'N';
END hasColumn;

----------------------------------------------------------------------------------------
-- Return 'Y' if the "current table" has a journal table column with the given name.
-- Otherwise return 'N'.
--
-- NOTE: If the "current table" does not have a journal table, tbl.jn_cols will be empty.
----------------------------------------------------------------------------------------
FUNCTION hasJnColumn(p_column_name VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
  IF tbl.jnDataType.EXISTS(p_column_name) THEN
     RETURN 'Y';
  END IF;
  RETURN 'N';
END hasJnColumn;

----------------------------------------------------------------------------------------
-- This procedure creates object_id_by_uk function code. Generated for tables with a
-- primary key constraint consisting of OBJECT_ID and any related unique key constraint
-- with at least OBJECT_CODE in it.
----------------------------------------------------------------------------------------
FUNCTION getObjectIdFunction(p_table_data r_table_data, p_package_part VARCHAR2)
RETURN VARCHAR2
IS
  lv2_parameter_list  VARCHAR2(2000);
  lv2_cur_par_list    VARCHAR2(2000);
  lv2_cur_call_list   VARCHAR2(2000);
  lv2_qualifier_list  VARCHAR2(2000);
  lv2_plsql_code      VARCHAR2(4000);
  lv2_comma           VARCHAR2(10);
  lv2_and             VARCHAR2(10);
  lv2_uk_name         VARCHAR2(30);
  b_has_object_id_fn  BOOLEAN := FALSE;
BEGIN
   lv2_parameter_list := '';
   lv2_comma := '';
   lv2_and := '';

   -- Find unique constraint that contains OBJECT_CODE
   FOR i IN 1..p_table_data.uk_cols.COUNT LOOP
     IF p_table_data.uk_cols(i).column_name = 'OBJECT_CODE' THEN
       lv2_uk_name := p_table_data.uk_cols(i).constraint_name;
     END IF;
   END LOOP;

   -- Build parameter list from unique constraint that contains OBJECT_CODE
   FOR i IN 1..p_table_data.uk_cols.COUNT LOOP
     IF p_table_data.uk_cols(i).constraint_name = lv2_uk_name THEN
       b_has_object_id_fn := TRUE;
       lv2_parameter_list := lv2_parameter_list || lv2_comma || 'p_' || LOWER(p_table_data.uk_cols(i).column_name) || ' ' || p_table_data.uk_cols(i).data_type;
       lv2_cur_par_list := lv2_cur_par_list || lv2_comma || 'cp_' || LOWER(p_table_data.uk_cols(i).column_name) || ' ' || p_table_data.uk_cols(i).data_type;
       lv2_cur_call_list := lv2_cur_call_list || lv2_comma || 'p_' || LOWER(p_table_data.uk_cols(i).column_name);
       lv2_qualifier_list := lv2_qualifier_list || lv2_and || LOWER(p_table_data.uk_cols(i).column_name) || ' = cp_' || LOWER(p_table_data.uk_cols(i).column_name);

       lv2_comma := ', ';
       lv2_and := CHR(10) || '   AND ';
     END IF;
   END LOOP;

   IF b_has_object_id_fn THEN
      IF p_package_part = 'HEAD' THEN
         lv2_plsql_code := 'FUNCTION object_id_by_uk(' || lv2_parameter_list || ') RETURN ' || p_table_data.ctrlObj.object_name ||'.OBJECT_ID%TYPE';
         lv2_plsql_code := lv2_plsql_code || ';' || CHR(10);
      ELSE
         lv2_plsql_code := 'FUNCTION object_id_by_uk(' || lv2_parameter_list || ')' || CHR(10) || 'RETURN ' || p_table_data.ctrlObj.object_name ||'.OBJECT_ID%TYPE';
         lv2_plsql_code := lv2_plsql_code || CHR(10) ||
                        'IS' || CHR(10) ||
                        '   v_return_val ' || p_table_data.ctrlObj.object_name || '.OBJECT_ID%TYPE;' || CHR(10) ||
                        '   CURSOR c_col_val(' || lv2_cur_par_list || ') IS' || CHR(10) ||
                        '   SELECT object_id col' || CHR(10) ||
                        '   FROM ' || p_table_data.ctrlObj.object_name || CHR(10) ||
                        '   WHERE ' || lv2_qualifier_list || ';' || CHR(10) ||
                        'BEGIN' || CHR(10) ||
                        '   FOR cur_row IN c_col_val(' || lv2_cur_call_list || ') LOOP' || CHR(10) ||
                        '      v_return_val := cur_row.col;' || CHR(10) ||
                        '   END LOOP;' || CHR(10) ||
                        '   RETURN v_return_val;' || CHR(10) ||
                        'END object_id_by_uk;' || CHR(10);
      END IF;
   END IF;
   RETURN lv2_plsql_code;
END getObjectIdFunction;

----------------------------------------------------------------------------------
-- Procedure : generatePackageViews
-- Purpose   : Builds and generates the package views
----------------------------------------------------------------------------------
PROCEDURE generatePackageViews IS
  lv2_parameter_list   VARCHAR2(2000);

  lv2_view_name_m      VARCHAR2(32);
  lv2_view_name_y      VARCHAR2(32);
  lv2_view_name_t      VARCHAR2(32);
  lv2_view_col_list    VARCHAR2(2000);
  lv2_pk_list          VARCHAR2(2000);

  lv2_table_name       VARCHAR2(32);
  lv2_alias            VARCHAR2(32);

  ln_func_l            NUMBER := 25;
  ln_view_l            NUMBER := 28;

  ln_count             NUMBER;
  lv2_delim            VARCHAR2(10) := '';
  lv2_view             VARCHAR2(30) := Lower(Substr(tbl.ctrlObj.object_name, 1, ln_view_l));
BEGIN
   lv2_parameter_list := '';
   lv2_table_name := Nvl(tbl.ctrlObj.view_pk_table_name, tbl.ctrlObj.object_name);

   -----------------------------------------------------------
   -- BUILD LIST OF COLUMNS BEING PART OF PK
   -----------------------------------------------------------
   FOR i IN 1..tbl.pk_cols.COUNT LOOP
      IF tbl.pk_cols(i).column_name != 'SUMMER_TIME' THEN
         lv2_parameter_list := lv2_parameter_list || lv2_delim || Lower(tbl.pk_cols(i).column_name);
         lv2_delim := ', ';
      END IF;
   END LOOP;

   IF upper(tbl.ctrlObj.object_name) like '%DAY%' THEN
      lv2_view_name_m := Replace(lv2_view, 'day', 'mtd');
      lv2_view_name_y := Replace(lv2_view, 'day', 'ytd');
      lv2_view_name_t := Replace(lv2_view, 'day', 'ttd');
   ELSIF upper(tbl.ctrlObj.object_name) like '%MTH%' THEN
      lv2_view_name_m := Replace(lv2_view, 'mth', 'mmtd');     -- should not be used
      lv2_view_name_y := Replace(lv2_view, 'mth', 'mytd');
      lv2_view_name_t := Replace(lv2_view, 'mth', 'mttd');
   ELSE
      lv2_view_name_m := 'mtd_' || lv2_view;
      lv2_view_name_y := 'ytd_' || lv2_view;
      lv2_view_name_t := 'ttd_' || lv2_view;
   END IF;

   IF Lower(Substr(tbl.ctrlObj.object_name,1,2)) <> 'v_' THEN
      lv2_view_name_m := 'v_' || lv2_view_name_m;
      lv2_view_name_y := 'v_' || lv2_view_name_y;
      lv2_view_name_t := 'v_' || lv2_view_name_t;
   END IF;

   lv2_pk_list := lv2_parameter_list;
   lv2_parameter_list := '(' || lv2_parameter_list || ')';

   ------------------------------------------------------------
   -- CREATE MTD VIEWS
   ------------------------------------------------------------
   ln_count := 0;
   lv2_view_col_list := lv2_pk_list;
   FOR i IN 1..tbl.genFns.COUNT LOOP
      IF tbl.genFns(i).mtd_cumulative = 'Y' OR tbl.genFns(i).mtd_average = 'Y' THEN
         ln_count := ln_count + 1;
         lv2_alias := tbl.alias(tbl.genFns(i).column_name);
         IF tbl.genFns(i).mtd_cumulative = 'Y' THEN
            lv2_view_col_list := lv2_view_col_list || CHR(10) ||
                              ', ec_' || Lower(lv2_table_name) || '.cumm_' || Nvl(Lower(lv2_alias), Lower(Substr(tbl.genFns(i).column_name,1,ln_func_l))) || lv2_parameter_list ||
                              ' CUMM_' || Nvl(Upper(lv2_alias), Upper(Substr(tbl.genFns(i).column_name,1,ln_func_l)));
         END IF;

         IF tbl.genFns(i).mtd_average = 'Y' THEN
            lv2_view_col_list := lv2_view_col_list || CHR(10) ||
                              ', ec_' || Lower(lv2_table_name) || '.avem_' || Nvl(Lower(lv2_alias), Lower(Substr(tbl.genFns(i).column_name,1,ln_func_l))) || lv2_parameter_list ||
                              ' AVEM_' || Nvl(Upper(lv2_alias), Upper(Substr(tbl.genFns(i).column_name,1,ln_func_l)));
         END IF;
      END IF;
   END LOOP;

   IF ln_count > 0 THEN
       buildPackageView(lv2_view_name_m, lv2_view_col_list, tbl.ctrlObj.object_name);
   END IF;

   ------------------------------------------------------------
   -- CREATE YTD VIEWS
   ------------------------------------------------------------
   ln_count := 0;
   lv2_view_col_list := lv2_pk_list;
   FOR i IN 1..tbl.genFns.COUNT LOOP
      IF tbl.genFns(i).ytd_cumulative = 'Y' OR tbl.genFns(i).ytd_average = 'Y' THEN
         ln_count := ln_count + 1;
         lv2_alias := tbl.alias(tbl.genFns(i).column_name);
         IF tbl.genFns(i).ytd_cumulative = 'Y' THEN
            lv2_view_col_list := lv2_view_col_list || CHR(10) ||
                              ', ec_' || Lower(lv2_table_name) || '.cumy_' || Nvl(Lower(lv2_alias), Lower(Substr(tbl.genFns(i).column_name,1,ln_func_l))) || lv2_parameter_list ||
                              ' CUMY_' || Nvl(Upper(lv2_alias), Upper(Substr(tbl.genFns(i).column_name,1,ln_func_l)));
         END IF;

         IF tbl.genFns(i).ytd_average = 'Y' THEN
            lv2_view_col_list := lv2_view_col_list || CHR(10) ||
                              ', ec_' || Lower(lv2_table_name) || '.avey_' || Nvl(Lower(lv2_alias), Lower(Substr(tbl.genFns(i).column_name,1,ln_func_l))) || lv2_parameter_list ||
                              ' AVEY_' || Nvl(Upper(lv2_alias), Upper(Substr(tbl.genFns(i).column_name,1,ln_func_l)));
         END IF;
      END IF;
   END LOOP;

   IF ln_count > 0 THEN
       buildPackageView(lv2_view_name_y, lv2_view_col_list, tbl.ctrlObj.object_name);
   END IF;

     ------------------------------------------------------------
   -- CREATE TTD VIEWS
   ------------------------------------------------------------
   ln_count := 0;
   lv2_view_col_list := lv2_pk_list;
   FOR i IN 1..tbl.genFns.COUNT LOOP
      IF tbl.genFns(i).ttd_cumulative = 'Y' OR tbl.genFns(i).ttd_average = 'Y' THEN
         ln_count := ln_count + 1;
         lv2_alias := tbl.alias(tbl.genFns(i).column_name);
         IF tbl.genFns(i).ttd_cumulative = 'Y' THEN
            lv2_view_col_list := lv2_view_col_list || CHR(10) ||
                              ', ec_' || Lower(lv2_table_name) || '.cumt_' || Nvl(Lower(lv2_alias), Lower(Substr(tbl.genFns(i).column_name,1,ln_func_l))) || lv2_parameter_list ||
                              ' CUMT_' || Nvl(Upper(lv2_alias), Upper(Substr(tbl.genFns(i).column_name,1,ln_func_l)));
         END IF;

         IF tbl.genFns(i).ttd_average = 'Y' THEN
            lv2_view_col_list := lv2_view_col_list || CHR(10) ||
                              ', ec_' || Lower(lv2_table_name) || '.avet_' || Nvl(Lower(lv2_alias), Lower(Substr(tbl.genFns(i).column_name,1,ln_func_l))) || lv2_parameter_list ||
                              ' AVET_' || Nvl(Upper(lv2_alias), Upper(Substr(tbl.genFns(i).column_name,1,ln_func_l)));
         END IF;
      END IF;
   END LOOP;

   IF ln_count > 0 THEN
       buildPackageView(lv2_view_name_t, lv2_view_col_list, tbl.ctrlObj.object_name);
   END IF;
END generatePackageViews;

----------------------------------------------------------------------------------
-- Builds and generates the package header and body
----------------------------------------------------------------------------------
PROCEDURE generatePackage IS

  -- Local variables used in procedure
  lv2_parameter_list              VARCHAR2(2000);
  lv2_parameter_list_oper         VARCHAR2(2000); -- Parameter list included v_compare_operator DEFAULT '='
  lv2_parameter_list_cursor       VARCHAR2(2000); -- Parameter list to be used for cursor loop
  lv2_par_list_cursor_func        VARCHAR2(2000); -- Parameter list to be used calling cursor function
  lv2_parameter_list_period       VARCHAR2(2000); -- Parameter list to be used calling period function
  lv2_parameter_list_count        VARCHAR2(2000);
  lv2_parameter_list_n_rows       VARCHAR2(2000); -- Parameter list to be used calling prev or next daytime
  lv2_summer_time_flag            VARCHAR2(1);
  lv2_parameter_list_s            VARCHAR2(2000);
  lv2_parameter_list_oper_s       VARCHAR2(2000);
  lv2_parameter_list_cursor_s     VARCHAR2(2000);
  lv2_row_cache_key               VARCHAR2(2000);

  lv2_where_clause_m              VARCHAR2(2000);
  lv2_where_clause_y              VARCHAR2(2000);
  lv2_where_clause_t              VARCHAR2(2000);
  lv2_where_clause_p              VARCHAR2(2000);
  lv2_where_clause_n              VARCHAR2(2000);
  lv2_where_clause_pe             VARCHAR2(2000);
  lv2_where_clause_ne             VARCHAR2(2000);
  lv2_where_clause_sub            VARCHAR2(2000);
  lv2_where_clause                VARCHAR2(2000);
  lv2_where_clause_per            VARCHAR2(2000);
  lv2_where_clause_count          VARCHAR2(2000);
  lv2_where_clause_s              VARCHAR2(2000);

  lv2_daytime                     VARCHAR2(1);

  lv2_daytime_clause_m            VARCHAR2(2000);
  lv2_daytime_clause_y            VARCHAR2(2000);
  lv2_daytime_clause_t            VARCHAR2(2000);
  lv2_daytime_clause_p            VARCHAR2(2000);
  lv2_daytime_clause_n            VARCHAR2(2000);
  lv2_daytime_clause_pe           VARCHAR2(2000);
  lv2_daytime_clause_ne           VARCHAR2(2000);
  lv2_daytime_clause              VARCHAR2(2000);
  lv2_daytime_clause_sub          VARCHAR2(2000);
  lv2_daytime_clause_per          VARCHAR2(2000);

  lv2_table_name                  VARCHAR2(32);
  ln_package_l                    NUMBER := 28;
  lv2_package_name                VARCHAR2(30);
  lb_version_table                VARCHAR2(1);

  lv2_delim                       VARCHAR2(100);
  lv2_delim2                      VARCHAR2(100);
  lv2_delim3                      VARCHAR2(100);
  lv2_fn_name                     VARCHAR2(1000);
  lv2_fn_type                     VARCHAR2(255);

  -- Find if this is a version tables where we can make assumptions about end_date handling
  CURSOR c_version_table(p_table_name VARCHAR2) IS
    SELECT 1
    FROM  class_cnfg c
    WHERE c.class_type = 'OBJECT'
    AND   c.db_object_attribute = p_table_name
    AND   p_table_name LIKE '%VERSION';
BEGIN

    pv_package_body.DELETE;

    lv2_package_name := lower(substr(tbl.ctrlObj.object_name, 1, ln_package_l));

    ------------------------------------------------------------
    -- BUILD DAYTIME CLAUSES
    ------------------------------------------------------------
    lv2_daytime_clause_m := 'daytime BETWEEN to_date(to_char(p_daytime,''YYYYMM'') || ''01'',''YYYYMMDD'') AND p_daytime';
    lv2_daytime_clause_y := 'daytime BETWEEN to_date(to_char(p_daytime,''YYYY'') || ''0101'',''YYYYMMDD'') AND p_daytime';
    lv2_daytime_clause_t := 'daytime <= p_daytime';
    lv2_daytime_clause_p := 'daytime < p_daytime';
    lv2_daytime_clause_n := 'daytime > p_daytime';
    lv2_daytime_clause_pe := 'daytime <= p_daytime';
    lv2_daytime_clause_ne := 'daytime >= p_daytime';
    lv2_daytime_clause   := 'daytime = p_daytime';
    lv2_daytime_clause_sub   := 'daytime = '; -- used if subselect max/min is needed

    -- Daytime clause for Math - functions
    lv2_daytime_clause_per := 'daytime BETWEEN Nvl(p_from_day, to_date(''01-JAN-1900'',''dd-mon-yyyy'')) AND Nvl(p_to_day, p_from_day)';

    ------------------------------------------------------------
    -- CREATE PACKAGE BODY HEADER
    ------------------------------------------------------------
    addHeaderLine(getPackageHeadHeader(lv2_package_name));
    addBodyLine(getPackageBodyHeader(lv2_package_name));

    lv2_parameter_list := Null;
    lv2_parameter_list_cursor := Null;
    lv2_parameter_list_period := Null;
    lv2_par_list_cursor_func := Null;
    lv2_where_clause  := Null;
    lv2_table_name := Nvl(tbl.ctrlObj.view_pk_table_name, tbl.ctrlObj.object_name);
    lv2_daytime := hasPkColumn('DAYTIME');
    lv2_summer_time_flag := hasPkColumn('SUMMER_TIME');
    lv2_row_cache_key := '''x''';

    lb_version_table := 'N';

    FOR curTable IN c_version_table(lv2_table_name) LOOP
      lb_version_table := 'Y';
    END LOOP;

    addBodyLine(
        P_DASHED_LINE||
        'TYPE row_cache IS TABLE OF ' || tbl.ctrlObj.object_name || '%ROWTYPE INDEX BY VARCHAR2(4000);'||CHR(10)||
        'sg_row_cache row_cache;'||CHR(10));

    -----------------------------------------------------------
    -- BUILD LIST OF COLUMNS BEING PART OF PK
    -----------------------------------------------------------
    lv2_delim2 := 'WHERE ';
    lv2_delim3 := CHR(10);

    FOR i IN 1..tbl.pk_cols.COUNT LOOP
     IF tbl.pk_cols(i).column_name != 'SUMMER_TIME' THEN
       IF i = 1 THEN
         lv2_delim := CHR(10);
       ELSE
         lv2_delim := ', '||CHR(10);
       END IF;

       lv2_parameter_list := lv2_parameter_list || lv2_delim || '         p_' || Lower(tbl.pk_cols(i).column_name) || ' ' || tbl.pk_cols(i).data_type;
       lv2_parameter_list_cursor := lv2_parameter_list_cursor || lv2_delim || '         p_' || Lower(tbl.pk_cols(i).column_name);

       IF tbl.pk_cols(i).data_type = 'DATE' THEN
          lv2_row_cache_key := lv2_row_cache_key || '||to_char(p_' || Lower(tbl.pk_cols(i).column_name) || ', ''yyyy-mm-dd"T"hh24:mi:ss'')';
       ELSE
          lv2_row_cache_key := lv2_row_cache_key || '||p_' || Lower(tbl.pk_cols(i).column_name);
       END IF;

       IF tbl.pk_cols(i).column_name != 'DAYTIME' THEN
          lv2_where_clause := lv2_where_clause || lv2_delim2 || Lower(tbl.pk_cols(i).column_name) || ' = ' || 'p_' || Lower(tbl.pk_cols(i).column_name);
          lv2_parameter_list_period := lv2_parameter_list_period || lv2_delim3 || '         p_' || Lower(tbl.pk_cols(i).column_name) || ' ' || tbl.pk_cols(i).data_type;
          lv2_parameter_list_count := lv2_parameter_list_count || lv2_delim3 || '         p_' || Lower(tbl.pk_cols(i).column_name) || ' ' || tbl.pk_cols(i).data_type;

          lv2_delim2 :=  CHR(10) || 'AND ';
          lv2_delim3 := ',' || CHR(10);
       END IF;
     END IF;
    END LOOP;

    -----------------------------------------------------------
    -- INITIATE THE PARAMETERLISTS
    -----------------------------------------------------------
    IF lv2_parameter_list IS NOT NULL THEN
       lv2_parameter_list_oper := '(' || lv2_parameter_list || ',' || CHR(10) || '         p_compare_oper VARCHAR2 DEFAULT ''='')';
       lv2_par_list_cursor_func := '(' || lv2_parameter_list_cursor || ', p_compare_oper)';
       lv2_parameter_list_cursor   := '(' || lv2_parameter_list_cursor || ')';
       lv2_parameter_list_period := '(' || lv2_parameter_list_period || ',' || CHR(10) || '         p_from_day DATE,' || CHR(10) || '         p_to_day DATE,' || CHR(10) || '         p_method VARCHAR2 DEFAULT ''SUM'')';
       lv2_parameter_list_count := '(' || lv2_parameter_list_count || ',' || CHR(10) || '         p_from_day DATE,' || CHR(10) || '         p_to_day DATE)';
       lv2_parameter_list_n_rows := '(' || lv2_parameter_list || ',' || CHR(10) || '         p_num_rows NUMBER DEFAULT 1' || ')';
       lv2_parameter_list   := '(' || lv2_parameter_list || ')';
    END IF;

    IF lv2_daytime = 'Y' THEN
       IF lv2_where_clause IS NULL THEN
          lv2_where_clause_m := 'WHERE ' || lv2_daytime_clause_m;
          lv2_where_clause_y := 'WHERE ' || lv2_daytime_clause_y;
          lv2_where_clause_t := 'WHERE ' || lv2_daytime_clause_t;
          lv2_where_clause_p := 'WHERE ' || lv2_daytime_clause_p;
          lv2_where_clause_n := 'WHERE ' || lv2_daytime_clause_n;
          lv2_where_clause_pe:= 'WHERE ' || lv2_daytime_clause_pe;
          lv2_where_clause_ne:= 'WHERE ' || lv2_daytime_clause_ne;
          lv2_where_clause_sub:='WHERE ' || lv2_daytime_clause_sub;
          lv2_where_clause   := 'WHERE ' || lv2_daytime_clause;
          lv2_where_clause_per :='WHERE ' || lv2_daytime_clause_per;
          lv2_where_clause_count :='WHERE ' || lv2_daytime_clause_per;
       ELSE
          lv2_where_clause_m := lv2_where_clause || CHR(10) || 'AND ' || lv2_daytime_clause_m;
          lv2_where_clause_y := lv2_where_clause || CHR(10) || 'AND ' || lv2_daytime_clause_y;
          lv2_where_clause_t := lv2_where_clause || CHR(10) || 'AND ' || lv2_daytime_clause_t;
          lv2_where_clause_p := lv2_where_clause || CHR(10) || 'AND ' || lv2_daytime_clause_p;
          lv2_where_clause_n := lv2_where_clause || CHR(10) || 'AND ' || lv2_daytime_clause_n;
          lv2_where_clause_pe:= lv2_where_clause || CHR(10) || 'AND ' || lv2_daytime_clause_pe;
          lv2_where_clause_ne:= lv2_where_clause || CHR(10) || 'AND ' || lv2_daytime_clause_ne;
          lv2_where_clause_sub:=lv2_where_clause || CHR(10) || 'AND ' || lv2_daytime_clause_sub;
          lv2_where_clause_per:=lv2_where_clause || CHR(10) || 'AND ' || lv2_daytime_clause_per;
          lv2_where_clause_count:=lv2_where_clause || CHR(10) || 'AND ' || lv2_daytime_clause_per;
          lv2_where_clause   := lv2_where_clause || CHR(10) || 'AND ' || lv2_daytime_clause;
       END IF;

       lv2_row_cache_key := lv2_row_cache_key || '||p_compare_oper';
    ELSE
       IF lv2_where_clause IS NULL THEN
          lv2_where_clause_m := null;
          lv2_where_clause_y := null;
          lv2_where_clause_t := null;
          lv2_where_clause_p := null;
          lv2_where_clause_n := null;
          lv2_where_clause_pe:= null;
          lv2_where_clause_ne:= null;
          lv2_where_clause_sub:= null;
          lv2_where_clause   := null;
          lv2_where_clause_per:= null;
          lv2_where_clause_count:= null;
       ELSE
          lv2_where_clause_m := lv2_where_clause;
          lv2_where_clause_y := lv2_where_clause;
          lv2_where_clause_t := lv2_where_clause;
          lv2_where_clause_p := lv2_where_clause;
          lv2_where_clause_n := lv2_where_clause;
          lv2_where_clause_pe:= lv2_where_clause;
          lv2_where_clause_ne:= lv2_where_clause;
          lv2_where_clause_sub:= lv2_where_clause;
          lv2_where_clause   := lv2_where_clause;
          lv2_where_clause_per:= lv2_where_clause;
          lv2_where_clause_count:= lv2_where_clause;
       END IF;
    END IF;

    ------------------------------------------------------------
    -- CREATE COMMON CURSORS, IF TABLE CONTAINS 'DAYTIME'
    ------------------------------------------------------------
    IF lv2_daytime = 'Y' THEN

      ------------------------------------------------------------
      -- cursor for daytime = v_daytime
      ------------------------------------------------------------
      IF lv2_summer_time_flag = 'Y' then
         lv2_parameter_list_s := substr(lv2_parameter_list,1, LENGTH(lv2_parameter_list)-1) ||','|| CHR(10) || '          p_summertime VARCHAR2 DEFAULT NULL)';
         lv2_where_clause_s := lv2_where_clause ||CHR(10) || 'AND SUMMER_TIME = nvl(p_summertime, SUMMER_TIME)' || CHR(10) ||'ORDER BY SUMMER_TIME ';
      ELSE
         lv2_parameter_list_s := lv2_parameter_list;
         lv2_where_clause_s := lv2_where_clause;
      END IF;

      addBodyLine(
          P_DASHED_LINE ||
          'CURSOR c_equal ' || lv2_parameter_list_s ||' IS '|| CHR(10) ||
          '   SELECT * ' || CHR(10) ||
          '   FROM ' || tbl.ctrlObj.object_name || CHR(10) ||
          '   ' || lv2_where_clause_s || ';' || CHR(10));

      ------------------------------------------------------------
      -- cursor for daytime <= v_daytime
      ------------------------------------------------------------
      IF lb_version_table = 'N' THEN
            addBodyLine(
              P_DASHED_LINE ||
              'CURSOR c_less_equal ' || lv2_parameter_list_s ||' IS '|| CHR(10) ||
              '   SELECT * ' || CHR(10) ||
              '   FROM ' || tbl.ctrlObj.object_name || CHR(10) ||
              '   ' || lv2_where_clause_sub || CHR(10) ||
              '     (SELECT max(daytime) ' || CHR(10) ||
              '      FROM '|| tbl.ctrlObj.object_name || CHR(10) ||
              '      ' || lv2_where_clause_pe || ');' || CHR(10));
        ELSE
            addBodyLine(
              P_DASHED_LINE ||
              'CURSOR c_less_equal ' || lv2_parameter_list_s ||' IS '|| CHR(10) ||
              '   SELECT * ' || CHR(10) ||
              '   FROM ' || tbl.ctrlObj.object_name || CHR(10) ||
              '   WHERE object_id = p_object_id' || CHR(10) ||
              '   AND p_daytime >= daytime' || CHR(10) ||
              '   AND p_daytime  < nvl(end_date,p_daytime+1);' || CHR(10));
      END IF;

      ------------------------------------------------------------
      -- cursor for daytime < v_daytime
      ------------------------------------------------------------
      IF lb_version_table = 'N' THEN
            addBodyLine(
              P_DASHED_LINE ||
              'CURSOR c_less ' || lv2_parameter_list_s ||' IS '|| CHR(10) ||
              '   SELECT * ' || CHR(10) ||
              '   FROM ' || tbl.ctrlObj.object_name || CHR(10) ||
              '   ' || lv2_where_clause_sub || CHR(10) ||
              '     (SELECT max(daytime) ' || CHR(10) ||
              '      FROM '|| tbl.ctrlObj.object_name || CHR(10) ||
              '      ' || lv2_where_clause_p || ');' || CHR(10));
      ELSE
            addBodyLine(
              P_DASHED_LINE ||
              'CURSOR c_less ' || lv2_parameter_list_s ||' IS '|| CHR(10) ||
              '   SELECT * ' || CHR(10) ||
              '   FROM ' || tbl.ctrlObj.object_name || CHR(10) ||
              '   WHERE object_id = p_object_id' || CHR(10) ||
              '   AND daytime < p_daytime' || CHR(10) ||
              '   AND nvl(end_date,p_daytime) >= p_daytime;' || CHR(10));

      END IF;

        ------------------------------------------------------------
        -- cursor for daytime >= v_daytime
        ------------------------------------------------------------
        addBodyLine(
          P_DASHED_LINE ||
          'CURSOR c_greater_equal ' || lv2_parameter_list_s ||' IS '|| CHR(10) ||
          '   SELECT * ' || CHR(10) ||
          '   FROM ' || tbl.ctrlObj.object_name || CHR(10) ||
          '   ' || lv2_where_clause_sub || CHR(10) ||
          '     (SELECT min(daytime) ' || CHR(10) ||
          '      FROM '|| tbl.ctrlObj.object_name || CHR(10) ||
          '      ' || lv2_where_clause_ne || ');' || CHR(10));

        ------------------------------------------------------------
        -- cursor for daytime > v_daytime
        ------------------------------------------------------------
        addBodyLine(
          P_DASHED_LINE ||
          'CURSOR c_greater ' || lv2_parameter_list_s ||' IS '|| CHR(10) ||
          '   SELECT * ' || CHR(10) ||
          '   FROM ' || tbl.ctrlObj.object_name || CHR(10) ||
          '   ' || lv2_where_clause_sub || CHR(10) ||
          '     (SELECT min(daytime) ' || CHR(10) ||
          '      FROM '|| tbl.ctrlObj.object_name || CHR(10) ||
          '      ' || lv2_where_clause_n || ');' || CHR(10));
      END IF;

      ------------------------------------------------------------
      -- CREATE FUNCTION CODE
      ------------------------------------------------------------

      ------------------------------------------------------------
      -- count_rows
      ------------------------------------------------------------
      IF tbl.ctrlObj.math = 'Y' AND hasPkColumn('DAYTIME') = 'Y' THEN
         addHeaderLine(getFnSignature('count_rows', lv2_parameter_list_count, 'NUMBER')||';'||CHR(10));
         addBodyLine(getFnSignature('count_rows', lv2_parameter_list_count, 'NUMBER', CHR(10))||
                     getCountFnBody(tbl.ctrlObj.object_name, lv2_where_clause_count));
      END IF;

      ------------------------------------------------------------
      -- period functions
      ------------------------------------------------------------
      IF tbl.ctrlObj.math = 'Y' AND hasPkColumn('DAYTIME') = 'Y' THEN
        FOR i IN 1..tbl.cols.COUNT LOOP
          IF tbl.cols(i).data_type = 'NUMBER' AND Upper(tbl.cols(i).column_name) <> 'REV_NO' THEN
            lv2_fn_name := 'math_'||Lower(tbl.alias(tbl.cols(i).column_name));
            addHeaderLine(getFnSignature(lv2_fn_name, lv2_parameter_list_period, 'NUMBER')||';'||CHR(10));
            addBodyLine(getFnSignature(lv2_fn_name, lv2_parameter_list_period, 'NUMBER')||CHR(10)||
                        getMathFnBody(
                                   tbl.ctrlObj.object_name,
                                   tbl.cols(i).column_name,
                                   'math_'||Lower(tbl.alias(tbl.cols(i).column_name)),
                                   lv2_where_clause_per));
          END IF;
        END LOOP;
      END IF;

      ------------------------------------------------------------
      -- cummulative
      ------------------------------------------------------------
      FOR i IN 1..tbl.genFns.COUNT LOOP
        IF tbl.genFns(i).mtd_cumulative = 'Y' THEN
           lv2_fn_name := 'cumm_'||lower(tbl.alias(tbl.genFns(i).column_name));
           addHeaderLine(getFnSignature(lv2_fn_name, lv2_parameter_list, 'NUMBER')||';'||CHR(10));
           addBodyLine(getFnSignature(lv2_fn_name, lv2_parameter_list, 'NUMBER', CHR(10)) ||  ' ' ||
                getCumFnBody(tbl.genFns(i), lv2_where_clause_m, lv2_fn_name));
        END IF;
      END LOOP;

      FOR i IN 1..tbl.genFns.COUNT LOOP
        IF tbl.genFns(i).ytd_cumulative = 'Y' THEN
           lv2_fn_name := 'cumy_'||lower(tbl.alias(tbl.genFns(i).column_name));
           addHeaderLine(getFnSignature(lv2_fn_name, lv2_parameter_list, 'NUMBER')||';'||CHR(10));
           addBodyLine(getFnSignature(lv2_fn_name, lv2_parameter_list, 'NUMBER', CHR(10)) || ' ' ||
                getCumFnBody(tbl.genFns(i), lv2_where_clause_y, lv2_fn_name));
        END IF;
      END LOOP;

      FOR i IN 1..tbl.genFns.COUNT LOOP
        IF tbl.genFns(i).ttd_cumulative = 'Y' THEN
           lv2_fn_name := 'cumt_'||lower(tbl.alias(tbl.genFns(i).column_name));
           addHeaderLine(getFnSignature(lv2_fn_name, lv2_parameter_list, 'NUMBER')||';'||CHR(10));
           addBodyLine(
                getFnSignature(lv2_fn_name, lv2_parameter_list, 'NUMBER', CHR(10)) || ' ' ||
                getCumFnBody(tbl.genFns(i), lv2_where_clause_t, lv2_fn_name));
        END IF;
       END LOOP;

       ------------------------------------------------------------
       -- average
       ------------------------------------------------------------
       FOR i IN 1..tbl.genFns.COUNT LOOP
         IF tbl.genFns(i).mtd_average = 'Y' THEN
             lv2_fn_name := 'avem_'||lower(tbl.alias(tbl.genFns(i).column_name));
             addHeaderLine(getFnSignature(lv2_fn_name, lv2_parameter_list, 'NUMBER')||';'||CHR(10));
             addBodyLine(
                   getFnSignature(lv2_fn_name, lv2_parameter_list, 'NUMBER', CHR(10))|| ' ' ||
                   getAveFnBody(tbl.genFns(i),
                                   lv2_where_clause_m,
                                   lv2_fn_name));
         END IF;
       END LOOP;

       FOR i IN 1..tbl.genFns.COUNT LOOP
         IF tbl.genFns(i).ytd_average = 'Y' THEN
            lv2_fn_name := 'avey_'||lower(tbl.alias(tbl.genFns(i).column_name));
            addHeaderLine(getFnSignature(lv2_fn_name, lv2_parameter_list, 'NUMBER')||';'||CHR(10));
            addBodyLine(
                getFnSignature(lv2_fn_name, lv2_parameter_list, 'NUMBER', CHR(10))|| ' ' ||
                getAveFnBody(tbl.genFns(i),
                                   lv2_where_clause_y,
                                   lv2_fn_name));
         END IF;
       END LOOP;

       FOR i IN 1..tbl.genFns.COUNT LOOP
         IF tbl.genFns(i).ttd_average = 'Y' THEN
             lv2_fn_name := 'avet_'||lower(tbl.alias(tbl.genFns(i).column_name));
             addHeaderLine(getFnSignature(lv2_fn_name, lv2_parameter_list, 'NUMBER')||';'||CHR(10));
             addBodyLine(
                getFnSignature(lv2_fn_name, lv2_parameter_list, 'NUMBER', CHR(10))|| ' ' ||
                getAveFnBody(tbl.genFns(i),
                                   lv2_where_clause_t,
                                   lv2_fn_name));
         END IF;
       END LOOP;

       IF hasColumn('DAYTIME') = 'Y' THEN
          ------------------------------------------------------------
          -- prev_daytime
          ------------------------------------------------------------
          lv2_fn_name := 'prev_daytime';
          addHeaderLine(getFnSignature(lv2_fn_name, lv2_parameter_list_n_rows, 'DATE')||';'||CHR(10));
          addBodyLine(
                getFnSignature(lv2_fn_name, lv2_parameter_list_n_rows, 'DATE', CHR(10))||' '||
                getDaytimeFnBody(
                      tbl.ctrlObj.object_name,
                      'DESC',
                      lv2_where_clause_p,
                      lv2_fn_name)
                  );

          ------------------------------------------------------------
          -- prev_equal_daytime
          ------------------------------------------------------------
          lv2_fn_name := 'prev_equal_daytime';
          addHeaderLine(getFnSignature(lv2_fn_name, lv2_parameter_list_n_rows, 'DATE')||';'||CHR(10));
          addBodyLine(
                getFnSignature(lv2_fn_name, lv2_parameter_list_n_rows, 'DATE', CHR(10))||' '||
                getDaytimeFnBody(
                      tbl.ctrlObj.object_name,
                      'DESC',
                      lv2_where_clause_pe,
                      lv2_fn_name)
                  );

          ------------------------------------------------------------
          -- next_daytime
          ------------------------------------------------------------
          lv2_fn_name := 'next_daytime';
          addHeaderLine(getFnSignature(lv2_fn_name, lv2_parameter_list_n_rows, 'DATE')||';'||CHR(10));
          addBodyLine(
                getFnSignature(lv2_fn_name, lv2_parameter_list_n_rows, 'DATE', CHR(10))||' '||
                getDaytimeFnBody(
                      tbl.ctrlObj.object_name,
                      'ASC',
                      lv2_where_clause_n,
                      lv2_fn_name)
                  );

          ------------------------------------------------------------
          -- next_equal_daytime
          ------------------------------------------------------------
          lv2_fn_name := 'next_equal_daytime';
          addHeaderLine(getFnSignature(lv2_fn_name, lv2_parameter_list_n_rows, 'DATE')||';'||CHR(10));
          addBodyLine(
                getFnSignature(lv2_fn_name, lv2_parameter_list_n_rows, 'DATE', CHR(10))||' '||
                getDaytimeFnBody(
                      tbl.ctrlObj.object_name,
                      'ASC',
                      lv2_where_clause_ne,
                      lv2_fn_name)
                  );
        END IF;

        IF hasPkColumn('OBJECT_ID') = 'Y' AND tbl.pk_cols.COUNT = 1 THEN
            -- OBJECT_ID is the only PK column
            --
            IF hasUkColumn('OBJECT_CODE') = 'Y' THEN
               -- We have a unique constraint that includes OBJECT_CODE
               --
               addHeaderLine(CHR(10) || getObjectIdFunction(tbl, 'HEAD'));
               addBodyLine(getObjectIdFunction(tbl, 'BODY'));
            END IF;
        END IF;

        IF lv2_daytime = 'Y' THEN
            IF lv2_summer_time_flag = 'Y' then
                   lv2_parameter_list_oper_s := substr(lv2_parameter_list_oper,1, LENGTH(lv2_parameter_list_oper)-1) ||','|| CHR(10) || '        p_summertime VARCHAR2 DEFAULT NULL)';
                   lv2_parameter_list_cursor_s := substr(lv2_parameter_list_cursor,1, LENGTH(lv2_parameter_list_cursor)-1) ||','|| CHR(10) || '        p_summertime)';
                   lv2_row_cache_key := lv2_row_cache_key || '||p_summertime';
            ELSE
                   lv2_parameter_list_oper_s := lv2_parameter_list_oper;
                   lv2_parameter_list_cursor_s := lv2_parameter_list_cursor;
            END IF;

            lv2_fn_name := 'row_by_rel_operator';
            lv2_fn_type := tbl.ctrlObj.object_name || '%ROWTYPE';
            addHeaderLine(getFnSignature(lv2_fn_name, lv2_parameter_list_oper_s, lv2_fn_type)||';'||CHR(10));
            addBodyLine(
                  getFnSignature(lv2_fn_name, lv2_parameter_list_oper_s, lv2_fn_type, CHR(10))||CHR(10)||
                  getRowByRelOpFnBody(
                      tbl.ctrlObj.object_name,
                      lv2_row_cache_key,
                      lv2_parameter_list_cursor_s
                  ));

            ------------------------------------------------------------
            -- single columns, if daytime is present
            ------------------------------------------------------------
            FOR i IN 1..tbl.cols.COUNT LOOP
               IF tbl.cols(i).column_name NOT IN ('REV_NO','REV_TEXT','CREATED_BY','CREATED_DATE','LAST_UPDATED_BY','LAST_UPDATED_DATE') AND
                  hasPkColumn(tbl.cols(i).column_name) = 'N' THEN
                  lv2_fn_name := Lower(tbl.alias(tbl.cols(i).column_name));
                  lv2_fn_type := tbl.ctrlObj.object_name || '.' || tbl.cols(i).column_name || '%TYPE';
                  addHeaderLine(getFnSignature(lv2_fn_name, lv2_parameter_list_oper_s, lv2_fn_type)||';'||CHR(10));
                  addBodyLine(
                      getFnSignature(lv2_fn_name, lv2_parameter_list_oper_s, lv2_fn_type, CHR(10))||' '||
                      getColumnFunctionDtBody(
                              CASE WHEN lb_version_table = 'Y' THEN TRUE ELSE FALSE END,
                              tbl.ctrlObj.object_name,
                              tbl.cols(i).column_name,
                              lv2_where_clause_s,
                              lv2_where_clause_pe,
                              lv2_where_clause_p,
                              lv2_where_clause_ne,
                              lv2_where_clause_n,
                              lv2_where_clause_sub,
                              Lower(tbl.alias(tbl.cols(i).column_name))));
               END IF;
            END LOOP;

        ------------------------------------------------------------
        -- rowtype, if daytime is present
        ------------------------------------------------------------
            IF tbl.ctrlObj.view_pk_table_name IS NULL THEN
               lv2_fn_name := 'row_by_pk';
               lv2_fn_type := tbl.ctrlObj.object_name || '%ROWTYPE';
               addHeaderLine(getFnSignature(lv2_fn_name, lv2_parameter_list_oper, lv2_fn_type)||';'||CHR(10));
               addBodyLine(getFnSignature(lv2_fn_name, lv2_parameter_list_oper, lv2_fn_type, CHR(10)) ||' '||getRowByPkFunctionDtBody(lv2_par_list_cursor_func));
            END IF;
     ELSE
            ------------------------------------------------------------
            -- single columns, if daytime is not present
            ------------------------------------------------------------
        FOR i IN 1..tbl.cols.COUNT LOOP
           IF tbl.cols(i).column_name NOT IN ('REV_NO','REV_TEXT','CREATED_BY','CREATED_DATE','LAST_UPDATED_BY','LAST_UPDATED_DATE') AND
              hasPkColumn(tbl.cols(i).column_name) = 'N' THEN
               lv2_fn_name := Lower(tbl.alias(tbl.cols(i).column_name));
               lv2_fn_type := tbl.ctrlObj.object_name || '.' || tbl.cols(i).column_name || '%TYPE';
               addHeaderLine(getFnSignature(lv2_fn_name, lv2_parameter_list, lv2_fn_type)||';'||CHR(10));
               addBodyLine(
                  getFnSignature(lv2_fn_name, lv2_parameter_list, lv2_fn_type, CHR(10)) || ' ' ||
                  getColumnFnBody(
                          lv2_table_name,
                          tbl.cols(i).column_name,
                          lv2_where_clause,
                          Lower(tbl.alias(tbl.cols(i).column_name))));
           END IF;
        END LOOP;

        ------------------------------------------------------------
        -- rowtype
        ------------------------------------------------------------
        IF tbl.ctrlObj.view_pk_table_name IS NULL THEN
           lv2_fn_name := 'row_by_pk';
           lv2_fn_type := tbl.ctrlObj.object_name || '%ROWTYPE';
           addHeaderLine(getFnSignature(lv2_fn_name, lv2_parameter_list, lv2_fn_type)||';'||CHR(10));
           addBodyLine(
                  getFnSignature(lv2_fn_name, lv2_parameter_list, lv2_fn_type, CHR(10)) || ' ' ||
                  getRowByPkFnBody(
                          lv2_table_name,
                          lv2_row_cache_key,
                          lv2_where_clause));
              IF hasPkColumn('OBJECT_ID') = 'Y' AND tbl.pk_cols.COUNT = 1 THEN
                  lv2_fn_name := 'row_by_object_id';
                  lv2_fn_type := tbl.table_name || '%ROWTYPE';
                  addHeaderLine(getFnSignature(lv2_fn_name, '(p_object_id VARCHAR2)', lv2_fn_type)||';'||CHR(10));
                  addBodyLine(
                    getFnSignature(lv2_fn_name, '(p_object_id VARCHAR2)', lv2_fn_type, CHR(10))||' '||
                    getRowByObjectIdFnBody(lv2_table_name));
              END IF;
        END IF;
        END IF;

        ------------------------------------------------------------
        -- flush_row_cache
        ------------------------------------------------------------
        addHeaderLine(P_DASHED_LINE || 'PROCEDURE flush_row_cache;'||CHR(10)||CHR(10));
        addBodyLine(CHR(10)||P_DASHED_LINE||
q'[PROCEDURE flush_row_cache IS
BEGIN
   sg_row_cache.DELETE;
END flush_row_cache;

]');

        ------------------------------------------------------------
        -- CREATE PACKAGE FOOTER
        ------------------------------------------------------------
        addHeaderLine(CHR(10)||'END ec_'||lv2_package_name||';');
        addBodyLine('END ec_' || lv2_package_name || ';');

        buildPackageHeader('EC_' || lv2_package_name);
        buildPackageBody('EC_' || lv2_package_name);
END generatePackage;

----------------------------------------------------------------------------------
-- Return TRUE if the given table is on the "exception list"
----------------------------------------------------------------------------------
FUNCTION isExceptionTable(p_table_name IN VARCHAR2)
RETURN BOOLEAN
IS
   ln_count NUMBER := 0;
BEGIN
   SELECT count(*) INTO ln_count 
   FROM   ctrl_object 
   WHERE  object_name = p_table_name 
   AND    nvl(pinc_trigger_ind, 'Y') = 'N'; 
   RETURN ln_count > 0 OR p_table_name = 'CTRL_OBJECT' OR p_table_name = 'CTRL_PINC';
END isExceptionTable;

----------------------------------------------------------------------------------
-- Return TRUE if the given trigger exists
----------------------------------------------------------------------------------
FUNCTION existsTrigger(p_trigger_name IN VARCHAR2)
RETURN BOOLEAN
IS
   ln_count NUMBER := 0;
BEGIN
   SELECT count(*) INTO ln_count 
   FROM   user_triggers 
   WHERE  trigger_name = p_trigger_name; 
   RETURN ln_count > 0;
END existsTrigger;

----------------------------------------------------------------------------------------
-- DATE column in PINC triggers
----------------------------------------------------------------------------------------
FUNCTION pincTriggerDateColumn(p_column_name IN VARCHAR2, p_old_or_new IN VARCHAR2, p_is_key IN VARCHAR2, p_col_prefix IN VARCHAR2)
RETURN VARCHAR2
IS
   lv2_line VARCHAR2(1000);
BEGIN
   lv2_line := q'[        dbms_lob.append(lcl_row,utl_raw.cast_to_raw(']'||p_column_name||q'[='|| to_char(:]'||p_old_or_new||'.'||p_column_name||q'[,'yyyy.mm.dd hh24:mi:ss') ||';'));
]';
   IF p_is_key = 'Y' THEN
      lv2_line := lv2_line || '        ' || p_col_prefix || 'to_char('||p_column_name||',''''yyyy.mm.dd hh24:mi:ss'''')=''''''|| to_char(:'||p_old_or_new||'.'||p_column_name||',''yyyy.mm.dd hh24:mi:ss'') || '''''''';'||CHR(10);
   END IF;
   RETURN lv2_line;
END pincTriggerDateColumn;

----------------------------------------------------------------------------------------
-- NUMBER column in PINC triggers
----------------------------------------------------------------------------------------
FUNCTION pincTriggerNumberColumn(p_column_name IN VARCHAR2, p_old_or_new IN VARCHAR2, p_is_key IN VARCHAR2, p_col_prefix IN VARCHAR2)
RETURN VARCHAR2
IS
   lv2_line VARCHAR2(1000);
BEGIN
   lv2_line := q'[        dbms_lob.append(lcl_row,utl_raw.cast_to_raw(']'||p_column_name||q'[='|| TO_CHAR(:]'||p_old_or_new||'.'||p_column_name||q'[,'9999999999999999D9999999999','NLS_NUMERIC_CHARACTERS=''.,''') ||';'));
]';
   IF p_is_key = 'Y' THEN
      lv2_line := lv2_line || '        ' || p_col_prefix || p_column_name||'=''|| to_char(:'||p_old_or_new||'.'||p_column_name||',''9999999999999999D9999999999'',''NLS_NUMERIC_CHARACTERS=''''.,'''''');'||CHR(10);
   END IF;
   RETURN lv2_line;
END pincTriggerNumberColumn;

----------------------------------------------------------------------------------------
-- VARCHAR column in PINC triggers
----------------------------------------------------------------------------------------
FUNCTION pincTriggerTextColumn(p_column_name IN VARCHAR2, p_old_or_new IN VARCHAR2, p_is_key IN VARCHAR2, p_col_prefix IN VARCHAR2)
RETURN VARCHAR2
IS
   lv2_line VARCHAR2(1000);
BEGIN
   lv2_line := q'[        dbms_lob.append(lcl_row,utl_raw.cast_to_raw(']'||p_column_name||q'[='|| Replace(:]'||p_old_or_new||'.'||p_column_name||q'[,CHR(39),CHR(39)||CHR(39)) ||';'));
]';
   IF p_is_key = 'Y' THEN
      lv2_line := lv2_line || '        ' || p_col_prefix || p_column_name||'=''''''|| Replace(:new'||'.'||p_column_name||',CHR(39),CHR(39)||CHR(39)) ||'''''''';'||CHR(10);
   END IF;
   RETURN lv2_line;
END pincTriggerTextColumn;

----------------------------------------------------------------------------------------
-- Build journal trigger for "current table"
----------------------------------------------------------------------------------------
PROCEDURE buildJournalTrigger
IS
   lv_code DBMS_SQL.varchar2a;
   lv2_cols VARCHAR2(30000);
   lv2_vals VARCHAR2(30000);
   lv2_trigger_name VARCHAR2(30) := 'JN_'||substr(tbl.table_name, 1, 25);
BEGIN
   lv2_cols := 'jn_operation, jn_oracle_user, jn_datetime, jn_notes'||CHR(10);
   lv2_vals := 'lv2_operation, lv2_last_updated_by, EcDp_Date_Time.getCurrentSysdate, EcDp_User_Session.getUserSessionParameter(''JN_NOTES'') ' || CHR(10);
   FOR i IN 1..tbl.cols.COUNT LOOP
      IF hasJnColumn(tbl.cols(i).column_name) = 'Y' THEN
        lv2_cols := lv2_cols || '       ,' || tbl.cols(i).column_name || CHR(10);
        lv2_vals := lv2_vals || '       ,:old.' || tbl.cols(i).column_name || CHR(10);
      END IF;
   END LOOP;

   EcDp_DynSql.AddSqlLineNoWrap(lv_code, 'CREATE OR REPLACE TRIGGER ' || lv2_trigger_name || CHR(10));
   EcDp_DynSql.AddSqlLineNoWrap(lv_code, 'AFTER UPDATE OR DELETE ON ' || tbl.table_name || CHR(10));
   EcDp_DynSql.AddSqlLineNoWrap(lv_code, 'FOR EACH ROW ' || CHR(10));
   EcDp_DynSql.AddSqlLineNoWrap(lv_code, q'[DECLARE
   lv2_operation char(3);
   lv2_last_updated_by VARCHAR2(30);
BEGIN
   IF (Nvl(:new.rev_no, 0) <> :old.rev_no) OR (Deleting) THEN
   IF Deleting THEN
     lv2_operation := 'DEL';
     lv2_last_updated_by := Nvl(EcDp_User_Session.getUserSessionParameter('USERNAME'), User);
   ELSE
     lv2_operation := 'UPD';
     lv2_last_updated_by := :new.last_updated_by;
   END IF;
]');
   EcDp_DynSql.AddSqlLineNoWrap(lv_code,
       '     INSERT INTO ' || tbl.table_name || '_JN' || CHR(10) ||
       '     ('||lv2_cols||')'||CHR(10)||'VALUES'||CHR(10)||'('||lv2_vals||');'||CHR(10) ||
       'END IF;' ||CHR(10) ||
       'END;');

   Ecdp_Dynsql.SafeBuildSupressErrors(lv2_trigger_name, 'TRIGGER', lv_code, 'EC_TRIGGERS');

   lv_code.DELETE;
END buildJournalTrigger;

----------------------------------------------------------------------------------------
-- Build PINC trigger for "current table"
----------------------------------------------------------------------------------------
PROCEDURE buildPINCTrigger
IS
   lv_code DBMS_SQL.varchar2a;
   lv2_trigger_name VARCHAR2(30) := 'AP_'||substr(tbl.table_name, 1, 27);
   lv2_is_pk_column VARCHAR2(1);
   lv_ins_or_upd_code DBMS_SQL.varchar2a;
   lv_del_code DBMS_SQL.varchar2a;
   lv2_col_prefix VARCHAR2(1000) := NULL;
BEGIN
   IF isExceptionTable(tbl.table_name) AND NOT existsTrigger(lv2_trigger_name) THEN
      RETURN;
   END IF;

   FOR i IN 1..tbl.cols.COUNT LOOP
     IF tbl.cols(i).data_type NOT IN ('CLOB','BLOB','LONG') AND
        tbl.cols(i).column_name NOT IN ('RECORD_STATUS','CREATED_BY','CREATED_DATE','LAST_UPDATED_BY','LAST_UPDATED_DATE','REV_NO','REV_TEXT','REC_ID') THEN
          lv2_is_pk_column := hasPkColumn(tbl.cols(i).column_name);
          IF lv2_is_pk_column = 'Y' THEN
            IF lv2_col_prefix IS NULL THEN
               lv2_col_prefix := 'lv2_key := ''';
            ELSE
               lv2_col_prefix := 'lv2_key := lv2_key ||'' AND ';
            END IF;
          END IF;

          IF tbl.cols(i).data_type = 'DATE' THEN
             Ecdp_Dynsql.AddSqlLineNoWrap(lv_ins_or_upd_code, pincTriggerDateColumn(tbl.cols(i).column_name, 'new', lv2_is_pk_column, lv2_col_prefix));
             Ecdp_Dynsql.AddSqlLineNoWrap(lv_del_code, pincTriggerDateColumn(tbl.cols(i).column_name, 'old', lv2_is_pk_column, lv2_col_prefix));
          ELSIF tbl.cols(i).data_type = 'NUMBER' THEN
             Ecdp_Dynsql.AddSqlLineNoWrap(lv_ins_or_upd_code, pincTriggerNumberColumn(tbl.cols(i).column_name, 'new', lv2_is_pk_column, lv2_col_prefix));
             Ecdp_Dynsql.AddSqlLineNoWrap(lv_del_code, pincTriggerNumberColumn(tbl.cols(i).column_name, 'old', lv2_is_pk_column, lv2_col_prefix));
          ELSE
             Ecdp_Dynsql.AddSqlLineNoWrap(lv_ins_or_upd_code, pincTriggerTextColumn(tbl.cols(i).column_name, 'new', lv2_is_pk_column, lv2_col_prefix));
             Ecdp_Dynsql.AddSqlLineNoWrap(lv_del_code, pincTriggerTextColumn(tbl.cols(i).column_name, 'old', lv2_is_pk_column, lv2_col_prefix));
          END IF;
     END IF;
   END LOOP;

   EcDp_DynSql.AddSqlLineNoWrap(lv_code,
               'CREATE OR REPLACE TRIGGER ' || lv2_trigger_name || CHR(10) ||
               'AFTER INSERT OR UPDATE OR DELETE ON ' || tbl.table_name || CHR(10) ||
               'FOR EACH ROW' || CHR(10) ||
q'[  DECLARE
    CURSOR c_pinc_trigger_ind IS 
      SELECT pinc_trigger_ind 
      FROM   ctrl_object
      WHERE  object_name=']'||tbl.table_name||q'[' AND pinc_trigger_ind='N';

    lv2_InstallModeTag varchar2(240);
    lcl_row BLOB;
    lv2_key VARCHAR2(4000);
    lv2_operation VARCHAR2(30);
    lv2_pinc_trigger_ind VARCHAR2(1) := 'Y';
BEGIN
    -- Note, this is a autogenerated trigger, do not put handcoded logic here.
    lv2_InstallModeTag := ecdp_pinc.getInstallModeTag;

    IF lv2_InstallModeTag IS NOT NULL THEN
      FOR cur IN c_pinc_trigger_ind LOOP
        lv2_pinc_trigger_ind := cur.pinc_trigger_ind;
      END LOOP;
      -- 
      -- NOTE: No pinc logging in install mode if ctrl_object.pinc_trigger_ind = 'N' (defaults to 'Y')
      -- 
      IF nvl(lv2_pinc_trigger_ind, 'Y') <> 'N' THEN 
        dbms_lob.createtemporary(lcl_row, TRUE, dbms_lob.CALL);
        lv2_key := NULL;

        IF INSERTING OR UPDATING THEN
]');

   EcDp_DynSql.AddSqlLinesNoWrap(lv_code, lv_ins_or_upd_code);

   EcDp_DynSql.AddSqlLineNoWrap(lv_code, '       ELSE'||CHR(10));

   EcDp_DynSql.AddSqlLinesNoWrap(lv_code, lv_del_code);

   EcDp_DynSql.AddSqlLineNoWrap(lv_code, q'[

        END IF;

        IF INSERTING THEN
          lv2_operation := 'INSERTING';
        ELSIF UPDATING THEN
          lv2_operation := 'UPDATING';
        ELSE
          lv2_operation := 'DELETING';
        END IF;

        EcDp_PInC.logTableContent(']'||tbl.table_name||q'['
                          ,lv2_operation
                          ,lv2_key
                          ,lcl_row);
      END IF;
    END IF;
END;]');

   Ecdp_Dynsql.SafeBuildSupressErrors(lv2_trigger_name, 'TRIGGER', lv_code, 'EC_TRIGGERS');
   
   lv_code.DELETE;

   IF isExceptionTable(tbl.table_name) AND existsTrigger(lv2_trigger_name) THEN
     EcDp_DynSql.execute_statement('ALTER TRIGGER '||lv2_trigger_name||' DISABLE');
   END IF; 
   
END buildPINCTrigger;

----------------------------------------------------------------------------------------
-- Build IU trigger for "current table"
----------------------------------------------------------------------------------------
PROCEDURE buildIUTrigger
IS
   lv2_trigger_body VARCHAR2(4000);
   lv2_sys_guid VARCHAR2(2000);
   lv2_daytime VARCHAR2(240);
   lv2_day VARCHAR2(240);
   lv2_dayhr VARCHAR2(240);
   lv2_trigger_name VARCHAR2(30) := substr('IU_'||tbl.table_name, 1, 30);
BEGIN
   IF hasColumn('REV_NO') <> 'Y' THEN
      RETURN;
   END IF;

   lv2_sys_guid := NULL;

   IF hasColumn('OBJECT_ID') = 'Y' AND
      tbl.isNullable('OBJECT_ID') = 'N' AND
      tbl.dataType('OBJECT_ID') = 'VARCHAR2' AND
      hasFkColumn('OBJECT_ID') = 'N' AND
      hasPkColumn('OBJECT_ID') = 'Y' AND tbl.pk_cols.COUNT = 1 THEN
      -- The original criterion also supported OBJECT_ID as a unique constraint
      -- We have no unique constraints with OBJECT_ID as the only column, though.
      lv2_sys_guid := '      IF :new.object_id IS NULL THEN' || CHR(10) ||
                      '         :new.object_id := SYS_GUID();'  || chr(10) ||
                      '      END IF;' || chr(10);
   END IF;

   lv2_daytime := NULL;
   lv2_day := NULL;
   lv2_dayhr := NULL;

   IF lv2_sys_guid IS NULL THEN
      FOR i IN 1..tbl.cols.COUNT LOOP
         IF tbl.cols(i).column_name = 'DAYTIME' THEN
            IF INSTR(tbl.table_name,'_DAY_') > 0 AND INSTR(tbl.table_name,'_SUB_') < 1 THEN
               lv2_daytime := '      :new.daytime := trunc(:new.daytime,''DD'');' || chr(10);
            ELSIF INSTR(tbl.table_name,'_MTH_') > 0 THEN
               lv2_daytime := '      :new.daytime := trunc(:new.daytime,''MM'');' || chr(10);
            END IF;
         ELSIF tbl.cols(i).column_name = 'DAY' THEN
            IF (INSTR(tbl.table_name,'_DAY_') + INSTR(tbl.table_name,'_MTH_')) < 1 AND SUBSTR(tbl.table_name,1,5) <> 'CTRL_' THEN
               lv2_day := '      :new.day := trunc(:new.daytime,''DD'');' || chr(10);
            END IF;
         ELSIF tbl.cols(i).column_name = 'DAYHR' THEN
            IF (INSTR(tbl.table_name,'_DAY_') + INSTR(tbl.table_name,'_MTH_')) < 1 AND SUBSTR(tbl.table_name,1,5) <> 'CTRL_' THEN
               lv2_dayhr := '      :new.dayhr := trunc(:new.daytime,''HH24'');' || chr(10);
            END IF;
         END IF;
      END LOOP;
   END IF;

   lv2_trigger_body := 'CREATE OR REPLACE TRIGGER ' || lv2_trigger_name || chr(10) ||
                       'BEFORE INSERT OR UPDATE ON ' || tbl.table_name || chr(10) ||
                       'FOR EACH ROW'||CHR(10)||
q'[BEGIN
    -- Basis
    IF Inserting THEN
]' || lv2_daytime ||  lv2_day ||  lv2_dayhr || q'[
      :new.record_status := nvl(:new.record_status, 'P');
]' || lv2_sys_guid || q'[
      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;
      IF :new.created_date IS NULL THEN
         :new.created_date := EcDp_Date_Time.getCurrentSysdate;
      END IF;
      :new.rev_no := 0;
    ELSE
      IF Nvl(:new.record_status,'P') = Nvl(:old.record_status,'P') THEN
         IF NOT UPDATING('LAST_UPDATED_BY') THEN
            :new.last_updated_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
         END IF;
         IF NOT UPDATING('LAST_UPDATED_DATE') THEN
           :new.last_updated_date := EcDp_Date_Time.getCurrentSysdate;
         END IF;
      END IF;
    END IF;
END;]';
   buildTrigger(lv2_trigger_name, lv2_trigger_body);
END buildIUTrigger;

----------------------------------------------------------------------------------------
-- Build AIUDT trigger
----------------------------------------------------------------------------------------
PROCEDURE buildAiudtTrigger
IS
   lv2_trigger_name VARCHAR2(30) := SUBSTR('AIUDT_'||tbl.table_name, 1, 30);
   lb_is_object_table BOOLEAN;
   lb_is_object_version_table BOOLEAN;
   lb_has_class_name_column BOOLEAN;

BEGIN
   lb_is_object_table :=
                      tbl.table_name NOT LIKE '%/_JN' ESCAPE '/' AND
                      tbl.table_name NOT IN ('OBJECTS_DATA', 'OBJECTS_ATTR_ROW') AND
                      hasColumn('OBJECT_ID') = 'Y' AND
                      hasColumn('OBJECT_CODE') = 'Y' AND
                      hasColumn('START_DATE') = 'Y' AND
                      hasColumn('END_DATE') = 'Y';

   lb_is_object_version_table :=
                      tbl.table_name LIKE '%/_VERSION' ESCAPE '/' AND
                      tbl.table_name NOT IN ('OBJECTS_ATTR_ROW_VERSION', 'OBJECTS_VERSION') AND
                      hasColumn('OBJECT_ID') = 'Y' AND
                      hasColumn('NAME') = 'Y' AND
                      hasColumn('DAYTIME') = 'Y' AND
                      hasColumn('END_DATE') = 'Y';

   lb_has_class_name_column := hasColumn('CLASS_NAME') = 'Y';

   IF lb_is_object_table THEN
      buildTrigger(lv2_trigger_name,
          'CREATE OR REPLACE TRIGGER ' || lv2_trigger_name || CHR(10) ||
          'AFTER INSERT OR UPDATE OR DELETE ON ' || tbl.table_name || CHR(10) ||
          'FOR EACH ROW ' || CHR(10) ||
          'BEGIN ' || CHR(10) ||
          '    IF Inserting THEN' || CHR(10) ||
          '      ec_generate.iudObject(' || CASE WHEN lb_has_class_name_column THEN ' :NEW.class_name, ' ELSE '''' || tbl.table_name || ''', ' END ||
          'NULL, :NEW.object_id, :NEW.object_code, :NEW.start_date, :NEW.end_date, :NEW.created_by, :NEW.created_date);' || CHR(10) ||
          '    ELSIF Updating THEN' || CHR(10) ||
          '      ec_generate.iudObject(' || CASE WHEN lb_has_class_name_column THEN ' :OLD.class_name, ' ELSE '''' || tbl.table_name || ''', ' END ||
          ':OLD.object_id, :NEW.object_id, :NEW.object_code, :NEW.start_date, :NEW.end_date, :NEW.created_by, :NEW.created_date);' || CHR(10) ||
          '    ELSE' || CHR(10) ||
          '      ec_generate.iudObject(' || CASE WHEN lb_has_class_name_column THEN ' :OLD.class_name, ' ELSE '''' || tbl.table_name || ''', ' END ||
          ':OLD.object_id,NULL, :OLD.object_code, :OLD.start_date, :OLD.end_date, :OLD.created_by, :OLD.created_date, FALSE);' || CHR(10) ||
          '    END IF;' || CHR(10) ||
          'END;' || CHR(10));
   ELSIF lb_is_object_version_table THEN
      buildTrigger(lv2_trigger_name,
          'CREATE OR REPLACE TRIGGER ' || lv2_trigger_name || CHR(10) ||
          'AFTER INSERT OR UPDATE OR DELETE ON ' || tbl.table_name || CHR(10) ||
          'FOR EACH ROW ' || CHR(10) ||
          'BEGIN ' || CHR(10) ||
          '    IF Inserting THEN' || CHR(10) ||
          '      ec_generate.iudObjectVersion(''' || tbl.table_name || ''', ' ||
          'NULL, :NEW.object_id, :NEW.name, :NEW.daytime, :NEW.end_date, :NEW.created_by, :NEW.created_date);' || CHR(10) ||
          '    ELSIF Updating THEN' || CHR(10) ||
          '      ec_generate.iudObjectVersion(''' || tbl.table_name || ''', ' ||
          ':OLD.object_id, :NEW.object_id, :NEW.name, :NEW.daytime, :NEW.end_date, :NEW.created_by, :NEW.created_date);' || CHR(10) ||
          '    ELSE' || CHR(10) ||
          '      ec_generate.iudObjectVersion(''' || tbl.table_name || ''', ' ||
          ':OLD.object_id, NULL, :OLD.name, :OLD.daytime, :OLD.end_date, :OLD.created_by, :OLD.created_date, FALSE);' || CHR(10) ||
          '    END IF;' || CHR(10) ||
          'END;' || CHR(10));
   END IF;
END buildAiudtTrigger;

----------------------------------------------------------------------------------------
-- Bit mask for "generate packages and views"
----------------------------------------------------------------------------------------
FUNCTION PACKAGES
RETURN INTEGER
IS
BEGIN
   RETURN I_PCK_MASK;
END PACKAGES;

----------------------------------------------------------------------------------------
-- Bit mask for "generate all triggers"
----------------------------------------------------------------------------------------
FUNCTION ALL_TRIGGERS
RETURN INTEGER
IS
BEGIN
   RETURN AP_TRIGGERS + AUT_TRIGGERS + AIUDT_TRIGGERS + IUR_TRIGGERS + IU_TRIGGERS + JN_TRIGGERS;
END ALL_TRIGGERS;

----------------------------------------------------------------------------------------
-- Bit mask for "generate basic triggers"
----------------------------------------------------------------------------------------
FUNCTION BASIC_TRIGGERS
RETURN INTEGER
IS
BEGIN
   RETURN AUT_TRIGGERS + AIUDT_TRIGGERS + IU_TRIGGERS;
END BASIC_TRIGGERS;

----------------------------------------------------------------------------------------
-- Bit mask for "generate PINC/AP trigger"
----------------------------------------------------------------------------------------
FUNCTION AP_TRIGGERS
RETURN INTEGER
IS
BEGIN
   RETURN I_AP_MASK;
END AP_TRIGGERS;

----------------------------------------------------------------------------------------
-- Bit mask for "generate AUT trigger"
----------------------------------------------------------------------------------------
FUNCTION AUT_TRIGGERS
RETURN INTEGER
IS
BEGIN
   RETURN I_AUT_MASK;
END AUT_TRIGGERS;

----------------------------------------------------------------------------------------
-- Bit mask for "generate AIUDT trigger"
----------------------------------------------------------------------------------------
FUNCTION AIUDT_TRIGGERS
RETURN INTEGER
IS
BEGIN
   RETURN I_AIUDT_MASK;
END AIUDT_TRIGGERS;

----------------------------------------------------------------------------------------
-- Bit mask for "generate IUR trigger"
----------------------------------------------------------------------------------------
FUNCTION IUR_TRIGGERS
RETURN INTEGER
IS
BEGIN
   RETURN I_IUR_MASK;
END IUR_TRIGGERS;

----------------------------------------------------------------------------------------
-- Bit mask for "generate IU trigger"
----------------------------------------------------------------------------------------
FUNCTION IU_TRIGGERS
RETURN INTEGER
IS
BEGIN
   RETURN I_IU_MASK;
END IU_TRIGGERS;

----------------------------------------------------------------------------------------
-- Bit mask for "generate JN trigger"
----------------------------------------------------------------------------------------
FUNCTION JN_TRIGGERS
RETURN INTEGER
IS
BEGIN
   RETURN I_JN_MASK;
END JN_TRIGGERS;

---------------------------------------------------------------------------------------------------
-- Generate triggers and EC package for the given table, or all tables if none is given.
-- The target type mask determines which objects to generate.
--
-- Example:
--     -- Generate EC packages for all tables
--     EcDp_Generate.generate(NULL, EcDp_Generate.PACKAGES);
--
--     -- Generate EC package for the BERTH table
--     EcDp_Generate.generate('BERTH', EcDp_Generate.PACKAGES);
--
--     -- Generate all triggers for BERTH table
--     EcDp_Generate.generate('BERTH', EcDp_Generate.ALL_TRIGGERS);
--
--     -- Generate AP, IUR and  triggers for all tables
--     EcDp_Generate.generate(NULL, EcDp_Generate.IU + EcDp_Generate.AUT + EcDp_Generate.AIUDT);
---------------------------------------------------------------------------------------------------
PROCEDURE generate(
          p_table_name IN VARCHAR2,
          p_target_mask IN INTEGER,
          p_missing_ind IN VARCHAR2 DEFAULT NULL)
IS
  CURSOR c_user_tables(cp_table_name IN VARCHAR2) IS
    SELECT ut.table_name, 'TABLE' AS object_type, ut.table_name AS key_table_name
    FROM   user_tables ut
    WHERE  ut.table_name NOT LIKE '%/_JN' ESCAPE '/'
    AND    ut.table_name = Nvl(cp_table_name, table_name)
    AND NOT EXISTS (SELECT 1 FROM user_mviews m WHERE ut.table_name = m.mview_name)
    UNION
    SELECT co.object_name AS table_name, 'VIEW' AS object_type, co.view_pk_table_name AS key_table_name
    FROM   ctrl_object co
    INNER JOIN user_views uv ON uv.view_name = co.object_name
    WHERE  co.view_pk_table_name IS NOT NULL
    AND    co.object_name = Nvl(cp_table_name, object_name)
    AND NOT EXISTS (SELECT 1 FROM user_mviews m WHERE uv.view_name = m.mview_name)
     ;

  CURSOR c_alias(p_table_name VARCHAR) IS
    SELECT column_name, alias_name
    FROM   ctrl_gen_function
    WHERE  table_name = p_table_name;

  CURSOR c_exists IS
    SELECT object_name FROM user_objects WHERE object_name LIKE 'IU/_%' ESCAPE '/' AND object_type='TRIGGER'
    UNION ALL
    SELECT object_name FROM user_objects WHERE object_name LIKE 'IUR/_%' ESCAPE '/' AND object_type='TRIGGER'
    UNION ALL
    SELECT object_name FROM user_objects WHERE object_name LIKE 'AP/_%' ESCAPE '/' AND object_type='TRIGGER'
    UNION ALL
    SELECT object_name FROM user_objects WHERE object_name LIKE 'AUT/_%' ESCAPE '/' AND object_type='TRIGGER'
    UNION ALL
    SELECT object_name FROM user_objects WHERE object_name LIKE 'AIUDT/_%' ESCAPE '/' AND object_type='TRIGGER'
    UNION ALL
    SELECT object_name FROM user_objects WHERE object_name LIKE 'JN/_%' ESCAPE '/' AND object_type='TRIGGER'
    UNION ALL
    SELECT object_name FROM user_objects WHERE object_name LIKE 'EC/_%' ESCAPE '/' AND object_type='PACKAGE'
    ;

  b_regenerate_existing BOOLEAN := Nvl(p_missing_ind, 'N') = 'N';
  b_generate_package BOOLEAN := bitand(p_target_mask, PACKAGES) > 0;
  b_generate_ap BOOLEAN := bitand(p_target_mask, AP_TRIGGERS) > 0;
  b_generate_aut BOOLEAN := bitand(p_target_mask, AUT_TRIGGERS) > 0;
  b_generate_aiudt BOOLEAN := bitand(p_target_mask, AIUDT_TRIGGERS) > 0;
  b_generate_iu BOOLEAN := bitand(p_target_mask, IU_TRIGGERS) > 0;
  b_generate_iur BOOLEAN := bitand(p_target_mask, IUR_TRIGGERS) > 0;
  b_generate_jn BOOLEAN := bitand(p_target_mask, JN_TRIGGERS) > 0;

  m_exists Varchar_30_M;

  v_target_mask INTEGER := 0;

  key_cols t_table_key_columns := NULL;

BEGIN
   IF NOT b_regenerate_existing THEN
     FOR cur IN c_exists LOOP
       m_exists(cur.object_name) := 'Y';
     END LOOP;
   END IF;

   FOR curTable IN c_user_tables(p_table_name) LOOP
      clearTbl;

      IF key_cols IS NOT NULL THEN
         key_cols.DELETE;
      END IF;

      key_cols := t_table_key_columns();

      b_regenerate_existing := Nvl(p_missing_ind, 'N') = 'N';
      b_generate_package := bitand(p_target_mask, PACKAGES) > 0;
      b_generate_ap := bitand(p_target_mask, AP_TRIGGERS) > 0 AND curTable.object_type = 'TABLE';
      b_generate_aut := bitand(p_target_mask, AUT_TRIGGERS) > 0 AND curTable.object_type = 'TABLE';
      b_generate_aiudt := bitand(p_target_mask, AIUDT_TRIGGERS) > 0 AND curTable.object_type = 'TABLE';
      b_generate_iu := bitand(p_target_mask, IU_TRIGGERS) > 0 AND curTable.object_type = 'TABLE';
      b_generate_iur := bitand(p_target_mask, IUR_TRIGGERS) > 0 AND curTable.object_type = 'TABLE';
      b_generate_jn := bitand(p_target_mask, JN_TRIGGERS) > 0 AND curTable.object_type = 'TABLE';

      IF NOT b_regenerate_existing THEN
        b_generate_package := b_generate_package AND NOT m_exists.EXISTS(substr('EC_'||curTable.table_name, 1, 30));
        b_generate_ap := b_generate_ap AND NOT m_exists.EXISTS(substr('AP_'||curTable.table_name, 1, 30));
        b_generate_aut := b_generate_aut AND NOT m_exists.EXISTS(substr('AUT_'||curTable.table_name, 1, 30));
        b_generate_aiudt := b_generate_aiudt AND NOT m_exists.EXISTS(substr('AIUDT_'||curTable.table_name, 1, 30));
        b_generate_iu := b_generate_iu AND NOT m_exists.EXISTS(substr('IU_'||curTable.table_name, 1, 30));
        b_generate_iur := b_generate_iur AND NOT m_exists.EXISTS(substr('IUR_'||curTable.table_name, 1, 30));
        b_generate_jn := b_generate_jn AND NOT m_exists.EXISTS(substr('JN_'||curTable.table_name, 1, 30));
      END IF;

      IF NOT (b_generate_package OR
              b_generate_ap OR
              b_generate_aut OR
              b_generate_aiudt OR
              b_generate_iu OR
              b_generate_iur OR
              b_generate_jn) THEN
        CONTINUE;
      END IF;

      v_target_mask := 0;

      IF b_generate_package THEN
         v_target_mask := v_target_mask + PACKAGES;
      END IF;

      IF b_generate_ap THEN
         v_target_mask := v_target_mask + AP_TRIGGERS;
      END IF;

      IF b_generate_aut THEN
         v_target_mask := v_target_mask + AUT_TRIGGERS;
      END IF;

      IF b_generate_aiudt THEN
         v_target_mask := v_target_mask + AIUDT_TRIGGERS;
      END IF;

      IF b_generate_iu THEN
         v_target_mask := v_target_mask + IU_TRIGGERS;
      END IF;

      IF b_generate_iur THEN
         v_target_mask := v_target_mask + IUR_TRIGGERS;
      END IF;

      IF b_generate_jn THEN
         v_target_mask := v_target_mask + JN_TRIGGERS;
      END IF;

      tbl.table_name := curTable.table_name;

      tbl.pday_buffer := FALSE;
      FOR one IN lt_flush_tables.FIRST..lt_flush_tables.LAST LOOP
        IF lt_flush_tables(one) = tbl.table_name THEN
          tbl.pday_buffer := TRUE;
          EXIT;
        END IF;
      END LOOP;

      IF b_generate_package OR b_generate_ap OR b_generate_iu THEN
         OPEN c_table_key_columns(curTable.key_table_name);
         FETCH c_table_key_columns BULK COLLECT INTO key_cols;
         CLOSE c_table_key_columns;

         FOR i IN 1..key_cols.COUNT LOOP
            IF key_cols(i).constraint_type = 'R' THEN
               tbl.fk_cols.EXTEND(1);
               tbl.fk_cols(tbl.fk_cols.COUNT) := key_cols(i);
            ELSIF key_cols(i).constraint_type = 'P' THEN
               tbl.pk_cols.EXTEND(1);
               tbl.pk_cols(tbl.pk_cols.COUNT) := key_cols(i);
            ELSIF key_cols(i).constraint_type = 'U' THEN
               tbl.uk_cols.EXTEND(1);
               tbl.uk_cols(tbl.uk_cols.COUNT) := key_cols(i);
            END IF;
         END LOOP;
      END IF;

      IF b_generate_package OR b_generate_aut THEN
         FOR cur IN c_ctrl_object(tbl.table_name) LOOP
            tbl.ctrlObj := cur;
         END LOOP;
      END IF;

      OPEN c_table_columns(tbl.table_name);
      FETCH c_table_columns BULK COLLECT INTO tbl.cols;
      CLOSE c_table_columns;

      FOR i IN 1..tbl.cols.COUNT LOOP
         tbl.alias(tbl.cols(i).column_name) := tbl.cols(i).column_name;
      END LOOP;

      IF b_generate_package THEN
        OPEN c_ctrl_gen_functions(curTable.table_name);
        FETCH c_ctrl_gen_functions BULK COLLECT INTO tbl.genFns;
        CLOSE c_ctrl_gen_functions;

        FOR curAlias IN c_alias(curTable.table_name) LOOP
           tbl.alias(curAlias.column_name) := Nvl(curAlias.alias_name, curAlias.column_name);
        END LOOP;
      END IF;

      IF b_generate_jn THEN
         OPEN c_table_columns(tbl.table_name||'_JN');
         FETCH c_table_columns BULK COLLECT INTO tbl.jn_cols;
         CLOSE c_table_columns;
      END IF;

      FOR i IN 1..tbl.cols.COUNT LOOP
         tbl.dataType(tbl.cols(i).column_name) := tbl.cols(i).data_type;
         tbl.isNullable(tbl.cols(i).column_name) := tbl.cols(i).nullable;
      END LOOP;

      FOR i IN 1..tbl.jn_cols.COUNT LOOP
         tbl.jnDataType(tbl.jn_cols(i).column_name) := tbl.jn_cols(i).data_type;
      END LOOP;

      FOR i IN 1..tbl.pk_cols.COUNT LOOP
         IF NOT tbl.dataType.EXISTS(tbl.pk_cols(i).column_name) THEN
            tbl.dataType(tbl.pk_cols(i).column_name) := tbl.pk_cols(i).data_type;
            tbl.isNullable(tbl.pk_cols(i).column_name) := 'N';
         END IF;
         tbl.pk_cols(i).data_type := tbl.dataType(tbl.pk_cols(i).column_name);
      END LOOP;

      FOR i IN 1..tbl.uk_cols.COUNT LOOP
         IF NOT tbl.dataType.EXISTS(tbl.uk_cols(i).column_name) THEN
            tbl.dataType(tbl.uk_cols(i).column_name) := tbl.uk_cols(i).data_type;
         END IF;
         tbl.uk_cols(i).data_type := tbl.dataType(tbl.uk_cols(i).column_name);
      END LOOP;

      FOR i IN 1..tbl.fk_cols.COUNT LOOP
         IF NOT tbl.dataType.EXISTS(tbl.fk_cols(i).column_name) THEN
           tbl.dataType(tbl.fk_cols(i).column_name) := tbl.fk_cols(i).data_type;
           tbl.isNullable(tbl.fk_cols(i).column_name) := 'N';
         END IF;
         tbl.fk_cols(i).data_type := tbl.dataType(tbl.fk_cols(i).column_name);
      END LOOP;

      IF b_generate_package AND tbl.ctrlObj.object_name IS NOT NULL AND Nvl(tbl.ctrlObj.ec_package, 'Y') = 'Y' THEN
        generatePackage;
        generatePackageViews;
      END IF;

      IF b_generate_ap AND Nvl(tbl.ctrlObj.pinc_trigger_ind, 'Y') = 'Y' THEN
         buildPINCTrigger;
      END IF;

      IF b_generate_aut THEN
        IF tbl.ctrlObj.object_name IS NOT NULL AND Nvl(tbl.ctrlObj.ec_package, 'Y') = 'Y' THEN
          IF tbl.pday_buffer THEN
            buildTrigger(
                 substr('AUT_'||tbl.table_name, 1, 30),
                 'CREATE OR REPLACE TRIGGER ' || substr('AUT_'||tbl.table_name, 1, 30) || CHR(10) ||
                 'AFTER UPDATE ON ' || tbl.table_name || CHR(10) ||
                 'BEGIN ' || CHR(10) || '    '||
                 substr('EC_'||tbl.table_name, 1, 30) || '.flush_row_cache;' || CHR(10) ||
                 '    ' || 'ecdp_productionday.flush_buffer;' || CHR(10) ||
                 'END;' || CHR(10));
            
          ELSE
            buildTrigger(
                 substr('AUT_'||tbl.table_name, 1, 30),
                 'CREATE OR REPLACE TRIGGER ' || substr('AUT_'||tbl.table_name, 1, 30) || CHR(10) ||
                 'AFTER UPDATE ON ' || tbl.table_name || CHR(10) ||
                 'BEGIN ' || CHR(10) || '    '||
                 substr('EC_'||tbl.table_name, 1, 30) || '.flush_row_cache;' || CHR(10) ||
                 'END;' || CHR(10));
          END IF;
        END IF;
      END IF;

      IF b_generate_aiudt THEN
         buildAiudtTrigger;
      END IF;

      IF b_generate_iu THEN
         buildIUTrigger;
      END IF;

      IF b_generate_iur THEN
         IF hasColumn('REV_NO') = 'Y' AND hasColumn('REC_ID') = 'Y' THEN
            buildTrigger(
               substr('IUR_'||tbl.table_name, 1, 30),
               'CREATE OR REPLACE TRIGGER ' || substr('IUR_'||tbl.table_name, 1, 30) || CHR(10) ||
               'BEFORE INSERT OR UPDATE ON ' || tbl.table_name || CHR(10) ||
               'FOR EACH ROW'|| CHR(10) ||
               IUR_TRIGGER_CODE);
         END IF;
      END IF;

      IF b_generate_jn AND tbl.jn_cols.COUNT > 0 THEN
         buildJournalTrigger;
      END IF;
   END LOOP;
END generate;

END EcDp_Generate;
--~^UTDELIM^~--
CREATE OR REPLACE PACKAGE EcDp_DynSql IS
/**************************************************************
** Package:    EcDp_DynSql
**
** $Revision: 1.14 $
**
** Filename:   EcDp_DynSql.sql
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
** Created:   	21.12.98  Arild Vervik, ISI AS
**
**
** Modification history:
**
**
** Date:      Whom:  Change description:
** --------   ----- --------------------------------------------
** 13.10.2004 AV     added 3 new functions SafeString, SafeNumber, safeDate
** 13.12.2005 AV   Support function converting an ID to anydata building up dynamic SQL
** 07.03.2006 DN   TI 3569: Added overloaded version of SafeBuild.
** 08.03.2006 AV   Added p_raise_error VARCHAR2 DEFAULT 'N' to SafeBuild procedure
** 11.08.2006 AV   Added new parameter to Safebuild, allowing user to spesify if parsing should
                   add linefeed after each line is structure, this is a default parameter, the default behaviour
                   remains unchanged
** 18.04.2007 HUS  Added AddSqlLines
** 28.08.2008 KEB  Added WriteDebugText
**************************************************************/

--
PROCEDURE execute_statement(
   p_statement      VARCHAR2
   ) ;

--

FUNCTION  execute_singlerow_date(
  p_statement varchar2
  )
RETURN DATE;

--

FUNCTION  execute_singlerow_varchar2(
  p_statement varchar2
  )
RETURN VARCHAR2;

--

FUNCTION  execute_singlerow_number(
  p_statement varchar2
  )
RETURN NUMBER;

--

FUNCTION date_to_string(p_daytime date
)
RETURN VARCHAR2;

FUNCTION SafeNumber(p_number NUMBER, p_datatype VARCHAR2 DEFAULT 'NUMBER')
RETURN VARCHAR2;

FUNCTION Safedate(p_date DATE)
RETURN VARCHAR2;

FUNCTION SafeString(p_string VARCHAR2)
RETURN VARCHAR2;

PROCEDURE PurgeRecycleBin;

PROCEDURE AddSqlLineNoWrap(
          p_lines   IN OUT NOCOPY DBMS_SQL.varchar2a,
          p_newline IN VARCHAR2);

PROCEDURE AddSqlLinesNoWrap(
          p_lines    IN OUT NOCOPY DBMS_SQL.varchar2a,
          p_newlines IN DBMS_SQL.varchar2a);

PROCEDURE AddSqlLine(p_lines   IN OUT DBMS_SQL.varchar2a,
                     p_newline IN     VARCHAR2,
                     p_nowrap         VARCHAR2 DEFAULT 'N'   -- Don't wrap long lines if this flag is set = 'Y'
);

PROCEDURE AddSqlLines(p_lines    IN OUT DBMS_SQL.varchar2a,
                      p_newlines IN DBMS_SQL.varchar2a,
                      p_nowrap   IN VARCHAR2 DEFAULT 'N'   -- Don't wrap long lines if this flag is set = 'Y'
);

PROCEDURE WriteDebugText(p_id_type VARCHAR2, p_sql VARCHAR2, p_debuglevel VARCHAR2);

PROCEDURE WriteTempText(p_id_type VARCHAR2, p_sql CLOB);

PROCEDURE DeleteTempText(p_id VARCHAR2);

PROCEDURE SafeBuildSupressErrors(
          p_object_name IN VARCHAR2,
          p_object_type IN VARCHAR2,
          p_lines       IN DBMS_SQL.varchar2a,
          p_id          IN VARCHAR2);

PROCEDURE SafeBuild(p_object_name VARCHAR2,
                    p_object_type VARCHAR2,
                    p_lines       DBMS_SQL.varchar2a,
                    p_target      VARCHAR2 DEFAULT 'CREATE',
                    p_id          VARCHAR2 DEFAULT 'GENCODE',
                    p_raise_error VARCHAR2 DEFAULT 'N',
                    p_lfflg       VARCHAR2 DEFAULT 'N'  -- Should be set to 'Y' if dbms_sql.parse should add chr(10) after each line in p_lines
                    );



FUNCTION Anydata_to_String(p_datetype VARCHAR2,p_id VARCHAR2) RETURN VARCHAR2;



PROCEDURE RecompileInvalid;


PROCEDURE BackupAndDeleteTable(p_table_name VARCHAR2);


FUNCTION CompareTableStructure(p_table_1 varchar2,
                               p_table_2 varchar2,
                               p_ignore_columns varchar2) RETURN NUMBER;

END;
--~^UTDELIM^~--

CREATE OR REPLACE PACKAGE BODY EcDp_DynSql IS
/**************************************************************
** Package:    EcDp_DynSql
**
** $Revision: 1.20 $
**
** Filename:   EcDp_DynSql.sql
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
** Created:   	21.12.98  Arild Vervik, ISI AS
**
**
** Modification history:
**
**
** Date:     Whom:  Change description:
** --------  ----- --------------------------------------------
** 13.10.2004 AV   Fixed weaknes in date_to_string,
**                 added 3 new functions SafeString, SafeNumber, safeDate
** 08.04.2005 AV   Added logging to t_temptext for safebuild
** 08.11.2005 AV   Fixed bug in WriteTempText splitting line in wrong places
** 13.12.2005 AV   Support function converting an ID to anydata building up dynamic SQL
** 07.03.2006 DN   TI 3569: Added overloaded version of SafeBuild.
** 08.03.2006 AV   Added p_raise_error VARCHAR2 DEFAULT 'N' to SafeBuild procedure, removed dummy creation
** 11.08.2006 AV   Added new parameter to Safebuild, allowing user to spesify if parsing should
                   add linefeed after each line is structure, this is a default parameter, the default behaviour
                   remains unchanged
** 18.04.2007 HUS  Added AddSqlLines
** 28.08.2008 KEB  Added WriteDebugText
**************************************************************/

syntax_error EXCEPTION;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : execute_statement                                                            --
-- Description    : executes a dynamic SQL statement. No binding                                 --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      : Parse and executes a SQL statement                                           --
--                                                                                               --
---------------------------------------------------------------------------------------------------
PROCEDURE execute_statement(
   p_statement      VARCHAR2
   )
--</EC-DOC>

IS

li_cursor	   integer;
li_returverdi	integer;
lv2_result     varchar2(2000);



BEGIN


   li_cursor := Dbms_sql.open_cursor;

   Dbms_sql.parse(li_cursor,p_statement,dbms_sql.v7);
   li_returverdi := Dbms_sql.execute(li_cursor);
   Dbms_Sql.Close_Cursor(li_cursor);


END execute_statement;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : execute_singlerow_date                                                       --
-- Description    : executes a dynamic SQL statement. Returns a date                             --
--                                                                                               --
-- Preconditions  : Statement must select a date column from the database                        --
-- Postcondition  : Return the data from the first row returned from database                    --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      : Parse and executes a SQL statement                                           --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION execute_singlerow_date(
   p_statement varchar2
   )
   RETURN DATE
--</EC-DOC>

IS

li_cursor	integer;
li_returverdi	integer;

ld_return_value date;

BEGIN

   li_cursor := Dbms_Sql.Open_Cursor;

   Dbms_sql.Parse(li_cursor,p_statement,dbms_sql.v7);
   Dbms_Sql.Define_Column(li_cursor,1,ld_return_value);

   li_returverdi := Dbms_Sql.Execute(li_cursor);

   IF Dbms_Sql.Fetch_Rows(li_cursor) = 0 THEN
	Dbms_Sql.Close_Cursor(li_cursor);
	RETURN NULL;
   ELSE
        Dbms_Sql.Column_Value(li_cursor,1,ld_return_value);
   END IF;

   Dbms_Sql.Close_Cursor(li_cursor);

   RETURN ld_return_value;

EXCEPTION

	WHEN OTHERS THEN

                IF  Dbms_sql.is_open(li_cursor) THEN
                    Dbms_Sql.Close_Cursor(li_cursor);
                END IF;

		-- log error, but continue
		RETURN NULL;

END execute_singlerow_date;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : execute_singlerow_varchar2                                                   --
-- Description    : executes a dynamic SQL statement. Returns a varchar2                         --
--                                                                                               --
-- Preconditions  : Statement must select a varchar2 expression from the database                --
-- Postcondition  : Return data from the first row returned from database                        --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      : Parse and executes a SQL statement                                           --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION execute_singlerow_varchar2(
   p_statement varchar2)
RETURN VARCHAR2
--</EC-DOC>

IS

li_cursor	integer;
li_returverdi	integer;

lv2_return_value varchar2(255);

BEGIN

   li_cursor := Dbms_Sql.Open_Cursor;

   Dbms_sql.Parse(li_cursor,p_statement,dbms_sql.v7);
   Dbms_Sql.Define_Column(li_cursor,1,lv2_return_value,255);

   li_returverdi := Dbms_Sql.Execute(li_cursor);

   IF Dbms_Sql.Fetch_Rows(li_cursor) = 0 THEN
        Dbms_Sql.Close_Cursor(li_cursor);
	RETURN NULL;
   ELSE
        Dbms_Sql.Column_Value(li_cursor,1,lv2_return_value);
   END IF;

   Dbms_Sql.Close_Cursor(li_cursor);

   RETURN lv2_return_value;

EXCEPTION

	WHEN OTHERS THEN

                IF  Dbms_sql.is_open(li_cursor) THEN
                    Dbms_Sql.Close_Cursor(li_cursor);
                END IF;

                RETURN NUll;

END execute_singlerow_varchar2;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : execute_singlerow_number                                                     --
-- Description    : executes a dynamic SQL statement. Returns a number                           --
--                                                                                               --
-- Preconditions  : Statement must select a number expression from the database                  --
-- Postcondition  : Return data from the first row returned from database                        --
-- Using Tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      : Parse and executes a SQL statement                                           --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION execute_singlerow_number(
  p_statement varchar2)
RETURN NUMBER
--</EC-DOC>

IS

li_cursor	integer;
li_returverdi	integer;

ln_return_value number;

BEGIN

   li_cursor := Dbms_Sql.Open_Cursor;

   Dbms_sql.Parse(li_cursor,p_statement,dbms_sql.v7);
   Dbms_Sql.Define_Column(li_cursor,1,ln_return_value);

   li_returverdi := Dbms_Sql.Execute(li_cursor);

   IF Dbms_Sql.Fetch_Rows(li_cursor) = 0 THEN
        Dbms_Sql.Close_Cursor(li_cursor);
	RETURN NULL;
   ELSE
        Dbms_Sql.Column_Value(li_cursor,1,ln_return_value);
   END IF;

   Dbms_Sql.Close_Cursor(li_cursor);

   RETURN ln_return_value;

EXCEPTION

	WHEN OTHERS THEN

                IF  Dbms_sql.is_open(li_cursor) THEN
                    Dbms_Sql.Close_Cursor(li_cursor);
                END IF;

        RETURN NUll;


END execute_singlerow_number
;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : date_to_string
-- Description    : takes a date and returns it as a string with to_date convertion
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION date_to_string(p_daytime date
)
RETURN VARCHAR2
--</EC-DOC>
IS
  lv2_datestr VARCHAR2(100);

BEGIN

   IF p_daytime IS NOT NULL THEN

      lv2_datestr := ' to_date(''' || to_char(p_daytime,'dd.mm.yyyy hh24:mi:ss') ||
                             ''', ''dd.mm.yyyy hh24:mi:ss'')' ;

   ELSE

      lv2_datestr :=  ' to_date(NULL) ' ;


   END IF;

   RETURN lv2_datestr;


END date_to_string
;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : SafeNumber
-- Description    : takes a number and returns it as a string with . as decimal separator
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION SafeNumber(p_number NUMBER, p_datatype VARCHAR2 DEFAULT 'NUMBER')
RETURN VARCHAR2
--</EC-DOC>
IS

   ln_value             NUMBER;
   ld_date              DATE;
   lv2_value            VARCHAR2(32000);
   lv2_text             VARCHAR2(32000);

BEGIN


   IF p_datatype = 'NUMBER' THEN

      IF p_number IS NULL THEN
         lv2_value := 'NULL';
      ELSE
         lv2_value := TO_CHAR(p_number,'9999999999999999D9999999999','NLS_NUMERIC_CHARACTERS=''.,''') ;
      END IF;

   ELSIF p_datatype = 'INTEGER' THEN

      IF p_number IS NULL THEN
         lv2_value := 'NULL';
      ELSE

         IF p_number - FLOOR(p_number) > 0 THEN

            Raise_Application_Error(-20107,'Value '||p_number||' is not a valid INTEGER.'  );

         END IF;

         lv2_value := TO_CHAR(p_number,'9999999999999999D9999999999','NLS_NUMERIC_CHARACTERS=''.,''') ;
      END IF;

   ELSE

      Raise_Application_Error(-20108,'Unsupported data type '||p_datatype||' in Ecdp_objects.UpdateObjectDataTables .');

   END IF;

   RETURN lv2_value;

END SafeNumber;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : SafeDate
-- Description    : takes a date and returns it as a string with to_date convertion
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION Safedate(p_date DATE)
RETURN VARCHAR2
--</EC-DOC>
IS

   ln_value             NUMBER;
   ld_date              DATE;
   lv2_value            VARCHAR2(32000);
   lv2_text             VARCHAR2(32000);

BEGIN

   IF p_date IS NOT NULL THEN
      lv2_value := ecdp_dynsql.date_to_string(p_date);
   ELSE
      lv2_value := 'NULL' ;
   END IF;

   RETURN lv2_value;

END SafeDate;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : SafeString
-- Description    : takes a string and returns it as a string where ' has been replaced by ''
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION SafeString(p_string VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS

   lv2_value            VARCHAR2(32000);

BEGIN

      IF p_string IS NOT NULL THEN
         lv2_value := ''''|| REPLACE(p_string,'''','''''')||'''';
      ELSE
         lv2_value := 'NULL' ;
      END IF;


   RETURN lv2_value;

END SafeString;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : WriteDebugText                                                               --
-- Description    : Write debug to T_TEMPTEXT                                                   --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  : Truncates to 4000 chars and writes to T_temptext with ID = 'GENCODE'         --
--                  AUTONOMOUS_TRANSACTION COMMITTED                                             --
-- Using Tables   : T_TEMPTEXT and CTRL_SYSTEM_ATTRIBUTE                                         --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       : INSERT INTO ctrl_system_attribute (daytime,attribute_type,attribute_text,    --
--                  comments) values(to_date('01.01.1900','dd.mm.yyyy'),'DB_DEBUG_LEVEL','FALSE',--
--                  'Sets debug level for witing debug text. Default should be FALSE')           --
--                                                                                               --
-- Behavior       : Writes to DB based on what is set in CTRL_SYSTEM_ATTRIBUTE.ATTRIBUTE_TEXT    --
--                  for CTRL_SYSTEM_ATTRIBUTE.ATTRIBUTE_TYPE =DB_DEBUG_LEVEL:                    --
--                  - FALSE: Does not write anything to DB                                       --
--                  - ERROR: Write to DB if p_debuglevel equals 'ERROR'                          --
--                  - DEBUG: Write to DB if p_debuglevel equals 'DEBUG'                          --
--                  More levels can be added when needed.                                        --
---------------------------------------------------------------------------------------------------
PROCEDURE WriteDebugText(p_id_type VARCHAR2, p_sql VARCHAR2, p_debuglevel VARCHAR2)
--</EC-DOC>

IS

  CURSOR c_db_level IS
    select max(ATTRIBUTE_TEXT) as attr_text
    from CTRL_SYSTEM_ATTRIBUTE
    where ATTRIBUTE_TYPE='DB_DEBUG_LEVEL';

    lb_dowrite   BOOLEAN;
    lv2_db_level VARCHAR2(2000);

BEGIN

   FOR curLevel IN c_db_level LOOP

      lv2_db_level := NVL(curLevel.attr_text, 'FALSE');

      IF lv2_db_level = 'FALSE' THEN
         lb_dowrite := FALSE;
      ELSIF lv2_db_level='ERROR' AND p_debuglevel='ERROR' THEN
         lb_dowrite := TRUE;
      ELSIF lv2_db_level='DEBUG' AND p_debuglevel='DEBUG' THEN
         lb_dowrite := TRUE;
      ELSE
         lb_dowrite := FALSE;
      END IF;

   END LOOP;

   IF lb_dowrite = TRUE THEN
      WriteTempText(p_id_type, p_sql);
   END IF;

END WriteDebugText;
---------------------------------------------------------------------------------


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : DeleteTempText                                                               --
-- Description    : Delete all t_temptext rows where the id matches the given pattern.           --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  : AUTONOMOUS_TRANSACTION COMMITTED                                             --
-- Using Tables   : T_TEMPTEXT                                                                   --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behavior       :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
PROCEDURE DeleteTempText(p_id VARCHAR2)
--</EC-DOC>
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  DELETE FROM t_temptext WHERE ID LIKE p_id;
  COMMIT;
END DeleteTempText;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : WriteTempText                                                                --
-- Description    : Write generated code to t_temptext                                           --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  : Truncates to 4000 chars and writes to T_temptext with ID = 'GENCODE'         --
--                  AUTONOMOUS_TRANSACTION COMMITTED                                             --
-- Using Tables   : T_TEMPTEXT                                                                   --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behavior       :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
PROCEDURE WriteTempText(p_id_type VARCHAR2, p_sql CLOB)
--</EC-DOC>

IS

PRAGMA  AUTONOMOUS_TRANSACTION;

ln_line    NUMBER;
lv2_buffer VARCHAR2(4000);
ln_start   NUMBER := 1;
ln_end     NUMBER;
ln_length  NUMBER;
ln_count   NUMBER;
ln_crfound NUMBER;

BEGIN

   SELECT MAX(line_number) INTO ln_line FROM T_TEMPTEXT WHERE ID = p_id_type;

   ln_length := DBMS_LOB.GETLENGTH(p_sql);
   ln_line := Nvl(ln_line+1,1);
   ln_crfound := 0;

   WHILE ln_length - ln_start >= 0 LOOP

    ln_crfound := 0;

    IF  ln_length - ln_start > 3999 THEN

        -- need to split in a safe place, this can be a bit tricky
        -- It's usually safe to look for a linebreak chr(10) instead of a white space.
        -- As a precaution we only go back a max number of places (but far enough!)

        ln_end := ln_start + 3999;
        ln_count := 0;

        IF DBMS_LOB.SUBSTR(p_sql,1.0,ln_end) = CHR(10) THEN

          ln_crfound := 1;

        END IF;


        WHILE ln_count < 3000 AND DBMS_LOB.SUBSTR(p_sql,1.0,ln_end) <> CHR(10) LOOP

           ln_end := ln_end - 1;
           ln_count := ln_count + 1;

           IF DBMS_LOB.SUBSTR(p_sql,1.0,ln_end) = CHR(10) THEN

             ln_crfound := 1;

           END IF;


        END LOOP;

    ELSE

      ln_end := ln_length;

    END IF;

     IF ln_crfound = 1 THEN -- remove last CR from buffer
       lv2_buffer := DBMS_LOB.SUBSTR(p_sql, ln_end - ln_start, ln_start);
     ELSE
       lv2_buffer := DBMS_LOB.SUBSTR(p_sql, ln_end - ln_start+1, ln_start);
     END IF;

     INSERT INTO T_TEMPTEXT(id,line_number,text,created_by, created_date ) VALUES(p_id_type,ln_line,lv2_buffer,USER,EcDp_Date_Time.getCurrentSysdate);
     ln_start := ln_end + 1;
     ln_line := ln_line + 1;

   END LOOP;

   COMMIT;

END WriteTempText;




--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : purge_recyclebin                                                             --
-- Description    : Purges the recyclebin                                                        --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   : <recyclebin>                                                                 --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      : Purges the recyclebin, and handles exceptions for versions pre-Oracle10      --
--                                                                                               --
---------------------------------------------------------------------------------------------------
PROCEDURE PurgeRecycleBin
--</EC-DOC>

IS

BEGIN
  EXECUTE IMMEDIATE 'PURGE RECYCLEBIN';

EXCEPTION
    WHEN OTHERS THEN
      NULL;

END PurgeRecycleBin;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : AddSqlLineNoWrap
-- Description    : Adds a new code line to a DBMS_SQL.varchar2a pl-sql table.
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE AddSqlLineNoWrap(
          p_lines   IN OUT NOCOPY DBMS_SQL.varchar2a,
          p_newline IN VARCHAR2)
--</EC-DOC>
IS
BEGIN
   p_lines(nvl(p_lines.last,0)+1) := p_newline;
END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : AddSqlLine
-- Description    : Adds a new code line to a DBMS_SQL.varchar2a pl-sql table, splits it if string > 256 char
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE AddSqlLine(p_lines   IN OUT DBMS_SQL.varchar2a,
                     p_newline IN     VARCHAR2,
                     p_nowrap         VARCHAR2 DEFAULT 'N'   -- Don't wrap long lines if this flag is set = 'Y'
)
--</EC-DOC>
IS
  lv2_newline VARCHAR2(32000) := p_newline;
  ln_end     NUMBER;
  ln_length  NUMBER;
  ln_line    NUMBER;
  ln_crfound NUMBER;

BEGIN

   IF  p_nowrap = 'N' THEN  -- split lines over 255 characters long

     -- First split on linebreak given by user
     ln_crfound := INSTR(lv2_newline,CHR(10));
     ln_length := LENGTH(lv2_newline);

     WHILE ln_crfound > 0 OR ln_length > 255 LOOP -- we need to split line

       -- see first if there is a CR that make first section < 256 characters
       IF ln_crfound > 0 AND ln_crfound < 256 THEN

         p_lines(nvl(p_lines.last,0)+1) := SUBSTR(lv2_newline,1,ln_crfound);
         lv2_newline := SUBSTR(lv2_newline,ln_crfound+1);


       ELSE -- need to split anyway, must find safe place to split use first blank chr(32) for this

         ln_end := 255;

         WHILE ln_end > 1 AND SUBSTR(lv2_newline,ln_end,1) <> CHR(32)   LOOP

            ln_end := ln_end -1;

         END LOOP;

         -- Check if we found a blank
         IF SUBSTR(lv2_newline,ln_end,1)<> CHR(32) THEN

           ln_end := 255; -- Just split after 255 characters

         END IF;

         p_lines(nvl(p_lines.last,0)+1) := SUBSTR(lv2_newline,1,ln_end) || CHR(10);
         lv2_newline := SUBSTR(lv2_newline,ln_end+1);


      END IF;

      ln_crfound := INSTR(lv2_newline,CHR(10));
      ln_length := LENGTH(lv2_newline);

    END LOOP;

    IF LENGTH(lv2_newline) > 0 THEN

         p_lines(nvl(p_lines.last,0)+1) := SUBSTR(lv2_newline,1,256) || CHR(10);

    END IF;

  ELSE

    p_lines(nvl(p_lines.last,0)+1) := p_newline;

  END IF;

END;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : AddSqlLines
-- Description    : Adds a new code lines to a DBMS_SQL.varchar2a pl-sql table.
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE AddSqlLines(p_lines    IN OUT DBMS_SQL.varchar2a,
                      p_newlines IN DBMS_SQL.varchar2a,
                      p_nowrap   IN VARCHAR2 DEFAULT 'N'   -- Don't wrap long lines if this flag is set = 'Y'
)
--</EC-DOC>
IS
BEGIN
   FOR l IN 1..nvl(p_newlines.last,0) LOOP
	    AddSqlLine(p_lines, p_newlines(l), p_nowrap);
   END LOOP;
END;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : AddSqlLinesNoWrap
-- Description    : Adds a new code lines to a DBMS_SQL.varchar2a pl-sql table.
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE AddSqlLinesNoWrap(
          p_lines    IN OUT NOCOPY DBMS_SQL.varchar2a,
          p_newlines IN DBMS_SQL.varchar2a)
--</EC-DOC>
IS
BEGIN
   FOR l IN 1..nvl(p_newlines.last,0) LOOP
	    AddSqlLineNoWrap(p_lines, p_newlines(l));
   END LOOP;
END;

PROCEDURE SafeBuildSupressErrors(
          p_object_name IN VARCHAR2,
          p_object_type IN VARCHAR2,
          p_lines       IN DBMS_SQL.varchar2a,
          p_id          IN VARCHAR2)
--</EC-DOC>
IS
  c BINARY_INTEGER;
  r INTEGER;
  lb_error_found BOOLEAN := FALSE;
BEGIN
   c := dbms_sql.open_cursor;

   BEGIN

     dbms_sql.parse(c,p_lines,p_lines.first,p_lines.last,FALSE,DBMS_SQL.NATIVE);
     r := dbms_sql.execute(c);

   EXCEPTION
   	 WHEN OTHERS THEN
        lb_error_found := TRUE;
   END;

   dbms_sql.close_cursor(c);

   IF lb_error_found THEN
      WriteTempText(p_id || 'ERROR','Syntax error generating '||p_object_type ||' for '||p_object_name||CHR(10)||SQLERRM);

      FOR i IN  p_lines.first.. p_lines.last LOOP
            WriteTempText(p_id || 'ERROR',p_lines(i) || CHR(10));
      END LOOP;

      WriteTempText(p_id || 'ERROR','/'|| CHR(10));
   END IF;
END SafeBuildSupressErrors;

PROCEDURE SafeBuild(p_object_name VARCHAR2,
                    p_object_type VARCHAR2,
                    p_lines       DBMS_SQL.varchar2a,
                    p_target      VARCHAR2 DEFAULT 'CREATE',
                    p_id          VARCHAR2 DEFAULT 'GENCODE',
                    p_raise_error VARCHAR2 DEFAULT 'N',
                    p_lfflg       VARCHAR2 DEFAULT 'N'  -- Should be set to 'Y' if dbms_sql.parse should add chr(10) after each line in p_lines
                    )
--</EC-DOC>

IS

  CURSOR c_user_errors IS
  SELECT ue.line, ue.position, ue.text
  FROM user_errors ue
  WHERE ue.name = p_object_name
  AND   ue.type =  p_object_type;


  c BINARY_INTEGER;
  result         Integer;
  lb_error_found BOOLEAN := FALSE;
  lv2_errors     VARCHAR2(4000);

BEGIN

    IF p_target = 'CREATE' THEN -- create the view


      c := dbms_sql.open_cursor;
      IF p_lfflg = 'Y' THEN
         dbms_sql.parse(c,p_lines,p_lines.first,p_lines.last,TRUE,DBMS_SQL.NATIVE);
      ELSE
         dbms_sql.parse(c,p_lines,p_lines.first,p_lines.last,FALSE,DBMS_SQL.NATIVE);
      END IF;

      result := dbms_sql.execute(c);
      dbms_sql.close_cursor(c);

      -- Check for errors in user_errors
      FOR curError IN c_user_errors LOOP

        lb_error_found := TRUE;
        IF p_raise_error = 'N' THEN
          WriteTempText(p_id ||'ERROR',p_object_name||'('||curError.line||','||curError.position||'): '||curError.text|| CHR(10));

        ELSE

         Raise_Application_Error(-20000,'Syntax error generating '||p_object_type ||' for '||p_object_name||CHR(10)||
                                 '('||curError.line||','||curError.position||'): '||curError.text||p_lines(1)  );

        END IF;

      END LOOP;


      IF lb_error_found THEN

  --      WriteTempText(p_id ||'ERROR','Syntax error generating '||p_object_type ||' for '||p_object_name||CHR(10)||SQLERRM);

        FOR i IN  p_lines.first.. p_lines.last LOOP

            WriteTempText(p_id ||'ERROR',p_lines(i) || CHR(10));

        END LOOP;

        WriteTempText(p_id ||'ERROR','/'|| CHR(10));

      END IF;

    ELSE -- insert in t_temptext

        FOR i IN  p_lines.first.. p_lines.last LOOP

            WriteTempText(p_id ,p_lines(i) || CHR(10));

        END LOOP;

        WriteTempText(p_id ,'/'|| CHR(10));

    END IF;


EXCEPTION


   	WHEN OTHERS THEN

   	  IF p_raise_error = 'N' THEN

        WriteTempText(p_id || 'ERROR','Syntax error generating '||p_object_type ||' for '||p_object_name||CHR(10)||SQLERRM);

        FOR i IN  p_lines.first.. p_lines.last LOOP

            WriteTempText(p_id || 'ERROR',p_lines(i) || CHR(10));

        END LOOP;

        WriteTempText(p_id || 'ERROR','/'|| CHR(10));

        IF  Dbms_sql.is_open(c) THEN
            Dbms_Sql.Close_Cursor(c);
        END IF;

      ELSE

         Raise_Application_Error(-20000,'Syntax error generating '||p_object_type ||' for '||p_object_name||CHR(10)||SQLERRM  );


      END IF;



END SafeBuild;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : Anydata_to_String
-- Description    : Support function converting an ID to anydata building up dynamic SQL
--
-- Preconditions  :
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION Anydata_to_String(p_datetype VARCHAR2,p_id VARCHAR2) RETURN VARCHAR2
--</EC-DOC>
IS
  lv2_return VARCHAR2(100);

BEGIN

   -- known data types 'STRING','NUMBER','INTEGER','DATE','VARCHAR2'

   IF p_datetype = 'DATE' THEN

     lv2_return := 'anydata.Convertdate('||p_id||')';

   ELSIF p_datetype IN ('NUMBER','INTEGER') THEN

     lv2_return := 'anydata.ConvertNumber('||p_id||')';

   ELSE

     lv2_return := 'anydata.ConvertVarChar2('||p_id||')';


   END IF;

   RETURN lv2_return;

END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : RecompileInvalid
-- Description    :
--
-- Preconditions  :
--
--
--
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE RecompileInvalid
--</EC-DOC>
IS

    CURSOR c_invalid_obj IS
    SELECT 'alter package ' || object_name || ' compile' || chr(10) AS AlterStatement
    FROM user_objects
    WHERE status = 'INVALID'
    AND object_type = 'PACKAGE'
    UNION ALL
    SELECT 'alter package ' || object_name || ' compile body' || chr(10) AS AlterStatement
    FROM user_objects
    WHERE status = 'INVALID'
    AND object_type = 'PACKAGE BODY'
    UNION ALL
    SELECT 'alter view ' || object_name || ' compile' AS AlterStatement
    FROM user_objects
    WHERE status = 'INVALID'
    AND object_type = 'VIEW'
    UNION ALL
    SELECT 'alter trigger ' || object_name || ' compile' AS AlterStatement
    FROM user_objects
    WHERE status = 'INVALID'
    AND object_type = 'TRIGGER';

-- Comiple invalid objects

   lv2_sql      VARCHAR2(2000);
   ln_counter   NUMBER DEFAULT 0;

BEGIN

   FOR curInv IN c_invalid_obj LOOP

      lv2_sql := curInv.AlterStatement;
      ln_counter := ln_counter + 1;

      BEGIN
         EXECUTE IMMEDIATE lv2_sql;
      EXCEPTION
        WHEN OTHERS THEN
        lv2_sql := NULL;
      END;

   END LOOP;

END;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : BackupAndDeleteTable
-- Description    : Make an old_xxx version of a table and check that all rows was coied before deleting original table
--
-- Preconditions  : All foreign key constrainst need to be removed up front.
--
--
--
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE BackupAndDeleteTable(p_table_name VARCHAR2) IS
--</EC-DOC>

  lv2_sql Varchar2(4000);
  ln_result  NUMBER;


BEGIN

  IF length(p_table_name) > 26 then
			Raise_Application_Error(-20100,'Filename to long to make backup as old_'|| p_table_name);
  end if;

	lv2_sql := 'select count(*) FROM USER_TABLES WHERE TABLE_NAME = ''' ||p_table_name||'''';

  begin

		  ln_result := ecdp_dynsql.execute_singlerow_number(lv2_sql);

		  IF ln_result > 0 THEN


					lv2_sql := 'CREATE TABLE OLD_'|| p_table_name ||' AS  SELECT * FROM ' ||p_table_name;


				    ecdp_dynsql.execute_statement(lv2_sql);

				  	lv2_sql := 'select count(*) FROM (SELECT * FROM  '|| p_table_name ||' MINUS  SELECT * FROM OLD_' ||p_table_name||')';
				  	ln_result := ecdp_dynsql.execute_singlerow_number(lv2_sql);

				  	IF ln_result > 0 THEN
				      Raise_Application_Error(-20100,'Not complete backup for '|| p_table_name);
				    END IF;

				    lv2_sql := 'Drop table '||p_table_name;
				    ecdp_dynsql.execute_statement(lv2_sql);


				    If p_table_name not in ('CLASS_DEPENDENCY') THEN

				      lv2_sql := 'Drop table '||p_table_name||'_JN';
				      ecdp_dynsql.execute_statement(lv2_sql);

				    END IF;

    END IF;

		EXCEPTION

		    WHEN OTHERS THEN

		       Raise_Application_Error(-20100,'Failed backup for '|| p_table_name||' sql '||lv2_sql);

		end;



END;


FUNCTION CompareTableStructure(p_table_1 varchar2,
                               p_table_2 varchar2,
                               p_ignore_columns varchar2) RETURN NUMBER

IS

cursor c_tablecompare is
select p_table_1 as table_name, column_name from cols
where table_name = p_table_1
minus
select p_table_1 as table_name, column_name from cols
where table_name = p_table_2
union all
select p_table_2 as table_name, column_name from cols
where table_name = p_table_2
minus
select p_table_2 as table_name, column_name from cols
where table_name = p_table_1;

ln_result number := 0;

BEGIN

  FOR curColumn in c_tablecompare LOOP

    IF instr(p_ignore_columns, curColumn.column_name ) = 0 THEN

       Raise_Application_Error(-20100,'Column Mismatch for '|| curColumn.table_name||'.'||curColumn.column_name);

    END IF;

  END LOOP;

  return ln_result;


END;


END;
--~^UTDELIM^~--

DECLARE
BEGIN
 
  -- Some tables on the hard-coded "blacklist" did not have ctrl_object entries.
  -- They have to be inserted with pinc_trigger_ind='N', to ensure that table content pinc logging is disabled.
  -- Inserting them in ctrl_object will trigger generation of EC packages, unless we set ec_package='N'.
  --
  -- INSERT INTO ctrl_object (object_name, ec_package, pinc_trigger_ind) VALUES ('CALC_ATTRIBUTE_META', 'N', 'N');
  -- INSERT INTO ctrl_object (object_name, ec_package, pinc_trigger_ind) VALUES ('CALC_OBJECT_META', 'N', 'N');
  -- INSERT INTO ctrl_object (object_name, ec_package, pinc_trigger_ind) VALUES ('CALC_VARIABLE_META', 'N', 'N');
  -- INSERT INTO ctrl_object (object_name, ec_package, pinc_trigger_ind) VALUES ('CTRL_PINC', 'N', 'N');
  -- INSERT INTO ctrl_object (object_name, ec_package, pinc_trigger_ind) VALUES ('CTRL_PINC_REPORT', 'N', 'N');
  -- INSERT INTO ctrl_object (object_name, ec_package, pinc_trigger_ind) VALUES ('GROUPS', 'N', 'N');
  -- INSERT INTO ctrl_object (object_name, ec_package, pinc_trigger_ind) VALUES ('NAV_MODEL_OBJECT_RELATION', 'N', 'N');
  -- INSERT INTO ctrl_object (object_name, ec_package, pinc_trigger_ind) VALUES ('OBJECTS_TABLE', 'N', 'N');
  -- INSERT INTO ctrl_object (object_name, ec_package, pinc_trigger_ind) VALUES ('OBJECTS_VERSION_TABLE', 'N', 'N');
  -- INSERT INTO ctrl_object (object_name, ec_package, pinc_trigger_ind) VALUES ('T_TEMPTEXT', 'N', 'N');
  -- Move hard-coded "blacklist" to ctrl_object.pinc_trigger_ind.
  --
  UPDATE ctrl_object
  SET    pinc_trigger_ind = 'N'
  WHERE  pinc_trigger_ind IS NULL AND object_name IN (
     'CARGO_ANALYSIS','CARGO_ANALYSIS_ITEM','CARGO_DEMURRAGE','CARGO_LIFTING_DELAY','CARGO_TRANSPORT'
    ,'CARRIER_INSPECTION','CHEM_TANK_PRODUCT','CHEM_TANK_STATUS','EQPM_DAY_STATUS','TEST_DEVICE_RESULT'
    ,'EQPM_SAMPLE','EQUITY_SHARE','FCTY_DAY_ALARM','FCTY_DAY_HSE','FCTY_DAY_POB','FCTY_DAY_VESSEL'
    ,'FCTY_SPILL_EVENT','FLOWLINE_SUB_WELL_CONN','IFLW_DAY_STATUS','IWEL_DAY_ALLOC','IWEL_DAY_STATUS'
    ,'IWEL_MTH_ALLOC','IWEL_PERIOD_STATUS','LIFTING_ACTIVITY','LIFT_ACCOUNT_MTH_BALANCE'
    ,'LIFT_ACCOUNT_TRANSACTION','OBJECT_DAY_WEATHER','OBJECT_ITEM_COMMENT','PFLW_DAY_STATUS'
    ,'PFLW_RESULT','PFLW_SAMPLE','PROD_FORECAST','PROD_WELL_FORECAST','PROD_STRM_FORECAST','PROD_FCTY_FORECAST','PRODUCT_ANALYSIS_ITEM','PRODUCT_MEAS_SETUP'
    ,'PRODUCT_PRICE','PWEL_DAY_ALLOC','PWEL_DAY_COMP_ALLOC','PWEL_DAY_STATUS','PWEL_MTH_ALLOC'
    ,'PWEL_MTH_COMP_ALLOC','PWEL_PERIOD_STATUS','PWEL_RESULT','PWEL_SAMPLE','PWEL_SUB_DAY_STATUS'
    ,'SCTR_ACC_PERIOD_STATUS','SCTR_DAY_DP_DELIVERY','SCTR_DAY_DP_FORECAST','SCTR_DAY_DP_NOM'
    ,'SCTR_DELIVERY_EVENT','SCTR_DELIVERY_PNT_USAGE','SCTR_PERIOD_STATUS','SCTR_SUB_DAY_DP_DELIVERY'
    ,'SCTR_SUB_DAY_DP_FORECAST','SCTR_SUB_DAY_DP_NOM','SCTR_UNIT_PRICE','STORAGE_LIFTING'
    ,'STORAGE_LIFT_NOMINATION','STOR_DAY_COENT_FORECAST','STOR_MTH_COENT_FORECAST','STOR_PERIOD_EXPORT_STATUS'
    ,'STRM_DAY_ALLOC','STRM_DAY_COMP_ALLOC','STRM_DAY_STREAM','STRM_EVENT','STRM_MTH_ALLOC'
    ,'STRM_MTH_COMP_ALLOC','STRM_MTH_STREAM','STRM_WATER_ANALYSIS','TANK_MEASUREMENT','TANK_STRAPPING'
    ,'TANK_USAGE','WEBO_INTERVAL_GOR','WEBO_PLT','WEBO_PLT_RESULT','WEBO_PRESSURE_TEST','WEBO_SPLIT_FACTOR'
    ,'WELL_CHRONOLOGY','CTRL_PINC','CTRL_PINC_REPORT','T_TEMPTEXT', 'NAV_MODEL_OBJECT_RELATION', 'CALC_OBJECT_META', 'CALC_ATTRIBUTE_META', 'CALC_VARIABLE_META'
    ,'WELL_VERSION', 'OBJECTS_TABLE', 'OBJECTS_VERSION_TABLE', 'GROUPS'
  );

  -- Product default is that class config tables are not subject to pinc logging.
  --
  UPDATE ctrl_object
  SET    pinc_trigger_ind = 'N'
  WHERE  pinc_trigger_ind IS NULL AND object_name IN (
     'CLASS_ATTRIBUTE_CNFG',
     'CLASS_ATTR_PROPERTY_CNFG',
     'CLASS_CNFG',
     'CLASS_DEPENDENCY_CNFG',
     'CLASS_PROPERTY_CNFG',
     'CLASS_PROPERTY_CODES',
     'CLASS_RELATION_CNFG',
     'CLASS_REL_PROPERTY_CNFG',
     'CLASS_TRA_PROPERTY_CNFG',
     'CLASS_TRIGGER_ACTN_CNFG',
     'CLASS_ATTR_PRES_CONFIG'
  );

  COMMIT;

  ecdp_generate.generate(NULL, ecdp_generate.AP_TRIGGERS);
END;
--~^UTDELIM^~--

DECLARE
    seqs NUMBER;
BEGIN
    SELECT COUNT(*) INTO seqs FROM user_sequences WHERE sequence_name = 'PROCESS_LOG_ID_SEQ';
    IF seqs = 0 THEN
        EXECUTE IMMEDIATE 'create sequence PROCESS_LOG_ID_SEQ';
    END IF;
END;
--~^UTDELIM^~--
DECLARE
    seqs NUMBER;
BEGIN
    SELECT COUNT(*) INTO seqs FROM user_sequences WHERE sequence_name = 'JBPM_BPM_DATA_SET_USAGE_WS_SEQ';
    IF seqs = 1 THEN
        EXECUTE IMMEDIATE 'rename JBPM_BPM_DATA_SET_USAGE_WS_SEQ to BPM_DATA_SET_USAGE_WS_SEQ';
    END IF;
END;
--~^UTDELIM^~--
DECLARE
    seqs NUMBER;
BEGIN
    SELECT COUNT(*) INTO seqs FROM user_sequences WHERE sequence_name = 'CASE_ID_INFO_ID_SEQ';
    IF seqs = 0 THEN
        EXECUTE IMMEDIATE 'create sequence CASE_ID_INFO_ID_SEQ';
    END IF;
END;
--~^UTDELIM^~--
DECLARE
    seqs NUMBER;
BEGIN
    SELECT COUNT(*) INTO seqs FROM user_sequences WHERE sequence_name = 'CASE_ROLE_ASSIGN_LOG_ID_SEQ';
    IF seqs = 0 THEN
        EXECUTE IMMEDIATE 'create sequence CASE_ROLE_ASSIGN_LOG_ID_SEQ';
    END IF;
END;
--~^UTDELIM^~--
DECLARE
    seqs NUMBER;
BEGIN
    SELECT COUNT(*) INTO seqs FROM user_sequences WHERE sequence_name = 'CASE_FILE_DATA_LOG_ID_SEQ';
    IF seqs = 0 THEN
        EXECUTE IMMEDIATE 'create sequence CASE_FILE_DATA_LOG_ID_SEQ';
    END IF;
END;
--~^UTDELIM^~--
DECLARE
    seqs NUMBER;
BEGIN
    SELECT COUNT(*) INTO seqs FROM user_sequences WHERE sequence_name = 'EXEC_ERROR_INFO_ID_SEQ';
    IF seqs = 0 THEN
        EXECUTE IMMEDIATE 'create sequence EXEC_ERROR_INFO_ID_SEQ';
    END IF;
END;
--~^UTDELIM^~--
