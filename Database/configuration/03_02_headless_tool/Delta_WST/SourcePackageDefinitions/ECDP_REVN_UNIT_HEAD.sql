CREATE OR REPLACE PACKAGE EcDp_Revn_Unit IS
/**************************************************************
** Package	:  EcDp_Revn_Unit
**
** $Revision: 1.6 $
**
** Purpose	:  Functions used to convert to either other units or fractions for EC Revenue
**
** General Logic:
**
**
** Modification history:
**
** SEE PACKAGE BODY
**
**************************************************************/

FUNCTION convertValue(--p_sysnam    VARCHAR2,
                      p_input_val NUMBER,
                      p_from_unit VARCHAR2,
                      p_to_unit   VARCHAR2,
                      p_object_id VARCHAR2, -- The object_id to get the BOE factor from
                      p_daytime   DATE DEFAULT NULL)
RETURN NUMBER;

FUNCTION boe_convert(p_input_val      NUMBER,
                     p_from_unit      VARCHAR2,
                     p_to_unit        VARCHAR2,
                     p_daytime        DATE,
                     p_stream_item_id VARCHAR2,
                     p_boe_from_uom   VARCHAR2 DEFAULT NULL,
                     p_boe_factor     NUMBER DEFAULT NULL)
RETURN NUMBER;


FUNCTION BOEInvert(p_input_val      NUMBER,
                   p_boe_to_uom     VARCHAR2,
                   p_daytime        DATE,
                   p_stream_item_id VARCHAR2,
                   p_boe_from_uom   VARCHAR2 DEFAULT NULL,
                   p_boe_factor     NUMBER DEFAULT NULL)
RETURN NUMBER;


FUNCTION GetUOMSetQty( -- returns the best match from input list
   ptab_uom_set  IN OUT EcDp_Unit.t_uomtable,
   target_uom_code VARCHAR2,
   p_daytime DATE,
   p_object_id VARCHAR2,
   p_do_delete BOOLEAN DEFAULT TRUE
   ) RETURN NUMBER;

END EcDp_Revn_Unit;