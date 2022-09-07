//*************************************************************************************/
///* Copyright (C) 2022 - Renaud Dubois - This file is part of cy_lib project	 */
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



func Verif_Musig2{ pedersen_ptr: HashBuiltin*, ec_op_ptr: EcOpBuiltin*}(R:felt*, s:felt, X :felt*, nb_users: felt, message_ptr: felt*, data_length: felt) ->(flag_verif:felt){
	alloc_locals;
	
	//cy_ecpoint_t *G=cy_ec_get_generator(ctx->ctx_ec); /* get generating point of the curve , todo ec: coder un get_generator */
	let ecpoint_G:EcPoint=recover_y(StarkCurve.GEN_X);
	//CY_CHECK(cy_ec_scalarmult_fp(ctx->ctx_ec, G, s, &ec_temp1)); 	/*g^s*/
	let g_pow_s: EcPoint = ec_mul(s, ecpoint_G);
   	//CY_CHECK(cy_ec_export(&ctx->ctx_ec->ctx_fp_q, R,ctx->ctx_ec->t8_modular_p,buffer));// free in Cairo, just append x and y to hash context
	//ctx->H->Hash_Update((void *)ctx->H, buffer, ctx->ctx_ec->t8_modular_p);
	
	
	// compute c =·= Hsig(X, R, m ),
	let (Hsig: HashState*) = hash_init();
	let Hsig_X: HashState* =hash_update{hash_ptr=pedersen_ptr}(Hsig, X, 2);// append Aggregated key to hash
	let Hsig_XR: HashState* =hash_update{hash_ptr=pedersen_ptr}(Hsig_X, R, 2);// append R part of sig to hash
	let Hsig_XRm: HashState* =hash_update{hash_ptr=pedersen_ptr}(Hsig_XR, message_ptr, data_length);// append message to hash
	local d;
	
	let c: felt= hash_finalize{hash_ptr=pedersen_ptr}(Hsig_XRm);// get hash result as felt
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
	

func main() {
	// Store the signature first part : point r=7G
    [ap] = 0x743829e0a179f8afe223fc8112dfc8d024ab6b235fd42283c4f5970259ce7b7, ap++;
    [ap] = 0xe67a0a63cc493225e45b9178a3375596ea2a1d7012628a328dbc14c78cd1b7, ap++;
    	//store the signature second part: felt s=input 
    [ap] = [ap - 2] + [ap - 1], ap++;
    [ap] = [ap - 2] * [ap - 1], ap++;
    [ap] = [ap - 1] / [ap - 2], ap++;
    
    
    //Verif_Musig2{ pedersen_ptr: HashBuiltin*, ec_op_ptr: EcOpBuiltin*}(ap, s, );
    
    ret ;
    let ec_point:EcPoint=recover_y([ap]);
//     let ec_point:EcPoint=get_point_from_x([ap]);
     
        
    let double_point:EcPoint=	  ec_add(ec_point, ec_point);
    
    
    return();
}

//****************************** Producing test vector with sagemath
//** sagemath is a usefull algebraic toolbox, you may install it or run directly the following lines without the "// comments" in https://sagecell.sagemath.org/
// Stark curve parameters extracted from https://github.com/starkware-libs/cairo-lang/blob/master/src/starkware/cairo/common/ec.cairo
// SIMULATION SAGE (install sagemath then type follow instructions in console
//p = p=2^251+17*2^192+1     
// is_prime(p); #should return true
//beta = 0x6f21413efbe40de150e596d72f7a8c5609ad26c15c915c1f4cdfcb99cee9e89
//Fp=GF(p)
//Stark_curve=EllipticCurve(Fp, [1, beta])
//Stark_order=0x800000000000010ffffffffffffffffb781126dcae7b2321e66a241adc64d2f
//GEN_X = 0x1ef15c18599971b7beced415a40f0c7deacfd9b0d1819e03d723d8bc943cfca;
//GEN_Y = 0x5668060aa49730b7be4801df46ec62de53ecd11abe43a32873000c36e8dc1f;
//Generator=Stark_curve([GEN_X, GEN_Y]); 
//Stark_order*Generator  #this should be equal to (0,1,0) (infty point)
//R=7*Generator;// (0x743829e0a179f8afe223fc8112dfc8d024ab6b235fd42283c4f5970259ce7b7, 0xe67a0a63cc493225e45b9178a3375596ea2a1d7012628a328dbc14c78cd1b7)
//X=12*Generator;//
//S=5*Generator;//













