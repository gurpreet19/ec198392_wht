CREATE OR REPLACE PACKAGE EcDp_Document_Portfolio IS
  /****************************************************************
  ** Package        :  EcDp_Document_Portfolio, header part
  **
  ** $Revision: 1.2 $
  **
  ** Purpose        :  Provide special functions on Document Portfolio.
  **
  ** Documentation  :  www.energy-components.com
  **
  ** Created  : 26.09.2009 Stian Skj�tad
  **
  ** Modification history:
  **
  ** Version  Date        Whom        Change description:
  ** -------  ----------  ----        --------------------------------------
  *************************************************************************/

FUNCTION GetLastDocument(p_doc_key    VARCHAR2,
                         p_booked_ind VARCHAR2 DEFAULT 'Y')

 RETURN VARCHAR2;

FUNCTION GetLastDocTransaction(p_doc_key         VARCHAR2,
                               p_transaction_key VARCHAR2,
                               p_booked_ind      VARCHAR2 DEFAULT 'Y')
  RETURN VARCHAR2;

END EcDp_Document_Portfolio;