// irs990_explore.do 
// Kelsey Pukelis
// explores IRS 990 data, complied by Erik James 

// import 
import delimited using "${dir_root}/data/food_pantry/IRS 990 - James, Erik/county_level_dataset.csv", delimiter(",") clear
*import delimited using "${dir_root}/data/food_pantry/IRS 990 - James, Erik/county_level_dataset_v2.csv", delimiter(",") clear

// preserve order of variables 
qui describe, varlist
global varlist_og `r(varlist)'
display in red "${varlist_og}"

// label variables 
renamefrom using "${dir_root}/data/food_pantry/IRS 990 - James, Erik/dataset_documentation.xlsx", filetype(excel) raw(_IDlowercase) clean(_IDlowercase) label(county_id) keepx
order $varlist_og
sort _id 

// determine level of data 
// is it state county? No.
duplicates tag statefp countyfp, gen(dup)
tab dup 
drop dup 

// is it state county year? almost. 
duplicates tag statefp countyfp year, gen(dup)
tab dup 
sort statefp countyfp year main_fiscal_year
*br _id statefp countyfp year main_fiscal_year* amount_grant* if dup == 1
**KP: for now, just keep first one
by statefp countyfp year: assert inlist(_N,1,2)
by statefp countyfp year: keep if _n == 1 
drop dup 
duplicates tag statefp countyfp year, gen(dup)
assert dup == 0
drop dup 

// turn into balanced panel 

// joint state county id
assert !missing(statefp)
assert !missing(countyfp)
gen statecountyfp = statefp*1000+countyfp
order statecountyfp, after(countyfp)

// statecounty EVER has a food bank grant 
assert !missing(has_food_bank_grant)
assert inlist(has_food_bank_grant,0,1)
bysort statecountyfp: egen has_food_bank_grant_ever = max(has_food_bank_grant)
preserve 
	keep statecountyfp has_food_bank_grant_ever
	duplicates drop 
	sum has_food_bank_grant_ever
	display in red `r(mean)'*100 "percent of counties ever have a food bank grant"
	display in red `r(N)' " total counties listed (denominator)"
restore 

// balanced panel of ONLY areas that ever have a grant 
*preserve 
	keep if has_food_bank_grant_ever == 1
	assert !missing(year)

	// set panel data 
	xtset statecountyfp year 
	tsfill, full 

	// carryforward variables 
	foreach var in _id statefp countyfp stateabbreviation statename countyname territories continental {

		// forward in time
		bysort statecountyfp (year): carryforward `var', replace 

		// backward in time 
		gsort statecountyfp -year
		by statecountyfp: carryforward `var', replace 
		gsort statecountyfp year 

	}

	// carryforward variables, uncertain if this is right 
	foreach var in copop coarea coarealand affid affid1 affid2 fa_fb_region split_shared combine_food_bank population201519acs estimatehouseholdstotal hh_inc_less_than_025 hh_inc_less_than_035 {
	KEEP GOING HERE, WITH THE LIST OF VARIABLES TO FILL IN 

		// forward in time
		bysort statecountyfp (year): carryforward `var', gen(`var'_for) 
		assert `var' == `var'_for if !missing(`var') & !missing(`var'_for)
		bysort statecountyfp (year): carryforward `var', replace 
		drop `var'_for  


		// backward in time 
		gsort statecountyfp -year
		by statecountyfp: carryforward `var', gen(`var'_back) 
		assert `var' == `var'_back if !missing(`var') & !missing(`var'_back)
		by statecountyfp: carryforward `var', replace 
		drop `var'_back
		gsort statecountyfp year 

	}
check
restore



check

