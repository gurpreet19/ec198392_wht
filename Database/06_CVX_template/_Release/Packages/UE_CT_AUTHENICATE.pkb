CREATE OR REPLACE PACKAGE BODY UE_CT_AUTHENICATE IS

  /****************************************************************
  ** Package        :  UE_CT_AUTHENICATE, header part
  **
  ** $Revision      : 1.0 $
  **
  ** Purpose        :  Use EC security to authenicate a request from 
  **                   a third party source
  **
  ** Documentation  :  
  **
  ** Created  : 18.Dec.2007  Mark Berkstresser
  **ue
  ** Modification history:
  **
  ** Version  Date        Whom  Change description:
  ** -------  ------      ----- --------------------------------------
  ** 1.0      18.DEC.2007  MWB    Initial Version
  *****************************************************************/

  ------------------------------------------------------------------
  -- Procedure   : UserValidate
  -- Description : Validate that the requesting user has permission
  --               to access the information requested
  ------------------------------------------------------------------
  FUNCTION RequestValid(p_requestor_cai VARCHAR2,
                        p_data_class    VARCHAR2,
                        p_activity      VARCHAR2) 
               RETURN NUMBER
 
   IS
    v_return_code NUMBER;
 v_verify_string VARCHAR2(40);
 v_access_level NUMBER;
 v_activity  VARCHAR(20);
 
BEGIN

v_activity := UPPER(p_activity);
v_return_code := 100;

--  Return codes and meaning
--  0 - Ok to proceed
--   1-  Not a valid EC ID or ID is not active
--  10 - SELECT is not allowed
--  20 - UPDATE is not allowed
--  30 - INSERT is not allowed
--  40 - DELETE is not allowed
--  99 - Invalid activity passed in
--  100 - Function error

--  Check to see is activity is in valid list
IF v_activity not in ('SELECT', 'UPDATE', 'INSERT', 'DELETE') THEN
   v_return_code := 99;
   RETURN v_return_code;
   END IF;

--  Check to see if a valid user ID and ID is active
--  We are not checking to see if the password is expired
  v_verify_string := ec_t_basis_user.active(lower(p_requestor_cai));
  
  IF v_verify_string <> 'Y' or v_verify_string is null THEN
     v_return_code := 1;
  RETURN v_return_code;
  END IF;
   
-- Determine if user has permission to access or update data being requrested
--  This requires a link through the TV_BUSINESS_FUNCTION and BF_COMPONENTS view and table.
  
select max(level_id) into v_access_level
   from tv_t_basis_access 
      where role_id in (select role_id from tv_t_basis_userrole  
      where user_id = LOWER(p_requestor_cai))
             and object_id in (select object_id from tv_t_basis_object 
         where object_name in (select URL from tv_business_function
         where bf_code in (select bf_code from bf_component where class_name = UPPER(p_data_class))));

--  If NULL the data class passed in is not linked through TV_business_function   
IF v_access_level IS NULL THEN
  v_return_code := 90;
  RETURN v_return_code;
  END IF;
  
--  We use the standard EC access level codes
--  A new code (5) has been added for situations where the user has authority to SELECT from a class
--  but does not have access to the BF


IF v_activity = 'SELECT' THEN
  IF v_access_level >= 5 THEN
  v_return_code := 0;
  RETURN v_return_code;
  ELSE
  v_return_code := 10;
  RETURN v_return_code;
  END IF;
  END IF;

IF v_activity = 'UPDATE' THEN
  IF v_access_level >= 20 THEN
  v_return_code := 0;
  RETURN v_return_code;
  ELSE
  v_return_code := 20;
  RETURN v_return_code;
  END IF;
  END IF;
  
IF v_activity = 'INSERT' THEN
  IF v_access_level >= 30 THEN
  v_return_code := 0;
  RETURN v_return_code;
  ELSE
  v_return_code := 30;
  RETURN v_return_code;
  END IF;
  END IF;
      
IF v_activity = 'DELETE' THEN
  IF v_access_level >= 40 THEN
  v_return_code := 0;
  RETURN v_return_code;
  ELSE
  v_return_code := 40;
  RETURN v_return_code;
  END IF;
  END IF;
 
  
RETURN v_return_code;
         
  END RequestValid;
         
END UE_CT_AUTHENICATE;
/

