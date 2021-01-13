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

**KP: coming back to these
//	illinois			
//  missouri
//	oregon			
//  massachusetts
//  colorado

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
**KP: missouri will move when updated	

#delimit ;
local states_collapse
	florida
	idaho
	massachusetts
	michigan		
; 
#delimit cr 

// conditions to combine observations together into a single county 
local county_collapse_list 	pulaski eastbatonrouge jefferson orleans sabine mahnomen doñaana eddy bernalillo valencia
local cond_pulaski 			`"state == "arkansas" & inlist(county,"pulaskieast","pulaskijville","pulaskinorth","pulaskisw","pulaskisouth")"'
local cond_eastbatonrouge	`"state == "louisiana" & inlist(county,"eastbatonrougenorth","eastbatonrougesouth")"'
local cond_jefferson		`"state == "louisiana" & inlist(county,"jeffersoneastbank","jeffersonwestbank")"'
local cond_orleans			`"state == "louisiana" & inlist(county,"orleansalgiers","orleansmidtown")"'
local cond_sabine			`"state == "louisiana" & inlist(county,"sabinemany","sabinezwolle")"'
local cond_mahnomen			`"state == "minnesota" & inlist(county,"mahnomen","whiteearthnation")"'
local cond_doñaana			`"state == "newmexico" & inlist(county,"eastdonaana","westdonaana","southdonaana")"'
local cond_eddy				`"state == "newmexico" & inlist(county,"eddyartesia","eddycarlsbad")"'
local cond_bernalillo		`"state == "newmexico" & inlist(county,"northeastbernalillo","northwestbernalillo","southeastbernalillo","southwestbernalillo")"'
local cond_valencia			`"state == "newmexico" & inlist(county,"valencianorth","valenciasouth")"'
*local cond_	`"state == "" & inlist(county,)"'

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
foreach state of local states_only {

	// display
	display in red "`state'"
	display in red "Nothing can be done"
	
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

// see what other variables might have the same name and so could be combined
dropmiss, force 
foreach v of varlist _all {
	display in red "`v'"
}
**see and update combine_vars.csv
**see code below that may need to be updated

// assert vars are combined
foreach v in individuals households issuance {
	assert !missing(`v') if !missing(`v'_npa) & !missing(`v'_pa)	
}

////////////////////
// GEOGRAPHY VARS //
////////////////////
	
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

// **KP: drop non county data for now, come back to these states later: 
tab state if missing(county)
drop if inlist(state,"massachusetts","colorado")

// remove puntuation from countynames 
replace county = ustrregexra(county," ","")
replace county = ustrregexra(county,"\.","")
replace county = ustrregexra(county,"-","")
replace county = ustrregexra(county,"\*","")
replace county = ustrregexra(county,"\&","and")
replace county = ustrregexra(county,`"`=char(34)'"',"") // single quotation
replace county = ustrregexra(county,`"'"',"")
replace county = ustrregexra(county,`"/"',"")
replace county = strlower(county)

// drop data that is not actually a county 
drop if state == "iowa" 		& county == "dhs"
drop if state == "maine" 		& county == "countyunknown"
drop if state == "michigan" 	& county == "unassigned"
drop if state == "michigan" 	& inlist(county,"presque","isle") // each of these is a repeat of the presqueisle county 
drop if state == "minnesota"	& county == "other"
drop if state == "newmexico" 	& county == "centralizedunits"
drop if state == "newyork"		& county == "newyorkcity"
drop if state == "newyork"		& county == "restofstate"
drop if state == "ohio" 		& county == "nocaseworkerassigned"
drop if state == "texas"		& county == "callcenters"
drop if state == "texas"		& county == "stateoffice"
drop if state == "wisconsin"	& inlist(county,"enrollmentservices*","enrollmentservices")
drop if state == "wisconsin"	& county == "stateagency"
drop if state == "minnesota" 	& county == "mnprairie" // dropping it because I don't know where it belongs
drop if state == "minnesota" 	& county == "millelacsbandtribe" // potentially combine with millelacs county instead
drop if state == "minnesota" 	& county == "redlakeindianresv" // potentially combine with redlake county instead
drop if state == "ohio"			& county == "southcentral" // dropping it because I don't know where it belongs
drop if state == "wisconsin" 	& county == "badriver" // dropping it because I don't know where it belongs (for now)
drop if state == "wisconsin" 	& county == "laccourteoreilles" // dropping it because I don't know where it belongs (for now)
drop if state == "wisconsin" 	& county == "lacduflambeau" // dropping it because I don't know where it belongs (for now)
drop if state == "wisconsin" 	& county == "oneidanation" // dropping it because I don't know where it belongs (for now)
drop if state == "wisconsin" 	& county == "potawatomi" // dropping it because I don't know where it belongs (for now)
drop if state == "wisconsin" 	& county == "redcliff" // dropping it because I don't know where it belongs (for now)
drop if state == "wisconsin" 	& county == "sokaogontribe" // dropping it because I don't know where it belongs (for now)
drop if state == "wisconsin" 	& county == "stockbridgemunsee" // dropping it because I don't know where it belongs (for now)

// manually rename counties to match with fips data 
replace county = "stjohnthebaptist" if state == "louisiana" & county == "stjohn"
replace county = "baltimorecounty"	if state == "maryland" & county == "baltimoreco"
replace county = "vanburen" 		if state == "michigan" & county == "buren"
replace county = "stclair"	 		if state == "michigan" & county == "clair"
replace county = "stjoseph" 		if state == "michigan" & county == "joseph"
replace county = "grandtraverse" 	if state == "michigan" & county == "traverse"
replace county = "doñaana" 			if state == "newmexico" & county == "donaana"

// drop duplicates (somehow michigan was duplicated a bunch)
duplicates drop 

// assert level of the data 
duplicates tag state county ym, gen(dup)
assert dup == 0
drop dup 

// collapse some observations together, using rules from local above 
foreach county of local county_collapse_list {

	// display in red 
	display in red "collapsing county `county'"

	// preserve
	preserve

	// keep observations to collapse 
	keep if `cond_`county''

	// make the name the same
	replace county = "`county'"

	// keep only relevant variables 
	dropmiss, force

	// manually drop some vars 
	if inlist("`county'","doñaana","eddy","bernalillo","valencia") {
		drop office
	}

	// create mean or sum across combo counties
	foreach var of varlist _all {
	if !inlist("`var'","state","statefips","county","ym","office","zipcode","city") {
		// **may need to be updated if new vars, if combine_vars.csv is updated
		rename `var' O`var'
		if inlist("`var'","avg_issuance_households","avg_issuance_individuals","avg_individuals_households","participation_rate","percpop_snap") {
			bysort county ym: egen `var' = mean(O`var')
		}
		else {
			bysort county ym: egen `var' = total(O`var')
		}
		drop O`var'
	}
	}

	// make county level 
	duplicates drop 
	duplicates tag county ym, gen(dup)
	assert dup == 0
	drop dup 

	// save this county's data 
	tempfile `county'
	save ``county''

	// restore
	restore

	// drop individual observations 
	drop if `cond_`county''

	// append this new data 
	append using ``county''

}
		
// merge in fips county codes
recast str32 county 
merge m:1 statefips county using "${dir_root}/state_data/_fips/countyfips_2019.dta", keepusing(countyfips county_og county_type)
*bysort state: tab county if _m == 1
drop if _m == 2
assert inlist(_m,3) | (inlist(_m,1) & state == "southdakota" & county == "shannon") // this didn't merge because of the year (only in 2014 fips data)
replace countyfips = 114 if state == "southdakota" & county == "shannon" 
replace county_og = "shannon county" if state == "southdakota" & county == "shannon" 
replace county_type = "county" if state == "southdakota" & county == "shannon" 
drop _m 

// make sure one observation per county ym 
duplicates tag state county ym, gen(dup)
drop if dup == 1 & source_ym > ym(2021,1) & !missing(source_ym)
drop dup 
duplicates tag state county ym, gen(dup)
assert dup == 0
drop dup

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
