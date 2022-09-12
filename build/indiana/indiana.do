// cleaning extracted Indiana data
// Kelsey Pukelis

*local start_ym 		= ym(2005,4)
local start_ym 		= ym(2010,5)
local end_ym 		= ym(2022,6)

***************************************************************************************


forvalues ym = `start_ym'(1)`end_ym' {

	// display ym 
	dis in red `ym'

	// for file names
	clear
	set obs 1
	gen year = year(dofm(`ym'))
	gen month = month(dofm(`ym'))
	tostring month, replace 
	replace month = "0" + month if strlen(month) == 1
	local month = month
	display in red "`month'"
	local year = year 
	display in red "`year'"

	// import file 
	import delimited "${dir_root}/data/state_data/indiana/csvs/tabula-`year'-`month'.csv", delimiter(",") clear
		
	// remove title columns
	drop if v1 == ""
	drop if strpos(v1,"TANF - REGULAR")
	drop if strpos(v1,"TANF - UNEMPLOYED PARENT")
	drop if strpos(v2,"Cumulative")
	drop if strpos(v3,"Cumulative")
	drop if strpos(v3,"January")
	drop if strpos(v3,"February")
	drop if strpos(v4,"Cumulative")
	drop if strpos(v5,"Annual")
	drop if strpos(v5,"Cumulative")
	drop if strpos(v5,"Change")
	drop if strpos(v1,`"Change""')
		
	// remove unnecessary characters
	foreach var in v2 v3 v4 v5 {
		replace `var' = trim(`var')
		replace `var' = ustrregexra(`var',",","")
		replace `var' = ustrregexra(`var',"%","")
		replace `var' = ustrregexra(`var',"NA","")
		destring `var', ignore("$") replace
	}

	// drop TANF variables
	while !strpos(v1,"issuance") {
		drop in 1
	}

	// drop Child Care variables
	gen obsnum = _n
	gsort -obsnum
	while !strpos(v1,"adults ineligible due to employment") {
		drop in 1
	}
	sort obsnum
	drop obsnum

	// drop HIP related variables, only available beginning 2019
	drop if v1 == "Total HIP 2.0 Members"
	drop if v1 == "HIP Members also SNAP Recipients"
	drop if v1 == "Percentage HIP Members SNAP Recipients"
	drop if v1 == "HIP Members SNAP ABAWDs"
	drop if v1 == "Percentage HIP Members SNAP ABAWDs"

	// assert 18 variables
	gen obsnum = _n
	count
	local numobs = r(N)
	assert inlist(`numobs',18,15) // 17 
		if `numobs' == 18 {
			assert strpos(v1,"Total") & strpos(v1,"issuance") if obsnum == 1
			assert v1 == "Number of households receiving SNAP benefits" if obsnum == 2
			assert v1 == "Number of recipients" if obsnum == 3
			assert v1 == "Average issuance per household" if obsnum == 4
			assert v1 == "Average issuance per recipient" if obsnum == 5
			assert v1 == "FFY Cumulative Positive Error Rate" if obsnum == 6
			assert v1 == "Monthly Positive Error Rate" if obsnum == 7
			assert v1 == "FFY Cumulative Negative Error Rate" if obsnum == 8
			assert v1 == "Monthly Negative Error Rate" if obsnum == 9
			assert v1 == "Number of IMPACT cases" if obsnum == 10
			assert strpos(v1,"Number of TANF IMPACT") if obsnum == 11
			assert v1 == "Number of SNAP IMPACT Cases" if obsnum == 12
			assert v1 == "Total number of adults employed" if obsnum == 13
			assert strpos(v1,"Number of TANF IMPACT adults") & strpos(v1,"employed") if obsnum == 14
			assert v1 == "Number of SNAP IMPACT adults employed" if obsnum == 15
			assert v1 == "Total number of adults ineligible due to employment" if obsnum == 16
			assert v1 == "Number of TANF adults ineligible due to employment" if obsnum == 17
			assert v1 == "Number of SNAP adults ineligible due to employment" if obsnum == 18
		}
		else if `numobs' == 15 {
			assert strpos(v1,"Total") & strpos(v1,"issuance") if obsnum == 1
			assert v1 == "Number of households receiving SNAP benefits" if obsnum == 2
			assert v1 == "Number of recipients" if obsnum == 3
			assert v1 == "Average issuance per household" if obsnum == 4
			assert v1 == "Average issuance per recipient" if obsnum == 5
			assert v1 == "Number of Applications" if obsnum == 6
			assert v1 == "Number of IMPACT cases" if obsnum == 7
			assert strpos(v1,"Number of TANF IMPACT") if obsnum == 8
			assert v1 == "Number of SNAP IMPACT Cases" if obsnum == 9
			assert v1 == "Total number of adults employed" if obsnum == 10
			assert strpos(v1,"Number of TANF IMPACT adults") & strpos(v1,"employed") if obsnum == 11
			assert v1 == "Number of SNAP IMPACT adults employed" if obsnum == 12
			assert v1 == "Total number of adults ineligible due to employment" if obsnum == 13
			assert v1 == "Number of TANF adults ineligible due to employment" if obsnum == 14
			assert v1 == "Number of SNAP adults ineligible due to employment" if obsnum == 15
		}

		// drop annual percent change
		drop v5
		capture confirm variable v6
		if !_rc {
			stop 
		}

		// keep old measurements
		local ym = `ym'
		local ym_lastmonth = ym(`year',`month') - 1
		local ym_lastyear = ym(`year',`month') - 12
		rename v2 _`ym'
		rename v3 _`ym_lastmonth'
		rename v4 _`ym_lastyear'
		
		// reshape 
		drop obsnum
		reshape long _, i(v1) j(ym)
		rename _ value 
		format ym %tm 
		
		// rename 
		gen varname = ""
		replace varname = "issuance" if strpos(v1,"Total") & strpos(v1,"issuance")
		replace varname = "households" if v1 == "Number of households receiving SNAP benefits"
		replace varname = "individuals" if v1 == "Number of recipients"
		replace varname = "avg_per_hh" if v1 == "Average issuance per household"
		replace varname = "avg_per_recip" if v1 == "Average issuance per recipient"
		replace varname = "apps_received" if v1 == "Number of Applications"
		replace varname = "ffy_cum_pos_errate" if v1 == "FFY Cumulative Positive Error Rate"
		replace varname = "mon_pos_errate" if v1 == "Monthly Positive Error Rate"
		replace varname = "ffy_cum_neg_errate" if v1 == "FFY Cumulative Negative Error Rate"
		replace varname = "mon_neg_errate" if v1 == "Monthly Negative Error Rate"
		replace varname = "total_impact" if v1 == "Number of IMPACT cases"
		replace varname = "tanf_impact" if strpos(v1,"Number of TANF IMPACT")
		replace varname = "snap_impact" if strpos(v1,"Number of SNAP IMPACT")
		replace varname = "total_emp" if v1 == "Total number of adults employed"
		replace varname = "tanf_emp" if strpos(v1,"Number of TANF IMPACT adults") & strpos(v1,"employed")
		replace varname = "snap_emp" if v1 == "Number of SNAP IMPACT adults employed"
		replace varname = "total_inelig" if v1 == "Total number of adults ineligible due to employment"
		replace varname = "tanf_inelig" if v1 == "Number of TANF adults ineligible due to employment"
		replace varname = "snap_inelig" if v1 == "Number of SNAP adults ineligible due to employment"
		assert !missing(varname)
		drop v1 
		
		// reshape
		rename value _
		reshape wide _, i(ym) j(varname) string 
		rename _issuance issuance
		rename _households households
		rename _individuals individuals
		rename _avg_per_hh avg_per_hh
		rename _avg_per_recip avg_per_recip
		capture rename _apps_received apps_received
		capture rename _ffy_cum_pos_errate ffy_cum_pos_errate
		capture rename _mon_pos_errate mon_pos_errate
		capture rename _ffy_cum_neg_errate ffy_cum_neg_errate
		capture rename _mon_neg_errate mon_neg_errate
		rename _total_impact total_impact
		rename _tanf_impact tanf_impact
		rename _snap_impact snap_impact
		rename _total_emp total_emp
		rename _tanf_emp tanf_emp
		rename _snap_emp snap_emp
		rename _total_inelig total_inelig
		rename _tanf_inelig tanf_inelig
		rename _snap_inelig snap_inelig
		
		// county 
		gen county = "total"

		// source 
		gen source = `ym'
		format source %tm 

		// save temporary
		tempfile _`ym'
		save `_`ym''
}

// append and save 
forvalues ym = `start_ym'(1)`end_ym' {
	if `ym' == `start_ym' {
		use `_`ym'', clear
	}
	else {
		append using `_`ym''
	}
}

// drop exact duplicates
// list them out because I include a source variable 
duplicates drop county ym avg_per_hh avg_per_recip ffy_cum_neg_errate ffy_cum_pos_errate households individuals issuance mon_neg_errate mon_pos_errate snap_emp snap_impact snap_inelig tanf_emp tanf_impact tanf_inelig total_emp total_impact total_inelig apps_received, force 

// drop variables I don't care about 
drop ffy_cum_pos_errate
drop ffy_cum_neg_errate
drop mon_pos_errate
drop mon_neg_errate

// drop exact duplicates again 
duplicates drop county ym avg_per_hh avg_per_recip households individuals issuance snap_emp snap_impact snap_inelig tanf_emp tanf_impact tanf_inelig total_emp total_impact total_inelig apps_received, force 

// drop more variables I don't care about 
drop avg_per_recip
drop avg_per_hh

// drop exact duplicates again 
duplicates drop county ym households individuals issuance snap_emp snap_impact snap_inelig tanf_emp tanf_impact tanf_inelig total_emp total_impact total_inelig apps_received, force 

// some observations have a non-missing apps_received
bysort county ym: gen obsnum_within = _n
gsort county ym -obsnum_within
by county ym: carryforward apps_received, replace 
gsort county ym obsnum_within
by county ym: carryforward apps_received, replace 
drop obsnum_within

// drop exact duplicates again 
duplicates drop county ym households individuals issuance snap_emp snap_impact snap_inelig tanf_emp tanf_impact tanf_inelig total_emp total_impact total_inelig apps_received, force 

// drop more variables I don't care about 
drop tanf_emp
drop tanf_impact
drop tanf_inelig

// drop exact duplicates again 
duplicates drop county ym households individuals issuance snap_emp snap_impact snap_inelig total_emp total_impact total_inelig apps_received, force 

// total_emp, snap_emp has one observation which differs by 1; ignore this 
// total_impact has a few duplicates, but the numbers are very close
*duplicates tag county ym issuance, gen(dup)
*drop dup 
duplicates drop county ym households individuals issuance snap_impact snap_inelig total_inelig apps_received, force 

// remaining discrepancies are from issuance; keep the later observation if two different numbers 
duplicates tag county ym issuance, gen(dup)
assert dup == 0
drop dup 
gsort county ym -source 
by county ym: gen obsnum_within = _n 
assert inlist(obsnum_within,1,2,3)
keep if obsnum_within == 1
drop obsnum_within

// check for duplicates 
sort county ym 
duplicates tag county ym, gen(dup)
assert dup == 0
drop dup 
drop source 

// order and sort 
order county ym households individuals issuance apps_received snap_* total_*
sort county ym 

// save 
save "${dir_root}/data/state_data/indiana/indiana.dta", replace 

