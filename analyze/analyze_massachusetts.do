// massachusetts_analyze.do
// imports households and persons from excel sheets

local beginning_clock1 			= ym(2018,1) - 0.5 
local expected_clock1 			= `beginning_clock1' + 3 + 1
*local beginning_clock2 			= ym(2019,3) - 0.5
*local expected_clock2 			= `beginning_clock2' + 3 + 1
local outcome 					cases
local background_color			white
local bar_color 				blue
local baroutline_color 			black
local baroutline_size 			medium
local start_graph				ym(2008,3)
local ytitle_size 				small
local dot_size 					tiny // vsmall

*********************************************



/*
// statewide graphs 

use "${dir_root}/massachusetts.dta", clear
keep if city == "grand total"

**KP: move this elsewhere later
label var cases "SNAP households"
label var recipients "SNAP persons"


foreach outcome in cases recipients {

	// graph
	twoway connected `outcome' ym if ym >= `start_graph', ///
		msize(`dot_size') ///
		xtitle(`""') ///
		title(`""') ///
		graphregion(fcolor(`background_color'))
/*		xline(`expected_clock1') xline(`expected_clock2') /// */
/*		caption(`"Vertical lines at expected effect."') /// */

	graph export "${dir_graphs}/`outcome'_raw.png", replace as(png)

}
*/


*********************************************

/////////////
// WAIVERS //
/////////////

// 2017-18

// merge in waiver status: at city/town level 
import excel "${dir_root}/data/policy_data/state_exempt_counties/massachusetts/ma_waivers.xlsx", sheet("waivers201718") firstrow case(lower) allstring clear

// zipcode 
replace zip = "0" + zip if strlen(zip) == 4
assert strlen(zip) == 5

// lowercase city name 
foreach var in citytownname county {
	replace `var' = strlower(`var')
	replace `var' = trim(`var')
}

// destring 
foreach var of varlist waiver???? {
	destring `var', replace 
	confirm numeric variable `var'
}

// drop zipcode, county: other years is just city-town level data 
drop zipcode
drop county
duplicates drop 

// manually drop one more duplicate 
count if citytownname == "fiskdale" & waiver2017group == "Waived County" 
assert r(N) == 1
drop if citytownname == "fiskdale" & waiver2017group == "Waived County"

// manual fix names 
replace citytownname = "great barrington" if citytownname == "gt barrington"
replace citytownname = "indian orchard" if citytownname == "indian orchrd"
replace citytownname = "marstons mills" if citytownname == "marstons mlls"
replace citytownname = "raynham center" if citytownname == "raynham ctr"
replace citytownname = "sagamore beach" if citytownname == "sagamore bch"
replace citytownname = "westover" if citytownname == "westover afb"
replace citytownname = "westport point" if citytownname == "westport pt"
replace citytownname = "cuttyhunk island" if citytownname == "cuttyhunk"
**replace citytownname = "dudley" if citytownname == "dudley hill"
**replace citytownname = "lenox" if citytownname == "lenox dale"
**replace citytownname = "raynham" if citytownname == "raynham center"
**replace citytownname = "wendell" if citytownname == "wendell depot"
**replace citytownname = "barnstable" if citytownname == "west barnstable"

// standardize boro vs. borough 
replace citytownname = ustrregexra(citytownname,"boro$","borough")

// assert level of the data 
duplicates tag citytownname, gen(dup)
assert dup == 0 
drop dup 

// save 
tempfile waivers201718
save `waivers201718'

// 2019, 2020

forvalues year = 2019(1)2020 {

	// merge in waiver status: at city/town level 
	import excel "${dir_root}/data/policy_data/state_exempt_counties/massachusetts/ma_waivers.xlsx", sheet("waivers`year'") firstrow case(lower) allstring clear
	
	// rename to match 
	rename towncity citytownname
	
	// lowercase city name 
	foreach var in citytownname {
		replace `var' = strlower(`var')
		replace `var' = trim(`var')
	}
	
	// standardize boro vs. borough 
	replace citytownname = ustrregexra(citytownname,"boro$","borough")

	// year 
	gen year = `year'
	
	// waiver 
	// Note: only is list of waived towns; does not include unwaived towns 
	gen waiver`year' = 1
	
	// assert level of the data 
	duplicates tag citytownname, gen(dup)
	assert dup == 0 
	drop dup 
	
	// save 
	tempfile waivers`year'
	save `waivers`year''

}

// TOWN CITY LIST 

// merge in waiver status: at city/town level 
import excel "${dir_root}/data/policy_data/state_exempt_counties/massachusetts/ma_waivers.xlsx", sheet("towncitylist") firstrow case(lower) allstring clear
dropmiss, force 
dropmiss, force obs 

// rename 
rename towncityname citytownname
*rename citytown 
drop datesettled
drop incorporatedasatowncity

// lowercase city name 
foreach var in citytownname county {
	replace `var' = subinstr(`var',"*","",.)
	replace `var' = strlower(`var')
	replace `var' = trim(`var')
}

// standardize boro vs. borough 
replace citytownname = ustrregexra(citytownname,"boro$","borough")

// assert level of the data 
duplicates tag citytownname, gen(dup)
assert dup == 0 
drop dup 

// save 
tempfile citytownlist 
save `citytownlist'


// "INCLUDING" LIST 

// 2019
use `waivers2019', clear 
reshape long includes, i(citytownname) j(num)
drop if missing(includes)
replace includes = strlower(includes)
drop waiver2019
drop year 
tempfile includes2019
save `includes2019'

// 2020
use `waivers2020', clear 
reshape long includes, i(citytownname) j(num)
drop if missing(includes)
replace includes = strlower(includes)
drop waiver2020
drop year 
tempfile includes2020
save `includes2020'

// combine 
use `includes2019', clear 
append using `includes2020'
duplicates drop 

// manual drop 
drop if citytownname == "rowe" & includes == "monroe bridge"
drop if citytownname == "west tisbury" & includes == "vineyard haven"

// manual fix 
replace includes = "cuttyhunk island" if includes == "cuttyhunk"
replace includes = "dudley" if includes == "dudley hill"
replace includes = "lenox" if includes == "lenox dale"
replace includes = "raynham" if includes == "raynham center"
replace includes = "wendell" if includes == "wendell depot"
replace includes = "barnstable" if includes == "west barnstable"

// standardize boro vs. borough 
replace citytownname = ustrregexra(citytownname,"boro$","borough")
replace includes = ustrregexra(includes,"boro$","borough")

// assert level of the data 
duplicates tag includes, gen(dup)
assert dup == 0
drop dup 

// rename 
rename citytownname citytownname_large 
rename includes citytownname

// save 
tempfile includes 
save `includes'

// MERGE WAIVERS ONTO CITYTOWNLIST

*use `citytownlist', clear 
use "${dir_root}/data/state_data/_fips/macitytowns.dta", clear
rename areaname citytownname
// standardize boro vs. borough 
replace citytownname = ustrregexra(citytownname,"boro$","borough")
// just keep one year; they are all pretty much the same 
keep if year == 2018
drop year 

// merge in 2017, 2018 waivers 
merge 1:1 citytownname using `waivers201718'
rename _merge _merge2017
	// see if the unmerged town names are actually mini-towns
	merge 1:1 citytownname using `includes'
	rename _merge _mergeincludes
	drop if _mergeincludes == 2
	tab _mergeincludes if _merge2017 == 2
	// yes, some are mini-towns, can safely drop those 
	drop if _mergeincludes == 3 & _merge2017 == 2
	assert _mergeincludes == 1 | citytownname == "oxford"
	*tab citytownname if _mergeincludes == 1
	tab citytownname if _merge2017 == 2
	/*
	keep if _merge2017 == 2
	citytownname
	ashley falls
	baldwinville
	bass river
	berkshire
	buzzards bay
	cataumet
	centerville
	chartley
	cotuit
	cummaquid
	cuttyhunk -> cuttyhunk island
	dudley hill -> dudley? no
	east orleans
	east otis
	east taunton
	east templeton
	east wareham
	fiskdale
	gay head
	glendale
	housatonic
	hyannis
	hyannis port
	lenox dale -> lenox? no
	marstons mills
	mill river
	monument bch
	north egremont
	onset
	osterville
	pocasset
	raynham center -> raynham? no
	sagamore
	sagamore beach
	siasconset
	south attleborough
	south egremont
	south lee
	south orleans
	south royalston
	southfield
	wendell depot -> wendell? no
	west barnstable -> barnstable? no
	west hyannisport
	west otis
	west wareham
	white horse
	winchendon sp
	*/
// drop these non-towns
drop if _merge2017 == 2 & _mergeincludes == 1
assert _merge2017 != 2
drop _mergeincludes
drop citytownname_large
drop num 
replace waiver2017 = 0 if _merge2017 == 1
assert !missing(waiver2017)
replace waiver2018 = 0 if _merge2017 == 1
assert !missing(waiver2018)

// merge 2019 waivers 
merge 1:1 citytownname using `waivers2019'
rename _merge _merge2019
assert _merge2019 != 2
replace waiver2019 = 0 if _merge2019 == 1
assert !missing(waiver2019)
drop year 

// merge 2020 waivers 
merge 1:1 citytownname using `waivers2020'
rename _merge _merge2020
assert _merge2020 != 2
replace waiver2020 = 0 if _merge2020 == 1
assert !missing(waiver2020)
drop year 

// drop vars 
drop includes*
drop _merge2017
drop _merge2019
drop _merge2020

// order 
order citytownname city town countysubdivisioncodefips countyfips waiver2017group waiver20??
check

// reshape long 
reshape long waiver, i(citytownname) j(year)


KEEP GOING HERE, 2019, 2020

sort zip citytownname
*br if dup > 0
drop dup

// collapse to level of zipcode (shouldn't affect many observations)
forvalues y = 2017(1)2018 {
	bysort zip: egen max_waiver`y' = max(waiver`y')
	bysort zip: egen mean_waiver`y' = mean(waiver`y')
	drop waiver`y'
}
drop citytownname
duplicates drop 
duplicates tag zip, gen(dup)
assert dup == 0
drop dup 

// reshape to year 
reshape long max_waiver mean_waiver, i(zip) j(year)

// expand to months 
bysort zip year: assert _N == 1
expand 12
bysort zip year: gen month = _n 
gen ym = ym(year,month)
format ym %tm 
drop year month 

// 2020 waivers only Jan - Mar 2020
// April 2020 onward statewide waiver due to covid
foreach type in max mean {
	replace `type'_waiver = 1 if inrange(ym,ym(2020,4),ym(2021,3)) // **KP: not sure when these will end
}

// order and sort 
order zip county ym max_waiver mean_waiver waiver2017group
sort zip ym 

// save 
tempfile waivers 
save `waivers'

// save 2018 waivers 
keep if ym == ym(2018,1)
drop ym 
rename max_waiver max_waiver2018
rename mean_waiver mean_waiver2018

// assert level 
duplicates tag zip, gen(dup)
assert dup == 0
drop dup 

// save 
tempfile waivers2018 
save `waivers2018'

**********************************************

// by county waiver status

// load massachusetts data 
use "${dir_root}/data/state_data/massachusetts/massachusetts.dta", clear 

// assert level of data 
duplicates tag zip ym, gen(dup)
assert dup == 0
drop dup 

// merge in 2018 waiver status 
merge m:1 zip using `waivers2018'
**not sure about _m == 2 cases, drop for now
drop if _m == 2
// zips not included don't have waivers 
replace max_waiver2018 = 0 if _m == 1
replace mean_waiver2018 = 0 if _m == 1
drop _m 

collapse (sum) households individuals, by(max_waiver2018 ym)

gen relative_ym = ym - `expected_clock1'

separate households, by(max_waiver2018)
separate individuals, by(max_waiver2018)

*keep if inrange(relative_ym,-12,12)
*ym >= `start_graph'
gen year = year(dofm(ym))
gen month = month(dofm(ym))

*forvalue d = 2

foreach var in households0 individuals0 households1 individuals1 {
	*regress `var' i.year i.month
	regress `var' ym 
	predict resid_`var', residual
}



// graph
#delimit ;
	twoway (connected households0 ym , yaxis(1) msize(`dot_size')) 
		   /*(connected individuals0 ym , yaxis(2) msize(`dot_size'))*/
		   (connected households1 ym , yaxis(2) msize(`dot_size')
		   /*(connected individuals1 ym , yaxis(2) msize(`dot_size')*/
		/*legend(label(1 "No county waiver (left axis)") label(2 "County waiver (right axis)") region(lstyle(none))) */
		ylabel(,labsize(vsmall) axis(1))
		ylabel(,labsize(vsmall) axis(2))
		xline(`expected_clock1') /*xline(`expected_clock2') */
		xtitle(`""') 
		title(`""') 
		caption(`"Vertical line at expected effect."' `"households series on left axis and individuals series on right axis."', size(small)) 
		graphregion(fcolor(`background_color')) 
		)
;
#delimit cr 
		
	graph export "${dir_graphs}/massachusetts_raw_bywaiver_byage.png", replace as(png)
check



check

