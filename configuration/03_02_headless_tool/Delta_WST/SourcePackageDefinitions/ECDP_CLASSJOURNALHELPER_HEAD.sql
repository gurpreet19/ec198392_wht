CREATE OR REPLACE PACKAGE EcDp_ClassJournalHelper IS
/****************************************************************
** Package        :  EcDp_ClassJournalHelper, header part
**
** $Revision: 1.2 $
**
** Purpose        :  Help view generator create Journal logic for InsteadofTriggers.
**
** Documentation  :  www.energy-components.com
**
** Created  : 12.02.2010  Arild Vervik
**
*****************************************************************/


Function makeJournalRuleSection(p_class_name varchar2) RETURN VARCHAR2;
Function makeObjectRuleSection(p_class_name varchar2) RETURN VARCHAR2;
Function makeObjectRevTextSection(p_class_name varchar2) RETURN VARCHAR2;

END EcDp_ClassJournalHelper;