CREATE OR REPLACE PACKAGE EcBp_ProductionForecast IS
/****************************************************************
** Package        :  EcBp_ProductionForecast, header part
**
** $Revision: 1.5 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created  : 19.04.2007 Arief Zaki
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------
** 19.04.2007  zakiiari ECPD-3905: Initial version
** 21.08.2008  rajarsar ECPD-9477: Added dynCursorGetFcstScenNo and updated getRecentProdForecastNo
** 10.04.2009  oonnnng  ECPD-6067: Modufied function copyToScenarioForParent, copyFromForecastForParent
**                                 to add p_object_id for local lock checking
*****************************************************************/

TYPE rc_fcst_data IS REF CURSOR;

PROCEDURE copyToScenarioForCurrent(p_object_id           VARCHAR2,
                                   p_tgt_fcst_scen_type  VARCHAR2,
                                   p_src_fcst_scen_type  VARCHAR2,
                                   p_src_fcst_type       VARCHAR2,
                                   p_src_effective_date  DATE,
                                   p_src_fcst_scen_no    NUMBER,
                                   p_user                VARCHAR2);

PROCEDURE copyToScenarioForParent(p_parent_object_id    VARCHAR2,
                                  p_child_class         VARCHAR2,
                                  p_tgt_fcst_scen_type  VARCHAR2,
                                  p_src_fcst_scen_type  VARCHAR2,
                                  p_src_fcst_type       VARCHAR2,
                                  p_src_effective_date  DATE,
                                  p_src_fcst_scen_no    NUMBER,
                                  p_user                VARCHAR2,
                                  p_fromdate            DATE,
                                  p_todate              DATE,
                                  p_group_type          VARCHAR2,
                                  p_object_id            VARCHAR2);

PROCEDURE copyToScenarioForAll(p_tgt_fcst_scen_type  VARCHAR2,
                               p_src_fcst_scen_type  VARCHAR2,
                               p_src_fcst_type       VARCHAR2,
                               p_src_effective_date  DATE,
                               p_src_fcst_scen_no    NUMBER,
                               p_user                VARCHAR2);

PROCEDURE copyFromForecastForCurrent(p_object_id           VARCHAR2,
                                     p_src_fcst_scen_no    NUMBER,
                                     p_tgt_fcst_scen_no    NUMBER,
                                     p_tgt_effective_date  DATE,
                                     p_user                VARCHAR2);

PROCEDURE copyFromForecastForParent(p_parent_object_id     VARCHAR2,
                                    p_child_class          VARCHAR2,
                                    p_src_fcst_scen_no     NUMBER,
                                    p_tgt_fcst_scen_no     NUMBER,
                                    p_tgt_effective_date   DATE,
                                    p_user                 VARCHAR2,
                                    p_fromdate             DATE,
                                    p_todate               DATE,
                                    p_group_type           VARCHAR2,
                                    p_object_id            VARCHAR2);

PROCEDURE copyFromForecastForAll(p_src_fcst_scen_no    NUMBER,
                                 p_tgt_fcst_scen_no    NUMBER,
                                 p_tgt_effective_date  DATE,
                                 p_user                VARCHAR2);

PROCEDURE verifyCurrent( p_object_class  VARCHAR2,
                         p_object_id VARCHAR2,
                         p_fcst_scen_no NUMBER);

PROCEDURE verifyAllObject(p_parent_object_id     VARCHAR2,
                          p_child_class          VARCHAR2,
                          p_fcst_scen_no         NUMBER,
                          p_fromdate             DATE,
                          p_todate               DATE,
                          p_group_type           VARCHAR2);

PROCEDURE approveCurrent(p_obj_class              VARCHAR2,
                         p_object_id              VARCHAR2,
                         p_fcst_scen_no           NUMBER);

PROCEDURE approveAllObject(p_parent_object_id     VARCHAR2,
                           p_child_class          VARCHAR2,
                           p_fcst_scen_no         NUMBER,
                           p_fromdate             DATE,
                           p_todate               DATE,
                           p_group_type           VARCHAR2);

FUNCTION getRecentProdForecastNo(p_object_id        VARCHAR2,
                                 p_daytime          DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(getRecentProdForecastNo, WNDS, WNPS, RNPS);


PROCEDURE dynCursorGetFcstScenNo(p_crs     IN OUT rc_fcst_data,
                            p_object_id    VARCHAR2,
                            p_daytime      DATE
                            );
PRAGMA RESTRICT_REFERENCES(dynCursorGetFcstScenNo, WNDS, WNPS, RNPS);

END EcBp_ProductionForecast;