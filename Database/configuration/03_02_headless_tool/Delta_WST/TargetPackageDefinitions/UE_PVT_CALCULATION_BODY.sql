CREATE OR REPLACE PACKAGE BODY ue_pvt_calculation IS
/******************************************************************************
** Package        :  ue_pvt_calculation, body part
**
** $Revision: 1.3 $
**
** Purpose        :  Perform PVT calculation based on user specific code, raise error if not found.
**
** Documentation  :  www.energy-components.com
**
** Created        :  23.03.2006 Khew Kok Seong
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------
** 09.05.2006  hagengei	Changed calculateStdAdjValues from function to procedure, input values to handle OUT parameters and added parameter resultNo
********************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calculateStdAdjValues
-- Description    : User exit function for PVT calculation
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE calculateStdAdjValues(testNo NUMBER,
                                resultNo VARCHAR2,
                                userId VARCHAR2,
                                pressure NUMBER,
                                temperature NUMBER,
                                flcOilVolRate NUMBER,
                                flcGasVolRate NUMBER,
                                flcConVolRate NUMBER,
                                flcWatVolRate NUMBER,
                                flcOilMassRate NUMBER,
                                flcGasMassRate NUMBER,
                                flcConMassRate NUMBER,
                                flcWatMassRate NUMBER,
                                flcOilDensity NUMBER,
                                flcGasDensity NUMBER,
                                flcConDensity NUMBER,
                                flcWatDensity NUMBER,
                                stdOilVolRate OUT NUMBER,
                                stdGasVolRate OUT NUMBER,
                                stdConVolRate OUT NUMBER,
                                stdWatVolRate OUT NUMBER,
                                stdOilMassRate OUT NUMBER,
                                stdGasMassRate OUT NUMBER,
                                stdConMassRate OUT NUMBER,
                                stdWatMassRate OUT NUMBER,
                                stdOilDensity OUT NUMBER,
                                stdGasDensity OUT NUMBER,
                                stdConDensity OUT NUMBER,
                                stdWatDensity OUT NUMBER)
--</EC-DOC>
IS
BEGIN



	stdOilVolRate  := -1;
	stdGasVolRate  := -1;
	stdConVolRate  := -1;
	stdWatVolRate  := -1;
	stdOilMassRate := -1;
	stdGasMassRate := -1;
	stdConMassRate := -1;
	stdWatMassRate := -1;
	stdOilDensity  := -1;
	stdGasDensity  := -1;
	stdConDensity  := -1;
	stdWatDensity  := -1;




END calculateStdAdjValues;

END ue_pvt_calculation;