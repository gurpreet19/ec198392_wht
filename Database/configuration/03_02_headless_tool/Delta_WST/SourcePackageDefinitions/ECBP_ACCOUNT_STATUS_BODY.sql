CREATE OR REPLACE PACKAGE BODY EcBp_Account_Status IS
/****************************************************************
** Package        :  EcBp_account_status
**
** $Revision: 1.5 $
**
** Purpose        :  This package is responsible for calculation of Monthly account
**                   status for loading volume and nominated volume
**
**
**
** Documentation  :  www.energy-components.com
**
** Created  : 20.06.2001  Stig Vidar Nordg�
**
** Modification history:
**
** Date       Whom  Change description:
** ---------- ----- --------------------------------------
** 11.03.2002 DN    Removed trailing spaces.
** 18.11.2003 DN    Replaced sysdate with new function.
** 08.09.2004 KSN	Updated to 8.0 (Tracker 1255)
** 08.10.2004 DN  Bugfix in adjustment and refinery functions:. Fixed parameter calls to locally declared cursor c_company_account_no.
**                Removed obsolete global cursor c_company_account_no.
*****************************************************************/

FUNCTION refinery_offtake(p_storage_id VARCHAR2,
         p_company_id VARCHAR2,
         p_startday DATE,
         p_endday DATE) RETURN NUMBER
IS

 CURSOR c_company_account_no(cp_company_id VARCHAR2)
 IS
 SELECT account_no
 FROM account
 WHERE company_id = cp_company_id;

ls_account_no VARCHAR2(16) := NULL;
ln_refinery_offtake NUMBER := 0;
ln_sum_refinery_offtake NUMBER := 0;

BEGIN



  FOR company_accont_no IN c_company_account_no(p_company_id) LOOP

    ls_account_no := company_accont_no.account_no;

    IF ls_account_no IS NOT NULL THEN

      ln_refinery_offtake := producer_balance(p_storage_id,
                                                      ls_account_no,
                                                      'OFFTAKE',
                                                      p_startday,
                                                      p_endday);

    ELSE
      ln_refinery_offtake := 0;
    END IF;

    ln_sum_refinery_offtake := ln_sum_refinery_offtake + ln_refinery_offtake;
  END LOOP;

  RETURN ln_sum_refinery_offtake;

 END refinery_offtake;

/*****************************************************************/

FUNCTION adjustment(p_storage_id VARCHAR2,
         p_company_id VARCHAR2,
         p_startday DATE,
         p_endday DATE) RETURN NUMBER
IS

 CURSOR c_company_account_no(cp_company_id VARCHAR2,
                             cp_storage_id VARCHAR2)
 IS
 SELECT account_no
 FROM account
 WHERE company_id = cp_company_id
 AND storage_id = cp_storage_id;

ls_account_no VARCHAR2(16) := NULL;
ln_adjustment  NUMBER := 0;
ln_sum_adjustment NUMBER := 0;

BEGIN



  FOR company_accont_no IN c_company_account_no(p_company_id, p_storage_id) LOOP

    ls_account_no := company_accont_no.account_no;

    IF ls_account_no IS NOT NULL THEN
     ln_adjustment := producer_balance(p_storage_id,
                                                      ls_account_no,
                                                      'ADJUSTMENT',
                                                      p_startday,
                                                      p_endday);
   ELSE
      ln_adjustment := 0;
    END IF;

    ln_sum_adjustment := ln_sum_adjustment + ln_adjustment;
  END LOOP;

 RETURN ln_sum_adjustment;

END adjustment;

/*******************************************************************************************/
FUNCTION producer_balance(p_storage_id     VARCHAR2,
                 p_account_no       VARCHAR2,
                 p_transaction_type VARCHAR2,
                 p_from_day         DATE,
                 p_to_day           DATE) RETURN NUMBER
IS
CURSOR c_sum_acc_trans(cp_transaction_type VARCHAR2) IS
SELECT SUM(credit) credit, SUM(debet) debit
FROM acc_transaction
WHERE storage_id = p_storage_id
AND transaction_type = cp_transaction_type
AND account_no = p_account_no
AND tran_status = 'A'
AND daytime >= p_from_day
AND daytime <= p_to_day;

ln_return						NUMBER;

BEGIN

  FOR sum_acc_trans IN c_sum_acc_trans(p_transaction_type) LOOP
   	ln_return := Nvl(sum_acc_trans.credit, 0) - Nvl(sum_acc_trans.debit, 0) ;
  END LOOP;
  IF p_transaction_type = 'ADJUSTMENT' THEN
  	FOR sum_acc_trans IN c_sum_acc_trans('ROYALTY') LOOP
  		ln_return := ln_return + Nvl(sum_acc_trans.credit, 0) - Nvl(sum_acc_trans.debit, 0);
  	END LOOP;
  END IF;

  RETURN Nvl(ln_return, 0);
END;

END EcBp_Account_Status;