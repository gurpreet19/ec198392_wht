CREATE OR REPLACE PACKAGE ue_Opportunity IS
/****************************************************************
** Package        :  ue_Opportunity; head part
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
** 17.10.2016  sharawan  ECPD-39295: Added procedure includeOpportunity and confirmOpportunity
**                       for Opportunities tab in Forecats Manager
** 14.12.2016  thotesan  ECPD-41647: Added procedure ValidateCargo
**************************************************************************************************/


  PROCEDURE copyOpportunity(p_opportunity_name   VARCHAR2,
                             p_daytime            DATE,
                             p_end_date           DATE,
                             p_company_id         VARCHAR2,
                             p_contract_id        VARCHAR2,
                             p_term_code          VARCHAR2,
                             p_opportunity_status VARCHAR2,
                             p_period             VARCHAR2);

  PROCEDURE includeOpportunity(p_opportunity_no NUMBER,p_forecast_id VARCHAR2);

  PROCEDURE confirmOpportunity(p_opportunity_no NUMBER);

  PROCEDURE ValidateCargo(p_forecast_id VARCHAR2,p_cargo_no NUMBER,p_start_date DATE,p_end_date DATE);
END ue_Opportunity;