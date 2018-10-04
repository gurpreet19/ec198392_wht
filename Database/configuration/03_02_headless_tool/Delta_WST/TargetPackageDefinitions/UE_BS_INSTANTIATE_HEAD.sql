CREATE OR REPLACE PACKAGE ue_bs_instantiate IS
/******************************************************************************
** Package        :  ue_bs_instantiate, header part
**
** $Revision: 1.1 $
**
** Purpose        :  User-exit package for instantiation purposes
**
** Documentation  :  www.energy-components.com
**
** Created        : 18.07.2006
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------
** 18.07.2006	SSK  initial version (TI 3948)
********************************************************************/

PROCEDURE new_day_end               (p_daytime DATE, p_to_daytime DATE DEFAULT NULL);

END ue_bs_instantiate;