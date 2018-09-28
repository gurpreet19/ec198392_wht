/****************************************************************
** SQL    :   CVX_TMPL_INSTL_MISC
**
** Revision:  Version 11.2
**
** Purpose  : Template Upgrade to EC.11.2
**
** Created  : 10-Nov-2018  Srikar Reddy
**
** Modification history:
**
** Version  Date                   Whom      		Change description:
** -------  ------                 -----     		-----------------------------------
** 11.1		10/10/2017 1:24:00 PM  Srikar Reddy 	
** 11.2     31-Jan-2018            Gayatri  		Added Property number for key CUSTOM_TARGET_MANDATORY
** 11.2     31-Jan-2018            varreraj  		Modified the DEFERMENT_VERSION from PD.0006 to PD.0020
*****************************************************************/

set define off
--
--Extracting DELETE statements
--
--Extracting INSERT statements
INSERT INTO CTRL_SYSTEM_ATTRIBUTE (DAYTIME, ATTRIBUTE_TYPE, ATTRIBUTE_TEXT) VALUES (to_date('01.01.1900','dd.mm.yyyy'), 'DT_USER', 'TRANSFER_XXXX');
INSERT INTO CTRL_PROPERTY (PROPERTY_NO, KEY, DAYTIME, VALUE_STRING) VALUES (1, '/com/ec/security/user/passwordexpirydays', to_date('01.01.2000','dd.mm.yyyy'), '90');
INSERT INTO CTRL_PROPERTY (PROPERTY_NO, KEY, DAYTIME, VALUE_STRING) VALUES (2, '/com/ec/pf/mainframe/applicationLabel', to_date('01.01.2000','dd.mm.yyyy'), (SELECT DESCRIPTION FROM CTRL_DB_VERSION));

INSERT INTO CTRL_PROPERTY (PROPERTY_NO,KEY, ROLE_ID, VALUE_STRING) VALUES (3,'CUSTOM_TARGET_MANDATORY', 'SYST.ADM', 'FCTY_CLASS_2');

INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('AX', 'Aaland Islands', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('AF', 'Afghanistan', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('AL', 'Albania', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('DZ', 'Algeria', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('AS', 'American Samoa', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('AD', 'andorra', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('AO', 'Angola', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('AI', 'Anguilla', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('AQ', 'Antarctica', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('AG', 'Antigua and Barbuda', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('AR', 'Argentina', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('AM', 'Armenia', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('AW', 'Aruba', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('AU', 'Australia', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('AT', 'Austria', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('AZ', 'Azerbaijan', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('BS', 'Bahamas', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('BH', 'Bahrain', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('BD', 'Bangladesh', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('BB', 'Barbados', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('BY', 'Belarus', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('BE', 'Belgium', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('BZ', 'Belize', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('BJ', 'Benin', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('BM', 'Bermuda', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('BT', 'Bhutan', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('BO', 'Bolivia', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('BA', 'Bosnia and Herzegowina', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('BW', 'Botswana', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('BV', 'Bouvet Island', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('BR', 'Brazil', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('IO', 'British Indian Ocean Territory', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('BN', 'Brunei Darussalam', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('BG', 'Bulgaria', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('BF', 'Burkina Faso', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('BI', 'Burundi', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('KH', 'Cambodia', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('CM', 'Cameroon', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('CA', 'Canada', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('CV', 'Cape Verde', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('KY', 'Cayman Islands', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('CF', 'Central African Republic', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('TD', 'Chad', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('CL', 'Chile', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('CN', 'China', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('CX', 'Christmas Island', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('CC', 'Cocos (Keeling) Islands', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('CO', 'Colombia', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('KM', 'Comoros', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('CD', 'Congo, Democratic Republic Of (Was Zaire)', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('CG', 'Congo, Republic Of', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('CK', 'Cook Islands', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('CR', 'Costa Rica', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('CI', 'Cote D''Ivoire', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('HR', 'Croatia (Local Name Hrvatska)', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('CU', 'Cuba', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('CY', 'Cyprus', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('CZ', 'Czech Republic', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('DK', 'Denmark', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('DJ', 'Djibouti', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('DM', 'Dominica', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('DO', 'Dominican Republic', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('EC', 'Ecuador', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('EG', 'Egypt', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('SV', 'El Salvador', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('GQ', 'Equatorial Guinea', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('ER', 'Eritrea', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('EE', 'Estonia', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('ET', 'Ethiopia', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('FK', 'Falkland Islands (Malvinas)', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('FO', 'Faroe Islands', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('FJ', 'Fiji', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('FI', 'Finland', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('FR', 'France', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('GF', 'French Guiana', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('PF', 'French Polynesia', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('TF', 'French Southern Territories', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('GA', 'Gabon', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('GM', 'Gambia', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('GE', 'Georgia', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('DE', 'Germany', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('GH', 'Ghana', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('GI', 'Gibraltar', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('GR', 'Greece', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('GL', 'Greenland', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('GD', 'Grenada', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('GP', 'Guadeloupe', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('GU', 'Guam', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('GT', 'Guatemala', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('GN', 'Guinea', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('GW', 'Guinea-Bissau', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('GY', 'Guyana', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('HT', 'Haiti', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('HM', 'Heard and Mc Donald Islands', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('HN', 'Honduras', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('HK', 'Hong Kong', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('HU', 'Hungary', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('IS', 'Iceland', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('IN', 'India', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('ID', 'Indonesia', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('IR', 'Iran (Islamic Republic Of)', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('IQ', 'Iraq', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('IE', 'Ireland', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('IL', 'Israel', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('IT', 'Italy', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('JM', 'Jamaica', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('JP', 'Japan', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('JO', 'Jordan', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('KZ', 'Kazakhstan', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('KE', 'Kenya', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('KI', 'Kiribati', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('KP', 'Korea, Democratic People''s Republic Of', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('KR', 'Korea, Republic Of', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('KW', 'Kuwait', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('KG', 'Kyrgyzstan', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('LA', 'Lao People''s Democratic Republic', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('LV', 'Latvia', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('LB', 'Lebanon', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('LS', 'Lesotho', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('LR', 'Liberia', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('LY', 'Libyan Arab Jamahiriya', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('LI', 'Liechtenstein', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('LT', 'Lithuania', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('LU', 'Luxembourg', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('MO', 'Macau', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('MK', 'Macedonia, The Former Yugoslav Republic Of', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('MG', 'Madagascar', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('MW', 'Malawi', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('MY', 'Malaysia', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('MV', 'Maldives', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('ML', 'Mali', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('MT', 'Malta', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('MH', 'Marshall Islands', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('MQ', 'Martinique', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('MR', 'Mauritania', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('MU', 'Mauritius', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('YT', 'Mayotte', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('MX', 'Mexico', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('FM', 'Micronesia, Federated States Of', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('MD', 'Moldova, Republic Of', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('MC', 'Monaco', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('MN', 'Mongolia', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('MS', 'Montserrat', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('MA', 'Morocco', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('MZ', 'Mozambique', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('MM', 'Myanmar', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('NA', 'Namibia', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('NR', 'Nauru', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('NP', 'Nepal', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('NL', 'Netherlands', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('AN', 'Netherlands Antilles', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('NC', 'New Caledonia', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('NZ', 'New Zealand', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('NI', 'Nicaragua', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('NE', 'Niger', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('NG', 'Nigeria', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('NU', 'Niue', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('NF', 'Norfolk Island', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('MP', 'Northern Mariana Islands', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('NO', 'Norway', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('OM', 'Oman', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('PK', 'Pakistan', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('PW', 'Palau', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('PS', 'Palestinian Territory, Occupied', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('PA', 'Panama', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('PG', 'Papua New Guinea', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('PY', 'Paraguay', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('PE', 'Peru', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('PH', 'Philippines', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('PN', 'Pitcairn', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('PL', 'Poland', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('PT', 'Portugal', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('PR', 'Puerto Rico', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('QA', 'Qatar', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('RE', 'Reunion', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('RO', 'Romania', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('RU', 'Russian Federation', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('RW', 'Rwanda', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('SH', 'Saint Helena', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('KN', 'Saint Kitts and Nevis', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('LC', 'Saint Lucia', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('PM', 'Saint Pierre and Miquelon', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('VC', 'Saint Vincent and The Grenadines', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('WS', 'Samoa', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('SM', 'San Marino', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('ST', 'Sao Tome and Principe', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('SA', 'Saudi Arabia', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('SN', 'Senegal', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('CS', 'Serbia and Montenegro', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('SC', 'Seychelles', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('SL', 'Sierra Leone', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('SG', 'Singapore', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('SK', 'Slovakia', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('SI', 'Slovenia', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('SB', 'Solomon Islands', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('SO', 'Somalia', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('ZA', 'South Africa', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('GS', 'South Georgia and The South Sandwich Islands', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('ES', 'Spain', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('LK', 'Sri Lanka', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('SD', 'Sudan', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('SR', 'Suriname', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('SJ', 'Svalbard and Jan Mayen Islands', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('SZ', 'Swaziland', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('SE', 'Sweden', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('CH', 'Switzerland', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('SY', 'Syrian Arab Republic', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('TW', 'Taiwan', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('TJ', 'Tajikistan', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('TZ', 'Tanzania, United Republic Of', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('TH', 'Thailand', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('TL', 'Timor-Leste', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('TG', 'Togo', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('TK', 'Tokelau', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('TO', 'Tonga', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('TT', 'Trinidad and Tobago', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('TN', 'Tunisia', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('TR', 'Turkey', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('TM', 'Turkmenistan', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('TC', 'Turks and Caicos Islands', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('TV', 'Tuvalu', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('UG', 'Uganda', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('UA', 'Ukraine', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('AE', 'United Arab Emirates', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('GB', 'United Kingdom', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('US', 'United States', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('UM', 'United States Minor Outlying Islands', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('UY', 'Uruguay', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('UZ', 'Uzbekistan', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('VU', 'Vanuatu', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('VA', 'Vatican City State (Holy See)', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('VE', 'Venezuela', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('VN', 'Viet Nam', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('VG', 'Virgin Islands (British)', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('VI', 'Virgin Islands (U.S.)', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('WF', 'Wallis and Futuna Islands', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('EH', 'Western Sahara', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('YE', 'Yemen', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('ZM', 'Zambia', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_COUNTRY (CODE, NAME, OBJECT_START_DATE, DAYTIME) VALUES ('ZW', 'Zimbabwe', to_date('01.01.1900','dd.mm.yyyy'), to_date('01.01.1900','dd.mm.yyyy'));
INSERT INTO OV_PRODUCT (CODE, NAME, OBJECT_START_DATE, SORT_ORDER) VALUES ('OIL', 'Oil', to_date('01.01.1968','dd.mm.yyyy'), 1);
INSERT INTO OV_PRODUCT (CODE, NAME, OBJECT_START_DATE, SORT_ORDER) VALUES ('PROPANE', 'Propane', to_date('01.01.1968','dd.mm.yyyy'), 5);
INSERT INTO OV_PRODUCT (CODE, NAME, OBJECT_START_DATE, SORT_ORDER) VALUES ('BUTANE', 'Butane', to_date('01.01.1968','dd.mm.yyyy'), 6);
INSERT INTO OV_PRODUCT (CODE, NAME, OBJECT_START_DATE, SORT_ORDER) VALUES ('SULFUR', 'Sulfur', to_date('01.01.1968','dd.mm.yyyy'), 8);
INSERT INTO OV_PRODUCT (CODE, NAME, OBJECT_START_DATE, SORT_ORDER) VALUES ('WATER', 'Water', to_date('01.01.1968','dd.mm.yyyy'), 7);
INSERT INTO OV_PRODUCT (CODE, NAME, OBJECT_START_DATE, SORT_ORDER, DESCRIPTION) VALUES ('COND', 'Condensate', to_date('01.01.1968','dd.mm.yyyy'), 2, 'Condensate');
INSERT INTO OV_PRODUCT (CODE, NAME, OBJECT_START_DATE, SORT_ORDER, DESCRIPTION) VALUES ('OTHER', 'Other', to_date('01.01.1968','dd.mm.yyyy'), 9, 'Other products not defined');
INSERT INTO OV_PRODUCT (CODE, NAME, OBJECT_START_DATE, SORT_ORDER, DESCRIPTION) VALUES ('NGL', 'NGL', to_date('01.01.1968','dd.mm.yyyy'), 4, 'Natural Gas Liquids');
INSERT INTO OV_PRODUCT (CODE, NAME, OBJECT_START_DATE, SORT_ORDER, DESCRIPTION) VALUES ('GAS', 'Gas', to_date('01.01.1968','dd.mm.yyyy'), 3, 'Natural Gas');
INSERT INTO OV_PRODUCT (CODE, NAME, OBJECT_START_DATE, SORT_ORDER) VALUES ('LNG', 'LNG', to_date('01.01.1968','dd.mm.yyyy'), 10);
INSERT INTO TV_LANGUAGE_SOURCE (SOURCE_ID, SOURCE) VALUES (100010, 'ORA-20901');
INSERT INTO TV_LANGUAGE_SOURCE (SOURCE_ID, SOURCE) VALUES (100011, 'ORA-20902');
INSERT INTO TV_LANGUAGE_SOURCE (SOURCE_ID, SOURCE) VALUES (100012, 'ORA-20903');
INSERT INTO TV_LANGUAGE_SOURCE (SOURCE_ID, SOURCE) VALUES (100013, 'ORA-20904');
INSERT INTO TV_LANGUAGE_TARGET (LANGUAGE_ID, SOURCE_ID, TARGET) VALUES (1, 100010, 'Password must be minimum of 8 characters');
INSERT INTO TV_LANGUAGE_TARGET (LANGUAGE_ID, SOURCE_ID, TARGET) VALUES (1, 100011, 'The password can only be changed once per day');
INSERT INTO TV_LANGUAGE_TARGET (LANGUAGE_ID, SOURCE_ID, TARGET) VALUES (1, 100012, 'The password matches one of the 5 prior passwords');
INSERT INTO TV_LANGUAGE_TARGET (LANGUAGE_ID, SOURCE_ID, TARGET) VALUES (1, 100013, 'The password must contain 3 of 4 (Upper, lower, number, special characters)');
--
--Extracting UPDATE statements
UPDATE CTRL_SYSTEM_ATTRIBUTE SET (ATTRIBUTE_TEXT) = (select 'PD.0020' from dual) WHERE DAYTIME = to_date('01.01.1900','dd.mm.yyyy') AND ATTRIBUTE_TYPE = 'DEFERMENT_VERSION';
UPDATE CTRL_SYSTEM_ATTRIBUTE SET (ATTRIBUTE_TEXT) = (select 'BUSINESS_PLAN' from dual) WHERE DAYTIME = to_date('01.01.1900','dd.mm.yyyy') AND ATTRIBUTE_TYPE = 'PROD_FCST_TYPE';
UPDATE CTRL_SYSTEM_ATTRIBUTE SET (ATTRIBUTE_TEXT) = (select 'OFU' from dual) WHERE DAYTIME = to_date('01.01.1900','dd.mm.yyyy') AND ATTRIBUTE_TYPE = 'UOM';
UPDATE CTRL_SYSTEM_ATTRIBUTE SET (ATTRIBUTE_VALUE) = (select 0 from dual) WHERE DAYTIME = to_date('01.01.1900','dd.mm.yyyy') AND ATTRIBUTE_TYPE = 'UTC2LOCALDEFAULT';
UPDATE CTRL_SYSTEM_ATTRIBUTE SET (ATTRIBUTE_TEXT) = (select '''ECKERNEL_XXXX'',''ENERGYX_XXXX''' from dual) WHERE DAYTIME = to_date('01.01.1900','dd.mm.yyyy') AND ATTRIBUTE_TYPE = 'DT_OVERWRITE';
--
--
set define on