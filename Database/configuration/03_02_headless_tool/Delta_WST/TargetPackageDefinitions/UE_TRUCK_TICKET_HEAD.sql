CREATE OR REPLACE PACKAGE Ue_Truck_Ticket IS

/****************************************************************
** Package        :  Ue_Truck_Ticket; head part
**
** $Revision: 1.1 $
**
** Purpose        :  This package is responsible for project specific extensions directly related
**                   to truck ticket operations, consisting of single transfer and
**                   stream-to/from-well transfer events.
**
** Documentation  :  www.energy-components.com
**
** Created        :  09.12.2009  Irlene Fincaryk
**
** Modification history:
**
** Version  Date        Whom         Change description:
** -------  ----------  --------     --------------------------------------
** 1.0      09.12.2009  fincairl     First version
*****************************************************************/

PROCEDURE prorateTruckedWellProd(
     p_startdate    DATE,
     p_end_date     DATE,
     p_facility_id  VARCHAR2);

PROCEDURE prorateTruckedWellLoadOil(
     p_facility_id  VARCHAR2,
     p_startday     DATE,
     p_endday      DATE);

END;