update tv_language_target
set target = 'The Cargo Status cannot change from Approved to Tentative, Official, Closed, Ready for Harbour or Cancelled'
where source_id=5003;
commit;