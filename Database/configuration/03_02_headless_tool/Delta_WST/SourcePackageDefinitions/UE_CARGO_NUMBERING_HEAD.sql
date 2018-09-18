CREATE OR REPLACE PACKAGE ue_Cargo_Numbering AS
/******************************************************************************
** Package        :  ue_Cargo_Numbering, header part
**
** $Revision: 1.1 $
**
** Purpose        :  License spesific package to provide cargo numbering as the customer expects in reporting
**
** Documentation  :  www.energy-components.com
**
** Created  : 27.03.2013 Lee Wei Yap
**
** Modification history:
**
** Version  Date     	Whom  		Change description:
** -------  ------   	----- 		-------------------------------------------
** 1.1   	27.03.2013  leeeewei    Renamed ecbp_cargo_numbering to ue_cargo_numbering
********************************************************************/

FUNCTION getCargoName(p_cargo_no NUMBER, p_parcels VARCHAR2, p_daytime DATE,p_forecast_id VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

END ue_Cargo_Numbering;