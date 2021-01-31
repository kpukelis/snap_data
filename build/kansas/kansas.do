// kansas.do 

local year_start 			= 2011
local year_end 				= 2021

********************************************************************
forvalues year = `year_start'(1)`year_end' {

	dis in red "`year'"

	// import data 
	import excel "${dir_root}/data/state_data/kansas/csvs/SFY`year'_CntyCaseload_Rpt.xlsx", allstring case(lower) clear
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
qui describe, varlist 
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
	drop obsnum_withincounty odd 
}
if `year' == 2020 {
	// manually drop extra observations
	drop if county == "total" & obsnum_withincounty == 3
	drop if county == "wichita" & missing(region)
}

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
save "${dir_root}/data/state_data/kansas/kansas.dta", replace


