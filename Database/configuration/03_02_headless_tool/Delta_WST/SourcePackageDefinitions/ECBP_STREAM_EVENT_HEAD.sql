CREATE OR REPLACE PACKAGE EcBp_Stream_Event IS
/****************************************************************
** Package        :  EcBp_Stream_Event; head part
**
** $Revision: 1.15 $
**
** Purpose        :  Stream event handler
**
** Documentation  :  www.energy-components.com
**
** Created        :  10/28/2004,  TAIPUTOH
**
** Modification history:
**
** Date        Whom      Change description:
** ----------  -------   -------------------------------------------
** 28.10.2004  Toha      Initial Version
** 23.11.2004  DN        Renamed files, formatted code and documentation according to standard.
** 07.07.2005  Jerome    Added procedure setStrmSwapEndDate
** 13.07.2005  Darren    Added procedure setStrmFactorEndDate
** 14.07.2005  Darren    Modification on procedure setStrmFactorEndDate
** 16.08.2005  Jerome    Added procedure swap_instantiate
** 13.02.2006  Jerome    Updated setStrmSwapEndDate
** 27.02.2007  zakiiari  ECPD#3649: Updated validatePeriod to include p_within_mth parameter. Added approvePeriod and verifyPeriod
** 19.03.2007  Lau       ECPD#2026: Added validatePeriodTotalizer, approvePeriodTotalizer and verifyPeriodTotalizer
** 26.03.2007  Lau       ECPD#2026: Added validateTotalizerMax
** 28.09.2007  rajarsar  ECPD#6052: Updated swap_instantiate.
** 21.01.2008  aliassit  ECPD#7291: Modify validatePeriodTotalizer by adding p_event_type
** 29.04.2009  leongsei  ECPD#11581: Added checkStreamEventLock
**************************************************************************************************/

PROCEDURE validatePeriod(p_object_id stream.object_id%TYPE,
                         p_daytime DATE,
                         p_end_date DATE,
                         p_within_mth CHAR DEFAULT 'YES')
;

PROCEDURE validatePeriodTotalizer(p_object_id stream.object_id%TYPE,
						 p_event_type VARCHAR2,
                         p_daytime DATE,
                         p_end_date DATE
                        )
;

PROCEDURE setStrmSwapEndDate(p_object_id VARCHAR2, p_company_id VARCHAR2, p_start_date DATE, p_end_date DATE);

PROCEDURE setStrmFactorEndDate(p_object_id VARCHAR2, p_daytime DATE, p_end_date DATE, p_company_id VARCHAR2);

PROCEDURE swap_instantiate(p_object_id VARCHAR2, p_company_id VARCHAR2, p_daytime DATE);

PROCEDURE swap_delete(p_swap_no NUMBER);

PROCEDURE approvePeriod(p_object_id stream.object_id%TYPE,
                         p_daytime DATE,
                         p_end_date DATE);

PROCEDURE verifyPeriod(p_object_id stream.object_id%TYPE,
                         p_daytime DATE,
                         p_end_date DATE);

PROCEDURE approvePeriodTotalizer(p_object_id stream.object_id%TYPE,
                         p_daytime DATE,
                         p_end_date DATE,
                         p_user VARCHAR2);

PROCEDURE verifyPeriodTotalizer(p_object_id stream.object_id%TYPE,
                         p_daytime DATE,
                         p_end_date DATE,
                         p_user VARCHAR2);

PROCEDURE validateTotalizerMax(p_object_id stream.object_id%TYPE,
                               p_daytime DATE,
                               p_overwrite NUMBER,
                               p_closing NUMBER);

PROCEDURE checkStreamEventLock(p_object_id VARCHAR2, p_event_type VARCHAR2, p_daytime DATE, p_class_name VARCHAR2);

END EcBp_Stream_Event;