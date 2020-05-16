global dir_root 				"C:/Users/Kelsey/Google Drive/Harvard/research/time_limits/state_data/texas"
global dir_data 				"${dir_root}"
global dir_graphs				"${dir_root}/graphs"

local ym_start 					= ym(2005,9)
local ym_end 					= ym(2020,4)

*********************************************

// import 
import excel using "${dir_root}/excel/state/snap-cases-eligible-statewide.xlsx", case(lower) allstring clear

// initial cleanup
dropmiss, force 
dropmiss, obs force 
describe, varlist 
rename (`r(varlist)') (v#), addnumber


drop if strpos(v1,"Benefit") & strpos(v1,"Month")
drop if strpos(v2,"Monthly SNAP Cases & Eligible Individuals Statewide")
drop if strpos(v2,"Data Source: dbo.b_DM_SNAP_CLIENT_MonthEnd and dbo.b_DM_SNAP_EDG_MonthEnd")
drop if strpos(v2,"Prepared by Human Services Programs")
drop if strpos(v2,"Case = designated group of people certified to receive the benefit (can be more than one person).")
drop if strpos(v2,"Average Payment / Case = average dollar benefit available to the case (shared by the recipients on that case)")
drop if v1 == "Average"
drop if v1 == "Year-To-Date"

// rename 
dropmiss, force 
dropmiss, obs force 
describe, varlist 
rename (`r(varlist)') (v#), addnumber
assert r(k) == 10
assert r(N) == `ym_end' - `ym_start' + 1
rename v1 monthyear 
rename v2 cases
rename v3 recipients
rename v4 age_00_04
rename v5 age_05_17
rename v6 age_18_59
rename v7 age_60_64
rename v8 age_65
rename v9 issuance
rename v10 avg_payment_percase

// date 
split monthyear, parse("-")
rename monthyear1 monthname 
rename monthyear2 yearshort
gen month = ""
replace month = "1" if monthname == "Jan"
replace month = "2" if monthname == "Feb"
replace month = "3" if monthname == "Mar"
replace month = "4" if monthname == "Apr"
replace month = "5" if monthname == "May"
replace month = "6" if monthname == "Jun"
replace month = "7" if monthname == "Jul"
replace month = "8" if monthname == "Aug"
replace month = "9" if monthname == "Sep"
replace month = "10" if monthname == "Oct"
replace month = "11" if monthname == "Nov"
replace month = "12" if monthname == "Dec"
destring month, replace 
confirm numeric variable month 
drop monthname
destring yearshort, replace 
confirm numeric variable yearshort
gen year = 2000 + yearshort
gen ym = ym(year,month)
format ym %tm
drop monthyear yearshort year month 

// destring 
foreach var in cases recipients issuance age_00_04 age_05_17 age_18_59 age_60_64 age_65 avg_payment_percase {
	destring `var', replace 
	confirm numeric variable `var'
}

// order and sort 
order ym cases recipients issuance age_00_04 age_05_17 age_18_59 age_60_64 age_65 avg_payment_percase
sort ym 

// save 
save "${dir_data}/texas_state.dta", replace 
