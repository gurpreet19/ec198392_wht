CREATE OR REPLACE PACKAGE BODY Ue_Aggregate_Fin_Posting IS
/****************************************************************
** Package        :  Ue_Aggregate_Fin_Posting, body part
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
************************************************************************************************************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : GetAccntMappingObjID
-- Description    : Determines if any FIN_ACCOUNT_OBJECT match the criterias in the arguments.
--                  See description in ecdp_fin_account_mapping for details.
--                  If any match, the object is returned by this function.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behaviour      :
-------------------------------------------------------------------------------------------------------------------------------------------
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
)

IS

BEGIN

    NULL;

END AggregateFinPostingData;

END Ue_Aggregate_Fin_Posting;