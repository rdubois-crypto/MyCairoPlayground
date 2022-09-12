## This is a simple makefile to fasten Musig2 compilation and testing


#compile Cairo and Sage and Compare Results
compile_n_run:
	cairo-compile test_musig2.cairo --output test_musig2.json
	sage testvector_gen_musig2.sage
	cairo-run --program=test_musig2.json --layout=all

#run a Musig2 aggregation for a set of 'nb_users' size (min=2)
example:
	sage -c 'nb_users=3; size_message=2;load("test_musig2_example.sage")'; 

testvec:
	sage testvector_gen_musig2.sage

asm:
	thoth -f test_musig2.json
		
default: compile_n_run


