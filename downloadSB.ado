cap program drop downloadSB
program define downloadSB

	net install updateSB, from("https://raw.githubusercontent.com/sbustos/codesSB/beta/") replace force

end
