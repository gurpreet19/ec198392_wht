CREATE OR REPLACE PACKAGE EcDp_Financial_Item IS
  /****************************************************************
  ** Package        :  EcDp_Financial_Item, header part
  **
  ** $Revision: 1.3 $
  **
  ** Purpose        :  Provide functionality for EcDp_Financial_Item
  **
  ** Documentation  :  http://energyextra.tietoenator.com
  **
  ** Created  : 04.06.2010  Anju Alex
  **
  ** Modification history:
  **
  ** Version  Date        Whom  Change description:
  ** -------  ------      ----- --------------------------------------
  ********************************************************************/

  PROCEDURE checkDatasetRules(p_fin_item_id VARCHAR2,
                              p_dataset     VARCHAR2,
                              p_end_date    DATE,
                              p_daytime     DATE);

  PROCEDURE checkDatasetOverlapping(p_fin_item_id VARCHAR2,
                                    p_dataset     VARCHAR2,
                                    p_end_date    DATE,
                                    p_daytime     DATE);

  PROCEDURE copyFITemplate(p_template_code     VARCHAR2,
                           p_new_template_code VARCHAR2,
                           p_new_template_name VARCHAR2,
                           p_valid_from        DATE,
                           p_valid_to          DATE DEFAULT NULL,
                           p_contract_area_id  VARCHAR2,
                           p_user              VARCHAR2 DEFAULT NULL);

  FUNCTION CopyTemplateWithoutValue(p_template_code VARCHAR2,
                                    p_from_date     DATE,
                                    p_time_span     VARCHAR2) RETURN VARCHAR2;

  FUNCTION CopyUseMonthValue(p_template_code VARCHAR2,
                             p_copy_date     DATE,
                             p_from_date     DATE,
                             p_time_span     VARCHAR2) RETURN VARCHAR2;

  /*FUNCTION CopyValueSelectedItems(P_month DATE, P_from_date DATE)
    RETURN VARCHAR2;*/

  PROCEDURE copyFIDefinition(p_code             VARCHAR2,
                             p_object_id        VARCHAR2,
                             p_new_code         VARCHAR2,
                             p_new_name         VARCHAR2,
                             p_valid_from       DATE,
                             p_valid_to         DATE DEFAULT NULL,
                             p_user             VARCHAR2 DEFAULT NULL,
                             p_contract_area_id VARCHAR2 DEFAULT NULL);

 /* PROCEDURE copyFIItem(p_item_name          VARCHAR2,
                       p_financial_item_key VARCHAR2,
                       P_DAYTIME            DATE,
                       p_new_template_code  VARCHAR2,
                       p_new_template_name  VARCHAR2,
                       p_user               VARCHAR2 DEFAULT NULL);*/

/*  PROCEDURE updateFITemplate(p_financial_item_key VARCHAR2,
                             P_DAYTIME            DATE,
                             p_template_code      VARCHAR2,
                             p_user               VARCHAR2 DEFAULT NULL);*/

  FUNCTION getFinancialItemTemplateName(p_template_code VARCHAR2,
                                        p_daytime       DATE)
    RETURN FINANCIAL_ITEM_TEMPLATE.NAME%TYPE;

  FUNCTION getUnitName(p_unit VARCHAR2, p_daytime DATE) RETURN VARCHAR2;

  FUNCTION ExtractDelimitedAltcode(p_code      IN VARCHAR2,
                                   p_code_type IN VARCHAR2,
                                   p_delimiter VARCHAR2,
                                   p_value     NUMBER) RETURN VARCHAR;

  FUNCTION GetLastGeneratedTemplate(p_user_id VARCHAR2) RETURN VARCHAR2;

  FUNCTION GetValueByPriority(value_calculated     NUMBER,
                              value_interfaced     NUMBER,
                              value_override       NUMBER,
                              P_Fin_Item_ID        VARCHAR2,
                              P_Daytime            DATE)
                              RETURN NUMBER ;

  PROCEDURE UpdateValuePriority(P_Fin_Item_ID        VARCHAR2,
                                 P_Daytime            DATE);

  PROCEDURE UpdateFormatMask(P_Fin_Item_ID        VARCHAR2,
                             P_Daytime            DATE);

  FUNCTION monthValue(p_time_span VARCHAR2,
                      p_nav_date    DATE) RETURN varchar2;

  FUNCTION getDatasetCodeText(p_dataset VARCHAR2) RETURN VARCHAR2;

  FUNCTION getDatasetValueHide(p_daytime          DATE,
                               p_timespan         VARCHAR2,
                               p_col              NUMBER,
                               p_dataset_code     VARCHAR2,
                               p_fin_template     VARCHAR2,
                               p_fin_item_name    VARCHAR2,
                               p_cost_object      VARCHAR2,
                               p_cost_object_type VARCHAR2,
                               p_object_link      VARCHAR2,
                               p_object_link_type VARCHAR2,
                               p_company          VARCHAR2,
                               p_comments         VARCHAR2,
                               p_business_unit_id VARCHAR2,
                               p_contract_area_id VARCHAR2,
                               p_status           VARCHAR2
                               ) RETURN VARCHAR2;

  FUNCTION getDatasetFilter(p_col NUMBER,
                            p_dataset_code VARCHAR2) RETURN VARCHAR2;

END EcDp_Financial_Item;