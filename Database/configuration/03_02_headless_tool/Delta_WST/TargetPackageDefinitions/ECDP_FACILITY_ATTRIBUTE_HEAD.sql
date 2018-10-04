CREATE OR REPLACE PACKAGE EcDp_Facility_Attribute IS
/****************************************************************
** Package        :  EcDp_Facility_Attribute, header part
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
** 4.3      21.06.01    GNO   Added attribute type for pre/post sample timestamp type
** 4.4      22.10.01 	GNO	Added new attribute type for automatic accept of well result
** 4.5      19.03.02    DN    Added oil to storage stream.
** 4.9      2002-04-10  FBa   Added methods INTEREST_METHOD_FACILITY and .._WELL
** 4.10	    04.03.05 kaurrnar	Removed oil_stor_stream, inlet_pot_oil, inlet_pot_gas,
**				process_pot_oil, process_pot_gas, export_pot_oil and export_pot_gas function
*****************************************************************/

FUNCTION ACCEPT_WELL_RESULT
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(ACCEPT_WELL_RESULT, WNDS, WNPS, RNPS);

--
FUNCTION ACCEPT_SEP_RESULT
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(ACCEPT_SEP_RESULT, WNDS, WNPS, RNPS);

--

FUNCTION AVERAGE_METHOD_TYPE
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(AVERAGE_METHOD_TYPE, WNDS, WNPS, RNPS);

--

FUNCTION AVERAGE_RATE_METHOD_TYPE
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(AVERAGE_RATE_METHOD_TYPE, WNDS, WNPS, RNPS);

--

FUNCTION AVERAGE_PT_METHOD_TYPE
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(AVERAGE_PT_METHOD_TYPE, WNDS, WNPS, RNPS);

--

FUNCTION NOM_EXPORT_OIL
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(NOM_EXPORT_OIL, WNDS, WNPS, RNPS);

--

FUNCTION SAMPLE_TIMESTAMP_TYPE
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(SAMPLE_TIMESTAMP_TYPE, WNDS, WNPS, RNPS);

--

FUNCTION INTEREST_METHOD_FACILITY
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(INTEREST_METHOD_FACILITY, WNDS, WNPS, RNPS);

FUNCTION INTEREST_METHOD_WELL
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(INTEREST_METHOD_WELL, WNDS, WNPS, RNPS);


END;