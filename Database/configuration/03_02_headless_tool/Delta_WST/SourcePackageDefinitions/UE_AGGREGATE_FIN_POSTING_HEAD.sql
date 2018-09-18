CREATE OR REPLACE PACKAGE Ue_Aggregate_Fin_Posting IS
/****************************************************************
**
** NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE
** NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE
** Enable this User Exit by setting variable below "isUserExitEnabled" = 'TRUE'
** NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE
** NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE
**
** Package        :  Ue_Aggregate_Fin_Posting, header part
**
** $Revision: 1.3 $
**
** Purpose        :  Provide special functions on Financials Accounts for interfacing with Finance applications
**
** Documentation  :  www.energy-components.com
**
** Created  : 22.11.2007  EnergyComponents Team
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
** 1.1	    22.11.2007 SRA  Initial version
*****************************************************************/
isUserExitEnabled VARCHAR2(32) := 'FALSE';


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

END Ue_Aggregate_Fin_Posting;