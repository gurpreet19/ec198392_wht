CREATE OR REPLACE PACKAGE EcDp_Doc_Sequence IS

PROCEDURE insNewDocSeqNumber
(p_object_id VARCHAR2,
 p_daytime DATE); --object Start Date

PROCEDURE resetDocSeqNumber
(p_object_id VARCHAR2,
 p_daytime DATE); --new Reset Date

PROCEDURE resetAllDocSeqNumber;

PROCEDURE updDocSeq
(p_new_object_code VARCHAR2,
 p_old_object_code VARCHAR2,
 p_new_starting_point NUMBER,
 p_old_starting_point NUMBER);

PROCEDURE delDocSeq
(p_object_id VARCHAR2, p_object_start_date DATE, p_object_end_date DATE);

END;