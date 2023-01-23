##*************************************************************************************/
##/* Copyright (C) 2022 - Renaud Dubois - This file is part of cairo_musig2 project	 */
##/* License: This software is licensed under a dual BSD and GPL v2 license. 	 */
##/* See LICENSE file at the root folder of the project.				 */
##/* FILE: musig2.sage							             	  */
##/* 											  */
##/* 											  */
##/* DESCRIPTION: ECDAA algorithm*/
##/* This is a high level simulation for validation purpose				  */
##/* 
##https://fidoalliance.org/specs/fido-v2.0-id-20180227/fido-ecdaa-algorithm-v2.0-id-20180227.html#ecdaa-join-algorithm           				  */
##/* note that some constant aggregating values could be precomputed			  */
##**************************************************************************************/
from sage.crypto.util import bin_to_ascii


#uncomment the curve to be used
#BLS12_381 : future of Ethereum
from common.arithmetic.curves.bls12_381 import *
#ALTBN128 aka BN254 : future of Ethereum
from common.arithmetic.curves.atlbn12.py import *



if __name__ == "__main__":
    arithmetic(False)
    local2_test_ate_pairing_bls12_aklgl()

