//*************************************************************************************/
///* Copyright (C) 2022 - Renaud Dubois - This file is part of Cairo_musig2 project	 */
///* License: This software is licensed under a dual BSD and GPL v2 license. 	 */
///* See LICENSE file at the root folder of the project.				 */
///* FILE: test_ecdsa_opti.cairo						         */
///* 											 */
///* 											 */
///* DESCRIPTION:  testing file for ecdsa speed up with mulmuladd over sec256r1 curve */
//**************************************************************************************/

//Shamir's trick:https://crypto.stackexchange.com/questions/99975/strauss-shamir-trick-on-ec-multiplication-by-scalar,
//Windowing method : https://en.wikipedia.org/wiki/Exponentiation_by_squaring, section 'sliding window'
//The implementation use a 2 bits window with trick, leading to a 16 points elliptic point precomputation

%builtins range_check 

from starkware.cairo.common.cairo_builtins import EcOpBuiltin 
from starkware.cairo.common.registers import get_ap
from starkware.cairo.common.registers import get_fp_and_pc
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.math_cmp import is_nn_le
from starkware.cairo.common.cairo_secp.bigint import BigInt3, UnreducedBigInt3, nondet_bigint3
from starkware.cairo.common.cairo_secp.field import (
    is_zero,
    unreduced_mul,
    unreduced_sqr,
    verify_zero,
)


from starkware.cairo.common.cairo_secp.signature import recover_public_key
from cairo_secp.signature_opti import recover_public_key_opti

from starkware.cairo.common.cairo_secp.ec import EcPoint, ec_add, ec_mul, ec_negate, ec_double

func test_verify_ecdsa{range_check_ptr}() {
   alloc_locals;
 
   let generator=EcPoint(
            BigInt3(0xe28d959f2815b16f81798, 0xa573a1c2c1c0a6ff36cb7, 0x79be667ef9dcbbac55a06),
            BigInt3(0x554199c47d08ffb10d4b8, 0x2ff0384422a3f45ed1229a, 0x483ada7726a3c4655da4f),
        );
   
  //dummy privatekey
  //let private_key=BigInt3(0xa1eaa1eaa1eaa1eaa1eaa, 0xa1eaa1eaa1eaa1eaa1eab, 0xa1eaa1eaa1eaa1eaa1eac);
   // corresponding pubkey
  //let public_key_pt=ec_mul(generator, private_key);
   // dummy nonce
  let nonce1=BigInt3(0xcacaa1eaa1eaa1eaacaca, 0xcacaa1eaa1eaa1eaacaca, 0xcacaa1eaa1eaa1eaacaca);
  let nonce2=BigInt3(0xcacaa1eaa1eaa1eaacaca, 0xcacaa1eaa1eaa1eaacaca, 0xcacaa1eaa1eaa1eaacaca);
  //let s:EcPoint=ec_mul( generator, nonce2);
   let s=EcPoint(
            BigInt3(0xe28d959f2815b16f81798, 0xa573a1c2c1c0a6ff36cb7, 0x79be667ef9dcbbac55a06),
            BigInt3(0x554199c47d08ffb10d4b8, 0x2ff0384422a3f45ed1229a, 0x483ada7726a3c4655da4f),
        );
        
  let msg_hash=BigInt3(0xbabaa1eaa1eaa1eaacaca, 0xcacaa1eaa1eaa1eaacaca, 0xcacaa1eaa1eaa1eaacaca);
  //let r:EcPoint=ec_mul( generator, nonce1);
  let r:EcPoint=EcPoint(
            BigInt3(0xe28d959f2815b16f81798, 0xa573a1c2c1c0a6ff36cb7, 0x79be667ef9dcbbac55a06),
            BigInt3(0x554199c47d08ffb10d4b8, 0x2ff0384422a3f45ed1229a, 0x483ada7726a3c4655da4f),
        );
  let parity=0;
    // this is not a valid signature, the comparizon just check the iso-behavior of non optimized and optimized versions
    
      let parity=0;
  let (r:EcPoint)=ec_double(generator);
  
  let (s:EcPoint)=ec_double(r);
    
  
   // this is not a valid signature, the comparizon just check the iso-behavior of non optimized and optimized versions
  
  let pub_opti:EcPoint= recover_public_key_opti(msg_hash=msg_hash, r=r.x, s=s.x, v=parity);
 
    
    return ();
}


//////////// MAIN
func main{ range_check_ptr}() {
    alloc_locals;
    let (__fp__, _) = get_fp_and_pc();
    
    
     %{ print("\n ECDSA test optimized implementation over sec256k1") %}//result of signature
    
    
    test_verify_ecdsa();
   
    
    return(); 
}     
