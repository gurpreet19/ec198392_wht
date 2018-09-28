CREATE OR REPLACE PACKAGE UE_CT_INSTALL_HISTORY IS
/****************************************************************
** Package        :  UE_CT_INSTALL_HISTORY
**
** Purpose        :  Log the installation of all TE-IS fixes and releases to client.
**                   A call to the entry procedure should be place at the top of every
**                   installation .sql file released to the client.
**
** Created  : 27.07.2006  Andrew Ball
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
** 1.0    27.07.2006 ARB   Initial version.
** 2.0    Dec 2006   MWB   Modified for Chevron
** 3.0    27.09.2011 SWGN  Updates for changes to CVX installation history in the template
**
*****************************************************************/

  PROCEDURE entry (p_id           CT_EC_INSTALL_HISTORY.INSTALL_ID%TYPE,
                   p_release_date DATE,
                   p_phase        VARCHAR2,
                   p_issues       VARCHAR2,
                   p_descr        VARCHAR2);
                   
  PROCEDURE entry (p_id           CT_EC_INSTALL_HISTORY.INSTALL_ID%TYPE,
                   p_release_date DATE,
                   p_description  VARCHAR2,
                   p_prepared_by  VARCHAR2);
                   
  PROCEDURE set_feature(p_feature_id        CT_EC_INSTALLED_FEATURES.FEATURE_ID%TYPE,
                        p_feature_name      CT_EC_INSTALLED_FEATURES.FEATURE_NAME%TYPE,
                        p_context_code      CT_EC_INSTALLED_FEATURES.CONTEXT_CODE%TYPE,
                        p_major_version     CT_EC_INSTALLED_FEATURES.MAJOR_VERSION%TYPE,
                        p_minor_version     CT_EC_INSTALLED_FEATURES.MINOR_VERSION%TYPE,
                        p_description       CT_EC_INSTALLED_FEATURES.DESCRIPTION%TYPE DEFAULT NULL);     
                          
  PROCEDURE drop_feature(p_feature_id         CT_EC_INSTALLED_FEATURES.FEATURE_ID%TYPE);                 
  
  PROCEDURE assert_feature_version(p_feature_id        CT_EC_INSTALLED_FEATURES.FEATURE_ID%TYPE,
                                   p_major_version     CT_EC_INSTALLED_FEATURES.MAJOR_VERSION%TYPE,
                                   p_minor_version     CT_EC_INSTALLED_FEATURES.MINOR_VERSION%TYPE,
                                   p_direction         VARCHAR2 DEFAULT '>=');

END UE_CT_INSTALL_HISTORY;
/
