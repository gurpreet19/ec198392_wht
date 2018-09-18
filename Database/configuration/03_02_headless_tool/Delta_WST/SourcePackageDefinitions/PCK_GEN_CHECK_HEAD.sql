CREATE OR REPLACE PACKAGE pck_gen_check IS
/**************************************************************
** Package   :  PCK_GEN_CHECK
**
** $Revision: 1.11 $
**
** Purpose   :  Provide general check according to defined entries in CTRL_CHECK_RULES
**
** General Logic: Creates dynamic SQL to perform checks
**
** Created:      08.06.99 HS/HN/TEJ
**
** Modification history:
**
** Date:     Whom:  Change description:
** -------   -----  ------------------------------------------
** 14.12.2004 DN    Moved getScreenLabel from pck_check to here.
** 18.02.2005 Hang   The following codes have been modified in function run_day_check : well_type IN ('WI','GI') to
**                   well_type IN ('WI','GI', 'OPGI', 'GPI'),  AND well_type IN ('OP','GP?) to well_type IN ('OP','GP', 'OPGI', 'GPI')
**                   in order to accommodate new well types as per enhancement for TI#1874.
** 12.07.2006 kaurrnar TI#4118 - Add run_check_all
** 20.08.2006 Toha  TI#3798 - check all performance
** 17.08.2006 Lau   TI#3998 - Schedule check rule by facility
**************************************************************/
--
--------------------------------------------------------------------------------------------------------------
-- PROCEDURES
-------------------------------------------------------------------------------------------------------------

PROCEDURE run_check_all ( p_from_date DATE,
                      p_to_date DATE,
                      p_class_type VARCHAR2 DEFAULT NULL,
                      p_fcty_id VARCHAR2 DEFAULT NULL);

PROCEDURE run_check(	p_from_date DATE,
						          p_to_date DATE,
                        p_object_where_clause VARCHAR2,
                        p_object_id VARCHAR2,
                        p_check_id NUMBER,
						          p_check_group VARCHAR2 DEFAULT 'ALL',
                        p_class_type VARCHAR2,
                        p_user_object VARCHAR2,
                        p_fcty_id VARCHAR2 DEFAULT NULL);


PROCEDURE run_day_check(p_day DATE,
                        p_check_id NUMBER,
						            p_check_group VARCHAR2 DEFAULT 'ALL',
                        p_class_type VARCHAR2,
                        p_where_clause VARCHAR2,
                        p_fcty_id VARCHAR2 DEFAULT NULL);

PROCEDURE log_message(	p_check_id 			NUMBER,
						p_daytime 			DATE,
						p_check_group 		VARCHAR2,
						p_severity_level	VARCHAR2,
						p_log_message 		VARCHAR2,
						p_object_id 		VARCHAR2,
						p_class_name		VARCHAR2);

FUNCTION hasLogEntires(	p_component VARCHAR2,
						p_user 		VARCHAR2)
						RETURN NUMBER;

------------------------------------------------------------
-- FUNCTION: getScreenLabel
--          Finds treeview label for a given treeview url
------------------------------------------------------------
FUNCTION getScreenLabel(p_screen_url   VARCHAR2) RETURN VARCHAR2;



END pck_gen_check;