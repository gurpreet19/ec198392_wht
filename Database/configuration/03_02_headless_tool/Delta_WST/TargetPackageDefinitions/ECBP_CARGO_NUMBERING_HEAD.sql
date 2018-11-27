CREATE OR REPLACE PACKAGE EcBp_Cargo_Numbering AS
/******************************************************************************
** Package        :  EcBp_Cargo_Numbering, header part
**
** $Revision: 1.5 $
**
** Purpose        :  License spesific package to provide cargo numbering as the customer expects in reporting
**
** Documentation  :  www.energy-components.com
**
** Created  : 06.10.2004 Kari Sandvik
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- -------------------------------------------
** #.#   DD.MM.YYYY  <initials>
********************************************************************/

FUNCTION getCargoName(p_cargo_no NUMBER, p_parcels VARCHAR2, p_daytime DATE) RETURN VARCHAR2;

END EcBp_Cargo_Numbering;