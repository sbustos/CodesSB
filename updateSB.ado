//----------------------------------------------------------------------------------------
cap program drop updateSB
program define updateSB
//----------------------------------------------------------------------------------------

noi di "Updating and installing custom used packages (ver Oct 7 2019)"

quietly{
	//------------------------------------------------------------
	// stata setup 
	// ------------------------------------------------------------
	ssc install  blindschemes, replace 
	ssc install ftools, replace 
	ssc install reghdfe, replace 
	ssc install moremata, replace 
	cap ftools, compile
	cap reghdfe, compile
	ssc install distinct, replace 
	ssc install winsor2, replace 
}

end
*------------------------------------------------------------------------------