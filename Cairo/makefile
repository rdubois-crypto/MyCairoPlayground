

## This is a simple makefile to fasten Musig2 compilation and testing

clean:
	rm *.json bench/*.dat
	
#Musig2 verification (Schnorr)
Musig2:
	clean
	cairo-compile test_musig2.cairo --output test_musig2.json
	cairo-run --program=test_musig2.json --layout=all

#run a Musig2 aggregation for a set of 'nb_users' size (min=2)
# modify nb_users to choose the size of the system (current=3 users)
# modify size_message to select a different message size
# modify seed value to generate different test vectors (fixed to ease debug)
# modify _MU value to increase the vector size (related to security):
#   as specified:  _MU=2
#   conservative: _MU=4
	
asm:
	thoth -f test_musig2.json

Test_mulmuladd:
	cairo-compile cairo_secp/tests/test_ec_mulmuladd_secp256k1.cairo --output build/test_ec_mulmuladd_secp256k1.json
	cairo-run --program=build/test_ec_mulmuladd_secp256k1.json --layout=all


Bench_mulmuladd:
	##bench sec256k1
	cairo-compile cairo_secp/bench/bench_ecmulmuladd_naive.cairo --output build/test_bench_secp256k1.json
	cairo-run --print_info --program=build/test_bench_secp256k1.json --layout=all>>bench/bench_secp256k1.dat
	cairo-compile cairo_secp/bench/bench_ecmulmuladd_secp256k1.cairo --output test_bench_secp256k1.json
	cairo-run --print_info --program=test_bench_secp256k1.json --layout=all>>bench/bench_secp256k1.dat
	rm test_bench_secp256k1.json
	
default:
	Cairo

