cap program drop downloadSB
program define downloadSB
	noi di "Downloading SB files"
	qui net install updateSB, from("https://raw.githubusercontent.com/sbustos/codesSB/master/") replace force
	qui net install ecomplexity, from("https://raw.githubusercontent.com/cid-harvard/ecomplexity/beta/") replace force
end
