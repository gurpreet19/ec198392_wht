CREATE OR REPLACE PACKAGE Ec_Bs_Sale_Instantiate IS
/***********************************************************************************************************************************************
** Package        :  Ec_Bs_Sale_Instantiate, header part
**
** $Revision: 1.4 $
**
** Purpose        :  Instantiate records in EC Sale data tables.
**
** Created        :  15.12.2004  Tor-Erik Hauge
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
** Date        Whom  		Change description:
** ------      ----- 		-----------------------------------------------------------------------------------------------
** 22.12.2004  BIH   		Initial version (first build / handover to test)
** 11.01.2005  BIH   		Added / cleaned up documentation
** 11.01.2006  ssk	 		Added procedure i_wet_gas_hourly_profile for instantiation of wet gas hourly profile
** 29.10.2013  muhammah		ECPD-25120: Added procedure i_period_sales_nom_comment
** 10.03.2014  farhaann		ECPD-26250: Added procedure priceRateMth and priceRateDay
************************************************************************************************************************************/

PROCEDURE new_day_end(p_daytime DATE, p_to_daytime DATE DEFAULT NULL);
PROCEDURE i_gscontr_day_del(p_daytime DATE);
PROCEDURE i_gscontr_mth_del(p_daytime DATE);
PROCEDURE i_scontr_per_status(p_daytime DATE);
PROCEDURE i_wet_gas_hourly_profile(p_daytime DATE);
PROCEDURE newMonth(p_daytime DATE);
PROCEDURE priceIndexMth(p_daytime DATE);
PROCEDURE priceIndexDay	(p_daytime DATE);
PROCEDURE i_wet_gas_export_fuel(p_daytime DATE);
PROCEDURE i_ngl_export(p_daytime DATE);
PROCEDURE i_expenditure(p_daytime DATE);
PROCEDURE i_period_sales_nom_comment(p_daytime DATE);
PROCEDURE priceRateMth(p_daytime DATE);
PROCEDURE priceRateDay(p_daytime DATE);
--
END Ec_Bs_Sale_Instantiate;