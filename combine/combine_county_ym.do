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

**KP: need to merge in fips county codes

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
save "${dir_root}/county_data/county_ym.dta", replace 

