CREATE OR REPLACE PACKAGE BODY ecdp_bf_util IS

FUNCTION getBFCodeFromUrl(p_url VARCHAR2)
  RETURN business_function.bf_code%TYPE
IS
 CURSOR c_BF(cp_url VARCHAR2) IS
   SELECT bf_code
     FROM business_function
    WHERE url = cp_url;

  lv2_bf_code business_function.bf_code%TYPE;

BEGIN

  FOR rsBF IN c_BF(p_url) LOOP
    lv2_bf_code := rsBF.bf_code;
  END LOOP;

  RETURN lv2_bf_code;

END getBFCodeFromUrl;

-----------------------------------------------------------------------------------------------------------------------------

PROCEDURE addBusinessFunction(p_bf_code VARCHAR2,
                              p_name VARCHAR2,
                              p_url VARCHAR2)
IS
BEGIN

  INSERT INTO business_function
    (bf_code, NAME, url)
    SELECT p_bf_code, p_name, p_url
      FROM dual
     WHERE NOT EXISTS (SELECT 1
                         FROM business_function
                        WHERE url = p_url);

END addBusinessFunction;

-----------------------------------------------------------------------------------------------------------------------------

PROCEDURE addBFComponent(p_bf_code VARCHAR2,
                         p_comp_code VARCHAR2,
                         p_name VARCHAR2,
                         p_url VARCHAR2,
                         p_class_name VARCHAR2)
IS

  lv2_bf_code business_function.bf_code%TYPE := p_bf_code;

BEGIN

  lv2_bf_code := nvl(p_bf_code, getBFCodeFromUrl(p_url));

  INSERT INTO bf_component
    (bf_code, comp_code, NAME, url, class_name)
    SELECT lv2_bf_code, p_comp_code, p_name, p_url, p_class_name
      FROM dual
     WHERE NOT EXISTS
     (SELECT 1
              FROM bf_component
             WHERE bf_code = lv2_bf_code
               AND nvl(url, 'IS_NULL') = nvl(p_url, 'IS_NULL'));

END addBFComponent;

-----------------------------------------------------------------------------------------------------------------------------

PROCEDURE addBFCompAction(p_bf_code VARCHAR2,
                          p_bf_url VARCHAR2,
                          p_bf_comp_url VARCHAR2,
                          p_bf_comp_action_url VARCHAR2,
                          p_bf_comp_action_name VARCHAR2)
IS
  lv2_bf_code business_function.bf_code%TYPE := p_bf_code;

BEGIN

  lv2_bf_code := nvl(p_bf_code, getBFCodeFromUrl(p_bf_url));

  INSERT INTO bf_component_action
    (bf_component_no, NAME, url)
    SELECT (SELECT bf_component_no
              FROM bf_component
             WHERE bf_code = lv2_bf_code
               AND nvl(url, 'IS_NULL') = nvl(p_bf_comp_url, 'IS_NULL')),
           p_bf_comp_action_name,
           p_bf_comp_action_url
      FROM dual
     WHERE NOT EXISTS
     (SELECT 1
              FROM bf_component_action
             WHERE bf_component_no =
                   (SELECT bf_component_no
                      FROM bf_component
                     WHERE bf_code = lv2_bf_code
                       AND nvl(url, 'IS_NULL') = nvl(p_bf_comp_url, 'IS_NULL'))
               AND url = p_bf_comp_action_url);

END addBFCompAction;

-----------------------------------------------------------------------------------------------------------------------------

PROCEDURE addCtrlClientHelp(p_bf_url VARCHAR2,
                              p_help_type VARCHAR2)
IS

BEGIN

   INSERT INTO ctrl_client_help(ec_client_obj,help_type)
   VALUES(p_bf_url,p_help_type);

END addCtrlClientHelp;

END ecdp_bf_util;