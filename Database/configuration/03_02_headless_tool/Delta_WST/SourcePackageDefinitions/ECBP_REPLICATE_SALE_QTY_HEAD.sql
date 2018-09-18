CREATE OR REPLACE PACKAGE EcBp_Replicate_Sale_Qty IS
/****************************************************************
** Package        :  EcBp_Replicate_Contract_Account
**
** $Revision: 1.3 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created        :  19.04.2006  Jean Ferre
**
** Modification history:
**
** Date        Whom  		Change description:
** ------      ----- 		-----------------------------------------------------------------------------------------------
** 19.04.2006  Jean Ferre  Initial version
** 11.05.2006 	KSN			   Rewrite
** 25.09.2015   ARVID      Rewrite
******************************************************************/
FUNCTION QtyUOMMapping(p_mapping_value VARCHAR2,
                       p_vol_uom VARCHAR2,
                       p_mass_uom VARCHAR2,
                       p_energy_uom VARCHAR2,
                       p_x1_uom VARCHAR2,
                       p_x2_uom VARCHAR2,
                       p_x3_uom VARCHAR2) RETURN VARCHAR2;

FUNCTION QtyValueMapping(p_mapping_value VARCHAR2,
                         p_vol_qty NUMBER DEFAULT NULL,
                         p_mass_qty NUMBER DEFAULT NULL,
                         p_energy_qty NUMBER DEFAULT NULL,
                         p_x1_qty NUMBER DEFAULT NULL,
                         p_x2_qty NUMBER DEFAULT NULL,
                         p_x3_qty NUMBER DEFAULT NULL ) RETURN NUMBER;

PROCEDURE insertSalesQty(
            p_class_name  VARCHAR2,
            p_object_id		VARCHAR2,
						p_account_code		VARCHAR2,
						p_profit_centre_id	VARCHAR2,
						p_company_id	VARCHAR2,
						p_time_span			VARCHAR2,
						p_daytime			DATE,
						p_vol_qty			NUMBER,
						p_mass_qty			NUMBER,
						p_energy_qty		NUMBER,
						p_user				VARCHAR2,
            p_doc_status        VARCHAR2 DEFAULT NULL,
            p_approved    boolean default false
);

PROCEDURE IFAC_TRANSACTION_LEVEL(
            p_class_name  VARCHAR2,
            p_object_id		VARCHAR2,
						p_account_code		VARCHAR2,
						p_time_span			VARCHAR2,
						p_daytime			DATE,
						p_vol_qty			NUMBER,
						p_mass_qty			NUMBER,
						p_energy_qty		NUMBER,
						p_user				VARCHAR2,
            p_doc_status        VARCHAR2 DEFAULT NULL
);

PROCEDURE IFAC_PROFIT_CENTRE_LEVEL(
            p_class_name  VARCHAR2,
            p_object_id		VARCHAR2,
						p_account_code		VARCHAR2,
						p_profit_centre_id	VARCHAR2,
						p_time_span			VARCHAR2,
						p_daytime			DATE,
						p_vol_qty			NUMBER,
						p_mass_qty			NUMBER,
						p_energy_qty		NUMBER,
						p_user				VARCHAR2,
            p_doc_status        VARCHAR2 DEFAULT NULL
);

PROCEDURE insertIFAC_PC_CPY_Qty(
            p_class_name  VARCHAR2,
            p_object_id		VARCHAR2,
						p_account_code		VARCHAR2,
						p_profit_centre_id	VARCHAR2,
            p_vendor_id        VARCHAR2,
            p_party_share      NUMBER,
						p_time_span			VARCHAR2,
						p_daytime			DATE,
						p_vol_qty			NUMBER,
						p_mass_qty			NUMBER,
						p_energy_qty		NUMBER,
						p_user				VARCHAR2,
            p_doc_status        VARCHAR2 DEFAULT NULL
);

PROCEDURE IFAC_COMPANY_LEVEL(
            p_class_name  VARCHAR2,
            p_object_id		VARCHAR2,
						p_account_code		VARCHAR2,
						p_profit_centre_id	VARCHAR2,
            p_company_id        VARCHAR2,
			p_time_span			VARCHAR2,
			p_daytime			DATE,
			p_vol_qty			NUMBER,
			p_mass_qty			NUMBER,
			p_energy_qty		NUMBER,
			p_user				VARCHAR2,
            p_doc_status        VARCHAR2 DEFAULT NULL
);

PROCEDURE ApproveCalc(p_run_no NUMBER);

FUNCTION GetIfacRecordPriceObject(p_contract_id        VARCHAR2,
                                  p_product_id         VARCHAR2,
                                  p_price_concept_code VARCHAR2,
                                  p_quantity_status    VARCHAR2,
                                  p_price_status       VARCHAR2,
                                  p_daytime            DATE,
                                  p_uom_code           VARCHAR2 DEFAULT NULL
)RETURN VARCHAR2;

END EcBp_Replicate_Sale_Qty;