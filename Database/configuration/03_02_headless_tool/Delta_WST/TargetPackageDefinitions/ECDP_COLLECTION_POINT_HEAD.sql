CREATE OR REPLACE PACKAGE EcDp_Collection_Point IS
/****************************************************************
** Package        :  EcDp_Collection_Point, header part
**
** $Revision: 1.1.4.5 $
**
** Purpose        :  Allows reorganize groups of objects from one Collection Point to another.
**
** Documentation  :  www.energy-components.com
**
** Created  : 31.12.2012
**
** Modification history:
**
** Version  Date       Whom     Change description:
** -------  ------     -----    --------------------------------------
**    1.0   31.12.2012 kumarsur ECPD-22967 Collection Point Hierarchy Reorganization business function.
*****************************************************************/

 PROCEDURE createNewVersion(p_object_id VARCHAR2, p_object_type VARCHAR2, p_daytime VARCHAR2, p_col_point_id VARCHAR2, p_user VARCHAR2);

 PROCEDURE insertVersion(p_object_id VARCHAR2, p_object_type VARCHAR2, p_daytime DATE, p_col_point_id VARCHAR2, p_user VARCHAR2);

 PROCEDURE changeAllVersions(p_object_id VARCHAR2, p_object_type VARCHAR2, p_col_point_id VARCHAR2, p_user VARCHAR2);

 PROCEDURE updateVersion(p_object_id VARCHAR2, p_object_type VARCHAR2, p_col_point_id VARCHAR2, p_user VARCHAR2);

 PROCEDURE updateProdTestResult(p_object_id VARCHAR2, p_col_point_id VARCHAR2, p_user VARCHAR2);

 PROCEDURE updateProdTestResultDaytime(p_object_id VARCHAR2, p_daytime DATE, p_col_point_id VARCHAR2, p_user VARCHAR2);

END EcDp_Collection_Point;