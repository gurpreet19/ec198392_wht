CREATE OR REPLACE PACKAGE BODY EcDp_QBL_Export_Report IS
  /****************************************************************
  ** Package        :  EcDp_QBL_Export_Report, body part
  **
  ** $Revision: 1.4.32.2 $
  **
  ** Purpose        :  Validation on the Report Columns.
  **
  ** Documentation  :  www.energy-components.com
  **
  ** Created  : 14.05.2009  Leong Weng Onn
  **
  ** Modification history:
  **
  ** Date        Who  Change description:
  ** ----------  ---- --------------------------------------
  ** 2009-05-14  LeongWen  Initial version
  ** 2012-04-11  hodneeri  Made the class handle both insert and delete of attributes
  ** 2012-11-28  jenserun  disallow changes to queries you dont own
  *****************************************************************/

  PROCEDURE ValidateReportColumns(p_object_id varchar2, p_qbl_query_no varchar2) IS
    CURSOR c_insert IS
      SELECT column_name
        FROM V_QBL_WHERE_COND_POPUP ec
       WHERE ec.table_name = p_object_id
      MINUS
      select column_name
        from QBL_EXPORT_COLUMNS ec
       WHERE ec.OBJECT_ID = p_object_id AND ec.QBL_EXPORT_QUERY_NO = p_qbl_query_no;

    CURSOR c_delete IS
      SELECT column_name
        FROM QBL_EXPORT_COLUMNS ec
       WHERE ec.OBJECT_ID = p_object_id AND ec.QBL_EXPORT_QUERY_NO = p_qbl_query_no
      MINUS
      select column_name
        from V_QBL_WHERE_COND_POPUP
       WHERE V_QBL_WHERE_COND_POPUP.TABLE_NAME = p_object_id;

    lv_attribute QBL_EXPORT_COLUMNS.COLUMN_NAME%TYPE;

  BEGIN

    --INSERT MISSING COLUMNS
    OPEN c_insert;
    LOOP
      FETCH c_insert
        INTO lv_attribute;
      EXIT WHEN c_insert%NOTFOUND;

      INSERT INTO QBL_EXPORT_COLUMNS
        (OBJECT_ID,
         START_DATE,
         END_DATE,
         COLUMN_NAME,
         INCLUDE_IN_RESULT,
         QBL_EXPORT_QUERY_NO,
         created_by,
         created_date)
      VALUES
        (p_object_id, sysdate, null, lv_attribute, 'N', p_qbl_query_no, EcDp_User_Session.getUserSessionParameter('USERNAME'), sysdate);

    END LOOP;
    CLOSE c_insert;

    --DELETE REMOVED COLUMNS
    OPEN c_delete;
    LOOP
      FETCH c_delete
        INTO lv_attribute;
      EXIT WHEN c_delete%NOTFOUND;

      DELETE FROM QBL_EXPORT_COLUMNS qec
       WHERE qec.object_id = p_object_id
         AND qec.column_name = lv_attribute
         AND qec.QBL_EXPORT_QUERY_NO = p_qbl_query_no;

    END LOOP;
    CLOSE c_delete;

  END ValidateReportColumns;

  PROCEDURE ValidateOwner(p_qbl_query_no varchar2) IS
    v_created_by VARCHAR2(30);
    BEGIN
      SELECT CREATED_BY INTO v_created_by
      FROM QBL_EXPORT_QUERY
      WHERE QBL_EXPORT_QUERY_NO=p_qbl_query_no;
      IF v_created_by!=EcDp_User_Session.getUserSessionParameter('USERNAME') THEN
       Raise_Application_Error(-20000,'Cannot modify other users queries');
      END IF;
  END ValidateOwner;

END EcDp_QBL_Export_Report;