CREATE OR REPLACE PACKAGE BODY EcDp_Doc_Sequence IS

PROCEDURE insNewDocSeqNumber
(p_object_id VARCHAR2,
 p_daytime DATE)
IS
 lv2_object_code VARCHAR2(32) := ec_doc_sequence.object_code(p_object_id);
 ln_count NUMBER :=0;
BEGIN
     /*
     --Create a new sequence
     Ecdp_System_Key.assignNextNumber(lv2_object_code, lv2_neq_seq);
     --update the created sequence to match with the starting point.
     UPDATE ASSIGN_ID ai SET ai.MAX_ID = ec_doc_sequence_version.starting_point(p_object_id, p_daytime, '<=')
     WHERE ai.TABLENAME = lv2_object_code;
     */

     SELECT count(*)INTO ln_count FROM ASSIGN_ID WHERE TABLENAME = lv2_object_code;

     IF ln_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20000,'This Code has existed! please choose another code.');
     ELSE
       INSERT INTO ASSIGN_ID (TABLENAME, MAX_ID)
       VALUES (lv2_object_code, NVL(ec_doc_sequence_version.starting_point(p_object_id, p_daytime, '<='),0) - 1);
     END IF;

END insNewDocSeqNumber;

PROCEDURE resetDocSeqNumber
(p_object_id VARCHAR2,
 p_daytime DATE)
IS
BEGIN

    --if new Reset Date = Today, reset the Assign ID.
    IF TO_CHAR(p_daytime, 'DD/MM') = TO_CHAR(Ecdp_Timestamp.getCurrentSysdate, 'DD/MM') THEN

       UPDATE ASSIGN_ID ai SET ai.MAX_ID = ec_doc_sequence_version.starting_point(p_object_id, ec_doc_sequence.start_date(p_object_id), '<=') - 1
       WHERE ai.TABLENAME = ec_doc_sequence.object_code(p_object_id);

    END IF;

END resetDocSeqNumber;

PROCEDURE resetAllDocSeqNumber
IS
  CURSOR c_doc_seq(cp_sysdate DATE) IS
  SELECT ds.object_code, dsv.starting_point
  FROM DOC_SEQUENCE ds, DOC_SEQUENCE_VERSION dsv
  WHERE TO_CHAR(reset_date, 'DD/MM') = TO_CHAR(cp_sysdate, 'DD/MM')
  AND ds.object_id = dsv.object_id;

BEGIN

    --if new Reset Date = Today, reset the Assign ID.
     FOR cur_rec IN c_doc_seq(Ecdp_Timestamp.getCurrentSysdate) LOOP

          UPDATE ASSIGN_ID ai SET ai.MAX_ID = cur_rec.starting_point - 1
          WHERE ai.TABLENAME = cur_rec.object_code;

     END LOOP;

END resetAllDocSeqNumber;

PROCEDURE updDocSeq
(p_new_object_code VARCHAR2,
 p_old_object_code VARCHAR2,
 p_new_starting_point NUMBER,
 p_old_starting_point NUMBER)
IS
 ln_count NUMBER := 0;
BEGIN
     --if DOC_SEQ OBJECT CODE is changed
     IF p_new_object_code <> p_old_object_code THEN

       SELECT count(*)INTO ln_count FROM ASSIGN_ID WHERE TABLENAME = p_new_object_code;

       IF ln_count > 0 THEN
          RAISE_APPLICATION_ERROR(-20000,'This Code has existed! please choose another code.');
       ELSE
         --update Assign ID Tablename
         UPDATE ASSIGN_ID ai SET ai.TABLENAME = p_new_object_code
         WHERE ai.TABLENAME = p_old_object_code;
       END IF;

     END IF;

END updDocSeq;

PROCEDURE delDocSeq
(p_object_id VARCHAR2, p_object_start_date DATE, p_object_end_date DATE)
IS
BEGIN

   IF TO_CHAR(p_object_start_date, 'DD/MM/YYYY') = TO_CHAR(p_object_end_date, 'DD/MM/YYYY') THEN
     delete ASSIGN_ID ai WHERE ai.TABLENAME = ec_doc_sequence.object_code(p_object_id);
   END IF;

END delDocSeq;

END;