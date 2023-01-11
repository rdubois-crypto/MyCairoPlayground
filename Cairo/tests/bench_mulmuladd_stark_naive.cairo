//*************************************************************************************/
///* Copyright (C) 2022 - Renaud Dubois - This file is part of Cairo_musig2 project	 */
///* License: This software is licensed under a dual BSD and GPL v2 license. 	 */
///* See LICENSE file at the root folder of the project.				 */
///* FILE: test_mulmuladd_stark.cairo						         */
///* 											 */
///* 											 */
///* DESCRIPTION:  testing file for ec_mulmuladd over stark curve			 */
//**************************************************************************************/

//Shamir's trick:https://crypto.stackexchange.com/questions/99975/strauss-shamir-trick-on-ec-multiplication-by-scalar,
//Windowing method : https://en.wikipedia.org/wiki/Exponentiation_by_squaring, section 'sliding window'
//The implementation use a 2 bits window with trick, leading to a 16 points elliptic point precomputation

%builtins range_check ec_op

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
from starkware.cairo.common.ec_point import EcPoint
from starkware.cairo.common.ec import ec_add, ec_mul, ec_double, StarkCurve

from ec_mulmuladd import ec_mulmuladd_W, ec_mulmuladd, ec_mulmuladd_naive




func test_naive{range_check_ptr, ec_op_ptr: EcOpBuiltin* } (){
 alloc_locals;
 %{ print("\n******************* Unitary Test windowed sharmir's trick mulmuladd :") %}
 
 //generating point
 let G=EcPoint(x=StarkCurve.GEN_X, y=StarkCurve.GEN_Y);
 
 
 let Q:EcPoint=ec_double(G);
 
 let scalar_u=-1;
 
 //v=N+1, (N+1)Q=2G    
 //let scalar_u=BigInt3(0x8a03bbfd25e8cd0364141 , 0x3ffffffffffaeabb739abd, 0xfffffffffffffffffffff);
 let scalar_v=-2;

 let res_naive:EcPoint=ec_mulmuladd_naive(G,Q,scalar_u, scalar_v); 
 
 return();
 
}
 
//////////// MAIN
func main{range_check_ptr, ec_op_ptr: EcOpBuiltin* }() {
    alloc_locals;
    let (__fp__, _) = get_fp_and_pc();
    
    
     %{ print("\n*******************CAIRO:Bench naive uG+vQ") %}
    
    
    test_naive{range_check_ptr=range_check_ptr, ec_op_ptr=ec_op_ptr}();
    
    return(); 
}     
 
 
 
 
