# MyCairoPlayground
A little playground to store some experiments with Cairo, the Starknet smarcontract language.


## Content
The implemented content is:

### Directory Cairo:
ec_mulmuladd.cairo: an implementation of the operation aP+bQ (addition of the results of two distincts point multiplication by scalar a and b). It uses the Shamir's trick with the windowing method.
signature_opt.cairo : optimisation of ECDSA verification using ec_mulmuladd_W function

cairo_secp : optimization of the ECDSA function over sec256k1, using starkware implementation with ec_mulmuladdW_sec256k1 (original implementation from Starkware commons here:https://github.com/https://github.com/starkware-libs/cairo-lang/tree/master/src/starkware/cairo/common/cairo_secp)

cairo_secp256k1 : optimization of the ECDSA function over sec256k1 using ec_mulmuladdW_sec256r1 (original implementation from Cartridge here:https://github.com/cartridge-gg/cairo-secp256r1).


musig2: Original implementation of the Schnorr verification algorithm. Please note that it is a custom implementation (cryptographically equivalent, but not identical to BlockStream implementation).
Namely arbitrary domain separator, choice of hash, byte ordering and annoying little choices are not compatible with Musig2 BIP proposal.

### Directory Sage:
The Musig2 signer implementation in sagemath language, compatible with the musig2.cairo verifier. 


### Directory slides:
A beamer presentation of the Musig2 multisignature protocol.

## Compiling, installing
You need to have Cairo and Sagemath installed.
- Cairo : https://www.cairo-lang.org/docs/quickstart.html
- Sagemath:sudo apt install sagemath
- thoth : https://github.com/FuzzingLabs/thoth/tree/master/thoth



To compile goto Musig2 directoty then type >make. The option of the makefile are:
- make Test_mulmuladd : test the ec_mulmuladd implementation. The test use the elliptic group property that 2(N+1)G+(N-1)G= G
- make Bench_mulmuladd : bench the ec_mulmuladd implementation with a comparizon to non optimized function
- make Cairo: The program writes the test vectors computation in the test_vec.dat file (computed using Sage directory sagemath implementation of signer) 
- make asm : display the assembly. (note that thoth is from FuzzingLabs and not guaranteed to be maintained)


## License 
License: This software is licensed under a dual BSD and GPL v2 license.

## External references
Cairo toolbox is here:
https://github.com/starkware-libs/cairo-lang/

Musig2 specification is here:
https://eprint.iacr.org/2020/1261.pdf 

