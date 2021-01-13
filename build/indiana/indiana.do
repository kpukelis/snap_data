// cleaning extracted Indiana data
// Kelsey Pukelis

*local start_year 	= 2005
*local start_month 	= 4
local start_year 	= 2010
local start_month 	= 5
local end_year 		= 2020
local end_month		= 4

***************************************************************************************

forvalues year = `start_year'(1)`end_year' {
	forvalues month = 1(1)$monthsinayear {
		display in red "`year'-`month'"
		if (`year' == `start_year' & `month' >= `start_month') | (`year' > `start_year' & `year' < `end_year') | (`year' == `end_year' & `month' <= `end_month') {
			if `month' <= 9 {
				local month_string = "0`month'" 
			}
			else {
				local month_string = "`month'"
			}
			import delimited "${dir_root}/data/state_data/indiana/csvs/tabula-`year'-`month_string'.csv", delimiter(",") clear
			
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
			**KP: might want to bring these back later
			drop if v1 == "Total HIP 2.0 Members"
			drop if v1 == "HIP Members also SNAP Recipients"
			drop if v1 == "Percentage HIP Members SNAP Recipients"
			drop if v1 == "HIP Members SNAP ABAWDs"
			drop if v1 == "Percentage HIP Members SNAP ABAWDs"

			// assert 18 variables
			gen obsnum = _n
			count
			local numobs = r(N)
			assert `numobs' == 18 | `numobs' == 17
			assert v1 == "Total  issuance" if obsnum == 1
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

			// drop old measurements and drop annual percent change
			drop v3 v4 v5

			// transform
			count
			local numobs = r(N)
			drop if obsnum == 9 & `numobs' == 18 // KP: dropping "Monthly Negative Error Rate" for now since it got dropped out of a lot of datasets 
			drop obsnum
			drop v1 
			xpose, clear 

			// label and rename vars
			label var v1 "Total  issuance"
			label var v2 "Number of households receiving SNAP benefits"
			label var v3 "Number of recipients"
			label var v4 "Average issuance per household"
			label var v5 "Average issuance per recipient"
			label var v6 "FFY Cumulative Positive Error Rate"
			label var v7 "Monthly Positive Error Rate"
			label var v8 "FFY Cumulative Negative Error Rate"
				*label var v9 "Monthly Negative Error Rate"
				*label var v10 "Number of IMPACT cases"
				*label var v11 "Number of TANF IMPACT Cases"
				*label var v12 "Number of SNAP IMPACT Cases"
				*label var v13 "Total number of adults employed"
				*label var v14 "Number of TANF IMPACT adults employed"
				*label var v15 "Number of SNAP IMPACT adults employed"
				*label var v16 "Total number of adults ineligible due to employment"
				*label var v17 "Number of TANF adults ineligible due to employment"
				*label var v18 "Number of SNAP adults ineligible due to employment"
			label var v9 "Number of IMPACT cases"
			label var v10 "Number of TANF IMPACT Cases"
			label var v11 "Number of SNAP IMPACT Cases"
			label var v12 "Total number of adults employed"
			label var v13 "Number of TANF IMPACT adults employed"
			label var v14 "Number of SNAP IMPACT adults employed"
			label var v15 "Total number of adults ineligible due to employment"
			label var v16 "Number of TANF adults ineligible due to employment"
			label var v17 "Number of SNAP adults ineligible due to employment"
			rename v1 issuance
			rename v2 households
			rename v3 individuals
			rename v4 avg_per_hh
			rename v5 avg_per_recip
			rename v6 ffy_cum_pos_errate
			rename v7 mon_pos_errate
			rename v8 ffy_cum_neg_errate
				*rename v9 mon_neg_errate
				*rename v10 total_impact
				*rename v11 tanf_impact
				*rename v12 snap_impact
				*rename v13 total_emp
				*rename v14 tanf_emp
				*rename v15 snap_emp
				*rename v16 total_inelig
				*rename v17 tanf_inelig
				*rename v18 snap_inelig
			rename v9 total_impact
			rename v10 tanf_impact
			rename v11 snap_impact
			rename v12 total_emp
			rename v13 tanf_emp
			rename v14 snap_emp
			rename v15 total_inelig
			rename v16 tanf_inelig
			rename v17 snap_inelig

			// assert one observation
			dropmiss, obs force
			count
			assert r(N) == 1

			// generate year and month variables
			gen year = `year'
			gen month = `month'
			gen ym = ym(year, month)
			format ym %tm 
			order ym year month 
			drop year month 

			// save temporary
			tempfile `year'_`month'
			save ``year'_`month''

		}
	}
}

// append and save 
forvalues year = `start_year'(1)`end_year' {
	forvalues month = 1(1)$monthsinayear {
		display in red "`year'-`month'"
		if (`year' == `start_year' & `month' == `start_month') {
			use ``year'_`month'', clear
		}
		if (`year' == `start_year' & `month' > `start_month') | (`year' > `start_year' & `year' < `end_year') | (`year' == `end_year' & `month' <= `end_month') {
			append using ``year'_`month''
		}
	}
}
save "${dir_root}/data/state_data/indiana/indiana.dta", replace 

