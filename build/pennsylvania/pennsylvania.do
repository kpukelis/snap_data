// pennsylvania.do
// imports households and persons from excel sheets

global dir_root 				"C:/Users/Kelsey/Google Drive/Harvard/research/time_limits/state_data/pennsylvania"
global dir_data 				"${dir_root}"
global dir_graphs				"${dir_root}/graphs"

local files 					July2017 Oct2017 Apr2019 Oct2019 Apr2020

local ym_start					= ym(2016,7)
local ym_end 					= ym(2020,4)

***************************************************************

foreach file of local files {
	foreach sheet in "SNAPIndividuals-HistorybyCounty" "SNAP $-HistorybyCounty" {
		
		display in red "`file'"
		display in red "`sheet'"

		// import 
		import excel using "${dir_root}/pdfs/needed/MA_TANF_GA_SNAP_`file'.xlsx", sheet("`sheet'") /*firstrow*/ case(lower) allstring clear
		dropmiss, force obs

		// rename variables
		foreach v of varlist _all {
			qui replace `v' = ustrregexra(`v',"20","2020") if _n == 1 & strpos(`v',"20") == 5
			qui replace `v' = ustrregexra(`v',"04","2004") if _n == 1
			qui replace `v' = ustrregexra(`v',"05","2005") if _n == 1
			qui replace `v' = ustrregexra(`v',"06","2006") if _n == 1
			qui replace `v' = ustrregexra(`v',"07","2007") if _n == 1
			qui replace `v' = ustrregexra(`v',"08","2008") if _n == 1
			qui replace `v' = ustrregexra(`v',"09","2009") if _n == 1
			qui replace `v' = ustrregexra(`v',"10","2010") if _n == 1
			qui replace `v' = ustrregexra(`v',"11","2011") if _n == 1
			qui replace `v' = ustrregexra(`v',"12","2012") if _n == 1
			qui replace `v' = ustrregexra(`v',"13","2013") if _n == 1
			qui replace `v' = ustrregexra(`v',"14","2014") if _n == 1
			qui replace `v' = ustrregexra(`v',"15","2015") if _n == 1
			qui replace `v' = ustrregexra(`v',"16","2016") if _n == 1
			qui replace `v' = ustrregexra(`v',"17","2017") if _n == 1
			qui replace `v' = ustrregexra(`v',"18","2018") if _n == 1
			qui replace `v' = ustrregexra(`v',"19","2019") if _n == 1
			qui replace `v' = ustrregexra(`v',"Jan","_01") if _n == 1
			qui replace `v' = ustrregexra(`v',"Feb","_02") if _n == 1
			qui replace `v' = ustrregexra(`v',"Mar","_03") if _n == 1
			qui replace `v' = ustrregexra(`v',"Apr","_04") if _n == 1
			qui replace `v' = ustrregexra(`v',"May","_05") if _n == 1
			qui replace `v' = ustrregexra(`v',"Jun","_06") if _n == 1
			qui replace `v' = ustrregexra(`v',"Jul","_07") if _n == 1
			qui replace `v' = ustrregexra(`v',"Aug","_08") if _n == 1
			qui replace `v' = ustrregexra(`v',"Sep","_09") if _n == 1
			qui replace `v' = ustrregexra(`v',"Oct","_10") if _n == 1
			qui replace `v' = ustrregexra(`v',"Nov","_11") if _n == 1
			qui replace `v' = ustrregexra(`v',"Dec","_12") if _n == 1
     		local try = strtoname(`v'[1]) 
     		capture rename `v' `try' 
		}
		rename A county
		rename _07_2014 _07_2014
		drop in 1
		drop if strpos(_07_2014,"New methodology used.") | strpos(_07_2014,"New method eliminates duplication of persons") | strpos(_07_2014,"moving from county to county in a given month.")

		// reshape
		reshape long _, i(county) j(mm_yyyy) string
		drop if missing(_)
		noisily drop if missing(county)
		replace _ = "" if strpos(_,"*Due to the partial federal government shutdown, SNAP participants' February benefits were issued to EBT cards on or before Jan. 18, 2019.")
		destring _, replace
		confirm numeric variable _
		if "`sheet'" == "SNAPIndividuals-HistorybyCounty" {
			rename _ individuals
		}
		if "`sheet'" == "SNAP $-HistorybyCounty" {
			rename _ issuance
		}

		// clean up vars 
		replace county = trim(county)
		replace county = strlower(county)
		gen month = substr(mm_yyyy,1,2)
		gen year = substr(mm_yyyy,4,7)
		destring month year, replace
		confirm numeric variable month
		confirm numeric variable year
		gen ym = ym(year,month)
		format ym %tm 
		drop year month mm_yyyy

		// order and sort 
		order county ym 
		sort county ym

		// save 
		if "`sheet'" == "SNAPIndividuals-HistorybyCounty" {
			tempfile individuals
			save `individuals'
		}
		if "`sheet'" == "SNAP $-HistorybyCounty" {
			tempfile issuance
			save `issuance'
		}
	}

	use `individuals', clear
	merge 1:1 county ym using `issuance'
	assert _m == 3
	drop _m 
	tempfile `file'
	save ``file''
	
}

*******************************************

foreach file of local files {
	if "`file'" == "July2017" {
		use ``file'', clear
	}
	else {
		append using ``file''
	}
	duplicates drop
}

// make sure all duplicates were dropped
duplicates tag county ym, gen(dup)
assert dup == 0
drop dup

// order and sort 
order county ym
sort county ym

// save
save "${dir_root}/pennsylvania.dta", replace


