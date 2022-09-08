//*************************************************************************************/
///* Copyright (C) 2	022 - Renaud Dubois - This file is part of cy_lib project	 */
///* License: This software is licensed under a dual BSD and GPL v2 license. 	 */
///* See LICENSE file at the root folder of the project.				 */
///* FILE: cy_hybridsig.h							         */
///* 											 */
///* 											 */
///* DESCRIPTION: 2 round_multisignature Musig2 signatures verification smart contract*/
///source code 		 */
///* https://eprint.iacr.org/2020/1261.pdf             				 */
///* note that some constant aggregating values could be precomputed			 */
//**************************************************************************************/
%builtins pedersen starkcurve

//%builtins pedersen secp256r1curve


from starkware.cairo.common.registers import get_ap
from starkware.cairo.common.registers import get_fp_and_pc

from starkware.cairo.common.bool import FALSE, TRUE

from starkware.cairo.common.cairo_builtins import EcOpBuiltin, HashBuiltin, SignatureBuiltin
from starkware.cairo.common.uint256 import Uint256

//Comparaison des codes en fonction des imports:
from starkware.cairo.common.ec import StarkCurve, ec_add, ec_mul, ec_sub, is_x_on_curve, recover_y
from starkware.cairo.common.ec_point import EcPoint

//from starkware.cairo.lang.vm.crypto import pedersen_hash

from starkware.cairo.common.hash_state import  hash_init,  hash_update, hash_finalize , HashState
from starkware.cairo.common.hash import hash2

//from starkware.cairo.common.signature import  hash_init,  hash_update, hash_finalize

//from starkware.cairo.common.cairo_secp.ec import EcPoint, ec_add, ec_mul, ec_negate //, get_point_from_x

//H_agg is chosen to be H(X1||X2||\ldots||X_i), where || denotes concatenation 

//cy_musig_Verification_All(cy_musig2_ctx_t *ctx, cy_ecpoint_t *Key_agg,
//		cy_ecpoint_t *R, cy_fp_t *s, cy_fp_t *c,
//		const uint8_t *message, const size_t message_t8,
//		boolean_t *flag_verif)



func Verif_Musig2{ hash_ptr: HashBuiltin*, ec_op_ptr: EcOpBuiltin*}(R:felt*, s:felt, X :felt*, nb_users: felt, message_ptr: felt*, data_length: felt) ->(flag_verif:felt){
	alloc_locals;
	
	//cy_ecpoint_t *G=cy_ec_get_generator(ctx->ctx_ec); /* get generating point of the curve , todo ec: coder un get_generator */
	let ecpoint_G:EcPoint=recover_y(StarkCurve.GEN_X);
	//CY_CHECK(cy_ec_scalarmult_fp(ctx->ctx_ec, G, s, &ec_temp1)); 	/*g^s*/
	let g_pow_s: EcPoint = ec_mul(s, ecpoint_G);
   	//CY_CHECK(cy_ec_export(&ctx->ctx_ec->ctx_fp_q, R,ctx->ctx_ec->t8_modular_p,buffer));// free in Cairo, just append x and y to hash context
	//ctx->H->Hash_Update((void *)ctx->H, buffer, ctx->ctx_ec->t8_modular_p);
	
	
	// compute c =·= Hsig(X, R, m ),
	let (Hsig: HashState*) = hash_init();
	let Hsig_X: HashState* =hash_update{hash_ptr=hash_ptr}(Hsig, X, 2);// append Aggregated key to hash
	let Hsig_XR: HashState* =hash_update{hash_ptr=hash_ptr}(Hsig_X, R, 2);// append R part of sig to hash
	let Hsig_XRm: HashState* =hash_update{hash_ptr=hash_ptr}(Hsig_XR, message_ptr, data_length);// append message to hash
	local d;
	%{ print("ap=", ap-1, "fp=",fp, "[ap-1]=",memory[ap-1], "[fp]=", memory[fp+1]) %}
	
	let c: felt= hash_finalize{hash_ptr=hash_ptr}(Hsig_XRm);// get hash result as felt
	d=c;
	let ecpoint_R:EcPoint=recover_y(R[0]); // recover R from R.x
	let ecpoint_X_pow_c:EcPoint=ec_mul(d, ecpoint_R);//compute X^c
	let ecpoint_RXc:EcPoint=ec_add(ecpoint_R, ecpoint_X_pow_c);//compute RX^c
		
	//* verifier accepts the signature if gs = RXec*/
	assert  ecpoint_RXc.x = g_pow_s.x;
	assert  ecpoint_RXc.y = g_pow_s.y;
	
 ret;	
}

	
//cy_ecpoint_t *G=cy_ec_get_generator(ctx->ctx_ec); /* get generating point of the curve , todo ec: coder un get_generator */
	

func main{pedersen_ptr: HashBuiltin*, starkcurve_ptr:EcOpBuiltin*}() {
    alloc_locals;
    
    // Get the value of the fp register.
    let (__fp__, _) = get_fp_and_pc();
    // Define a tuple.
    local R: (felt, felt) = (0x743829e0a179f8afe223fc8112dfc8d024ab6b235fd42283c4f5970259ce7b7, 0xe67a0a63cc493225e45b9178a3375596ea2a1d7012628a328dbc14c78cd1b7);
    [ap]=3,ap++;
    %{ print("ap=", ap-1, "fp=",fp, "[ap-1]=",memory[ap-1], "[fp]=", memory[fp+1]) %}
    [ap]=12,ap++;	
    local s:felt=5;    
    
    local  X: (felt, felt)=(0x66276b22edf076517b8fa9287280242555afda9ed00e78eedc9f99be8542aa3, 0x587d4c16426bc2b24c41319ca321cc7325359ad3c9bc465e30eb9078a5c002a );

    local message:(felt, felt, felt)=(0x616c6c657a206269656e20766f757320666169726520656e63756c65722021 ,0x70617220756e652062616e6465206465206cc3a967696f6e6e61697265732021,
       0x70617220756e652062616e6465206465206cc3a967696f6e6e61697265732021);
    local R: (felt, felt) = (0x743829e0a179f8afe223fc8112dfc8d024ab6b235fd42283c4f5970259ce7b7, 0xe67a0a63cc493225e45b9178a3375596ea2a1d7012628a328dbc14c78cd1b7);
    %{ print("Hello world! ap=", ap) %}
    //Verif_Musig2{ hash_ptr: HashBuiltin*, ec_op_ptr: EcOpBuiltin*}(ap, s, );
    
  
    let res:felt=Verif_Musig2{ hash_ptr=pedersen_ptr, ec_op_ptr=starkcurve_ptr}(&R, s, &X, 2, &message, 3);
    
    return();
}

//****************************** Produced test vector with sagemath (see musig2.sage)

//local  R: :(felt, felt)=( 0x743829e0a179f8afe223fc8112dfc8d024ab6b235fd42283c4f5970259ce7b7 , 0xe67a0a63cc493225e45b9178a3375596ea2a1d7012628a328dbc14c78cd1b7 );
//local  X: :(felt, felt)=( 0x66276b22edf076517b8fa9287280242555afda9ed00e78eedc9f99be8542aa3 , 0x587d4c16426bc2b24c41319ca321cc7325359ad3c9bc465e30eb9078a5c002a );
//local  g_pow_S: :(felt, felt)=( 0x788435d61046d3eec54d77d25bd194525f4fa26ebe6575536bc6f656656b74c , 0x13926386b9e5e908c359519eaa68c44a2430f4b4ca5d0dbdcb4231f031eb18b );
//local  User1: :(felt, felt)=( 0x216b4f076ff47e03a05032d1c6ee17933d8de8b2b4c43eb5ad5a7e1b25d3849 , 0x54b14e088019c05fd3c7ea1dadef2999de50590264fbf9ffe77692ceb241a8c );
//local  User2: :(felt, felt)=( 0x408f052dfe0289ab18a69ffdcb38a303fb0766979dca58262a9fabe4a0c7632 , 0x6342e6aba72fd3fef06d8274bdaf8cc86bc3eab59b3ae413f9e3cb086317923 );











