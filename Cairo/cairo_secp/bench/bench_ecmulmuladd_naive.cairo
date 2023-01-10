//*************************************************************************************/
///* Copyright (C) 2022 - Renaud Dubois - This file is part of Cairo_musig2 project	 */
///* License: This software is licensed under a dual BSD and GPL v2 license. 	 */
///* See LICENSE file at the root folder of the project.				 */
///* FILE: bench_scalarmul.cairo						         */
///* 											 */
///* 											 */
///* DESCRIPTION: bench of non-optimized dual basis multiplication*/
///* the algorithm combines the so called Shamir's trick with Windowing method	  */
//**************************************************************************************/


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
from starkware.cairo.common.cairo_secp.constants import BETA, N0, N1, N2
from starkware.cairo.common.cairo_secp.ec import EcPoint, ec_add, ec_mul, ec_negate, ec_double

from ec_mulmuladd import  ec_mulmuladd_naive


func bench_naive{range_check_ptr }(G:EcPoint, scalar_u: BigInt3, scalar_v: BigInt3)->(res:EcPoint){
    alloc_locals;
//* parameters for 256k1:
//https://en.bitcoin.it/wiki/Secp256k1
//order=115792089237316195423570985008687907852837564279074904382605163141518161494337
//low=hex(n&(2^86-1)), med=hex((n>>86)&(2^86-1)), hi=hex((n>>(2*86))&(2^84-1))
//0x8a03bbfd25e8cd0364141 , 0x3ffffffffffaeabb739abd, 0xfffffffffffffffffffff
//int(low,16)+(int(med,16)<<86)+(int(hi,16)<<2*86)  
    
    
   
 let Q:EcPoint=ec_double(G);


 //(qG)+(q-2)*G shall be equal to P using Fermat theorem
 let res:EcPoint=ec_mulmuladd_naive(G,Q,scalar_u, scalar_v); 
  
 if(res.x.d0!=G.x.d0){
   %{  print("\n error in bench !!") %}
     
  return(res=res);   
 } 
    
    
 return(res=Q);
}

//////////// MAIN
func main{range_check_ptr }() {
 %{ print("\n***************** Benching ecmulmuladd: naive") %}

 let G=EcPoint(
            BigInt3(0xe28d959f2815b16f81798, 0xa573a1c2c1c0a6ff36cb7, 0x79be667ef9dcbbac55a06),
            BigInt3(0x554199c47d08ffb10d4b8, 0x2ff0384422a3f45ed1229a, 0x483ada7726a3c4655da4f),
   );


  //u=N-1, vP=-P
  let scalar_u=BigInt3(0x8a03bbfd25e8cd0364140 , 0x3ffffffffffaeabb739abd, 0xfffffffffffffffffffff);
 
  //v=N+1, (N+1)Q=2G    
  //let scalar_u=BigInt3(0x8a03bbfd25e8cd0364141 , 0x3ffffffffffaeabb739abd, 0xfffffffffffffffffffff);
  let scalar_v=BigInt3(0x8a03bbfd25e8cd0364142 , 0x3ffffffffffaeabb739abd, 0xfffffffffffffffffffff);

  let R1:EcPoint=bench_naive(G, scalar_u, scalar_v);
  let R2:EcPoint=bench_naive(R1, scalar_u, scalar_v);
  let R3:EcPoint=bench_naive(R2, scalar_u, scalar_v);

  %{  print("\n bench terminate without error") %}
  
  return();
  
}









