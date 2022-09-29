

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


asm:
	thoth -f test_musig2.json


default:
	Cairo

