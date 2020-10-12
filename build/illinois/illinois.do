// illinois.do
// imports households and individuals from excel sheets

**KP: need to change name of sheet

*local year_start				2010
local year_start				2015
local year_end 					2019
local sheets 					individuals households

***************************************************************

forvalues year = `year_start'(1)`year_end' {
	foreach sheet of local sheets {

		// year 
		display in red `"`sheet'"' `year'

		// import 
		import excel using "${dir_root}/snap`year'.xlsx", sheet("`sheet'") firstrow case(lower) allstring clear
		
		// drop observations, then variables with all missing values
		dropmiss, obs force
		dropmiss, force

		// clean up county 
		if inlist(`year',2018,2019) {
			gen county = office
			replace county = officenumber if inlist(officenumber,"DOWNSTATE","COOK COUNTY","TOTAL STATE")
			replace officenumber = "" if inlist(officenumber,"DOWNSTATE","COOK COUNTY","TOTAL STATE")
			destring officenumber, replace
			confirm numeric variable officenumber
		}
		replace county = strlower(county)
		replace county = trim(county)
		drop if county == "cntl all kid"
		if inlist(`year',2013) {
			drop if strpos(county,"notice:")
		}

		// reshape
		rename january _1 
		rename february _2 
		rename march _3
		rename april _4 
		rename may _5
		rename june _6 
		rename july _7
		rename august _8
		rename september _9
		if `year' != 2019 {
			rename october _10 
			rename november _11
			rename december _12
		}
		reshape long _, i(county) j(month)
		rename _ `sheet'

		// clean up main variable
		replace `sheet' = ustrregexra(`sheet',",","")
		replace `sheet' = ustrregexra(`sheet',"-","")
		replace `sheet' = ustrregexra(`sheet'," ","")
		gen consolidated_note = ""
		replace consolidated_note = `sheet' if strpos(`sheet',"consolidated")
		replace consolidated_note = `sheet' if inlist(`sheet',"Closed","closed")
		replace consolidated_note = county if strpos(county,"consolidated")
		replace `sheet' = "" if strpos(`sheet',"consolidated")
		replace `sheet' = "" if  inlist(`sheet',"Closed","closed")
		*/
*		if `year' != 2014 {
		if !inrange(`year',2014,2017) {
			replace county = ustrregexra(county," ","")
		}
		gen county_temp = county 
		split county_temp, parse(" ")
		foreach v of varlist county_temp? {
			replace `v' = trim(`v') 
			replace `v' = ustrregexra(`v'," ","")
		}
		capture confirm variable county_temp2
		if !_rc {
			capture noisily assert inlist(county_temp2,"county","")
			replace county = county_temp1 if inlist(county_temp2,"county","")
			capture confirm variable county_temp3
			if !_rc {
				capture noisily assert inlist(county_temp2,"county","") | inlist(county_temp3,"county","")
				replace county = county_temp1 + " " + county_temp2 if inlist(county_temp3,"county","")
				capture confirm variable county_temp4
				if !_rc {
					noisily assert inlist(county_temp2,"county","") | inlist(county_temp3,"county","","illinois)")
					replace county = county_temp1 + " " + county_temp2 + " " + county_temp3 if inlist(county_temp3,"illinois)")
				}
			}
		}
		else {

		}
		
		drop county_temp*
		replace county = ustrregexra(county," ","")
		if `year' == 2013 {
			replace county = "clinton" if county == "clintonclintoncountyofficeclosedandconsolidatedwithmarioncountyoffice."
			replace county = "mercer" if county == "mercer mercercountyofficeclosed,consolidatedwithwarrencountyoffice."
		}
		*/
		replace `sheet' = ustrregexra(`sheet'," ","")
		destring `sheet', replace
        confirm numeric variable `sheet'

		// date 
		gen year = `year'
		gen ym = ym(year,month)
		format ym %tm 
		drop year month 

		// order and sort 
		order county ym `sheet'
		sort county ym

		// manually fix duplicates
		if `year' == 2014 {
			drop if county == "bond" & ym == ym(2014,1) & consolidated_note == "bond county office closed and consolidated with madison county office, effective 2/2014."
			drop if county == "bond" & inrange(ym,ym(2014,2),ym(2014,12)) & consolidated_note != "bond county office closed and consolidated with madison county office, effective 2/2014."
		}
		if `year' == 2015 {
			drop if county == "hancock" & ym == ym(2015,1) & consolidated_note == "hancock county office closed and consolidated with adams county office."
			drop if county == "hancock" & inrange(ym,ym(2015,2),ym(2015,12)) & consolidated_note != "hancock county office closed and consolidated with adams county office."
			drop if county == "schuyler" & inrange(ym,ym(2015,1),ym(2015,6)) & consolidated_note == "schuyler county office closed and consolidated with cass county office."
			drop if county == "schuyler" & inrange(ym,ym(2015,7),ym(2015,12)) & consolidated_note != "schuyler county office closed and consolidated with cass county office."
		}

		// assert no duplicates by county ym 
		duplicates tag county ym, gen(dup)
		assert dup == 0
		drop dup

		// save 
		tempfile `year'_`sheet'
		save ``year'_`sheet''

	}

}

***************************************************************

forvalues year = `year_start'(1)`year_end' {
	display in red "`year'"
	foreach sheet of local sheets {
		display in red "`sheet'"
		if "`sheet'" == "individuals" {
			use ``year'_`sheet'', clear
		}
		else {
			merge 1:1 county ym using ``year'_`sheet''
			assert _m == 3
			drop _m
		}

		tempfile _`year'
		save `_`year''
	}
}

forvalues year = `year_start'(1)`year_end' {
	if `year' == `year_start' {
		use `_`year'', clear
	}
	else {
		append using `_`year''
	}
}

// order and sort 
order county ym 
sort county ym

// save
save "${dir_root}/illinois.dta", replace 

******************************************************************************

// collapse to larger office level

// generate office id 

// generate closed date 
gen ym_closed = .
replace ym_closed = ym(2011,1) if inlist(county,"brown","calhoun","clark","cumberland","dewitt","edwards","ford","gallatin","grundy","hardin","jasper","johnson","lee","menard","monroe","piatt","putnum","scott","stark","washington","wayne","woodford")
replace ym_closed = ym(2011,3) if inlist(county,"mercer")
replace ym_closed = ym(2011,7) if inlist(county,"boone","perry")
henderson
KEEP GOING HERE

madison |         36        0.73       53.54
                        madison-e.alton |         21        0.43       53.96
                         madison-g.city |         21        0.43       5

 kane |         36        0.73       40.18
                            kane-aurora |         21        0.43       40.61
                             kane-elgin |         21        0.43       41.04

  st.clair |         36        0.73       83.17
                    st.clair-e.st.louis |         21        0.43       8

