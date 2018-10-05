CREATE OR REPLACE PACKAGE EcDp_Unit IS
/**************************************************************
** Package	:  EcDp_Unit
**
** $Revision: 1.16 $
**
** Purpose	:  Functions used to convert to either other units or fractions
**
** General Logic:
**
**
** Modification history:
**
** Date:     Whom	Change description:
** yyyymmdd
** --------  ---- ---------------------------------------------
** 20040108  DN   Added GetUnitFromLogical.
** 20050405  SHN  Added function GetViewFormatMask
** 20060823 SRA  Added Revenue Functionality
** 20100326 rajarsar ECPD:11223:Updated convertValue,added getUnitConObjFactor, getUnitConGrpFactor and getBaseUnitPrefFactor
**************************************************************/
--
TYPE t_uom_set IS RECORD
  (
   qty NUMBER,
   uom VARCHAR2(32)
  );

TYPE t_UOMTable IS TABLE OF t_uom_set;

TYPE t_unit_rec IS RECORD
    (
       from_unit VARCHAR2(32)
       ,to_unit VARCHAR2(32)
       ,prefix VARCHAR2(32)
       ,prefix_factor NUMBER
       ,mult_fact NUMBER
       ,add_numb NUMBER
       ,precision NUMBER
       ,use_ue VARCHAR2(1)
       ,user_exit VARCHAR2(240)
       ,inverse VARCHAR(1)
    );

FUNCTION GetUOMGroup(p_uom_code  VARCHAR2)
RETURN VARCHAR2;

FUNCTION GetUOMSubGroup(p_uom_code  VARCHAR2)
RETURN VARCHAR2;

FUNCTION GetUOMSubGroupTarget(p_uom_subgroup  VARCHAR2)
RETURN VARCHAR2;

FUNCTION GetSubGroupFromUOM(p_uom  VARCHAR2)
RETURN VARCHAR2;

FUNCTION GetUOMSetQty(
   ptab_uom_set  IN OUT t_uomtable,
   target_uom_code VARCHAR2,
   p_daytime DATE
   )

RETURN NUMBER;

PROCEDURE GenQtyUOMSet(
   ptab_uom_set IN OUT t_uomtable,
   p_qty1 NUMBER,
   p_uom1 VARCHAR2,
   p_qty2 NUMBER,
   p_uom2 VARCHAR2,
   p_qty3 NUMBER,
   p_uom3 VARCHAR2,
   p_qty4 NUMBER,
   p_uom4 VARCHAR2,
   p_qty5 NUMBER DEFAULT NULL,
   p_uom5 VARCHAR2 DEFAULT NULL,
   p_qty6 NUMBER DEFAULT NULL,
   p_uom6 VARCHAR2 DEFAULT NULL
)
;

FUNCTION convertValue(p_input_val NUMBER
                      ,p_from_unit VARCHAR2
                      ,p_to_unit   VARCHAR2
                      ,p_daytime   DATE DEFAULT NULL
                      ,p_precision   NUMBER DEFAULT NULL
                      ,p_via_group VARCHAR2 DEFAULT 'N'
                      ,p_supress_error VARCHAR2 DEFAULT 'N'
                      ,p_source_object_id_1 VARCHAR2 DEFAULT NULL -- Infrastructure ID 1, can be left NULL for general conversion
                      ,p_source_object_id_2 VARCHAR2 DEFAULT NULL -- Infrastructure ID 2, fallback if not hit on no 1
                      ,p_source_object_id_3 VARCHAR2 DEFAULT NULL -- Infrastructure ID 3, fallback if not hit on no 2
                      ,p_source_object_id_4 VARCHAR2 DEFAULT NULL -- Infrastructure ID 4, fallback if not hit on no 3
                      ,p_source_object_id_5 VARCHAR2 DEFAULT NULL -- Infrastructure ID 5, fallback if not hit on no 4
                      )
RETURN NUMBER
;

PRAGMA RESTRICT_REFERENCES (convertValue ,RNPS, WNPS,WNDS);


FUNCTION GetUnitFromLogical(p_measurement_type VARCHAR2) RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (GetUnitFromLogical ,RNPS, WNPS,WNDS);

FUNCTION GetViewUnitFromLogical(p_measurement_type VARCHAR2) RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (GetViewUnitFromLogical ,RNPS, WNPS,WNDS);


FUNCTION GetUnitLabel(p_unit VARCHAR2) RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (GetUnitLabel ,RNPS, WNPS,WNDS);

FUNCTION GetViewFormatMask(p_uom_code	VARCHAR2,
									p_static_pres_syntax	VARCHAR2)
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (GetViewFormatMask,RNPS, WNPS,WNDS);

FUNCTION GetRevnViewFormatMask(p_measurement_type VARCHAR2,p_uom_code	VARCHAR2)
RETURN VARCHAR2;

FUNCTION getBaseUnitFactor(p_from_unit VARCHAR2, p_to_unit VARCHAR2, p_object_id VARCHAR2, p_daytime DATE)
RETURN t_unit_rec;
PRAGMA RESTRICT_REFERENCES (getBaseUnitFactor ,RNPS, WNPS,WNDS);

FUNCTION getObjectConvFactor(p_from_unit VARCHAR2, p_to_unit VARCHAR2, p_object_id VARCHAR2, p_daytime DATE, p_prefix_ind VARCHAR2 DEFAULT 'N')
RETURN t_unit_rec;
PRAGMA RESTRICT_REFERENCES (getObjectConvFactor ,RNPS, WNPS,WNDS);

FUNCTION getDefaultConvFactor(p_from_unit VARCHAR2, p_to_unit VARCHAR2, p_daytime DATE)
RETURN t_unit_rec;
PRAGMA RESTRICT_REFERENCES (getDefaultConvFactor ,RNPS, WNPS,WNDS);


END EcDp_Unit;