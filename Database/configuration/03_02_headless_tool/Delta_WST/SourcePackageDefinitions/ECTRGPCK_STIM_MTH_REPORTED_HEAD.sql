CREATE OR REPLACE PACKAGE EcTrgPck_stim_mth_reported IS
/****************************************************************
** Package        :  EcTrgPck_stim_mth_reported
**
** $Revision: 1.2 $
**
** Purpose        :  Provide a means to pass data between triggers to avoid mutating table state
**
** Created  : 20.01.2004  Arild Vervik
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
**
*****************************************************************/

TYPE t_rec IS RECORD (
  object_id   OBJECTS.OBJECT_ID%TYPE,
  daytime     DATE,
  production_period DATE
);


TYPE t_tab IS TABLE OF t_rec;


ptab t_tab;


END EcTrgPck_stim_mth_reported;