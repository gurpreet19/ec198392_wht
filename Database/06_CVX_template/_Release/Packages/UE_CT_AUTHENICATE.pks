CREATE OR REPLACE PACKAGE UE_CT_AUTHENICATE is
  /****************************************************************
  ** Package        :  UE_CT_AUTHENICATE, header part
  **
  ** $Revision      : 1.0 $
  **
  ** Purpose        :  Use EC security to authenicate a request from 
  **                   a third party source
  **
  ** Documentation  :  
  **
  ** Created  : 18.Dec.2007  Mark Berkstresser
  **
  ** Modification history:
  **
  ** Version  Date        Whom  Change description:
  ** -------  ------      ----- --------------------------------------
  ** 1.0      18.DEC.2007  MWB    Initial Version
  *****************************************************************/

FUNCTION RequestValid(p_requestor_cai VARCHAR2,
                          p_data_class    VARCHAR2,
                          p_activity          VARCHAR2) 
                          RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES (RequestValid, WNDS, WNPS, RNPS);


end UE_CT_AUTHENICATE;
/

