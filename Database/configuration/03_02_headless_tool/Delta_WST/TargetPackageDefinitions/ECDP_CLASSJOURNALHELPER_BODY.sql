CREATE OR REPLACE PACKAGE BODY EcDp_ClassJournalHelper IS
/****************************************************************
** Package        :  EcDp_ClassJournalHelper, body part
**
** $Revision: 1.4 $
**
** Purpose        :  Help view generator create Journal logic for InsteadofTriggers.
**
** Documentation  :  www.energy-components.com
**
** Created  : 12.02.2010  Arild Vervik
**
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : makeJournalRuleSection
-- Description    : Find the journal rules for given class and combind it with global rules
--                  to make the journal releated code for class generated Insteadoftriggers
--                  Also include handling of rev_text if manadatory.
--
-- Preconditions  : None
--
--
-- Postcondition  : If class journaling rules are found, return a codeblock that can be used
--                  by viewgenerator as part of trigger logic
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
FUNCTION makeJournalRuleSection(p_class_name varchar2)
RETURN VARCHAR2
--</EC-DOC>

IS

   lv2_journal_section      VARCHAR2(32000) := '';
   lv2_build_if_rev_no      VARCHAR2(32000);
   lv2_build_if_rev_text    VARCHAR2(32000);
   lv2_journal_if           CLASS.JOURNAL_RULE_DB_SYNTAX%TYPE;
   lv2_jour_usr_excl_old    CTRL_SYSTEM_ATTRIBUTE.ATTRIBUTE_TEXT%TYPE;
   lv2_jour_usr_excl_new    CTRL_SYSTEM_ATTRIBUTE.ATTRIBUTE_TEXT%TYPE;

begin

    -- Include update for rev info
   lv2_journal_if := EcDp_ClassMeta.getClassJournalIfCondition(p_class_name);

   IF lv2_journal_if IS NOT NULL THEN

     IF ec_ctrl_system_attribute.attribute_text(TRUNC(SYSDATE),'JOUR_USER_EXCL_OLD_IND','<=') = 'Y' THEN
       lv2_jour_usr_excl_old  := ec_ctrl_system_attribute.attribute_text(TRUNC(SYSDATE),'JOUR_USER_EXCL_OLD','<=');
     END IF;

     IF ec_ctrl_system_attribute.attribute_text(TRUNC(SYSDATE),'JOUR_USER_EXCL_NEW_IND','<=') = 'Y' THEN
       lv2_jour_usr_excl_new  := ec_ctrl_system_attribute.attribute_text(TRUNC(SYSDATE),'JOUR_USER_EXCL_NEW','<=');
     END IF;

     lv2_build_if_rev_no := lv2_journal_if ||CHR(10);


     IF  lv2_jour_usr_excl_old IS NOT NULL THEN

        lv2_build_if_rev_no := lv2_build_if_rev_no ||'   and NOT (nvl(o_last_updated_by,o_created_by) IN (' || lv2_jour_usr_excl_old||'))'||CHR(10);

     END IF;

     lv2_build_if_rev_text := lv2_build_if_rev_no;

     IF  lv2_jour_usr_excl_new IS NOT NULL THEN

        lv2_build_if_rev_no := lv2_build_if_rev_no ||'   and NOT (nvl(n_last_updated_by,n_created_by) IN ('||lv2_jour_usr_excl_new||')'|| CHR(10);
        lv2_build_if_rev_text := lv2_build_if_rev_no || ')';
        lv2_build_if_rev_no := lv2_build_if_rev_no ||'            AND nvl(o_last_updated_by,o_created_by) IN ('||lv2_jour_usr_excl_new||'))'|| CHR(10);

      END IF;

     lv2_journal_section := '   IF ' || lv2_build_if_rev_no ;
     lv2_journal_section := lv2_journal_section ||'   THEN' || CHR(10);
     lv2_journal_section := lv2_journal_section ||'      n_rev_no := n_rev_no + 1;' || CHR(10);
     lv2_journal_section := lv2_journal_section ||'   END IF;'||CHR(10)||CHR(10);

     IF EcDp_ClassMeta.IsRevTextMandatory(p_class_name) = 'Y' THEN
         lv2_journal_section := lv2_journal_section ||'   IF UPDATING AND '||lv2_build_if_rev_text||'   THEN -- Check rev_text, controlled by class.ensure_rev_text_on_upd'||CHR(10);
         lv2_journal_section := lv2_journal_section ||'      IF NOT UPDATING(''REV_TEXT'') OR n_rev_text IS NULL OR Nvl(n_rev_text,''NA'') = Nvl(:old.rev_text,''NA'') THEN Raise_Application_Error(-20111,''Please provide a new value for the revision text''); END IF;'||CHR(10);
         lv2_journal_section := lv2_journal_section ||'   END IF;'||CHR(10)||CHR(10);
     END IF;

   END IF;

   RETURN lv2_journal_section;

END makeJournalRuleSection;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : makeObjectRuleSection
-- Description    : Find the journal rules for given object class and combind it with global rules
--                  to make the journal releated code for class generated Insteadoftriggers
--
-- Preconditions  : None
--
--
-- Postcondition  : If class journaling rules are found, return a codeblock that can be used
--                  by viewgenerator as part of trigger logic
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
Function makeObjectRuleSection(p_class_name varchar2)
RETURN VARCHAR2
--</EC-DOC>

IS

   lv2_journal_section      VARCHAR2(32000) := '';
   lv2_build_if_rev_no      VARCHAR2(32000);
   lv2_build_if_rev_text    VARCHAR2(32000);
   lv2_journal_if           CLASS.JOURNAL_RULE_DB_SYNTAX%TYPE;
   lv2_jour_usr_excl_old    CTRL_SYSTEM_ATTRIBUTE.ATTRIBUTE_TEXT%TYPE;
   lv2_jour_usr_excl_new    CTRL_SYSTEM_ATTRIBUTE.ATTRIBUTE_TEXT%TYPE;

begin

    -- Include update for rev info
   lv2_journal_if := EcDp_ClassMeta.getClassJournalIfCondition(p_class_name);

   IF lv2_journal_if IS NOT NULL THEN

     IF ec_ctrl_system_attribute.attribute_text(TRUNC(SYSDATE),'JOUR_USER_EXCL_OLD_IND','<=') = 'Y' THEN
       lv2_jour_usr_excl_old  := ec_ctrl_system_attribute.attribute_text(TRUNC(SYSDATE),'JOUR_USER_EXCL_OLD','<=');
     END IF;

     IF ec_ctrl_system_attribute.attribute_text(TRUNC(SYSDATE),'JOUR_USER_EXCL_NEW_IND','<=') = 'Y' THEN
       lv2_jour_usr_excl_new  := ec_ctrl_system_attribute.attribute_text(TRUNC(SYSDATE),'JOUR_USER_EXCL_NEW','<=');
     END IF;

     lv2_build_if_rev_no := lv2_journal_if ||CHR(10);


     IF  lv2_jour_usr_excl_old IS NOT NULL THEN

        lv2_build_if_rev_no := lv2_build_if_rev_no ||'   and NOT (nvl(o_last_updated_by,o_created_by) IN (' || lv2_jour_usr_excl_old||'))'||CHR(10);

     END IF;

     lv2_build_if_rev_text := lv2_build_if_rev_no;

     IF  lv2_jour_usr_excl_new IS NOT NULL THEN

        lv2_build_if_rev_no := lv2_build_if_rev_no ||'   and NOT (nvl(n_last_updated_by,n_created_by) IN ('||lv2_jour_usr_excl_new||')'|| CHR(10);
        lv2_build_if_rev_text := lv2_build_if_rev_no || ')';
        lv2_build_if_rev_no := lv2_build_if_rev_no ||'            AND nvl(o_last_updated_by,o_created_by) IN ('||lv2_jour_usr_excl_new||'))'|| CHR(10);

      END IF;

     lv2_journal_section := '   IF ' || lv2_build_if_rev_no ;
     lv2_journal_section := lv2_journal_section ||'   THEN' || CHR(10);
     lv2_journal_section := lv2_journal_section ||'      n_main_rev_no := n_main_rev_no + 1;' || CHR(10);
     lv2_journal_section := lv2_journal_section ||'      n_ver_rev_no := n_ver_rev_no + 1;' || CHR(10);
     lv2_journal_section := lv2_journal_section ||'   END IF;'||CHR(10)||CHR(10);


   END IF;

   RETURN lv2_journal_section;

END makeObjectRuleSection;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : makeObjectRevTextSection
-- Description    : Make the code section for enforcing manadtory revition text in Object
--                 class generated Insteadoftriggers
--
-- Preconditions  : None
--
--
-- Postcondition  : If class journaling rules are found, return a codeblock that can be used
--                  by viewgenerator as part of trigger logic
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior      :
--
---------------------------------------------------------------------------------------------------
Function makeObjectRevTextSection(p_class_name varchar2)
RETURN VARCHAR2
--</EC-DOC>

IS

   lv2_journal_section      VARCHAR2(32000) := '';
   lv2_build_if_rev_no      VARCHAR2(32000);
   lv2_build_if_rev_text    VARCHAR2(32000);
   lv2_journal_if           CLASS.JOURNAL_RULE_DB_SYNTAX%TYPE;
   lv2_jour_usr_excl_old    CTRL_SYSTEM_ATTRIBUTE.ATTRIBUTE_TEXT%TYPE;
   lv2_jour_usr_excl_new    CTRL_SYSTEM_ATTRIBUTE.ATTRIBUTE_TEXT%TYPE;

begin

    -- Include update for rev info
   lv2_journal_if := EcDp_ClassMeta.getClassJournalIfCondition(p_class_name);

   IF lv2_journal_if IS NOT NULL THEN

     IF ec_ctrl_system_attribute.attribute_text(TRUNC(SYSDATE),'JOUR_USER_EXCL_OLD_IND','<=') = 'Y' THEN
       lv2_jour_usr_excl_old  := ec_ctrl_system_attribute.attribute_text(TRUNC(SYSDATE),'JOUR_USER_EXCL_OLD','<=');
     END IF;

     IF ec_ctrl_system_attribute.attribute_text(TRUNC(SYSDATE),'JOUR_USER_EXCL_NEW_IND','<=') = 'Y' THEN
       lv2_jour_usr_excl_new  := ec_ctrl_system_attribute.attribute_text(TRUNC(SYSDATE),'JOUR_USER_EXCL_NEW','<=');
     END IF;

     lv2_build_if_rev_no := lv2_journal_if ||CHR(10);


     IF  lv2_jour_usr_excl_old IS NOT NULL THEN

        lv2_build_if_rev_no := lv2_build_if_rev_no ||'   and NOT (nvl(o_last_updated_by,o_created_by) IN (' || lv2_jour_usr_excl_old||'))'||CHR(10);

     END IF;

     lv2_build_if_rev_text := lv2_build_if_rev_no;

     IF  lv2_jour_usr_excl_new IS NOT NULL THEN

        lv2_build_if_rev_no := lv2_build_if_rev_no ||'   and NOT (nvl(n_last_updated_by,n_created_by) IN ('||lv2_jour_usr_excl_new||')'|| CHR(10);
        lv2_build_if_rev_text := lv2_build_if_rev_no || ')';

      END IF;


     IF EcDp_ClassMeta.IsRevTextMandatory(p_class_name) = 'Y' THEN

         lv2_journal_section := '   IF UPDATING AND '||lv2_build_if_rev_text||' AND NOT UPDATING(''DAYTIME'')   THEN -- Check rev_text, controlled by class.ensure_rev_text_on_upd'||CHR(10);
         lv2_journal_section := lv2_journal_section ||'      IF NOT UPDATING(''REV_TEXT'') OR n_rev_text IS NULL OR Nvl(n_rev_text,''NA'') = Nvl(:old.rev_text,''NA'') THEN Raise_Application_Error(-20111,''Please provide a new value for the revision text''); END IF;'||CHR(10);
         lv2_journal_section := lv2_journal_section ||'   END IF;'||CHR(10)||CHR(10);

         lv2_journal_section := lv2_journal_section ||'  IF UPDATING AND ( n_object_end_date = n_object_start_date )'||CHR(10);
         lv2_journal_section := lv2_journal_section ||'  THEN -- Always check rev_text, for this "delete" operation '||CHR(10);
         lv2_journal_section := lv2_journal_section ||'    IF NOT UPDATING(''REV_TEXT'') OR n_rev_text IS NULL OR Nvl(n_rev_text,''NA'') = Nvl(:old.rev_text,''NA'') THEN Raise_Application_Error(-20111,''Please provide a new value for the revision text''); END IF;'||CHR(10);
         lv2_journal_section := lv2_journal_section ||'  END IF;'||CHR(10);

     END IF;




   END IF;

   RETURN lv2_journal_section;

END makeObjectRevTextSection;




END EcDp_ClassJournalHelper;