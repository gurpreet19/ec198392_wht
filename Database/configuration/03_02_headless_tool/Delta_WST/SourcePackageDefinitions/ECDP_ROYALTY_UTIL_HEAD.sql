CREATE OR REPLACE PACKAGE ECDP_ROYALTY_UTIL IS

  /***********************************************************************
  ** Type           :  ECDP_ROYALTY_UTIL, header
  **
  ** Purpose        :  Facilitate Royalty Data Handling
  **
  **
  ** Documentation  :  www.energy-components.com
  **
  ** Created        : 27.03.2013 Kenneth Masamba
  **
  ** Modification history:
  **
  ** Version  Date        Whom       Change description:
  ** -------  ----------  --------   --------------------------------------
  ** 1.0      27.03.2014  kenenth Masamba   Initial version
  ***************************************************************************/


  FUNCTION getProdSortOrder(p_product_group_id VARCHAR2, p_product_id VARCHAR2, p_daytime DATE) RETURN NUMBER;

  PROCEDURE  updateChildShareSeq(p_contract_id VARCHAR2, p_party_role VARCHAR2, p_daytime DATE, p_company_id VARCHAR2);

  PROCEDURE  CreateBurdens(p_do_code VARCHAR2);

END ECDP_ROYALTY_UTIL;