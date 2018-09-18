CREATE OR REPLACE PACKAGE BODY ue_Inbound_Interface IS
/****************************************************************
** Package        :  ue_Inbound_Interface, body part
**
** $Revision: 1.7 $
**
** Purpose        :  Provide special functions for outbound interfaces
**
** Documentation  :  www.energy-components.com
**
** Created  : 01.04.2009  EnergyComponents Team
**
** Modification history:
**
** Version  Date       Whom       Change description:
** -------  ---------- ---------- --------------------------------------
** 1.1	    01.04.2009 SKJORSTI   Initial version
** 1.7      08.12.2011 ROSNEDAG   Added Instead of, Pre and Post for all user exits
************************************************************************************************************************************************************/

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       : TransferQuantitiesRecord
-- Description    : This is an INSTEAD OF user-exit addon to the standard EcDp_Inbound_Interface.TransferQuantitiesRecord.
-- Preconditions  : Must be enabled using global variable isTransferQtyRecordUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
FUNCTION TransferQuantitiesRecord(p_Rec     IFAC_QTY%ROWTYPE,
                                  p_user    VARCHAR2,
                                  p_daytime DATE DEFAULT sysdate -- run time
                                  )
RETURN VARCHAR2
IS
BEGIN

  RETURN NULL;

END TransferQuantitiesRecord;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       :  TransferQuantitiesRecordPre
-- Description    : This is a PRE user-exit addon to the standard EcDp_Inbound_Interface.TransferQuantitiesRecordPre.
-- Preconditions  : Must be enabled using global variable isTransferQtyRecPreUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
FUNCTION TransferQuantitiesRecordPre(p_Rec     IFAC_QTY%ROWTYPE,
                                     p_user    VARCHAR2,
                                     p_daytime DATE DEFAULT sysdate, -- run time
                                     p_status  VARCHAR2)
RETURN VARCHAR2
IS
BEGIN

  RETURN NULL;

END TransferQuantitiesRecordPre;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       : TransferQuantitiesRecordPost
-- Description    : This is a POST user-exit addon to the standard EcDp_Inbound_Interface.TransferQuantitiesRecordPost.
-- Preconditions  : Must be enabled using global variable isTransferQtyRecPostUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
FUNCTION TransferQuantitiesRecordPost(p_Rec     IFAC_QTY%ROWTYPE,
                                      p_user    VARCHAR2,
                                      p_daytime DATE DEFAULT SYSDATE, -- run time
                                      p_status  VARCHAR2)
RETURN VARCHAR2
IS
BEGIN

  RETURN NULL;

END TransferQuantitiesRecordPost;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       : ReceiveCargoQtyRecord
-- Description    : This is an INSTEAD OF user-exit addon to the standard EcDp_Inbound_Interface.ReceiveCargoQtyRecord.
--                  The procedure should handle population of one ifac_cargo_value record.
-- Preconditions  : Must be enabled using global variable isReceiveCargoQtyRecordUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
PROCEDURE ReceiveCargoQtyRecord(
   p_Rec       IFAC_CARGO_VALUE%ROWTYPE,
   p_user      VARCHAR2,
   p_daytime   DATE DEFAULT sysdate -- run time
   )
--</EC-DOC>
IS
BEGIN

  NULL;

END ReceiveCargoQtyRecord;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       : ReceiveCargoQtyRecordPre
-- Description    : This is a PRE user-exit addon to the standard EcDp_Inbound_Interface.ReceiveCargoQtyRecord.
-- Preconditions  : Must be enabled using global variable isReceiveCargoQtyRecPreUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
PROCEDURE ReceiveCargoQtyRecordPre(p_Rec     IN OUT IFAC_CARGO_VALUE%ROWTYPE,
                                   p_user    VARCHAR2,
                                   p_daytime DATE DEFAULT SYSDATE)
--</EC-DOC>
IS
BEGIN

  NULL;

END ReceiveCargoQtyRecordPre;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       : ReceiveCargoQtyRecordPost
-- Description    : This is a POST user-exit addon to the standard EcDp_Inbound_Interface.ReceiveCargoQtyRecord.
-- Preconditions  : Must be enabled using global variable isReceiveCargoQtyRecPostUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
PROCEDURE ReceiveCargoQtyRecordPost(p_Rec     IN OUT IFAC_CARGO_VALUE%ROWTYPE,
                                    p_user    VARCHAR2,
                                    p_daytime DATE DEFAULT SYSDATE)
--</EC-DOC>
IS
BEGIN

  NULL;

END ReceiveCargoQtyRecordPost;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       : ReceiveSalesQtyRecord
-- Description    : This is a INSTEAD OF user-exit addon to the standard EcDp_Inbound_Interface.ReceiveSalesQtyRecord.
--                  The procedure should handle population of one ifac_sales_qty record.
-- Preconditions  : Must be enabled using global variable isReceiveSalesQtyRecordUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
PROCEDURE ReceiveSalesQtyRecord(p_Rec     IFAC_SALES_QTY%ROWTYPE,
                                p_user    VARCHAR2,
                                p_daytime DATE DEFAULT SYSDATE) -- run time
--</EC-DOC>
IS
BEGIN

   NULL;

END ReceiveSalesQtyRecord;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       : ReceiveSalesQtyRecordPre
-- Description    : This is a PRE user-exit addon to the standard EcDp_Inbound_Interface.ReceiveSalesQtyRecord.
-- Preconditions  : Must be enabled using global variable isReceiveSalesQtyRecPreUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
PROCEDURE ReceiveSalesQtyRecordPre(p_Rec       IN OUT IFAC_SALES_QTY%ROWTYPE,
                                   p_user      VARCHAR2,
                                   p_daytime   DATE DEFAULT SYSDATE)
--</EC-DOC>
IS
BEGIN

   NULL;

END ReceiveSalesQtyRecordPre;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function       : ReceiveSalesQtyRecordPost
-- Description    : This is a POST user-exit addon to the standard EcDp_Inbound_Interface.ReceiveSalesQtyRecord.
-- Preconditions  : Must be enabled using global variable isReceiveSalesQtyRecPostUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
-------------------------------------------------------------------------------------------------
PROCEDURE ReceiveSalesQtyRecordPost(p_Rec       IN OUT IFAC_SALES_QTY%ROWTYPE,
                                    p_user      VARCHAR2,
                                    p_daytime   DATE DEFAULT SYSDATE)
--</EC-DOC>
IS
BEGIN

   NULL;

END ReceiveSalesQtyRecordPost;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : ReceiveIfacDocRecord
-- Description    : This is a INSTEAD OF user-exit addon to the standard EcDp_Inbound_Interface.ReceiveIfacDocRecord.
--                  The procedure should handle a simple population of an ifac document record.
-- Preconditions  : Must be enabled using global variable isReceiveIfacDocRecordUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
PROCEDURE ReceiveIfacDocRecord(
   p_Rec       IFAC_DOCUMENT%ROWTYPE,
   p_user      VARCHAR2,
   p_daytime   DATE DEFAULT sysdate -- run time
   )
--</EC-DOC>
IS

BEGIN

  NULL;

END ReceiveIfacDocRecord;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : ReceiveIfacDocRecordPre
-- Description    : This is a PRE user-exit addon to the standard EcDp_Inbound_Interface.ReceiveIfacDocRecord.
-- Preconditions  : Must be enabled using global variable isReceiveIfacDocRecPreUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
PROCEDURE ReceiveIfacDocRecordPre(
   p_Rec       IN OUT IFAC_DOCUMENT%ROWTYPE,
   p_user      VARCHAR2,
   p_daytime   DATE DEFAULT sysdate -- run time
   )
--</EC-DOC>
IS

BEGIN

  NULL;

END ReceiveIfacDocRecordPre;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : ReceiveIfacDocRecordPost
-- Description    : This is a POST user-exit addon to the standard EcDp_Inbound_Interface.ReceiveIfacDocRecord.
-- Preconditions  : Must be enabled using global variable isReceiveIfacDocRecPostUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
PROCEDURE ReceiveIfacDocRecordPost(
   p_Rec       IN OUT IFAC_DOCUMENT%ROWTYPE,
   p_user      VARCHAR2,
   p_daytime   DATE DEFAULT sysdate -- run time
   )
--</EC-DOC>
IS

BEGIN

  NULL;

END ReceiveIfacDocRecordPost;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : ReceiveERPPostingRecord
-- Description    : This is a INSTEAD OF user-exit addon to the standard ReceiveERPPostingRecord.
--                  The procedure should handle a simple population of an ifac erp posting record.
-- Preconditions  : Must be enabled using global variable isReceiveERPPostRecordUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
PROCEDURE ReceiveERPPostingRecord(
   p_Rec       IFAC_ERP_POSTINGS%ROWTYPE,
   p_user      VARCHAR2,
   p_daytime   DATE DEFAULT sysdate -- run time
   )
--</EC-DOC>
IS

BEGIN

  NULL;

END ReceiveERPPostingRecord;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : ReceiveERPPostingRecordPre
-- Description    : This is a PRE user-exit addon to the standard ReceiveERPPostingRecord.
-- Preconditions  : Must be enabled using global variable isReceiveERPPostRecPreUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
PROCEDURE ReceiveERPPostingRecordPre(
   p_Rec       IN OUT IFAC_ERP_POSTINGS%ROWTYPE,
   p_user      VARCHAR2,
   p_daytime   DATE DEFAULT sysdate -- run time
   )
--</EC-DOC>
IS

BEGIN

  NULL;

END ReceiveERPPostingRecordPre;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : ReceiveERPPostingRecordPost
-- Description    : This is a POST user-exit addon to the standard ReceiveERPPostingRecord.
-- Preconditions  : Must be enabled using global variable isReceiveERPPostRecPostUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
PROCEDURE ReceiveERPPostingRecordPost(
   p_Rec       IN OUT IFAC_ERP_POSTINGS%ROWTYPE,
   p_user      VARCHAR2,
   p_daytime   DATE DEFAULT sysdate -- run time
   )
--</EC-DOC>
IS

BEGIN

  NULL;

END ReceiveERPPostingRecordPost;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getPeriodQtyStatus
-- Description    : This is a INSTEAD OF user-exit addon to the standard getPeriodQtyStatus.
-- Preconditions  : Must be enabled using global variable isGetPeriodQtyStatusUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
PROCEDURE getPeriodQtyStatus(isqRec IN OUT ifac_sales_qty%ROWTYPE)
IS
--</EC-DOC>
BEGIN
  NULL;
END getPeriodQtyStatus;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getPeriodQtyStatusPre
-- Description    : This is a PRE user-exit addon to the standard getPeriodQtyStatus.
-- Preconditions  : Must be enabled using global variable isGetPeriodQtyStatusPreUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------

PROCEDURE getPeriodQtyStatusPre(isqRec IN OUT ifac_sales_qty%ROWTYPE)
IS
--</EC-DOC>
BEGIN
  NULL;
END getPeriodQtyStatusPre;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getPeriodQtyStatusPost
-- Description    : This is a POST user-exit addon to the standard getPeriodQtyStatus.
-- Preconditions  : Must be enabled using global variable isGetPeriodQtyStatusPostUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------

PROCEDURE getPeriodQtyStatusPost(isqRec IN OUT ifac_sales_qty%ROWTYPE)
IS
--</EC-DOC>
BEGIN
  NULL;
END getPeriodQtyStatusPost;
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getNewCargoRecords
-- Description    : This is a INSTEAD OF user-exit addon to the standard ReAnalyseNewCargoRecords.
-- Preconditions  : Must be enabled using global variable isReAnalyseNewCargoRecUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
PROCEDURE getNewCargoRecords (p_contract_id      VARCHAR2,
                              p_contract_area_id VARCHAR2,
                              p_business_unit_id VARCHAR2,
                              p_user             VARCHAR2
                             )
IS
--</EC-DOC>
BEGIN
  NULL;
END getNewCargoRecords;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getNewCargoRecordsPre
-- Description    : This is a PRE user-exit addon to the standard ReAnalyseNewCargoRecords.
-- Preconditions  : Must be enabled using global variable isReAnalyzeNewCargoRecPreUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------

PROCEDURE getNewCargoRecordsPre(p_contract_id      VARCHAR2,
                                p_contract_area_id VARCHAR2,
                                p_business_unit_id VARCHAR2,
                                p_user             VARCHAR2
                               )
IS
--</EC-DOC>
BEGIN
  NULL;
END getNewCargoRecordsPre;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getNewCargoRecordsPost
-- Description    : This is a POST user-exit addon to the standard ReAnalyseNewCargoRecords.
-- Preconditions  : Must be enabled using global variable isReAnalyzeNewCargoRecPostUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------

PROCEDURE getNewCargoRecordsPost(p_contract_id      VARCHAR2,
                                 p_contract_area_id VARCHAR2,
                                 p_business_unit_id VARCHAR2,
                                 p_user             VARCHAR2,
                                 p_Rec IN OUT IFAC_CARGO_VALUE%ROWTYPE
                                )
IS
--</EC-DOC>
BEGIN
  NULL;
END getNewCargoRecordsPost;

---------------------------------------------------------------------------------------------------
-- Procedure      : getNewSalesQtyRecords
-- Description    : This is a INSTEAD OF user-exit addon to the standard ReAnalyseNewSalesQtyRecords.
-- Preconditions  : Must be enabled using global variable isReAnalyseNewSalesQtyUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
PROCEDURE getNewSalesQtyRecords (p_contract_id      VARCHAR2,
                                 p_contract_area_id VARCHAR2,
                                 p_business_unit_id VARCHAR2,
                                 p_user             VARCHAR2
                                )
IS
--</EC-DOC>
BEGIN
  NULL;
END getNewSalesQtyRecords;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getNewSalesQtyRecordsPre
-- Description    : This is a PRE user-exit addon to the standard ReAnalyseNewSalesQtyRecords.
-- Preconditions  : Must be enabled using global variable isReAnalyzeNewSalesQtyPreUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------

PROCEDURE getNewSalesQtyRecordsPre(p_contract_id      VARCHAR2,
                                   p_contract_area_id VARCHAR2,
                                   p_business_unit_id VARCHAR2,
                                   p_user             VARCHAR2
                                  )
IS
--</EC-DOC>
BEGIN
  NULL;
END getNewSalesQtyRecordsPre;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getNewSalesQtyRecordsPost
-- Description    : This is a POST user-exit addon to the standard ReAnalyseNewSalesQtyRecords.
-- Preconditions  : Must be enabled using global variable isReAnalyzeNewSalesQtyPostUEE
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------

PROCEDURE getNewSalesQtyRecordsPost(p_contract_id      VARCHAR2,
                                    p_contract_area_id VARCHAR2,
                                    p_business_unit_id VARCHAR2,
                                    p_user             VARCHAR2,
                                    p_Rec IN OUT IFAC_SALES_QTY%ROWTYPE
                                   )
  IS
--</EC-DOC>
BEGIN
  NULL;
END getNewSalesQtyRecordsPost;
END ue_Inbound_Interface;