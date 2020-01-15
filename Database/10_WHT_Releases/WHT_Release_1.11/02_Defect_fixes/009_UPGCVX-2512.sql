update ov_company SET OBJECT_END_DATE='15-APR-15' WHERE OBJECT_ID='97B3426B6B7F31DFE0530100007FF750';

update ov_company SET OBJECT_END_DATE='14-APR-15' WHERE OBJECT_ID='97B3426B6B8231DFE0530100007FF750';


commit;
UPDATE viewlayer_dirty_log SET DIRTY_IND='Y' WHERE object_name in ('ov_company');
commit;
EXECUTE EcDp_Viewlayer.BuildViewLayer('ov_company',p_force => 'Y') ;
EXECUTE EcDp_Viewlayer.BuildReportLayer('ov_company',p_force => 'Y');
commit;





