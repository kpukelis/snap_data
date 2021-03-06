// pub78list.do 
// Kelsey Pukelis
// Explores IRS data to see available data on food banks, food pantries

**************************************************************************************************************************************

// Publication 78 Data
// List of organizations eligible to receive tax-deductible charitable contributions.  If an organization uses a “doing business as” name, is not listed in the file. Only the business name registered with the IRS is in the listing. 

/*
// import 
import delimited using "${dir_root}/data/food_pantry/IRS 990/data-download-pub78/data-download-pub78.txt", delimiter("|") clear

// rename vars 
rename v1 ein_probably
rename v2 name 
rename v3 city 
rename v4 state 
rename v5 country 
rename v6 type_ofsomekind 

// lowercase name 
gen name_lower = strlower(name)

count 
// 1,164,565

// keep if food related 
keep if strpos(name_lower,"food")
sort state city name
count 
// 3850
check
*/
**************************************************************************************************************************************

// import 
import delimited using "${dir_root}/data/food_pantry/IRS 990/data-download-epostcard/data-download-epostcard.txt", delimiter("|") clear
dropmiss, force


// rename vars 
// I actually don't know what these vars are yet; the labels are just guesses for now
rename v1 ein_probably
rename v2 year_ofsomething
rename v3 name 
rename v4 all_Ts
rename v5 truefalse_unknown
rename v6 date_ofsomething
rename v7 date_ofsomethingelse
rename v8 website_or_email
rename v9 contactperson_or_org 
rename v10 address_street1
rename v11 address_unit1
rename v12 city1 
rename v13 city_or_country1
rename v14 state1
rename v15 zip1
rename v16 country1
rename v17 address_street2
rename v18 address_unit2
rename v19 city2 
rename v20 city_or_country2
rename v21 state2
rename v22 zip2
rename v23 country2
rename v24 name_repeated_sometimes
rename v25 almost_emptyA
rename v26 almost_emptyB

// lowercase name 
gen name_lower = strlower(name)

count 
// 1,161,301

// keep if food related 
keep if strpos(name_lower,"food")
sort state city name

count
// 3071
check
