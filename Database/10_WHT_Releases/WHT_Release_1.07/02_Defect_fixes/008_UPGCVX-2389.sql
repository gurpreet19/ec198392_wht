Update cargo_harbour_dues
   set daytime=EC_HARBOUR_DUES.prev_equal_daytime(DUE_CODE,EcBp_cargo_transport.getfirstnomdate(CARGO_NO));
   
   COMMIT;