CREATE OR REPLACE PACKAGE EcBp_Storage_Proc_Plant IS
/****************************************************************
** Package        :  EcBp_Storage_Proc_Plant, header part
**
** $Revision: 1.29 $
**
** Purpose        :  Finds storage differences for active storages
**
** Documentation  :  www.energy-components.com
**
** Created  : 04.01.2011  Sarojini Rajaretnam
**
** Modification history:
**
** Version  Date     Whom  	    Change description:
** -------  ------   -------- 	--------------------------------------
**          04.01.11 rajarsar   ECPD-16478:Initial Version
**          05.01.11 farhaann   ECPD-16484:Added validateOverlappingPeriod - checking for overlapping events
**          11.01.11 musthram   ECPD-16483:Added validateBlendContentSplit - checking for sum equal to 100
**          24.01.11 farhaann   ECPD-16478:Added getStorageDayGrsOpeningVol, getStorageDayGrsClosingVol, getStorageDayGrsReceiptsVol, getStorageDayGrsYieldVol,
**                                         getStorageDayGrsIntakeVol, getStorageDayGrsDeliveredVol, getStorageDayGrsGainVol, getStorageDayGrsLossVol, getStorageDayGrsSellVol,
**                                         getStorageDayGrsBuyVol, getStorageDayDiffVol, createGainLossTransaction, getStorTotalCreditVol, getStorTotalDebitVol, getTotalTankVol
**          28.01.11 rajarsar   ECPD-16479:Added getProdDayGrsOpeningVol, getProdDayGrsClosingVol and createTransactionOwnshp
**          31.01.11 rajarsar   ECPD-16479:Added validateSplitVolume
**          21.02.11 rajarsar   ECPD-16872:Added updateOwnshpVol and updateChildOwnshp
**          24.02.11 rajarsar   ECPD-16874:Added createComplementTrans,updateComplementOwnshp, deleteComplmentEvent
**          25.02.11 rajarsar   ECPD-16874: Changed procedure name from deleteComplementEvent to deleComplementTrans
**          28.02.11 farhaann   ECPD-16480: Added createBlendContent, validateBlendSplitVolume and validateBlendContentVolume.
**          28.02.11 farhaann   ECPD-16480:Added getActualVolume
**          28.02.11 rajarsar   ECPD-16873:Added createRegradeTrans and getCompDayVol
**          01.03.11 rajarsar   ECPD-16481:Added getCompDayGrsOpeningVol and getCompDayGrsClosingVol
**          02.03.11 rajarsar   ECPD-16481:Added getTotalProdTransVol, getTotalProdGrsOpeningVol and getTotalProdGrsClosingVol
**          02.03.11 farhaann   ECPD-16480:Added updateBlendContent and approveSelectedBatch
**          03.03.11 rajarsar   ECPD-16873:Added updateOwnshpType
**          03.03.11 farhaann   ECPD-16480:Added updateBlendOwnshp and updateVolBlendOwnshp
**          22.03.11 farhaann   ECPD-16480:Added deleteChildEvent
**          06.05.11 rajarsar   ECPD-16920:Added updateRecalculateStorageMeas,insertRecalculateStorageMeas and deleteRecalculateStorageMeas
**                                        :Removed getStorTotalCreditVol and getStorTotalDebitVol.
**          31.05.11 rajarsar   ECPD-17518:Added updateBlendTrans
**          22.06.11 rajarsar   ECPD-17708:Added createComplementTransOwnshp
**          25.07.11 musthram   ECPD-17948:Removed getStorageDayGrsReceiptsVol, getStorageDayGrsYieldVol,
**                                         getStorageDayGrsIntakeVol, getStorageDayGrsDeliveredVol, getStorageDayGrsGainVol, getStorageDayGrsLossVol
** 										   Added getStorageDayGrsTransactionVol
**          15.09.11 musthram   ECPD-18629:Removed updateComplementOwnshp
**			19.10.11 madondin	ECPD-18457:Add new function for validateStorageProdUpdate and validateStorageProdDelete
**			27.12.11 musthram	ECPD-18949:Added updateApprovedBatchOwnshp, insertApprovedBatchOwnshp, deleteApprovedBatchOwnshp and deleteApprovedProductTrans
**                                        :Updated UpdateBlendTrans and ApproveSelectedBatch
**			30.01.12 choonshu	ECPD-18622:Added calcBlendContentMass, updateVolBlendBatch and approveBlendContent
*****************************************************************/
PROCEDURE validateOverlappingPeriod(p_object_id  VARCHAR2,
                                    p_daytime    DATE,
                                    p_end_date   DATE,
                                    p_product_id VARCHAR2);

PROCEDURE validateBlendContentSplit(p_object_id VARCHAR2, p_daytime DATE);

FUNCTION getStorageDayGrsOpeningVol (
    p_object_id            storage.object_id%TYPE,
    p_daytime              DATE)
RETURN NUMBER;

FUNCTION getStorageDayGrsClosingVol (
    p_object_id            storage.object_id%TYPE,
    p_daytime              DATE)
RETURN NUMBER;

FUNCTION getStorageDayGrsTransactionVol(
    p_object_id storage.object_id%TYPE,
    p_daytime   DATE,
    p_trans_type VARCHAR2)
RETURN NUMBER;

FUNCTION getStorageDayGrsSellVol (
    p_object_id storage.object_id%TYPE,
    p_daytime   DATE)
RETURN NUMBER;

FUNCTION getStorageDayGrsBuyVol (
    p_object_id storage.object_id%TYPE,
    p_daytime   DATE)
RETURN NUMBER;

FUNCTION getStorageDayDiffVol (
    p_object_id storage.object_id%TYPE,
    p_daytime   DATE)
RETURN NUMBER;

PROCEDURE createGainLossTransaction(p_object_id  VARCHAR2,
                                    p_daytime    DATE );


FUNCTION getTotalTankVol (
    p_object_id storage.object_id%TYPE,
    p_daytime   DATE)
RETURN NUMBER;

FUNCTION getProdDayGrsOpeningVol (
    p_object_id storage.object_id%TYPE,
    p_product_id product.object_id%TYPE,
    p_daytime   DATE)
RETURN NUMBER;

FUNCTION getProdDayGrsClosingVol (
    p_object_id storage.object_id%TYPE,
    p_product_id product.object_id%TYPE,
    p_daytime   DATE,
    p_to_daytime DATE DEFAULT NULL)
RETURN NUMBER;


FUNCTION getProdTransVol (
    p_object_id product.object_id%TYPE,
    p_company_id company.object_id%TYPE,
    p_daytime   DATE,
    p_to_daytime DATE DEFAULT NULL,
    p_trans_type VARCHAR2)
RETURN NUMBER;

PROCEDURE createTransactionOwnshp(p_event_no NUMBER);

FUNCTION getCompDayVol (
    p_object_id company.object_id%TYPE,
    p_daytime   DATE)
RETURN NUMBER;

PROCEDURE validateSplitVolume(p_event_no NUMBER);

PROCEDURE updateOwnshpVol(p_event_no NUMBER, p_user VARCHAR2);

PROCEDURE updateOwnshpType(p_event_no NUMBER);

PROCEDURE updateChildOwnshp(p_event_no NUMBER);

PROCEDURE createComplementTrans(p_event_no NUMBER);

PROCEDURE updateComplementTrans(p_event_no NUMBER,  p_user VARCHAR2);

PROCEDURE deleteComplementTrans(p_event_no NUMBER);

PROCEDURE createBlendContent(p_event_no NUMBER);

PROCEDURE validateBlendSplitVolume(p_event_no NUMBER);

PROCEDURE validateBlendContentVolume(p_event_no NUMBER);

FUNCTION getActualVolume(
   p_object_id  VARCHAR2,
   p_event_no NUMBER)
RETURN NUMBER;

PROCEDURE createRegradeTrans(p_event_no NUMBER);


FUNCTION getCompDayGrsOpeningVol (
    p_object_id product.object_id%TYPE,
    p_company_id company.object_id%TYPE,
    p_daytime   DATE)
RETURN NUMBER;


FUNCTION getCompDayGrsClosingVol (
    p_object_id product.object_id%TYPE,
    p_company_id company.object_id%TYPE,
    p_daytime   DATE,
    p_to_daytime DATE DEFAULT NULL)
RETURN NUMBER;

FUNCTION getTotalProdTransVol (
    p_object_id product.object_id%TYPE,
    p_daytime   DATE,
    p_to_daytime DATE DEFAULT NULL,
    p_trans_type VARCHAR2)
RETURN NUMBER;

FUNCTION getTotalProdGrsOpeningVol (
    p_object_id product.object_id%TYPE,
    p_daytime   DATE
   )
RETURN NUMBER;

FUNCTION getTotalProdGrsClosingVol(
    p_object_id product.object_id%TYPE,
    p_daytime   DATE,
    p_to_daytime DATE DEFAULT NULL)
RETURN NUMBER;

PROCEDURE updateBlendContent(p_event_no NUMBER);

PROCEDURE approveSelectedBatch(p_event_no VARCHAR2, p_user_name VARCHAR2);

PROCEDURE updateBlendOwnshp(p_event_no NUMBER);

PROCEDURE updateVolBlendOwnshp(p_event_no NUMBER);

PROCEDURE deleteChildEvent(p_event_no NUMBER);

PROCEDURE updateRecalculateStorageMeas(p_event_no NUMBER);

PROCEDURE insertRecalculateStorageMeas(p_event_no NUMBER);

PROCEDURE deleteRecalculateStorageMeas(p_event_no NUMBER);

PROCEDURE updateBlendTrans(p_event_no NUMBER,p_user VARCHAR2);

PROCEDURE createComplementTransOwnshp(p_event_no NUMBER);

PROCEDURE validateStorageProdUpdate(p_object_id VARCHAR2, p_daytime DATE, p_end_daytime DATE, p_product_id  VARCHAR2);

PROCEDURE validateStorageProdDelete(p_object_id VARCHAR2, p_daytime DATE, p_product_id  VARCHAR2);

PROCEDURE updateApprovedBatchOwnshp(p_event_no NUMBER);

PROCEDURE insertApprovedBatchOwnshp(p_event_no NUMBER, p_object_id VARCHAR2);

PROCEDURE deleteApprovedBatchOwnshp(p_event_no NUMBER, p_object_id VARCHAR2);

PROCEDURE deleteApprovedProductTrans(p_event_no NUMBER, p_object_id VARCHAR2);

FUNCTION calcBlendContentMass(
    p_object_id VARCHAR2,
    p_event_no NUMBER)
RETURN NUMBER;

PROCEDURE updateVolBlendBatch(p_event_no NUMBER);

PROCEDURE approveBlendContent(p_event_no NUMBER, p_object_id VARCHAR2);

END EcBp_Storage_Proc_Plant;