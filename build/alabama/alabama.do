// alabama.do

local ym_start	 				= ym(2001,1)
local ym_end 					= ym(2022,9)
local num_counties 				= 68 // including total 

************************************************************

forvalues ym = `ym_start'(1)`ym_end' {
if `ym' != ym(2015,8) {

	dis in red `ym'

	// for file names
	clear
	set obs 1
	gen year = year(dofm(`ym'))
	gen year_short = year - 2000
	tostring year_short, replace 
	replace year_short = "0" + year_short if strlen(year_short) == 1
	gen month = month(dofm(`ym'))
	gen monthname = ""
	if inrange(`ym',ym(2001,1),ym(2010,7)) {
		replace monthname = "Jan" if month == 1
		replace monthname = "Feb" if month == 2
		replace monthname = "Mar" if month == 3
		replace monthname = "Apr" if month == 4
		replace monthname = "May" if month == 5
		replace monthname = "Jun" if month == 6
		replace monthname = "Jul" if month == 7
		replace monthname = "Aug" if month == 8
		replace monthname = "Sep" if month == 9
		replace monthname = "Oct" if month == 10
		replace monthname = "Nov" if month == 11
		replace monthname = "Dec" if month == 12
	}
	else if `ym' >= ym(2010,8) {
		replace monthname = "01" if month == 1
		replace monthname = "02" if month == 2
		replace monthname = "03" if month == 3
		replace monthname = "04" if month == 4
		replace monthname = "05" if month == 5
		replace monthname = "06" if month == 6
		replace monthname = "07" if month == 7
		replace monthname = "08" if month == 8
		replace monthname = "09" if month == 9
		replace monthname = "10" if month == 10
		replace monthname = "11" if month == 11
		replace monthname = "12" if month == 12
	}
	local monthname = monthname
	display in red "`monthname'"
	local year_short = year_short 
	display in red "`year_short'"
	local year = year 
	display in red "`year'"

	// import 
	if inrange(`ym',ym(2001,1),ym(2010,7)) {
		import excel using "${dir_root}/data/state_data/alabama/excel/`year'/`monthname'`year_short'.pdf_short.xlsx", case(lower) allstring clear
	}
	else if `ym' >= ym(2010,8) {
		import excel using "${dir_root}/data/state_data/alabama/excel/`year'/STAT`monthname'`year_short'.pdf_short.xlsx", case(lower) allstring clear
	}
	
	// initial cleanup
	dropmiss, force 
	dropmiss, obs force 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber

	// mark observations to keep
	gen obsnum = _n
	replace v1 = trim(v1)
	count if v1 == "TOTAL"
	assert `r(N)' == 1
	qui sum obsnum if v1 == "TOTAL"
	local page1_begin = `r(mean)'
	count if v1 == "Geneva"
	assert `r(N)' == 1
	qui sum obsnum if v1 == "Geneva"
	local page2_begin = `r(mean)' 
	count if v1 == "Franklin"
	assert `r(N)' == 1
	qui sum obsnum if v1 == "Franklin"
	local page1_end = `r(mean)'
	count if v1 == "Winston"
	assert `r(N)' == 1
	qui sum obsnum if v1 == "Winston"
	local page2_end = `r(mean)'

	// keep observations
	keep if inrange(obsnum,`page1_begin',`page1_end') | inrange(obsnum,`page2_begin',`page2_end')
	drop obsnum

	// rename variables
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber
	assert r(k) == 6
	rename v1 county 
	rename v2 households
	rename v3 individuals_pa
	rename v4 individuals_npa 
	rename v5 individuals 
	rename v6 issuance

	// destring
	foreach v in households individuals issuance individuals_npa individuals_pa {
		replace `v' = ustrregexra(`v',"\,","")
		destring `v', replace ignore("$")
		confirm numeric variable `v'
	}
	
	// lowercase county 
	replace county = strlower(county)

	// make county string variable shorter (easier to browse)
	gen county_copy = county 
	drop county 
	rename county_copy county
	
	// ym 
	gen ym = `ym'
	format ym %tm

	// order and sort 
	order county ym households individuals issuance individuals_npa individuals_pa
	sort county ym 
	
	// save 
	tempfile _`ym'
	save `_`ym''

}
}

// append years 
forvalues ym = `ym_start'(1)`ym_end' {
if `ym' != ym(2015,8) {
	if `ym' == `ym_start' {
		use `_`ym'', clear
	}
	else {
		append using `_`ym''
	}
}
}

// expand to include ym(2015,8)
encode county, gen(county_num)
tsset county_num ym 
tsfill, full 
gsort county_num -ym 
by county_num: carryforward county, replace 
gsort county_num ym 
by county_num: carryforward county, replace 
drop county_num

// assert number of observations 
local num_months = `ym_end' - `ym_start' + 1
local target_obs = `num_months' * `num_counties'
count 
display in red "actual obs:" `r(N)'
display in red "target obs:" `target_obs'
assert `r(N)' == `target_obs'

// order and sort 
order county ym households individuals issuance individuals_npa individuals_pa
sort county ym 

// save 
save "${dir_root}/data/state_data/alabama/alabama.dta", replace

check
