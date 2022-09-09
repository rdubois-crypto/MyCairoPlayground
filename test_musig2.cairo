//*************************************************************************************/
///* Copyright (C) 2022 - Renaud Dubois - This file is part of Cairo_musig2 project	 */
///* License: This software is licensed under a dual BSD and GPL v2 license. 	 */
///* See LICENSE file at the root folder of the project.				 */
///* FILE: test_musig2.cairo							         */
///* 											 */
///* 											 */
///* DESCRIPTION: 2 round_multisignature Musig2 signatures verification smart contract*/
/// testing 		 */
///* [MUSIG2] https://eprint.iacr.org/2020/1261.pdf             			 */
///* note that some constant aggregating values could be precomputed			 */
//**************************************************************************************/

from starkware.cairo.common.registers import get_ap
from starkware.cairo.common.registers import get_fp_and_pc
from starkware.cairo.common.bool import FALSE, TRUE
from starkware.cairo.common.cairo_builtins import EcOpBuiltin, HashBuiltin, SignatureBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.ec import StarkCurve, ec_add, ec_mul, ec_sub, is_x_on_curve, recover_y
from starkware.cairo.common.ec_point import EcPoint
from starkware.cairo.common.hash_state import  hash_init,  hash_update, hash_finalize , HashState
from starkware.cairo.common.hash import hash2
from musig2 import HSig, Verif_Musig2_core, Verif_Musig2_all


//vector test generated with musig2.sage, 
//hashing is dummy (not yet implemented in external sage) thus test fails (to be completed)
func vec_test_all{pedersen_ptr: HashBuiltin*, ec_op_ptr:EcOpBuiltin*}() {
    alloc_locals;
    
    // Get the value of the fp register.
 let (__fp__, _) = get_fp_and_pc();
   
 local  X :(felt, felt)=( 0x76fc80c2ffe50db728abe66c5863042e6eca6fc0eacc906ead1f18d12645ce8 , 0x1c2007ab8300692fb3042a8b9ebb1ffbe532d3d7e60684b58df2fc2165b52b1 );
 local  R :(felt, felt)=( 0x561d1ada3798e36dc6734c203eee3a5995d97a6db6dad83c89ad24c754499aa , 0x2615a0c492a14a00405a548f1125054704bac52e471b8726c7f19b54cfe41ff );
 local  s :felt= 0x398bc516a144ac8867348cd7d5517d3dc6a4cd53fd4359c4aad6f47382635ea ;
 local  c :felt= 0x6a18d4ab6a7aa9ba01cabf4d8580f7b6318a7523d49a080df1801d171d66419 ;


 local message:(felt, felt, felt)=(0x616c6c657a206269656e20766f757320666169726520656e63756c65722021 ,0x70617220756e652062616e6465206465206cc3a967696f6e6e61697265732021,
       0x70617220756e652062616e6465206465206cc3a967696f6e6e61697265732021);
 let hachi:felt=hash2{ hash_ptr=pedersen_ptr}(message[0], message[1]);
   %{ print("Musig2 hash result=", memory[ap-1]) %}//result of hash h(m(0),m(1))
        
 local R: (felt, felt) = (0x743829e0a179f8afe223fc8112dfc8d024ab6b235fd42283c4f5970259ce7b7, 0xe67a0a63cc493225e45b9178a3375596ea2a1d7012628a328dbc14c78cd1b7);
    
  
 let res:felt=Verif_Musig2_all{ hash_ptr=pedersen_ptr, ec_op_ptr2=ec_op_ptr}(&R, s, &X, &message, 3);
      %{ print("Musig2 verification result=", memory[ap-1]) %}//result of signature
  
    return();
}


//unitary vector test generated with musig2.sage
func vec_test_core{pedersen_ptr: HashBuiltin*, ec_op_ptr:EcOpBuiltin*}()->(flag_verif:felt){
 alloc_locals;
 let (__fp__, _) = get_fp_and_pc();
 
 local  X :(felt, felt)=( 0x15eefe05d45ff1614b19dc23ed36a48061d1529b9c5d291306e1c901c429541 , 0x3ca8fb58147f51041c68ca7a166b5371b5fbe4cbb53c6c57a09639f7c70a0d2 );
 local  R :(felt, felt)=( 0x17bfebc3b1e070a5a3deb3a686c8cce15abfccc1716b1cc2816ebb9da617c91 , 0x6fbbedd0eaa875ff5804d8b6a5f2c3dd2a7366ecb387193e61ea5dea4a56e7e );
 local  s :felt= 0x22b8bbb477ecac34814ebb48fec72f655bee51e176e51efa8508a3796ad52c9 ;
 local  c :felt= 0x11c5b5d5b8150b8cf28f57bc295a0962bd54f1ee08f4bcc441b2c47d009ab6a ;

 let d:felt=Verif_Musig2_core{ hash_ptr=pedersen_ptr, ec_op_ptr2=ec_op_ptr}(&R, s, &X, c);


 return (flag_verif=d);  
}

//////////// MAIN
func main{pedersen_ptr: HashBuiltin*, ec_op_ptr:EcOpBuiltin*}() {
    alloc_locals;
    let (__fp__, _) = get_fp_and_pc();
    
    let flag=vec_test_core{ pedersen_ptr=pedersen_ptr, ec_op_ptr=ec_op_ptr}();
    
     %{ print("Musig2 verification result=", memory[ap-1]) %}//result of signature
     %{ if(memory[ap-1]==1):print("Success!") %}//result of signature
     
     let flag2=vec_test_all{ pedersen_ptr=pedersen_ptr, ec_op_ptr=ec_op_ptr}();
   
     
     return();
}



