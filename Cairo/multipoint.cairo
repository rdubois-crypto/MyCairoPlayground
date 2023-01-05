//*************************************************************************************/
///* Copyright (C) 2022 - Renaud Dubois - This file is part of Cairo_musig2 project	 */
///* License: This software is licensed under a dual BSD and GPL v2 license. 	 */
///* See LICENSE file at the root folder of the project.				 */
///* FILE: multipoint.cairo							         */
///* 											 */
///* 											 */
///* DESCRIPTION: optimization of dual base multiplication*/
/// testing 		 */
///* [MUSIG2] https://eprint.iacr.org/2020/1261.pdf             			 */
///* note that some constant aggregating values could be precomputed			 */
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

func ec_mulmuladd_inner{range_check_ptr}(R: EcPoint, G: EcPoint, Q: EcPoint, H: EcPoint,scalar_u: felt, scalar_v: felt, m: felt) -> (res: EcPoint){
   

    alloc_locals;
    let (double_point: EcPoint) = ec_double(R);
    let mm1:felt=m-1;
    local dibit;
    
   
    //this means if m=-1, beware if felt definition changes
    if(m == 3618502788666131213697322783095070105623107215331596699973092056135872020480){
    %{ print("\n end of recursion" ) %}
     return(res=R);
    }
     %{ print("\n inner mulmuladd with m=", ids.m) %}
 
    //extract MSB values of both exponents
     %{ ids.dibit = ((ids.scalar_u >>ids.m)&1) +2*((ids.scalar_v >>ids.m)&1) %}
     %{ print("\n ui=",ids.scalar_u >>ids.m, "\n vi=", ids.scalar_v >>ids.m) %}
    
     
     %{ print("\n dibit=", ids.dibit) %}

    	
    //set R:=R+R
    if(dibit==0){
    	let (res:EcPoint)= ec_mulmuladd_inner(double_point,G,Q,H,scalar_u,scalar_v,mm1 );
    	return(res=res);
    }
    //if ui=1 and vi=0, set R:=R+G
    if(dibit==1){
    	let (res10:EcPoint)=ec_add(double_point,G);
    	let (res:EcPoint)= ec_mulmuladd_inner(res10,G,Q,H,scalar_u,scalar_v,mm1 );
    	return(res=res);
    }
    //(else) if ui=0 and vi=1, set R:=R+Q
    if(dibit==2){
    	let (res01:EcPoint)=ec_add(double_point,Q);
    	let (res:EcPoint)= ec_mulmuladd_inner(res01,G,Q,H,scalar_u,scalar_v,mm1 );
    	return(res=res);
        }
    //(else) if ui=1 and vi=1, set R:=R+Q
    if(dibit==3){
   	let (res11:EcPoint)=ec_add(double_point,H);
    	let (res:EcPoint)= ec_mulmuladd_inner(res11,G,Q,H,scalar_u,scalar_v,mm1 );
    	
    	return(res=res);
    }
    

     //you shall never end up here
     return(res=R);

}


func is_BigInt3_le{range_check_ptr}(scalar_a: BigInt3, scalar_b: BigInt3) -> felt {
	
	if(is_nn_le{range_check_ptr=range_check_ptr}(a=scalar_a.d0, b=scalar_b.d0)==0){
		return 0;
	}
	if(is_nn_le{range_check_ptr=range_check_ptr}(a=scalar_a.d1, b=scalar_b.d1)==0){
		return 0;
	}
	if(is_nn_le{range_check_ptr=range_check_ptr}(a=scalar_a.d2, b=scalar_b.d2)==1){
		return 1;
	}
	return 0;
}


//https://crypto.stackexchange.com/questions/99975/strauss-shamir-trick-on-ec-multiplication-by-scalar
func ec_mulmuladd{range_check_ptr}(G: EcPoint, Q: EcPoint, scalar_u: felt, scalar_v: felt) -> (res: EcPoint){

    alloc_locals;
    local m;
    //Precompute H=P+Q
    let H:EcPoint=ec_add{range_check_ptr=range_check_ptr}(G,Q);
    //recover MSB bit index
    %{ ids.m=max(ids.scalar_u.bit_length(), ids.scalar_v.bit_length())-1 %}    
    %{ print("\n length=", ids.m) %}

    //initialize R with infinity point
    let R = EcPoint(BigInt3(0, 0, 0), BigInt3(0, 0, 0));
    let (resu:EcPoint)=ec_mulmuladd_inner(R,G,Q,H, scalar_u, scalar_v, m);
   
     return (res=resu);
	
}


func ec_mulmuladd_bg3{range_check_ptr}(G: EcPoint, Q: EcPoint, scalar_u: BigInt3, scalar_v: BigInt3) -> (res: EcPoint){

    alloc_locals;
    local len_hi; 
    local len_med; 
    local len_low;
    
    //Precompute H=P+Q
    let H:EcPoint=ec_add{range_check_ptr=range_check_ptr}(G,Q);
   
    //initialize R with infinity point
    let R = EcPoint(BigInt3(0, 0, 0), BigInt3(0, 0, 0));
    
     //recover MSB bit index of high part
    %{ ids.len_hi=max(ids.scalar_u.d2.bit_length(), ids.scalar_v.d2.bit_length())-1 %}    
    %{ print("\n length=", ids.len_hi) %}
    let (lowR:EcPoint)=ec_mulmuladd_inner(R,G,Q,H, scalar_u.d2, scalar_v.d2, len_hi);

    //recover MSB bit index of med part
    %{ ids.len_med=max(ids.scalar_u.d1.bit_length(), ids.scalar_v.d1.bit_length())-1 %}    
    %{ print("\n length=", ids.len_med) %}
    let (medR:EcPoint)=ec_mulmuladd_inner(lowR,G,Q,H, scalar_u.d1, scalar_v.d1, len_med);
 
    //recover MSB bit index of low part
    %{ ids.len_low=max(ids.scalar_u.d0.bit_length(), ids.scalar_v.d0.bit_length())-1 %}    
    %{ print("\n length=", ids.len_low) %}

    let (hiR:EcPoint)=ec_mulmuladd_inner(medR,G,Q,H, scalar_u.d0, scalar_v.d0, len_low);

    return (res=hiR);
}

func test_ecmulmuladd()->(res:felt){


}

//////////// MAIN
func main{range_check_ptr }() {
    alloc_locals;
    let (__fp__, _) = get_fp_and_pc();
     %{ print("\n*******************CAIRO:Shamir's trick testing") %}//result of signature

     %{ print("\n******************* Unitary Test 1: test mulmuladd inner on single precision scalar") %}
     let G=EcPoint(
            BigInt3(0xe28d959f2815b16f81798, 0xa573a1c2c1c0a6ff36cb7, 0x79be667ef9dcbbac55a06),
            BigInt3(0x554199c47d08ffb10d4b8, 0x2ff0384422a3f45ed1229a, 0x483ada7726a3c4655da4f),
        );
     
    
     let Q:EcPoint=ec_double(G);

     let scal_3=3;
     let scal_31=31;
     let m1=-1;	
    
     //compute 3G+31Q= 65G
     let computed:EcPoint=ec_mulmuladd( G, Q, scal_3, scal_31);
     let compX=computed.x.d0;
     %{ print("\n Computed x=", ids.compX) %}
     
     let soixantecinq=BigInt3(0x41, 0x0, 0x0);
     
     let expected:EcPoint=ec_mul(G, soixantecinq);
     let expX=expected.x.d0;
    
     %{  print("\n Expected x=", ids.expX) %}
     %{ print("\n******************* Unitary Test 2: test mulmuladd inner on BigInt3") %}
    
     return();
     
}     
     

