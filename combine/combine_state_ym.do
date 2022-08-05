// combine_state_ym.do 
// Kelsey Pukelis

//	alabama			 // not completed (fixed individual)
// 	alaska			 fixed statewide 
//	connecticut		 // not completed (fixed individual)
// 	delaware		 rolling clock
//	hawaii			 // not completed (rolling clock)
//	illinois		 fixed statewide
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

#delimit ;
local first_state arizona
;

local states_withtotal
	arizona
	arkansas
	colorado
	illinois
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
	oregon
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
	missouri // county needs to be cleaned
	nebraska		
; 
#delimit cr 

#delimit ;
local states_collapse
	california
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
	use "${dir_root}/data/state_data/`state'/`state'.dta", clear
	
	// keep total 
	keep if county == "total"
	drop county

	// state variable 
	gen state = "`state'"

	// drop all missing vars 
	dropmiss, force 

	// rename to combine 
	capture rename issuancehousehold 	avg_issuance_households
	capture rename issuance_percase 	avg_issuance_households
	capture rename avg_pay_per_case 	avg_issuance_households
	capture rename avg_payment_percase 	avg_issuance_households
	capture rename issuanceperson 		avg_issuance_individuals
	capture rename issuance_perrecip	avg_issuance_individuals
	capture rename avg_pay_per_person	avg_issuance_individuals
	*capture drop issuancehousehold
	*capture drop issuance_percase
	*capture drop avg_pay_per_case
	*capture drop avg_payment_percase
	*capture drop issuanceperson
	*capture drop issuance_perrecip
	*capture drop avg_pay_per_person
	capture rename avg_recip_per_case	avg_individuals_households
	*capture drop avg_recip_per_case
	// ***apps_received CA MO TX NM MD LA AK
	// ***apps_approved CA MO NM MD LA AK
	// apps_disposed CA 
	// ***apps_denied CA MO MD LA AK
	// apps_withdrawn CA
	// apps_expedited CA MO
	// apps_timely TX
		// apps_nottimely CA
		// pendingdays* AK
		// avg_days_process?? MO
	// recerts CA
		// rename: recerts_disposed TX
		// households_cert MD
	// recerts_elig CA
	// recerts_inelig CA
	// recerts_overdue CA
		// recert_timely TX 
		// overdue* AK
	// ***children MO  TX SD  OR  OH NM NJ LA KS AZ MI
	// ***adults  (MO) TX SD (OR) OH NM NJ LA KS AZ MI
	// ***generate infants 
		// age_00_04 TX
		if "`state'" == "texas" {
			gen infants = age_00_04 	
		}
		// age_0_5 OR
		if "`state'" == "oregon" {
			gen infants = age_0_5
		}
		// female_00_05 WI
		// male_00_05 WI 
		if "`state'" == "wisconsin" {
			gen infants = rowtotal(female_00_05 male_00_05)
		}
	// age_05_17 TX
	// age_18_59 MO TX
	// ***generate elderly
		// age_60_64 TX
		// age_65    TX
		if "`state'" == "texas" {
			egen elderly = rowtotal(age_60_64 age_65)
		}
		// age_60    MO OR NJ
		if "`state'" == "missouri" | "`state'" == "newjersey" | "`state'" == "oregon" {
			gen elderly = age_60
		}
		// female_65plus WI
		// male_65plus WI
		if "`state'" == "wisconsin" {
			egen elderly = rowtotal(female_65plus male_65plus)
		}
	// ***disabled MO NJ
	// ***generate female, male
		// gender_female NM
		// gender_male NM
		// female_00_05 WI
		// female_06_17 WI
		// female_18_34 WI
		// female_35_49 WI
		// female_50_64 WI
		// female_65plus WI
		if "`state'" == "wisconsin" {
			egen gender_female = rowtotal(female_00_05 female_06_17 female_18_34 female_35_49 female_50_64 female_65plus)
		}
		// male_00_05 WI
		// male_06_17 WI
		// male_18_34 WI
		// male_35_49 WI
		// male_50_64 WI
		// male_65plus WI
		if "`state'" == "wisconsin" {
			egen gender_male = rowtotal(male_00_05 male_06_17 male_18_34 male_35_49 male_50_64 male_65plus)
		}																	

	// variables list 
	noisily describe, varlist 

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
	use "${dir_root}/data/state_data/`state'/`state'.dta", clear

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
	*capture drop issuancehousehold
	*capture drop issuance_percase
	*capture drop avg_pay_per_case
	*capture drop avg_payment_percase
	*capture drop issuanceperson
	*capture drop issuance_perrecip
	*capture drop avg_pay_per_person
	capture rename avg_recip_per_case	avg_individuals_households
	*capture drop avg_recip_per_case
	// ***apps_received CA MO TX NM MD LA AK NC
	// ***apps_approved CA MO NM MD LA AK
	// apps_disposed CA 
	// ***apps_denied CA MO MD LA AK
	// apps_withdrawn CA
	// apps_expedited CA MO
	// apps_timely TX
		// apps_nottimely CA
		// pendingdays* AK
		// avg_days_process?? MO
	// recerts CA
		// rename: recerts_disposed TX
		// households_cert MD
	// recerts_elig CA
	// recerts_inelig CA
	// recerts_overdue CA
		// recert_timely TX 
		// overdue* AK
	// ***children MO  TX SD  OR  OH NM NJ LA KS AZ MI
	// ***adults  (MO) TX SD (OR) OH NM NJ LA KS AZ MI
	// ***generate infants 
		// age_00_04 TX
		if "`state'" == "texas" {
			gen infants = age_00_04 	
		}
		// age_0_5 OR
		if "`state'" == "oregon" {
			gen infants = age_0_5
		}
	// age_05_17 TX
	// age_18_59 MO TX
	// ***generate elderly
		// age_60_64 TX
		// age_65    TX
		if "`state'" == "texas" {
			egen elderly = rowtotal(age_60_64 age_65)
		}
		// age_60    MO OR NJ
		if "`state'" == "missouri" | "`state'" == "newjersey" | "`state'" == "oregon" {
			gen elderly = age_60
		}
	// ***disabled MO NJ

	// variables list 
	noisily describe, varlist 

	// save 
	tempfile `state'
	save ``state''
}

// need to collapse to get state total
foreach state of local states_collapse {

	// display
	display in red "`state'"

	// load 
	use "${dir_root}/data/state_data/`state'/`state'.dta", clear 

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
	*capture drop issuancehousehold
	*capture drop issuance_percase
	*capture drop avg_pay_per_case
	*capture drop avg_payment_percase
	*capture drop issuanceperson
	*capture drop issuance_perrecip
	*capture drop avg_pay_per_person
	capture rename avg_recip_per_case	avg_individuals_households
	*capture drop avg_recip_per_case
	// ***apps_received CA MO TX NM MD LA AK
	// ***apps_approved CA MO NM MD LA AK
	// apps_disposed CA 
	// ***apps_denied CA MO MD LA AK
	// apps_withdrawn CA
	// apps_expedited CA MO
	// apps_timely TX
		// apps_nottimely CA
		// pendingdays* AK
		// avg_days_process?? MO
	// recerts CA
		// rename: recerts_disposed TX
		// households_cert MD
	// recerts_elig CA
	// recerts_inelig CA
	// recerts_overdue CA
		// recert_timely TX 
		// overdue* AK
	// ***children MO  TX SD  OR  OH NM NJ LA KS AZ MI
	// ***adults  (MO) TX SD (OR) OH NM NJ LA KS AZ MI
	// ***generate infants 
		// age_00_04 TX
		if "`state'" == "texas" {
			gen infants = age_00_04 
			capture drop age_00_04	
		}
		// age_0_5 OR
		if "`state'" == "oregon" {
			gen infants = age_0_5
			capture drop age_0_5
		}
	// age_05_17 TX
	// age_18_59 MO TX
	// ***generate elderly
		// age_60_64 TX
		// age_65    TX
		if "`state'" == "texas" {
			egen elderly = rowtotal(age_60_64 age_65)
			capture drop age_60_64
			capture drop age_65
		}
		// age_60    MO OR NJ
		if "`state'" == "missouri" | "`state'" == "newjersey" | "`state'" == "oregon" {
			gen elderly = age_60
			capture drop age_60
		}
	// ***disabled MO NJ

	// variables list 
	noisily describe, varlist 

	// setup varlist for later
	describe, varlist
	local variable_list "`r(varlist)'"

	// collapse each var 
	foreach v in households individuals issuance adults children apps_received apps_approved apps_denied infants elderly disabled {
		display in red "`v'"

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
	if inlist("`state'","idaho") {
		local keep_varlist individuals households issuance adults children apps_received apps_approved apps_denied infants elderly disabled
	}
	else {
		local keep_varlist households individuals issuance adults children apps_received apps_approved apps_denied infants elderly disabled	
	}
	foreach v in `keep_varlist' {
		if strpos("`variable_list'","`v'") {
			if inlist("`state'","idaho") {
				if "`v'" == "individuals" {
					use ``v'', clear
				}
				else {
					merge 1:1 state ym using ``v'', assert(3) nogen
				}
			}
			else {
				if "`v'" == "households" {
					use ``v'', clear
				}
				else {
					merge 1:1 state ym using ``v'', assert(3) nogen
				}
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
label var apps_received "Applications received"
label var apps_approved "Applications approved"
label var apps_denied "Applications denied"
label var infants "Infants (age < 5)"
label var elderly "Elderly (age > 60)"
label var disabled "Disabled"
*label var gender_*
*label var ethnicity_*
*label var race_*

// assert level of data 
duplicates tag state ym, gen(dup)
assert dup == 0
drop dup 

// calculate adults where needed 
assert missing(adults) if inlist(state,"missouri","oregon")
replace adults = individuals - children if inlist(state,"missouri","oregon")

// order and sort 
order state ym individuals households issuance adults children apps_received apps_approved apps_denied infants elderly disabled
sort state ym 

// check where vars are nonmissing 
foreach var in individuals households issuance adults children apps_received apps_approved apps_denied infants elderly disabled {
	display in red "`var'"
	tab state if !missing(`var')
}

// save 
save "${dir_root}/data/state_data/state_ym.dta", replace 

