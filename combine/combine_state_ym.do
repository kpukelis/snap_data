// combine_state_ym.do 
// Kelsey Pukelis

//	alabama			 // not completed (fixed individual)
// 	alaska			 fixed statewide 
//	california		 // not completed (fixed individual)
//	connecticut		 // not completed (fixed individual)
// 	delaware		 rolling clock
//	hawaii			 // not completed (rolling clock)
// 	nevada			 fixed individual
// 	newhampshire	 fixed individual
//	northdakota		 // not completed (rolling clock)
//	oklahoma		 // not completed (fixed individual)
// 	rhodeisland		 fixed statewide
// 	utah			
//	vermont			
//	washington		 // **not completed (fixed statewide, but yearly)
// 	westvirginia	 fixed statewide
// 	wyoming			 fixed statewide
// 	districtofcolumbia			 unclear clock


//	illinois			
//  missouri
//	oregon			


#delimit ;
local states_withtotal
	arizona
	arkansas
	colorado
	iowa
	kansas
	louisiana
	maine
   	maryland
	minnesota
	montana
	newmexico
	newyork
	northcarolina
	ohio
	pennsylvania
	southcarolina
	southdakota
	tennessee
	texas
	virginia
	wisconsin

; 
#delimit cr 

#delimit ;
local states_only
	georgia
	indiana
	kentucky
	mississippi
	missouri
	nebraska		
; 
#delimit cr 

#delimit ;
local states_collapse
	florida
	idaho
	massachusetts
	michigan
	newjersey		
; 
#delimit cr 

***********************************************************************************

// data is there already when county = "total"
foreach state of local states_withtotal {
	
	display in red "`state'"

	use "${dir_root}/state_data/`state'/`state'.dta", clear
	keep if county == "total"
	drop county
	gen state = "`state'"
	tempfile `state'
	save ``state''
}

// data is already only state-month level
**KP: missouri will move when updated	
foreach state of local states_only {

	display in red "`state'"

	use "${dir_root}/state_data/`state'/`state'.dta", clear
	gen state = "`state'"
	tempfile `state'
	save ``state''
}

// need to collapse to get state total
foreach state of local states_collapse {

	display in red "`state'"

	use "${dir_root}/state_data/`state'/`state'.dta", clear 
	gen state = "`state'" 
	describe, varlist
	local variable_list "`r(varlist)'"

	// collapse each var 
	foreach v in individuals households issuance adults children {
		
		capture confirm variable `v' 
		if !_rc {
			preserve 
			collapse (sum) `v', by(state ym)
			tempfile `v'
			save ``v''
			restore
		}
		else {
			preserve
			keep state ym 
			duplicates drop
			gen `v' = .
			tempfile `v'
			save ``v''
			restore
		}

	}
	// merge 
	foreach v in individuals households issuance adults children {
		if strpos("`variable_list'","`v'") {
			if "`v'" == "individuals" {
				use ``v'', clear
			}
			else {
				merge 1:1 state ym using ``v'', assert(3) nogen
			}
		}
	}
	tempfile `state'
	save ``state''

}


*************************************************************************************************

foreach state in `states_withtotal' `states_only' `states_collapse' {
	if "`state'" == "`first_state'" {
		use ``state'', clear
	}
	else {
		append using ``state''
	}
}

// label vars 
label var individuals "Individuals"
label var households "Households"
label var issuance "Issuance"
label var adults "Adults"
label var children "Children"

// order and sort 
order state ym 
sort state ym 

// save 
save "${dir_root}/state_data/state_ym.dta", replace 

