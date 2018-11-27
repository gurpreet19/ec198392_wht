CREATE OR REPLACE PACKAGE EcBp_Contract_Account_Event IS
/******************************************************************************
** Package        :  EcBp_Contract_Account_Event, header part
**
** $Revision: 1.1 $
**
** Purpose        :  Class action for cntr_ACC_DAY_EVENT
**
** Documentation  :  www.energy-components.com
**
** Created        :  12.12.2005 Stian Skj�tad
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------

********************************************************************/

PROCEDURE validateQty(
  	p_contract_id       	VARCHAR2,
  	p_account_code				VARCHAR2,
  	p_event_type				VARCHAR2,
  	p_qty						NUMBER
);

PROCEDURE setRecordStatus(
	p_object_id		VARCHAR2,
	p_account_code	VARCHAR2,
	p_event_type	VARCHAR2,
	p_daytime		DATE,
	p_user			VARCHAR2 DEFAULT NULL
	);



END EcBp_Contract_Account_Event;