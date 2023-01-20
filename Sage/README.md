# MyCairoPlayground/Sage
Some Sagemath experimentations and high level implementations. The implementations provided here are used for testing and validation of
 Cairo and Nano implementations.



#### Musig2
A custom Musig2 signer implementation in sagemath language, compatible with the musig2.cairo verifier. 
#### Pairings
Implementation of pairings, using external imported from https://gitlab.inria.fr/zk-curves/snark-2-chains/-/tree/master/sage
#### PedersenHash
Implementation of the PedersenHash (mainly for Stark curve simulations)
#### ECDAA
Implementation of Anonymous attestations ECDAA algorithm
#### external
External repo, namingly:
- https://gitlab.inria.fr/zk-curves/snark-2-chains/-/tree/master/sage : a wide variety of generic pairing friendly curves implementation in Sage (bls, bn, bw, kss)

## External references

Musig2 specification is here:
https://eprint.iacr.org/2020/1261.pdf 

