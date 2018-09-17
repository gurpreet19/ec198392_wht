CREATE OR REPLACE TRIGGER "AIU_BUSINESS_FUNCTION" 
AFTER UPDATE ON BUSINESS_FUNCTION
BEGIN
  -- $Revision: 1.2 $
  -- Common
  IF EcDp_Business_function.l_new_bf_list IS NOT NULL THEN

     -- Some BF codes has chaneged , need to update children for this

     FOR i in 1..EcDp_Business_function.l_new_bf_list.count LOOP

        UPDATE BF_COMPONENT SET BF_CODE = EcDp_Business_function.l_new_bf_list(i) WHERE BF_CODE = EcDp_Business_function.l_old_bf_list(i);
        UPDATE CNTX_MENU_ITEM SET BF_CODE =  EcDp_Business_function.l_new_bf_list(i) WHERE BF_CODE = EcDp_Business_function.l_old_bf_list(i);
        UPDATE CNTX_MENU_ITEM_PARAM SET BF_CODE = EcDp_Business_function.l_new_bf_list(i) WHERE BF_CODE = EcDp_Business_function.l_old_bf_list(i);
        UPDATE BF_PROFILE_SETUP SET BF_CODE = EcDp_Business_function.l_new_bf_list(i) WHERE BF_CODE = EcDp_Business_function.l_old_bf_list(i);
    END LOOP;

    EcDp_Business_function.l_new_bf_list.delete;
    EcDp_Business_function.l_old_bf_list.delete;

  END IF;
END;

