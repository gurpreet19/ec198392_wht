CREATE OR REPLACE PACKAGE ecdp_contract_inventory IS
/******************************************************************************
** Package        :  ecdp_contract_invetory, header part
**
** $Revision: 1.8 $
**
** Purpose        :  Find and work with delivery data
**
** Documentation  :  www.energy-components.com
**
** Created        :  17.02.2011 Kenneth Masamba
**
** Modification history:
**
** Date        Whom         Change description:
** ------      -----        -----------------------------------------------------------------------------------------------
** 17.02.2011  masamken     Initial version (Update inventory level)
** 31.07.2012  sharawan     ECPD-19482: Add new function getAllocQty for GD.0047 : Monthly OBA Status screen
** 31.07.2012  muhammah		ECPD-19482: Monthly OBA Status screen - Added new functions getAccumulatedBalDay and getAccumulatedBalMth
** 30.08.2012  masamken		ECPD-21446: Created new function checkOperBalTrans
** 26.09.2013  leeeewei		ECPD-24392: Added procedure checkTransSign
********************************************************************/
--

PROCEDURE aggregateDebitTransactions(p_object_id      VARCHAR2,
                                         p_daytime        DATE,
                                         p_debit_qty      NUMBER,
                                         p_credit_qty     NUMBER,
                                         p_old_debit_qty  NUMBER,
                                         p_old_credit_qty NUMBER
);

PROCEDURE aggregateCreditTransactions(p_object_id      VARCHAR2,
                                          p_daytime        DATE,
                                          p_debit_qty      NUMBER,
                                          p_credit_qty     NUMBER,
                                          p_old_debit_qty  NUMBER,
                                          p_old_credit_qty NUMBER
);

PROCEDURE aggregateDeletedDebitTrans(p_object_id      VARCHAR2,
                                         p_daytime        DATE,
                                         p_debit_qty      NUMBER,
                                         p_credit_qty     NUMBER,
                                         p_old_debit_qty  NUMBER,
                                         p_old_credit_qty NUMBER
);

PROCEDURE aggregateDeletedCreditTrans(p_object_id      VARCHAR2,
                                          p_daytime        DATE,
                                          p_debit_qty      NUMBER,
                                          p_credit_qty     NUMBER,
                                          p_old_debit_qty  NUMBER,
                                          p_old_credit_qty NUMBER
);

PROCEDURE addSwapTransactions( p_swap_seq       NUMBER,
                               p_class_name     VARCHAR2,
                               p_sender_id      VARCHAR2,
                               p_daytime        DATE,
                               p_receiver_id    VARCHAR2,
                               p_swap_qty       NUMBER
);

FUNCTION getAllocQty(p_object_id VARCHAR2, p_daytime DATE, p_time_span VARCHAR2) RETURN NUMBER;

FUNCTION getAccumulatedBalDay(p_object_id VARCHAR2, p_daytime DATE)RETURN NUMBER;

FUNCTION getAccumulatedBalMth(p_object_id VARCHAR2, p_daytime DATE)RETURN NUMBER;

PROCEDURE checkOperBalTrans(p_object_id        VARCHAR2,
                        	p_daytime          DATE,
							p_transaction_type VARCHAR2
);

PROCEDURE checkTransSign(p_debit     NUMBER,
                         p_credit    NUMBER);

END ecdp_contract_inventory;