CREATE OR REPLACE PACKAGE EcBp_Contract_Analysis IS
/******************************************************************************
** Package        :  ecbp_sale_analysis, header part
**
** $Revision: 1.3 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created        : 14.10.2005 by Kristin Eide
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------
** 14.10.2005  eideekri   Initial version (first build / handover to test)
**
********************************************************************/



PROCEDURE generateAnalysisDays(
	p_delivery_point_id	VARCHAR2,
	p_daytime 		DATE,
	p_analysis_type VARCHAR2,
	p_class_name VARCHAR2,
	p_user 			VARCHAR2
);


PROCEDURE generateComp(
	p_delivery_point_id	VARCHAR2,
	p_daytime 		DATE,
	p_sampling_method VARCHAR2,
	p_analysis_type VARCHAR2,
	p_class_name VARCHAR2,
	p_user VARCHAR2
	);

PROCEDURE generateCompNP(
	p_np_id	VARCHAR2,
	p_daytime 		DATE,
	p_sampling_method VARCHAR2,
	p_analysis_type VARCHAR2,
	p_class_name VARCHAR2,
	p_user VARCHAR2
	);

PROCEDURE generateCompMeter(
	p_meter_id	VARCHAR2,
	p_daytime 		DATE,
	p_sampling_method VARCHAR2,
	p_analysis_type VARCHAR2,
	p_class_name VARCHAR2,
	p_user VARCHAR2
	);

END EcBp_Contract_Analysis;