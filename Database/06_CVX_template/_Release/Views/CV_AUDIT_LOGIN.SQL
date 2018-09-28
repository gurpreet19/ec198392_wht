/****************************************************************
** SQL    :   CV_AUDIT_LOGIN
**
** Revision:  Version 11.2
**
** Purpose  : Template Upgrade to EC.11.2
**
** Created  : 29-Jan-2018  Nikita Agarwal
**
** Modification history:
**
** Version  Date         Whom      		Change description:
** -------  ------       -----     		-----------------------------------
** 11.2     29-Jan-2018  Nikita  		LOGIN_RESULT column removed by product in 11.2 SP03,hence commented
*****************************************************************/

CREATE OR REPLACE FORCE VIEW CV_AUDIT_LOGIN AS
SELECT X.*, 
Y.LAST_LOGIN_DATE,
Y.DAYS_SINCE_LAST_LOGIN,
NVL(Y.DAYS_SINCE_LAST_LOGIN, X.DAYS_SINCE_USER_CREATED) AS USER_INACTIVE_DAYS
FROM 
(
SELECT 
USER_ID,
GIVEN_NAME AS FIRST_NAME,
SURNAME AS LAST_NAME,
ACTIVE,
CREATED_DATE,
ROUND(SYSDATE - CREATED_DATE) AS DAYS_SINCE_USER_CREATED
FROM T_BASIS_USER
ORDER BY USER_ID
)X,
(
SELECT * FROM 
(
SELECT 
DAYTIME AS LAST_LOGIN_DATE,
DENSE_RANK () OVER (PARTITION BY REMOTE_USER ORDER BY DAYTIME DESC) AS SERIAL_NO,
REMOTE_USER,
--LOGIN_RESULT,
AUTHENTICATED_IND,
ROUND(SYSDATE - DAYTIME) AS DAYS_SINCE_LAST_LOGIN
FROM TV_AUDIT_LOGIN
ORDER BY DAYTIME DESC
)
WHERE SERIAL_NO < 2
AND AUTHENTICATED_IND = 'Y'
)Y
WHERE X.USER_ID = Y.REMOTE_USER (+)
ORDER BY USER_INACTIVE_DAYS ;