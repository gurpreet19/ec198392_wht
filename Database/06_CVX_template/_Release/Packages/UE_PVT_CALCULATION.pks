CREATE OR REPLACE PACKAGE ue_pvt_calculation IS
/******************************************************************************
** Package        :  ue_pvt_calculation, head part
**
** $Revision: 1.3 $
**
** Purpose        :  user exit functions should be put here
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
                                stdWatDensity OUT NUMBER);

--PRAGMA RESTRICT_REFERENCES (calculateStdAdjValues, WNDS, WNPS, RNPS);


END ue_pvt_calculation;
/