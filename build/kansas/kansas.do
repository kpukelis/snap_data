// kansas.do 

local year_start 			= 2011
local year_end 				= 2023 
local last_year_monthlist 	7 8 9 // 10 11 12 1 2 3 4 5 6
local all_year_monthlist	7 8 9 10 11 12 1 2 3 4 5 6
local year_2021_monthlist 	7 8 9 10 11 12 1 2 3 // this year of data is incomplete
local num_counties 			= 106 // includes total 
local ym_start 				= ym(2010,7)
local ym_end 				= ym(2022,9)

********************************************************************

// STATEWIDE DATA 

// import 
import excel "${dir_root}/data/state_data/kansas/excel/CURRENT_PAR_SFYXXXX_Access.xlsx", allstring case(lower) firstrow clear

// clean up
dropmiss, force 
dropmiss, force obs

// check number of variables
describe, varlist
assert `r(k)' == 9

// date 
destring year, replace 
confirm numeric variable year 
replace month = trim(month)
replace month = strlower(month)
replace month = "1" if month == "january"
replace month = "2" if month == "february"
replace month = "3" if month == "march"
replace month = "4" if month == "april"
replace month = "5" if month == "may"
replace month = "6" if month == "june"
replace month = "7" if month == "july"
replace month = "8" if month == "august"
replace month = "9" if month == "september"
replace month = "10" if month == "october"
replace month = "11" if month == "november"
replace month = "12" if month == "december"
assert !missing(month)
destring month, replace
confirm numeric variable month 
gen ym = ym(year,month)
format ym %tm 
drop year month 

// variable to merge with county level data 
gen county = "total"

// rename to match data below
rename cases 			households
rename persons 			individuals 
rename avgcostpercase 	avg_issuance_households
rename avgcostperperson avg_issuance_individuals
rename expenditures 	issuance

// destring 
foreach var in households adults children individuals avg_issuance_households avg_issuance_individuals issuance {
	destring `var', replace 
	confirm numeric variable `var'
}

// order and sort 
order county ym households individuals issuance adults children avg_issuance_households avg_issuance_individuals
sort county ym 

// save 
tempfile kansas_state 
save `kansas_state'

********************************************************************

// COUNTY DATA 

forvalues year = `year_start'(1)`year_end' {
if inrange(`year',2020,2023) {

// local for monthlist 
if `year' == `year_end' {
	local monthlist `last_year_monthlist'
}	
else if `year' == 2021 {
	local monthlist `year_2021_monthlist'
}
else {
	local monthlist `all_year_monthlist'
}

	foreach month of local monthlist {
	
	display in red "year `year'"
	display in red "month `month'"

	// import data 
	import excel "${dir_root}/data/state_data/kansas/csvs/SFY`year'_CntyCaseload_Rpt.xlsx", sheet("`month'") allstring case(lower) clear
	dropmiss, force
	foreach v of varlist _all {
		replace `v' = trim(`v')
		replace `v' = strlower(`v')
	}
	gen obsnum = _n 

	// make var type for strings shorter, for easier display
	foreach v of varlist _all {
		gen `v'copy = `v'
		drop `v'
		rename `v'copy `v'
	}
	*br
	
	// assert right structure of data 
	describe, varlist 
	assert r(k) == 13

	// variable names 
	else if r(k) == 13 {
		local variable_names `"tanf_households tanf_adults tanf_children tanf_persons households adults children individuals childcare_households childcare_children"'
	}

	// rename variables 
	qui describe, varlist
	rename (`r(varlist)') (county region `variable_names' obsnum)
	drop in 1 
	drop in 1 
	drop in 1 
	if (`year' == 2021 & inlist(`month',7,8,9,10,11,12,1,2,3,4,5,6)) {
		drop in 1
	}

	// assert number of observations 
	count 
	assert `r(N)' == 106

	// destring
	foreach v in `variable_names' {
		destring `v', replace
	}

	// drop region totals data 
	drop if inlist(county,"kansas city","kansas city metro","south central","southeast","northeast","east","west")
	
	// fix county names 
	replace county = "total" if strpos(county,"state total")

	// wichita is both a county and a region, want to keep county, which is first observation within month
	// 2 state total rows are the same, just keep one per month
	count if county == "wichita"
	assert `r(N)' == 1

	// generate date info
	gen month = `month'
	gen year = .
	replace year = `year' if inrange(month,1,6)
	replace year = `year' - 1 if inrange(month,7,12)
	gen ym = ym(year,month)
	format ym %tm 
	drop year month obsnum

	// order and sort 
	order county region ym 
	sort county ym 

	// save 
	tempfile _`year'_`month'
	save `_`year'_`month''

	}

	// append across months 
	foreach month of local monthlist {
		if `month' == 7 {
			use `_`year'_`month'', clear 
		}
		else {
			append using `_`year'_`month''	
		}
	}

	// save 
	tempfile _`year'
	save `_`year''
	
}


********************************************************************

if inrange(`year',2011,2019) {

dis in red "`year'"

// import data 
import excel "${dir_root}/data/state_data/kansas/csvs/SFY`year'_CntyCaseload_Rpt.xlsx", sheet("Table 1") allstring case(lower) clear
dropmiss, force
foreach v of varlist _all {
	replace `v' = trim(`v')
	replace `v' = strlower(`v')
}
gen obsnum = _n 	


#delimit ;
local condition `"if 
!inlist(A,
"allen",
"anderson",
"atchison",
"barber",
"barton",
"bourbon",
"brown",
"butler",
"chase"
) & !inlist(A,
"chautauqua",
"cherokee",
"cheyenne",
"clark",
"clay",
"cloud",
"coffey",
"comanche",
"cowley"
) & !inlist(A,
"crawford",
"decatur",
"dickinson",
"doniphan",
"douglas",
"edwards",
"elk",
"ellis",
"ellsworth"
) & !inlist(A,
"finney",
"ford",
"franklin",
"geary",
"gove",
"graham",
"grant",
"gray",
"greeley"
) & !inlist(A,
"greenwood",
"hamilton",
"harper",
"harvey",
"haskell",
"hodgeman",
"jackson",
"jefferson",
"jewell"
) & !inlist(A,
"johnson",
"kearny",
"kingman",
"kiowa",
"labette",
"lane",
"leavenworth",
"lincoln",
"linn"
) & !inlist(A,
"logan",
"lyon",
"marion",
"marshall",
"mcpherson",
"meade",
"miami",
"mitchell",
"montgomery"
) & !inlist(A,
"morris",
"morton",
"nemaha",
"neosho",
"ness",
"norton",
"osage",
"osborne",
"ottawa"
) & !inlist(A,
"pawnee",
"phillips",
"pottawatomie",
"pratt",
"rawlins",
"reno",
"republic",
"rice",
"riley"
) & !inlist(A,
"rooks",
"rush",
"russell",
"saline",
"scott",
"sedgwick",
"seward",
"shawnee",
"sheridan"
) & !inlist(A,
"sherman",
"smith",
"stafford",
"stanton",
"stevens",
"sumner",
"thomas",
"trego",
"wabaunsee"
) & !inlist(A,
"wallace",
"washington",
"wichita",
"wilson",
"woodson",
"wyandotte"
) & !inlist(A,
"kansas city",
"east",
"west",
"state totals",
"state totals:",
"kansas city metro",
"northeast",
"south central",
"southeast"
)"'
;
#delimit cr

** review this part manually for each year to be sure I'm not missing data
foreach v of varlist _all {
	tab `v' `condition'
}
drop `condition'
dropmiss, force

// make var type for strings shorter, for easier display
foreach v of varlist _all {
	gen `v'copy = `v'
	drop `v'
	rename `v'copy `v'
}
*br

// assert right structure of data 
describe, varlist 
assert r(k) == 17 | r(k) == 13 | r(k) == 41 | r(k) == 18
if r(k) == 18 {
	rename (`r(varlist)') v#, addnumber
	bysort v1 (v18): gen obsnum_incounty = _n 
	levelsof obsnum_incounty, local(obsnum_incounty_nums)
	if `year' == 2020 {
		drop if inrange(obsnum_incounty,4,4)
		levelsof obsnum_incounty, local(obsnum_incounty_nums)
	}
	foreach num of local obsnum_incounty_nums {
		preserve
		display in red `num'
		keep if obsnum_incounty == `num'
		if `num' == 2 {
			local condition inlist(v1,"state totals","wichita")
			replace v5 = v6 if missing(v5) & `condition'
			replace v7 = v8 if missing(v7) & `condition'
			replace v9 = v10 if missing(v9) & `condition'
			replace v11 = v12 if missing(v11) & `condition'
			replace v14 = v13 if missing(v14) & `condition'
			replace v6 = "" if `condition'
			replace v8 = "" if `condition'
			replace v10 = "" if `condition'
			replace v12 = "" if `condition'
			replace v13 = "" if `condition'
		}
		drop obsnum_incounty
		dropmiss, force 
		qui describe, varlist		
		assert r(k) == 13

		local variable_names `"tanf_households tanf_adults tanf_children tanf_persons households adults children individuals childcare_households childcare_children"'

		// rename variables 
		qui describe, varlist
		rename (`r(varlist)') (county region `variable_names' obsnum)

		tempfile little_data`num'
		save `little_data`num''
		restore
	}
	
	clear 
	foreach num of local obsnum_incounty_nums {
		if `num' == 1 {
			use `little_data`num'', clear 
		}
		else {
			append using `little_data`num''
		}
	
	}	
}
***********************
if r(k) == 41 {
	rename (`r(varlist)') v#, addnumber
	bysort v1 (v41): gen obsnum_incounty = _n 
	levelsof obsnum_incounty, local(obsnum_incounty_nums)
	if `year' == 2019 {
		drop if inrange(obsnum_incounty,14,26)
		levelsof obsnum_incounty, local(obsnum_incounty_nums)
	}
	foreach num of local obsnum_incounty_nums {
		preserve
		display in red `num'
		keep if obsnum_incounty == `num'
		if `num' == 2 {
			local condition inlist(v1,"state totals","wichita")
			replace v9 = v10 if missing(v9) & `condition'
			replace v14 = v16 if missing(v4) & `condition'
			replace v18 = v21 if missing(v18) & `condition'
			replace v22 = v25 if missing(v22) & `condition'
			replace v27 = v28 if missing(v27) & `condition'
			replace v31 = v32 if missing(v31) & `condition'
			replace v35 = v36 if missing(v35) & `condition'
			replace v38 = v39 if missing(v9) & `condition'
			replace v10 = "" if `condition'
			replace v16 = "" if `condition'
			replace v21 = "" if `condition'
			replace v25 = "" if `condition'
			replace v28 = "" if `condition'
			replace v32 = "" if `condition'
			replace v36 = "" if `condition'
			replace v39 = "" if `condition'
		}
		if `num' == 3 {
			local condition inlist(v1,"state totals","wichita")
			replace v8 = v9 if missing(v8) & `condition'
			replace v12 = v14 if missing(v12) & `condition'
			replace v17 = v18 if missing(v17) & `condition'
			replace v23 = v22 if missing(v23) & `condition'
			replace v28 = v27 if missing(v28) & `condition'
			replace v31 = v32 if missing(v32) & `condition'
			replace v36 = v35 if missing(v36) & `condition'
			replace v39 = v38 if missing(v39) & `condition'
			replace v9 = "" if `condition'
			replace v14 = "" if `condition'
			replace v18 = "" if `condition'
			replace v22 = "" if `condition'
			replace v27 = "" if `condition'
			replace v32 = "" if `condition'
			replace v35 = "" if `condition'
			replace v38 = "" if `condition'
		}
		if `num' == 4 {
			local condition inlist(v1,"state totals","wichita")
			replace v13 = v14 if missing(v13) & `condition'
			replace v39 = v38 if missing(v39) & `condition'
			replace v14 = "" if `condition'
			replace v38 = "" if `condition'
		}
		if `num' == 5 {
			local condition inlist(v1,"state totals","wichita")
			replace v10 = v8 if missing(v8) & `condition'
			replace v15 = v12 if missing(v15) & `condition'
			replace v18 = v17 if missing(v18) & `condition'
			replace v22 = v23 if missing(v22) & `condition'
			replace v27 = v28 if missing(v27) & `condition'
			replace v31 = v32 if missing(v31) & `condition'
			replace v35 = v36 if missing(v35) & `condition'
			replace v38 = v39 if missing(v38) & `condition'
			replace v8 = "" if `condition'
			replace v12 = "" if `condition'
			replace v17 = "" if `condition'
			replace v23 = "" if `condition'
			replace v28 = "" if `condition'
			replace v32 = "" if `condition'
			replace v36 = "" if `condition'
			replace v39 = "" if `condition'
		}
		if `num' == 6 {
			local condition inlist(v1,"state totals","wichita")
			replace v10 = v8 if missing(v8) & `condition'
			replace v15 = v12 if missing(v15) & `condition'
			replace v18 = v17 if missing(v18) & `condition'
			replace v22 = v23 if missing(v22) & `condition'
			replace v26 = v28 if missing(v26) & `condition'
			replace v30 = v32 if missing(v30) & `condition'
			replace v34 = v36 if missing(v34) & `condition'
			replace v38 = v39 if missing(v38) & `condition'
			replace v8 = "" if `condition'
			replace v12 = "" if `condition'
			replace v17 = "" if `condition'
			replace v23 = "" if `condition'
			replace v28 = "" if `condition'
			replace v32 = "" if `condition'
			replace v36 = "" if `condition'
			replace v39 = "" if `condition'
		}
		if `num' == 7 {
			local condition inlist(v1,"state totals","wichita")
			replace v15 = v13 if missing(v15) & `condition'
			replace v20 = v18 if missing(v20) & `condition'
			replace v24 = v22 if missing(v24) & `condition'
			replace v28 = v27 if missing(v28) & `condition'
			replace v32 = v31 if missing(v32) & `condition'
			replace v36 = v35 if missing(v36) & `condition'
			replace v13 = "" if `condition'
			replace v18 = "" if `condition'
			replace v22 = "" if `condition'
			replace v27 = "" if `condition'
			replace v31 = "" if `condition'
			replace v35 = "" if `condition'
		}
		if `num' == 8 {
			local condition inlist(v1,"state totals","wichita")
			replace v10 = v9 if missing(v10) & `condition'
			replace v15 = v13 if missing(v15) & `condition'
			replace v19 = v18 if missing(v19) & `condition'
			replace v23 = v22 if missing(v23) & `condition'
			replace v28 = v27 if missing(v28) & `condition'
			replace v32 = v31 if missing(v32) & `condition'
			replace v36 = v35 if missing(v36) & `condition'
			replace v38 = v39 if missing(v38) & `condition'
			replace v9 = "" if `condition'
			replace v13 = "" if `condition'
			replace v18 = "" if `condition'
			replace v22 = "" if `condition'
			replace v27 = "" if `condition'
			replace v31 = "" if `condition'
			replace v35 = "" if `condition'
			replace v39 = "" if `condition'
		}
		if `num' == 9 {
			local condition inlist(v1,"state totals","wichita")
			replace v4 = v3 if missing(v4) & `condition'
			replace v7 = v6 if missing(v7) & `condition'
			replace v11 = v10 if missing(v11) & `condition'
			replace v16 = v15 if missing(v16) & `condition'
			replace v21 = v18 if missing(v21) & `condition'
			replace v25 = v22 if missing(v25) & `condition'
			replace v29 = v27 if missing(v29) & `condition'
			replace v33 = v31 if missing(v33) & `condition'
			replace v37 = v35 if missing(v37) & `condition'
			replace v40 = v38 if missing(v40) & `condition'
			replace v3 = "" if `condition'
			replace v6 = "" if `condition'
			replace v10 = "" if `condition'
			replace v15 = "" if `condition'
			replace v18 = "" if `condition'
			replace v22 = "" if `condition'
			replace v27 = "" if `condition'
			replace v31 = "" if `condition'
			replace v35 = "" if `condition'
			replace v38 = "" if `condition'
		}
		if `num' == 10 {
			local condition inlist(v1,"state totals","wichita")
			replace v4 = v3 if missing(v4) & `condition'
			replace v7 = v6 if missing(v7) & `condition'
			replace v11 = v10 if missing(v11) & `condition'
			replace v16 = v15 if missing(v16) & `condition'
			replace v21 = v18 if missing(v21) & `condition'
			replace v25 = v22 if missing(v25) & `condition'
			replace v29 = v27 if missing(v29) & `condition'
			replace v33 = v31 if missing(v33) & `condition'
			replace v37 = v35 if missing(v37) & `condition'
			replace v40 = v38 if missing(v40) & `condition'
			replace v3 = "" if `condition'
			replace v6 = "" if `condition'
			replace v10 = "" if `condition'
			replace v15 = "" if `condition'
			replace v18 = "" if `condition'
			replace v22 = "" if `condition'
			replace v27 = "" if `condition'
			replace v31 = "" if `condition'
			replace v35 = "" if `condition'
			replace v38 = "" if `condition'
		}
		if `num' == 11 {
			local condition inlist(v1,"state totals","wichita")
			replace v4 = v3 if missing(v4) & `condition'
			replace v7 = v6 if missing(v7) & `condition'
			replace v11 = v10 if missing(v11) & `condition'
			replace v16 = v15 if missing(v16) & `condition'
			replace v21 = v18 if missing(v21) & `condition'
			replace v25 = v22 if missing(v25) & `condition'
			replace v29 = v26 if missing(v29) & `condition'
			replace v33 = v30 if missing(v33) & `condition'
			replace v37 = v34 if missing(v37) & `condition'
			replace v40 = v38 if missing(v40) & `condition'
			replace v3 = "" if `condition'
			replace v6 = "" if `condition'
			replace v10 = "" if `condition'
			replace v15 = "" if `condition'
			replace v18 = "" if `condition'
			replace v22 = "" if `condition'
			replace v26 = "" if `condition'
			replace v30 = "" if `condition'
			replace v34 = "" if `condition'
			replace v38 = "" if `condition'
		}
		if `num' == 12 {
			local condition inlist(v1,"state totals","wichita")
			replace v4 = v3 if missing(v4) & `condition'
			replace v7 = v6 if missing(v7) & `condition'
			replace v11 = v10 if missing(v11) & `condition'
			replace v16 = v15 if missing(v16) & `condition'
			replace v21 = v18 if missing(v21) & `condition'
			replace v25 = v22 if missing(v25) & `condition'
			replace v29 = v26 if missing(v29) & `condition'
			replace v33 = v30 if missing(v33) & `condition'
			replace v37 = v34 if missing(v37) & `condition'
			replace v40 = v38 if missing(v40) & `condition'
			replace v3 = "" if `condition'
			replace v6 = "" if `condition'
			replace v10 = "" if `condition'
			replace v15 = "" if `condition'
			replace v18 = "" if `condition'
			replace v22 = "" if `condition'
			replace v26 = "" if `condition'
			replace v30 = "" if `condition'
			replace v34 = "" if `condition'
			replace v38 = "" if `condition'
		}
		if `num' == 13 {
			local condition inlist(v1,"state totals","wichita")
			replace v5 = v6 if missing(v5) & `condition'
			replace v13 = v15 if missing(v13) & `condition'
			replace v18 = v20 if missing(v18) & `condition'
			replace v22 = v24 if missing(v22) & `condition'
			replace v29 = v28 if missing(v29) & `condition'
			replace v33 = v32 if missing(v33) & `condition'
			replace v6 = "" if `condition'
			replace v15 = "" if `condition'
			replace v20 = "" if `condition'
			replace v24 = "" if `condition'
			replace v28 = "" if `condition'
			replace v32 = "" if `condition'
		}
		dropmiss, force 
		drop obsnum_incounty
		qui describe, varlist		
		assert r(k) == 13

		local variable_names `"tanf_households tanf_adults tanf_children tanf_persons households adults children individuals childcare_households childcare_children"'

		// rename variables 
		qui describe, varlist
		rename (`r(varlist)') (county region `variable_names' obsnum)

		tempfile little_data`num'
		save `little_data`num''
		restore
	}
	
	clear 
	foreach num of local obsnum_incounty_nums {
		if `num' == 1 {
			use `little_data`num'', clear 
		}
		else {
			append using `little_data`num''
		}
	
	}
}


qui describe, varlist
if r(k) == 17 {
	local variable_names `"tanf_households tanf_adults tanf_children tanf_persons ga_households ga_adults ga_children ga_persons households adults children individuals childcare_households childcare_children"'
}
else if r(k) == 13 {
	local variable_names `"tanf_households tanf_adults tanf_children tanf_persons households adults children individuals childcare_households childcare_children"'
}

// rename variables 
qui describe, varlist
rename (`r(varlist)') (county region `variable_names' obsnum)

// destring
foreach v in `variable_names' {
	destring `v', replace
}

// drop region totals data 
drop if inlist(county,"kansas city","kansas city metro","south central","southeast","northeast","east","west")

// fix county names 
replace county = "total" if strpos(county,"state total")

// getting towards months 
bysort county (obsnum): gen obsnum_withincounty = _n

// wichita is both a county and a region, want to keep county, which is first observation within month
// 2 state total rows are the same, just keep one per month
if !inrange(`year',2019,2020) {
	gen odd = mod(obsnum_withincounty,2)	
	keep if !inlist(county,"wichita","total") | (odd == 1 & inlist(county,"wichita","total"))
	tab obsnum_withincounty if county == "wichita"
	drop odd 
}
if `year' == 2020 {
	// manually drop extra observations
	drop if county == "total" & obsnum_withincounty == 3
	drop if county == "wichita" & missing(region)
}
drop obsnum_withincounty

// drop 13th month (it's an average) - 2nd month for 2020
bysort county: assert _N == 12 | _N == 13 if `year' < 2020
bysort county: assert _N == 2 if `year' == 2020
bysort county: gen monthnum = _n 
noisily drop if monthnum == 13
if `year' == 2020 {
	noisily drop if monthnum == 2 
}
drop monthnum

// generate date info
bysort county: assert _N == 12 if `year' < 2020
bysort county: assert _N == 1 if `year' == 2020
bysort county (obsnum): gen month = _n + 6
replace month = month - 12 if inrange(month,13,18)
gen year = .
replace year = `year' if inrange(month,1,6)
replace year = `year' - 1 if inrange(month,7,12)
gen ym = ym(year,month)
format ym %tm 
drop year month obsnum

// order and sort 
order county region ym 
sort county ym 

// save 
tempfile _`year'
save `_`year''

}
}

// append all years
forvalues year = `year_start'(1)`year_end' {
	if `year' == `year_start' {
		use `_`year'', clear
	}
	else {
		append using `_`year''
	}
}

// order and sort 
order county region ym 
sort county ym 

// save 
tempfile kansas_county
save `kansas_county'


******************************************************************************
******************************************************************************

// MERGE IN STATEWIDE DATA 

// merge 
use `kansas_county', clear 
merge 1:1 county ym using `kansas_state', update replace // update replace to use consistent state totals

// validate merge
assert inlist(_m,1,2,3,4,5)
assert county != "total" if inlist(_m,1)
assert (inrange(ym,ym(2010,7),ym(2021,3)) | inrange(ym,ym(2021,7),ym(2022,9))) & county == "total" if inlist(_m,3,4,5)
assert inrange(ym,ym(2021,4),ym(2021,6)) if _m == 2 // county data is missing for these months
drop _m 

// expand to full set of county ym 
encode county, gen(county_num)
tsset county_num ym 
tsfill, full 
gsort county_num -ym 
by county_num: carryforward county, replace 
gsort county_num ym 
by county_num: carryforward county, replace 
drop county_num

// assert the right amount of observations 
local num_months = `ym_end' - `ym_start' + 1
local target_obs = `num_months' * `num_counties'
count 
display in red "actual obs:" `r(N)'
display in red "target obs:" `target_obs'
assert `r(N)' == `target_obs'

// order and sort 
order county region ym 
sort county ym 

// save 
save "${dir_root}/data/state_data/kansas/kansas.dta", replace


