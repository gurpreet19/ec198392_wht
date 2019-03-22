CREATE OR REPLACE PACKAGE Ecdp_Contract_Setup IS
/****************************************************************
** Package        :  Ecdp_Contract_Setup, header part
**
** $Revision: 1.203 $
**
** Purpose        :  Provide special functions on Contract Object. Use EcDp_Objects for basis functions
**
** Documentation  :  www.energy-components.com
**
** Created  : 15.11.2005 Trond-Arne Brattli
**
** Modification history:
**
** Version  Date        Whom           Change description:
** -------  ----------  ---------   ------------------------------------------
**  1.1     15.11.2005   TRA         Initial version
** 1.17     09.02.2006  skjorsti    Handeling new financial-codes TA_INCOME and TA_COST in addition to SALE and PURCHASE in several functions/procedures
** 1.131    22.11.2007  DRo         Merged changes from Baseline 9.2 up to Baseline 9.3.
*****************************************************************/

TYPE t_object_id IS RECORD
  (
  object_id VARCHAR2(32)
  );

TYPE t_sum_group_object_id IS TABLE OF t_object_id;
TYPE t_price_basis_object_id IS TABLE OF t_object_id;

TYPE trec_price_object IS RECORD
  (
  new_object_id VARCHAR2(32),
  old_object_id VARCHAR2(32)
  );

TYPE t_price_object IS TABLE OF trec_price_object;

tab_price_object t_price_object;

TYPE t_bank_details IS RECORD
  (
   bank_account_id VARCHAR2(32),
   bank_account_code VARCHAR2(32),
   bank_info   VARCHAR2(200),
   bank_account_info VARCHAR2(200)
  );

TYPE t_col_line IS RECORD (
    col_1_text VARCHAR2(2000),
    col_2_text VARCHAR2(2000),
    col_3_text VARCHAR2(2000)
    );

TYPE t_TextLineTable IS TABLE OF t_col_line;

FUNCTION GenContractCopy(
   p_object_id VARCHAR2, -- to copy from
   p_code      VARCHAR2,
   p_user      VARCHAR2,
   p_cntr_type VARCHAR2 default NULL, --could be D or T
   p_new_startdate DATE DEFAULT NULL,
   p_new_enddate DATE DEFAULT NULL)

RETURN VARCHAR2; -- new contract object_id

FUNCTION GenDocSetup(
   p_object_id VARCHAR2, -- to copy from
   p_daytime   DATE, -- start date
   p_contract_id VARCHAR2,
   p_code      VARCHAR2,
   p_name      VARCHAR2,
   p_user      VARCHAR2,
   p_cntr_type VARCHAR2 default NULL) --could be D or T

RETURN VARCHAR2; -- new contract doc object_id

FUNCTION GenTranTemplate(
   p_tran_templ_id VARCHAR2, -- to copy from
   p_daytime   DATE, -- start date
   p_contract_id VARCHAR2,
   p_contract_doc_id VARCHAR2,
   p_user      VARCHAR2,
   p_cntr_type VARCHAR2 default NULL) --could be D or T

RETURN VARCHAR2; -- new transaction template object_id

PROCEDURE DelContract(
   p_object_id VARCHAR2,
   p_user      VARCHAR2
   );

PROCEDURE DoDelContract(
   p_object_id VARCHAR2
   );

PROCEDURE DelContractDoc (
    p_object_id VARCHAR2
   ,p_end_date  DATE
   ,p_user      VARCHAR2
   );

PROCEDURE DoDelContractDoc (
    p_object_id        VARCHAR2
   ,p_del_contract_doc VARCHAR2 DEFAULT 'N'
   );

PROCEDURE DelTransactionTemplate(p_object_id VARCHAR2);

PROCEDURE DoDelTransactionTemplate(p_object_id VARCHAR2, p_del_trans_templ VARCHAR2 default 'N');

PROCEDURE ReviseContract(
   p_object_id VARCHAR2,
   p_daytime   DATE,
   p_user      VARCHAR2 DEFAULT NULL
);

PROCEDURE CreDefaultCustomerVendor(
   p_object_id VARCHAR2,
   p_daytime   DATE,
   p_user      VARCHAR2 DEFAULT NULL
);

PROCEDURE ValidateContrCustVend(
   p_object_id VARCHAR2,
   p_daytime   DATE,
   p_user      VARCHAR2 DEFAULT NULL
);

FUNCTION GetPriceElemVal(
   p_object_id VARCHAR2,
   p_price_object_id VARCHAR2,
   p_price_elem_code VARCHAR2,
   p_product_id VARCHAR2,
   p_pricing_currency_id VARCHAR2,
   p_daytime   DATE,
   p_parcel_key VARCHAR2
)
RETURN NUMBER;

FUNCTION GetPriceElemDate(
   p_object_id VARCHAR2,
   p_price_object_id VARCHAR2,
   --p_price_concept_code VARCHAR2,
   p_price_elem_code VARCHAR2,
   p_product_id VARCHAR2,
   p_pricing_currency_id VARCHAR2,
   p_daytime   DATE,
   p_parcel_key VARCHAR2
)
RETURN DATE;

FUNCTION GetPriceConceptVal(
   p_object_id VARCHAR2,
   p_price_object_id VARCHAR2,
   p_price_concept_code VARCHAR2,
   p_product_id VARCHAR2,
   p_pricing_currency_id VARCHAR2,
   p_daytime   DATE,
   p_parcel_key VARCHAR2 DEFAULT NULL
) RETURN NUMBER
;

PROCEDURE InsNewPriceElementSet(
   p_object_id VARCHAR2,
   p_product_id VARCHAR2,
   p_price_concept_id VARCHAR2,
   p_daytime   DATE,
   p_user     VARCHAR2
);

FUNCTION GetCustomerCnt(
   p_object_id VARCHAR2,
   p_daytime   DATE
)
RETURN NUMBER;


FUNCTION GetVendorCnt(
    p_object_id                     VARCHAR2,
    p_daytime                       DATE
)
RETURN NUMBER;


FUNCTION GetCompBankDetails(
    p_object_id                     VARCHAR2,
    p_target_obj_id                 VARCHAR2, -- customer or vendor object id
    p_comp_source_obj               VARCHAR2, -- 'COMPANY' or 'VENDOR' or 'CUSTOMER'
    p_currency_id                   VARCHAR2,
    p_daytime                       DATE,
    p_contract_doc_id               VARCHAR2 DEFAULT NULL
)
RETURN t_bank_details;


FUNCTION GetPayDate(
    p_object_id                     VARCHAR2,
    p_document_id                   VARCHAR2,
    p_pt_base_code                  VARCHAR2,
    p_payment_terms_id              VARCHAR2,
    p_daytime                       DATE  -- invoice_date
)
RETURN DATE;


FUNCTION GetLocalCurrencyCode(
   p_object_id VARCHAR2, -- contract object id
   p_daytime   DATE
   )
RETURN VARCHAR2;

FUNCTION GetTextLineTableFromText(
   p_text VARCHAR2
)
RETURN t_TextLineTable;

FUNCTION GetCompSplitShare(
   p_object_id VARCHAR2,
   p_comp_source_obj VARCHAR2, -- 'CUSTOMER' or 'VENDOR'
   p_target_obj_id VARCHAR2, -- customer or vendor object id
   p_daytime   DATE
)
RETURN NUMBER;

FUNCTION GetDateForPostingAccount(p_transaction_key VARCHAR2, p_daytime DATE)
RETURN DATE;

FUNCTION GetFinAccSearchCriteria(-- Get the Account Search criteria result
   p_object_id VARCHAR2, -- contract id
   p_daytime   DATE,
   p_trans_template_id VARCHAR2,
   p_price_object_id VARCHAR2 default null,
   p_product_id VARCHAR2 default null,
   p_line_item_template_id VARCHAR2 default null,
   p_line_item_type VARCHAR2 default null
)RETURN T_TABLE_ACC_MAP_ASSIS;


PROCEDURE GenFinPostingData( -- set the financial posting data
   p_object_id VARCHAR2,
   p_document_id VARCHAR2,
   p_fin_code VARCHAR2,
   p_status VARCHAR2,
   p_doc_total NUMBER,
   p_company_obj_id VARCHAR2,
   p_daytime   DATE,
   p_user      VARCHAR2
);

PROCEDURE AggregateFinPostingData( -- aggregate financial posting data
   p_object_id VARCHAR2,
   p_document_id VARCHAR2,
   p_document_concept VARCHAR2,
   p_fin_code VARCHAR2,
   p_status VARCHAR2,
   p_doc_total NUMBER,
   p_company_obj_id VARCHAR2,
   p_daytime   DATE,
   p_document_date DATE,
   p_user      VARCHAR2
);

FUNCTION CorrectToFI (
   p_object_id VARCHAR2,
   p_daytime DATE,
   p_document_id VARCHAR2)
RETURN VARCHAR2;

PROCEDURE GenericRounding(
      p_table_name VARCHAR2,
      p_column_name VARCHAR2,
      p_total_val  NUMBER,
      p_where VARCHAR2
);

PROCEDURE SetPriceElementFactorBasis(
   p_object_id             VARCHAR2,
   p_price_elem_id         VARCHAR2,
   p_product_id            VARCHAR2,
   p_price_cons_id         VARCHAR2,
   p_factor_basis          VARCHAR2,
   p_daytime               DATE,
   p_user                  VARCHAR2 DEFAULT NULL
);

FUNCTION getShareBankAccount(
   p_contract_id VARCHAR2,
   p_cust_id     VARCHAR2 DEFAULT NULL,
   p_vend_id     VARCHAR2 DEFAULT NULL
) RETURN VARCHAR2;

FUNCTION getShareBankAccountDesc(
   p_contract_id VARCHAR2,
   p_cust_id     VARCHAR2 DEFAULT NULL,
   p_vend_id     VARCHAR2 DEFAULT NULL
) RETURN VARCHAR2;


FUNCTION InsNewContractCopy(p_object_id  VARCHAR2, -- to copy from
                            p_start_date DATE, -- to copy from
                            p_code       VARCHAR2,
                            p_user       VARCHAR2,
                            p_end_date   DATE) RETURN VARCHAR2;


FUNCTION InsNewContract(p_object_id   VARCHAR2,
                        p_object_code VARCHAR2,
                        p_start_date  DATE,
                        p_end_date    DATE DEFAULT NULL,
                        p_user        VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2;


FUNCTION InsNewDocSetupCopy(p_object_id  VARCHAR2, -- to copy from
                            p_start_date DATE, -- to copy from
                            p_contract_id VARCHAR2,
                            p_code       VARCHAR2,
                            p_user       VARCHAR2,
                            p_end_date   DATE DEFAULT NULL)
  RETURN VARCHAR2;


FUNCTION InsNewDocSetup(p_object_id   VARCHAR2,
                        p_object_code VARCHAR2,
                        p_contract_id VARCHAR2,
                        p_start_date  DATE,
                        p_end_date    DATE DEFAULT NULL,
                        p_user        VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2;

PROCEDURE validateContractCompany(
   p_contract_id VARCHAR2,
   p_daytime     DATE,
   p_party_id    VARCHAR2,
   p_party_role  VARCHAR2
);

PROCEDURE SetIsSDistributedFlag (
            p_code                                  VARCHAR2,
            p_daytime                               DATE,
            p_dist_type                             VARCHAR2,
            p_user                                  VARCHAR2);


FUNCTION GetDocumentsStatus(p_object_id VARCHAR2) RETURN VARCHAR2;

FUNCTION getBaseDate(
   p_object_id VARCHAR2,
   p_document_key VARCHAR2,
   p_daytime DATE,
   p_date_type VARCHAR2 default 'DOC_RECEIVED',
   p_contract_doc_id VARCHAR2 default NULL, --contract doc id, can be Null during updating dates
   p_vendor_id VARCHAR2 default NULL
)
RETURN DATE;

FUNCTION getDocDate(
   p_contract_id VARCHAR2,
   p_document_key VARCHAR2,
   p_daytime DATE,
   p_document_date DATE,
   p_contract_doc_id VARCHAR2 default NULL --contract doc id, can be Null during updating dates
)
RETURN DATE;

FUNCTION getValidDocDaytime(p_contract_id VARCHAR2,
                            p_contract_doc_id VARCHAR2,
                            p_daytime DATE)
RETURN DATE;


FUNCTION getDueDate(
   p_object_id VARCHAR2, --contract id
   p_document_key VARCHAR2, --document key
   p_daytime DATE, -- document date while initializing
   p_date_type VARCHAR2 default 'DOC_RECEIVED',
   p_contract_doc_id VARCHAR2 default NULL, --contract doc id, can be Null during updating dates
   p_vendor_id VARCHAR2 default NULL
)
RETURN DATE;

PROCEDURE updateAllDocumentDates
(
   p_object_id VARCHAR2, --contract id
   p_document_key VARCHAR2, --document key
   p_daytime DATE, -- daytime
   p_document_date DATE, -- document date
   p_user VARCHAR2, --curent login user
   p_level NUMBER default 6 --level to indicates which dates need to be updated
)
;

PROCEDURE updatePriceIndex
(
	p_object_id VARCHAR2,
	p_daytime DATE,
	p_int_type_id VARCHAR2
);

FUNCTION InsDealContractCopy(p_object_id  VARCHAR2, -- to copy from
                            p_start_date DATE, -- to copy from
                            p_code       VARCHAR2,
                            p_user       VARCHAR2,
                            p_end_date   DATE,
                            p_cntr_type  VARCHAR2 DEFAULT 'T')  --contract type, default is Contract Template
RETURN VARCHAR2;

FUNCTION InsDealContract(p_object_id   VARCHAR2,
                        p_object_code VARCHAR2,
                        p_start_date  DATE,
                        p_end_date    DATE DEFAULT NULL,
                        p_user        VARCHAR2 DEFAULT NULL,
                        p_deal_code VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;

FUNCTION GetContractAreaCode(
         p_object_id VARCHAR2)
RETURN VARCHAR2;

PROCEDURE AddContractArea(
          p_contract_code VARCHAR2,
          p_contract_area_code VARCHAR2,
          p_daytime DATE);



PROCEDURE updFinancialCode(p_object_id      VARCHAR2,
                           p_daytime        VARCHAR2,
                           p_financial_code VARCHAR2);


FUNCTION GetNewContractAreaSetupCode
RETURN VARCHAR2;

FUNCTION getObjectCodeNumber (p_object_code VARCHAR2)
RETURN INTEGER;

FUNCTION isCntrPriceElmMoveToVO (p_contract_id VARCHAR2)
RETURN VARCHAR2;

PROCEDURE validateNumberOfShareParties(
   p_contract_id VARCHAR2,
   p_role_name   VARCHAR2
);

PROCEDURE syncContractOwnerPayment(
   p_object_id  VARCHAR2,
   p_party_role   VARCHAR2,
   p_daytime   DATE,
   p_class_name VARCHAR2
);

PROCEDURE syncContractOwnerDocPayment(p_document_key VARCHAR2,
                                      p_company_id   VARCHAR2);


PROCEDURE validateContractArea(p_object_id VARCHAR2, p_daytime DATE);

PROCEDURE populateFactorPrice(p_daytime DATE, p_price_group_id VARCHAR2, p_user VARCHAR2);

    PROCEDURE updateFactorAdjustedPrice(p_object_id          VARCHAR2, --product_price_id
                                        p_price_concept_code VARCHAR2,
                                        p_price_element_code VARCHAR2,
                                        p_daytime            DATE,
                                        p_user               VARCHAR2);

	PROCEDURE insertContractPriceList(p_object_id        VARCHAR2,
    							     p_price_concept_code        VARCHAR2,
							     p_price_element_code        VARCHAR2,
							     p_daytime                   DATE,
								 p_price_category 			VARCHAR2,
							     p_user                      VARCHAR2);

	PROCEDURE updateCalcContractPriceList(
	    p_object_id                 VARCHAR2,
	    p_price_concept_code        VARCHAR2,
	    p_price_element_code        VARCHAR2,
	    p_daytime                   DATE,
		p_price_category 			VARCHAR2,
	    p_user                      VARCHAR2
	);

    PROCEDURE updateFactorAdjustedPriceAll(
        p_object_id          VARCHAR2, --product_price_id
        p_price_concept_code   VARCHAR2,
        p_price_element_code   VARCHAR2,
        p_daytime DATE,
        p_end_date           DATE,
        p_user               VARCHAR2);

    PROCEDURE UpdateDocumentVendor(
              p_contract_id  VARCHAR2
    );

    PROCEDURE UpdateDocumentVendorData(
              p_contract_id  VARCHAR2
    );

    FUNCTION GetDocCompanyNames(
       p_document_key  VARCHAR2,
       p_company_type  VARCHAR2     -- CUSTOMER/VENDOR
    ) RETURN VARCHAR2;


    FUNCTION GetContractCustomerId
    (
        p_contract_object_id    VARCHAR2,
        p_daytime               DATE
    )
    RETURN VARCHAR2;


    FUNCTION GetDocCustomerId(
       p_document_key  VARCHAR2
    ) RETURN VARCHAR2;


    FUNCTION getNumSeq(
        p_number VARCHAR2,
        p_char VARCHAR2)
    RETURN VARCHAR2;


    FUNCTION getNumericFormatString(
        p_left                          VARCHAR2,
        p_decimals                      NUMBER)
    RETURN VARCHAR2;

    ------------------------------------+-------------------------------------------------

    FUNCTION GetContractPartyComposition(
        p_contract_id                   VARCHAR2,
        p_daytime                       DATE)
    RETURN VARCHAR2;

    ------------------------------------+-------------------------------------------------

    FUNCTION GetContractComposition(
        p_contract_id                   VARCHAR2,
        p_trans_tmpl_id                 VARCHAR2,
        p_daytime                       DATE)
    RETURN VARCHAR2;

    ------------------------------------+-------------------------------------------------

    FUNCTION GetVendorComposition(
             p_contract_id VARCHAR2,
             p_daytime DATE)
    RETURN VARCHAR2;


    ------------------------------------+-------------------------------------------------

    PROCEDURE q_TransactionTemplate(
        p_cursor                        OUT SYS_REFCURSOR,
        p_object_id                     VARCHAR2,
        p_daytime                       DATE);

    ------------------------------------+-------------------------------------------------

    FUNCTION ContractHasDocSetupConcept(
        p_Contract_Id                   VARCHAR2,
        p_daytime                       DATE,
        p_doc_concept                   VARCHAR2,
        p_doc_setup_id                  OUT VARCHAR2)
    RETURN BOOLEAN;

    ------------------------------------+-------------------------------------------------

    FUNCTION ContractHasDocSetupConcept(
        p_Contract_Id                   VARCHAR2,
        p_daytime                       DATE,
        p_doc_concept                   VARCHAR2)
    RETURN BOOLEAN;

    ------------------------------------+-------------------------------------------------

    PROCEDURE ValidateNewDocSetup(
        p_Contract_Id                   VARCHAR2,
        p_daytime                       DATE,
        p_doc_concept_code              VARCHAR2);

    ------------------------------------+-------------------------------------------------

    FUNCTION HasSingleReceiver(
        p_document_key                  VARCHAR2)
    RETURN VARCHAR2;

    ------------------------------------+-------------------------------------------------

    FUNCTION IsAllowedContractCustomer(
        p_contract_id                   VARCHAR2,
        p_customer_id                   VARCHAR2,
        p_daytime                       DATE,
        p_d_contract_owner_id           VARCHAR2 DEFAULT NULL,
        p_d_restrict_customer_att       VARCHAR2 DEFAULT NULL)
    RETURN VARCHAR2;
   ---------------------------------------------------------------------------------------
     PROCEDURE IsdateConflicting(p_target_price_object_id   VARCHAR2,
        p_target_price_element_code VARCHAR2,
        p_source_price_object_id VARCHAR2,
        p_source_price_element_code VARCHAR2 ,
        p_daytime DATE,
        p_end_date DATE);
    ------------------------------------+-------------------------------------------------
      FUNCTION IsPriceEditable(
         p_price_object_id		VARCHAR2,
         p_price_element_code VARCHAR2)
      RETURN VARCHAR2;
    --------------------------------------------------------------------------------------
     PROCEDURE IfSrcObjElmCodeSameAsTarget(
        p_target_price_object_id   VARCHAR2,
        p_target_price_element_code VARCHAR2,
        p_source_price_object_id VARCHAR2,
		p_source_price_element_code VARCHAR2 ) ;
	--------------------------------------------------------------------------------------
	  PROCEDURE IsdateOverlappingOnUpd(
		p_target_price_object_id   VARCHAR2,
		p_target_price_element_code VARCHAR2,
		p_source_price_object_id VARCHAR2,
		p_source_price_element_code VARCHAR2 ,
		p_daytime DATE,p_end_date DATE );
    -----------------------------------------------------------------------------------------
	END Ecdp_Contract_Setup;