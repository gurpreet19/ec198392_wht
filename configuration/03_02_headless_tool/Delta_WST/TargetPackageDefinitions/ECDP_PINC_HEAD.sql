CREATE OR REPLACE PACKAGE EcDp_PInC IS
/**************************************************************
** Package:    EcDp_PInC
**
** $Revision: 1.6 $
**
** Filename:   EcDp_PInC_head.sql
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
** Created:   	10.01.05  Christer Grims?th, EC FRMW
**
**
** Modification history:
**
**
** Date:     Whom:  Change description:
** --------  ----- --------------------------------------------
** 10.01.05   CGR   Created.
** 26.04.05	  MOT   Added PROCEDURE generateReport
** 28.04.05   MOT   generateReport updated
** 09.05.05   MOT   Updated getLiveTag to also accept TABLE CONTENT
**************************************************************/

  /* ********** */
  /* PUBLIC API */
  /* ********** */

  /* Get/set the Install Mode */
  PROCEDURE enableInstallMode(p_tag VARCHAR2);
  PROCEDURE disableInstallMode;
  FUNCTION isInstallMode RETURN BOOLEAN;
  FUNCTION getInstallModeTag RETURN VARCHAR2;

  /* Compute MD5 sum of some bits */
  FUNCTION computeMD5(p_object IN BLOB) RETURN VARCHAR2;

  /* Get Info about Live objects */
  PROCEDURE getLiveSrc(p_source IN OUT BLOB, p_type VARCHAR2, p_name VARCHAR2, p_key VARCHAR2 DEFAULT NULL);
  FUNCTION  getLiveSrc(p_type VARCHAR2, p_name VARCHAR2, p_key VARCHAR2 DEFAULT NULL) RETURN BLOB;
  PROCEDURE getLiveTableSrc(p_source IN OUT BLOB, p_name VARCHAR2, p_alterStmt VARCHAR2 DEFAULT NULL);
  PROCEDURE getLiveIndexSrc(p_source IN OUT BLOB, p_name VARCHAR2);
  FUNCTION  getLiveMD5(p_type VARCHAR2, p_name VARCHAR2, p_key VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
  FUNCTION  getLiveTag(p_type VARCHAR2, p_name VARCHAR2, p_key VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

  /* Get Info from CTRL_PINC about objects */
  FUNCTION getMD5ByTag(p_type VARCHAR2, p_name VARCHAR2, p_tag VARCHAR2) RETURN VARCHAR2;
  FUNCTION getMD5ByDaytime(p_type VARCHAR2, p_name VARCHAR2, p_daytime TIMESTAMP) RETURN VARCHAR2;
  PROCEDURE getSrcByTag(p_source IN OUT BLOB, p_type VARCHAR2, p_name VARCHAR2, p_tag VARCHAR2);

  /* Table Content helper methods */
  PROCEDURE logTableContent(p_tableName VARCHAR2, p_operation VARCHAR2, p_key VARCHAR2, p_source BLOB);

  /* Report methods */
  PROCEDURE generateReport(p_reportType VARCHAR2, p_daytime DATE, p_prefix VARCHAR2, p_suffix VARCHAR2, p_filter1 VARCHAR2 DEFAULT NULL, p_filter2 VARCHAR2 DEFAULT NULL, p_filter3 VARCHAR2 DEFAULT NULL);
  PROCEDURE writeRepObj(p_report IN OUT CLOB, p_daytime TIMESTAMP, p_typeFilter VARCHAR2, p_nameFilter VARCHAR2);
  PROCEDURE writeRepCustom(p_report IN OUT CLOB, p_typeFilter VARCHAR2, p_nameFilter VARCHAR2);
  PROCEDURE writeRepTag(p_report IN OUT CLOB, p_tag VARCHAR2);
  PROCEDURE writeRepStatus(p_report IN OUT CLOB);

  /* *************************************** */
  /* PUBLIC UTILITY and TEST API             */
  /* NOTE: This may be removed at any time!  */
  /* *************************************** */
  FUNCTION getRep_TEST(p_reportName VARCHAR2, p_daytime TIMESTAMP, p_typeFilter VARCHAR2, p_nameFilter VARCHAR2, p_tag VARCHAR2) RETURN CLOB;

END EcDp_PInC;