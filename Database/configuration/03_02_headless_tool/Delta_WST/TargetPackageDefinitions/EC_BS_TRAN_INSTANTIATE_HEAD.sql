CREATE OR REPLACE PACKAGE Ec_Bs_Tran_Instantiate IS
/***********************************************************************************************************************************************
** Package        :  Ec_Bs_Tran_Instantiate, header part
**
** $Revision: 1.1.82.2 $
**
** Purpose        :  Instantiate records in EC Tran data tables.
**
** Created        :  24.03.2006  Kristin Eide
**
** Documentation  :  www.energy-components.com
**
** Short how-to:
**	Create an instantiate procedure for the table(s) you want to instantiate. In this procedure
**	create a cursor that finds the primary keys for those tables you want to instantiate.
**	Loop this cursor and insert records for the daytime(s) taken as parameter.
**	Add the created procedure to the for loop in new_day_end.
**
** Modification history:
**
** Date        Whom  			Change description:
** ------      ----- 			-----------------------------------------------------------------------------------------------
** 24.03.2006  eideekri   		Initial version
** 14.08.2013  leeeewei			Added procedure i_contract_seasonality
************************************************************************************************************************************/


PROCEDURE new_day_end(
p_daytime DATE, p_to_daytime DATE DEFAULT NULL);

--
PROCEDURE i_dp_sub_day_target(p_daytime DATE);

--
PROCEDURE newMonth(p_daytime DATE);

--
PROCEDURE i_contract_inventory_day(p_daytime DATE);

--
PROCEDURE i_contract_inventory_mth(P_daytime DATE);

--
PROCEDURE i_contract_seasonality(p_daytime DATE);

END Ec_Bs_Tran_Instantiate;