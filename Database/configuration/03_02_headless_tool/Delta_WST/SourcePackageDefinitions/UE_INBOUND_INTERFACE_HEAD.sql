CREATE OR REPLACE package ue_Inbound_Interface IS
/****************************************************************
**
** NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE
** NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE

** Enable this User Exit by setting variables below to 'TRUE'

** NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE
** NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE
**
** Package        :  ue_Inbound_Interface, header part
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
************************************************************************/

-- Enabling User Exits for EcDp_Inbound_Interface.TransferQuantitiesRecord
isTransferQtyRecordUEE  VARCHAR2(32) := 'FALSE'; -- Instead of
isTransferQtyRecPreUEE  VARCHAR2(32) := 'FALSE'; -- Pre
isTransferQtyRecPostUEE VARCHAR2(32) := 'FALSE'; -- Post

-- Enabling User Exits for EcDp_Inbound_Interface.ReceiveCargoQtyRecord
isReceiveCargoQtyRecordUEE  VARCHAR2(32) := 'FALSE'; -- Instead of
isReceiveCargoQtyRecPreUEE  VARCHAR2(32) := 'FALSE'; -- Pre
isReceiveCargoQtyRecPostUEE VARCHAR2(32) := 'FALSE'; -- Post

-- Enabling User Exits for EcDp_Inbound_Interface.ReceiveSalesQtyRecord
isReceiveSalesQtyRecordUEE  VARCHAR2(32) := 'FALSE'; -- Instead of
isReceiveSalesQtyRecPreUEE  VARCHAR2(32) := 'FALSE'; -- Pre
isReceiveSalesQtyRecPostUEE VARCHAR2(32) := 'FALSE'; -- Post

-- Enabling User Exits for EcDp_Inbound_Interface.ReceiveIfacDocRecord
isReceiveIfacDocRecordUEE  VARCHAR2(32) := 'FALSE'; -- Instead of
isReceiveIfacDocRecPreUEE  VARCHAR2(32) := 'FALSE'; -- Pre
isReceiveIfacDocRecPostUEE VARCHAR2(32) := 'FALSE'; -- Post

-- Enabling User Exits for EcDp_Inbound_Interface.ReceiveERPPostingRecord
isReceiveERPPostRecordUEE  VARCHAR2(32) := 'FALSE'; -- Instead of
isReceiveERPPostRecPreUEE  VARCHAR2(32) := 'FALSE'; -- Pre
isReceiveERPPostRecPostUEE VARCHAR2(32) := 'FALSE'; -- Post

-- Enabling User Exits for EcDp_Inbound_Interface.GetPeriodQtyStatus
isGetPeriodQtyStatusUEE     VARCHAR2(32) := 'FALSE'; -- Instead of
isGetPeriodQtyStatusPreUEE  VARCHAR2(32) := 'FALSE'; -- Pre
isGetPeriodQtyStatusPostUEE VARCHAR2(32) := 'FALSE'; -- Post

-- Enabling User Exits for EcDp_Inbound_Interface.ReAnalyseNewCargoRecords
isReAnalyseNewCargoRecUEE     VARCHAR2(32) := 'FALSE'; -- Instead of
isReAnalyzeNewCargoRecPreUEE  VARCHAR2(32) := 'FALSE'; -- Pre
isReAnalyzeNewCargoRecPostUEE VARCHAR2(32) := 'FALSE'; -- Post


-- Enabling User Exits for EcDp_Inbound_Interface.ReAnalyseNewSalesQtyRecords
isReAnalyseNewSalesQtyUEE     VARCHAR2(32) := 'FALSE'; -- Instead of
isReAnalyzeNewSalesQtyPreUEE  VARCHAR2(32) := 'FALSE'; -- Pre
isReAnalyzeNewSalesQtyPostUEE VARCHAR2(32) := 'FALSE'; -- Post

-----------------------------------------------------------------------------------------------------------------------------
-- User Exit Set for EcDp_Inbound_Interface.TransferQuantitiesRecord

FUNCTION TransferQuantitiesRecord(p_Rec     IFAC_QTY%ROWTYPE,
                                  p_user    VARCHAR2,
                                  p_daytime DATE DEFAULT SYSDATE -- run time
                                  ) RETURN VARCHAR2;

FUNCTION TransferQuantitiesRecordPre(p_Rec    IFAC_QTY%ROWTYPE,
                                    p_user    VARCHAR2,
                                    p_daytime DATE DEFAULT sysdate, -- run time
                                    p_status  VARCHAR2
                                    ) RETURN VARCHAR2;

FUNCTION TransferQuantitiesRecordPost(p_Rec    IFAC_QTY%ROWTYPE,
                                     p_user    VARCHAR2,
                                     p_daytime DATE DEFAULT sysdate, -- run time
                                     p_status  VARCHAR2
                                     ) RETURN VARCHAR2;

-----------------------------------------------------------------------------------------------------------------------------
-- User Exit Set for EcDp_Inbound_Interface.ReceiveCargoQtyRecord:

PROCEDURE ReceiveCargoQtyRecord(p_Rec     IFAC_CARGO_VALUE%ROWTYPE,
                                p_user    VARCHAR2,
                                p_daytime DATE DEFAULT SYSDATE);

PROCEDURE ReceiveCargoQtyRecordPre(p_Rec     IN OUT IFAC_CARGO_VALUE%ROWTYPE,
                                   p_user    VARCHAR2,
                                   p_daytime DATE DEFAULT SYSDATE);

PROCEDURE ReceiveCargoQtyRecordPost(p_Rec     IN OUT IFAC_CARGO_VALUE%ROWTYPE,
                                    p_user    VARCHAR2,
                                    p_daytime DATE DEFAULT SYSDATE);

-----------------------------------------------------------------------------------------------------------------------------
-- User Exit Set for EcDp_Inbound_Interface.ReceiveSalesQtyRecord:

PROCEDURE ReceiveSalesQtyRecord(p_Rec       IFAC_SALES_QTY%ROWTYPE,
                                p_user      VARCHAR2,
                                p_daytime   DATE DEFAULT SYSDATE);

PROCEDURE ReceiveSalesQtyRecordPre(p_Rec       IN OUT IFAC_SALES_QTY%ROWTYPE,
                                   p_user      VARCHAR2,
                                   p_daytime   DATE DEFAULT SYSDATE);

PROCEDURE ReceiveSalesQtyRecordPost(p_Rec       IN OUT IFAC_SALES_QTY%ROWTYPE,
                                    p_user      VARCHAR2,
                                    p_daytime   DATE DEFAULT SYSDATE);

-----------------------------------------------------------------------------------------------------------------------------
-- User Exit Set for EcDp_Inbound_Interface.ReceiveIfacDocRecord:

PROCEDURE ReceiveIfacDocRecord(p_Rec     IFAC_DOCUMENT%ROWTYPE,
                               p_user    VARCHAR2,
                               p_daytime DATE DEFAULT SYSDATE);

PROCEDURE ReceiveIfacDocRecordPre(p_Rec     IN OUT IFAC_DOCUMENT%ROWTYPE,
                                  p_user    VARCHAR2,
                                  p_daytime DATE DEFAULT SYSDATE);

PROCEDURE ReceiveIfacDocRecordPost(p_Rec     IN OUT IFAC_DOCUMENT%ROWTYPE,
                                   p_user    VARCHAR2,
                                   p_daytime DATE DEFAULT SYSDATE);

-----------------------------------------------------------------------------------------------------------------------------
-- User Exit Set for EcDp_Inbound_Interface.ReceiveERPPostingRecord:

PROCEDURE ReceiveERPPostingRecord(p_Rec     IFAC_ERP_POSTINGS%ROWTYPE,
                                  p_user    VARCHAR2,
                                  p_daytime DATE DEFAULT SYSDATE);

PROCEDURE ReceiveERPPostingRecordPre(p_Rec     IN OUT IFAC_ERP_POSTINGS%ROWTYPE,
                                     p_user    VARCHAR2,
                                     p_daytime DATE DEFAULT SYSDATE);

PROCEDURE ReceiveERPPostingRecordPost(p_Rec     IN OUT IFAC_ERP_POSTINGS%ROWTYPE,
                                      p_user    VARCHAR2,
                                      p_daytime DATE DEFAULT SYSDATE);

-----------------------------------------------------------------------------------------------------------------------------
-- User Exit Set for EcDp_Inbound_Interface.ReceiveERPPostingRecord:
PROCEDURE getPeriodQtyStatus(isqRec IN OUT ifac_sales_qty%ROWTYPE);
PROCEDURE getPeriodQtyStatusPre(isqRec IN OUT ifac_sales_qty%ROWTYPE);
PROCEDURE getPeriodQtyStatusPost(isqRec IN OUT ifac_sales_qty%ROWTYPE);

-----------------------------------------------------------------------------------------------------------------------------
-- User Exit Set for EcDp_Inbound_Interface.ReAnalyseNewCargoRecords:
PROCEDURE getNewCargoRecords(p_contract_id      VARCHAR2,
                             p_contract_area_id VARCHAR2,
                             p_business_unit_id VARCHAR2,
                             p_user             VARCHAR2  );

PROCEDURE getNewCargoRecordsPre(p_contract_id      VARCHAR2,
                                p_contract_area_id VARCHAR2,
                                p_business_unit_id VARCHAR2,
                                p_user             VARCHAR2  );

PROCEDURE getNewCargoRecordsPost(p_contract_id      VARCHAR2,
                                 p_contract_area_id VARCHAR2,
                                 p_business_unit_id VARCHAR2,
                                 p_user             VARCHAR2,
                                 p_Rec IN OUT IFAC_CARGO_VALUE%ROWTYPE);

-----------------------------------------------------------------------------------------------------------------------------
-- User Exit Set for EcDp_Inbound_Interface.ReAnalyseNewSalesQtyRecords:
PROCEDURE getNewSalesQtyRecords(p_contract_id      VARCHAR2,
                                p_contract_area_id VARCHAR2,
                                p_business_unit_id VARCHAR2,
                                p_user             VARCHAR2  );

PROCEDURE getNewSalesQtyRecordsPre(p_contract_id      VARCHAR2,
                                   p_contract_area_id VARCHAR2,
                                   p_business_unit_id VARCHAR2,
                                   p_user             VARCHAR2  );

PROCEDURE getNewSalesQtyRecordsPost(p_contract_id      VARCHAR2,
                                    p_contract_area_id VARCHAR2,
                                    p_business_unit_id VARCHAR2,
                                    p_user             VARCHAR2,
                                    p_Rec IN OUT IFAC_SALES_QTY%ROWTYPE);

-----------------------------------------------------------------------------------------------------------------------------
end ue_Inbound_Interface;