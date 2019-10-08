//----------------------------------------------------------------------------------------
cap program drop updateSB
program define updateSB
//----------------------------------------------------------------------------------------

noi di "Updating and installing custom used packages"

quietly{
	//------------------------------------------------------------
	// stata setup 
	// ------------------------------------------------------------
	ssc install  blindschemes
	ssc install ftools
	ssc install reghdfe
	ssc install moremata
	ftools, compile
	reghdfe, compile
	ssc install distinct
	ssc install winsor2
}

end
*------------------------------------------------------------------------------