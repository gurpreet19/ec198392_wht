CREATE OR REPLACE PACKAGE EcDp_Defer_Loss_Accounting IS
    /****************************************************************
    ** Package        :  EcDp_Defer_Loss_Accounting
    **
    ** $Revision: 1.4 $
    **
    ** Purpose        :  This package is responsible for supporting business functions
    **                   related to Daily Facility and Field Loss Accounting.
    **
    ** Documentation  :  www.energy-components.com
    **
    ** Created  : 23.09.2010  Sarojini Rajaretnam
    **
    ** Modification history:
    **
    ** Date       Whom     Change description:
    ** ------     -------- --------------------------------------
    **09.11.2010  rajarsar ECPD-15770:Initial version
    **27.12.2010  rajarsar ECPD-16192:Updated calckBOE and updateRate
    **31.01.2011  rajarsar ECPD-16192:Added deleteChildEvent
    *****************************************************************/

    FUNCTION calcDuration(p_object_id VARCHAR2,
                          p_daytime  DATE,
                          p_end_date DATE) RETURN VARCHAR2;

    PROCEDURE populateFctyStreamRecord(p_event_no NUMBER,
                                   p_daytime  DATE DEFAULT NULL,
                                   p_end_date DATE DEFAULT NULL);

    PROCEDURE populateFldStreamRecord(p_event_no NUMBER,
                                   p_daytime  DATE DEFAULT NULL,
                                   p_end_date DATE DEFAULT NULL);

    PROCEDURE updateStreamRecord(p_event_no NUMBER,
                                 p_daytime  DATE,
                                 p_end_date DATE);

    PROCEDURE deleteStream(p_event_no NUMBER, p_daytime DATE, p_end_date DATE);

    FUNCTION calcStrmDuration(p_event_no  NUMBER,
                              p_object_id VARCHAR2,
                              p_daytime   DATE) RETURN NUMBER;

    FUNCTION calckBOE(p_event_no  NUMBER,
                     p_object_id VARCHAR2,
                     p_daytime   DATE) RETURN NUMBER;


    PROCEDURE updateStartDaytimeStreamRecord(p_event_no NUMBER,
                                 p_daytime  DATE
                                 );

    PROCEDURE verifyLossAccounting(p_event_no VARCHAR2,
                                   p_user_name VARCHAR2);

    PROCEDURE approveLossAccounting(p_event_no VARCHAR2,
                                   p_user_name VARCHAR2);

    PROCEDURE updateRate(p_event_no VARCHAR2,p_object_id VARCHAR2,p_daytime DATE,
                                   p_user_name VARCHAR2);

    PROCEDURE deleteChildEvent(p_event_no NUMBER);


END EcDp_Defer_Loss_Accounting;