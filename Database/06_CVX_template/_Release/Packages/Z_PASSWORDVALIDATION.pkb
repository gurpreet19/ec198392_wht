CREATE OR REPLACE PACKAGE BODY Z_PASSWORDVALIDATION IS
 /****************************************************************
 ** Package : z_PasswordValidation
 **
 ** $Revision : 1.0 $
 ** Notes: EC executes Password Validation package before z-passwordvalidation. The password validation package has the covers the following conditions:
 ** 1.New password must not be null.
 ** 2.New password must match the retyped new password.
 ** 3.New password must not match the old password.
 ** 4.New password must not match the user name.
 ** 5.New password must not be less than 6 characters.
 ** 6.New password must contain alphanumeric character - numbers and symbols for passwords do not work, symbols and letters do work, numbers and letters do work
 ** Unfortunately, we do not currently have access to the java code and the above conditions are executed as is.
 ** Purpose : Customize for <customer>
 ** Stronger password checking for <customer ,project>
 ** The rules are;
 ** 1.	Minimum 8 Characters
 ** 2.	Should be 3 of the following
 ** 	a. Numbers
 ** 	b. UPPERCASE
 ** 	c. Lowercase
 ** 	d. Special characters
 ** 3.	Password History - New password should not be one of the last five. 
 ** 4.	Password expiration – maximum of 90 days
 ** 5.	Password Reset -You are only allowed to change your password once every day unless reset by the user admin.
 ** 	a. New password should not be NULL
 ** 	b. New password should not match the username
 ** 	c. New password should not match the old password
 **
 ** Modification history:
 **
 ** Date Whom Change description:
 ** ---------- ----- --------------------------------------
 ** DD.MM.YYYY ... Initial version
 ** 10.11.2009 SVZZ #2 Previously, the password needed to have all three - numbers, letters and symbols. This has been changed as above.
 ** 10.11.2009 SVZZ #3 Repeat Characters are not a Chevron requirement and are thus commented out.
 ** Dec 2010 BERK Cleaned up logic - Updated logic so the password needs 3 or 4 character types (numbers, letters, and symbols)
 ** Dec 2010 BERK Improved error messages They now use EC Text Translation based on the ORA error that is returned
 ** Jun 2011 CAIL Updated comments to body to add clear password rules.  Copied said comments to spec
 *****************************************************************/

 -- Private variable declarations
 digit_array VARCHAR2(20) := '0123456789';
 char_array VARCHAR2(52) := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
 lower_array VARCHAR2(52) := 'abcdefghijklmnopqrstuvwxyz';
 upper_array VARCHAR2(52) := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
 punct_array VARCHAR2(25) := '!@#$%^&*()-=_+';
 pwd_length INTEGER := 0;
 digit_arr_lgth INTEGER := LENGTH(digit_array);
 char_arr_lgth INTEGER := LENGTH(char_array);
 lower_arr_lgth INTEGER := LENGTH(lower_array);
 upper_arr_lgth INTEGER := LENGTH(upper_array);
 punct_arr_lgth INTEGER := LENGTH(punct_array);
 password VARCHAR2(100);

 -- SubProgram forward declaration
 FUNCTION is_char_mix RETURN BOOLEAN;
 --FUNCTION has_no_repeats RETURN BOOLEAN;
 -- FUNCTION has_upper_and_lower RETURN BOOLEAN;
 FUNCTION is_alphabet (input CHAR) RETURN BOOLEAN;
 FUNCTION is_lower (input CHAR) RETURN BOOLEAN;
 FUNCTION is_upper (input CHAR) RETURN BOOLEAN;
 FUNCTION is_numeric (input CHAR) RETURN BOOLEAN;
 FUNCTION is_punct (input CHAR) RETURN BOOLEAN;
 FUNCTION is_used_5pwd(p_username VARCHAR2, p_new_pwd VARCHAR2) RETURN BOOLEAN;
 FUNCTION not_changed_today(p_username VARCHAR2) RETURN BOOLEAN;

 -- Function and procedure implementations
 FUNCTION is_valid(username varchar2, old_pwd VARCHAR2, new_pwd VARCHAR2) RETURN INTEGER IS
 ln_grant BOOLEAN;
 ErrorRulesViolated EXCEPTION;
 -- lv_warn_msg VARCHAR2(1024);
 BEGIN

 password := new_pwd;
 pwd_length := LENGTH(new_pwd);
 
 ln_grant := (pwd_length >= 8) AND
 is_char_mix AND
 NOT (is_used_5pwd(username, new_pwd)) AND 
 not_changed_today(username);
 -- The actual error messages are stored in the Language Translation tables as ORA-20901 for the example below.
 -- The text in Raise_application_error only displays if there is nothing in the translation tables. 
 IF pwd_length < 8 THEN
 Raise_Application_Error(-20901,'Length message');
 END IF; 
 
 IF ln_grant = TRUE THEN
 RETURN 0;
 ELSE
 RAISE ErrorRulesViolated;
 END IF;
 EXCEPTION
 WHEN ErrorRulesViolated THEN
 Raise_Application_Error(-20000,'Error in password validation');
 WHEN OTHERS THEN
 Raise_Application_Error(-20001, SQLERRM);
 END is_valid;

 FUNCTION is_used_5pwd (p_username VARCHAR2, p_new_pwd VARCHAR2) RETURN BOOLEAN IS
 CURSOR cUser (lp_username VARCHAR2) IS
 SELECT password_login
 FROM ( SELECT password_login
 FROM t_basis_user_jn
 WHERE user_id = lp_username
 GROUP BY password_login
 ORDER BY MAX ( jn_datetime ) DESC )
 WHERE rownum < 6;
 ErrorRulesViolated EXCEPTION;
 lv_warn_msg VARCHAR2(128);
 ls_checksum_string VARCHAR2(32);
 lb_exist BOOLEAN := FALSE;
 BEGIN
 lv_warn_msg := 'Should not have the same last 5 consecutive old passwords.' || chr(10);
 ls_checksum_string := lower(rawtohex(dbms_obfuscation_toolkit.md5(input => utl_raw.cast_to_raw(p_new_pwd))));
 FOR rec IN cUser(p_username) LOOP
 IF ls_checksum_string = rec.password_login THEN
 RAISE ErrorRulesViolated;
 END IF;
 END LOOP;
 RETURN lb_exist;
 EXCEPTION
 WHEN ErrorRulesViolated THEN
 Raise_Application_Error(-20903,lv_warn_msg);
 WHEN OTHERS THEN
 Raise_Application_Error(-20001, SQLERRM);
 END is_used_5pwd;

 -- check for mix of alphanumeric characters and special characters - 3 of the conditions must be followed: !@#$%^&*()-=_+
 FUNCTION is_char_mix RETURN BOOLEAN IS
 lb_has_digit NUMBER := 0;
 lb_has_lower NUMBER := 0;
 lb_has_sign NUMBER := 0;
 lb_has_upper NUMBER := 0;
 lb_exist BOOLEAN := FALSE;

 BEGIN
 
 FOR i IN 1 .. pwd_length LOOP
 IF is_numeric ( SUBSTR ( password, i, 1 ) ) THEN
 lb_has_digit := 1;
 ELSIF is_lower ( SUBSTR ( password, i, 1 ) ) THEN
 lb_has_lower := 1;
 ELSIF is_punct ( SUBSTR ( password, i, 1 ) ) THEN
 lb_has_sign := 1;
 ELSIF is_upper ( SUBSTR ( password, i, 1 ) ) THEN
 lb_has_upper := 1;
 END IF;
 END LOOP;
 -- Check to see if 3 or more are true
 IF (lb_has_digit + lb_has_lower + lb_has_sign + lb_has_upper) >= 3 THEN
 lb_exist := TRUE; 
 END IF;
 
 IF lb_exist = FALSE THEN
 Raise_Application_Error(-20904,'Mixed Character message');
 END IF; 
 
 RETURN lb_exist; -- True if three of the conditions are present
 END is_char_mix;

 -- Password should not contain repeated consecutive characters, e.g. "password"
 -- Allowed repeats are; "pasSword" or "paswords"

/*
 FUNCTION has_no_repeats RETURN BOOLEAN IS
 lb_has_no_repeats BOOLEAN := TRUE;
 BEGIN
 -- get each character and compare with next
 FOR i IN 1 .. pwd_length - 1 LOOP
 IF SUBSTR ( password, i, 1 ) = SUBSTR ( password, i + 1, 1 ) THEN
 lb_has_no_repeats := FALSE;
 EXIT; -- Repeat found, exit loop...
 END IF;
 END LOOP;
 RETURN lb_has_no_repeats;
 END has_no_repeats;
*/
 -- at least one uppercase and one lowercase letter exist.
/* FUNCTION has_upper_and_lower RETURN BOOLEAN IS
 lc_char CHAR(1);
 lb_has_upper BOOLEAN := FALSE;
 lb_has_lower BOOLEAN := FALSE;

 BEGIN
 FOR i IN 1 .. pwd_length LOOP
 lc_char := SUBSTR ( password, i, 1 );
 IF is_alphabet ( lc_char ) THEN
 IF lc_char = UPPER ( lc_char ) THEN
 lb_has_upper := TRUE;
 ELSIF lc_char = LOWER ( lc_char ) THEN
 lb_has_lower := TRUE;
 END IF;
 END IF;
 IF lb_has_upper AND lb_has_lower THEN
 EXIT;
 END IF;
 END LOOP;
 RETURN lb_has_upper AND lb_has_lower;
 END has_upper_and_lower;
*/

 -- check whether the character is an alphabet
 FUNCTION is_alphabet (input CHAR) RETURN BOOLEAN IS
 BEGIN
 FOR i IN 1 .. char_arr_lgth LOOP
 IF (input = SUBSTR(char_array, i, 1)) THEN
 RETURN(TRUE);
 END IF;
 END LOOP;
 RETURN(FALSE);
 END is_alphabet;
 
 FUNCTION is_lower (input CHAR) RETURN BOOLEAN IS
 BEGIN
 FOR i IN 1 .. lower_arr_lgth LOOP
 IF (input = SUBSTR(lower_array, i, 1)) THEN
 RETURN(TRUE);
 END IF;
 END LOOP;
 RETURN(FALSE);
 END is_lower;
 
-- check whether the character is an alphabet
 FUNCTION is_upper (input CHAR) RETURN BOOLEAN IS
 BEGIN
 FOR i IN 1 .. upper_arr_lgth LOOP
 IF (input = SUBSTR(upper_array, i, 1)) THEN
 RETURN(TRUE);
 END IF;
 END LOOP;
 RETURN(FALSE);
 END is_upper;

 -- check whether the character is numeric
 FUNCTION is_numeric (input CHAR) RETURN BOOLEAN IS
 BEGIN
 FOR i IN 1 .. digit_arr_lgth LOOP
 IF (input = SUBSTR(digit_array, i, 1)) THEN
 RETURN(TRUE);
 END IF;
 END LOOP;
 RETURN(FALSE);
 END is_numeric;

 -- check whether the character is a punctuation
 FUNCTION is_punct (input CHAR) RETURN BOOLEAN IS
 BEGIN
 FOR i IN 1 .. punct_arr_lgth LOOP
 IF (input = SUBSTR(punct_array, i, 1)) THEN
 RETURN(TRUE);
 END IF;
 END LOOP;
 RETURN(FALSE);
 END is_punct;
 
-- ensure the user has not changed to password already today
 FUNCTION not_changed_today (p_username VARCHAR2) RETURN BOOLEAN IS
 
 ErrorRulesViolated EXCEPTION;
 lv_warn_msg VARCHAR2(128);
 lb_exist BOOLEAN := TRUE;
 
-- Determine last user to update record 
 
 CURSOR cUser_id (lp_username VARCHAR2) IS
 SELECT * FROM (SELECT *
 FROM t_basis_user_jn
 WHERE user_id = lp_username
 AND JN_DATETIME > trunc(sysdate,'DD')
 ORDER BY JN_DATETIME DESC)
 WHERE rownum < 2;

 BEGIN
 
 lv_warn_msg := 'You can only change the password once per day.' || chr(10);
 -- The following logic is tricky. ENERGYX updates T_BASIS_USER when there is a failed log-in attempt.
 -- To get around this we need to check the journal table
 
 
 FOR rec IN cUser_id(p_username) LOOP
 IF (rec.jn_oracle_user = p_username 
 OR substr(rec.jn_oracle_user, 1, INSTR(rec.jn_oracle_user, '@', 1)-1 ) = p_username) THEN
 RAISE ErrorRulesViolated;
 END IF;
 END LOOP;
 RETURN lb_exist;
 EXCEPTION
 WHEN ErrorRulesViolated THEN
 Raise_Application_Error(-20902,lv_warn_msg);
 WHEN OTHERS THEN
 Raise_Application_Error(-20001, SQLERRM);
 END not_changed_today;

END z_PasswordValidation; 
/

