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
from starkware.cairo.common.hash_state import  hash_init,  hash_update, hash_finalize , HashState, hash_felts
from starkware.cairo.common.hash import hash2
from musig2 import HSig, Verif_Musig2_core, Verif_Musig2_all

from musig2_xonly import HSig_xonly, Verif_Musig2_all_xonly, Verif_Musig2_short_xonly


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


//unitary vector test generated with test_musig2_example.sage
func vec_test_Musig2_core{pedersen_ptr: HashBuiltin*, ec_op_ptr:EcOpBuiltin*}()->(flag_verif:felt){
 alloc_locals;
 let (__fp__, _) = get_fp_and_pc();
 
 local  X :(felt, felt)=( 2691991349280861182525365095645492501799041544647681493267316816575070318625 , 964920030696087922447606943895072427921210732852145972476320138235037406950 );
 local  R :(felt, felt)=( 1154543393826499327384925594716943854756278752519748612882695342387905476485 , 3198087695386183225673073483228017283558755677681197577257486316144848035013 );
 local  s :felt= 1082631760734147029776619237951131338486686452862679559365522792258354836851 ;
 local  c :felt= 1270063422062718958814700756961132487764709718831040164632853007755546300240 ;

 let d:felt=Verif_Musig2_core{ hash_ptr=pedersen_ptr, ec_op_ptr2=ec_op_ptr}(&R, s, &X, c);


 return (flag_verif=d);  
}

//Input to Hsig= [1, 2691991349280861182525365095645492501799041544647681493267316816575070318625, 964920030696087922447606943895072427921210732852145972476320138235037406950, 1154543393826499327384925594716943854756278752519748612882695342387905476485, 3198087695386183225673073483228017283558755677681197577257486316144848035013, 1312926488893051640838690020429502555760453277462134805675804440214385331882]

//unitary vector test generated with test_musig2_example.sage
func vec_test_Hsig_xonly{pedersen_ptr: HashBuiltin*, ec_op_ptr:EcOpBuiltin*}()->(test_res:felt){
 alloc_locals;
 let (__fp__, _) = get_fp_and_pc();
 local d;
 	
 local  message:felt=	1312926488893051640838690020429502555760453277462134805675804440214385331882;
 local  X :felt= 3067118560697589524435384931491320927549001107642126949141615071965375409500 ;
 local  R :felt= 805608576337223666507608055448388656839464615861511853976287840398054978764  ;
 local  s :felt= 2794984427638061003832909310448843078134666016451605026434589603196253996757 ;
 local  expected :felt= 1405388610216890693451590793908065992860380736413274668546085119243050006294 ;//expected Hsig

 let hashed:felt=HSig_xonly{hash_ptr=pedersen_ptr, ec_op_ptr2=ec_op_ptr}(R,s,X, &message,1);
  %{ print("Musig2 Hsig =", memory[ap-1]) %}//result of hsig(R,s,X,m)
  
 if(hashed==expected){
  d=1;//warning:OK is one
 }else{
  d=0;
 }
 
 return (test_res=d);  
}


//unitary vector test generated with test_musig2_example.sage
func vec_test_Hsig{pedersen_ptr: HashBuiltin*, ec_op_ptr:EcOpBuiltin*}()->(test_res:felt){
 alloc_locals;
 let (__fp__, _) = get_fp_and_pc();
 local d;
 	
 local  message:felt=	1312926488893051640838690020429502555760453277462134805675804440214385331882;
 local  X :(felt, felt)=( 2691991349280861182525365095645492501799041544647681493267316816575070318625 , 964920030696087922447606943895072427921210732852145972476320138235037406950 );
 local  R :(felt, felt)=( 1154543393826499327384925594716943854756278752519748612882695342387905476485 , 3198087695386183225673073483228017283558755677681197577257486316144848035013 );
 local  s :felt= 1082631760734147029776619237951131338486686452862679559365522792258354836851 ;
 local  expected :felt= 1270063422062718958814700756961132487764709718831040164632853007755546300240 ;//expected Hsig

 let hashed:felt=HSig{hash_ptr=pedersen_ptr, ec_op_ptr2=ec_op_ptr}(&R,s,&X, &message,1);
  %{ print("Musig2 Hsig =", memory[ap-1]) %}//result of hsig(R,s,X,m)
  
 if(hashed==expected){
  d=1;//warning:OK is one
 }else{
  d=0;
 }
 
 return (test_res=d);  
}

// vec_test_pedersen_hash
//unitary vector test generated with pedersen_hashpoint.sage
func vec_test_pedersen_hash{pedersen_ptr: HashBuiltin*, ec_op_ptr:EcOpBuiltin*}()->(test_res:felt) {
 alloc_locals;
 let (__fp__, _) = get_fp_and_pc();
 local expected :felt=1507473129754433389303589648688410091651017934427319142210890580198758665242;
 local d;
 
 let message:(felt, felt)=(0x616c6c657a206269656e20766f757320666169726520656e63756c65722021 ,0x617220756e643262616e6465206465206cc3a967696f6e6e61697265732013);

 let hachi:felt=hash2{ hash_ptr=pedersen_ptr}(message[0], message[1]);
   %{ print("Musig2 hash result=", memory[ap-1]) %}//result of hash h(m(0),m(1))
 if(hachi==expected){
  d=1;//warning:OK is one
 }else{
  d=0;
 }
 
 return (test_res=d); //there is no OK const	
}


// vec_test_pedersen_hash
//unitary vector test generated with pedersen_hashpoint.sage
//h(h(h(0, x1), x2), 2)
func vec_test_pedersen_hash_felts{pedersen_ptr: HashBuiltin*, ec_op_ptr:EcOpBuiltin*}()->(test_res:felt) {
 alloc_locals;
 let (__fp__, _) = get_fp_and_pc();
 local expected :felt=2782949571272047847418452244933652681923153427435107168660157281737758615001;//extracted from pedersen_hashpoint.sage result
 local d;
 
 local message:(felt, felt)=(0x616c6c657a206269656e20766f757320666169726520656e63756c65722021 ,0x617220756e643262616e6465206465206cc3a967696f6e6e61697265732013);

 let hachi:felt=hash_felts{ hash_ptr=pedersen_ptr}(&message[0],2);
   %{ print("hash_felts=", memory[ap-1]) %}//result of hash h(m(0),m(1))
 if(hachi==expected){
  d=1;//warning:OK is one
 }else{
  d=0;
 }
 
 return (test_res=d); //there is no OK const	
}



//vector test generated with test_musig2_example.sage, 
//hashing is dummy (not yet implemented in external sage) thus test fails (to be completed)
func vec_test_all{pedersen_ptr: HashBuiltin*, ec_op_ptr:EcOpBuiltin*}()->(flag_verif:felt) {
    alloc_locals;
    
    // Get the value of the fp register.	
 let (__fp__, _) = get_fp_and_pc();
   
  
 	
 local  message:felt=	1312926488893051640838690020429502555760453277462134805675804440214385331882;
 local  X :(felt, felt)=( 2691991349280861182525365095645492501799041544647681493267316816575070318625 , 964920030696087922447606943895072427921210732852145972476320138235037406950 );
 local  R :(felt, felt)=( 1154543393826499327384925594716943854756278752519748612882695342387905476485 , 3198087695386183225673073483228017283558755677681197577257486316144848035013 );
 local  s :felt= 1082631760734147029776619237951131338486686452862679559365522792258354836851 ;
   	  
 let res:felt=Verif_Musig2_all{ hash_ptr=pedersen_ptr, ec_op_ptr2=ec_op_ptr}(&R[0], s, &X, &message, 1);
 
 %{ print("Musig2  full verification result=", memory[ap-1]) %}//result of signature
  
 return (flag_verif=res);  
}

//vector test generated with test_musig2_example.sage, 
//hashing is dummy (not yet implemented in external sage) thus test fails (to be completed)
func vec_test_all_xonly{pedersen_ptr: HashBuiltin*, ec_op_ptr:EcOpBuiltin*}()->(flag_verif:felt) {
    alloc_locals;
    
    // Get the value of the fp register.	
 let (__fp__, _) = get_fp_and_pc();
   
  
 	
 local  message:felt=	1312926488893051640838690020429502555760453277462134805675804440214385331882;
 local  X :felt= 3067118560697589524435384931491320927549001107642126949141615071965375409500 ;
 local  R :felt= 805608576337223666507608055448388656839464615861511853976287840398054978764 ;
 local  s :felt= 2794984427638061003832909310448843078134666016451605026434589603196253996757 ;
   	  
 let res:felt=Verif_Musig2_all_xonly{ hash_ptr=pedersen_ptr, ec_op_ptr2=ec_op_ptr}(R, s, X, &message, 1);
 
 %{ print("Musig2  full verification result=", memory[ap-1]) %}//result of signature
  
 return (flag_verif=res);  
}

//////////// MAIN
func main{pedersen_ptr: HashBuiltin*, ec_op_ptr:EcOpBuiltin*}() {
    alloc_locals;
    let (__fp__, _) = get_fp_and_pc();
     %{ print("\n\n********************************************************* \n*******************CAIRO:Musig2 verification module testing") %}//result of signature

//    Testing Unitary hash
     %{ print("\n******************* Unitary Test 1") %}
     
     let flag2=vec_test_pedersen_hash{ pedersen_ptr=pedersen_ptr, ec_op_ptr=ec_op_ptr}();
     %{ print("hash2:", memory[ap-1],":") %}//result of signature
     %{ if(memory[ap-1]==1):print("Test OK") %}//result of hash comparizon to vector reference
     %{ if(memory[ap-1]!=1):print("Abortion") %}//result of signature
     %{ if(memory[ap-1]!=1):exit() %}//result of signature
     
//    Testing Chain hash     
     %{ print("\n******************* Unitary Test 2") %}
     let flag_test3=vec_test_pedersen_hash_felts{ pedersen_ptr=pedersen_ptr, ec_op_ptr=ec_op_ptr}();
     %{ print("Verif_hash_chain_core:", memory[ap-1],":") %}//result of hash chain

     %{ if(memory[ap-1]==1):print("Test OK") %}//result of hash
     %{ if(memory[ap-1]!=1):print("Abortion") %}//result of hash
     %{ if(memory[ap-1]!=1):exit() %}//result of signature
     
//    Testing Hsig     
     %{ print("\n******************* Unitary Test 3") %}
     let flag_test4=vec_test_Hsig{ pedersen_ptr=pedersen_ptr, ec_op_ptr=ec_op_ptr}();
     %{ print("Verif_hash_chain_core:", memory[ap-1],":") %}//result of hash chain
     %{ if(memory[ap-1]==1):print("Test OK") %}//result of hash
     %{ if(memory[ap-1]!=1):print("Abortion") %}//result of hash
   

//    Testing Hsig with x-only     
     %{ print("\n******************* Unitary Test 3'- xonly") %}
     let flag_test4=vec_test_Hsig_xonly{ pedersen_ptr=pedersen_ptr, ec_op_ptr=ec_op_ptr}();
     %{ print("Verif_hash_chain_core:", memory[ap-1],":") %}//result of hash chain
     %{ if(memory[ap-1]==1):print("Test OK") %}//result of hash
     %{ if(memory[ap-1]!=1):print("Abortion") %}//result of hash
     %{ if(memory[ap-1]!=1):exit() %}//result of signature
       	
     
//    Testing Verification Core
     %{ print("\n******************* Unitary Test 4") %}
     
     %{ print("Verif_Musig2_core:", memory[ap-1],":") %}//result of signature
     let flag=vec_test_core{ pedersen_ptr=pedersen_ptr, ec_op_ptr=ec_op_ptr}();
     %{ if(memory[ap-1]==1):print("Test OK") %}//result of signature
     %{ if(memory[ap-1]!=1):print("Abortion") %}//result of signature
     %{ if(memory[ap-1]!=1):exit() %}//result of signature
     
      %{ print("Verif_Musig2_core:", memory[ap-1],":") %}//result of signature
     let flag=vec_test_Musig2_core{ pedersen_ptr=pedersen_ptr, ec_op_ptr=ec_op_ptr}();
     %{ if(memory[ap-1]==1):print("Test OK") %}//result of signature
     %{ if(memory[ap-1]!=1):print("Abortion") %}//result of signature
     %{ if(memory[ap-1]!=1):exit() %}//result of signature
     
      
//    Testing Full Verification 
     %{ print("\n******************* Unitary Test 5: Full Verification") %}
     let flag=vec_test_all{ pedersen_ptr=pedersen_ptr, ec_op_ptr=ec_op_ptr}();
     %{ if(memory[ap-1]==1):print("Test OK") %}//result of signature
     %{ if(memory[ap-1]!=1):print("Abortion") %}//result of signature
     %{ if(memory[ap-1]!=1):exit() %}//result of signature
    
     
//    Testing Full Verification xonly
     %{ print("\n******************* Unitary Test 5': Full Verification xonly") %}
     let flag=vec_test_all_xonly{ pedersen_ptr=pedersen_ptr, ec_op_ptr=ec_op_ptr}();
     %{ if(memory[ap-1]==1):print("Test OK") %}//result of signature
     %{ if(memory[ap-1]!=1):print("Abortion") %}//result of signature
     %{ if(memory[ap-1]!=1):exit() %}//result of signature
     %{ print("\nAll test OK") %}//result of signature
  
   
     return();
}



