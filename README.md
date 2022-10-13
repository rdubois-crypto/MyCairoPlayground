# MyCairoPlayground
A little playground to store some experiments with Cairo, the Starknet smarcontract language.


## Content
Some Musig2 Cairo verification implementation with a sage high-level test vectors generation.

Cairo toolbox is here:
https://github.com/starkware-libs/cairo-lang/

Musig2 specification is here:
https://eprint.iacr.org/2020/1261.pdf 


## Compiling, installing
You need to have Cairo and Sagemath installed.
- Cairo : https://www.cairo-lang.org/docs/quickstart.html
- Sagemath:sudo apt install sagemath
- thoth : https://github.com/FuzzingLabs/thoth/tree/master/thoth


To compile goto Musig2 directoty then type >make. The option of the makefile are:
- make (default:Cairo) The program writes the test vectors computation in the test_vec.dat file 
- make asm : display the assembly. (note that thoth is from FuzzingLabs and not guaranteed to be maintained)

## License 
License: This software is licensed under a dual BSD and GPL v2 license.
