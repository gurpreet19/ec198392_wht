CREATE OR REPLACE PACKAGE ue_Contract_Sale IS
/****************************************************************
** Package        :  ue_Contract_Sale; head part
**
** $Revision: 1.3 $
**
** Purpose        :  User exit package for sale releated functionality for contracts
**				  :  Any implementation found here is considered an example implementaiont.
**				  :	 Project may override and adjust this ue package
**
** Documentation  :  www.energy-components.com
**
** Created        :  03.02.2009	Kari Sandvik
**
** Modification history:
**
** Date        Whom            	Change description:
** ----------  -----           	-------------------------------------------
** 10/02/2014  Khairul Afendi  	ECPD-17240: Add copy contract features to ue_contract_sale
** 24/07/2014  muhammah			ECPD-26255: added procedure useAccountTemplate
**************************************************************************************************/

PROCEDURE amendContract(
  p_new_object_id VARCHAR2,
  p_from_object_id VARCHAR2,
  p_user VARCHAR2);

PROCEDURE useAccountTemplate(p_contract_id VARCHAR2, p_tmpl_code VARCHAR2, p_daytime DATE);

END ue_Contract_Sale;