// maine.do

local ym_start	 				= ym(2005,1)
local ym_end 					= ym(2020,4)

************************************************************

forvalues ym = `ym_start'(1)`ym_end' {

	dis in red `ym'

	// for file names
	clear
	set obs 1
	gen year = year(dofm(`ym'))
	gen month = month(dofm(`ym'))
	gen monthname = ""
	if inrange(year,2008,2014) {
		replace monthname = "january" if month == 1
		replace monthname = "february" if month == 2
		replace monthname = "march" if month == 3
		replace monthname = "april" if month == 4
		replace monthname = "may" if month == 5
		replace monthname = "june" if month == 6
		replace monthname = "july" if month == 7
		replace monthname = "august" if month == 8
		replace monthname = "september" if month == 9
		replace monthname = "october" if month == 10
		replace monthname = "november" if month == 11
		replace monthname = "december" if month == 12
	}
	if inlist(year,2015,2016,2005) {
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
	if inlist(year,2017,2018,2019,2020) {
		replace monthname = "jan" if month == 1
		replace monthname = "feb" if month == 2
		replace monthname = "mar" if month == 3
		replace monthname = "apr" if month == 4
		replace monthname = "may" if month == 5
		replace monthname = "jun" if month == 6
		replace monthname = "jul" if month == 7
		replace monthname = "aug" if month == 8
		replace monthname = "sep" if month == 9
		replace monthname = "oct" if month == 10
		replace monthname = "nov" if month == 11
		replace monthname = "dec" if month == 12
	}
	if inlist(year,2006,2007) {
		replace monthname = "January" if month == 1
		replace monthname = "February" if month == 2
		replace monthname = "March" if month == 3
		replace monthname = "April" if month == 4
		replace monthname = "May" if month == 5
		replace monthname = "June" if month == 6
		replace monthname = "July" if month == 7
		replace monthname = "August" if month == 8
		replace monthname = "September" if month == 9
		replace monthname = "October" if month == 10
		replace monthname = "November" if month == 11
		replace monthname = "December" if month == 12
	}
	tostring month, replace 
	replace month = "0" + month if strlen(month) == 1
	local month = month
	display in red "`month'"
	local year = year 
	display in red "`year'"
	local monthname = monthname
	display in red "`monthname'"

	// import 
	if inrange(`ym',ym(2005,1),ym(2007,12)) {
		import excel using "${dir_root}/csvs/`year'/`monthname'-`year'.xlsx", case(lower) allstring clear
	}
	else if inrange(`ym',ym(2008,1),ym(2008,12)) {
		import excel using "${dir_root}/csvs/`year'/geo-`monthname'_1.xlsx", case(lower) allstring clear
	}
	else if inrange(`ym',ym(2009,1),ym(2009,12)) {
		import excel using "${dir_root}/csvs/`year'/geo-`monthname'_2.xlsx", case(lower) allstring clear
	}
	else if inrange(`ym',ym(2010,1),ym(2010,12)) {
		import excel using "${dir_root}/csvs/`year'/geo-`monthname'_3.xlsx", case(lower) allstring clear
	}
	else if inrange(`ym',ym(2011,1),ym(2011,12)) {
		import excel using "${dir_root}/csvs/`year'/geo-`monthname'_4.xlsx", case(lower) allstring clear
	}
	else if inrange(`ym',ym(2012,1),ym(2012,12)) {
		import excel using "${dir_root}/csvs/`year'/geo-`monthname'_5.xlsx", case(lower) allstring clear
	}
	else if inrange(`ym',ym(2013,1),ym(2013,12)) {
		import excel using "${dir_root}/csvs/`year'/geo-`monthname'_6.xlsx", case(lower) allstring clear
	}
	else if inrange(`ym',ym(2014,1),ym(2014,12)) {
		import excel using "${dir_root}/csvs/`year'/geo-`monthname'.xlsx", case(lower) allstring clear
	}
	else if inrange(`ym',ym(2015,1),ym(2015,12)) {
		import excel using "${dir_root}/csvs/`year'/GeoDist_`monthname'2015.xlsx", case(lower) allstring clear
	}
	else if inrange(`ym',ym(2016,1),ym(2016,12)) {
		import excel using "${dir_root}/csvs/`year'/GeoDistrib_`monthname'.xlsx", case(lower) allstring clear
	}
	else if inrange(`ym',ym(2017,1),ym(2017,12)) {
		import excel using "${dir_root}/csvs/`year'/geo-distribution-`monthname'.xlsx", case(lower) allstring clear
	}
	else if inrange(`ym',ym(2018,1),ym(2018,12)) {
		import excel using "${dir_root}/csvs/`year'/geo-distribution-`monthname'_1.xlsx", case(lower) allstring clear
	}
	else if inrange(`ym',ym(2019,1),ym(2019,12)) {
		import excel using "${dir_root}/csvs/`year'/geo-distribution-`monthname'_2.xlsx", case(lower) allstring clear
	}
	else if inrange(`ym',ym(2020,1),ym(2020,12)) {
		import excel using "${dir_root}/csvs/`year'/geo-distribution-`monthname'_3.xlsx", case(lower) allstring clear
	}
	dropmiss, force
	qui describe, varlist
	rename (`r(varlist)') (v#), addnumber
	foreach v of varlist _all {
		replace `v' = trim(`v')
		replace `v' = strlower(`v')
	}

	if inrange(`ym',ym(2005,1),ym(2005,3)) | inrange(`ym',ym(2005,5),ym(2005,7)) | inrange(`ym',ym(2005,9),ym(2006,6))  {
		gen obsnum = _n 
		local counties androscoggin aroostook aroostook unknown cumberland franklin hancock kennebec knox lincoln oxford penobscot piscataquis sagadahoc somerset waldo washington york 
		foreach county of local counties {
		
			// preserve 
			preserve 

			sum obsnum if strpos(v1,"county name") & strpos(v1,"`county'")
			assert r(N) == 2 | r(N) == 3
			local begin_`county' = r(min)
			sum obsnum if obsnum > `begin_`county'' & strpos(v1,"county total")
			keep if obsnum == r(min) 
			dropmiss, force 
			qui describe, varlist
			rename (`r(varlist)') (v#), addnumber
			assert r(k) == 14
			assert r(N) == 1
			replace v1 = "`county'"
			qui describe, varlist 
			rename (`r(varlist)') (county rca_cases rca_benefits pas_cases tanf_cases tanf_children tanfpas_benefits households individuals issuance aspire_participants all_uniqueindiv all_uniquecases obsnum)
			foreach v in rca_cases rca_benefits pas_cases tanf_cases tanf_children tanfpas_benefits households individuals issuance aspire_participants all_uniqueindiv all_uniquecases {
				destring `v', replace
			}

			// save 
			tempfile _`county'
			save `_`county''

			// restore 
			restore 

		}
		foreach county of local counties {
			if "`county'" == "androscoggin" {
				use `_`county'', clear
			}
			else {
				append using `_`county''
			}
		}
	}
	else {

		// only keep county and state totals
		count if v1 == "county name"
		assert r(N) == 1
		gen obsnum = _n 
		sum obsnum if v1 == "county name"
		keep if obsnum >= r(mean)
		drop in 1
		if inrange(`ym',ym(2018,7),ym(2020,4)) {
			drop in 1
		}
		dropmiss, force  
		qui describe, varlist
		rename (`r(varlist)') (v#), addnumber
		assert r(k) == 14
		assert r(N) == 18
		qui describe, varlist 
		rename (`r(varlist)') (county rca_cases rca_benefits pas_cases tanf_cases tanf_children tanfpas_benefits households individuals issuance aspire_participants all_uniqueindiv all_uniquecases obsnum)
		foreach v in rca_cases rca_benefits pas_cases tanf_cases tanf_children tanfpas_benefits households individuals issuance aspire_participants all_uniqueindiv all_uniquecases {
			destring `v', replace
		}
		replace county = "total" if county == "final totals"
	}
	// date 
	gen ym = `ym'
	format ym %tm

	// order and sort 
	order county ym 
	sort county ym 

	// save 
	tempfile _`ym'
	save `_`ym''

}

*************
forvalues ym = `ym_start'(1)`ym_end' {
	if `ym' == `ym_start' {
		use `_`ym'', clear
	}
	else {
		append using `_`ym''
	}
}

// drop duplicates 
duplicates drop 

// drop obsnum 
drop obsnum

// clean up county name 
replace county = "county unknown" if county == "unknown"

// just to shorten the string 
gen county_new = county 
drop county 
rename county_new county 

// sort and order 
order county ym 
sort county ym 

// save 
save "${dir_data}/maine.dta", replace	


