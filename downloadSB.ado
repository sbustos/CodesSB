cap program drop downloadSB
program define downloadSB
	noi di "Downloading SB files"
	qui net install updateSB, from("https://raw.githubusercontent.com/sbustos/codesSB/beta/") replace force

end
