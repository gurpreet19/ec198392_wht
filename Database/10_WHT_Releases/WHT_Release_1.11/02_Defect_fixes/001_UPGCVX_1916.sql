update TV_UNIT_CONVERSION set ADD_NUMB =0 where from_unit = 'PSIA' and to_unit = 'BARG' and daytime='01-JAN-60';
commit;
