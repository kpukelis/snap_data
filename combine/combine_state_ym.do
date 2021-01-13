// combine_state_ym.do 
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
	newjersey
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

#delimit ;
local states_collapse
	florida
	idaho
	massachusetts
	michigan		
; 
#delimit cr 

***********************************************************************************

// data is there already when county = "total"
foreach state of local states_withtotal {
	
	// display
	display in red "`state'"

	// load 
	use "${dir_root}/state_data/`state'/`state'.dta", clear
	
	// keep total 
	keep if county == "total"
	drop county

	// state variable 
	gen state = "`state'"

	// rename to combine 
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
**KP: missouri will move when updated	
foreach state of local states_only {

	// display
	display in red "`state'"

	// load
	use "${dir_root}/state_data/`state'/`state'.dta", clear

	// state var 
	gen state = "`state'"

	// rename to combine 
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

// need to collapse to get state total
foreach state of local states_collapse {

	// display
	display in red "`state'"

	// load 
	use "${dir_root}/state_data/`state'/`state'.dta", clear 

	// state var 
	gen state = "`state'" 

	// rename to combine 
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

	// setup varlist for later
	describe, varlist
	local variable_list "`r(varlist)'"

	// collapse each var 
	foreach v in individuals households issuance adults children {
		
		capture confirm variable `v' 
		if !_rc {
			preserve 
			collapse (sum) `v', by(state ym)
			tempfile `v'
			save ``v''
			restore
		}
		else {
			preserve
			keep state ym 
			duplicates drop
			gen `v' = .
			tempfile `v'
			save ``v''
			restore
		}

	}

	// merge 
	foreach v in individuals households issuance adults children {
		if strpos("`variable_list'","`v'") {
			if "`v'" == "individuals" {
				use ``v'', clear
			}
			else {
				merge 1:1 state ym using ``v'', assert(3) nogen
			}
		}
	}

	// save 
	tempfile `state'
	save ``state''

}


*************************************************************************************************

// append all states 
foreach state in `states_withtotal' `states_only' `states_collapse' {
	if "`state'" == "`first_state'" {
		use ``state'', clear
	}
	else {
		append using ``state''
	}
}

// see what other variables might have the same name and so could be combined
dropmiss, force 
foreach v of varlist _all {
	display in red "`v'"
}
**see and update combine_vars.csv

// assert vars are combined
foreach v in individuals households issuance {
	assert !missing(`v') if !missing(`v'_npa) & !missing(`v'_pa)	
}

// label vars 
label var individuals "Individuals"
label var households "Households"
label var issuance "Issuance"
label var adults "Adults"
label var children "Children"

// order and sort 
order state ym 
sort state ym 

// save 
save "${dir_root}/state_data/state_ym.dta", replace 

