CREATE OR REPLACE PACKAGE UE_CT_WELL_RESERVOIR IS
/****************************************************************
** Package      :  UE_CT_Well_Reservoir, header part
**
** $Revision: 1.12.2.1 $
**
** Purpose      :  This package defines well/reservoir related
**                 functionality.
**
** Documentation:  www.energy-components.com
**
** Created      : 02.12.1999  Carl-Fredrik Sørensen
**
** Modification history:
**
** Version      Date            Whom    Change description:
** -------      -----------    -----------------------------------
**  1.0         24.08.2011     LBFK     First Version
**  1.1         24.01.2012     JGIH     Package modified to include only
**                   			relevant code for zonal allocation.
*****************************************************************/

FUNCTION reservoir_id(p_object_id VARCHAR2) RETURN RESV_FORMATION.OBJECT_ID%TYPE;
   
FUNCTION reservoir_code(p_object_id VARCHAR2) RETURN RESV_FORMATION.OBJECT_CODE%TYPE;

FUNCTION zone_id(p_object_id VARCHAR2) RETURN RESV_FORMATION.OBJECT_ID%TYPE;
   
FUNCTION zone_code(p_object_id VARCHAR2) RETURN RESV_FORMATION.OBJECT_CODE%TYPE;

END;
/

