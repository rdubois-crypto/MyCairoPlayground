## This is a simple makefile to fasten Musig2 compilation and testing


#compile Cairo and Sage and Compare Results
compile_n_run:
	cairo-compile test_musig2.cairo --output test_musig2.json
	date >> test_vec.dat
	sage -c '_MU=2;nb_users=4; size_message=1;seed=0;load("test_musig2_example.sage")' >>test_vec.dat; 

	cairo-run --program=test_musig2.json --layout=all

#run a Musig2 aggregation for a set of 'nb_users' size (min=2)
# modify nb_users to choose the size of the system (current=3 users)
# modify size_message to select a different message size
# modify seed value to generate different test vectors (fixed to ease debug)
# modify _MU value to increase the vector size (related to security):
#   as specified:  _MU=2
#   conservative: _MU=4

example:
	sage -c '_MU=2;nb_users=10; size_message=2;seed=0;load("test_musig2_example.sage")'; 

testvec:
	sage testvector_gen_musig2.sage

asm:
	thoth -f test_musig2.json
		
default: compile_n_run


