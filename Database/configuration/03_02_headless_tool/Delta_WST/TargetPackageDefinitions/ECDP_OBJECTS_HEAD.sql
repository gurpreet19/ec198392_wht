CREATE OR REPLACE PACKAGE EcDp_Objects IS

/****************************************************************
** Package        :  EcDp_Objects, header part
**
** $Revision: 1.27.48.1 $
**
** Purpose        :  Provide basic functions on Objects
**
** Documentation  :  www.energy-components.com
**
** Created  : 27.02.2003  Øistein Haaland
**
** Modification history:
**
** Date     Whom   description:
** -------  ------ --------------------------------------
**  13.05.03 AV    Added new procedure WriteObjDataRow
**  30.06.03 AV    Added p_rev_text as default parameter in setPropertyxxx procedures
**  04.07.03 AV    Added p_rev_no
**  22.07.03 AV    Rework added isValidOwnerReference, getLastDataClassDaytimeRef
**                 UpdateObjectDataTables
**  23.07.03 AV    Added isValidClassReference
**  03.09.03 AV    Added class_name and class_type as parameters to UpdateObjectDataTables
**  02.12.03 SHN   Added new functions: InsNewClassicObjVersion and InsNewClassicObj
**  16.12.03 SHN   Added procedure InsertAttribute.
**  13.10.04 AV    Added GetInsertedRelationID, GetUpdatedRelationID, GetInsertedDaytime
**  16.11.04 AV    Added function ExistsObjectVersion to check if a version allready exist
**                 on the date you are trying to creating a new version for
**  10.02.04 SHN    Rewritten due to major changes in release 8.1
**  15.03.05 AV     Added new function If$Str, help function for generate trigger package
**  07.04.05 SHN    Removed procedure SetObjStartDate/SetObjEndDate and added function IsValidObjStartDate,IsValidObjEndDate
**  08.04.05 AV     Renamed If$Str to IfDollarStr
**  12.04.05 DN     Added PRAGMAS.
**  15.04.05 SHN    Added function GetNonValidRelation
**  08.11.05 Rov    Tracker #3046 Added new function getParentFacility
**  23.11.05 DN     Moved getParentFacility to EC_PROD EcDp_Facility.
**  08.05.06 Toha   TI#3691: Added default parameters to GetFirstClassDaytimeRef, GetFirstClassDaytimeRef
**  08.04.08 LIZ    ECPD-4576: Took out new procedures and put under EcBp_Production_Object instead.
**  20.07.12 Wang   Add function CheckObjectAccess to check whether current AppUser have access to given object_id
*****************************************************************/

type update_column is  RECORD(
    column_name         VARCHAR2(30),
    column_type         VARCHAR2(30),
    column_data         ANYDATA,
    table_name          VARCHAR2(32),
    column_attr_name    VARCHAR2(32)
    );

TYPE update_list is table of update_column index by BINARY_INTEGER;

PROCEDURE AddUpdateList(
    p_update_list     IN OUT  ecdp_objects.update_list,
    p_count           IN OUT  NUMBER ,
    p_column_name             VARCHAR2 ,
    p_data_type		      	VARCHAR2 ,
    p_column_data             ANYDATA,
    p_table_name              VARCHAR2 DEFAULT NULL,
    p_column_attr_name        VARCHAR2 DEFAULT NULL
);

PROCEDURE UpdateTables(
   p_class_name       VARCHAR2,
   p_class_type       VARCHAR2,
   p_table_name       VARCHAR2,
   p_update_list      ecdp_objects.update_list,
   p_old_object_id    VARCHAR2,
   p_old_daytime      DATE
   );

FUNCTION getUpdateListValue(p_update_column ecdp_objects.update_column )
RETURN VARCHAR2;
--PRAGMA RESTRICT_REFERENCES (getUpdateListValue, WNDS, WNPS, RNPS);



FUNCTION GetObjIDFromCode(
  p_class_name          VARCHAR2,
  p_code                VARCHAR2
)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (GetObjIDFromCode, WNDS, WNPS, RNPS);


FUNCTION GetObjClassName(
  p_object_id VARCHAR2
)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (GetObjClassName, WNDS, WNPS, RNPS);


FUNCTION GetObjName(
  p_object_id VARCHAR2,
  p_daytime DATE
)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (GetObjName, WNDS, WNPS, RNPS);

FUNCTION GetObjCode(
  p_object_id VARCHAR2
)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (GetObjCode, WNDS, WNPS, RNPS);

FUNCTION GetObjStartDate(
  p_object_id VARCHAR2
)
RETURN DATE;
PRAGMA RESTRICT_REFERENCES (GetObjStartDate, WNDS, WNPS, RNPS);

FUNCTION GetObjEndDate(
  p_object_id VARCHAR2
)
RETURN DATE;
PRAGMA RESTRICT_REFERENCES (GetObjEndDate, WNDS, WNPS, RNPS);

FUNCTION IsValidObjStartDate(
                   p_object_id      VARCHAR2,
                   p_daytime        DATE)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (IsValidObjStartDate, WNDS, WNPS, RNPS);

FUNCTION IsValidObjEndDate(
                   p_object_id      VARCHAR2,
                   p_daytime        DATE)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (IsValidObjEndDate, WNDS, WNPS, RNPS);

FUNCTION GetFirstClassDaytimeRef(
   p_class_name 	VARCHAR2,
   p_object_id  	VARCHAR2,
   p_recursive BOOLEAN DEFAULT FALSE,
   p_min_date DATE DEFAULT NULL

)
RETURN DATE;
PRAGMA RESTRICT_REFERENCES (GetFirstClassDaytimeRef, WNDS, WNPS, RNPS);

FUNCTION GetLastClassDaytimeRef(
   p_class_name VARCHAR2,
   p_object_id  VARCHAR2,
   p_recursive BOOLEAN DEFAULT FALSE,
   p_max_date DATE DEFAULT NULL
)
RETURN DATE;
PRAGMA RESTRICT_REFERENCES (GetLastClassDaytimeRef, WNDS, WNPS, RNPS);


PROCEDURE DelObj(
   p_object_id 				VARCHAR2
);

FUNCTION isValidOwnerReference(
   p_class_name VARCHAR2,
   p_object_id  VARCHAR2
)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (isValidOwnerReference, WNDS, WNPS, RNPS);

FUNCTION isValidClassReference(
   p_class_name VARCHAR2,
   p_object_id  VARCHAR2
)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (isValidClassReference, WNDS, WNPS, RNPS);

FUNCTION GetInsertedDaytime(
		p_object_start_date DATE,
		p_daytime DATE,
		p_object_end_date DATE)
RETURN DATE;
PRAGMA RESTRICT_REFERENCES (GetInsertedDaytime, WNDS, WNPS, RNPS);

FUNCTION GetInsertedRelationID(
		p_role_name VARCHAR2,
		p_rel_class_name VARCHAR2,
		p_new_rel_object_id VARCHAR2,
		p_new_object_code VARCHAR2,
		p_daytime				DATE)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (GetInsertedRelationID, WNDS, WNPS, RNPS);

FUNCTION  GetUpdatedRelationID(
		p_upd_id 					BOOLEAN,
		p_upd_code 					BOOLEAN,
		p_role_name 				VARCHAR2,
		p_rel_class_name 			VARCHAR2,
		p_new_rel_object_id 		VARCHAR2,
		p_new_object_code 		VARCHAR2,
		p_daytime 					DATE)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (GetUpdatedRelationID, WNDS, WNPS, RNPS);

FUNCTION  GetInsertedObjectID(
		p_new_rel_object_id VARCHAR2)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (GetInsertedObjectID, WNDS, WNPS, RNPS);

FUNCTION  IfDollarStr(p_condition VARCHAR2,p1 VARCHAR2, p2 VARCHAR2)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (IfDollarStr, WNDS, WNPS, RNPS);

FUNCTION GetNonValidRelation(
   p_class_name 				VARCHAR2,
   p_object_id  				VARCHAR2,
   p_daytime					DATE
)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (GetNonValidRelation, WNDS, WNPS, RNPS);

FUNCTION GetNonValidRelationEndDate(
   p_class_name 				VARCHAR2,
   p_object_id  				VARCHAR2,
   p_end_date					DATE
)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (GetNonValidRelationEndDate, WNDS, WNPS, RNPS);

FUNCTION CheckObjectAccess(
   p_object_id VARCHAR2,
   p_object_class_name VARCHAR2 DEFAULT NULL
)
RETURN VARCHAR2;

END EcDp_Objects;