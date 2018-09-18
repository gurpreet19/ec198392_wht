CREATE OR REPLACE PACKAGE EcDp_Opportunity IS
  /****************************************************************
  ** Package        :  EcDp_Opportunity; head part
  **
  ** $Revision: 1.8 $
  **
  ** Purpose        :  Handles Opportunity operations
  **
  ** Documentation  :  www.energy-components.com
  **
  ** Created        :  28.09.2016 thote sandeep
  **
  ** Modification history:
  **
  ** Date        Whom      Change description:
  ** ----------  -----     -------------------------------------------
  ** 28.09.2016  thotesan  ECPD-36215: Initial Version.
  ** 25.10.2016  sharawan  ECPD-39295: Modify updateOpportunity to add changes to FORECAST_ID
  **************************************************************************************************/

  PROCEDURE instantiateOpportunityGenTerm(p_opportunity_no     number,
                                         p_opportunity_name   varchar2,
                                         p_daytime            date,
                                         p_end_date           date,
                                         p_company_id         varchar2,
                                         p_contract_id        varchar2,
                                         p_term_code          varchar2,
                                         p_opportunity_status varchar2,
                                         p_period             varchar2);

  PROCEDURE deleteOpportunity(p_opportunity_no NUMBER);

  PROCEDURE updateGenTerms(p_opportunity_no     NUMBER,
							 p_opportunity_name   VARCHAR2,
							 p_daytime            DATE,
							 p_end_date           DATE,
							 p_company_id         VARCHAR2,
							 p_contract_id        VARCHAR2,
							 p_term_code          VARCHAR2,
							 p_opportunity_status VARCHAR2,
							 p_period             VARCHAR2);

  PROCEDURE updateOpportunity(p_opportunity_no     NUMBER,
                               p_opportunity_name   VARCHAR2,
                               p_daytime            DATE,
                               p_end_date           DATE,
                               p_company_id         VARCHAR2,
                               p_contract_id        VARCHAR2,
                               p_forecast_id        VARCHAR2,
                               p_term_code          VARCHAR2,
                               p_opportunity_status VARCHAR2,
                               p_period             VARCHAR2);

END EcDp_Opportunity;