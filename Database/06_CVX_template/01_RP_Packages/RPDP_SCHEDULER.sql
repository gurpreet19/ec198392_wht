
 -- START PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.45.57 AM


CREATE or REPLACE PACKAGE RPDP_SCHEDULER
IS

   FUNCTION CRONPARTDOW(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CRONPARTHOUR(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CRONPARTMONDAY(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CRONPARTMONTHLYDAY(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CRONPARTSYNTAXMONTH(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CRONPARTTUESDAY(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CRONPARTYEARLYDAY(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION ISTRIGGERENABLED(
      NAME IN VARCHAR2,
      SGROUP IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION QUARTLONGTIMETOECDATE(
      LONGTIME IN NUMBER)
      RETURN DATE;
   FUNCTION READYTORUN(
      P_SHCEDULE_NO IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION CRONPART(
      CRONEXPRESSION IN VARCHAR2,
      PART IN INTEGER )
      RETURN VARCHAR2;
   FUNCTION CRONPARTFRIDAY(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CRONPARTSUBDAILYHOUR(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CRONPARTSYNTAXHOUR(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CRONPARTSYNTAXMONDAY(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CRONPARTSYNTAXTUESDAY(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION ISJOBSTATEFUL(
      NAME IN VARCHAR2,
      SGROUP IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TRIGGERDESCRIPTION(
      NAME IN VARCHAR2,
      SGROUP IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CRONPARTDAILYOP1(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CRONPARTDOM(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CRONPARTDOMDAY(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CRONPARTSATURDAY(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CRONPARTSUBDAILYMIN(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CRONPARTSYNTAXFRIDAY(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CRONPARTSYNTAXMIN(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CRONPARTSYNTAXNTHWEEK(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CRONPARTSYNTAXSUNDAY(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CRONPARTYEARLYMONTHRECURRING(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETPINNEDTONODE
      RETURN VARCHAR2;
   FUNCTION SCHEDULETYPE(
      CRON IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CRONEXPRESSIONSYNTAX(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CRONPARTMONTHLYOP1(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CRONPARTNTHWEEK(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CRONPARTSUBDAILYOP2(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CRONPARTWEDNESDAY(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CRONPARTYEAR(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CRONPARTYEARLYOP2(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION DATETOECDATE(
      THEDATE IN DATE)
      RETURN DATE;
   FUNCTION ISJOBEXECUTING(
      NAME IN VARCHAR2,
      SGROUP IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CRONPARTMIN(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CRONPARTMONTHLYDAYRECURRING(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CRONPARTSUNDAY(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CRONPARTSYNTAXDOM(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CRONPARTSYNTAXSATURDAY(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CRONPARTSYNTAXTHURSDAY(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CRONPARTYEARLYDAYRECURRING(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CRONPARTYEARLYOP1(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION GETUNIQUENAME(
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION QUARTLONGTIMETODATE(
      LONGTIME IN NUMBER)
      RETURN DATE;
   FUNCTION TRIGGERCRONEXPRESSION(
      NAME IN VARCHAR2,
      SGROUP IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TRIGGERENDDATE(
      NAME IN VARCHAR2,
      SGROUP IN VARCHAR2)
      RETURN DATE;
   FUNCTION CRONPARTMONTH(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CRONPARTMONTHLYEVERYMONTHOP2(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CRONPARTMONTHLYWEEKDAY(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CRONPARTSEC(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CRONPARTSYNTAXWEDNESDAY(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CRONPARTTHURSDAY(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TRIGGERNEXTFIRETIME(
      NAME IN VARCHAR2,
      SGROUP IN VARCHAR2)
      RETURN DATE;
   FUNCTION TRIGGERSCHEDULETYPE(
      NAME IN VARCHAR2,
      SGROUP IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION TRIGGERSTARTDATE(
      NAME IN VARCHAR2,
      SGROUP IN VARCHAR2)
      RETURN DATE;
   FUNCTION TRIGGERSTATUS(
      NAME IN VARCHAR2,
      SGROUP IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CRONPARTSYNTAXDOW(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CRONPARTDAILYOP2(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CRONPARTMONTHLYEVERYMONTH(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CRONPARTMONTHLYOP2(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CRONPARTSUBDAILYOP1(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION CRONPARTYEARLYWEEKDAY(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION STATUSORPINSTATUS(
      SNAME IN VARCHAR2,
      SGROUP IN VARCHAR2,
      REALSTATUS IN VARCHAR2)
      RETURN VARCHAR2;

END RPDP_SCHEDULER;

/



CREATE or REPLACE PACKAGE BODY RPDP_SCHEDULER
IS

   FUNCTION CRONPARTDOW(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTDOW      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTDOW;
   FUNCTION CRONPARTHOUR(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTHOUR      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTHOUR;
   FUNCTION CRONPARTMONDAY(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTMONDAY      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTMONDAY;
   FUNCTION CRONPARTMONTHLYDAY(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTMONTHLYDAY      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTMONTHLYDAY;
   FUNCTION CRONPARTSYNTAXMONTH(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTSYNTAXMONTH      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTSYNTAXMONTH;
   FUNCTION CRONPARTTUESDAY(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTTUESDAY      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTTUESDAY;
   FUNCTION CRONPARTYEARLYDAY(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTYEARLYDAY      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTYEARLYDAY;
   FUNCTION ISTRIGGERENABLED(
      NAME IN VARCHAR2,
      SGROUP IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.ISTRIGGERENABLED      (
         NAME,
         SGROUP );
         RETURN ret_value;
   END ISTRIGGERENABLED;
   FUNCTION QUARTLONGTIMETOECDATE(
      LONGTIME IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_SCHEDULER.QUARTLONGTIMETOECDATE      (
         LONGTIME );
         RETURN ret_value;
   END QUARTLONGTIMETOECDATE;
   FUNCTION READYTORUN(
      P_SHCEDULE_NO IN NUMBER)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.READYTORUN      (
         P_SHCEDULE_NO );
         RETURN ret_value;
   END READYTORUN;
   FUNCTION CRONPART(
      CRONEXPRESSION IN VARCHAR2,
      PART IN INTEGER )
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPART      (
         CRONEXPRESSION,
         PART );
         RETURN ret_value;
   END CRONPART;
   FUNCTION CRONPARTFRIDAY(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTFRIDAY      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTFRIDAY;
   FUNCTION CRONPARTSUBDAILYHOUR(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTSUBDAILYHOUR      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTSUBDAILYHOUR;
   FUNCTION CRONPARTSYNTAXHOUR(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTSYNTAXHOUR      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTSYNTAXHOUR;
   FUNCTION CRONPARTSYNTAXMONDAY(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTSYNTAXMONDAY      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTSYNTAXMONDAY;
   FUNCTION CRONPARTSYNTAXTUESDAY(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTSYNTAXTUESDAY      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTSYNTAXTUESDAY;
   FUNCTION ISJOBSTATEFUL(
      NAME IN VARCHAR2,
      SGROUP IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.ISJOBSTATEFUL      (
         NAME,
         SGROUP );
         RETURN ret_value;
   END ISJOBSTATEFUL;
   FUNCTION TRIGGERDESCRIPTION(
      NAME IN VARCHAR2,
      SGROUP IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.TRIGGERDESCRIPTION      (
         NAME,
         SGROUP );
         RETURN ret_value;
   END TRIGGERDESCRIPTION;
   FUNCTION CRONPARTDAILYOP1(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTDAILYOP1      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTDAILYOP1;
   FUNCTION CRONPARTDOM(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTDOM      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTDOM;
   FUNCTION CRONPARTDOMDAY(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTDOMDAY      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTDOMDAY;
   FUNCTION CRONPARTSATURDAY(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTSATURDAY      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTSATURDAY;
   FUNCTION CRONPARTSUBDAILYMIN(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTSUBDAILYMIN      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTSUBDAILYMIN;
   FUNCTION CRONPARTSYNTAXFRIDAY(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTSYNTAXFRIDAY      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTSYNTAXFRIDAY;
   FUNCTION CRONPARTSYNTAXMIN(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTSYNTAXMIN      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTSYNTAXMIN;
   FUNCTION CRONPARTSYNTAXNTHWEEK(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTSYNTAXNTHWEEK      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTSYNTAXNTHWEEK;
   FUNCTION CRONPARTSYNTAXSUNDAY(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTSYNTAXSUNDAY      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTSYNTAXSUNDAY;
   FUNCTION CRONPARTYEARLYMONTHRECURRING(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTYEARLYMONTHRECURRING      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTYEARLYMONTHRECURRING;
   FUNCTION GETPINNEDTONODE
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN

         ret_value := ECDP_SCHEDULER.GETPINNEDTONODE ;
         RETURN ret_value;
   END GETPINNEDTONODE;
   FUNCTION SCHEDULETYPE(
      CRON IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.SCHEDULETYPE      (
         CRON );
         RETURN ret_value;
   END SCHEDULETYPE;
   FUNCTION CRONEXPRESSIONSYNTAX(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONEXPRESSIONSYNTAX      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONEXPRESSIONSYNTAX;
   FUNCTION CRONPARTMONTHLYOP1(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTMONTHLYOP1      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTMONTHLYOP1;
   FUNCTION CRONPARTNTHWEEK(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTNTHWEEK      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTNTHWEEK;
   FUNCTION CRONPARTSUBDAILYOP2(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTSUBDAILYOP2      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTSUBDAILYOP2;
   FUNCTION CRONPARTWEDNESDAY(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTWEDNESDAY      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTWEDNESDAY;
   FUNCTION CRONPARTYEAR(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTYEAR      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTYEAR;
   FUNCTION CRONPARTYEARLYOP2(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTYEARLYOP2      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTYEARLYOP2;
   FUNCTION DATETOECDATE(
      THEDATE IN DATE)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_SCHEDULER.DATETOECDATE      (
         THEDATE );
         RETURN ret_value;
   END DATETOECDATE;
   FUNCTION ISJOBEXECUTING(
      NAME IN VARCHAR2,
      SGROUP IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.ISJOBEXECUTING      (
         NAME,
         SGROUP );
         RETURN ret_value;
   END ISJOBEXECUTING;
   FUNCTION CRONPARTMIN(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTMIN      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTMIN;
   FUNCTION CRONPARTMONTHLYDAYRECURRING(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTMONTHLYDAYRECURRING      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTMONTHLYDAYRECURRING;
   FUNCTION CRONPARTSUNDAY(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTSUNDAY      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTSUNDAY;
   FUNCTION CRONPARTSYNTAXDOM(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTSYNTAXDOM      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTSYNTAXDOM;
   FUNCTION CRONPARTSYNTAXSATURDAY(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTSYNTAXSATURDAY      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTSYNTAXSATURDAY;
   FUNCTION CRONPARTSYNTAXTHURSDAY(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTSYNTAXTHURSDAY      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTSYNTAXTHURSDAY;
   FUNCTION CRONPARTYEARLYDAYRECURRING(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTYEARLYDAYRECURRING      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTYEARLYDAYRECURRING;
   FUNCTION CRONPARTYEARLYOP1(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTYEARLYOP1      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTYEARLYOP1;
   FUNCTION GETUNIQUENAME(
      P_NAME IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.GETUNIQUENAME      (
         P_NAME );
         RETURN ret_value;
   END GETUNIQUENAME;
   FUNCTION QUARTLONGTIMETODATE(
      LONGTIME IN NUMBER)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_SCHEDULER.QUARTLONGTIMETODATE      (
         LONGTIME );
         RETURN ret_value;
   END QUARTLONGTIMETODATE;
   FUNCTION TRIGGERCRONEXPRESSION(
      NAME IN VARCHAR2,
      SGROUP IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.TRIGGERCRONEXPRESSION      (
         NAME,
         SGROUP );
         RETURN ret_value;
   END TRIGGERCRONEXPRESSION;
   FUNCTION TRIGGERENDDATE(
      NAME IN VARCHAR2,
      SGROUP IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_SCHEDULER.TRIGGERENDDATE      (
         NAME,
         SGROUP );
         RETURN ret_value;
   END TRIGGERENDDATE;
   FUNCTION CRONPARTMONTH(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTMONTH      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTMONTH;
   FUNCTION CRONPARTMONTHLYEVERYMONTHOP2(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTMONTHLYEVERYMONTHOP2      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTMONTHLYEVERYMONTHOP2;
   FUNCTION CRONPARTMONTHLYWEEKDAY(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTMONTHLYWEEKDAY      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTMONTHLYWEEKDAY;
   FUNCTION CRONPARTSEC(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTSEC      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTSEC;
   FUNCTION CRONPARTSYNTAXWEDNESDAY(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTSYNTAXWEDNESDAY      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTSYNTAXWEDNESDAY;
   FUNCTION CRONPARTTHURSDAY(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTTHURSDAY      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTTHURSDAY;
   FUNCTION TRIGGERNEXTFIRETIME(
      NAME IN VARCHAR2,
      SGROUP IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_SCHEDULER.TRIGGERNEXTFIRETIME      (
         NAME,
         SGROUP );
         RETURN ret_value;
   END TRIGGERNEXTFIRETIME;
   FUNCTION TRIGGERSCHEDULETYPE(
      NAME IN VARCHAR2,
      SGROUP IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.TRIGGERSCHEDULETYPE      (
         NAME,
         SGROUP );
         RETURN ret_value;
   END TRIGGERSCHEDULETYPE;
   FUNCTION TRIGGERSTARTDATE(
      NAME IN VARCHAR2,
      SGROUP IN VARCHAR2)
      RETURN DATE
   IS
      ret_value    DATE ;
   BEGIN
      ret_value := ECDP_SCHEDULER.TRIGGERSTARTDATE      (
         NAME,
         SGROUP );
         RETURN ret_value;
   END TRIGGERSTARTDATE;
   FUNCTION TRIGGERSTATUS(
      NAME IN VARCHAR2,
      SGROUP IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.TRIGGERSTATUS      (
         NAME,
         SGROUP );
         RETURN ret_value;
   END TRIGGERSTATUS;
   FUNCTION CRONPARTSYNTAXDOW(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTSYNTAXDOW      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTSYNTAXDOW;
   FUNCTION CRONPARTDAILYOP2(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTDAILYOP2      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTDAILYOP2;
   FUNCTION CRONPARTMONTHLYEVERYMONTH(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTMONTHLYEVERYMONTH      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTMONTHLYEVERYMONTH;
   FUNCTION CRONPARTMONTHLYOP2(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTMONTHLYOP2      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTMONTHLYOP2;
   FUNCTION CRONPARTSUBDAILYOP1(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTSUBDAILYOP1      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTSUBDAILYOP1;
   FUNCTION CRONPARTYEARLYWEEKDAY(
      CRONEXPRESSION IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.CRONPARTYEARLYWEEKDAY      (
         CRONEXPRESSION );
         RETURN ret_value;
   END CRONPARTYEARLYWEEKDAY;
   FUNCTION STATUSORPINSTATUS(
      SNAME IN VARCHAR2,
      SGROUP IN VARCHAR2,
      REALSTATUS IN VARCHAR2)
      RETURN VARCHAR2
   IS
      ret_value   VARCHAR2(4000) ;
   BEGIN
      ret_value := ECDP_SCHEDULER.STATUSORPINSTATUS      (
         SNAME,
         SGROUP,
         REALSTATUS );
         RETURN ret_value;
   END STATUSORPINSTATUS;

END RPDP_SCHEDULER;

/
--GRANT EXECUTE ON ECKERNEL_WST.RPDP_SCHEDULER TO REPORT_ROLE_XXX;



 -- FINISH PKG_GEN_PKGS.sf_get_functions at:05/07/2019 11.46.10 AM


