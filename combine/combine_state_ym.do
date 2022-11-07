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
	massachusetts // moved here because I collapsed things sooner 
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
   	maryland // moved here because not all variables have a state total 
	michigan		
; 
#delimit cr 

***********************************************************************************

// data is there already when county = "total"
foreach state of local states_withtotal {
	
	// display
	display in red "`state'"

	// global: so that this carries through to the helper dofile
	global state "`state'"

	// load 
	use "${dir_root}/data/state_data/`state'/`state'.dta", clear

	// keep total 
	if "`state'" == "massachusetts" {
		keep if city == "total"
		drop city 
	}
	else {
		keep if county == "total"
		drop county
	}
	
	// state variable 
	gen state = "`state'"

	// drop all missing vars 
	dropmiss, force 

	// code to combine / standardize variable names across states 
	do "${dir_code}/combine/combine_state_vars.do"

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

	// global: so that this carries through to the helper dofile
	global state "`state'"

	// load
	use "${dir_root}/data/state_data/`state'/`state'.dta", clear

	// state var 
	gen state = "`state'"

	// code to combine / standardize variable names across states 
	do "${dir_code}/combine/combine_state_vars.do"

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

	// global: so that this carries through to the helper dofile
	global state "`state'"

	// load 
	use "${dir_root}/data/state_data/`state'/`state'.dta", clear 

	// state var 
	gen state = "`state'" 

	// maryland: drop state totals
	// because not all variables have a state total 
	if "${state}" == "maryland" {
		drop if county == "total"
	}

	// make sure there are no totals 
	count if county == "total"	
	assert `r(N)' == 0

	// code to combine / standardize variable names across states 
	do "${dir_code}/combine/combine_state_vars.do"

	// variables list 
	noisily describe, varlist 

	// setup varlist for later
	describe, varlist
	local variable_list "`r(varlist)'"

	// keep varlist 
	#delimit ;
	local keep_varlist_short
	/*households*/
	/*individuals*/
	issuance
	adults
	children
	infants
	elderly
	disabled
	gender_female
	gender_male
	ethnicity_hispanic
	ethnicity_nonhispanic
	race_africanamericanorblack
	race_asian
	race_morethanonerace
	race_nativeamericanoralaskanna
	race_nativehawaiianorpacificis
	race_unknownnotdeclared
	race_white
	apps_received
	apps_approved
	apps_denied
	apps_denied_needbased
	apps_denied_procedural
	apps_denied_nottimely
	apps_withdrawn
	apps_expedited
	apps_expedited_elig
	apps_expedited_notelig
	/**/
	apps_timely 
	apps_untimely
	apps_timely_perc
	apps_expedited_timely
	apps_expedited_untimely
	apps_notexpedited_timely
	apps_notexpedited_untimely
	/**/
	households_carryover_start
	households_new 
	households_new_apps
	households_new_change_pacfnacf
	households_new_change_county
	households_new_reinstated
	households_new_other
	firsttimehouseholds
	recerts
	recerts_approved
	recerts_denied
	recerts_deniedB
	recerts_denied_procedural
	recerts_denied_needbased
	c_1_statetotal
	c_2_earnedincometotal
	c_2_othereligibilitytotal
	c_2_otherreasonstotal
	c_2_proceduralreasonstotal
	c_2_sanctionreasonstotal
	c_2_unearnedincometotal
	c_2_voluntarywithdrawal
	c_3_abawdindividualfailedtomeet
	c_3_changeinstatelaworpolicy
	c_3_citizenshipnotmet
	c_3_clientrequest
	c_3_convictedofipv
	c_3_deathofapplicantheadofhouse
	c_3_decreaseneedorexpenses
	c_3_doesnotpurchasepreparemeals
	c_3_doesnotreceivessi
	c_3_drugconviction
	c_3_expiredredetermination
	c_3_failednetincometest
	c_3_failedrefusedtoprovideverif
	c_3_failedtocomplywithlajet
	c_3_failedtocomplywithlwc
	c_3_failedtokeepappointment
	c_3_failedtoprovidecompletesemi
	c_3_failedtoregisterforworkhire
	c_3_failedtotimelyreapply
	c_3_failureduetoeandtsanction
	c_3_failureduetovoluntarywithdr
	c_3_grossinceligibilitynetexcee
	c_3_grossincomeineligible
	c_3_headofhhpayeelefthome
	c_3_householdmemberdisqualified
	c_3_includedinanothercertificat
	c_3_increaseinchildsupport
	c_3_increaseincontributions
	c_3_increaseinotherfederalbenef
	c_3_increaseinotherstatebenefit
	c_3_increaseinsocialsecurityors
	c_3_increaseinwagesornewemploym
	c_3_individualdoesnotmeetagereq
	c_3_individualdoesnotmeetprogra
	c_3_institutionalizationincarce
	c_3_livingwithchildunderage22la
	c_3_livingwithspouselacaponly
	c_3_movedoutofstate
	c_3_noeligiblechildmemberintheh
	c_3_nolongerinlivingarrangement
	c_3_notaonepersonhouseholdineli
	c_3_originallyineligible
	c_3_otherdisasterclosuresinclud
	c_3_questionableinformationnotp
	c_3_refusedtocomplywitheligibil
	c_3_refusedtocomplywithpres
	c_3_refusedtocomplywithqualityc
	c_3_residenceoutofparish
	c_3_residencerequirementnotmet
	c_3_resourcesoverlimit
	c_3_selectedregularfsbecauseofe
	c_3_transferredresources
	c_3_unabletolocate
	c_3_voluntaryquitwithoutgoodcau
	medicaid_households
	medicaid_individuals
	medicaid_children
	medicaid_elderly_disabled
	medicaid_apps_received
	medicaid_apps_approved
	tanf_households
	tanf_individuals
	tanf_issuance
	tanf_children
	tanf_adults
	tanf_apps_received
	tanf_apps_approved
	tanf_apps_denied
	;
	#delimit cr

	// collapse each var 
	foreach v in households individuals `keep_varlist_short' {

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
		local keep_varlist individuals households `keep_varlist_short'
	}
	else {
		local keep_varlist households individuals `keep_varlist_short'	
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
**see and update combine_vars.csv -- not updated as of 2022-09-11; best reference is combine_state_vars.do

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

// order and sort 
order state ym `keep_varlist'
sort state ym 

// check where vars are nonmissing 
foreach var in `keep_varlist' {
	display in red "`var'"
	tab state if !missing(`var')
}

// save 
save "${dir_root}/data/state_data/state_ym.dta", replace 

check
