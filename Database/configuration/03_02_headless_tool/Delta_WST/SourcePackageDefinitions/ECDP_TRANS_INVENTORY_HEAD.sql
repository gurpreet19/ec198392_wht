CREATE OR REPLACE PACKAGE Ecdp_Trans_Inventory IS
/****************************************************************
** Package        :  Ecdp_Trans_Inventory, header part
**
** $Revision: 1.2 $
**
** Purpose        :  Provide special functions on Inventory handling. Use EcDp_Objects for basis functions
**
** Documentation  :  www.energy-components.com
**
** Created        : 23.02.2014 Brandon Lewis
**
** Modification history:
**
** Date        Whom rec_trans_inv_gen_log Change description:
** ------      ----- --------------------------------------
*****************************************************************/
TYPE t_trans_inv_gen_log IS RECORD
  (
  log_item_no      revn_log.log_no%type,
  log_type         revn_log.category%type,
  daytime          DATE,
  trans_inv_id     trans_inventory.object_id%type,
  created_by       revn_log.created_by%type
  );

rec_trans_inv_gen_log t_trans_inv_gen_log;

PROCEDURE WriteTransInvGenLog(p_log_level        VARCHAR2,
                              p_log_text         VARCHAR2,
                              p_contract_id      VARCHAR2,
                              p_run_description  VARCHAR2 DEFAULT NULL
                         );
PROCEDURE FinalGenLog(p_final_status VARCHAR2,p_contract_id VARCHAR2);

PROCEDURE CreateFromAllocNetwork(p_object_id VARCHAR2,
                                 p_daytime     DATE
                                 );
PROCEDURE btnSaveInventory(p_contract_id VARCHAR2,
                            p_calc_group_id VARCHAR2,
                            p_object_id   VARCHAR2 DEFAULT NULL,
                           p_daytime     DATE,
                           p_user_id     VARCHAR2);

PROCEDURE btnSaveInventoryTemplate(p_contract_id          VARCHAR2,
                                   p_prod_stream_group_id VARCHAR2,
                                   p_trans_inventory_id   VARCHAR2,
                                   p_user_id              VARCHAR2,
                                   p_template_code        VARCHAR2);

FUNCTION CreateTransInv(p_object_id   VARCHAR2,
                         p_node        VARCHAR2,
                         p_version     DATE,
                         p_log_item_no NUMBER DEFAULT NULL) RETURN VARCHAR2;

PROCEDURE CreateTransInv(p_object_id VARCHAR2,
                         p_node        VARCHAR2,
                         p_version     DATE,
                         p_log_item_no NUMBER DEFAULT NULL);

FUNCTION CreateTransInvLine(p_tran_inventory_id VARCHAR2,
                             p_trans_node_id     VARCHAR2,
                             p_stream_id         VARCHAR2,
                             p_daytime           DATE,
                              p_log_item_no      NUMBER DEFAULT NULL
                             )  RETURN VARCHAR2;

PROCEDURE CreateTransInvLine(p_tran_inventory_id VARCHAR2,
                             p_trans_node_id     VARCHAR2,
                             p_stream_id         VARCHAR2,
                             p_daytime           DATE,
                             p_log_item_no       number DEFAULT NULL
                             );
/*FUNCTION GetRecommendedProdSet(p_product_id         VARCHAR2,
                               p_node_type          VARCHAR2,
                               p_daytime            DATE
                               ) RETURN VARCHAR2;


PROCEDURE createProducts(p_object_id varchar2,
                         p_daytime varchar2,
                         p_end_date varchar2,
                         p_tag varchar2,
                         p_product_id                 VARCHAR2,
                         p_cost_type                  VARCHAR2,
                         p_type varchar2);

FUNCTION GetDimItem(p_set_id         VARCHAR2,
                    p_tag          VARCHAR2,
                    p_daytime            DATE
                    ) RETURN VARCHAR2;
*/
FUNCTION CopyTransInvPosting(p_rec            trans_inv_li_pr_cntracc%ROWTYPE,
                             p_object_id      VARCHAR2,
                             p_prod_Stream_id VARCHAR2,
                             p_line_tag       VARCHAR2,
                             P_product_id     VARCHAR2,
                             p_cost_type      VARCHAR2,
                             p_daytime        DATE,
                             p_user_id        VARCHAR2) RETURN NUMBER;

PROCEDURE  CreateLocalVariableParams(p_object_id VARCHAR2,
                                     p_daytime   DATE,
                                     p_object_start_date DATE,
                                     p_object_end_date   DATE,
                                     p_end_date DATE,
                                     p_calc_context_id VARCHAR2,
                                     p_calc_var_signature VARCHAR2) ;

Procedure createVarDim(p_object_id VARCHAR2,
                       p_daytime   DATE,
                       p_object_start_date DATE,
                       p_object_end_date   DATE,
                       p_end_date DATE,
                       p_calc_context_id VARCHAR2,
                       p_calc_var_signature VARCHAR2);


FUNCTION createProductChild
                          (p_object_id VARCHAR2,
                          p_daytime date,
                          p_end_date date,
                          p_line_tag VARCHAR2,
                          p_quantity_src_attribute VARCHAR2,
                          p_quantity_source_method VARCHAR2,
                           p_product_id                 VARCHAR2,
                           p_cost_type                  VARCHAR2) RETURN varchar2;

PROCEDURE createProductChild
                          (p_object_id VARCHAR2,
                          p_daytime date ,
                          p_end_date date,
                          p_line_tag VARCHAR2,
                          p_quantity_src_attribute VARCHAR2,
                          p_quantity_source_method VARCHAR2,
                           p_product_id                 VARCHAR2,
                           p_cost_type                  VARCHAR2) ;

FUNCTION FindAppropriateVariable( p_product_id                 VARCHAR2,
                                  p_cost_type                  VARCHAR2,p_class_name               VARCHAR2,
                                 p_daytime                  DATE,
                                 p_end_Date                 DATE,
                                 p_quantity_src_attribute   VARCHAR2,
                                 p_line_tag VARCHAR2 default 'XXX',
                                 p_object_id VARCHAR2)
                                     RETURN VARCHAR2;

FUNCTION FindVariableParamType(p_object_id  VARCHAR2,
                               p_daytime    DATE) return VARCHAR2;



PROCEDURE refreshparams(p_object_id VARCHAR2,
                        p_prod_stream_id              VARCHAR2,
                         p_config_variable_id VARCHAR2,
                         p_daytime DATE,
                         p_end_date DATE,
                          p_product_id                 VARCHAR2,
                           p_cost_type                  VARCHAR2,
                         p_line_tag VARCHAR2,
                         p_exec_order varchar2);

FUNCTION FindParamValue (p_variable_id VARCHAR2,
                         p_dimension number,
                         p_object_id VARCHAR2,
                         p_line_tag VARCHAR2,
                         p_Type VARCHAR2,
                         p_daytime DATE
                         ) return varchar2;

FUNCTION GetParameterObject(p_dimension VARCHAR2,
                            p_variable_id VARCHAR2,
                            p_daytime date) RETURN VARCHAR2;


FUNCTION SkipInventory(p_contract_id VARCHAR2,p_object_id VARCHAR2,p_daytime DATE)  RETURN VARCHAR ;
FUNCTION SkipLine(p_contract_id VARCHAR2,p_object_id VARCHAR2,p_daytime DATE,p_line_tag VARCHAR2)  RETURN VARCHAR ;
FUNCTION SkipProduct(p_contract_id VARCHAR2,p_object_id VARCHAR2,p_daytime DATE,p_product_id VARCHAR2,p_cost_type varchar2,p_line_tag VARCHAR2)  RETURN VARCHAR ;
FUNCTION SkipAllDim(p_contract_id VARCHAR2,p_object_id VARCHAR2,p_daytime DATE,p_product_id VARCHAR2,p_cost_type varchar2,p_line_tag VARCHAR2,p_dimension_id VARCHAR2)     RETURN VARCHAR ;
FUNCTION SkipVariable(p_contract_id VARCHAR2, p_object_id VARCHAR2,p_daytime DATE,p_product_id VARCHAR2,p_cost_type varchar2,p_line_tag VARCHAR2,p_exec_order number,p_config_variable varchar2)  RETURN VARCHAR;

FUNCTION InsNewTransInvCopy(p_network_id VARCHAR2, --Copy to network
                            p_object_id  VARCHAR2, -- to copy from
                            p_start_date DATE, -- to copy from
                            p_code       VARCHAR2,
                            p_user       VARCHAR2,
                            p_end_date   DATE DEFAULT NULL
                            )
  return varchar2;


PROCEDURE btnCopyTransInvLiProdSet(p_trans_inv_id    VARCHAR2,
                                   p_trans_inv_line  VARCHAR2,
                                   p_daytime         DATE,
                                   p_user_id         VARCHAR2) ;


PROCEDURE btnCopyTransInvLiProduct(p_trans_inv_id VARCHAR2,
                                   p_trans_inv_line VARCHAR2,
                                   p_daytime DATE,
                                   p_product_id                 VARCHAR2,
                                   p_cost_type                  VARCHAR2,
                                   p_user_id     VARCHAR2) ;

PROCEDURE btnPasteTransInv(p_network_id  VARCHAR2,
                           p_daytime     DATE,
                           p_user_id     VARCHAR2) ;

PROCEDURE btnPasteTransInvLiProduct( p_to_trans_inv_id VARCHAR2,
                           p_to_line_tag               VARCHAR2,
                           p_daytime                   DATE,
                           p_user_id                   VARCHAR2) ;

PROCEDURE btnPasteTransInvLiProdSet( p_to_trans_inv_id  VARCHAR2,
                                     p_to_line_tag      VARCHAR2,
                                     p_daytime          DATE,
                                     p_user_id          VARCHAR2);

PROCEDURE btnPasteTransInvLiVarSet(p_to_trans_inv_id   VARCHAR2,
                                   p_to_prod_stream_id VARCHAR2,
                                   p_to_line_tag       VARCHAR2,
                                   p_to_product_id     VARCHAR2,
                                   p_to_cost_type      VARCHAR2,
                                   p_daytime           VARCHAR2,
                                   p_user_id           VARCHAR2);

PROCEDURE btnCopyTransInvLiVarSet(p_trans_inv_id       VARCHAR2,
                                  p_trans_inv_line     VARCHAR2,
                                  p_daytime            VARCHAR2,
                                  p_product_id         VARCHAR2,
                                  p_cost_type          VARCHAR2,
                                  p_user_id            VARCHAR2,
                                  p_config_variable_id VARCHAR2 DEFAULT NULL,
                                  p_var_exec_order     VARCHAR2 DEFAULT NULL);

PROCEDURE btnCopyPosting(p_trans_inv_id       VARCHAR2,
                         p_prod_stream_id     VARCHAR2,
                         p_trans_inv_line_tag VARCHAR2,
                         p_product_group_id   VARCHAR2,
                         p_product_id         VARCHAR2,
                         p_cost_type          VARCHAR2,
                         p_daytime            VARCHAR2,
                         p_user_id            VARCHAR2,
                         p_id                 VARCHAR2);



PROCEDURE btnPastePosting(p_object_id      VARCHAR2,
                          p_line_tag       VARCHAR2,
                          p_prod_stream_id VARCHAR2,
                          p_product_id     VARCHAR2,
                          p_cost_type      VARCHAR2,
                          p_daytime        VARCHAR2,
                          p_user_id        VARCHAR2);


PROCEDURE btnCopyTransInv(p_trans_inv_id VARCHAR2,
                          p_user_id VARCHAR2) ;

PROCEDURE btnCopyTransInvLine(p_trans_inv_id   VARCHAR2,
                              p_trans_inv_line VARCHAR2,
                              p_daytime        DATE,
                              p_user           varchar2);

PROCEDURE btnPasteTransInvLine(p_to_trans_inv_id VARCHAR2,
                               p_daytime     VARCHAR2,
                               p_user_id     VARCHAR2) ;

PROCEDURE CopyTransInvLiProd(p_from_trans_inv VARCHAR2,
                             p_from_tag       VARCHAR2,
                             p_to_trans_inv   VARCHAR2,
                             p_to_tag         VARCHAR2,
                             p_product_id     VARCHAR2,
                             p_cost_type      VARCHAR2,
                             p_daytime        DATE,
                             p_new_daytime    DATE,
                             p_user_id        VARCHAR2);

FUNCTION CopyTransInvLiPrVar(p_rec            TRANS_INV_LI_PR_VAR%ROWTYPE,
                             p_object_id      VARCHAR2,
                             p_prod_Stream_id VARCHAR2,
                             p_line_tag       VARCHAR2,
                             p_product_id     VARCHAR2,
                             p_cost_type      VARCHAR2,
                             p_daytime        DATE,
                             p_user_id        VARCHAR2) RETURN NUMBER;

FUNCTION DefaultInventory(p_inventory_id VARCHAR2,
                          p_product_id                 VARCHAR2,
                          p_daytime DATE,
                          p_user_id VARCHAR2,
                          p_contract_id VARCHAR2 DEFAULT NULL)  RETURN VARCHAR2;

FUNCTION DefaultInventory(p_run_no  VARCHAR2 default '-1',
                          p_user_id VARCHAR2)  RETURN VARCHAR2;

FUNCTION DefaultInventoryTemplate(p_contract_id          VARCHAR2,
                                  p_revn_prod_stream_id  VARCHAR2,
                                  p_prod_stream_group_id VARCHAR2,
                                  p_trans_inventory_id   VARCHAR2,
                                  p_user_id              VARCHAR2)  RETURN VARCHAR2;

FUNCTION GetNextInventory(p_group_id VARCHAR2,
                          p_object_id VARCHAR2,
                          p_trans_inv_id VARCHAR2,
                          p_daytime   DATE) return varchar2;

FUNCTION GetPreviousInventory( p_group_id VARCHAR2,
                              p_object_id VARCHAR2,
                              p_trans_inv_id VARCHAR2,
                              p_daytime   DATE) return varchar2;

PROCEDURE CopyLineProdSet(p_from_trans_inv_id  VARCHAR2, -- Tran Inventory to copy
                             p_from_tag        VARCHAR2,      -- Line Tag
                             p_to_trans_inv_id VARCHAR2,
                             p_to_tag          VARCHAR2,
                             p_daytime         DATE,
                             p_new_daytime     DATE,
                             p_user_id         VARCHAR2);


PROCEDURE InsNewTransInvLineCopy(p_from_object_id    VARCHAR2, -- Tran Inventory to copy
                             p_from_tag              VARCHAR2,-- Line Tag
                             p_to_object_id          VARCHAR2,
                             p_to_tag                VARCHAR2,
                             p_daytime               DATE,
                             p_new_daytime           DATE,
                             p_user_id               VARCHAR2);

/*function AllowChangeProdSet(p_daytime date,
                            p_end_date date,
                            p_prodset varchar2,
                            p_object_id varchar2) return boolean;*/

PROCEDURE UpdateTIEndDate(p_object_id VARCHAR2,
                         p_new_daytime DATE,
                         p_new_end_date DATE);

PROCEDURE UpdateTILineEndDate(p_object_id VARCHAR2,
                         p_line_tag     VARCHAR2,
                         p_new_daytime DATE,
                         p_new_end_date DATE) ;

PROCEDURE UpdateTILiVarEndDate(p_object_id VARCHAR2,
                             p_line_tag  VARCHAR2,
                             p_product_id                 VARCHAR2,
                             p_cost_type                  VARCHAR2,
                             p_new_daytime DATE,
                             p_new_end_date DATE);

PROCEDURE UpdateTILineStartDate(p_object_id VARCHAR2,
                         p_line_tag         VARCHAR2,
                         p_new_daytime      DATE,
                         p_old_daytime      DATE) ;

PROCEDURE UpdateTILiVarStartDate(p_object_id VARCHAR2,
                         p_line_tag          VARCHAR2,
                         p_product_id                 VARCHAR2,
                         p_cost_type                  VARCHAR2,
                         p_new_daytime      DATE,
                         p_old_daytime      DATE);

PROCEDURE UpdateTILiVarTag(p_object_id              VARCHAR2,
                           p_line_tag               VARCHAR2,
                           p_new_line_tag           VARCHAR2,
                           p_product_id                 VARCHAR2,
                           p_cost_type                  VARCHAR2,
                           p_daytime                DATE);


PROCEDURE UpdateTILineTag(p_object_id VARCHAR2,
                         p_line_tag         VARCHAR2,
                         p_new_line_tag     VARCHAR2,
                         p_daytime          DATE);

PROCEDURE UpdateTILiProd(p_object_id                      VARCHAR2,
                         p_line_tag                       VARCHAR2,
                         p_daytime                        DATE,
                         p_product_id                 VARCHAR2,
                         p_cost_type                  VARCHAR2,
                          p_new_product_id                 VARCHAR2,
                           p_new_cost_type                  VARCHAR2);

FUNCTION  GetSourceId(p_object_id    VARCHAR2,
                      p_daytime      DATE,
                      p_dimention   NUMBER,
                      p_source_param VARCHAR2) RETURN VARCHAR2;


Function SingleValue(
  p_OBJECT_ID       VARCHAR2,
  p_DAYTIME         DATE,
  p_LAYER_MONTH     DATE,
  p_DIMENSION_TAG   VARCHAR2,
  p_TABLE_NAME      VARCHAR2,
  p_CALC_RUN_NO     VARCHAR2,
  p_column_name     VARCHAR2) RETURN NUMBER;

FUNCTION GetDimName(p_object_id VARCHAR2,
                    p_line_tag VARCHAR2,
                    p_contract_id VARCHAR2,
                    p_daytime date) return varchar2;

FUNCTION DimNameFromTag(p_object_id VARCHAR2,
                        p_contract_id VARCHAR2,
                        p_daytime DATE,
                        p_dim_tag VARCHAR2,
                        p_dim_number NUMBER DEFAULT -1) return varchar2;

/*FUNCTION DimOrder(p_object_id VARCHAR2,
                  p_dimensions VARCHAR2,
                  p_daytime DATE) RETURN NUMBER;*/


-----------------------------------------------------------------------
----+---+--------------------------------+-----------------------------
FUNCTION CreateDimOverride(
    p_object_id                          VARCHAR2,
    p_line_tag                           VARCHAR2,
    p_project_id                         VARCHAR2,
    p_daytime                            VARCHAR2,
    p_end_date                           VARCHAR2) RETURN VARCHAR2;

-----------------------------------------------------------------------
----+---+--------------------------------+-----------------------------
PROCEDURE DeleteDimOverride(
    p_object_id                          VARCHAR2,
    p_line_tag                           VARCHAR2,
    p_project_id                         VARCHAR2,
    p_daytime                            DATE);

-----------------------------------------------------------------------
----+---+--------------------------------+-----------------------------
FUNCTION CopyDimToNewVersion(
    p_object_id                          VARCHAR2,
    p_line_tag                           VARCHAR2,
    p_project_id                         VARCHAR2,
    p_daytime                            VARCHAR2,
    p_new_daytime                        VARCHAR2,
    p_new_end_date                       VARCHAR2) RETURN VARCHAR2;

FUNCTION CheckDimGroupChange(p_object_id VARCHAR2,
                           p_daytime DATE,
                           p_end_date DATE DEFAULT NULL) return VARCHAR2;

FUNCTION CheckDimSetChange(p_object_id VARCHAR2,
                           p_daytime DATE,
                           p_end_date DATE DEFAULT NULL) return VARCHAR2;

FUNCTION CreateTransInvLineOverride(p_trans_inventory_id VARCHAR2,
                                     p_contract_id        VARCHAR2,
                                     p_trans_inv_line     VARCHAR2,
                                     p_daytime            DATE,
                                     p_from_date          DATE,
                                     p_to_date            DATE,
                                     p_user_id            VARCHAR2) RETURN VARCHAR2 ;


FUNCTION getdefaultProRateProduct(p_TYPE VARCHAR2,
         p_PRORATE_LINE VARCHAR2,
         p_PRODUCT_SOURCE_METHOD VARCHAR2,
         p_object_id VARCHAR2,
         p_product_id  VARCHAR2,
         p_counter_product_ind VARCHAR2,

         p_cost_type VARCHAR2 DEFAULT NULL,
         p_sum_value_cost_ind  VARCHAR2 DEFAULT NULL,
         p_master_product varchar2)
  RETURN VARCHAR2;

FUNCTION getdefaultQtyMtd(p_TYPE VARCHAR2,
         p_PRORATE_LINE VARCHAR2,
         p_PRODUCT_SOURCE_METHOD VARCHAR2 ,
         p_object_id VARCHAR2,
         p_product_id  VARCHAR2,
         p_counter_product_ind VARCHAR2,
         p_is_master_IND VARCHAR2,
         p_cost_type VARCHAR2 DEFAULT NULL,
         p_sum_value_cost_ind  VARCHAR2 DEFAULT NULL         ) RETURN VARCHAR2;


FUNCTION getdefaultValMtd(p_TYPE VARCHAR2,
         p_PRORATE_LINE VARCHAR2,
         p_PRODUCT_SOURCE_METHOD VARCHAR2,
         p_object_id VARCHAR2,
         p_product_id  VARCHAR2,
         p_counter_product_ind VARCHAR2,
         p_is_master_IND VARCHAR2,
         p_cost_type VARCHAR2 DEFAULT NULL,
         p_sum_value_cost_ind  VARCHAR2 DEFAULT NULL,
         p_line_type  VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

FUNCTION CreateTransInvProdOverride(p_trans_inventory_id VARCHAR2,
                                     p_contract_id        VARCHAR2,
                                     p_trans_inv_line     VARCHAR2,
                                     p_product_id         VARCHAR2,
                                     p_cost_type       VARCHAR2,
                                     p_daytime            DATE,
                                     p_from_date          DATE,
                                     p_to_date            DATE,
                                     p_user_id            VARCHAR2)  RETURN VARCHAR2;

FUNCTION DimOrder(p_object_id VARCHAR2,
                  p_dimensions VARCHAR2,
                  p_daytime DATE) RETURN NUMBER;

FUNCTION SortOrder(p_sort_order           NUMBER,
                   p_dimension_tag        VARCHAR2,
                   p_layer_month          DATE ,
                   p_prod_stream_id       VARCHAR2,
                   p_daytime              DATE
                   ) RETURN NUMBER;

PROCEDURE IsTransInvSummaryValid(p_trans_inv_id   VARCHAR2,
                                p_prod_stream_id VARCHAR2,
                                p_start_date     DATE,
                                p_end_date       DATE);

PROCEDURE UpdTransInvSummary(p_trans_inv_id       VARCHAR2,
                             p_prod_stream_id     VARCHAR2,
                             p_src_trans_inv_id   VARCHAR2,
                             p_src_prod_stream_id VARCHAR2,
                             p_src_trans_inv_line VARCHAR2,
                             p_start_date         DATE,
                             p_end_date           DATE);

PROCEDURE UpdTransInvProdStream(p_trans_inv_id   VARCHAR2,
                                p_prod_stream_id VARCHAR2,
                                p_start_date     DATE,
                                p_end_date       DATE);

PROCEDURE DeleteCalc(p_calc_run_no NUMBER);

FUNCTION verifyAction(p_calc_run_no VARCHAR2) RETURN VARCHAR2;
FUNCTION unverifyAction(p_calc_run_no VARCHAR2) RETURN VARCHAR2;
FUNCTION Exist_TransInvSummaryItem(p_object_id            VARCHAR2,
                                   p_trans_inventory_id   VARCHAR2,
                                   p_daytime              DATE
                                   ) RETURN VARCHAR2;
FUNCTION Exist_TransInvPosting(p_object_id                VARCHAR2,
                               p_trans_inventory_id       VARCHAR2,
                               p_daytime                  DATE
                               ) RETURN VARCHAR2;
FUNCTION Exist_TransInvLinePosting(p_object_id             VARCHAR2,
                                   p_trans_inventory_id    VARCHAR2,
                                   p_start_date            DATE DEFAULT NULL,
                                   p_tag                   VARCHAR2 DEFAULT NULL,
                                   p_end_date              DATE DEFAULT NULL,
                                   p_product_id            VARCHAR2 DEFAULT NULL,
                                   p_cost_type             VARCHAR2 DEFAULT NULL
                                   ) RETURN VARCHAR2;
FUNCTION Exist_LineOverride(p_line_tag                  VARCHAR2,
                            p_object_id                 VARCHAR2,
                            p_start_date                DATE DEFAULT NULL,
                            p_end_date                  DATE DEFAULT NULL
                            ) RETURN VARCHAR2;
FUNCTION Exist_ProductOverride(p_line_tag                  VARCHAR2,
                               p_object_id                 VARCHAR2,
                               p_product_id                VARCHAR2 DEFAULT NULL,
                               p_cost_type                 VARCHAR2 DEFAULT NULL,
                               p_start_date                DATE DEFAULT NULL,
                               p_end_date                  DATE DEFAULT NULL
                                ) RETURN VARCHAR2 ;
FUNCTION Exist_TransInvLineProdVar(p_object_id                      VARCHAR2,
                                   p_trans_inventory_id             VARCHAR2,
                                   p_start_date                     DATE DEFAULT NULL,
                                   p_tag                            VARCHAR2 DEFAULT NULL,
                                   p_end_date                       DATE DEFAULT NULL,
                                   p_product_id                     VARCHAR2 DEFAULT NULL,
                                   p_cost_type                      VARCHAR2 DEFAULT NULL
                                   ) RETURN VARCHAR2;
FUNCTION Exist_TransInvMessages(p_object_id                    VARCHAR2,
                                p_trans_inventory_id           VARCHAR2,
                                p_daytime                      DATE
                                ) RETURN VARCHAR2;
FUNCTION PreInventoryDeleteTest(p_object_id                    VARCHAR2,
                                p_trans_inventory_id           VARCHAR2,
                                p_daytime                      DATE
                                ) RETURN VARCHAR2;
PROCEDURE CheckAttbSyntax(p_attribute_syntax  VARCHAR2,
                          p_scope             VARCHAR2);
FUNCTION PreDeleteTemplateTest( p_tag                       VARCHAR2,
                                p_object_id                 VARCHAR2,
                                p_daytime                   DATE,
                                p_end_date                  DATE,
                                p_product_id                VARCHAR2,
                                p_cost_type                 VARCHAR2,
                                p_type                      VARCHAR2
                                ) RETURN VARCHAR2;
FUNCTION IsUsingTemplate( p_template_id                      VARCHAR2,
                          p_daytime                          VARCHAR2
                         ) RETURN VARCHAR2 ;

PROCEDURE CreateTransInvProdVarOverride(p_trans_inventory_id VARCHAR2,
                                       p_prod_Stream_id     VARCHAR2,
                                       p_line_tag           VARCHAR2,
                                       p_product_id         VARCHAR2,
                                       p_cost_type          VARCHAR2,
                                       p_daytime            DATE,
                                       p_user_id            VARCHAR2,
                                       p_config_variable_id VARCHAR2,
                                       p_var_exec_order     VARCHAR2,
                                       p_over_ind           VARCHAR2);

PROCEDURE CreateTransInvLiPrVar(p_object_id           VARCHAR2,
                                p_prod_Stream_id      VARCHAR2,
                                p_line_tag            VARCHAR2,
                                p_product_id          VARCHAR2,
                                p_cost_type           VARCHAR2,
                                p_daytime             DATE,
                                p_end_date            DATE,
                                p_config_variable_id  VARCHAR2,
                                p_var_exec_order      VARCHAR2,
                                p_name                VARCHAR2,
                                p_reverse_value_ind   VARCHAR2,
                                p_net_zero_ind        VARCHAR2,
                                p_round_ind           VARCHAR2,
                                p_type                VARCHAR2,
                                p_post_process_ind    VARCHAR2,
                                p_trans_def_dimension VARCHAR2,
                                p_disable_ind         VARCHAR2,
                                p_user_id             VARCHAR2);

PROCEDURE DeleteTransInvProdVarOverride(p_trans_inventory_id VARCHAR2,
                                        p_prod_Stream_id     VARCHAR2,
                                        p_line_tag           VARCHAR2,
                                        p_product_id         VARCHAR2,
                                        p_cost_type          VARCHAR2,
                                        p_daytime            DATE,
                                        p_config_variable_id VARCHAR2,
                                        p_var_exec_order     VARCHAR2,
                                        p_disable_ind        VARCHAR2);

function GetLineLabel(p_trans_inventory_id VARCHAR2,
                                        p_prod_Stream_id     VARCHAR2,
                                        p_line_tag           VARCHAR2,
                                        p_daytime              date,
                                        p_with_number VARCHAR2 default 'N') RETURN VARCHAR2;


FUNCTION Trans_inv_Report(p_level varchar2,
                           p_inventory_id varchar2 default null,
                           p_run_no number,
                           p_template_code varchar2,
                           p_include_country_ind VARCHAR2 DEFAULT 'Y',
                           p_include_delivery_point_ind VARCHAR2 DEFAULT 'Y') RETURN
  T_TABLE_TRANS_INV;


PROCEDURE CopyMsg(p_object_id in out varchar2  ,
                  p_prod_stream_id in out varchar2  ,
                  p_alt_inventory_id in out varchar2,
                  p_alt_prod_stream_id in out varchar2 ,
                  o_object_id  in out varchar2  ,
                  o_prod_stream_id in out varchar2  ,
                  p_daytime varchar2,
                  p_tag varchar2,
                  p_disabled_ind varchar2 default 'N');

PROCEDURE CopyPosting(p_object_id in out VARCHAR2,
                      p_prod_stream_id in out VARCHAR2,
                      p_alt_inventory_id in out VARCHAR2,
                      p_alt_prod_stream_id in out VARCHAR2,
                      o_object_id in out VARCHAR2,
                      o_prod_stream_id in out VARCHAR2,
                      p_daytime in out DATE,
                      n_id in out VARCHAR2,
                      n_ref_id  in out VARCHAR2,
                      p_disabled_ind VARCHAR2 DEFAULT 'N');

PROCEDURE CopyRef(p_alt_key varchar2,
                  o_alt_key in out varchar2,
                  p_REPORT_REF_CONN_ID varchar2,
                  o_REPORT_REF_CONN_ID in out varchar2,
                  p_id in out number,
                  o_id in out number,
                  p_ref_id in out number,
                  p_disabled_ind VARCHAR2 DEFAULT 'N');

END Ecdp_Trans_Inventory;