// idaho.do
// imports cases and clients from csvs

local ym_start	 				= ym(2009,11) 
local ym_end 					= ym(2022,12)

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
	import excel using "${dir_root}/data/state_data/idaho/excel/`year'-`month'.xlsx", allstring firstrow case(lower) clear
	
	// clean 
	rename a county
	rename ofpopulationonbenefit percpop_snap
	rename participants individuals
	replace county = trim(county)
	replace county = strlower(county)
	destring percpop_snap, replace 
	destring individuals, replace

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
save "${dir_root}/data/state_data/idaho/idaho.dta", replace 


