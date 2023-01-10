//*************************************************************************************/
///* Copyright (C) 2022 - Renaud Dubois - This file is part of cairo_musig2 project	 */
///* License: This software is licensed under a dual BSD and GPL v2 license. 	 */
///* See LICENSE file at the root folder of the project.				 */
///* FILE: musig2.cairo							         */
///* 											 */
///* 											 */
///* DESCRIPTION: 2 round_multisignature Musig2 signatures verification smart contract*/
///source code 		 */
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


// /** constant for domain separation of musig2
const _SEPARATION_SIG=1;


// This file implements a x-only version, using point compression. All serialized points 
// (KeyAgg, and R part of signature) are assumed to have even y-coordinate
// 

// /** \brief Hsig, hashing function, with x-only convention

// * Implicit:
// * \param[in]  R part of the signatures as a couple (x,y) of felt (type: felt*)
// * \param[in]  s part of the signatures  (type: felt*)
// * Inputs:
// * \param[in]  R part of the signatures as a felt (compressed point)
// * \param[in]  s part of the signatures  (type: felt*)
// * \param[in]  X Aggregated key (x,y) as a couple of felt (type: felt*)
// * \param[in]  message_ptr, pointer to the message of  data_length felt (type: felt*)
// * \param[in]  data_length is the length in felt (not byte!) of the message (type: felt*)
// * Output:
// * \param[out] Hsign the value of the hash (type: felt)
// * The Hsig function of [MUSIG2], instanciated with pedersen hash. All data are represented as felt, the 
// * payload input is X|| R|| m, where || notes concatenation
// */
func HSig_xonly{ hash_ptr: HashBuiltin*, ec_op_ptr2: EcOpBuiltin*}(R:felt, s:felt, X :felt,  message_ptr: felt*, data_length: felt)->(Hsign:felt){
	// compute c =·= Hsig(X, R, m ),
	alloc_locals;
	let (__fp__, _) = get_fp_and_pc();
	
	let (Hsig: HashState*) = hash_init();
	local const_separation=_SEPARATION_SIG;
	
	let Hsig_0: HashState* =hash_update{hash_ptr=hash_ptr}(Hsig, &const_separation, 1);
	
	let Hsig_X: HashState* =hash_update{hash_ptr=hash_ptr}(Hsig_0, &X, 1);// append Aggregated key to hash
		
	let Hsig_XR: HashState* =hash_update{hash_ptr=hash_ptr}(Hsig_X, &R, 1);// append R part of sig to hash
	let Hsig_XRm: HashState* =hash_update{hash_ptr=hash_ptr}(Hsig_XR, message_ptr, data_length);// append message to hash
	
	let d: felt= hash_finalize{hash_ptr=hash_ptr}(Hsig_XRm);// get hash result as felt
 	return (Hsign=d);
}



// /** \brief The core verification algorithm, computed in one shot (hash internally)

// * Implicit:

// * Inputs:
// * \param[in]  R part of the signatures as a single felt (compressed point of even y)
// * \param[in]  s part of the signatures  (type: felt*)
// * \param[in]  KeyAgg Aggregated key as single felt (type: felt) (compressed point of even y)


// * \param[in]  message_ptr, pointer to the message of  data_length felt (type: felt*)
// * \param[in]  data_length is the length in felt (not byte!) of the message (type: felt*)
// * Output:
// * \param[out] flag_verif the value of the verification (TRUE/FALSE), encoded as felt
// * The verification function of [MUSIG2], instanciated with pedersen hash over the Starkcurve. 
// */
//
func Verif_Musig2_all_xonly{ hash_ptr: HashBuiltin*, ec_op_ptr2: EcOpBuiltin*}(R:felt, s:felt, KeyAgg :felt,  message_ptr: felt*, data_length: felt) ->(flag_verif:felt){
	alloc_locals;
	
	//cy_ecpoint_t *G=cy_ec_get_generator(ctx->ctx_ec); /* get generating point of the curve , todo ec: coder un get_generator */
	let ecpoint_G:EcPoint=EcPoint(x=StarkCurve.GEN_X, y=StarkCurve.GEN_Y);
	//CY_CHECK(cy_ec_scalarmult_fp(ctx->ctx_ec, G, s, &ec_temp1)); 	/*g^s*/
	let g_pow_s: EcPoint = ec_mul{ec_op_ptr=ec_op_ptr2}(s, ecpoint_G);
   	let ecpoint_X: EcPoint = recover_y(KeyAgg);
   	
	// compute c =·= Hsig(X, R, m ),	
	let c: felt= HSig_xonly(R,s,KeyAgg, message_ptr, data_length);// get hash result as felt
	
 	%{ print("Musig2  Internal hash =", memory[ap-1]) %}//result of signature
	local d=c;
	
	
	let ecpoint_R: EcPoint = recover_y(R);
	let ecpoint_X_pow_c:EcPoint=ec_mul{ec_op_ptr=ec_op_ptr2}(d, ecpoint_X);//compute X^c
	let ecpoint_RXc:EcPoint=ec_add(ecpoint_R, ecpoint_X_pow_c);//compute RX^c
		
	//* verifier accepts the signature if gs = RXec*/
	if(  ecpoint_RXc.x == g_pow_s.x){
	   return (flag_verif=TRUE);
	}
	// testing R-Xc for point compression, note that it restores some malleability and should
	let ecpoint_RmXc:EcPoint=ec_sub( ecpoint_X_pow_c, ecpoint_R);//compute RX^c
	if(  ecpoint_RmXc.x == g_pow_s.x){
	   return (flag_verif=TRUE);
	}
		
	   return (flag_verif=FALSE);
	   
}		



// /** \brief The core verification algorithm, computed in one shot (hash internally)

// * Implicit:

// * Inputs:
// * \param[in]  R part of the signatures as a single felt (compressed point of even y)
// * \param[in]  s part of the signatures  (type: felt*)
// * \param[in]  KeyAgg Aggregated key as single felt (type: felt) (compressed point of even y)


// * \param[in]  single felt message of type (type: felt)
// * \param[in]  data_length is the length in felt (not byte!) of the message (type: felt*)
// * Output:
// * \param[out] flag_verif the value of the verification (TRUE/FALSE), encoded as felt
// * The verification function of [MUSIG2], instanciated with pedersen hash over the Starkcurve. 
// */
//
func Verif_Musig2_short_xonly{ hash_ptr: HashBuiltin*, ec_op_ptr2: EcOpBuiltin*}(R:felt, s:felt, KeyAgg :felt,  message: felt, data_length: felt) ->(flag_verif:felt){
	alloc_locals;
	let (__fp__, _) = get_fp_and_pc();
	
	//cy_ecpoint_t *G=cy_ec_get_generator(ctx->ctx_ec); /* get generating point of the curve , todo ec: coder un get_generator */
	let ecpoint_G:EcPoint=EcPoint(x=StarkCurve.GEN_X, y=StarkCurve.GEN_Y);
	//CY_CHECK(cy_ec_scalarmult_fp(ctx->ctx_ec, G, s, &ec_temp1)); 	/*g^s*/
	let g_pow_s: EcPoint = ec_mul{ec_op_ptr=ec_op_ptr2}(s, ecpoint_G);
   	let ecpoint_X: EcPoint = recover_y(KeyAgg);
   	
	// compute c =·= Hsig(X, R, m ),	
	let c: felt= HSig_xonly(R,s,KeyAgg, &message, data_length);// get hash result as felt
	
 	%{ print("Musig2  Internal hash =", memory[ap-1]) %}//result of signature
	local d=c;
	
	
	let ecpoint_R: EcPoint = recover_y(R);
	let ecpoint_X_pow_c:EcPoint=ec_mul{ec_op_ptr=ec_op_ptr2}(d, ecpoint_X);//compute X^c
	let ecpoint_RXc:EcPoint=ec_add(ecpoint_R, ecpoint_X_pow_c);//compute RX^c
		
	//* verifier accepts the signature if gs = RXec*/
	if(  ecpoint_RXc.x == g_pow_s.x){
	   return (flag_verif=TRUE);
	}
	// testing R-Xc for point compression, note that it restores some malleability and should
	let ecpoint_RmXc:EcPoint=ec_sub( ecpoint_X_pow_c, ecpoint_R);//compute RX^c
	if(  ecpoint_RmXc.x == g_pow_s.x){
	   return (flag_verif=TRUE);
	}
		
	   return (flag_verif=FALSE);
	   
}		



