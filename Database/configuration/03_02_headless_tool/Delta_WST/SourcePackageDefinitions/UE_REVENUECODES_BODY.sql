CREATE OR REPLACE PACKAGE BODY ue_RevenueCodes IS
/****************************************************************
** Package        :  ue_RevenueCodes, body part
**
** $Revision: 1.3 $
**
** Purpose        :  Provide functions to get codes for revenue
**
** Documentation  :  www.energy-components.com
**
** Created  : 09.11.2006 Sigve Ravndal
**
** Modification history:
**
** Version  Date         Whom   Change description:
** -------  ------       -----  --------------------------------------
**  1.1     01.11.2006   SRA         Initial version
******************************************************************/

FUNCTION GetCodeForClass(
   p_object_id VARCHAR2, -- The id to create the code for
   p_daytime   DATE, -- The date to create the code for
   p_class     VARCHAR2 -- The class to generate the code for
)
RETURN VARCHAR2 -- new code
IS
lv2_code VARCHAR2(32);
lv2_type VARCHAR2(32);
lv2_prefix  VARCHAR2(32);
BEGIN
    IF p_class = 'STREAM' THEN
        Ecdp_System_Key.assignNextNumber('STREAM', lv2_code);
        lv2_code := 'S' || lpad(to_char(lv2_code),5, '0');
    ELSIF p_class = 'STREAM_ITEM' THEN
        Ecdp_System_Key.assignNextNumber('STREAM_ITEM', lv2_code);
        lv2_code := 'SI' || lpad(to_char(lv2_code),6, '0');
    ELSIF p_class = 'SPLIT_KEY' THEN
        lv2_type := ec_split_key_version.split_type(p_object_id, p_daytime, '<=');
        IF (lv2_type = 'PRODUCT') THEN
            Ecdp_System_Key.assignNextNumber('SPLIT_KEY_PRODUCT', lv2_code);
            lv2_prefix := 'PR';
        ELSIF (lv2_type = 'COMPANY') THEN
            Ecdp_System_Key.assignNextNumber('SPLIT_KEY_COMPANY', lv2_code);
            lv2_prefix := 'CO';
        ELSIF (lv2_type = 'FIELD') THEN
            Ecdp_System_Key.assignNextNumber('SPLIT_KEY_COMPANY', lv2_code);
            lv2_prefix := 'FI';
        ELSIF (lv2_type = 'PROFIT_CENTER') THEN
            Ecdp_System_Key.assignNextNumber('SPLIT_KEY_PROFIT_CENTER', lv2_code);
            lv2_prefix := 'PC';
        ELSIF (lv2_type = 'STREAM_ITEM_CATEGORY') THEN
            Ecdp_System_Key.assignNextNumber('SPLIT_KEY_STREAM_ITEM_CATEGORY', lv2_code);
            lv2_prefix := 'SC';
        ELSIF (lv2_type = 'STREAM_ITEM') THEN
            Ecdp_System_Key.assignNextNumber('SPLIT_KEY_STREAM_ITEM', lv2_code);
            lv2_prefix := 'SI';
        ELSIF (lv2_type = 'SPLIT_ITEM_OTHER') THEN
            Ecdp_System_Key.assignNextNumber('SPLIT_KEY_SPLIT_ITEM_OTHER', lv2_code);
            lv2_prefix := 'OT';
        END IF;
        lv2_code := lv2_prefix || lpad(to_char(lv2_code),4, '0');
    ELSIF p_class = 'BALANCE' THEN
        Ecdp_System_Key.assignNextNumber('BALANCE', lv2_code);
        lv2_code := 'HCB' || lpad(to_char(lv2_code),4, '0');
    ELSIF p_class = 'INVENTORY' THEN
        Ecdp_System_Key.assignNextNumber('INVENTORY', lv2_code);
        lv2_code := 'IN' || lpad(to_char(lv2_code),4, '0');
    ELSIF p_class = 'PRODUCT_NODE_ITEM' THEN
        Ecdp_System_Key.assignNextNumber('PRODUCT_NODE_ITEM', lv2_code);
        lv2_code := 'PD' || lpad(to_char(lv2_code),4, '0');
    ELSIF p_class = 'STREAM_ITEM_COLLECTION' THEN
        Ecdp_System_Key.assignNextNumber('STREAM_ITEM_COLLECTION', lv2_code);
        lv2_code := 'IL' || lpad(to_char(lv2_code),4, '0');
    END IF;

    RETURN lv2_code;

END GetCodeForClass;

PROCEDURE UpdateCodeForClass(
   p_object_id VARCHAR2, -- The id to create the code for
   p_daytime   DATE, -- The date to create the code for
   p_class     VARCHAR2 -- The class to generate the code for
)
IS
lv2_code VARCHAR2(32);
BEGIN
    lv2_code := GetCodeForClass(p_object_id, p_daytime, p_class);
    IF p_class = 'STREAM' THEN
        UPDATE stream t SET t.object_code = lv2_code WHERE object_id = p_object_id;
    ELSIF p_class = 'STREAM_ITEM' THEN
        UPDATE stream_item t SET t.object_code = lv2_code WHERE object_id = p_object_id;
    ELSIF p_class = 'SPLIT_KEY' THEN
        UPDATE split_key t SET t.object_code = lv2_code WHERE object_id = p_object_id;
    ELSIF p_class = 'BALANCE' THEN
        UPDATE balance t SET t.object_code = lv2_code WHERE object_id = p_object_id;
    ELSIF p_class = 'INVENTORY' THEN
        UPDATE inventory t SET t.object_code = lv2_code WHERE object_id = p_object_id;
    ELSIF p_class = 'PRODUCT_NODE_ITEM' THEN
        UPDATE product_node_item t SET t.object_code = lv2_code WHERE object_id = p_object_id;
    ELSIF p_class = 'STREAM_ITEM_COLLECTION' THEN
        UPDATE stream_item_collection t SET t.object_code = lv2_code WHERE object_id = p_object_id;
    END IF;

END UpdateCodeForClass;

END ue_RevenueCodes;