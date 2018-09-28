CREATE OR REPLACE PACKAGE UE_CT_WELL_TEST_SRV is
  /****************************************************************
  ** Package        :  UE_CT_WELL_TEST_SRV, header part
  **
  ** $Revision      : 1.0 $
  **
  ** Purpose        :  Interface between IFM and EC for well test validation
  **
  ** Documentation  :
  **
  ** Created  : 29.11.2007  Mark Berkstresser
  **
  ** Modification history:
  **
  ** Version  Date        Whom  Change description:
  ** -------  ------      ----- --------------------------------------
  ** 1.0      29.11.2007  MWB    Initial Version
  *****************************************************************/
/*
  PROCEDURE CreateDupWellTest(p_result_no 	 	 NUMBER,
							  p_requested_by 	 VARCHAR2,
                              p_new_result_no    OUT NUMBER,
                              p_comments         VARCHAR2 DEFAULT NULL,
							  p_source_system	 VARCHAR2,
							  p_use_in_alloc	 VARCHAR2,
                              p_new_oil_rate     NUMBER   DEFAULT NULL,
                              p_new_water_rate   NUMBER   DEFAULT NULL,
                              p_new_gas_rate     NUMBER   DEFAULT NULL,
                              p_new_gor          NUMBER   DEFAULT NULL,
                              p_new_watercut_pct NUMBER   DEFAULT NULL,
                              p_update_col_1     VARCHAR2 DEFAULT NULL,
                              p_update_value_1   NUMBER   DEFAULT NULL,
                              p_update_col_2     VARCHAR2 DEFAULT NULL,
                              p_update_value_2   NUMBER   DEFAULT NULL,
                              p_update_col_3     VARCHAR2 DEFAULT NULL,
                              p_update_value_3   NUMBER   DEFAULT NULL,
                              p_update_col_4     VARCHAR2 DEFAULT NULL,
                              p_update_value_4   NUMBER   DEFAULT NULL,
                              p_update_col_5     VARCHAR2 DEFAULT NULL,
                              p_update_value_5   NUMBER   DEFAULT NULL,
                              p_update_col_6     VARCHAR2 DEFAULT NULL,
                              p_update_value_6   NUMBER   DEFAULT NULL,
                              p_update_col_7     VARCHAR2 DEFAULT NULL,
                              p_update_value_7   NUMBER   DEFAULT NULL,
                              p_update_col_8     VARCHAR2 DEFAULT NULL,
                              p_update_value_8   NUMBER   DEFAULT NULL,
                              p_update_col_9     VARCHAR2 DEFAULT NULL,
                              p_update_value_9   NUMBER   DEFAULT NULL,
                              p_update_col_10    VARCHAR2 DEFAULT NULL,
                              p_update_value_10  NUMBER   DEFAULT NULL);

  PROCEDURE UpdateWellTestStatus(p_result_no NUMBER,
								p_requested_by VARCHAR2,
								p_operation VARCHAR2,
								p_comments VARCHAR2,
								p_source_system VARCHAR2,
								p_use_in_alloc VARCHAR2);
*/

PROCEDURE UpdateWellTest   (p_result_no        NUMBER,
                            p_requested_by     VARCHAR2,
                            p_record_date      DATE,
                            p_operation        VARCHAR2,
      						p_source_system    VARCHAR2,
                            p_new_result_no    OUT NUMBER,
                            p_return_code      OUT NUMBER,
                            p_return_desc      OUT VARCHAR2,
                            p_comments         VARCHAR2 DEFAULT NULL,
                            p_new_oil_rate     NUMBER   DEFAULT NULL,
                            p_new_water_rate   NUMBER   DEFAULT NULL,
                            p_new_gas_rate     NUMBER   DEFAULT NULL,
                            p_new_gor          NUMBER   DEFAULT NULL,
                            p_new_watercut_pct NUMBER   DEFAULT NULL,
                            p_update_col_1     VARCHAR2 DEFAULT NULL,
                            p_update_value_1   NUMBER   DEFAULT NULL,
                            p_update_col_2     VARCHAR2 DEFAULT NULL,
                            p_update_value_2   NUMBER   DEFAULT NULL,
                            p_update_col_3     VARCHAR2 DEFAULT NULL,
                            p_update_value_3   NUMBER   DEFAULT NULL,
                            p_update_col_4     VARCHAR2 DEFAULT NULL,
                            p_update_value_4   NUMBER   DEFAULT NULL,
                            p_update_col_5     VARCHAR2 DEFAULT NULL,
                            p_update_value_5   NUMBER   DEFAULT NULL,
                            p_update_col_6     VARCHAR2 DEFAULT NULL,
                            p_update_value_6   NUMBER   DEFAULT NULL,
                            p_update_col_7     VARCHAR2 DEFAULT NULL,
                            p_update_value_7   NUMBER   DEFAULT NULL,
                            p_update_col_8     VARCHAR2 DEFAULT NULL,
                            p_update_value_8   NUMBER   DEFAULT NULL,
                            p_update_col_9     VARCHAR2 DEFAULT NULL,
                            p_update_value_9   NUMBER   DEFAULT NULL,
                            p_update_col_10    VARCHAR2 DEFAULT NULL,
                            p_update_value_10  NUMBER   DEFAULT NULL,
							p_use_in_alloc 	   VARCHAR2 DEFAULT 'Y');

PROCEDURE InsertWellTest   (p_requested_by 	   VARCHAR2,
						    p_operation 	   VARCHAR2,
							p_comments 		   VARCHAR2 DEFAULT NULL,
						    p_source_system    VARCHAR2,
							p_new_oil_rate     NUMBER DEFAULT NULL,
							p_new_water_rate   NUMBER DEFAULT NULL,
						    p_new_gas_rate 	   NUMBER DEFAULT NULL,
						    p_new_gor 		   NUMBER DEFAULT NULL,
							p_new_watercut_pct NUMBER DEFAULT NULL,
						    p_new_result_no    OUT NUMBER,
							p_return_code 	   OUT NUMBER,
							p_return_desc 	   OUT VARCHAR2,
							p_use_in_alloc 	   VARCHAR2 DEFAULT 'Y');

end UE_CT_WELL_TEST_SRV;
/
