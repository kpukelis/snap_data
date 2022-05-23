// michigan.do 
// Kelsey Pukelis

local first_year 				= 2009
local years 					2009 2012 2014 2016 2018 2020 // 2019
	// don't need 2019 since all the same info is in 2020 now
local _2009_length 				= 36
local _2012_length 				= 28
local _2014_length 				= 27
local _2016_length 				= 30
local _2018_length 				= 31 // **KP: not sure if this is right note that this could change as more data gets added for 2020
local _2019_length 				= 26 // **KP: note that this could change as more data gets added for 2021
local _2020_length 				= 31 // GUESS **KP: note that this could change as more data gets added for 2022

local first_county 				Alcona
#delimit ;
local counties 					
/*State*/ /*first page of state totals not imported properly for years 2012, 2014, 2016, and 2018*/
Alcona
Alger
Allegan
Alpena
Antrim
Arenac
Baraga
Barry
Bay
Benzie
Berrien
Branch
Calhoun
Cass
Charlevoix
Cheboygan
Chippewa
Clare
Clinton
Crawford
Delta
Dickinson
Eaton
Emmet
Genesee
Gladwin
Gogebic
Traverse
Gratiot
Hillsdale
Houghton
Huron
Ingham
Ionia
Iosco
Iron
Isabella
Jackson
Kalamazoo
Kalkaska
Kent
Keweenaw
Lake
Lapeer
Leelanau
Lenawee
Livingston
Luce
Mackinac
Macomb
Manistee
Marquette
Mason
Mecosta
Menominee
Midland
Missaukee
Monroe
Montcalm
Montmorency
Muskegon
Newaygo
Oakland
Oceana
Ogemaw
Ontonagon
Osceola
Oscoda
Otsego
Ottawa
Presque
Roscommon
Saginaw
Sanilac
Schoolcraft
Shiawassee
Clair
Joseph
Tuscola
Buren
Washtenaw
Wayne
Wexford
Unassigned
;
#delimit cr 

********************************************************************

foreach year of local years {
	dis in red "`year'"
	
	// import data 
	import excel "${dir_root}/data/state_data/michigan/excel/DHS-Trend_Table_24_269236_7_`year'.xlsx", allstring case(lower) clear

	// initial cleanup
	dropmiss, force 
	dropmiss, obs force 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber

	// drop title line
	drop if strpos(v1,"Reporting Month")
	// drop monthly averages 
	drop if strpos(v1,"Monthly Avg.")
	// drop unnecessary lines 
	drop if strpos(v1,"Fiscal Year")
	drop if strpos(v2,"Fiscal Year")

	// county list 
	*list v1 if strpos(v1,"County")

	// second cleanup
	dropmiss, force 
	dropmiss, obs force 
	describe, varlist 
	rename (`r(varlist)') (v#), addnumber

	gen obsnum = _n

	foreach county of local counties {
		
		display in red `"`county'"'

		// preserve
		preserve 
		
		if "`county'" == "State" {
			// get state totals  
			keep if obsnum <= `_`year'_length'
			drop obsnum 
		}
		else {
			sum obsnum if strpos(v1,"County") & strpos(v1,"`county'")
			assert r(N) == 1
			local begin_data = r(mean) + 1
			local end_data = r(mean) + `_`year'_length'
			keep if inrange(obsnum,`begin_data',`end_data')
			drop obsnum
		}

		// make sure I have the right shape 
		describe, varlist 
		assert r(k) == 9
		assert r(N) == `_`year'_length'

		// rename variables 
		rename v1 monthyear 
		rename v2 households 
		rename v3 individuals 
		rename v4 adults 
		rename v5 children 
		rename v6 issuance 
		rename v7 avg_pay_per_case
		rename v8 avg_pay_per_person 
		rename v9 avg_recip_per_case

		// fix date 
		replace monthyear = trim(monthyear)
		split monthyear, parse(" ")
		rename monthyear1 monthname 
		rename monthyear2 yearshort 
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
		assert !missing(month)
		destring month, replace 
		drop monthname
		destring yearshort, replace ignore("\'")
		confirm numeric variable yearshort
		gen year = yearshort + 2000
		drop yearshort
		drop monthyear
		gen ym = ym(year,month)
		format ym %tm 
		drop year month 

		// generate county variables 
		gen county = "`county'"
			// fix names that have more than one word
			replace county = "grand traverse" if county == "traverse"
			replace county = "presque isle" if county == "presque"
			replace county = "saint clair" if county == "clair"
			replace county = "saint joseph" if county == "joseph"
			replace county = "van buren" if county == "buren"

		// destring 
		foreach var in households individuals adults children issuance avg_pay_per_case avg_pay_per_person avg_recip_per_case {

			// destring 
			destring `var', replace 
			
			// assert variable is numeric
			confirm numeric variable `var'
		}

		// sort and order 
		order county ym 
		sort county ym 

		// save 
		tempfile _`county'
		save `_`county''

		// restore
		restore 
	}

	// append data across counties 
	foreach county of local counties {
		if "`county'" == "`first_county'" {
			use `_`county'', clear 
		}
		else {
			append using `_`county''
		}
	}

	// order and sort 
	order county ym 
	sort county ym 

	// save 
	tempfile _`year'
	save `_`year''

}


**********************************

// append across years 
foreach year of local years {
	if "`year'" == "`first_year'" {
		use `_`year'', clear
	}
	else {
		append using `_`year''
	}
}

// change name for total column
replace county = "total" if county == "State"

// make counties lowercase
replace county = strlower(county)

// drop duplicates
duplicates drop 

// assert level of data 
duplicates tag county ym, gen(dup)
assert dup == 0
drop dup 

// order and sort 
order county ym 
sort county ym 

// save 
save "${dir_root}/data/state_data/michigan/michigan.dta", replace 


	