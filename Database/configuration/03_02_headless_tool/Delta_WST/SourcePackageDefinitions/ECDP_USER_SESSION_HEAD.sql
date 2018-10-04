CREATE OR REPLACE PACKAGE EcDp_user_session IS
/****************************************************************
** Package        :  EcDp_user_session
**
** $Revision: 1.2 $
**
** Purpose        :  Can holds session user name ++
**
** Created  : 19.08.2003  Arild Vervik
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
**          26.04.07 HUS   Move p_user_session from HEAD to BODY to make it private.
*****************************************************************/

type user_session is  RECORD(
     parameter_name       varchar2(30)
    ,parameter_value      varchar2(200)
    );


TYPE t_user_session IS TABLE OF user_session;

PROCEDURE SetUserSessionParameter(
   p_parameter_name  VARCHAR2
  ,p_parameter_value VARCHAR2
);

FUNCTION getUserSessionParameter(
   p_parameter_name  VARCHAR2
)
RETURN VARCHAR2;



END;