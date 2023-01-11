

## This is a simple makefile to fasten Musig2 compilation and testing


#compile Cairo and Sage and Compare Results
Cairo:
	cairo-compile test_musig2.cairo --output test_musig2.json
	cairo-run --program=test_musig2.json --layout=all

#run a Musig2 aggregation for a set of 'nb_users' size (min=2)
# modify nb_users to choose the size of the system (current=3 users)
# modify size_message to select a different message size
# modify seed value to generate different test vectors (fixed to ease debug)
# modify _MU value to increase the vector size (related to security):
#   as specified:  _MU=2
#   conservative: _MU=4

#testing implementation of Windowing+Shamir's trick
Test_mulmuladd:
	cairo-compile tests/test_ec_mulmuladd_secp256k1.cairo --output test_ec_mulmuladd_secp256k1.json
	cairo-run --program=test_ec_mulmuladd_secp256k1.json --layout=all

Bench_mulmuladd:
	cairo-compile bench/bench_ecmulmuladd_naive.cairo --output test_bench_secp256k1.json
	cairo-run --print_info --program=test_bench_secp256k1.json --layout=all>>bench_secp256k1.dat
	
	cairo-compile bench/bench_ecmulmuladd_secp256k1.cairo --output test_bench_secp256k1.json
	cairo-run --print_info --program=test_bench.json --layout=all>>bench.dat
	
asm:
	thoth -f test_musig2.json


default:
	Cairo

