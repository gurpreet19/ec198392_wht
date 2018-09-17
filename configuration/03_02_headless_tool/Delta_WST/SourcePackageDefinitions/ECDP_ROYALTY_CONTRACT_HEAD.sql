CREATE OR REPLACE PACKAGE ECDP_ROYALTY_CONTRACT IS
/******************************************************************************
** Package        :  ECDP_ROYALTY_CONTRACT, header part
**
** $Revision: 1.1 $
**
** Purpose        :  Data package for Forecasting
**
** Documentation  :  www.energy-components.com
**
** Created  : 21.04.2014 Kenneth Masamba
**
** Modification history:
**
** Date     Whom  Change description:
** ------   ----- -------------------------------------------
**
********************************************************************/

  PROCEDURE validateOverlappingPeriod(p_object_id VARCHAR2, p_perf_int_id VARCHAR2, p_daytime DATE, p_end_date DATE, p_class_name VARCHAR2);

  PROCEDURE validateEndDate(p_object_id VARCHAR2, p_perf_int_id VARCHAR2, p_daytime DATE, p_end_date DATE);

  PROCEDURE  instProducts(p_daytime DATE, p_contract_id VARCHAR2);

  PROCEDURE  updateProducts(p_daytime DATE, p_product_group_id VARCHAR2, p_contract_id VARCHAR2, p_rty_base_volume VARCHAR2, p_use_ind VARCHAR2);

END ECDP_ROYALTY_CONTRACT;