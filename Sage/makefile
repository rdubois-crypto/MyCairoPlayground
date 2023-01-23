# if your imports fail, try this:
export_path:
	export PYTHONPATH=$PYTHONPATH:$(pwd)

## This is a simple makefile to fasten Musig2 compilation and testing


#compile Cairo and Sage and Compare Results
test_bls12_381:
	sage common/arithmetic/curves/bls12_381.sage
test_altbn128:
	sage common/arithmetic/curves/atlbn128.py

test_ecdaa:
	sage ECDAA/tests/test_ECDAA.sage


