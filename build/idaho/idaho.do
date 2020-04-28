// idaho.do
// imports cases and clients from csvs

global dir_root 				"C:/Users/Kelsey/Google Drive/Harvard/research/time_limits/state_data/idaho"
global dir_data 				"${dir_root}"
global dir_graphs				"${dir_root}/graphs"

local ym_start	 				= ym(2009,11) 
local ym_end 					= ym(2019,10)

************************************************************

forvalues ym = `ym_start'(1)`ym_end' {

	dis in red `ym'

	// for file names
	clear
	set obs 1
	gen year = year(dofm(`ym'))
	gen month = month(dofm(`ym'))
	tostring month, replace 
	replace month = "0" + month if strlen(month) == 1
	local month = month
	display "`month'"
	local year = year 
	display "`year'"

	// import 
	import excel using "${dir_root}/excel/`year'-`month'.xlsx", allstring firstrow case(lower) clear
	
	// clean 
	rename a county
	rename ofpopulationonbenefit percpop_snap
	rename participants persons
	replace county = trim(county)
	replace county = strlower(county)
	destring percpop_snap, replace 
	destring persons, replace

	// date 
	gen ym = `ym'
	format ym %tm 

	// order and sort 
	sort county ym 
	order county ym 

	// save 
	tempfile _`ym'
	save `_`ym''
	
}


**************************
forvalues ym = `ym_start'(1)`ym_end' {
	dis in red `ym'
		if `ym' == `ym_start' {
			use `_`ym'', clear
		}
		else {
			append using `_`ym''
		}
}

// order and sort 
order county ym 
sort county ym

// save 
save "${dir_data}/idaho.dta", replace 
check

