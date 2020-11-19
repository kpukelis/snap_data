// combine_state_month.do 
// Kelsey Pukelis

#delimit ;
local states
//	alabama			 // not completed (fixed individual)
// 	alaska			 fixed statewide 
	arizona			
	arkansas			
	california		 // not completed (fixed individual)
	colorado			
	connecticut		 // not completed (fixed individual)
// 	delaware		 rolling clock
	florida			
	georgia			 
	hawaii			 // not completed (rolling clock)
	idaho			
	illinois			
	indiana			
	iowa			
	kansas			
	kentucky			
	louisiana			
	maine			
	maryland			
	massachusetts			
	michigan			
	minnesota			
	mississippi			
	missouri			
	montana			
	nebraska			
// 	nevada			 fixed individual
// 	newhampshire	 fixed individual
	newjersey			
	newmexico			
	newyork			
	northcarolina			
	northdakota		 // not completed (rolling clock)
	ohio			
	oklahoma		 // not completed (fixed individual)
	oregon			
	pennsylvania			
// 	rhodeisland		 fixed statewide
	southcarolina			
	southdakota			
	tennessee			
	texas			
// 	utah			
	vermont			
	virginia		
	washington		 // **not completed (fixed statewide, but yearly)
// 	westvirginia	 fixed statewide
	wisconsin			
// 	wyoming			 fixed statewide
// 	districtofcolumbia			 unclear clock
; 
#delimit cr 


***********************************************************************************

foreach state of local states {
	
	// state total already in the data 
	if inlist("`state'","arizona","arkansas","colorado","iowa","kansas","louisiana","maine","maryland","minnesota","montana") {
		use "${dir_root}/state_data/`state'/`state'.dta", clear
		keep if county == "total"
		drop county 
		gen state = "`state'"
		tempfile `state'
		save ``state''
	}
	// data is already only state-month level
	**KP: missouri will move when updated
	else if inlist("`state'","georgia","indiana","kentucky","mississippi","missouri","nebraska") {
		use "${dir_root}/state_data/`state'/`state'.dta", clear
		gen state = "`state'"
		tempfile `state'
		save ``state''
	}
	// need to collapse to get state total
	else if inlist("`state'","florida","idaho","massachusetts","michigan") {
		use "${dir_root}/state_data/`state'/`state'.dta", clear 
		gen state = "`state'" 
		describe, varlist

		// collapse each var 
		foreach v in individuals households issuance adults children {
			capture confirm variable `v' 
			!_rc {
				collapse (sum) `v', by(state ym)
			}
			else {
				keep state ym 
				duplicates drop
				gen `v' = .
			}
			tempfile `v'
			save ``v''
		}
		// merge 
		foreach v in individuals households issuance adults children {
			if "`v'" == "individuals" {
				use ``v'', clear
			}
			else {
				merge 1:1 state ym using ``v'', assert(3) nogen
			}
		}
		tempfile `state'
		save ``state''
	}


	check

}



