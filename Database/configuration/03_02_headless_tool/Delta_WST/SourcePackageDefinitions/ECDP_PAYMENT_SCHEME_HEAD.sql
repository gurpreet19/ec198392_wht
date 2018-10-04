CREATE OR REPLACE PACKAGE EcDp_Payment_Scheme IS
/****************************************************************
** Package        :  EcDp_Payment_Scheme, header part
**
** $Revision: 1.4 $
**
** Purpose        :  Provide functionality to handle validation and population of Payment Schemes
**
** Documentation  :  www.energy-components.com
**
** Created  : 21.06.2007  Stian Skj?tad
**
** Modification history:
**
** Version  Date        Whom  Change description:
** -------  ------      ----- --------------------------------------
********************************************************************/

PROCEDURE AddYear(p_object_id VARCHAR2,
                  p_daytime   DATE,
                  p_year      NUMBER,
                  p_user      VARCHAR2);

PROCEDURE DelObj(p_object_id VARCHAR2, p_end_date DATE);


FUNCTION GetDaysLateTotal(p_object_id    VARCHAR2,
                          p_document_key VARCHAR2,
                          p_customer_id  VARCHAR2) RETURN NUMBER;

PROCEDURE WritePayTrackItems(p_object_id           VARCHAR2,
                             p_document_key        VARCHAR2,
                             p_payment_scheme_id   VARCHAR2,
                             p_document_type       VARCHAR2,
                             p_valid1_user_id      VARCHAR2,
                             p_owner_company_id    VARCHAR2,
                             p_customer_id         VARCHAR2,
                             p_vendor_id           VARCHAR2,
                             p_booking_currency_id VARCHAR2,
                             p_doc_booking_total   NUMBER,
                             p_contract_reference  VARCHAR2,
                             p_daytime             DATE);

FUNCTION GetBookedTotalMinusFixedV(p_object_id    VARCHAR2,
                                   p_booked_total NUMBER,
                                   p_prod_mth     DATE) RETURN NUMBER;

FUNCTION GetDaysOverdue(p_date DATE) RETURN NUMBER;

END EcDp_Payment_Scheme;