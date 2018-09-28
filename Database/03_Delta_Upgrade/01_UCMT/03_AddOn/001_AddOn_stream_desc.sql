DECLARE
  CURSOR c_missing_desc IS
	SELECT *
	FROM   class_attribute_cnfg a
	WHERE  a.class_name='STREAM' 
	AND    a.attribute_name IN(
        'STREAM_TYPE' 
       ,'STREAM_PHASE' 
       ,'STRM_METER_METHOD' 
       ,'STREAM_METER_FREQ' 
       ,'AGGREGATE_FLAG' 
       ,'ALLOC_PERIOD' 
       ,'ALLOC_DATA_FREQ' 
       ,'ALLOC_FIXED' 
       ,'GROSS_VOLUME_METHOD' 
       ,'NET_VOLUME_METHOD' 
       ,'BSW_VOL_METHOD' 
       ,'GRS_MASS_METHOD' 
       ,'NET_MASS_METHOD' 
       ,'BSW_WT_METHOD' 
       ,'STD_DENSITY_METHOD' 
       ,'STD_GRS_DENS_METHOD' 
       ,'ENERGY_METHOD' 
       ,'GCV_METHOD' 
       ,'SALT_WT_METHOD' 
       ,'GOR_METHOD' 
       ,'CGR_METHOD' 
       ,'WGR_METHOD' 
       ,'WDF_METHOD' 
       ,'COND_VOL_METHOD' 
       ,'WATER_VOL_METHOD' 
       ,'WATER_MASS_METHOD' 
       ,'SPECIFIC_GRAVITY_METHOD')
    AND NOT EXISTS(
       SELECT 1 FROM class_attr_property_cnfg WHERE class_name=a.class_name AND attribute_name=a.attribute_name AND owner_cntx=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION'
    );   
BEGIN

	FOR cur IN c_missing_desc LOOP
		INSERT INTO class_attr_property_cnfg (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value)
		VALUES (cur.class_name, cur.attribute_name, 'DESCRIPTION', 0, '/EC', 'APPLICATION', NULL);
	END LOOP;


UPDATE class_attr_property_cnfg SET property_value='The stream type is a list of predefined types supported by EC.
If the stream changes stream type, set an end date on the old stream and create a new stream for the new type.
The stream type is used by the EC system in the instantiation,aggregation, performance test calculation, and fluid property retrieval from the reservoir.
'||chr(60)||'p'||chr(62)||'==> M - Measured 
A Measured Stream in EC is used to capture data from real meters. Although it'||chr(39)||'s representing a real meter, some of the values can also be calculated, but at least one number will be recorded from the meter.
'||chr(60)||'p'||chr(62)||'==> D - Derived
A Derived Stream in EC is a virtual Stream that is calculated on the fly depending on the formula defined under Stream Formula Editor or from the predfined list of methods available. No input can be accepted for a Derived Stream.
'||chr(60)||'p'||chr(62)||'==> C - Calculated
A Calculated Stream in EC is a Stream which only stores results from a calculation. The Stream cannot have input.
'||chr(60)||'p'||chr(62)||'==> Q - Quality
A Quality Stream in EC is a Stream which is used to hold common reservoir shrinakge constants used in well test shrinakge calculations. The object class Resv Block Formation has a reference to a Quality Stream that represents the quality of the fluid in the reservoir.
'||chr(60)||'p'||chr(62)||'==> R - Reference
A Reference Stream in EC is a Stream which is used to hold common reference data used by a number of other Streams.
'||chr(60)||'p'||chr(62)||'' WHERE CLASS_NAME='STREAM' AND ATTRIBUTE_NAME='STREAM_TYPE' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';

UPDATE class_attr_property_cnfg SET property_value='The stream phase is a list of predefined phases used by EC.  If the stream changes stream phase, set an end date on the old stream and create a new stream for the new phase.

The stream phase is used in all types of stream calculations, including allocation. 
'||chr(60)||'p'||chr(62)||'==> OIL - Oil
The stream phase is Oil. Stream phase is often used to process all streams of the same phase and from_node in the allocation.
'||chr(60)||'p'||chr(62)||'==> GAS - Gas
The stream phase is Gas.
'||chr(60)||'p'||chr(62)||'==> WAT - Water
The stream phase is Water.
'||chr(60)||'p'||chr(62)||'==> COND - Condensate
The stream phase is Condensate.
'||chr(60)||'p'||chr(62)||'==> RES - Reservoir fluid
Used to hold reservoir fluid composition.
'||chr(60)||'p'||chr(62)||'==> NGL - NGL
The stream phase is NGL.
'||chr(60)||'p'||chr(62)||'==> SOL - Solid
The stream phase is Solid, e.g. sulphur.
'||chr(60)||'p'||chr(62)||'==> STEAM - Steam
The stream phase is Steam.
'||chr(60)||'p'||chr(62)||'==> ELECTRICAL - Electrical
Electrical is used to capture meters measuring electricity.
'||chr(60)||'p'||chr(62)||'==> CO2 - CO2
The stream phase is CO2.
'||chr(60)||'p'||chr(62)||'==> LNG - Liquified Natural Gas
The stream phase is Liquified Natural Gas.' WHERE CLASS_NAME='STREAM' AND ATTRIBUTE_NAME='STREAM_PHASE' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';

UPDATE class_attr_property_cnfg SET property_value = '==> FREQ - Regular Intervals
This Stream will have data at regular intervals. The frequence is given by Stream Meter Frequency
'||chr(60)||'p'||chr(62)||'==> EVENT - Irregular Events
This Stream will have data at irregular events, no regular intervals
'||chr(60)||'p'||chr(62)||'==> PERIOD - Irregular Periods
This Stream Well have data at irregular periods. A period has a start date'||chr(38)||'time and end date'||chr(38)||'time.' WHERE CLASS_NAME='STREAM' AND ATTRIBUTE_NAME='STRM_METER_METHOD' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';
UPDATE class_attr_property_cnfg SET property_value='The stream meter frequency is used by the instantiation process to determine how often and where data records for the stream should be created (instantiated). In addition, the stream type must also be ''Metered''.
'||chr(60)||'p'||chr(62)||'==> YR - Year
One record per year only.
'||chr(60)||'p'||chr(62)||'==> MTH - Month
One record per month only.
'||chr(60)||'p'||chr(62)||'==> DAY - Day
One record per day only.
'||chr(60)||'p'||chr(62)||'==> 2H - Two Hours
One record every two hours, but the Stream can also have daily records if the Aggregate flag is Y.
'||chr(60)||'p'||chr(62)||'==> 1H - One Hour
One record every hour, but the Stream can also have daily records if the Aggregate flag is Y
'||chr(60)||'p'||chr(62)||'==> 30M - Thirty Minutes
One record every thirty minutes, but the Stream can also have daily records if the Aggregate flag is Y.
'||chr(60)||'p'||chr(62)||'==> 15M - Fifteen Minutes
One record every fifteen minutes, but the Stream can also have daily records if the Aggregate flag is Y.
'||chr(60)||'p'||chr(62)||'==> 10M - Ten Minutes
One record every ten minutes, but the Stream can also have daily records if the Aggregate flag is Y.
'||chr(60)||'p'||chr(62)||'==> 5M - Five Minutes
One record every five minutes, but the Stream can also have daily records if the Aggregate flag is Y.
'||chr(60)||'p'||chr(62)||'==> 1M - One Minute
One record every one minutes, but the Stream can also have daily records if the Aggregate flag is Y.
'||chr(60)||'p'||chr(62)||'==> NA - Not Applicable' WHERE CLASS_NAME='STREAM' AND ATTRIBUTE_NAME='STREAM_METER_FREQ' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';

UPDATE class_attr_property_cnfg SET property_value='Attribute that defines whether sub-daily data should be aggregated to daily values:
'||chr(60)||'p'||chr(62)||'=>	Daily records should be instantiated for objects with sub-daily meter frequency if the aggregate flag is ''Y''. 
'||chr(60)||'p'||chr(62)||'=>	Aggregate button in sub-daily BFs should be disabled if AGGREGATE_FLAG=''N''

'||chr(60)||'p'||chr(62)||'==> NA - Not Applicable
Not applicable because of choise done for Stream Meter Frequence
'||chr(60)||'p'||chr(62)||'==> Y - Yes
Yes, aggregate from sub daily interval to daily interval
'||chr(60)||'p'||chr(62)||'==> N - No
No, do not aggregate from sub daily to daily interval' WHERE CLASS_NAME='STREAM' AND ATTRIBUTE_NAME='AGGREGATE_FLAG' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';
UPDATE class_attr_property_cnfg SET property_value = 'This attribute defines the time span the allocation will need to deal with for any given stream.  The allocation period can also be set to a combination of time-spans.
'||chr(60)||'p'||chr(62)||'==> DAY - Daily
The Stream is included in daily allocation only
'||chr(60)||'p'||chr(62)||'==> MONTH - Monthly
The Stream is included in monthly allocation only
'||chr(60)||'p'||chr(62)||'==> YEAR - Yearly
The Stream is included in yearly allocation only 
'||chr(60)||'p'||chr(62)||'==> DAY_MONTH - Daily and monthly
The Stream is included in both daily and monthly allocation
'||chr(60)||'p'||chr(62)||'==> DAY_MONTH_YEAR - Daily, monthly and yearly
The Stream is included in daily, monthly and yearly allocation
'||chr(60)||'p'||chr(62)||'==> MONTH_YEAR - Monthly and yearly
The Stream is included in both monthly and yearly allocation
'||chr(60)||'p'||chr(62)||'==> SUB_DAY - Sub-daily
The Stream is included in sub daily allocation only
'||chr(60)||'p'||chr(62)||'==> SUB_DAY_DAY - Sub-daily and daily
The Stream is included in both sub daily and daily allocation
'||chr(60)||'p'||chr(62)||'==> SUB_DAY_DAY_MONTH - Sub-daily, daily and monthly
The Stream is included in sub daily, daily and monthly allocation
'||chr(60)||'p'||chr(62)||'==> NONE - Not included
Not included in the allocation'
WHERE CLASS_NAME='STREAM' AND ATTRIBUTE_NAME='ALLOC_PERIOD' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';
UPDATE class_attr_property_cnfg SET property_value ='Attribute that defines the frequency of the allocation data
Ec-Code: ALLOC_DATA_FREQ
The Alloc Data Freq is only used for Derived Streams included in the alloc network, all other Stream can have '||chr(39)||'NA'||chr(39)||' or NULL
'||chr(60)||'p'||chr(62)||'==> NA - Not Applicable
Use this if the Stream is not a Derived Stream or the Stream is Derived but not included in allocation networks.
'||chr(60)||'p'||chr(62)||'==> DAY - Daily Data Allocation
A Derived Stream included in the allocation network will display its daily values
'||chr(60)||'p'||chr(62)||'==> MTH - Monthly Data Allocation
A Derived Stream included in the allocation network will display its monthly values'
WHERE CLASS_NAME='STREAM' AND ATTRIBUTE_NAME='ALLOC_DATA_FREQ' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';
UPDATE class_attr_property_cnfg SET property_value='This is only applicable to streams used by the allocation. Streams that shall not be adjusted by the allocation will have this attribute set to YES. 
Streams not included in the allocation can leave this attribute NULL.
'||chr(60)||'p'||chr(62)||'==> Y - Yes 
the allocation will keep the value fixed and not adjust it when writing results to the allocation tables
'||chr(60)||'p'||chr(62)||'==> N -  No
The allocation will adjust the number and write an adjusted value to allocation tables, but not replace to source' 
WHERE CLASS_NAME='STREAM' AND ATTRIBUTE_NAME= 'ALLOC_FIXED' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';
UPDATE class_attr_property_cnfg SET property_value='The gross volume method is used to configure how the gross volume should be read from the database. 
'||chr(60)||'p'||chr(62)||'==> NET_VOL - Use Net vol method
This method will simply return the value from the Net Vol Method configured. See Net Vol Method.
'||chr(60)||'p'||chr(62)||'==> MEASURED - Measured
If meter_freq=DAY, this method will return the attribute GRS_VOL_GAS/OIL from the BF''s "Daily <phase>  Stream Status"
If meter_freq=MTH, this method will return the attribute GRS_VOL_GAS/GRS_VOL from the BF''s "Monthly <phase> Stream Status"
If meter_freq=EVENT, this method will return the attribute GRS_VOL from the BF "Batch Oil Stream Data" for all daytimes in production day.
'||chr(60)||'p'||chr(62)||'==> MEASURED_TRUCKED - Trucks Single Transfer
This method will return the attribute GRS_VOL_ACTUAL from the Truck Tickets BF.
'||chr(60)||'p'||chr(62)||'==> FORMULA - Formula
This method calls the configurable formulas you can define using Stream Formula Editor.
'||chr(60)||'p'||chr(62)||'==> MASS_DENSITY - Gross Mass / Density
This method uses the Grs Mass returned from Grs Mass Method and divide by the Density from Std Density Method.
'||chr(60)||'p'||chr(62)||'==> RUNTIME_RATE - Runtime * Reference Rate
This method will return the hourly reference rate from the BF "Stream Reference Values" multiplied with the run time from the BF "Daily Gas Stream Status - Run Hours and Rate"
'||chr(60)||'p'||chr(62)||'==> TANK_DUAL_DIP - Dual Tank Dip
This method will return the delta tank gross inventory change from Tank Grs Vol Method + attribute Manual Adj Vol from the BF "Batch Tank Oil Export - Tank Dip"
'||chr(60)||'p'||chr(62)||'==> TOTALIZER_EVENT - Totalizer Event
This method will return a calculated Grs Vol from the BF''s "Period <phase> Stream - Totalizer". The calc takes into account many factors which can be set in the BF "Strm Reference Values" and it multiplies with a calc VCF factor.
'||chr(60)||'p'||chr(62)||'==> TOTALIZER_EVENT_RAW - Totalizer Event Raw
This method will return a calculated Grs Vol from the BF''s "Period <phase> Stream - Totalizer". 
'||chr(60)||'p'||chr(62)||'==> NET_VOL_WATER - Net Volume + Water
This method uses the Net Volume returned from Net Vol Method and adds Water from Water Vol Method
'||chr(60)||'p'||chr(62)||'==> AGA - AGA
This method calculates the total of Grs Vol for all events in BF '||chr(34)||'Period Gas Stream Data - AGA Calc'||chr(34)||' contributing fully or partially to the production day. The attribute Volume is calculated and stored in the database using the AGA library. See PO.0026 for more details.
'||chr(60)||'p'||chr(62)||'==> ENERGY_GCV - Energy / GCV
This method uses the Energy from the Energy Method divided by the Gross Calorific Value from the GCV Method.
'||chr(60)||'p'||chr(62)||'==> TOTALIZER_DAY - Totalizer Day
This method will include whole or the parts of a totalizer reading the falls inside the production day definition of the totalizer readings and multiply with meter/pressure/shrinkage/conversion factors . Opening Daytime and Closing Daytime will be used to calculate the fraction of a production day the totalizer belongs to. 
'||chr(60)||'p'||chr(62)||'==> API_BLEND_SHRINKAGE - API 12.3 blend shrinkage
This method returns the grs vol based on API 12.3 blend shrinkage calculation.
'||chr(60)||'p'||chr(62)||'==> USER_EXIT - User Exit
This method is the User Exit option and it calls the package ue_stream_fluid.getGrsStdVol.'
WHERE CLASS_NAME='STREAM' AND ATTRIBUTE_NAME='GROSS_VOLUME_METHOD' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';
UPDATE class_attr_property_cnfg SET property_value='The net volume method is used to configure how the net volume should be read from the database.
'||chr(60)||'p'||chr(62)||'==> GRS_VOL - Net volume = Grs volume
This method will call the Grs Vol Method and return grs volume as net volume.
'||chr(60)||'p'||chr(62)||'==> GROSS_BSW - Net volume = Grs - bsw
This method will call Grs Vol Method and multiply with (1 - BSW Vol Method) to return Net Volume.
'||chr(60)||'p'||chr(62)||'==> MEASURED - Measured
If meter_freq=DAY, this method will return the attribute NET_VOL from the BF''s "Daily <phase>  Stream Status"
If meter_freq=MTH, this method will return the attribute NET_VOL from the BF''s "Monthly <phase> Stream Status"
'||chr(60)||'p'||chr(62)||'==> ALLOCATED - Allocated
This method will access allocated data and return net_vol from table strm_day_alloc.net_vol
'||chr(60)||'p'||chr(62)||'==> FORMULA - Formula
This method calls the configurable formulas you can define using Stream Formula Editor.
'||chr(60)||'p'||chr(62)||'==> MASS_DENSITY - Net Mass / Density
This method uses the Net Mass returned from Net Mass Method and divide by the Density from Std Density Method.
'||chr(60)||'p'||chr(62)||'==> GROSS_FACTOR - Gross Vol*(1-Bsw frac)*Factor*Shrinkage
This method uses the gross volume returned from Grs Vol Method and mulitiplies with (1-Bsw Vol Method) * meter factor * shrinkage factor. Factors are found in Strm Reference value.
'||chr(60)||'p'||chr(62)||'==> GRS_VOL_WDF - Wet Gas Vol / Wet Dry Factor
This method uses the gross volume returned from Grs Vol Method and divides by Wet Dry Factor found from WDF Method
'||chr(60)||'p'||chr(62)||'==> TANK_DUAL_DIP - Dual Tank Dip
This method calculates the net volume from the Tank opening and closing net inventory levels + adjustment volume. This method can only be used for Streams linked to the BF Batch Oil Tank Export - Tank Dip.
'||chr(60)||'p'||chr(62)||'==> TOTALIZER_EVENT - Totalizer Event
This method will assign to whole totalizer net volume calculated from Grs Vol Method * (1-Bsw Vol Method) to one production day only, controlled by Production Day attribute
'||chr(60)||'p'||chr(62)||'==> TOTALIZER_DAY - Totalizer Day
This method will include whole or the parts of a totalizer reading the falls inside the production day definition Grs Vol Method * (1-Bsw Vol Method). Opening Daytime and Closing Daytime will be used to calculate the fraction of a production day the totalizer belongs to. 
'||chr(60)||'p'||chr(62)||'==> TOTALIZER_DAY_EXTRAPOLATE - Totalizer Day Extrapolate
This method is identical to the above, except that it will return the last daily average totalizer volume for the next month if there are no reading yet.
'||chr(60)||'p'||chr(62)||'==> WELL_INV_WITHDRAW - Well Inventory Withdrawn
This method calculates the net volume from the BF Event Well Inventory.
'||chr(60)||'p'||chr(62)||'==> ALLOC_THEOR - Theoretical Net Vol from alloc table
This method returns the net vol from strm_day_alloc table.
'||chr(60)||'p'||chr(62)||'==> API_BLEND_SHRINKAGE - API 12.3 blend shrinkage
This method returns the net vol based on API 12.3 blend shrinkage calculation.
'||chr(60)||'p'||chr(62)||'==> USER_EXIT - User Exit
Net Volume is calculated in the user exit package ue_stream_fluid.getNetStdVol().
'||chr(60)||'p'||chr(62)||'==> NA - Not Applicable
Not applicable for e.g. quality streams.'
WHERE CLASS_NAME='STREAM' AND ATTRIBUTE_NAME='NET_VOLUME_METHOD' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';
UPDATE class_attr_property_cnfg SET property_value='The bsw volume method is used to configure how the bsw volume fraction should be read from the database.
Common for all '||chr(34)||'ANALYSIS'||chr(34)||' methods:
If customer uses Analysis Status, default will be NEW and EC will only access ACCEPTED analysis.
If customer doesn'||chr(39)||'t use Analysis Status (disabled), then EC access all analysis regardless of Analysis Status.
It is the Valid From date that is used when accessing analysis, not the Daytime the analysis is taken.
If a Stream has configured a Reference Analysis Stream, it will be the Reference Analysis Stream that will be used to access analysis data.
'||chr(60)||'p'||chr(62)||'==> MEASURED - Measured
BSW is found from either,
the Daily Oil Stream Status if Meter Frequence is Day
the Monthly Oil Stream Status if Meter Frequence is Month
the Truck Ticket - Single Transfer if Meter Frequence is Spot and Grs Method = Measured Trucked
the Batch Oil Stream Data if Meter Frequence is Spot and Grs Method = Measured Trucked
'||chr(60)||'p'||chr(62)||'==> ZERO - No BSW - return 0
Return 0
'||chr(60)||'p'||chr(62)||'==> COMP_ANALYSIS - Component Analysis, any sampling
BSW is found from last Accepted analysis from Stream Gas Component Analysis, regardless of Sampling Method.
'||chr(60)||'p'||chr(62)||'==> COMP_ANALYSIS_SPOT - Component Analysis, Spot sampling
BSW is found from last Accepted analysis from Stream Gas Component Analysis where Sampling Method=Spot.
'||chr(60)||'p'||chr(62)||'==> COMP_ANALYSIS_DAY - Component Analysis, Day sampling
BSW is found from last Accepted analysis from Stream Gas Component Analysis where Sampling Method=Day Sampler.
'||chr(60)||'p'||chr(62)||'==> COMP_ANALYSIS_MTH - Component Analysis, Month sampling
BSW is found from last Accepted analysis from Stream Gas Component Analysis where Sampling Method=Month Sampler.
'||chr(60)||'p'||chr(62)||'==> SAMPLE_ANALYSIS - Sample Analysis, any sampling
BSW is found from last Accepted analysis from Stream Sample Analysis, regardless of Sampling Method.
'||chr(60)||'p'||chr(62)||'==> SAMPLE_ANALYSIS_SPOT - Sample Analysis, Spot sampling
BSW is found from last Accepted analysis from Stream Sample Analysis, where Sampling Method=Spot.
'||chr(60)||'p'||chr(62)||'==> SAMPLE_ANALYSIS_DAY - Sample Analysis, Day sampling
BSW is found from last Accepted analysis from Stream Sample Analysis, where Sampling Method=Day Sampler.
'||chr(60)||'p'||chr(62)||'==> SAMPLE_ANALYSIS_MTH - Sample Analysis, Month sampling
BSW is found from last Accepted analysis from Stream Sample Analysis, where Sampling Method=Month Sampler.
'||chr(60)||'p'||chr(62)||'==> REF_VALUE - Reference Value
BSW is found from BS'||chr(38)||'W Vol% in Stream Reference Value.
'||chr(60)||'p'||chr(62)||'==> USER_EXIT - User Exit
'||chr(60)||'p'||chr(62)||'BSW is calculated in the user exit package Ue_Stream_Fluid.getBSWVol().'
WHERE CLASS_NAME='STREAM' AND ATTRIBUTE_NAME='BSW_VOL_METHOD' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';
UPDATE class_attr_property_cnfg SET property_value='The gross mass method is used to configure how the gross mass should be read from the database.
'||chr(60)||'p'||chr(62)||'==> MEASURED - Measured
If meter_freq=DAY, this method will return the attribute GRS_MASS_OIL/ GRS_MASS_GAS from the BF''s "Daily <phase>  Stream Status".
If meter_freq=MTH, this method will return the attribute GRS_MASS from the BF''s "Monthly <phase> Stream Status".
If meter_freq=EVENT, this method will return the attribute GRS_MASS from the BF "Batch Oil Stream Data" for all daytimes in production day.
'||chr(60)||'p'||chr(62)||'==> FORMULA - Formula
This method calls the configurable formulas you can define using Stream Formula Editor.
'||chr(60)||'p'||chr(62)||'==> NET_MASS - Net Mass
This method will simply return the value from the Net Mass Method configured. See Net Mass Method.
'||chr(60)||'p'||chr(62)||'==> VOLUME_DENSITY - Volume * Density
This method uses the gross volume returned from Grs Vol Method and multiply with the Density from Std Density Method.
'||chr(60)||'p'||chr(62)||'==> RUNTIME_RATE - Runtime * Rate
This method will return the hourly reference rate from the BF "Stream Reference Values" multiplied with the run time from the BF "Daily Gas Stream Status - Run Hours and Rate".
'||chr(60)||'p'||chr(62)||'==> OPEN_CLOSE_WEIGHT - Closing - Opening Weight
'||chr(60)||'p'||chr(62)||'==> MEASURED_TRUCKED - Trucks Single Transfer
This method will return the attribute GRS_MASS_ACTUAL from the  Truck Tickets BF.
'||chr(60)||'p'||chr(62)||'==> NET_MASS_WATER - Net Mass + Water
This method uses the net mass  returned from Net Mass Method and adds Water from Water Mass Method.
'||chr(60)||'p'||chr(62)||'==> TOTALIZER_DAY - Totalizer Day 
If meter_freq=DAY, this method will calculate grs mass from totalizer mass readings from BF "Daily Liquid Stream Data".
'||chr(60)||'p'||chr(62)||'==> USER_EXIT - User Exit
Gross mass is calculated in the user exit package Ue_Stream_Fluid.getGrsStdMass().'
WHERE CLASS_NAME='STREAM' AND ATTRIBUTE_NAME='GRS_MASS_METHOD' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';
UPDATE class_attr_property_cnfg SET property_value='The net mass method is used to configure how the gross mass should be read from the database.
'||chr(60)||'p'||chr(62)||'==> MEASURED - Measured
If meter_freq=DAY, this method will return the attribute NET_MASS_OIL/NET_MASS_GAS from the BF''s "Daily <phase>  Stream Status".
If meter_freq=MTH, this method will return the attribute NET_MASS from the BF''s "Monthly <phase> Stream Status".
If meter_freq=EVENT, this method will return the attribute NET_MASS from the BF "Batch Oil Stream Data" for all daytimes in production day.
'||chr(60)||'p'||chr(62)||'==> ALLOCATED - Allocated
This method will access allocated data to get the net mass, hence the Stream Type should be '||chr(39)||'C'||chr(39)||' for calculated.
'||chr(60)||'p'||chr(62)||'==> FORMULA - Formula
This method calls the configurable formulas you can define using Stream Formula Editor.
'||chr(60)||'p'||chr(62)||'==> GRS_MASS - Gross Mass
This method will simply return the value from the Grs Mass Method configured. See Grs Mass Method.
'||chr(60)||'p'||chr(62)||'==> VOLUME_DENSITY - Volume * Density
this method uses the gross volume returned from Net Vol Method and multiply with the Density from Std Density Method.
'||chr(60)||'p'||chr(62)||'==> GROSS_BSW - Gross Mass * (1-Bsw)
This method will call Grs Mass Method and multiply with (1 - BSW Weight Method) to return Net Mass.
'||chr(60)||'p'||chr(62)||'==> GRS_MASS_WDF - Wet Gas Mass / Wet Dry Factor
This method calculates the net mass from the Grs Mass Method divided by the WDF Method (wet-dry factor).
'||chr(60)||'p'||chr(62)||'==> GROSS_BSW_SALT - Gross Mass * (1-Bsw Wt-Salt Wt)
This method will call Grs Mass Method and multiply with (1 - BSW Weight Method) and (1-Salt Weight Method) to return Net Mass.
'||chr(60)||'p'||chr(62)||'==> TANK_DUAL_DIP - Tank Dual Dip
This method calculates the net mass from the Tank opening and closing net inventory levels + adjustment volume. This method can only be used for Streams linked to the BF Batch Oil Tank Export - Tank Dip.
'||chr(60)||'p'||chr(62)||'==> GRS_MASS_MINUS_WATER - Grs Mass - Water Mass
This method calculated the net mass from the Grs Mass Method minus the Water Mass Method.
'||chr(60)||'p'||chr(62)||'==> TOTALIZER_DAY - Totalizer Day
If meter_freq=DAY, this method will call Grs Mass Method and multiply with (1 - BSW Weight Method) and (1-Salt Weight Method) to return Net Mass.
'||chr(60)||'p'||chr(62)||'==> GRS_MASS_BSW_VOL - Grs Mass*(1-(BSW Vol*Density/(Grs Mass/Grs Vol)))
This method will call Grs Mass Method and multiply with (1 - BSW Vol * Std Density /( Grs Mass/Grs Vol)) to return Net Mass.
'||chr(60)||'p'||chr(62)||'==> USER_EXIT - User Exit
Net mass is calculated in the user exit package Ue_Stream_Fluid.getNetStdMass().'
WHERE CLASS_NAME='STREAM' AND ATTRIBUTE_NAME='NET_MASS_METHOD' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';
UPDATE class_attr_property_cnfg SET property_value='The bsw weight method is used to configure how the bsw weight fraction should be read from the database.
Common for all '||chr(34)||'ANALYSIS'||chr(34)||' methods:
If customer uses Analysis Status, default will be NEW and EC will only access ACCEPTED analysis.
If customer doesn'||chr(39)||'t use Analysis Status (disabled), then EC access all analysis regardless of Analysis Status.
It is the Valid From date that is used when accessing analysis, not the Daytime the analysis is taken.
If a Stream has configured a Reference Analysis Stream, it will be the Reference Analysis Stream that will be used to access analysis data.
'||chr(60)||'p'||chr(62)||'==> MEASURED - Measured
BSW Wt is found from either,
the Daily Oil Stream Status if Meter Frequence is Day
the Monthly Oil Stream Status if Meter Frequence is Month
the Truck Ticket - Single Transfer if Meter Frequence is Spot and Grs Method = Measured Trucked
the Batch Oil Stream Data if Meter Frequence is Spot and Grs Method = Measured Trucked
'||chr(60)||'p'||chr(62)||'==> ZERO - No BSW Wt - return 0
Return 0
'||chr(60)||'p'||chr(62)||'==> BSW_VOL_FRAC - Bsw Vol Frac
This method calculates BSW Wt from BSW Vol Method and specific gravity using this formula:
BSW Wt = 1  /  ( 1 - specific gravity + (specific gravity / BSW Vol frac))
'||chr(60)||'p'||chr(62)||'==> COMP_ANALYSIS - Component Analysis, any sampling
BSW Wt is found from last Accepted analysis from Stream Gas Component Analysis, regardless of Sampling Method.
'||chr(60)||'p'||chr(62)||'==> COMP_ANALYSIS_SPOT - Component Analysis, Spot sampling
BSW Wt is found from last Accepted analysis from Stream Gas Component Analysis where Sampling Method=Spot.
'||chr(60)||'p'||chr(62)||'==> COMP_ANALYSIS_DAY - Component Analysis, Day sampling
BSW Wt is found from last Accepted analysis from Stream Gas Component Analysis where Sampling Method=Day Sampler.
'||chr(60)||'p'||chr(62)||'==> COMP_ANALYSIS_MTH - Component Analysis, Month sampling
BSW Wt is found from last Accepted analysis from Stream Gas Component Analysis where Sampling Method=Month Sampler.
'||chr(60)||'p'||chr(62)||'==> SAMPLE_ANALYSIS - Sample Analysis, any sampling
BSW Wt is found from last Accepted analysis from Stream Sample Analysis, regardless of Sampling Method.
'||chr(60)||'p'||chr(62)||'==> SAMPLE_ANALYSIS_SPOT - Sample Analysis, Spot sampling
BSW Wt is found from last Accepted analysis from Stream Sample Analysis, where Sampling Method=Spot.
'||chr(60)||'p'||chr(62)||'==> SAMPLE_ANALYSIS_DAY - Sample Analysis, Day sampling
BSW Wt is found from last Accepted analysis from Stream Sample Analysis, where Sampling Method=Day Sampler.
'||chr(60)||'p'||chr(62)||'==> SAMPLE_ANALYSIS_MTH - Sample Analysis, Month sampling
BSW Wt is found from last Accepted analysis from Stream Sample Analysis, where Sampling Method=Month Sampler.
'||chr(60)||'p'||chr(62)||'==> REF_VALUE - Reference Value
BSW Wt is found from BS'||chr(38)||'W Wt% in Stream Reference Value.
'||chr(60)||'p'||chr(62)||'==> USER_EXIT - User Exit
'||chr(60)||'p'||chr(62)||'BSW Wt is calculated from the user exit function Ue_Stream_Fluid.getBSWWt().'
WHERE CLASS_NAME='STREAM' AND ATTRIBUTE_NAME='BSW_WT_METHOD' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';
UPDATE class_attr_property_cnfg SET property_value='==> REF_VALUE - Reference Value
Density is found from the Stream Reference Value Density attribute.
'||chr(60)||'p'||chr(62)||'==> COMP_ANALYSIS - Component Analysis, any sampling
Density is found from last Accepted analysis from Stream Gas Component Analysis, regardless of Sampling Method.
'||chr(60)||'p'||chr(62)||'==> COMP_ANALYSIS_SPOT - Component Analysis, Spot sampling
Density is found from last Accepted analysis from Stream Gas Component Analysis where Sampling Method=Spot.
'||chr(60)||'p'||chr(62)||'==> COMP_ANALYSIS_DAY - Component Analysis, Day sampling
Density is found from last Accepted analysis from Stream Gas Component Analysis where Sampling Method=Day Sampler.
'||chr(60)||'p'||chr(62)||'==> COMP_ANALYSIS_MTH - Component Analysis, Month sampling
Density is found from last Accepted analysis from Stream Gas Component Analysis where Sampling Method=Month Sampler.
'||chr(60)||'p'||chr(62)||'==> SAMPLE_ANALYSIS - Sample Analysis, any sampling
Density is found from last Accepted analysis from Stream Sample Analysis.
'||chr(60)||'p'||chr(62)||'==> ANALYSIS_SP_GRAV - Using Comp.Analysis Spec.Grav
Using Comp.Analysis Spec.Grav.
'||chr(60)||'p'||chr(62)||'==> MEASURED - Measured
Density is found from either,
the Daily Oil/Gas Stream Status if Meter Frequence is Day
the Monthly Oil/Gas Stream Status if Meter Frequence is Month
the Truck Ticket - Load From Wells if Meter Frequence is Spot and Std Density Method = Measured
'||chr(60)||'p'||chr(62)||'==> CALCULATED - Net mass / Net volume
This method calls the Net Mass Method and divide by the result from Net Volume Method.
'||chr(60)||'p'||chr(62)||'==> ALLOCATED - Allocated
This method will access allocated data to get the std density, hence the Stream Type should be '||chr(39)||'C'||chr(39)||' for calculated.
'||chr(60)||'p'||chr(62)||'==> REF_STREAM - Density from Ref. Analysis Stream
Density from Reference Analysis Stream.
'||chr(60)||'p'||chr(62)||'==> MEASURED_API - Measured API
Density from Truck Ticket if meter method is Event.
'||chr(60)||'p'||chr(62)||'==> USER_EXIT - User Exit
Std Density is calculated from the user exit function Ue_Stream_Fluid.findStdDens().'
WHERE CLASS_NAME='STREAM' AND ATTRIBUTE_NAME='STD_DENSITY_METHOD' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';
UPDATE class_attr_property_cnfg SET property_value='The standard gross density method is used to configure how the gross density should be read from the database.
'||chr(60)||'p'||chr(62)||'==> CALCULATED - Grs Mass / Grs Vol
This method calls the Grs Mass Method and divide by the result from Grs Volume Method 
'||chr(60)||'p'||chr(62)||'==> USER_EXIT - User Exit
Std Density is calculated from the user exit function Ue_Stream_Fluid.getGrsDens()'
WHERE CLASS_NAME='STREAM' AND ATTRIBUTE_NAME='STD_GRS_DENS_METHOD' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';
UPDATE class_attr_property_cnfg SET property_value='The energy method is used to configure how the gas energy value should be read from database.
'||chr(60)||'p'||chr(62)||'==> MEASURED - Measured
If meter_freq=DAY, this method will return the attribute MEAS_ENERGY from the BF''s "Daily Gas Stream Status".
If meter_freq=MTH, this method will return the attribute MEAS_ENERGY from the BF''s "Monthly Gas Stream Status".
'||chr(60)||'p'||chr(62)||'==> VOLUME_GCV - Volume * GCV
This method will call the Net Volume Method and mulitply with the number from Gross Calorific Method (GCV Method).
'||chr(60)||'p'||chr(62)||'==> ALLOCATED - Allocated
This method will get Energy from the allocation table Strm_mth_alloc, column alloc_energy.
'||chr(60)||'p'||chr(62)||'==> VOLUME_REF_MBTU - Volume * Ref MBtu
This method will call the Net Volume Method and mulitply with NVL(attribute energy_factor_override, strm_reference_value.mbtu_factor).
This method will only work for Event streams using the BF '||chr(34)||'Period Gas Stream - Totalizer'||chr(34)||'
'||chr(60)||'p'||chr(62)||'==> FORMULA - Formula
This method calls the configurable formulas you can define using Stream Formula Editor.
'||chr(60)||'p'||chr(62)||'==> TOTALIZER_DAY - Totalizer Day
If meter_freq=DAY, this method will return the attribute TOTALIZER_ENERGY from the BF''s "Daily Liquid Stream Data".
'||chr(60)||'p'||chr(62)||'==> USER_EXIT - User Exit
Energy is calculated in the user exit package Ue_Stream_Fluid.findEnergy().'
WHERE CLASS_NAME='STREAM' AND ATTRIBUTE_NAME='ENERGY_METHOD' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';
UPDATE class_attr_property_cnfg SET property_value='Common for all '||chr(34)||'ANALYSIS'||chr(34)||' methods:
If customer uses Analysis Status, default will be NEW and EC will only access ACCEPTED analysis
If customer doesn'||chr(39)||'t use Analysis Status (disabled), then EC access all analysis regardless of Analysis Status
It is the Valid From date that is used when accessing analysis, not the Daytime the analysis is taken.
If a Stream has configured a Reference Analysis Stream, it will be the Reference Analysis Stream that will be used to access analysis data.
'||chr(60)||'p'||chr(62)||'==> COMP_ANALYSIS - Component Analysis, any sampling
GCV is found from last Accepted analysis from Stream Gas Component Analysis, regardless of Sampling Method.
'||chr(60)||'p'||chr(62)||'==> COMP_ANALYSIS_SPOT - Component Analysis, Spot sampling
GCV is found from last Accepted analysis from Stream Gas Component Analysis where Sampling Method=Spot.
'||chr(60)||'p'||chr(62)||'==> COMP_ANALYSIS_DAY - Component Analysis, Day sampling
GCV is found from last Accepted analysis from Stream Gas Component Analysis where Sampling Method=Day Sampler.
'||chr(60)||'p'||chr(62)||'==> COMP_ANALYSIS_MTH - Component Analysis, Month sampling
GCV is found from last Accepted analysis from Stream Gas Component Analysis where Sampling Method=Month Sampler.
'||chr(60)||'p'||chr(62)||'==> MEASURED - Measured
GCV is found from either the Daily Gas Stream Status or  Monthly Gas Stream Status depending on Meter Frequence.
'||chr(60)||'p'||chr(62)||'==> SAMPLE_ANALYSIS - Sample Analysis, any sampling
GCV is found from last Accepted analysis from Stream Sample Analysis, regardless of Sampling Method.
'||chr(60)||'p'||chr(62)||'==> SAMPLE_ANALYSIS_SPOT - Sample Analysis, Spot sampling
GCV is found from last Accepted analysis from Stream Sample Analysis, where Sampling Method=Spot.
'||chr(60)||'p'||chr(62)||'==> SAMPLE_ANALYSIS_DAY - Sample Analysis, Day sampling
GCV is found from last Accepted analysis from Stream Sample Analysis, where Sampling Method=Day Sampler.
'||chr(60)||'p'||chr(62)||'==> SAMPLE_ANALYSIS_MTH - Sample Analysis, Month sampling
GCV is found from last Accepted analysis from Stream Sample Analysis, where Sampling Method=Month Sampler.
'||chr(60)||'p'||chr(62)||'==> ENERGY_DIV_VOLUME - Energy / Volume
GCV is calculated by calling the Stream Energy Method and divide by the Stream Grs Gas Volume.
'||chr(60)||'p'||chr(62)||'==> REF_VALUE - Reference Value
GCV is found from GCV in Stream Reference Value.
'||chr(60)||'p'||chr(62)||'==> REF_STREAM - GCV from Ref. Analysis Stream
GCV from Reference Analysis Stream.
'||chr(60)||'p'||chr(62)||'==> FORMULA - Formula
this method calls the configurable formulas you can define using Stream Formula Editor.
'||chr(60)||'p'||chr(62)||'==> USER_EXIT - User Exit
GCV is calculated from the user exit function Ue_Stream_Fluid.findGCV().'
WHERE CLASS_NAME='STREAM' AND ATTRIBUTE_NAME='GCV_METHOD' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';
UPDATE class_attr_property_cnfg SET property_value='The Salt Weight Method is used to configure how the Salt Weight should be retrieved.
Common for all '||chr(34)||'ANALYSIS'||chr(34)||' methods:
If customer uses Analysis Status, default will be NEW and EC will only access ACCEPTED analysis
If customer doesn'||chr(39)||'t use Analysis Status (disabled), then EC access all analysis regardless of Analysis Status
It is the Valid From date that is used when accessing analysis, not the Daytime the analysis is taken.
If a Stream has configured a Reference Analysis Stream, it will be the Reference Analysis Stream that will be used to access analysis data.
'||chr(60)||'p'||chr(62)||'==> DENSITY - Density
This method will calculate Salt wt fraction as Salt from daily record divided by (specific gravity * water density)
'||chr(60)||'p'||chr(62)||'==> MEASURED - Measured
Salt Wt is found from either,
the Daily Oil Stream Status if Meter Frequence is Day
the Monthly Oil Stream Status if Meter Frequence is Month
'||chr(60)||'p'||chr(62)||'==> COMP_ANALYSIS - Component Analysis, any sampling
Salt Wt is found from last Accepted analysis from Stream Gas Component Analysis, regardless of Sampling Method.
'||chr(60)||'p'||chr(62)||'==> COMP_ANALYSIS_SPOT - Component Analysis, Spot sampling
Salt Wt is found from last Accepted analysis from Stream Gas Component Analysis where Sampling Method=Spot.
'||chr(60)||'p'||chr(62)||'==> COMP_ANALYSIS_DAY - Component Analysis, Day sampling
Salt Wt is found from last Accepted analysis from Stream Gas Component Analysis where Sampling Method=Day Sampler.
'||chr(60)||'p'||chr(62)||'==> COMP_ANALYSIS_MTH - Component Analysis, Month sampling
Salt Wt is found from last Accepted analysis from Stream Gas Component Analysis where Sampling Method=Month Sampler.
'||chr(60)||'p'||chr(62)||'==> SAMPLE_ANALYSIS - Sample Analysis, any sampling
Salt Wt is found from last Accepted analysis from Stream Sample Analysis, regardless of Sampling Method.
'||chr(60)||'p'||chr(62)||'==> SAMPLE_ANALYSIS_SPOT - Sample Analysis, Spot sampling
Salt Wt is found from last Accepted analysis from Stream Sample Analysis, where Sampling Method=Spot
'||chr(60)||'p'||chr(62)||'==> SAMPLE_ANALYSIS_DAY - Sample Analysis, Day sampling
Salt Wt is found from last Accepted analysis from Stream Sample Analysis, where Sampling Method=Day Sampler.
'||chr(60)||'p'||chr(62)||'==> SAMPLE_ANALYSIS_MTH - Sample Analysis, Month sampling
Salt Wt is found from last Accepted analysis from Stream Sample Analysis, where Sampling Method=Month Sampler.'
WHERE CLASS_NAME='STREAM' AND ATTRIBUTE_NAME='SALT_WT_METHOD' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';
UPDATE class_attr_property_cnfg SET property_value='==> MEASURED - Measured
If meter_freq=DAY, this method will return the attribute GOR from the BF''s "Daily Oil Stream Status".
If meter_freq=1H,  this method will return the attribute GOR from the BF''s "Daily Oil Stream Status" after aggregation on "Sub Daily Oil Stream Status".
If meter_freq=MTH, this method will return the attribute GOR from the BF''s "Monthly Liquid Stream Status".
'||chr(60)||'p'||chr(62)||'==> REF_VALUE - Reference Value
GOR is found from the Stream Reference Value attribute GOR.'
WHERE CLASS_NAME='STREAM' AND ATTRIBUTE_NAME='GOR_METHOD' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';
UPDATE class_attr_property_cnfg SET property_value='The Condensate dry Gas Ratio Method is used to configure how the Condensate dry Gas Ratio should be retrieved.
==> REF_VALUE - Reference Value
CGR is found from the Stream Reference Value attribute CGR.' 
WHERE CLASS_NAME='STREAM' AND ATTRIBUTE_NAME='CGR_METHOD' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';
UPDATE class_attr_property_cnfg SET property_value='The Water dry Gas Ratio Method is used to configure how the Water dry Gas Ratio be should retrieved.
==> REF_VALUE - Reference Value
WGR is found from the Stream Reference Value attribute WGR' 
WHERE CLASS_NAME='STREAM' AND ATTRIBUTE_NAME='WGR_METHOD' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';
UPDATE class_attr_property_cnfg SET property_value='The Wet Dry Ratio Method is used to configure how the Wet Dry Ratio should be retrieved.
==> REF_VALUE - Reference Value
WDF is found from the Stream Reference Value attribute WDF. ' 
WHERE CLASS_NAME='STREAM' AND ATTRIBUTE_NAME='WDF_METHOD' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';
UPDATE class_attr_property_cnfg SET property_value='The Condensate Volume Method is used to configure how the Condensate Volume should be read from the database.
==> NET_VOL_CGR - Dry Gas * CGR
Condensate is found by calling the Net Std Volume Method and multiplying with the CGR from the CGR Method.
'||chr(60)||'p'||chr(62)||'==> USER_EXIT - User Exit
Condensate is calculated in the user exit package Ue_Stream_Fluid.findCondVol().' 
WHERE CLASS_NAME='STREAM' AND ATTRIBUTE_NAME='COND_VOL_METHOD' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';
UPDATE class_attr_property_cnfg SET property_value='The water volume method is used to configure how the water should be read from the database.
'||chr(60)||'p'||chr(62)||'==> GROSS_BSW - Gross * BS'||chr(38)||'W
This method calculates Water Volume from the Gross Volume Method and mulitplies with the values from the BSW Vol Method
'||chr(60)||'p'||chr(62)||'==> MEASURED - Measured
Water Volume is found from either,
the Daily Water Stream Status if Meter Frequence is Day
the Monthly Oil Stream Status if Meter Frequence is Month
'||chr(60)||'p'||chr(62)||'==> MASS_DENSITY - Water Mass / Density
This method calcilates water volume from Water Mass Method divided by the water density (using std from www.gaussian.com/gchem/waterd.htm which has discrepancy less than 0.03% between 0-50C)
'||chr(60)||'p'||chr(62)||'==> TANK_DUAL_DIP - Tank Dual Dip
this method will return the delta tank water inventory change from Tank Water Vol Method from the BF "Batch Tank Oil Export - Tank Dip"
'||chr(60)||'p'||chr(62)||'==> NET_VOL_WGR - Dry Gas * WGR
This method will calculate water volume from Dry Gas found from Net Vol Method and multiply with the WGR from from the Water Dry Gas Ratio Method (WGR Method)
'||chr(60)||'p'||chr(62)||'==> WELL_INV_WITHDRAW - Well Inventory Withdrawn
This method calculates the water volume from the BF Event Well Inventory
'||chr(60)||'p'||chr(62)||'==> GRS_MINUS_NET - Use gross minus net
This method calculated water from the Gross Volume Method minus the Net Volume Method
'||chr(60)||'p'||chr(62)||'==> USER_EXIT - User Exit
'||chr(60)||'p'||chr(62)||'Water is calculated in the user exit package Ue_Stream_Fluid.findWatVol()'
WHERE CLASS_NAME='STREAM' AND ATTRIBUTE_NAME='WATER_VOL_METHOD' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';
UPDATE class_attr_property_cnfg SET property_value='==> MEASURED - Measured
Water Mass is found from either,
the Daily Water Stream Status if Meter Frequence is Day
the Monthly Oil Stream Status if Meter Frequence is Month
'||chr(60)||'p'||chr(62)||'==> VOLUME_DENSITY - Volume * Density
This method will calculate the water mass from the Water Volume Method multiplied by the Water Density
'||chr(60)||'p'||chr(62)||'==> GROSS_BSW - Gross * BS'||chr(38)||'W
This method will calculate the water mass from the Gross Mass Method muliplied by the BSW Weight Method
'||chr(60)||'p'||chr(62)||'==> GRS_MINUS_NET - Gross - Net
This method will calculate the water mass from the Gross Mass minus Net Mass.
'||chr(60)||'p'||chr(62)||'==> USER_EXIT - User Exit
Water Mass is calculated in the user exit package Ue_Stream_Fluid.findWatMass()'
WHERE CLASS_NAME='STREAM' AND ATTRIBUTE_NAME='WATER_MASS_METHOD' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';
UPDATE class_attr_property_cnfg SET property_value='The specific gravity method is used to configure how the specific gravity should be read from the database.
'||chr(60)||'p'||chr(62)||'==> 1 - Reference Value
This method will find specific gravity from stream reference value. AGA reference analysis stream is used if found.
Note, This method is will also be used if no specific method is configured - it works as an '||chr(34)||'ELSE'||chr(34)||'
'||chr(60)||'p'||chr(62)||'==> 2 - Sample Analysis, any sampling
Salt Wt is found from last Accepted analysis from Stream Sample Analysis, regardless of Sampling Method.
'||chr(60)||'p'||chr(62)||'==> 3 - Measured
This method will access specific gravity attribute SP_GRAV from Daily Gas Stream Status
'||chr(60)||'p'||chr(62)||'==> 4 - Component Analysis, any sampling
Salt Wt is found from last Accepted analysis from Stream Gas Component Analysis, regardless of Sampling Method.
'||chr(60)||'p'||chr(62)||'==> 5 - Component Analysis, Spot sampling
Salt Wt is found from last Accepted analysis from Stream Gas Component Analysis where Sampling Method=Spot.
'||chr(60)||'p'||chr(62)||'==> 6 - Component Analysis, Day sampling
Salt Wt is found from last Accepted analysis from Stream Gas Component Analysis where Sampling Method=Day Sampler.
'||chr(60)||'p'||chr(62)||'==> 7 - Component Analysis, Month sampling
Salt Wt is found from last Accepted analysis from Stream Gas Component Analysis where Sampling Method=Month Sampler.
'||chr(60)||'p'||chr(62)||'==> 8 - Sample Analysis, Spot sampling
Salt Wt is found from last Accepted analysis from Stream Sample Analysis, where Sampling Method=Spot.
'||chr(60)||'p'||chr(62)||'==> 9 - Sample Analysis, Day sampling
Salt Wt is found from last Accepted analysis from Stream Sample Analysis, where Sampling Method=Day Sampler.
'||chr(60)||'p'||chr(62)||'==> 10 - Sample Analysis, Month sampling
Salt Wt is found from last Accepted analysis from Stream Sample Analysis, where Sampling Method=Month Sampler.
'WHERE CLASS_NAME='STREAM' AND ATTRIBUTE_NAME='SPECIFIC_GRAVITY_METHOD' AND OWNER_CNTX=0 AND presentation_cntx='/EC' AND property_code='DESCRIPTION' AND property_type='APPLICATION';
END;
/