// combine_county_ym.do 
// Kelsey Pukelis

local first_state alabama
#delimit ;
local states_withcounty
	alabama
	arizona
	arkansas
	illinois
	iowa
	kansas
	louisiana
	maine
	massachusetts // moved here because I collapsed things sooner 
	minnesota
	missouri
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
	california
	florida
	idaho
   	maryland // moved here because not all variables have a state total 	
	michigan	
	colorado 
; 
#delimit cr 

// conditions to combine observations together into a single county 
local county_collapse_list 	pulaski eastbatonrouge jefferson orleans sabine mahnomen /*doñaana eddy bernalillo valencia*/
local cond_pulaski 			`"state == "arkansas" & inlist(county,"pulaskieast","pulaskijville","pulaskinorth","pulaskisw","pulaskisouth")"'
local cond_eastbatonrouge	`"state == "louisiana" & inlist(county,"eastbatonrougenorth","eastbatonrougesouth")"'
local cond_jefferson		`"state == "louisiana" & inlist(county,"jeffersoneastbank","jeffersonwestbank")"'
local cond_orleans			`"state == "louisiana" & inlist(county,"orleansalgiers","orleansmidtown","orleansgentilly","orleansuptown")"'
local cond_sabine			`"state == "louisiana" & inlist(county,"sabinemany","sabinezwolle")"'
local cond_mahnomen			`"state == "minnesota" & inlist(county,"mahnomen","whiteearthnation")"'
*local cond_doñaana			`"state == "newmexico" & inlist(county,"eastdonaana","westdonaana","southdonaana")"'
*local cond_eddy				`"state == "newmexico" & inlist(county,"eddyartesia","eddycarlsbad")"'
*local cond_bernalillo		`"state == "newmexico" & inlist(county,"northeastbernalillo","northwestbernalillo","southeastbernalillo","southwestbernalillo")"'
*local cond_valencia			`"state == "newmexico" & inlist(county,"valencianorth","valenciasouth")"'
*local cond_	`"state == "" & inlist(county,)"'

***********************************************************************************
/*
// data is there already when county = "total"
foreach state of local states_withcounty {
	
	// display
	display in red "`state'"

	// global: so that this carries through to the helper dofile
	global state "`state'"

	// load 
	use "${dir_root}/data/state_data/`state'/`state'.dta", clear

	// keep total 
	drop if county == "total"
	
	// state variable 
	gen state = "`state'"

	// drop all missing vars 
	dropmiss, force 

	// drop fips 
	capture drop fips 
	capture drop countycode 
	capture drop county_num

	// code to combine / standardize variable names across states 
	do "${dir_code}/combine/combine_county_vars.do"

	// variables list 
	noisily describe, varlist 

	// save 
	tempfile `state'
	save ``state''
}


*************************************************************************************************

foreach state in `states_withcounty' {
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
**KP: this hasn't been updated

// assert vars are combined
foreach v in individuals households issuance {
	assert !missing(`v') if !missing(`v'_npa) & !missing(`v'_pa)	
}

**TEMPORARY
save "${dir_root}/data/state_data/county_ym_TEMP.dta", replace 
*/
////////////////////
// GEOGRAPHY VARS //
////////////////////
/*
**TEMPORARY
use "${dir_root}/data/state_data/county_ym_TEMP.dta", clear

// merge in state fips codes 
merge m:1 state using "${dir_root}/data/state_data/_fips/statefips_2019.dta", keepusing(statefips) assert(2 3) keep(3) nogen 

// assert no state data 
assert state_marker == 0 | missing(state_marker)
drop state_marker

// drop regional data 
drop if region_marker == 1
drop region_marker

// drop multicounty data 
drop if multicounty_marker == 1
drop multicounty_marker

// assert county data only 
assert county_marker == 1 | missing(county_marker) | county == "other/virtual totals"

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

**TEMPORARY
save "${dir_root}/data/state_data/county_ym_TEMP2.dta", replace 
*/
**TEMPORARY
use "${dir_root}/data/state_data/county_ym_TEMP2.dta", clear

// drop data that is not actually a county 
drop if state == "arkansas" 	& county == "acpu"
drop if state == "arkansas" 	& county == "acpuvi"
drop if state == "iowa" 		& county == "dhs"
drop if state == "maine" 		& county == "countyunknown"
drop if state == "massachusetts" & county== "notavailable"
drop if state == "michigan" 	& county == "unassigned"
drop if state == "michigan" 	& inlist(county,"presque","isle") // each of these is a repeat of the presqueisle county 
drop if state == "minnesota"	& county == "other"
drop if state == "newmexico" 	& county == "centralizedunits"
drop if state == "newyork"		& county == "newyorkcity"
drop if state == "newyork"		& county == "restofstate"
drop if state == "northcarolina" & county== "notassigned"
drop if state == "ohio" 		& county == "nocaseworkerassigned"
drop if state == "texas"		& county == "callcenters"
drop if state == "texas"		& county == "stateoffice"
drop if state == "wisconsin"	& inlist(county,"enrollmentservices*","enrollmentservices")
drop if state == "wisconsin"	& county == "stateagency"
drop if state == "louisiana"	& county == "downtown" // dropping it because I don't know where it belongs
drop if state == "minnesota" 	& county == "mnprairie" // dropping it because I don't know where it belongs
drop if state == "minnesota" 	& county == "millelacsbandtribe" // potentially combine with millelacs county instead
drop if state == "minnesota" 	& county == "redlakeindianresv" // potentially combine with redlake county instead
drop if state == "minnesota" 	& county == "wphs" // dropping it because I don't know where it belongs
drop if state == "missouri" 	& county == "unknown"
drop if state == "ohio"			& county == "southcentral" // dropping it because I don't know where it belongs
drop if state == "ohio" 		& county == "unknown"
drop if state == "oregon" 		& county == "blank"
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
replace county = "stmarys"			if state == "maryland" & county == "saintmarys"
replace county = "vanburen" 		if state == "michigan" & county == "buren"
replace county = "stclair"	 		if state == "michigan" & county == "clair"
replace county = "stjoseph" 		if state == "michigan" & county == "joseph"
replace county = "grandtraverse" 	if state == "michigan" & county == "traverse"
replace county = "doñaana" 			if state == "newmexico" & county == "donaana"

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
merge m:1 statefips county using "${dir_root}/data/state_data/_fips/countyfips_2019.dta", keepusing(countyfips county_og county_type)
bysort state: tab county if _m == 1
drop if _m == 2
#delimit ;
assert 	inlist(_m,3) | 
		(inlist(_m,1) & state == "southdakota" & county == "shannon") | /*this didn't merge because of the year (only in 2014 fips data)*/
		(inlist(_m,1) & state == "louisiana" & strpos(county,"virtual")) | /*virtual counties won't match */
		(inlist(_m,1) & state == "louisiana" & county == "other") /*other counties won't match */
;
#delimit cr 
replace countyfips = 114 if state == "southdakota" & county == "shannon" 
replace county_og = "shannon county" if state == "southdakota" & county == "shannon" 
replace county_type = "county" if state == "southdakota" & county == "shannon" 
drop _m 

// make sure one observation per county ym 
*duplicates tag state county ym, gen(dup)
*drop if dup == 1 & source_ym > ym(2021,1) & !missing(source_ym)
*drop dup 
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
save "${dir_root}/data/state_data/county_ym.dta", replace 

check