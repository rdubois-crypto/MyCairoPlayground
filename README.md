# MyCairoPlayground
A little playground to store some experiments with Cairo, the Starknet smarcontract language.


## Content
You won't find anything fancy here. Just some experiments, beginning with some Musig2 Cairo verification implementation.

Cairo toolbox is here:
https://github.com/starkware-libs/cairo-lang/

Musig2 specification is here:
https://eprint.iacr.org/2020/1261.pdf 


## Compiling, installing
You need to have Cairo and Sagemath installed.
- Cairo : https://www.cairo-lang.org/docs/quickstart.html
- Sagemath:sudo apt install sagemath
- thoth : https://github.com/FuzzingLabs/thoth/tree/master/thoth

To compile type >make. The program display the test vectors computation with sage and their 
execution with Cairo.

To dissassemble, type >make asm (note that thoth is from FuzzingLabs and not guaranteed to be maintained)


## License 
License: This software is licensed under a dual BSD and GPL v2 license.
