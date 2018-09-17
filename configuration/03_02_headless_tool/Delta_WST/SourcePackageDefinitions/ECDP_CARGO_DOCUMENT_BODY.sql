CREATE OR REPLACE PACKAGE BODY EcDp_Cargo_Document IS
/**************************************************************************************************
** Package  :  EcDp_Cargo_Document
**
** $Revision: 1.15 $
**
** Purpose  :  This package handles the triggered updating of Cargo Document views
**
** Created:     28.05.2007 Nik Eizwan
**
** Modification history:
**
** Date:        Whom:       Rev.  Change description:
** ----------    -----       ----  ------------------------------------------------------------------------
** 28.05.2007   Nik Eizwan  0.1   First version
** 17.03.2009   oonnnng           Added retrieve SORT_ORDER column in c_lift_acc_recv_temp cursor.
**                                Added SORT_ORDER column and value when insert into lifting_doc_receiver table, looping c_lift_acc_recv_temp cursor.
** 10.03.2010   oonnnng           ECPD-13464: Added reset of lb_exist switch, and checking on ctrl_property_meta in useTemplate() procedure.
** 22.10.2012   chooysie		  ECPD-22137: Edit instantiation procedure
** 03.12.2012   muhammah          ECPD-21877:
                                  add global cursors: c_company_recv_temp, c_company_doc_instr_temp
                                  add procedures: useDocTemplate, updateCPYDocSet, instCPYInstructionReceiver, instCPYInstructionDoc, updateDocTemplate
                                  add funtion: getTemplateName
** 21.12.2012   chooysie		  ECPD-22215: Add sort_order while insert to lifting_doc_set in instInstructionReceiver
**************************************************************************************************/

--** global cursors **
--cursor for looping through lift_acc_recv_temp
CURSOR c_lift_acc_recv_temp(cp_object_id VARCHAR2, cp_template_code VARCHAR2) IS
SELECT
  lart.OBJECT_ID,
  lart.TEMPLATE_CODE,
  lart.COMPANY_CONTACT_ID,
  lart.DISTRIBUTION_METHOD,
  lart.SORT_ORDER
FROM lift_acc_receiver_temp lart
WHERE
  lart.object_id = cp_object_id AND
  lart.template_code = cp_template_code;

--cursor for looping through company_recv_temp
CURSOR c_company_recv_temp(cp_object_id VARCHAR2, cp_template_code VARCHAR2) IS
SELECT
  crt.OBJECT_ID,
  crt.TEMPLATE_CODE,
  crt.COMPANY_CONTACT_ID,
  crt.DISTRIBUTION_METHOD,
  crt.SORT_ORDER
FROM company_receiver_temp crt
WHERE
  crt.object_id = cp_object_id AND
  crt.template_code = cp_template_code;

--make cursor for looping through lift_acc_doc_instr_temp
CURSOR c_lift_acc_doc_instr_temp(cp_object_id VARCHAR2, cp_template_code VARCHAR2) IS
SELECT
  ladit.OBJECT_ID,
  ladit.TEMPLATE_CODE,
  ladit.COMPANY_CONTACT_ID,
  ladit.DOC_CODE,
  ladit.ORIGINAL,
  ladit.COPIES
FROM lift_acc_doc_instr_temp ladit
WHERE
  ladit.object_id = cp_object_id AND
  ladit.template_code = cp_template_code;

--make cursor for looping through company_doc_instr_temp
CURSOR c_company_doc_instr_temp(cp_object_id VARCHAR2, cp_template_code VARCHAR2) IS
SELECT
  cdit.OBJECT_ID,
  cdit.TEMPLATE_CODE,
  cdit.COMPANY_CONTACT_ID,
  cdit.DOC_CODE,
  cdit.ORIGINAL,
  cdit.COPIES
FROM company_doc_instr_temp cdit
WHERE
  cdit.object_id = cp_object_id AND
  cdit.template_code = cp_template_code;

--cursor for looping through lift_acc_doc_temp
CURSOR c_lift_acc_doc_temp (cp_object_id VARCHAR2, cp_template_code VARCHAR2) IS
SELECT  ladt.OBJECT_ID,
  ladt.TEMPLATE_CODE,
  ladt.TEMPLATE_NAME,
  ladt.DEFAULT_IND,
  ladt.CARGO_DOC_TEMPLATE_CODE
FROM   lift_acc_doc_template ladt
WHERE  ladt.object_id = cp_object_id AND
  ladt.template_code = cp_template_code;

--cursor for looping through cargo_doc_template_list
CURSOR c_car_doc_temp_list (cp_code VARCHAR2) IS
SELECT cdtlist.doc_code
FROM cargo_doc_template_list cdtlist
WHERE cdtlist.code = cp_code;

--cursor for getting CARGO DOCUMENT codes from prosty_codes
CURSOR c_prosty_codes IS
SELECT eccodes.code, sort_order
FROM prosty_codes eccodes
WHERE eccodes.code_type = 'CARGO_DOCUMENT'
AND nvl(eccodes.is_active, 'N') = 'Y';

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : useTemplate
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE useTemplate(p_parcel_no NUMBER,
          p_template_code VARCHAR2)
--</EC-DOC>
IS
--cursor to check for existing in lifting_doc_receiver
CURSOR c_lift_doc_receiver (cp_parcel_no VARCHAR2, cp_company_contact_id VARCHAR2, cp_distribution_method VARCHAR2)IS
  SELECT 1
  FROM lifting_doc_receiver ldr
  WHERE ldr.parcel_no = cp_parcel_no AND
    ldr.company_contact_id = cp_company_contact_id;

--as above, for lift_doc_instruction
CURSOR c_lift_doc_instr (cp_parcel_no VARCHAR2, cp_company_contact_id VARCHAR2, cp_doc_code VARCHAR2) IS
  SELECT *
  FROM lift_doc_instruction ldi
  WHERE ldi.parcel_no = cp_parcel_no AND
    ldi.company_contact_id = cp_company_contact_id AND
    ldi.doc_code = cp_doc_code;

--searches through lift_doc_instruction for existing (checkbox) ORIGINALs
CURSOR c_ldi_ori (cp_parcel_no VARCHAR2, cp_doc_code VARCHAR2) IS
  SELECT *
  FROM lift_doc_instruction ldi
  WHERE ldi.parcel_no = cp_parcel_no AND
    ldi.doc_code = cp_doc_code AND
    NVL(ldi.original,'dummy') = 'Y';

CURSOR c_doc_set (cp_object_id VARCHAR2, cp_template_code VARCHAR2) IS
  select s.doc_code, s.sort_order
  from lift_acc_doc_set s
  where s.object_id = cp_object_id
  and s.template_code =  cp_template_code;

CURSOR c_doc_exist (cp_parcel_no VARCHAR2, cp_doc_code VARCHAR2) IS
  select s.doc_code
  from lifting_doc_set s
  where parcel_no = cp_parcel_no
  and doc_code =  cp_doc_code;

lb_exist BOOLEAN := FALSE;
lv_docinstr_ori   VARCHAR2(32);
lv_Receipt_list   VARCHAR2(240);

BEGIN
  --Get Receipt list
  lv_Receipt_List := EcDp_ctrl_property.getSystemProperty('/com/ec/tran/to/screens/cargo_document/receipt_list', ec_storage_lift_nomination.requested_date(p_parcel_no));

  -- receivers
  FOR curLiftAccRecv IN c_lift_acc_recv_temp(ec_storage_lift_nomination.lifting_account_id(p_parcel_no), p_template_code) LOOP

    --reset the lb_exist switch
    lb_exist := FALSE;

    FOR curDocRecv IN c_lift_doc_receiver(p_parcel_no, curLiftAccRecv.company_contact_id, curLiftAccRecv.distribution_method) LOOP
      lb_exist := TRUE;
      EXIT;
    END LOOP;

        IF NOT lb_exist THEN
      INSERT INTO lifting_doc_receiver(parcel_no, company_contact_id, distribution_method, sort_order, created_by)
      VALUES (p_parcel_no, curLiftAccRecv.company_contact_id, curLiftAccRecv.distribution_method, curLiftAccRecv.sort_order, ecdp_context.getAppUser);
    END IF;
  END LOOP;

  -- documents
  FOR curDoc IN c_doc_set(ec_storage_lift_nomination.lifting_account_id(p_parcel_no), p_template_code) LOOP
    lb_exist := FALSE;
    FOR curDocExist IN c_doc_exist(p_parcel_no,  curDoc.doc_code) LOOP
      lb_exist := TRUE;
      EXIT;
    END LOOP;

    IF NOT lb_exist THEN
      INSERT INTO lifting_doc_set (PARCEL_NO, DOC_CODE, sort_order, created_by)
      VALUES (p_parcel_no, curDoc.doc_code, curDoc.sort_order, ecdp_context.getAppUser);
    END IF;
  END LOOP;

  --instruction
  FOR curLiftAccInstr IN c_lift_acc_doc_instr_temp(ec_storage_lift_nomination.lifting_account_id(p_parcel_no), p_template_code) LOOP
    lb_exist := FALSE;
    FOR curDocInstr IN c_lift_doc_instr(p_parcel_no, curLiftAccInstr.company_contact_id, curLiftAccInstr.doc_code) LOOP
      lb_exist := TRUE;
      EXIT;
    END LOOP;

        IF NOT lb_exist THEN
          -- get first original document; nullify the rest (currently works only with checkbox ORIGINALs)
      lv_docinstr_ori := curLiftAccInstr.original;
      FOR curDocInstr_ori IN c_ldi_ori(p_parcel_no, curLiftAccInstr.doc_code) LOOP
         -- If the receiver is the one specified in the receipt list in ctrl_property_meta an original is always allowed
         IF nvl(instr(lv_Receipt_list, ec_company_contact.object_code(curLiftAccInstr.company_contact_id)),0) = 0 then
            lv_docinstr_ori := '';
         END IF;
        EXIT;
      END LOOP;

      INSERT INTO lift_doc_instruction(parcel_no, company_contact_id, doc_code, original, copies, created_by)
      VALUES (p_parcel_no, curLiftAccInstr.company_contact_id, curLiftAccInstr.doc_code, lv_docinstr_ori, curLiftAccInstr.copies, ecdp_context.getAppUser);
    END IF;
  END LOOP;

END useTemplate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : useDocTemplate
-- Description    : to get document template from Lifting Account and Company
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE useDocTemplate(p_parcel_no NUMBER,
          p_template_code VARCHAR2,
          p_la_cpy_id VARCHAR2)
--</EC-DOC>
IS
--cursor to check for existing in lifting_doc_receiver
CURSOR c_lift_doc_receiver (cp_parcel_no VARCHAR2, cp_company_contact_id VARCHAR2, cp_distribution_method VARCHAR2)IS

  SELECT 1
  FROM lifting_doc_receiver ldr
  WHERE ldr.parcel_no = cp_parcel_no AND
    ldr.company_contact_id = cp_company_contact_id;

--as above, for lift_doc_instruction
CURSOR c_lift_doc_instr (cp_parcel_no VARCHAR2, cp_company_contact_id VARCHAR2, cp_doc_code VARCHAR2) IS
  SELECT *
  FROM lift_doc_instruction ldi
  WHERE ldi.parcel_no = cp_parcel_no AND
    ldi.company_contact_id = cp_company_contact_id AND
    ldi.doc_code = cp_doc_code;

--searches through lift_doc_instruction for existing (checkbox) ORIGINALs
CURSOR c_ldi_ori (cp_parcel_no VARCHAR2, cp_doc_code VARCHAR2) IS
  SELECT *
  FROM lift_doc_instruction ldi
  WHERE ldi.parcel_no = cp_parcel_no AND
    ldi.doc_code = cp_doc_code AND
    NVL(ldi.original,'dummy') = 'Y';

CURSOR c_doc_set (cp_object_id VARCHAR2, cp_template_code VARCHAR2) IS
  select s.doc_code, s.sort_order
  from lift_acc_doc_set s
  where s.object_id = cp_object_id
  and s.template_code =  cp_template_code;

CURSOR c_cpy_doc_set (cp_object_id VARCHAR2, cp_template_code VARCHAR2) IS
  select s.doc_code, s.sort_order
  from COMPANY_DOC_SET s
  where s.object_id = cp_object_id
  and s.template_code =  cp_template_code;

CURSOR c_doc_exist (cp_parcel_no VARCHAR2, cp_doc_code VARCHAR2) IS
  select s.doc_code
  from lifting_doc_set s
  where parcel_no = cp_parcel_no
  and doc_code =  cp_doc_code;

lb_exist BOOLEAN := FALSE;
lv_docinstr_ori   VARCHAR2(32);
lv_Receipt_list   VARCHAR2(240);
lv_ObjClassName VARCHAR2(32);

BEGIN

  lv_ObjClassName := ecdp_objects.GetObjClassName(p_la_cpy_id);

  --Get Receipt list
  lv_Receipt_List := EcDp_ctrl_property.getSystemProperty('/com/ec/tran/to/screens/cargo_document/receipt_list', ec_storage_lift_nomination.requested_date(p_parcel_no));

-- receivers

  delete tv_LIFTING_DOC_RECEIVER a where a.PARCEL_NO = p_parcel_no;
  IF lv_ObjClassName = 'LIFTING_ACCOUNT' THEN
      FOR curRecvTemp IN c_lift_acc_recv_temp(ec_storage_lift_nomination.lifting_account_id(p_parcel_no), p_template_code) LOOP
          --reset the lb_exist switch
          lb_exist := FALSE;

          FOR curDocRecv IN c_lift_doc_receiver(p_parcel_no, curRecvTemp.company_contact_id, curRecvTemp.distribution_method) LOOP
              lb_exist := TRUE;
              EXIT;
          END LOOP;

      IF NOT lb_exist THEN
         INSERT INTO lifting_doc_receiver(parcel_no, company_contact_id, distribution_method, sort_order, created_by)
         VALUES (p_parcel_no, curRecvTemp.company_contact_id, curRecvTemp.distribution_method, curRecvTemp.sort_order, ecdp_context.getAppUser);
         END IF;
      END LOOP;
  END IF;

  IF lv_ObjClassName = 'COMPANY' THEN
	  FOR curRecvTemp IN c_company_recv_temp(ec_lifting_account.company_id( ec_storage_lift_nomination.lifting_account_id(p_parcel_no)), p_template_code) LOOP
		 --reset the lb_exist switch
		      lb_exist := FALSE;

		      FOR curDocRecv IN c_lift_doc_receiver(p_parcel_no, curRecvTemp.company_contact_id, curRecvTemp.distribution_method) LOOP
		          lb_exist := TRUE;
		          EXIT;
		      END LOOP;

	    IF NOT lb_exist THEN
		     INSERT INTO lifting_doc_receiver(parcel_no, company_contact_id, distribution_method, sort_order, created_by)
		     VALUES (p_parcel_no, curRecvTemp.company_contact_id, curRecvTemp.distribution_method, curRecvTemp.sort_order, ecdp_context.getAppUser);
		  END IF;
	   END LOOP;
	END IF;

-- documents

  delete lifting_doc_set a where a.PARCEL_NO = p_parcel_no;
  IF lv_ObjClassName = 'LIFTING_ACCOUNT' THEN
     FOR curDoc IN c_doc_set(ec_storage_lift_nomination.lifting_account_id(p_parcel_no), p_template_code) LOOP
        lb_exist := FALSE;
        FOR curDocExist IN c_doc_exist(p_parcel_no,  curDoc.doc_code) LOOP
            lb_exist := TRUE;
            EXIT;
        END LOOP;

      IF NOT lb_exist THEN
        INSERT INTO lifting_doc_set (PARCEL_NO, DOC_CODE, sort_order, created_by)
        VALUES (p_parcel_no, curDoc.doc_code, curDoc.sort_order, ecdp_context.getAppUser);
      END IF;
    END LOOP;
  END IF;

  IF lv_ObjClassName = 'COMPANY' THEN
      FOR curDoc IN c_cpy_doc_set (ec_lifting_account.company_id( ec_storage_lift_nomination.lifting_account_id(p_parcel_no)), p_template_code) LOOP
      lb_exist := FALSE;
      FOR curDocExist IN c_doc_exist(p_parcel_no,  curDoc.doc_code) LOOP
        lb_exist := TRUE;
        EXIT;
      END LOOP;

      IF NOT lb_exist THEN
        INSERT INTO lifting_doc_set (PARCEL_NO, DOC_CODE, sort_order, created_by)
        VALUES (p_parcel_no, curDoc.doc_code, curDoc.sort_order, ecdp_context.getAppUser);
      END IF;
    END LOOP;
  END IF;

--instruction

  delete lift_doc_instruction a where a.parcel_no = p_parcel_no;
  IF lv_ObjClassName = 'LIFTING_ACCOUNT' THEN
    FOR curDocInstrTemp IN c_lift_acc_doc_instr_temp(ec_storage_lift_nomination.lifting_account_id(p_parcel_no), p_template_code) LOOP
        lb_exist := FALSE;
        FOR curDocInstr IN c_lift_doc_instr(p_parcel_no, curDocInstrTemp.company_contact_id, curDocInstrTemp.doc_code) LOOP
            lb_exist := TRUE;
            EXIT;
        END LOOP;

        IF NOT lb_exist THEN
            -- get first original document; nullify the rest (currently works only with checkbox ORIGINALs)
            lv_docinstr_ori := curDocInstrTemp.original;
            FOR curDocInstr_ori IN c_ldi_ori(p_parcel_no, curDocInstrTemp.doc_code) LOOP
                -- If the receiver is the one specified in the receipt list in ctrl_property_meta an original is always allowed
                IF nvl(instr(lv_Receipt_list, ec_company_contact.object_code(curDocInstrTemp.company_contact_id)),0) = 0 then
                   lv_docinstr_ori := '';
                END IF;
                EXIT;
             END LOOP;

        INSERT INTO lift_doc_instruction(parcel_no, company_contact_id, doc_code, original, copies, created_by)
        VALUES (p_parcel_no, curDocInstrTemp.company_contact_id, curDocInstrTemp.doc_code, lv_docinstr_ori, curDocInstrTemp.copies, ecdp_context.getAppUser);
      END IF;
    END LOOP;
  END IF;

  IF lv_ObjClassName = 'COMPANY' THEN
     FOR curDocInstrTemp IN c_company_doc_instr_temp(ec_lifting_account.company_id( ec_storage_lift_nomination.lifting_account_id(p_parcel_no)), p_template_code) LOOP
         lb_exist := FALSE;
         FOR curDocInstr IN c_lift_doc_instr(p_parcel_no, curDocInstrTemp.company_contact_id, curDocInstrTemp.doc_code) LOOP
             lb_exist := TRUE;
             EXIT;
         END LOOP;

     IF NOT lb_exist THEN
        -- get first original document; nullify the rest (currently works only with checkbox ORIGINALs)
        lv_docinstr_ori := curDocInstrTemp.original;
        FOR curDocInstr_ori IN c_ldi_ori(p_parcel_no, curDocInstrTemp.doc_code) LOOP
           -- If the receiver is the one specified in the receipt list in ctrl_property_meta an original is always allowed
           IF nvl(instr(lv_Receipt_list, ec_company_contact.object_code(curDocInstrTemp.company_contact_id)),0) = 0 then
              lv_docinstr_ori := '';
           END IF;
          EXIT;
        END LOOP;

        INSERT INTO lift_doc_instruction(parcel_no, company_contact_id, doc_code, original, copies, created_by)
        VALUES (p_parcel_no, curDocInstrTemp.company_contact_id, curDocInstrTemp.doc_code, lv_docinstr_ori, curDocInstrTemp.copies, ecdp_context.getAppUser);
      END IF;
    END LOOP;
  END IF;

  update STORAGE_LIFT_NOMINATION
  set TEMPLATE_CODE = p_template_code,
  LA_CPY_ID = p_la_cpy_id
  where PARCEL_NO = p_parcel_no;

END useDocTemplate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : updateDocSet
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE updateDocSet(p_object_id VARCHAR2,
              p_template_code VARCHAR2,
              p_old_cargo_temp_code VARCHAR2,
              p_new_cargo_temp_code VARCHAR2)
--</EC-DOC>
IS

  CURSOR c_temp_list (cp_template_code VARCHAR2) IS
    SELECT doc_code, sort_order
    FROM cargo_doc_template_list
    WHERE code = cp_template_code;


BEGIN

  -- if updating
  IF (Nvl(p_old_cargo_temp_code, '-1') <> nvl(p_new_cargo_temp_code, '-1')) then

    DELETE lift_acc_doc_set WHERE object_id = p_object_id AND template_code = p_template_code;
    DELETE lift_acc_doc_instr_temp WHERE object_id = p_object_id AND template_code = p_template_code;

    IF (p_new_cargo_temp_code IS NOT NULL) THEN
      -- insert documents from cargo doc template
      FOR curTempList IN c_temp_list(p_new_cargo_temp_code) LOOP
        INSERT INTO lift_acc_doc_set(object_id, template_code, doc_code, sort_order, created_by)
        VALUES (p_object_id, p_template_code, curTempList.doc_code, curTempList.sort_order, ecdp_context.getAppUser);
      END LOOP;
    ELSE
      -- insert documents from ec codes if no cargo doc template is set
      FOR curProstyCodes IN c_prosty_codes LOOP
        INSERT INTO lift_acc_doc_set(object_id, template_code, doc_code, sort_order, created_by)
        VALUES (p_object_id, p_template_code, curProstyCodes.code, curProstyCodes.sort_order, ecdp_context.getAppUser);
      END LOOP;
    END IF;
  END IF;

  -- if inserting and both old and new is null
  IF (p_old_cargo_temp_code IS NULL AND p_new_cargo_temp_code IS NULL) THEN
    -- insert documents from ec codes if no cargo doc template is set
    FOR curProstyCodes IN c_prosty_codes LOOP
      INSERT INTO lift_acc_doc_set(object_id, template_code, doc_code, sort_order, created_by)
      VALUES (p_object_id, p_template_code, curProstyCodes.code, curProstyCodes.sort_order, ecdp_context.getAppUser);
    END LOOP;
  END IF;

END updateDocSet;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : instInstructionReceiver
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE instInstructionReceiver(p_parcel_no NUMBER,
                p_company_contact_id VARCHAR2)
--</EC-DOC>
IS

CURSOR c_doc_set (cp_parcel_no NUMBER) IS
  SELECT doc_code
  FROM lifting_doc_set
  WHERE parcel_no = cp_parcel_no;

CURSOR c_la_temp (cp_object_id VARCHAR2, cp_rec_id VARCHAR2, cp_doc_code VARCHAR2 ) IS
  SELECT  original, copies, doc_code
  FROM   lift_acc_doc_instr_temp i, lift_acc_doc_template t
  WHERE  t.object_id = cp_object_id
  AND     t.object_id = i.object_id
    AND     i.company_contact_id = cp_rec_id
    AND     t.template_code = i.template_code
    AND    i.doc_code = Nvl(cp_doc_code, i.doc_code)
  AND    Nvl(t.default_ind, 'N') = 'Y';

CURSOR c_la_temp_doc_set (cp_object_id VARCHAR2, cp_rec_id VARCHAR2, cp_doc_code VARCHAR2 ) IS
  SELECT  original, copies, i.doc_code, s.sort_order
  FROM   lift_acc_doc_instr_temp i, lift_acc_doc_template t, lift_acc_doc_set s
  WHERE  t.object_id = cp_object_id
  AND     t.object_id = i.object_id
  AND     i.company_contact_id = cp_rec_id
  AND     t.template_code = i.template_code
  AND    i.doc_code = Nvl(cp_doc_code, i.doc_code)
  and s.object_id=t.object_id
  and s.template_code = i.template_code
  and s.doc_code = i.doc_code
  AND    Nvl(t.default_ind, 'N') = 'Y';

  lv_original VARCHAR2(32) := NULL;
  ln_copies  NUMBER := NULL;
  lb_exist  BOOLEAN := FALSE;

BEGIN
  -- if doucments already exist in set.look for template settings
  FOR curDoc IN c_doc_set (p_parcel_no) LOOP

    FOR curTemp IN c_la_temp (ec_storage_lift_nomination.lifting_account_id(p_parcel_no), p_company_contact_id, curDoc.doc_code) LOOP
      lv_original := curTemp.original;
      ln_copies := curTemp.copies;
    END LOOP;

    INSERT INTO lift_doc_instruction(parcel_no, company_contact_id, doc_code, original, copies, created_by)
    VALUES (p_parcel_no, p_company_contact_id, curDoc.doc_code, lv_original, ln_copies, ecdp_context.getAppUser);

    lb_exist := TRUE;
  END LOOP;

  --if documents dont exist. Use template
  IF NOT lb_exist THEN
    lb_exist := FALSE;

    FOR curTempDocSet IN c_la_temp_doc_set (ec_storage_lift_nomination.lifting_account_id(p_parcel_no), p_company_contact_id, null) LOOP
      INSERT INTO lifting_doc_set (PARCEL_NO, DOC_CODE, SORT_ORDER,created_by)
      VALUES (p_parcel_no, curTempDocSet.doc_code, curTempDocSet.sort_order, ecdp_context.getAppUser);

      INSERT INTO lift_doc_instruction(parcel_no, company_contact_id, doc_code, original, copies, created_by)
      VALUES (p_parcel_no, p_company_contact_id, curTempDocSet.doc_code, lv_original, ln_copies, ecdp_context.getAppUser);

      lb_exist := TRUE;
    END LOOP;

    -- if no template, use ec codes
    IF NOT lb_exist THEN
      FOR curProstyCodes IN c_prosty_codes LOOP
        INSERT INTO lifting_doc_set (PARCEL_NO, DOC_CODE, SORT_ORDER, created_by)
        VALUES (p_parcel_no, curProstyCodes.code, curProstyCodes.Sort_Order, ecdp_context.getAppUser);

        INSERT INTO lift_doc_instruction(parcel_no, company_contact_id, doc_code, created_by)
        VALUES (p_parcel_no, p_company_contact_id, curProstyCodes.code, ecdp_context.getAppUser);
      END LOOP;

    END IF;
  END IF;

END instInstructionReceiver;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : instInstructionDoc
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE instInstructionDoc(p_parcel_no NUMBER,
                p_doc_code VARCHAR2)
--</EC-DOC>
IS

  CURSOR c_rec (cp_parcel_no NUMBER) IS
  SELECT COMPANY_CONTACT_ID
  FROM lifting_doc_receiver
  WHERE parcel_no = cp_parcel_no;

  CURSOR c_la_temp (cp_object_id VARCHAR2, cp_rec_id VARCHAR2, cp_doc_code VARCHAR2 ) IS
  SELECT  original, copies, i.company_contact_id
  FROM   lift_acc_doc_instr_temp i, lift_acc_doc_template t
  WHERE  t.object_id = cp_object_id
  AND     t.object_id = i.object_id
    AND     i.company_contact_id = Nvl(cp_rec_id, i.company_contact_id)
    AND     t.template_code = i.template_code
    AND    i.doc_code = cp_doc_code
  AND    Nvl(t.default_ind, 'N') = 'Y';

  lv_original VARCHAR2(32) := NULL;
  ln_copies  NUMBER := NULL;
  lb_exist  BOOLEAN := FALSE;

BEGIN
  -- if receivers already exist. look for template settings
  FOR curRec IN c_rec (p_parcel_no) LOOP

    FOR curTemp IN c_la_temp (ec_storage_lift_nomination.lifting_account_id(p_parcel_no), curRec.COMPANY_CONTACT_ID, p_doc_code) LOOP
      lv_original := curTemp.original;
      ln_copies := curTemp.copies;
    END LOOP;

    INSERT INTO lift_doc_instruction(parcel_no, company_contact_id, doc_code, original, copies, created_by)
    VALUES (p_parcel_no, curRec.COMPANY_CONTACT_ID, p_doc_code, lv_original, ln_copies, ecdp_context.getAppUser);

    lb_exist := TRUE;
  END LOOP;

  --if receivers dont exist. Use receivers from template
  IF NOT lb_exist THEN

    FOR curTemp IN c_la_temp (ec_storage_lift_nomination.lifting_account_id(p_parcel_no), NULL, p_doc_code) LOOP
      INSERT INTO lifting_doc_receiver (PARCEL_NO, COMPANY_CONTACT_ID, created_by)
      VALUES (p_parcel_no, curTemp.company_contact_id , ecdp_context.getAppUser);

      INSERT INTO lift_doc_instruction(parcel_no, company_contact_id, doc_code, original, copies, created_by)
      VALUES (p_parcel_no, curTemp.company_contact_id, p_doc_code, lv_original, ln_copies, ecdp_context.getAppUser);
    END LOOP;

    --IF no receivers IN template it IS NOT possible to insert anything
  END IF;
END instInstructionDoc;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : instLAInstructionReceiver
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE instLAInstructionReceiver(p_lift_acc_id VARCHAR2,
                p_template_code VARCHAR2,
                p_company_contact_id VARCHAR2)
--</EC-DOC>
IS

CURSOR c_doc_set (cp_lift_acc_id VARCHAR2, cp_template_code VARCHAR2) IS
  SELECT doc_code
  FROM lift_acc_doc_set
  WHERE object_id = cp_lift_acc_id
    AND template_code = cp_template_code;

BEGIN
  -- get documents
  FOR curDoc IN c_doc_set (p_lift_acc_id, p_template_code) LOOP

    INSERT INTO lift_acc_doc_instr_temp(object_id, template_code, company_contact_id, doc_code, created_by)
    VALUES (p_lift_acc_id, p_template_code, p_company_contact_id, curDoc.doc_code, ecdp_context.getAppUser);
  END LOOP;

END instLAInstructionReceiver;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : instLAInstructionDoc
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE instLAInstructionDoc(p_lift_acc_id VARCHAR2,
                p_template_code VARCHAR2,
                p_doc_code VARCHAR2)
--</EC-DOC>
IS

  CURSOR c_rec(cp_lift_acc_id VARCHAR2, cp_template_code VARCHAR2) IS
  SELECT COMPANY_CONTACT_ID
  FROM LIFT_ACC_RECEIVER_TEMP
  WHERE object_id = cp_lift_acc_id
    AND template_code = cp_template_code;

BEGIN
  -- if receivers already exist. look for template settings
  FOR curRec IN c_rec (p_lift_acc_id, p_template_code) LOOP

    INSERT INTO lift_acc_doc_instr_temp(object_id, template_code, company_contact_id, doc_code, created_by)
    VALUES (p_lift_acc_id, p_template_code, curRec.COMPANY_CONTACT_ID, p_doc_code, ecdp_context.getAppUser);
  END LOOP;

END instLAInstructionDoc;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : updateCPYDocSet
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE updateCPYDocSet(p_object_id VARCHAR2,
              p_template_code VARCHAR2,
              p_old_cargo_temp_code VARCHAR2,
              p_new_cargo_temp_code VARCHAR2)
--</EC-DOC>
IS

  CURSOR c_temp_list (cp_template_code VARCHAR2) IS
    SELECT doc_code, sort_order
    FROM cargo_doc_template_list
    WHERE code = cp_template_code;


BEGIN

  -- if updating
  IF (Nvl(p_old_cargo_temp_code, '-1') <> nvl(p_new_cargo_temp_code, '-1')) then

    DELETE COMPANY_DOC_SET WHERE object_id = p_object_id AND template_code = p_template_code;
    DELETE COMPANY_DOC_INSTR_TEMP WHERE object_id = p_object_id AND template_code = p_template_code;

    IF (p_new_cargo_temp_code IS NOT NULL) THEN
      -- insert documents from cargo doc template
      FOR curTempList IN c_temp_list(p_new_cargo_temp_code) LOOP
        INSERT INTO COMPANY_DOC_SET(object_id, template_code, doc_code, sort_order, created_by)
        VALUES (p_object_id, p_template_code, curTempList.doc_code, curTempList.sort_order, ecdp_context.getAppUser);
      END LOOP;
    ELSE
      -- insert documents from ec codes if no cargo doc template is set
      FOR curProstyCodes IN c_prosty_codes LOOP
        INSERT INTO COMPANY_DOC_SET(object_id, template_code, doc_code, sort_order, created_by)
        VALUES (p_object_id, p_template_code, curProstyCodes.code, curProstyCodes.sort_order, ecdp_context.getAppUser);
      END LOOP;
    END IF;
  END IF;

  -- if inserting and both old and new is null
  IF (p_old_cargo_temp_code IS NULL AND p_new_cargo_temp_code IS NULL) THEN
    -- insert documents from ec codes if no cargo doc template is set
    FOR curProstyCodes IN c_prosty_codes LOOP
      INSERT INTO COMPANY_DOC_SET(object_id, template_code, doc_code, sort_order, created_by)
      VALUES (p_object_id, p_template_code, curProstyCodes.code, curProstyCodes.sort_order, ecdp_context.getAppUser);
    END LOOP;
  END IF;

END updateCPYDocSet;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : instCPYInstructionReceiver
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE instCPYInstructionReceiver(p_company_id VARCHAR2,
                p_template_code VARCHAR2,
                p_company_contact_id VARCHAR2)
--</EC-DOC>
IS

CURSOR c_doc_set (cp_company_id VARCHAR2, cp_template_code VARCHAR2) IS
  SELECT doc_code
  FROM COMPANY_DOC_SET
  WHERE object_id = cp_company_id
    AND template_code = cp_template_code;

BEGIN
  -- get documents
  FOR curDoc IN c_doc_set (p_company_id, p_template_code) LOOP

    INSERT INTO COMPANY_DOC_INSTR_TEMP(object_id, template_code, company_contact_id, doc_code, created_by)
    VALUES (p_company_id, p_template_code, p_company_contact_id, curDoc.doc_code, ecdp_context.getAppUser);
  END LOOP;

END instCPYInstructionReceiver;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : instCPYInstructionDoc
-- Description    :
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE instCPYInstructionDoc(p_company_id VARCHAR2,
                p_template_code VARCHAR2,
                p_doc_code VARCHAR2)
--</EC-DOC>
IS

  CURSOR c_rec(cp_company_id VARCHAR2, cp_template_code VARCHAR2) IS
  SELECT COMPANY_CONTACT_ID
  FROM LIFT_ACC_RECEIVER_TEMP
  WHERE object_id = cp_company_id
    AND template_code = cp_template_code;

BEGIN
  -- if receivers already exist. look for template settings
  FOR curRec IN c_rec (p_company_id, p_template_code) LOOP

    INSERT INTO COMPANY_DOC_INSTR_TEMP(object_id, template_code, company_contact_id, doc_code, created_by)
    VALUES (p_company_id, p_template_code, curRec.COMPANY_CONTACT_ID, p_doc_code, ecdp_context.getAppUser);
  END LOOP;

END instCPYInstructionDoc;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : updateDocTemplate
-- Description    : to update doc tempalate based on template type Lifting Account or Company
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE updateDocTemplate(p_parcel_no NUMBER,
          p_template_code VARCHAR2,
          p_la_cpy_id VARCHAR2)
--</EC-DOC>
IS

--cursor to check for existing in lifting_doc_receiver
CURSOR c_lift_doc_rec (cp_parcel_no VARCHAR2 )IS
  SELECT
	ldr.company_contact_id,
	ldr.distribution_method,
	ldr.sort_order
  FROM lifting_doc_receiver ldr
  WHERE ldr.parcel_no = cp_parcel_no;

CURSOR c_lift_doc_set (cp_parcel_no VARCHAR2) IS
  SELECT
  lds.doc_code,
  lds.sort_order
  FROM LIFTING_DOC_SET lds
  WHERE  lds.parcel_no = cp_parcel_no;

CURSOR c_lift_doc_ins (cp_parcel_no VARCHAR2) IS
  SELECT
  ins.company_contact_id,
  ins.doc_code,
  ins.original,
  ins.copies
  FROM LIFT_DOC_INSTRUCTION ins
  WHERE  ins.parcel_no = cp_parcel_no;

lv_ObjClassName VARCHAR2(32);

BEGIN

  lv_ObjClassName := ecdp_objects.GetObjClassName(p_la_cpy_id);

  IF lv_ObjClassName = 'COMPANY' THEN
    --delete from existing in configuration before update
    delete company_doc_instr_temp a where a.TEMPLATE_CODE = p_template_code;
    delete company_doc_set a where a.TEMPLATE_CODE = p_template_code;
    delete COMPANY_RECEIVER_TEMP a where a.TEMPLATE_CODE = p_template_code;

		FOR curLifDocRec in c_lift_doc_rec(p_parcel_no) LOOP
			INSERT INTO COMPANY_RECEIVER_TEMP(OBJECT_ID, TEMPLATE_CODE, COMPANY_CONTACT_ID, DISTRIBUTION_METHOD,SORT_ORDER, created_by)
      VALUES (p_la_cpy_id, p_template_code,curLifDocRec.Company_Contact_Id,curLifDocRec.Distribution_Method,curLifDocRec.Sort_Order, ecdp_context.getAppUser);
		END LOOP;

    FOR curLiftDocSet in  c_lift_doc_set(p_parcel_no) LOOP
      INSERT INTO company_doc_set(object_id,template_code,doc_code,sort_order,created_by)
      VALUES(p_la_cpy_id, p_template_code, curLiftDocSet.Doc_Code, curLiftDocSet.Sort_Order,ecdp_context.getAppUser);
    END LOOP;

    FOR curLiftDocIns in c_lift_doc_ins (p_parcel_no) LOOP
       INSERT INTO company_doc_instr_temp(object_id,template_code,company_contact_id,doc_code,original,copies, created_by)
       VALUES (p_la_cpy_id, p_template_code, curLiftDocIns.Company_Contact_Id, curLiftDocIns.Doc_Code,curLiftDocIns.Original, curLiftDocIns.Copies,ecdp_context.getAppUser);
    END LOOP;
	END IF;

  IF lv_ObjClassName = 'LIFTING_ACCOUNT' THEN
    --delete from existing in configuration before update
    delete lift_acc_doc_instr_temp a where a.TEMPLATE_CODE = p_template_code;
    delete lift_acc_doc_set a where a.TEMPLATE_CODE = p_template_code;
    delete lift_acc_receiver_temp a where a.TEMPLATE_CODE = p_template_code;

		FOR curLifDocRec in c_lift_doc_rec(p_parcel_no) LOOP
			INSERT INTO lift_acc_receiver_temp(OBJECT_ID, TEMPLATE_CODE, COMPANY_CONTACT_ID, DISTRIBUTION_METHOD,SORT_ORDER, created_by)
      VALUES (p_la_cpy_id, p_template_code,curLifDocRec.Company_Contact_Id,curLifDocRec.Distribution_Method,curLifDocRec.Sort_Order, ecdp_context.getAppUser);
		END LOOP;

    FOR curLiftDocSet in  c_lift_doc_set(p_parcel_no) LOOP
      INSERT INTO lift_acc_doc_set(object_id,template_code,doc_code,sort_order,created_by)
      VALUES(p_la_cpy_id, p_template_code, curLiftDocSet.Doc_Code, curLiftDocSet.Sort_Order,ecdp_context.getAppUser);
    END LOOP;

    FOR curLiftDocIns in c_lift_doc_ins (p_parcel_no) LOOP
       INSERT INTO lift_acc_doc_instr_temp(object_id,template_code,company_contact_id,doc_code,original,copies, created_by)
       VALUES (p_la_cpy_id, p_template_code, curLiftDocIns.Company_Contact_Id, curLiftDocIns.Doc_Code,curLiftDocIns.Original, curLiftDocIns.Copies,ecdp_context.getAppUser);
    END LOOP;
	END IF;

END updateDocTemplate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTemplateName
-- Description    : returns the template name based on the template type
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getTemplateName( p_template_code VARCHAR2,
						p_la_cpy_id VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS

lv_template_name VARCHAR2(100);
lv_ObjClassName VARCHAR2(32);

BEGIN

	lv_ObjClassName := ecdp_objects.GetObjClassName(p_la_cpy_id);

	IF lv_ObjClassName = 'LIFTING_ACCOUNT' THEN
		lv_template_name :=  ec_lift_acc_doc_template.template_name(p_la_cpy_id,p_template_code);
	END IF;

	IF lv_ObjClassName = 'COMPANY' THEN
		lv_template_name :=  ec_company_doc_template.template_name(p_la_cpy_id,p_template_code);
	END IF;

  RETURN lv_template_name;

END getTemplateName;

END EcDp_Cargo_Document;