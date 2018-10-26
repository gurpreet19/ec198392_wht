CREATE OR REPLACE PACKAGE ecdp_bf_util IS

  FUNCTION getBFCodeFromUrl(p_url VARCHAR2)
  RETURN business_function.bf_code%TYPE;

  PROCEDURE addBusinessFunction(p_bf_code VARCHAR2,
                                p_name VARCHAR2,
                                p_url VARCHAR2);

  PROCEDURE addBFComponent(p_bf_code VARCHAR2,
                         p_comp_code VARCHAR2,
                         p_name VARCHAR2,
                         p_url VARCHAR2,
                         p_class_name VARCHAR2);


  PROCEDURE addBFCompAction(p_bf_code VARCHAR2,
                            p_bf_url VARCHAR2,
                            p_bf_comp_url VARCHAR2,
                            p_bf_comp_action_url VARCHAR2,
                            p_bf_comp_action_name VARCHAR2);

  PROCEDURE addCtrlClientHelp(p_bf_url VARCHAR2,
                              p_help_type VARCHAR2);
END ecdp_bf_util;