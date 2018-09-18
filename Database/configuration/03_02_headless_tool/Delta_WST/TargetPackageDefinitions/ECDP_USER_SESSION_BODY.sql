CREATE OR REPLACE PACKAGE BODY EcDp_user_session IS
/****************************************************************
** Package        :  EcDp_user_session
**
** $Revision: 1.3 $
**
** Purpose        :  Can holds session user name ++
**
** Created  : 19.08.2003  Arild Vervik
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
**          26.04.07 HUS   Set and get parameter 'USERNAME' forwarded to EcDp_Context.
**			   Move p_user_session from HEAD to BODY to make it private.
*****************************************************************/

p_user_session t_user_session;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- PROCEDURE       : SetUserSessionParameter
-- Description    : Creates a session PL/SQL table containing session parameters that the oracle user
--                  can set and refer to. These parameters will only be visible to the current session
--
--
-- Preconditions  : none
--
--
--
-- Postcondition  : p_user_session will be populated with given name
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE SetUserSessionParameter(
   p_parameter_name  VARCHAR2
  ,p_parameter_value VARCHAR2
)
--</EC-DOC>
IS

  lb_found BOOLEAN := FALSE;
BEGIN
   IF UPPER(LTRIM(RTRIM(p_parameter_name)))='USERNAME' THEN
      EcDp_Context.setAppUser(p_parameter_value);
   ELSE

     IF p_user_session IS NULL THEN

       p_user_session := t_user_session();

     END IF;


     FOR i IN 1..p_user_session.COUNT LOOP

       IF p_user_session(i).parameter_name  = UPPER(LTRIM(RTRIM(p_parameter_name))) THEN

         lb_found := TRUE;
         p_user_session(i).parameter_value := p_parameter_value;
         EXIT;

       END IF;

     END LOOP;

     IF NOT lb_found THEN

       p_user_session.EXTEND;
       p_user_session(p_user_session.LAST).parameter_name := UPPER(LTRIM(RTRIM(p_parameter_name)));
       p_user_session(p_user_session.LAST).parameter_value := p_parameter_value;


     END IF;

   END IF;

END;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : getUserSessionParameter
-- Description    : get a session parameter from  a session PL/SQL table
--                  If the given parameter is not set in the structure this function will return NULL
--
-- Preconditions  : none
--
--
--
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getUserSessionParameter(
   p_parameter_name  VARCHAR2
)
RETURN VARCHAR2

IS

  lv2_return_value VARCHAR2(200) := NULL;

BEGIN
   IF UPPER(LTRIM(RTRIM(p_parameter_name)))='USERNAME' THEN

      lv2_return_value := EcDp_Context.getAppUser;

   ELSIF p_user_session IS NOT NULL THEN

      FOR i IN 1..p_user_session.COUNT LOOP

        IF p_user_session(i).parameter_name  = UPPER(LTRIM(RTRIM(p_parameter_name))) THEN

           lv2_return_value := p_user_session(i).parameter_value;
           EXIT;

        END IF;

      END LOOP;

   ELSE

      lv2_return_value :=  NULL;

   END IF;

   RETURN  lv2_return_value;


EXCEPTION

  WHEN OTHERS THEN

      RETURN NULL;



END;


END;