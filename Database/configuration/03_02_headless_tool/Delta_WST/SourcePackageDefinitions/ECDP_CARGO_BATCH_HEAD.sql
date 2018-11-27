CREATE OR REPLACE PACKAGE EcDp_Cargo_Batch IS
/******************************************************************************
** Package        :  EcDp_Cargo_Batch, head part
**
** $Revision: 1.3 $
**
** Purpose        :  Handles functinality around cargo batches
**
** Created  	  :  10.01.2005 	Kari Sandvik
**
** Modification history:
**
** Date        	Whom  			Change description:
** ------      	----- 			-----------------------------------------------------------------------------------------------
** 17.07.2007   kaurrnar        ECPD5477 - Added p_lifting_event parameter to instansiate procedure
** 23.07.2007   kaurrnar        ECPD5477 - Added p_lifting_event parameter to apportionBatchQty procedure
********************************************************************************************************************************/

PROCEDURE instansiate(p_cargo_bach_no NUMBER, p_lifting_event VARCHAR2, p_user_id VARCHAR2 DEFAULT NULL);
PROCEDURE deleteBatch(p_cargo_bach_no NUMBER);
PROCEDURE apportionBatchQty(p_cargo_no NUMBER, p_lifting_event VARCHAR2, p_user_id VARCHAR2 DEFAULT NULL);

END EcDp_Cargo_Batch;