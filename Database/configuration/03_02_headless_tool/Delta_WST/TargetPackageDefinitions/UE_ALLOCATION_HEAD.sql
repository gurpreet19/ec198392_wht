CREATE OR REPLACE PACKAGE ue_allocation IS

  /******************************************************************************
  ** Package        :  ue_allocation, header part
  **
  ** $Revision: 1.1.2.1 $
  **
  ** Purpose        :  Includes user-exit functionality for meter allocation
  **
  ** Documentation  :  www.energy-components.com
  **
  ** Created  : 11.06.2012 Lee Wei Yap
  **
  ** Modification history:
  **
  ** Date        Whom     Change description:
  ** -------     ------   -----------------------------------------------
  ** 13.06.2012  leeeewei  Added functions to calculate nomination split
  */

  FUNCTION getTotalSchedQtyPrDelstrm(p_delstrm_id VARCHAR2,
                                     p_nom_cycle  VARCHAR2,
                                     p_loc_type   VARCHAR2,
                                     p_date       DATE,
                                     p_nom_seq    NUMBER)
									 RETURN NUMBER;

  FUNCTION getTotalSchedQtyPrDelpnt(p_delpnt_id VARCHAR2,
                                    p_nom_cycle VARCHAR2,
                                    p_loc_type  VARCHAR2,
                                    p_date      DATE,
                                    p_nom_seq   NUMBER)
									RETURN NUMBER;

  FUNCTION getNomSplit(p_loc_id    VARCHAR2,
                       p_nom_cycle VARCHAR2,
                       p_loc_type  VARCHAR2,
                       p_date      DATE,
                       p_nom_seq   NUMBER)
					   RETURN NUMBER;

  FUNCTION getRepNomSplit(p_loc_id    VARCHAR2,
                          p_nom_cycle VARCHAR2,
                          p_loc_type  VARCHAR2,
                          p_date      DATE,
                          p_nom_seq   NUMBER)
						  RETURN NUMBER;

  FUNCTION getTotalRepSchedQtyPrDelpnt(p_delpnt_id VARCHAR2,
                                       p_nom_cycle VARCHAR2,
                                       p_loc_type  VARCHAR2,
                                       p_date      DATE,
                                       p_nom_seq   NUMBER)
									   RETURN NUMBER;

  FUNCTION getTotalRepSchedQtyPrDelstrm(p_delstrm_id VARCHAR2,
                                        p_nom_cycle  VARCHAR2,
                                        p_loc_type   VARCHAR2,
                                        p_date       DATE,
                                        p_nom_seq    NUMBER)
										RETURN NUMBER;

END ue_allocation;