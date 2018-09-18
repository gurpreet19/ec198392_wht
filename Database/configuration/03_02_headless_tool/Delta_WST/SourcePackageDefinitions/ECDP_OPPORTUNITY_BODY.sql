CREATE OR REPLACE PACKAGE BODY EcDp_Opportunity IS
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

  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : instantiateOpportunityGenTerm
  -- Description    : Instantiates opportunity_gen_term
  --
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   : OPPORTUNITY_GEN_TERM
  --
  -- Using functions:
  --
  -- Configuration
  -- required       :
  --
  -- Behaviour      :

  ---------------------------------------------------------------------------------------------------
  PROCEDURE instantiateOpportunityGenTerm(p_opportunity_no     NUMBER,
                                         p_opportunity_name   VARCHAR2,
                                         p_daytime            DATE,
                                         p_end_date           DATE,
                                         p_company_id         VARCHAR2,
                                         p_contract_id        VARCHAR2,
                                         p_term_code          VARCHAR2,
                                         p_opportunity_status VARCHAR2,
                                         p_period             VARCHAR2)
  --</EC-DOC>

   IS

  BEGIN
    INSERT INTO OPPORTUNITY_GEN_TERM
      (OPPORTUNITY_NO,
       OPPORTUNITY_NAME,
       DAYTIME,
       END_DATE,
       COMPANY_ID,
       CONTRACT_ID,
       TERM_CODE,
       OPPORTUNITY_STATUS,
       PERIOD,
       CREATED_BY)
    VALUES
      (p_opportunity_no,
       p_opportunity_name,
       p_daytime,
       p_end_date,
       p_company_id,
       p_contract_id,
       p_term_code,
       p_opportunity_status,
       p_period,
       ecdp_context.getAppUser);

  END instantiateOpportunityGenTerm;

  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : deleteOpportunity
  -- Description    : Deletes respective entry from OPPORTUNITY_GEN_TERM table
  --
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   : OPPORTUNITY_GEN_TERM
  --
  -- Using functions:
  --
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  ---------------------------------------------------------------------------------------------------
  PROCEDURE deleteOpportunity(p_opportunity_no NUMBER)
  --</EC-DOC>

   IS

  BEGIN

    DELETE FROM OPPORTUNITY_GEN_TERM gt
     WHERE gt.OPPORTUNITY_NO = p_opportunity_no;

  END deleteOpportunity;
  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : updateGenTerms
  -- Description    : Update OPPORTUNITY_GEN_TERM table for any changes done in OPPORTUNITY table
  --
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   : OPPORTUNITY_GEN_TERM
  --
  -- Using functions:
  --
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  ---------------------------------------------------------------------------------------------------
  PROCEDURE updateGenTerms(p_opportunity_no     NUMBER,
                             p_opportunity_name   VARCHAR2,
                             p_daytime            DATE,
                             p_end_date           DATE,
                             p_company_id         VARCHAR2,
                             p_contract_id        VARCHAR2,
                             p_term_code          VARCHAR2,
                             p_opportunity_status VARCHAR2,
                             p_period             VARCHAR2) IS

  BEGIN

    UPDATE OPPORTUNITY_GEN_TERM
       SET OPPORTUNITY_NAME   = p_opportunity_name,
           DAYTIME            = p_daytime,
           END_DATE           = p_end_date,
           COMPANY_ID         = p_company_id,
           CONTRACT_ID        = p_contract_id,
           TERM_CODE          = p_term_code,
           OPPORTUNITY_STATUS = p_opportunity_status,
           PERIOD             = p_period
     WHERE OPPORTUNITY_NO = p_opportunity_no;

  END updateGenTerms;

  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : updateOpportunity
  -- Description    : Update OPPORTUNITY table for any changes done in OPPORTUNITY_GEN_TERM table
  --
  -- Preconditions  :
  -- Postconditions :
  --
  -- Using tables   : OPPORTUNITY
  --
  -- Using functions:
  --
  -- Configuration
  -- required       :
  --
  -- Behaviour      :
  ---------------------------------------------------------------------------------------------------
  PROCEDURE updateOpportunity(p_opportunity_no     NUMBER,
                               p_opportunity_name   VARCHAR2,
                               p_daytime            DATE,
                               p_end_date           DATE,
                               p_company_id         VARCHAR2,
                               p_contract_id        VARCHAR2,
                               p_forecast_id        VARCHAR2,
                               p_term_code          VARCHAR2,
                               p_opportunity_status VARCHAR2,
                               p_period             VARCHAR2) IS

  BEGIN

    UPDATE OPPORTUNITY
       SET OPPORTUNITY_NAME   = p_opportunity_name,
           DAYTIME            = p_daytime,
           END_DATE           = p_end_date,
           COMPANY_ID         = p_company_id,
           CONTRACT_ID        = p_contract_id,
           FORECAST_ID        = p_forecast_id,
           TERM_CODE          = p_term_code,
           OPPORTUNITY_STATUS = p_opportunity_status,
           PERIOD             = p_period
     WHERE OPPORTUNITY_NO = p_opportunity_no;

  END updateOpportunity;

END EcDp_Opportunity;