CREATE OR REPLACE PACKAGE ECBP_WELL_PVTSIM_CALSEP IS

/****************************************************************
** Package        :  ECBP_WELL_PVTSIM_CALSEP, header part
*
** Version  Date        Whom      Change description:
** -------  ------      -----     -----------------------------------
**
*****************************************************************/


--CREATE OR REPLACE TYPE qstrm_pmass_rec as object (indx INT, qstrm_id varchar2(32), hc_mass number);
--CREATE OR REPLACE TYPE qstrm_pmass_arr as table of qstrm_pmass_rec;


/*TYPE qstrm_pmass_rec is record(
                                indx     int,
                               qstrm_id   varchar2(32),
                               hc_mass    number
                              );

--TYPE qstrm_pmass_arr is table of qstrm_pmass_rec;
*/

FUNCTION  CalcFluidQualityMix(p_result_no  NUMBER)
RETURN qstrm_pmass_arr PIPELINED;
--
FUNCTION xml_tagvalues(p_object_id VARCHAR2,p_daytime DATE)
RETURN VARCHAR2;
--
END ECBP_WELL_PVTSIM_CALSEP;