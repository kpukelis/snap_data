// combine_state_month.do 
// Kelsey Pukelis

#delimit ;
local states
	alabama			 // not completed (fixed individual)
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
	
	use "${dir_data}/`state'.dta", clear
	keep if county == "state total"

	check

}



