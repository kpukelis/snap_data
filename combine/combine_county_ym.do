// combine_county_ym.do 
// Kelsey Pukelis

//	alabama			 // not completed (fixed individual)
// 	alaska			 fixed statewide 
//	california		 // not completed (fixed individual)
//	connecticut		 // not completed (fixed individual)
// 	delaware		 rolling clock
//	hawaii			 // not completed (rolling clock)
// 	nevada			 fixed individual
// 	newhampshire	 fixed individual
//	northdakota		 // not completed (rolling clock)
//	oklahoma		 // not completed (fixed individual)
// 	rhodeisland		 fixed statewide
// 	utah			
//	vermont			
//	washington		 // **not completed (fixed statewide, but yearly)
// 	westvirginia	 fixed statewide
// 	wyoming			 fixed statewide
// 	districtofcolumbia			 unclear clock


//	illinois			
//  missouri
//	oregon			


#delimit ;
local states_withtotal
	arizona
	arkansas
	colorado
	iowa
	kansas
	louisiana
	maine
   	maryland
	minnesota
	montana
	newmexico
	newyork
	northcarolina
	ohio
	pennsylvania
	southcarolina
	southdakota
	tennessee
	texas
	virginia
	wisconsin
; 
#delimit cr 

#delimit ;
local states_only
	georgia
	indiana
	kentucky
	mississippi
	missouri
	nebraska		
; 
#delimit cr 
**KP: missouri will move when updated	

#delimit ;
local states_collapse
	florida
	idaho
	massachusetts
	michigan
	newjersey		
; 
#delimit cr 

***********************************************************************************

// county = "total"
foreach state of local states_withtotal {
	
	// display 
	display in red "`state'"

	// load 
	use "${dir_root}/state_data/`state'/`state'.dta", clear
	
	// drop "total" observations
	drop if county == "total"

	// state variable 
	gen state = "`state'"

	// fix for maryland data only 
	**KP: need to copy this to combine_state_ym
	capture rename snap_npa_recipients individuals_npa
	capture rename snap_pa_recipients individuals_pa
	capture confirm variable individuals_npa
	if !_rc {
		capture gen individuals = individuals_npa + individuals_pa
	}
	foreach type in received approved notapproved {
		capture confirm variable snap_npa_apps_`type' 
		if !_rc {
			replace snap_apps_`type' = snap_npa_apps_`type' + snap_pa_apps_`type' if missing(snap_apps_`type') & !missing(snap_npa_apps_`type') & !missing(snap_pa_apps_`type')
			assert !missing(snap_apps_`type') if !missing(snap_npa_apps_`type') & !missing(snap_pa_apps_`type')
		}
		capture drop snap_npa_apps_`type'
		capture drop snap_pa_apps_`type'
	}
	capture rename snap_apps_received 		apps_received
	capture rename snap_apps_approved 		apps_approved
	capture rename snap_apps_notapproved 	apps_denied

	// rename to combine 
	**KP: need to copy this to combine_state_ym
	capture rename issuancehousehold 	avg_issuance_households
	capture rename issuance_percase 	avg_issuance_households
	capture rename avg_pay_per_case 	avg_issuance_households
	capture rename avg_payment_percase 	avg_issuance_households
	capture rename issuanceperson 		avg_issuance_individuals
	capture rename issuance_perrecip	avg_issuance_individuals
	capture rename avg_pay_per_person	avg_issuance_individuals
	capture drop issuancehousehold
	capture drop issuance_percase
	capture drop avg_pay_per_case
	capture drop avg_payment_percase
	capture drop issuanceperson
	capture drop issuance_perrecip
	capture drop avg_pay_per_person
	capture rename avg_recip_per_case	avg_individuals_households
	capture drop avg_recip_per_case
	capture rename apps apps_received
	capture drop apps 
	
	// save 
	tempfile `state'
	save ``state''
}

// data is already only state-month level
foreach state of local states_only {

	// display
	display in red "`state'"
	display in red "Nothing can be done"
	
	// rename to combine 
	**KP: need to copy this to combine_state_ym
	**capture rename issuancehousehold 	avg_issuance_households
	**capture rename issuance_percase 	avg_issuance_households
	**capture rename avg_pay_per_case 	avg_issuance_households
	**capture rename avg_payment_percase 	avg_issuance_households
	**capture rename issuanceperson 		avg_issuance_individuals
	**capture rename issuance_perrecip	avg_issuance_individuals
	**capture rename avg_pay_per_person	avg_issuance_individuals
	**capture drop issuancehousehold
	**capture drop issuance_percase
	**capture drop avg_pay_per_case
	**capture drop avg_payment_percase
	**capture drop issuanceperson
	**capture drop issuance_perrecip
	**capture drop avg_pay_per_person
	**capture rename avg_recip_per_case	avg_individuals_households
	**capture drop avg_recip_per_case
	**capture rename apps apps_received
	**capture drop apps 

}

// all ready to go (no "total" observation)
foreach state of local states_collapse {

	// display 
	display in red "`state'"

	// load 
	use "${dir_root}/state_data/`state'/`state'.dta", clear 
	
	// state var 
	gen state = "`state'" 

	// rename to combine 
	**KP: need to copy this to combine_state_ym
	capture rename issuancehousehold 	avg_issuance_households
	capture rename issuance_percase 	avg_issuance_households
	capture rename avg_pay_per_case 	avg_issuance_households
	capture rename avg_payment_percase 	avg_issuance_households
	capture rename issuanceperson 		avg_issuance_individuals
	capture rename issuance_perrecip	avg_issuance_individuals
	capture rename avg_pay_per_person	avg_issuance_individuals
	capture drop issuancehousehold
	capture drop issuance_percase
	capture drop avg_pay_per_case
	capture drop avg_payment_percase
	capture drop issuanceperson
	capture drop issuance_perrecip
	capture drop avg_pay_per_person
	capture rename avg_recip_per_case	avg_individuals_households
	capture drop avg_recip_per_case
	capture rename apps apps_received
	capture drop apps 

	// save 
	tempfile `state'
	save ``state''

}


*************************************************************************************************

foreach state in `states_withtotal' /*`states_only'*/ `states_collapse' {
	if "`state'" == "`first_state'" {
		use ``state'', clear
	}
	else {
		append using ``state''
	}
}

**KP: need to copy this to combined_state_ym.do as well!!!!!

// see what other variables might have the same name and so could be combined
dropmiss, force 
foreach v of varlist _all {
	display in red "`v'"
}
**see and update combine_vars.csv

// combine vars that were not already combined
replace households = snap_households if missing(households) & !missing(snap_households)
replace individuals = snap_recipients if missing(individuals) & !missing(snap_recipients)
foreach v in individuals households issuance {
	assert !missing(`v') if !missing(`v'_npa) & !missing(`v'_pa)	
}

**KP: need to copy this to combined_state_ym.do as well!!!!!

// clean up geography vars 
	// merge in state fips code 
	merge m:1 state using "${dir_root}/state_data/_fips/statefips_2019.dta", keepusing(statefips) assert(2 3) keep(3) nogen 
	// just drop county fips codes for now; I will merge these in my own based on countyname later 
	drop countycode
	drop county_num 
	drop fips 
	// assert no state data 
	assert state_marker == 0 | missing(state_marker)
	drop state_marker
	// drop regional data 
	drop if region_marker == 1
	drop region_marker
**KP: need to address multicounty cases; split evenly or split based on population share among the group of counties

	// merge in fips county codes
	**gen year = year(dofm(ym))
	recast str32 county 
	replace county = ustrregexra(county," ","")
	replace county = strlower(county)
	**merge m:1 statefips year county using "${dir_root}/state_data/_fips/countyfips.dta"
	merge m:1 statefips county using "${dir_root}/state_data/_fips/countyfips_2019.dta", keepusing(countyfips county_og county_type)


**KP: temporary to check merge
drop if _m == 3



keep _m state county countyfips statefips ym individuals households issuance county_og county_type
order state county _m 
sort state county _m 


**KP: temporary

**KP: need to investigate missing counties
*br if _m == 1 & missing(county)

br if _m == 1 & !missing(county)

/*
bysort state: tab county if _m == 1

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-> state = 
no observations

**KP: arkansas: collapse all pulaski county source observations together

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-> state = arkansas

                                 county |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                           pulaski-east |        136       20.00       20.00
                         pulaski-jville |        136       20.00       40.00
                          pulaski-north |        136       20.00       60.00
                           pulaski-s.w. |        136       20.00       80.00
                          pulaski-south |        136       20.00      100.00
----------------------------------------+-----------------------------------
                                  Total |        680      100.00

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-> state = colorado
no observations

in fips data:
*replace hills with hillsborough
*miami-dade: remove - 
*stjohns stlucie: remove .

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-> state = florida

                                 county |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                           hillsborough |        329       25.00       25.00
                              miamidade |        329       25.00       50.00
                                stjohns |        329       25.00       75.00
                                stlucie |        329       25.00      100.00
----------------------------------------+-----------------------------------
                                  Total |      1,316      100.00

in source data: 
**KP: drop dhs as a county 
in fips data: 
*replace ' with missing
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-> state = iowa

                                 county |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                    dhs |         45       50.00       50.00
                                 obrien |         45       50.00      100.00
----------------------------------------+-----------------------------------
                                  Total |         90      100.00


in source data:
**KP: collapse eastbatonrougenorth and eastbatonrougesouth into one county: eastbatonrouge
**KP: collapse jeffersoneastbank and jeffersonwestbank into one county: jefferson
**KP: collapse orleansalgiers and orleansmidtown into one county: orleans
**KP: collapse sabine-many and sabine-zwolle into one county: sabine
**KP: also remove - from county names sabine-many
**KP: also remove . from county names sabine-many, sabine-zwolle
**KP: rename st.john stjohnthebaptist
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-> state = louisiana

                                 county |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                    eastbatonrougenorth |         48        9.76        9.76
                    eastbatonrougesouth |         48        9.76       19.51
                      jeffersoneastbank |         48        9.76       29.27
                      jeffersonwestbank |         48        9.76       39.02
                         orleansalgiers |         48        9.76       48.78
                         orleansmidtown |         48        9.76       58.54
                            sabine-many |         48        9.76       68.29
                          sabine-zwolle |         48        9.76       78.05
                                st.john |        108       21.95      100.00
----------------------------------------+-----------------------------------
                                  Total |        492      100.00


in source data
**KP: drop countyunknown data
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-> state = maine

                                 county |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                          countyunknown |        184      100.00      100.00
----------------------------------------+-----------------------------------
                                  Total |        184      100.00

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-> state = maryland

in source data: 
**KP: rename baltimoreco. baltimore 
                                 county |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                           baltimoreco. |        154      100.00      100.00
----------------------------------------+-----------------------------------
                                  Total |        154      100.00

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-> state = massachusetts
no observations

in source data:
**KP: buren -> vanburen
**KP: clair -> stclair
**KP: isle -> presqueisle (presque and isle might have to be combined)
**KP: joseph -> stjoseph
**KP: presque -> presqueisle (presque and isle might have to be combined)
**KP: traverse -> grandtraverse
**KP: drop unassigned county
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-> state = michigan

                                 county |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                  buren |        139       14.29       14.29
                                  clair |        139       14.29       28.57
                                   isle |        139       14.29       42.86
                                 joseph |        139       14.29       57.14
                                presque |        139       14.29       71.43
                               traverse |        139       14.29       85.71
                             unassigned |        139       14.29      100.00
----------------------------------------+-----------------------------------
                                  Total |        973      100.00


**KP: also remove - from county names 
**KP: millelacsbandtribe -> millelacs
**KP: drop "other"
**KP: redlakeindianresv -> redlake
**KP: whiteearthnation, collapse with mahnomen county
**KP: check numbers on mnprairie; I might have to drop it because I don't know where it belongs

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-> state = minnesota

                                 county |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                   mille-lacs-bandtribe |         77       22.51       22.51
                              mnprairie |         65       19.01       41.52
                                  other |         65       19.01       60.53
                      redlakeindianresv |         58       16.96       77.49
                       whiteearthnation |         77       22.51      100.00
----------------------------------------+-----------------------------------
                                  Total |        342      100.00


**KP: replace & -> and
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-> state = montana

                                 county |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                            lewis&clark |         61      100.00      100.00
----------------------------------------+-----------------------------------
                                  Total |         61      100.00

**KP: rename njtotal -> total

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-> state = newjersey

                                 county |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                njtotal |        318      100.00      100.00
----------------------------------------+-----------------------------------
                                  Total |        318      100.00



**KP: drop centralizedunits
**KP: donaana -> doñaana
**KP: collapse eastdonaana and westdonaana and southdonaana -> doñaana
**KP: collapse eddyartesia eddycarlsbad -> eddy
**KP: collapse northeastbernalillo + northwestbernalillo + southeastbernalillo + southwestbernalillo -> bernalillo
**KP: collapse valencianorth + valenciasouth -> valencia

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-> state = newmexico

                                 county |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                       centralizedunits |         83        8.14        8.14
                                donaana |         13        1.27        9.41
                            eastdonaana |         84        8.24       17.65
                            eddyartesia |         84        8.24       25.88
                           eddycarlsbad |         84        8.24       34.12
                    northeastbernalillo |         84        8.24       42.35
                    northwestbernalillo |         84        8.24       50.59
                           southdonaana |         84        8.24       58.82
                    southeastbernalillo |         84        8.24       67.06
                    southwestbernalillo |         84        8.24       75.29
                          valencianorth |         84        8.24       83.53
                          valenciasouth |         84        8.24       91.76
                            westdonaana |         84        8.24      100.00
----------------------------------------+-----------------------------------
                                  Total |      1,020      100.00

**KP: drop newyorkcity and restofstate (these are regions)

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-> state = newyork

                                 county |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                            newyorkcity |        232       50.00       50.00
                            restofstate |        232       50.00      100.00
----------------------------------------+-----------------------------------
                                  Total |        464      100.00

**KP: drop nocaseworkerassigned
**KP: def/paulding: paulding borders defiance county; so if there is no defiance county in the source data, use population to split the counts between those two counties, following the virginia procedure
**KP: not sure which this is; drop it? southcentral

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-> state = ohio

                                 county |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                           def/paulding |         74       46.25       46.25
                   nocaseworkerassigned |          2        1.25       47.50
                           southcentral |         84       52.50      100.00
----------------------------------------+-----------------------------------
                                  Total |        160      100.00

**KP: this didn't merge because of the year (only in 2014 fips data)
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-> state = southdakota

                                 county |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                shannon |         27      100.00      100.00
----------------------------------------+-----------------------------------
                                  Total |         27      100.00

**KP: drop callcenters, stateoffice
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-> state = texas

                                 county |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                            callcenters |         76       50.00       50.00
                            stateoffice |         76       50.00      100.00
----------------------------------------+-----------------------------------
                                  Total |        152      100.00


work on virginia separately; some issue with county and city
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-> state = virginia

                                 county |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                    alleghany/covington |        224        5.17        5.17
            augusta/staunton/waynesboro |        171        3.95        9.12
                     bedfordcounty/city |        150        3.46       12.58
           chesterfield/colonialheights |        224        5.17       17.75
                           cliftonforge |          9        0.21       17.96
                                fairfax |        448       10.34       28.30
         fairfaxcounty/city/fallschurch |        224        5.17       33.47
                               franklin |        448       10.34       43.81
                    greensville/emporia |        224        5.17       48.98
                    halifax/southboston |        178        4.11       53.09
                     henry/martinsville |        224        5.17       58.26
                               richmond |        448       10.34       68.61
                                roanoke |        448       10.34       78.95
                    roanokecounty/salem |        178        4.11       83.06
        rockbridge/buenavista/lexington |        224        5.17       88.23
                rockingham/harrisonburg |        224        5.17       93.40
                            southboston |          9        0.21       93.61
                       staunton/augusta |         53        1.22       94.83
                          york/poquoson |        224        5.17      100.00
----------------------------------------+-----------------------------------
                                  Total |      4,332      100.00


**KP: remove - 
**KP: can't figure out what these places are: badriver, laccourteoreilles, lacduflambeau, potawatomi, redcliff, stockbridge-munsee
**KP: they might be native american tribes??
**KP: drop enrollmentservices*, stateagency
**KP: if there is no separate oneida county, oneidanation -> oneida


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-> state = wisconsin

                                 county |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                               badriver |        120       12.50       12.50
                    enrollmentservices* |         12        1.25       13.75
                      laccourteoreilles |         96       10.00       23.75
                          lacduflambeau |        120       12.50       36.25
                           oneidanation |        120       12.50       48.75
                             potawatomi |        120       12.50       61.25
                               redcliff |        120       12.50       73.75
                          sokaogontribe |        120       12.50       86.25
                            stateagency |         12        1.25       87.50
                     stockbridge-munsee |        120       12.50      100.00
----------------------------------------+-----------------------------------
                                  Total |        960      100.00


. 
KEEP GOING HERE 

*/


check

// label vars 
label var individuals "Individuals"
label var households "Households"
label var issuance "Issuance"
label var adults "Adults"
label var children "Children"

// order and sort 
order state county ym individuals households issuance adults children 
sort state county ym 

// save 
save "${dir_root}/state_data/county_ym.dta", replace 

