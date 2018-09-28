CREATE OR REPLACE PACKAGE Z_PASSWORDVALIDATION IS

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

 -- Public function and procedure declarations
 FUNCTION is_valid (username varchar2, old_pwd VARCHAR2, new_pwd VARCHAR2) RETURN INTEGER;
 --PRAGMA RESTRICT_REFERENCES (is_valid, WNDS);

END z_PasswordValidation; 
/

