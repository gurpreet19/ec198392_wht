CREATE OR REPLACE PACKAGE ue_Balancing IS
/******************************************************************************
** Package        :  ue_Balancing, head part
**
** $Revision:
**
** Purpose        :
**
** Documentation  :
**
** Created        :  10.02.2016 Mawaddah
**
** Modification history:
**
** Date        Whom        Change description:
** ------      --------    -----------------------------------------------------------------------------------------------
** 10-02-16    abdulmaw    Initial Version
********************************************************************/

PROCEDURE validateBalancingAdj(
	p_product_group_id VARCHAR2,
	p_product_id       VARCHAR2,
	p_strm_bal_category VARCHAR2,
	p_stream_id		   VARCHAR2,
	p_from_object_type VARCHAR2,
	p_from_object_id   VARCHAR2,
	p_to_object_type   VARCHAR2,
	p_to_object_id     VARCHAR2,
	ue_flag OUT CHAR);

END ue_Balancing;