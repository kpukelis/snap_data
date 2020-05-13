// kentucky.do
// imports cases and clients from excel sheets

global dir_root 				"C:/Users/Kelsey/Google Drive/Harvard/research/time_limits/state_data/kentucky"
global dir_data 				"${dir_root}"
global dir_graphs				"${dir_root}/graphs"

local ym_start 					= ym(2005,1)
local ym_end 					= ym(2020,3)

*******************************************************

// import 
import excel "${dir_data}/excel/kentucky_data.xlsx", allstring clear 
drop in 1
rename A monthyear 
rename B recipients

// date 
split monthyear, parse(" ")
rename monthyear1 monthname 
rename monthyear2 year 
destring year, replace 
gen month = ""
replace month = "1" if monthname == "January"
replace month = "2" if monthname == "February"
replace month = "3" if monthname == "March"
replace month = "4" if monthname == "April"
replace month = "5" if monthname == "May"
replace month = "6" if monthname == "June"
replace month = "7" if monthname == "July"
replace month = "8" if monthname == "August"
replace month = "9" if monthname == "September"
replace month = "10" if monthname == "October"
replace month = "11" if monthname == "November"
replace month = "12" if monthname == "December"
destring month, replace 
confirm numeric variable month 
confirm numeric variable year
gen ym = ym(year,month)
format ym %tm 
drop monthyear monthname year month 

// destring
destring recipients, replace
confirm numeric variable recipients

// order and sort 
order ym recipients
sort ym 

// save 
save "${dir_data}/kentucky.dta", replace 


