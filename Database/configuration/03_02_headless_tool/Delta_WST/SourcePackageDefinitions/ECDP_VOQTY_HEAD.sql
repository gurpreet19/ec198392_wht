CREATE OR REPLACE PACKAGE EcDp_VOQty IS
/****************************************************************
** Package        :  EcDp_VOQty, header part
**
** $Revision: 1.10 $
**
** Purpose        :  Provide functionality to replace to original VO qtys when needed
**
** Documentation  :  www.energy-components.com
**
** Created  : 20.01.2004  Trond-Arne Brattli
**
** Modification history:
**
** Date        Whom  Change description:
** ----------  ----- --------------------------------------
** 13.12.2006  DN    Removed document_key column. Added documentation header.
** 21.12.2006  DN    Re-defined primary key in cont_qty_stim_mth_value table.
*****************************************************************/

PROCEDURE StoreVOQty(
          p_object_id VARCHAR2,
          p_transaction_id VARCHAR2,
          p_stream_item_id VARCHAR2,
          p_transaction_date DATE,
          p_user VARCHAR2
);

PROCEDURE ReStoreVOQty (
          p_object_id VARCHAR2,
          p_transaction_id VARCHAR2,
          p_stream_item_id VARCHAR2,
          p_transaction_date DATE,
          p_user VARCHAR2
);

PROCEDURE CleanUp (
          p_stream_item_id VARCHAR2,
          p_daytime DATE,
          p_object_id VARCHAR2 DEFAULT NULL,
          p_transaction_id VARCHAR2 DEFAULT NULL
);

END EcDp_VOQty;