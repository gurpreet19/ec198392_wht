CREATE OR REPLACE PACKAGE EcBp_Dispatching_Mapping IS
/****************************************************************
** Package        :  EcBp_Dispatching_Mapping
**
** $Revision: 1.8 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created  : 03.01.2006  by Svein Helge Kallevik
**
** Modification history:
**
** Date       Whom  	 Change description:
** --------   ----- 	--------------------------------------
** 03.01.06   shk   Initial version
** 13.07.06   Khew  Tracker 4148. Added new function getColumnValueByName.
** 06.11.06   Siah  #4702/#4554. Added getConvertedValue, getCellValueInViewUnit and setCellValueInViewUnit
** 29.08.07   ismaiime ECPD-6087 Added setRowMappingEndDate, setColMappingEndDate, validateDelete
** 05.01.09	  ismaiime	  ECPD-9970 Modified functions getColumnValueByName and validateDelete. Add parameter daytime and end date.
******************************************************************/
    FUNCTION  getCellValue(p_class_name varchar2, p_object_id varchar2, p_attribute_name varchar2, p_daytime date) return NUMBER;

    FUNCTION getColumnValueByName(p_stream_id VARCHAR2, p_field_id VARCHAR2, p_grouping_type VARCHAR2, p_bf_class_name VARCHAR2, p_col_name VARCHAR2, p_daytime DATE) RETURN VARCHAR2;

    PROCEDURE setCellValue(p_class_name varchar2, p_object_id varchar2, p_attribute_name varchar2, p_daytime date, p_value number);

    FUNCTION  getConvertedValue(p_object_id VARCHAR2, p_bf_class_name VARCHAR2, p_val_number NUMBER, p_convert_type VARCHAR2 DEFAULT 'V') return NUMBER;

    FUNCTION  getCellValueInViewUnit(p_class_name varchar2, p_object_id varchar2, p_attribute_name varchar2, p_daytime date) return NUMBER;

    PROCEDURE setCellValueInViewUnit(p_class_name varchar2, p_object_id varchar2, p_attribute_name varchar2, p_daytime date, p_value number);

    PROCEDURE setRowMappingEndDate(p_object_id VARCHAR2, p_bf_class_name VARCHAR2, p_daytime DATE);

    PROCEDURE setColMappingEndDate(p_object_id VARCHAR2, p_bf_class_name VARCHAR2, p_daytime DATE, p_attribute_name VARCHAR2, p_stream_id VARCHAR2, p_table_name VARCHAR2);

    PROCEDURE validateDelete(p_object_id VARCHAR2, p_bf_class_name VARCHAR2, p_daytime DATE, p_end_date DATE);

END EcBp_Dispatching_Mapping;