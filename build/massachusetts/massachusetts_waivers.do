// massachusetts_waivers.do 
// Kelsey Pukelis
// builds massachusetts waiver data

/////////////
// 2017-18 //
/////////////

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
*drop zipcode
*drop county
*duplicates drop 

// manually drop one more duplicate 
*count if citytownname == "fiskdale" & waiver2017group == "Waived County" 
*assert r(N) == 1
*drop if citytownname == "fiskdale" & waiver2017group == "Waived County"

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

// reshape long 
duplicates drop 
reshape long waiver, i(citytownname zipcode) j(year)

// gen waiver@zip level 
bysort zipcode year: egen max_waiver = max(waiver)
bysort zipcode year: egen mean_waiver = mean(waiver)
bysort zipcode year: egen min_waiver = min(waiver)
// maybe in the future, one that incorporates population in each town 
rename waiver town_waiver

// reshape to zipcode level 
bysort zipcode year (citytownname): gen obsnum = _n
reshape wide citytownname town_waiver, i(zipcode year) j(obsnum)

// assert level of the data 
duplicates tag zipcode year, gen(dup)
assert dup == 0 
drop dup 

// order 
order zipcode year min_waiver max_waiver mean_waiver county waiver2017group 
sort zipcode year 

// save 
tempfile waivers201718
save `waivers201718'

// save each year separately 
use `waivers201718', clear 
keep if year == 2017
tempfile waivers2017
save `waivers2017'
use `waivers201718', clear 
keep if year == 2018
tempfile waivers2018
save `waivers2018'

////////////////
// 2019, 2020 //
////////////////

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

// ZIP LIST 

// import 
import delimited "${dir_root}/data/policy_data/state_exempt_counties/massachusetts/zips/Export_Output.csv", delimiter(",") case(lower) clear

// rename
rename postcode zipcode 

// zipcode 
tostring zipcode, replace
replace zipcode = "0" + zipcode if strlen(zipcode) == 4
assert strlen(zipcode) == 5

// list of zips only 
keep zipcode
duplicates drop 

// assert level of data 
duplicates tag zipcode, gen(dup)
assert dup == 0
drop dup 

// save 
tempfile ziplist 
save `ziplist'

// ZIP LIST - FULL

// import 
import delimited "${dir_root}/data/policy_data/state_exempt_counties/massachusetts/zips/Export_Output.csv", delimiter(",") case(lower) clear

// drop unneeded vars 
drop fid 
drop area_sqmi
drop shape_area
drop shape_len

// rename
rename postcode zipcode 
rename pc_name 	zipcodename
rename pc_type zipcodetype
rename pa_fips countysubdivisioncodefips
rename pa_name countysubdivisionname
rename city_town citytownname 

// zipcode 
tostring zipcode, replace
replace zipcode = "0" + zipcode if strlen(zipcode) == 4
assert strlen(zipcode) == 5

// lowercase 
foreach var in zipcodename zipcodetype countysubdivisionname citytownname county {
	replace `var' = strlower(`var')
}

// break up city town names 
split citytownname, parse(",")
tab citytownname2
drop citytownname
rename citytownname1 citytownname
rename citytownname2 townof 

// assert level of data 
duplicates tag zipcode citytownname, gen(dup)
assert dup == 0
drop dup 

// order and sort 
sort zipcode countysubdivisioncodefips citytownname

// save 
tempfile ziplist_full
save `ziplist_full'

**********************************************

// merge 2019 data to ziplist_full

// load full ziplist
use `ziplist_full', clear 
merge m:1 citytownname using `waivers2019'
*tab citytownname if _m == 2
*granville (countysubdivisionname) <=> tolland (citytownname), included
assert inlist(citytownname,"clarksburg","granville","new ashford","tisbury") if _m == 2
*drop if _m == 2
*drop _m 
bysort zipcode: egen _merge2019_max = max(_merge)
drop _merge
replace year = 2019 if missing(year)
replace waiver2019 = 0 if missing(waiver2019)
assert year == 2019
rename waiver2019 waiver 
bysort zipcode: egen max_waiver = max(waiver)
bysort zipcode: egen mean_waiver = mean(waiver)
bysort zipcode: egen min_waiver = min(waiver)
drop waiver
drop county 
drop citytownname 
drop townof
drop includes*
duplicates drop 
tempfile waivers2019_full 
save `waivers2019_full'

// merge 2020 data to ziplist_full

// load full ziplist
use `ziplist_full', clear 
merge m:1 citytownname using `waivers2020'
*tab citytownname if _m == 2
*granville (countysubdivisionname) <=> tolland (citytownname), included
assert inlist(citytownname,"aquinnah","clarksburg","granville","montgomery","new ashford","tisbury","washington","west tisbury") if _m == 2
*drop if _m == 2
*drop _m 
bysort zipcode: egen _merge2020_max = max(_merge)
drop _merge
replace year = 2020 if missing(year)
replace waiver2020 = 0 if missing(waiver2020)
assert year == 2020
rename waiver2020 waiver 
bysort zipcode: egen max_waiver = max(waiver)
bysort zipcode: egen mean_waiver = mean(waiver)
bysort zipcode: egen min_waiver = min(waiver)
drop waiver
drop county 
drop citytownname 
drop townof
drop includes*
duplicates drop 
tempfile waivers2020_full 
save `waivers2020_full'

// MERGE 2017-18 DATA TO ZIPLIST

// load ziplist 
use `ziplist', clear 
merge 1:1 zipcode using `waivers2017'
rename _merge _merge2017
replace year = 2017 if missing(year)
foreach var in min_waiver max_waiver mean_waiver {
	replace `var' = 0 if missing(`var')	
}
assert year == 2017
tempfile waivers2017_full 
save `waivers2017_full'

// load ziplist 
use `ziplist', clear 
merge 1:1 zipcode using `waivers2018'
rename _merge _merge2018
replace year = 2018 if missing(year)
foreach var in min_waiver max_waiver mean_waiver {
	replace `var' = 0 if missing(`var')	
}
assert year == 2018
tempfile waivers2018_full 
save `waivers2018_full'

// MERGE ALL YEARS TOGETHER 

// append everything 
use `waivers2017_full', clear 
append using `waivers2018_full'
append using `waivers2019_full'
append using `waivers2020_full'

// make a balanced panel 
destring zipcode, gen(zipcode_num)
drop zipcode
confirm numeric variable zipcode_num
xtset zipcode_num year 
tsfill, full

// fill in waiver status 
foreach var in min_waiver max_waiver mean_waiver {
	replace `var' = 0 if missing(`var')
	assert !missing(`var')
}

// expand to months 
bysort zipcode_num year: assert _N == 1
expand 12
bysort zipcode_num year: gen month = _n 
gen ym = ym(year,month)
format ym %tm 
drop year month 

// 2020 waivers only Jan - Mar 2020
// April 2020 onward statewide waiver due to covid
foreach type in min max mean {
	replace `type'_waiver = 1 if inrange(ym,ym(2020,4),ym(2021,3)) // **KP: not sure when these will end
}

// order and sort 
order zipcode_num ym min_waiver max_waiver mean_waiver
sort zipcode_num ym 

// save full data 
save "${dir_root}/data/state_data/massachusetts/massachusetts_waivers_full.dta", replace 

// save short data 
keep zipcode_num ym min_waiver max_waiver mean_waiver
drop if missing(zipcode_num)
save "${dir_root}/data/state_data/massachusetts/massachusetts_waivers.dta", replace 
unique zipcode_num

// 2015 also was statewide waiver 
gen year = year(dofm(ym))
expand 13 if ym == ym(2020,4)
bysort zipcode_num ym: gen obsnum = _n
sum obsnum
assert r(max) == 13
replace year = 2015 if obsnum > 1
gen month = obsnum - 1 if year == 2015
gen ym_new = ym(year,month)
replace ym_new = ym if missing(ym_new)
drop year 
drop month
drop obsnum
format ym_new %tm 
drop ym 
rename ym_new ym 
tab ym 
sort ym 

// merge in population info 
preserve
import delimited using "${dir_root}/data/policy_data/state_exempt_counties/massachusetts/new england town to zip crosswalk/zcta_necta_rel_10.csv", delimiter(",") varnames(1) clear 
keep zcta5 zpop
rename zcta5 zipcode_num 
confirm numeric variable zipcode_num
duplicates drop 
duplicates tag zipcode_num, gen(dup)
assert dup == 0
drop dup 
tempfile zip_pop
save `zip_pop'
restore
merge m:1 zipcode_num using `zip_pop'

// graph proportion of population with waivers 
// not perfect
preserve 
bysort min_waiver ym: egen zpop_min_waiver = total(zpop)
bysort ym: egen zpop_dnom = total(zpop)
gen prop_min_waiver = zpop_min_waiver / zpop_dnom
keep if min_waiver == 1
keep prop_min_waiver ym 
duplicates drop 
#delimit ;
twoway 
(connected prop_min_waiver  ym, yaxis(1) msize(small)
		legend(off)
		yline(581)
		ylabel(0(0.2)1,angle(0))
		xtitle(`""')
		ytitle(`"approx population in waived zipcodes"')
		title(`""')
		graphregion(fcolor(white))
)
;
#delimit cr 
graph export "${dir_graphs}/ma_waivers_zipcode_pop.png", replace as(png)
restore

// plots which summarize waiver behavior 
collapse (sum) max_waiver min_waiver (mean) mean_waiver, by(ym)

#delimit ;
twoway 
/*(connected max_waiver  ym, yaxis(1) msize(small))*/
(connected min_waiver  ym, yaxis(1) msize(small)
/*(connected mean_waiver ym, yaxis(2) msize(small)*/
		legend(off)
		yline(581)
		ylabel(0 100 200 300 400 500 581,angle(0))
		xtitle(`""')
		ytitle(`"number of waived zipcodes"')
		title(`""')
		graphregion(fcolor(white))
)
;
#delimit cr 

graph export "${dir_graphs}/ma_waivers_zipcode.png", replace as(png)

/*
OLD

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