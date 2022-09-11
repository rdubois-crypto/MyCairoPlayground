

compile_n_run:
	cairo-compile test_musig2.cairo --output test_musig2.json
	sage musig2.sage
	cairo-run --program=test_musig2.json --layout=all

asm:
	thoth -f test_musig2.json
		
	
default: compile_n_run


