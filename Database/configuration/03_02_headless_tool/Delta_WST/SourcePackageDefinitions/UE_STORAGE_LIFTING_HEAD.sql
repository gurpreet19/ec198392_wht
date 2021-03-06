CREATE OR REPLACE PACKAGE ue_storage_lifting IS

/******************************************************************************
** Package        :  UE_STORAGE_LIFTING, header part
**
** $Revision: 1.5 $
**
** Purpose        :  Includes user-exit functionality for terminal operation screens
**
** Documentation  :  www.energy-components.com
**
** Created  : 12.10.2005 Stian Skj�tad
**
** Modification history:
**
** Date        Whom     Change description:
** -------     ------   -----------------------------------------------
** 13.10.2005  skjorsti	Added function calcUnloadValue
** 12.09.2012  meisihil   ECPD-20962: Added function setBalanceDeltaQty
** -------  ------   ----- -----------------------------------------------------------------------------------------------
*/


  -- Public function and procedure declarations
FUNCTION calcExpUnload(ceu_parcel_no NUMBER, ceu_product_meas_no NUMBER) RETURN NUMBER;

PROCEDURE calcUnloadValue(cuv_parcel_no NUMBER);
PROCEDURE calcLiftedValue (clv_parcel_no NUMBER);

PROCEDURE setBalanceDeltaQty(p_parcel_no NUMBER, p_lifting_event VARCHAR2 DEFAULT 'LOAD', p_xtra_qty NUMBER DEFAULT 0);

END ue_storage_lifting;