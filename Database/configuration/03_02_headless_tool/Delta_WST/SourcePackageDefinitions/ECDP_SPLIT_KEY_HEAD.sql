CREATE OR REPLACE PACKAGE EcDp_Split_Key IS
/****************************************************************
** Package        :  EcDp_Split_Key, header part
**
** $Revision: 1.23 $
**
** Purpose        :  Provide special functions on Split_key. Use EcDp_Objects for basis functions
**
** Documentation  :  www.energy-components.com
**
** Created  : 01.07.2002  Henning Stokke
**
** Modification history:
**
** Version  Date        Whom  Change description:
** -------  ------      ----- --------------------------------------
**  SEE PACKAGE BODY FOR DETAILS
*****************************************************************/

FUNCTION GetSplitShareDay(
   p_object_id VARCHAR2,
   p_target_id VARCHAR2,
   p_daytime   DATE
) RETURN NUMBER;

FUNCTION GetSplitShareMth(
   p_object_id VARCHAR2,
   p_target_id VARCHAR2,
   p_daytime   DATE,
   p_source_split_uom_code VARCHAR2 DEFAULT NULL, -- must set this when requesting a split for a SOURCE_SPLIT key
   p_role_name VARCHAR2 DEFAULT 'SPLIT_KEY'
)  RETURN NUMBER;

FUNCTION GetTotShareMth(
   p_object_id VARCHAR2, -- the split key
   p_daytime   DATE,
   p_role_name VARCHAR2 DEFAULT 'SPLIT_KEY'
) RETURN NUMBER;

FUNCTION GetSplitValueMth(
   p_object_id VARCHAR2,
   p_target_id VARCHAR2,
   p_daytime   DATE,
   p_role_name VARCHAR2 DEFAULT 'SPLIT_KEY',
   p_attribute_type VARCHAR2 DEFAULT 'SPLIT_VALUE_MTH'
) RETURN NUMBER;

PROCEDURE InsSplit(
   p_object_id VARCHAR2,
   p_target_id VARCHAR2,
   p_share_name VARCHAR2,
   p_value_name VARCHAR2,
   p_daytime   DATE,
   p_end_date  DATE DEFAULT NULL,
   p_role_name VARCHAR2 DEFAULT 'SPLIT_KEY',
   p_user      VARCHAR2 DEFAULT NULL
);

PROCEDURE DelSplit(
   p_object_id VARCHAR2,
   p_target_id VARCHAR2,
   p_share_name VARCHAR2,
   p_value_name VARCHAR2,
   p_daytime   DATE,
   p_role_name VARCHAR2 DEFAULT 'SPLIT_KEY',
   p_user      VARCHAR2 DEFAULT NULL,
   p_reset_shares VARCHAR2 DEFAULT 'TRUE',
   p_validate_on_presave   VARCHAR2 DEFAULT 'FALSE'

);

PROCEDURE InsNewSourceSplit(
   p_object_id VARCHAR2,
   p_target_id VARCHAR2,
   p_target_source_id VARCHAR2,
   p_daytime   DATE,
   p_user      VARCHAR2,
   p_role_name VARCHAR2 DEFAULT 'SPLIT_KEY'
);


FUNCTION InsNewSplitKey(
   p_object_id VARCHAR2,
   p_object_code VARCHAR2,
   p_start_date   DATE,
   p_end_date  DATE,
   p_user      VARCHAR2,
   p_object_name VARCHAR2 DEFAULT NULL,
   p_split_type varchar2
) RETURN VARCHAR2;

FUNCTION InsNewSplitKeyCopy(
   p_object_id VARCHAR2,
   p_object_code VARCHAR2,
   p_start_date   DATE,
   p_end_date    DATE DEFAULT NULL,
   p_user      VARCHAR2,
   p_copy_first_version_only BOOLEAN DEFAULT FALSE
) RETURN VARCHAR2;

PROCEDURE CopySplitKeyMembers(
   p_old_object_id VARCHAR2,
   p_new_object_id VARCHAR2,
   p_start_date   DATE,
   p_user      VARCHAR2,
   p_source_date DATE DEFAULT NULL
);

PROCEDURE InsNewSplitKeyVersion(
   p_object_id VARCHAR2,
   p_start_date   DATE,
   p_end_date  DATE,
   p_user      VARCHAR2,
   p_use_same_child_split_key BOOLEAN DEFAULT FALSE
);

PROCEDURE DelSourceSplit(
   p_object_id VARCHAR2,
   p_target_id VARCHAR2,
   p_target_source_id VARCHAR2,
   p_daytime   DATE,
   p_role_name VARCHAR2 DEFAULT 'SPLIT_KEY'
);

PROCEDURE UpdateShare(
   p_rel_to_obj_id VARCHAR2,
   p_share_name VARCHAR2,
   p_value_name VARCHAR2,
   p_daytime DATE,
   p_user    VARCHAR2 DEFAULT NULL
);

PROCEDURE DelSplitShare(
     p_object_id VARCHAR2,
     p_share_name VARCHAR2,
     P_daytime DATE,
     p_user    VARCHAR2 DEFAULT NULL
);

FUNCTION checkSplitUoms(
   p_object_id VARCHAR2,
   p_type VARCHAR2, -- MTH or DAY
   p_daytime   DATE
)
RETURN NUMBER;

FUNCTION setObjCode(
   p_object_id VARCHAR2 -- the split key
)
RETURN VARCHAR2;














/**
 * "OLD" company_split_key
 */















PROCEDURE InsNewCustVendRevision(
   p_contract_obj_id VARCHAR2,
   p_vendor_sk_to_obj_id VARCHAR2,
   p_customer_sk_to_obj_id VARCHAR2,
   p_rel_attr_daytime DATE,
   p_user VARCHAR2
);

PROCEDURE InsNewVendor(
   p_contract_obj_id VARCHAR2,
   p_vendor_sk_to_obj_id VARCHAR2,
   p_vendor_object_id VARCHAR2,
   p_bank_account_obj_id VARCHAR2,
   p_rel_attr_daytime DATE,
   p_rel_attr_end_date DATE,
   p_user VARCHAR2
);

PROCEDURE DelVendor(
   p_contract_obj_id VARCHAR2,
   p_vendor_sk_to_obj_id VARCHAR2,
   p_vendor_object_id VARCHAR2,
   p_bank_account_obj_id VARCHAR2,
   p_rel_attr_daytime DATE,
   p_user             VARCHAR2
);

PROCEDURE InsNewCustomer(
   p_contract_obj_id VARCHAR2,
   p_customer_sk_to_obj_id VARCHAR2,
   p_customer_object_id VARCHAR2,
   p_bank_account_obj_id VARCHAR2,
   p_rel_attr_daytime DATE,
   p_rel_attr_end_date DATE,
   p_user VARCHAR2
);

PROCEDURE DelCustomer(
   p_contract_obj_id VARCHAR2,
   p_customer_sk_to_obj_id VARCHAR2,
   p_customer_object_id VARCHAR2,
   p_bank_account_obj_id VARCHAR2,
   p_rel_attr_daytime DATE,
   p_user VARCHAR2 DEFAULT NULL
);

PROCEDURE DelCustVendSplitShare(
   p_rel_from_obj_id VARCHAR2,
   p_rel_attr_daytime DATE,
   p_user VARCHAR2 DEFAULT NULL
);

PROCEDURE UpdateCustVendShareMth(
   p_rel_to_obj_id VARCHAR2,
   p_rel_attr_daytime DATE,
   p_user VARCHAR2 DEFAULT NULL
);

PROCEDURE InsNewChildSplitKey (
    p_parent_split_key_id VARCHAR2,
    p_parent_split_member_id VARCHAR2,
    p_child_split_type VARCHAR2, -- ex: COMPANY, FIELD, STREAM_ITEM
    p_child_split_key_method VARCHAR2, -- ex: PERCENTAGE, SOURCE_SPLIT
    p_daytime DATE
);

PROCEDURE ValidateSpSetupSplitKey (
    p_split_key_id VARCHAR2,
    p_daytime DATE
);

PROCEDURE DelNewerSplitKeyVersions(p_split_key_id VARCHAR2, p_latest_version_to_keep DATE);

PROCEDURE InsNewSplitKeyVersionWithChild(p_split_key_id VARCHAR2,
    p_new_version_daytime DATE, p_source_version_daytime DATE DEFAULT NULL, p_new_version_enddate DATE, p_user VARCHAR2);

FUNCTION InsNewSplitKeyItem(
   p_object_code VARCHAR2,
   p_object_name VARCHAR2 DEFAULT NULL,
   p_start_date   DATE,
   p_end_date  DATE,
   p_user      VARCHAR2
) RETURN VARCHAR2;
------------------------+-----------------------------------+------------------------------------+---------------------------
------------------------+-----------------------------------+------------------------------------+---------------------------

PROCEDURE CopySplitKeySetupForNewVersion(
   p_object_id VARCHAR2,
   p_start_date   DATE,
   p_user      VARCHAR2
  );

END EcDp_Split_Key;