CREATE OR REPLACE PACKAGE ue_cont_line_item IS
/****************************************************************
** Package        :  ue_cont_line_item, header part
**
** $Revision:
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created  : 07.02.2012 Dagfinn Rosnes
**
** Modification history:
**
** Version  Date         Whom   Change description:
** -------  ------       -----  --------------------------------------
******************************************************************/

isInsPPATransIntLIUEE     VARCHAR2(32) := 'FALSE';
isInsPPATransIntLIPreUEE  VARCHAR2(32) := 'FALSE';
isInsPPATransIntLIPostUEE VARCHAR2(32) := 'FALSE';

PROCEDURE InsPPATransIntLineItem(p_transaction_key VARCHAR2,
                                 p_line_item_template_id VARCHAR2,
                                 p_user VARCHAR2);

PROCEDURE InsPPATransIntLineItemPre(p_transaction_key VARCHAR2,
                                 p_line_item_template_id VARCHAR2,
                                 p_user VARCHAR2);

PROCEDURE InsPPATransIntLineItemPost(p_transaction_key VARCHAR2,
                                 p_line_item_template_id VARCHAR2,
                                 p_user VARCHAR2);

END ue_cont_line_item;