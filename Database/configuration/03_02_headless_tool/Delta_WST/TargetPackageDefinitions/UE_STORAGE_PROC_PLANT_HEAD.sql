CREATE OR REPLACE PACKAGE ue_storage_proc_plant IS
/****************************************************************
** Package        :  ue_storage_proc_plant; head part
**
** $Revision: 1.2 $
**
** Purpose        :  This package is used by calling from EcBp_Storage_Proc_plant when predefined functions supplied by EC does not cover the requirements.
**
** Documentation  :  www.energy-components.com
**
** Created        :  05.04.2011 Sarojini Rajaretnam
**
** Modification history:
**
** Date        Whom  	Change description:
** ----------  ----- 	-------------------------------------------
** 05.04.2011  rajarsar	ECPD-17066:Initial version
** 30.01.2012  choonshu	ECPD-18622:Added getContentDensity
*************************************************************************/

FUNCTION getStorageDayGrsOpeningVol(p_object_id storage.object_id%TYPE, p_daytime DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getStorageDayGrsOpeningVol, WNDS, WNPS, RNPS);

FUNCTION getStorageDayGrsClosingVol(p_object_id storage.object_id%TYPE, p_daytime DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getStorageDayGrsClosingVol, WNDS, WNPS, RNPS);

FUNCTION getProdDayGrsOpeningVol (
    p_object_id storage.object_id%TYPE,
    p_product_id product.object_id%TYPE,
    p_daytime   DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getProdDayGrsOpeningVol, WNDS, WNPS, RNPS);

FUNCTION getProdDayGrsClosingVol (
  p_object_id        storage.object_id%TYPE,
  p_product_id product.object_id%TYPE,
  p_daytime          DATE,
  p_to_daytime DATE DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getProdDayGrsClosingVol, WNDS, WNPS, RNPS);

FUNCTION getCompDayGrsOpeningVol (
  p_object_id        product.object_id%TYPE,
  p_company_id       company.object_id%TYPE,
  p_daytime          DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getCompDayGrsOpeningVol, WNDS, WNPS, RNPS);

FUNCTION getCompDayGrsClosingVol (
  p_object_id        product.object_id%TYPE,
  p_company_id       company.object_id%TYPE,
  p_daytime          DATE,
  p_to_daytime DATE DEFAULT NULL )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getCompDayGrsClosingVol, WNDS, WNPS, RNPS);

Procedure createGainLossTransaction(p_object_id VARCHAR2,p_daytime DATE);

Procedure createRegradeOwnship(p_event_no NUMBER);

FUNCTION getContentDensity (
  p_object_id        product.object_id%TYPE,
  p_daytime          DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getContentDensity, WNDS, WNPS, RNPS);

END ue_storage_proc_plant;