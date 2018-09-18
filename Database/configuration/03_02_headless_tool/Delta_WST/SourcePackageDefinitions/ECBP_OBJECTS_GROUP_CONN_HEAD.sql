CREATE OR REPLACE PACKAGE EcBp_Objects_Group_Conn IS

/****************************************************************
** Package        :  EcBp_Objects_Group_Conn, header part
**
** $Revision: 1.8 $
**
** Purpose        :  Provide basic functions on objects
**
** Documentation  :  www.energy-components.com
**
** Created  : 25.05.2007  Sarojini Rajaretnam
**
** Modification history:
**
**  Date     	Whom  	Change description:
**  ------   	----- 	--------------------------------------
**  24.06.2008 	rajarsar ECPD-6880: Updated validateDeleteObjectGrp,verifyObjectGrp, verifyObjectGrpConn and added checkIfEventOverlaps
**  19.05.2009  sharawan ECPD-10212: Added procedure updateChildEndDate
**  23.07.2009  rajarsar ECPD-11890: Added procedure deleteChild
**  05.08.2009  rajarsar ECPD-11890: Added function findParentFacility
**  11.06.20010 leongsei ECPD-14703: Added function verifyObjectGrpBefore
**  15.06.2010  oonnnng  ECPD-14704: Added checkSwingWellConn() function.
**	27.06.2014	makkkkam ECPD-27802: Added verifyEqpmConn and updateEqpmConnEndDate
**	15.05.2016	dhavaalo ECPD-34558: Removed updateEqpmConnEndDate
****************************************************************/

PROCEDURE validateDeleteObjectGrp(p_object_id VARCHAR2, p_daytime DATE, p_group_type VARCHAR2);

PROCEDURE verifyObjectGrpBefore(p_object_id VARCHAR2,p_parent_start_date DATE, p_parent_group_type VARCHAR2, p_end_date DATE);

PROCEDURE verifyObjectGrp(p_object_id VARCHAR2,p_parent_start_date DATE, p_parent_group_type VARCHAR2, p_end_date DATE);

PROCEDURE verifyObjectGrpConn(p_object_id VARCHAR2, p_parent_start_date DATE, p_parent_group_type VARCHAR2, p_daytime DATE, p_end_date DATE);

PROCEDURE checkIfEventOverlaps(p_object_id VARCHAR2, p_parent_start_date DATE, p_parent_group_type VARCHAR2, p_child_object_id VARCHAR2, p_daytime DATE, p_end_date DATE);

PROCEDURE updateChildEndDate(p_object_id VARCHAR2, p_group_type VARCHAR2, p_daytime DATE, p_object_end_date DATE);

PROCEDURE deleteChild(p_object_id VARCHAR2, p_child_object_id VARCHAR2, p_parent_group_type VARCHAR2, p_daytime DATE);

FUNCTION findParentFacility(p_child_object_id VARCHAR2,  p_child_class_name VARCHAR2,  p_daytime DATE)
RETURN VARCHAR2;

PROCEDURE checkSwingWellConn(p_object_id VARCHAR2, p_parent_start_date DATE, p_parent_group_type VARCHAR2, p_child_object_id VARCHAR2, p_daytime DATE, p_end_date DATE);

PROCEDURE verifyEqpmConn(p_object_id VARCHAR2, p_eqpm_conn_name VARCHAR2, p_daytime DATE, p_end_date DATE);

END EcBp_Objects_Group_Conn;