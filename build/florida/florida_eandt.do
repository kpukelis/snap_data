
global dir_root 				"C:/Users/Kelsey/Google Drive/Harvard/research/time_limits/state_data/florida"
global dir_data 				"${dir_root}"
global dir_graphs				"${dir_root}/graphs"

*local beginning_clock1 		= ym(2016,1) - 0.5
local beginning_clock1 			= ym(2015,12) - 0.5
local expected_clock1 			= `beginning_clock1' + 3 + 1
*local beginning_clock2 		= ym(2019,1) - 0.5
local beginning_clock2 			= ym(2018,12) - 0.5
local expected_clock2 			= `beginning_clock2' + 3 + 1

local num_counties 				= 6
********************************************************************
**KP: could obtain history of openings and closings using wayback machine, there are many screen shots

/*


// import data 
import excel "${dir_data}/build/CareerSource Florida Network Details Table.xlsx", sheet("data") firstrow case(lower) clear

// drop vars 
dropmiss, force
drop obsnum

// generate observation ID 
gen id = _n
local observations_to_start = _N 

// separate counties vars by commas
replace counties = trim(counties)
split counties, parse(",")
forvalues n = 1/`num_counties' {
	rename counties`n' county`n'
	replace county`n' = trim(county`n')
	replace county`n' = lower(county`n')
}

// reshape long
reshape long county, i(id) j(obsnum)
drop obsnum 
drop if missing(county)
by id: gen obsnum = _n 
by id: gen num_counties = _N

// check that I still have at least one observation for the original list of locations 
count if obsnum == 1
assert r(N) == `observations_to_start'

// dummies for level of service
replace levelofservices = trim(levelofservices)
gen service_full 		= (levelofservices == "Full Service")
gen service_satellite 	= (levelofservices == "Satellite")
gen service_business 	= (levelofservices == "Business Center")

// save
save "${dir_data}/clean/EandTcenters_Florida.dta", replace
*/
**************************************************************************
**************
// unemployment data 
use "${dir_data}/clean/unemp_built_county.dta", clear 

// drop statewide data 
drop if citycounty == "statewide"

// keep data from right around the ABAWD enrollment drop 
keep if ym == ym(2016,3)

// recalulate unemployment rate 
gen unemp_rate_precise = (unemp / laborforce) * 100

// rename to match varname 
rename countyname county 

// save 
tempfile unemp 
save `unemp'

**************

// load data 
use "${dir_data}/clean/EandTcenters_Florida.dta", clear 

// merge in unemployment data 
merge m:1 county using `unemp', keepusing(laborforce emp unemp unemp_rate_precise) assert(3) nogen

// by center: size of laborforce served, size of unemployed served, unemployed rate of served population
bysort id: egen laborforce_served = total(laborforce)
bysort id: egen unemp_served = total(unemp)
gen unemp_rate_served = (unemp_served / laborforce_served) * 100

// leave-one-out: size of laborforce served, size of unemployed served, unemployment rate of served population
gen loo_laborforce_served = laborforce_served - laborforce
gen loo_unemp_served = unemp_served - unemp 
gen loo_unemp_rate_served = (loo_unemp_served / loo_laborforce_served) * 100

**NOTE: right now, because the county groups/regions are mutually exclusive, the leave-one-out mean is the same within county, across centers

// collapse to number of centers in each county
gen count = 1
collapse 	(sum) 	total = count ///
					total_full = service_full ///
					total_satellite = service_satellite ///
					total_business = service_business ///
			(mean)	avg_loo_laborforce_served = loo_laborforce_served ///
					avg_loo_unemp_served = loo_unemp_served ///
					avg_loo_unemp_rate_served = loo_unemp_rate_served ///
					avg_laborforce_served = laborforce_served ///
					avg_unemp_served = unemp_served ///
					avg_unemp_rate_served = unemp_rate_served ///
			(first)	laborforce ///
					emp ///
					unemp ///
					unemp_rate_precise ///
					, by(county)

**KP move this elsewhere later
// clean up countyname for merge 
replace county = subinstr(county, "-", "",.) 
replace county = subinstr(county, ".", "",.) 
replace county = subinstr(county, " ", "",.) 

// save
save "${dir_data}/clean/EandTcenters_Florida_county_level.dta", replace


*******************
use "${dir_data}/clean/EandTcenters_Florida_county_level.dta", clear 
merge 1:1 county using "${dir_data}/clean/drop_county_level.dta", assert(3) nogen 
save "${dir_data}/clean/analysis.dta", replace

check

**KP: should merge in population counts, SNAP population counts
**to see which ones are close to capacity

**KP: should do a geocode merge using address to get a stricter measure of which counties have a center

**KP: consider communiting zones

**KP: see if I can get center openings and closing dates
**KP: see if I can get data on capacity (e.g. number of people able to be served, number of case workers, etc.) at each snap e&t center