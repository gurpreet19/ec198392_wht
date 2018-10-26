CREATE OR REPLACE PACKAGE BODY EcDp_Document_Portfolio IS
  /****************************************************************
  ** Package        :  EcDp_Document_Portfolio, header part
  **
  ** $Revision: 1.2 $
  **
  ** Purpose        :  Provide special functions on Document Portfolio.
  **
  ** Documentation  :  www.energy-components.com
  **
  ** Created  : 26.09.2009 Stian Skj�tad
  **
  ** Modification history:
  **
  ** Version  Date        Whom        Change description:
  ** -------  ----------  ----        --------------------------------------
  *************************************************************************/

-- Current document + all decendants
CURSOR c_portfolio_documents (cp_document_key VARCHAR2, cp_booked_ind VARCHAR2) IS
SELECT distinct d.document_key,
                d.preceding_document_key,
                d.reversal_ind,
                d.document_level_code,
                d. created_date
  FROM cont_document d
 WHERE d.document_level_code =
       DECODE(cp_booked_ind, 'Y', 'BOOKED', 'N', d.document_level_code)
 START WITH d.document_key = cp_document_key
CONNECT BY PRIOR d.document_key = d.preceding_document_key
UNION
SELECT DISTINCT dx.document_key,
                dx.preceding_document_key,
                dx.reversal_ind,
                dx.document_level_code,
                dx.created_date
  FROM cont_document dx
 WHERE dx.document_key = cp_document_key
 ORDER BY created_date DESC;

-- Current transaction + all decendants
CURSOR c_portfolio_transactions (cp_document_key VARCHAR2, cp_transaction_key VARCHAR2, cp_booked_ind VARCHAR2) IS
SELECT DISTINCT t.transaction_key,
                t.preceding_trans_key,
                t.trans_template_id,
                d.reversal_ind,
                t.created_date
  FROM cont_transaction t, cont_document d
 WHERE t.document_key = d.document_key
   AND d.actual_reversal_date IS NULL

 START WITH t.transaction_key = cp_transaction_key
        AND t.document_key = cp_document_key
CONNECT BY PRIOR t.transaction_key = t.preceding_trans_key
UNION
SELECT DISTINCT tx.transaction_key,
                tx.preceding_trans_key,
                tx.trans_template_id,
                dx.reversal_ind,
                tx.created_date
  FROM cont_transaction tx, cont_document dx
 WHERE tx.transaction_key = cp_transaction_key
   AND dx.document_key = tx.document_key
   AND tx.document_key = cp_document_key
 ORDER BY created_date DESC;





--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : GetLastDocument
-- Description    : Finds the latest dependent document in a document portfolio. The document might be booked or unbooked, but not reversed.
--                  If function returns null, there's no valid dependent document i.e. if existing it might be unbooked, or reversed.
--
-- Preconditions  :
--
--
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
---------------------------------------------------------------------------------------------------
FUNCTION GetLastDocument(p_doc_key    VARCHAR2,
                         p_booked_ind VARCHAR2 DEFAULT 'Y')
RETURN VARCHAR2
--</EC-DOC>
IS

lv2_doc_id cont_document.document_key%TYPE;

BEGIN

FOR docs IN c_portfolio_documents(p_doc_key,p_booked_ind) LOOP

  IF docs.preceding_document_key IS NOT NULL THEN

     IF docs.reversal_ind = 'N' THEN
        lv2_doc_id := docs.document_key;
     END IF;

  END IF;

  EXIT WHEN lv2_doc_id IS NOT NULL;

END LOOP;

RETURN lv2_doc_id;


END GetLastDocument;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : GetLastDocTransaction
-- Description    : Finds the latest dependent transaction in a document portfolio based on a document and a transaction.
--                  The document the transaction belongs to might be booked or unbooked, but not reversed.
--                  If function returns null, there's no valid dependent document (hence no valid dependent transaction)
--                  i.e. if existing it might be unbooked, or reversed.
--
-- Preconditions  :
--
--
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
---------------------------------------------------------------------------------------------------
FUNCTION GetLastDocTransaction(p_doc_key         VARCHAR2,
                               p_transaction_key VARCHAR2,
                               p_booked_ind      VARCHAR2 DEFAULT 'Y')
  RETURN VARCHAR2
--</EC-DOC>
IS

lv2_transaction_key cont_transaction.transaction_key%TYPE;

BEGIN


FOR transactions IN c_portfolio_transactions(p_doc_key,p_transaction_key, p_booked_ind) LOOP

  IF transactions.preceding_trans_key IS NOT NULL THEN

     IF transactions.reversal_ind = 'N' THEN
        lv2_transaction_key := transactions.transaction_key;
     END IF;

  END IF;

  EXIT WHEN lv2_transaction_key IS NOT NULL;

END LOOP;

RETURN lv2_transaction_key;


END GetLastDocTransaction;






END EcDp_Document_Portfolio;