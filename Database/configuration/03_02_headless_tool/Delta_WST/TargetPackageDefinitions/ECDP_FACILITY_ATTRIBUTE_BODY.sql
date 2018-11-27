CREATE OR REPLACE PACKAGE BODY EcDp_Facility_Attribute IS

/****************************************************************
** Package        :  EcDp_Facility_Attribute, body part
**
** $Revision: 1.2 $
**
**
** Purpose        :  Definition of facility attributes
**
** Documentation  :  www.energy-components.com
**
** Created  : 13.07.2000	Ådne Bakkane
**
** Modification history:
**
** Version  Date        Whom  Change description:
** -------  ------      ----- -----------------------------------
** 4.2      20.04.01    CFS   Added new attribute types for average calculation method
** 4.3      20.06.01    GNO   Changed return values to handle db field limitiation.
** 4.4      21.06.01    GNO   Added attribute type for pre/post sample timestamp type
** 4.5		22.10.01 	GNO	Added attribute type Accept_Well_Result
** 4.6      19.03.02    DN    Added oil to storage stream.
** 4.9      2002-04-10  FBa   Added methods INTEREST_METHOD_FACILITY and .._WELL
** 4.10	    04.03.05 kaurrnar	Removed oil_stor_stream, inlet_pot_oil, inlet_pot_gas,
**				process_pot_oil, process_pot_gas, export_pot_oil and export_pot_gas function
*****************************************************************/


FUNCTION ACCEPT_WELL_RESULT
RETURN VARCHAR2 IS

BEGIN

   RETURN 'ACCEPT_WELL_RES';

END ACCEPT_WELL_RESULT;

--

FUNCTION ACCEPT_SEP_RESULT
RETURN VARCHAR2 IS

BEGIN

   RETURN 'ACCEPT_SEP_RES';

END ACCEPT_SEP_RESULT;

--

FUNCTION AVERAGE_METHOD_TYPE
RETURN VARCHAR2 IS

BEGIN

   RETURN 'AVG_METHOD';

END AVERAGE_METHOD_TYPE;

--

FUNCTION AVERAGE_RATE_METHOD_TYPE
RETURN VARCHAR2 IS

BEGIN

   RETURN 'AVG_RATE_METHOD';

END AVERAGE_RATE_METHOD_TYPE;

--

FUNCTION AVERAGE_PT_METHOD_TYPE
RETURN VARCHAR2 IS

BEGIN

   RETURN 'AVG_PT_METHOD';

END AVERAGE_PT_METHOD_TYPE;

--

FUNCTION NOM_EXPORT_OIL
RETURN VARCHAR2 IS

BEGIN

   RETURN 'NOM_EXPORT_OIL';

END NOM_EXPORT_OIL;

--

FUNCTION SAMPLE_TIMESTAMP_TYPE
RETURN VARCHAR2 IS

BEGIN

   RETURN 'TIMESTAMP_TYPE';

END SAMPLE_TIMESTAMP_TYPE;

--

FUNCTION INTEREST_METHOD_FACILITY
RETURN VARCHAR2 IS

BEGIN

	RETURN 'FCTY_ATTRIBUTE';

END INTEREST_METHOD_FACILITY;

--

FUNCTION INTEREST_METHOD_WELL
RETURN VARCHAR2 IS

BEGIN

	RETURN 'WELL';

END INTEREST_METHOD_WELL;

--



END EcDp_Facility_Attribute;