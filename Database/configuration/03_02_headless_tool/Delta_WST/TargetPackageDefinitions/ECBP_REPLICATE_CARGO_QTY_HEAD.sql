CREATE OR REPLACE PACKAGE EcBp_Replicate_Cargo_Qty IS
/******************************************************************************
** Package        :  EcBp_Replicate_Cargo_Qty, head part
**
** $Revision: 1.2 $
**
** Purpose        :  Replicate quantities from sale into ifac_quantities
**
** Documentation  :  www.energy-components.com
**
** Created  		:	09.03.2006 Kari Sandvik
**
** Modification history:
**
** Date        	Whom  			Change description:
** ------      	----- 			-----------------------------------------------------------------------------------------------
** 09.03.2006		Jean Ferré		Initial version
** 04.04.2006	Kari Sandvik	Updated**
** 07.04.2006	Arild Vervik	Added Exportparselsplit and replicateMeL, checked in redesigned package
*******************************************************************************/

PROCEDURE replicatePROD(p_DAYTIME DATE);

PROCEDURE replicateGIT(p_DAYTIME DATE);

PROCEDURE replicateLoss(p_DAYTIME DATE);

PROCEDURE replicateInv(p_DAYTIME DATE);

PROCEDURE replicateMeL(p_DAYTIME DATE);


END EcBp_Replicate_Cargo_Qty;