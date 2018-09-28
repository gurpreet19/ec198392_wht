
--For business functions:
delete 
from   BF_PROFILE_SETUP
where  bf_code in ( select bf_code
                    from   business_function
                    where  url = '/com.ec.tran.gd.screens/period_factors/TARGET/CONTRACT/CLASS/TRCN_FACTOR'
                  );

delete BF_COMPONENT_ACTION bca
where  exists ( select 'X'
                from   BF_COMPONENT      bc
                ,      BUSINESS_FUNCTION bf
                where  bca.bf_component_no     = bc.bf_component_no 
                and    bc.business_function_no = bf.business_function_no 
                and    bf.url in ( '/com.ec.frmw.co.screens/manage_object_relation/CLASS_NAME/TRANS_PROD_SET_ITEM/FROM_CLASS_NAME/TRANS_PROD_SET/ROLE_ID/TRANS_PROD_SET_ID'
                                 , '/com.ec.frmw.co.screens/manage_object_relation/CLASS_NAME/TRANS_DIM_SET_ITEM/FROM_CLASS_NAME/TRANS_DIM_SET/ROLE_ID/TRANS_DIM_SET_ID'
                                 , '/com.ec.frmw.co.screens/manage_object/CLASS_NAME/TRANS_PROD_SET'
                                 , '/com.ec.frmw.co.screens/manage_object/CLASS_NAME/TRANS_DIM_SET'
                                 )
              );
              
delete BF_COMPONENT bc
where  exists ( select 'X'
                from   BUSINESS_FUNCTION bf
                where  bc.business_function_no = bf.business_function_no 
                and    bf.url in ( '/com.ec.frmw.co.screens/manage_object_relation/CLASS_NAME/TRANS_PROD_SET_ITEM/FROM_CLASS_NAME/TRANS_PROD_SET/ROLE_ID/TRANS_PROD_SET_ID'
                                 , '/com.ec.frmw.co.screens/manage_object_relation/CLASS_NAME/TRANS_DIM_SET_ITEM/FROM_CLASS_NAME/TRANS_DIM_SET/ROLE_ID/TRANS_DIM_SET_ID'
                                 , '/com.ec.frmw.co.screens/manage_object/CLASS_NAME/TRANS_PROD_SET'
                                 , '/com.ec.frmw.co.screens/manage_object/CLASS_NAME/TRANS_DIM_SET'
                                 )
              );
                             
delete BUSINESS_FUNCTION 
where  url in                    ( '/com.ec.frmw.co.screens/manage_object_relation/CLASS_NAME/TRANS_PROD_SET_ITEM/FROM_CLASS_NAME/TRANS_PROD_SET/ROLE_ID/TRANS_PROD_SET_ID'
                                 , '/com.ec.frmw.co.screens/manage_object_relation/CLASS_NAME/TRANS_DIM_SET_ITEM/FROM_CLASS_NAME/TRANS_DIM_SET/ROLE_ID/TRANS_DIM_SET_ID'
                                 , '/com.ec.frmw.co.screens/manage_object/CLASS_NAME/TRANS_PROD_SET'
                                 , '/com.ec.frmw.co.screens/manage_object/CLASS_NAME/TRANS_DIM_SET'
                                 );
