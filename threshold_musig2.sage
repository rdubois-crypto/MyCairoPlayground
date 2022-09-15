##*************************************************************************************/
##/* Copyright (C) 2022 - Renaud Dubois - This file is part of CairoMusig2 project	 */
##/* License: This software is licensed under a dual BSD and GPL v2 license. 	 */
##/* See LICENSE file at the root folder of the project.				 */
##/* FILE: threshold_musig2.sage							  */
##/* 											  */
##/* 											  */
##/* DESCRIPTION: Adaptation of Musig2 in a Threshold version			  */

##/* This is a high level simulation for validation purpose				  */
##/* https:##eprint.iacr.org/2020/1261.pdf             				  */
##/* note that some constant aggregating values could be precomputed			  */
##**************************************************************************************/
## Stark curve parameters extracted from
## https:github.com/starkware-libs/cairo-lang/blob/master/src/starkware/cairo/common/ec.cairo

load('pedersen_hashpoint.sage');
load('musig2.sage');
load ('threshold.sage');


##***********************Aggregator functions****************************************/

# expected public keys format is (int, int) of size k+1 (k degree of polynomial, value of threshold
#to be decided: do we use directly the lagrange coefficient or a hashed one ?
#for now we keep the H_agg
def Th_Musig2_KeyAgg(Curve, curve_generator, L, k, curve_order):
	sum=0*curve_generator;				# initiate sum at infty_point
	for i in [0..k-1]:
		ai=H_agg(L, nb_users, L[2*i], L[2*i+1], curve_order);	#i-th ai
		sum=sum+Lagrange_j(L,i,k)*(ai*Curve(L[2*i], L[2*i+1]));	#Xi^ai, where Xi is the ith public key
	return sum;


##***********************Single user functions***************************************/

#input is n_users vector of size v
def Th_Musig2_Sig1Agg(vec_Ri, X, k):
	infty_point=0*curve_Generator;
	Aggregated_Ri=[0.._MU-1];
	
	for j in [0.._MU-1]:
		Aggregated_Ri[j]=infty_point;
	
	for i in [0..k-1]:
		for j in [0.._MU-1]:#sum the contribution to previous ones
			Aggregated_Ri[j]+=vec_Ri[i][j];	
	return Aggregated_Ri;



### Round2 from single signer view
def Musig2_Sign_Round2_all( 
		Curve, curve_generator,curve_order, k, KeyAgg,#common parameters
		ai, privatekey_xi,					#user's data
		vec_R, vec_nonces,					#First round output
		message,  message_feltlength):			#input message
	Fq=GF(curve_order);
	b=H_non(KeyAgg, nb_users, vec_R, message,  message_feltlength, curve_order);
	
	R=0*curve_generator;
	for j in [0.._MU-1]:
		R=R+(b^(j)*vec_R[j]) ;
	c=(H_sig(KeyAgg, R, message, message_feltlength, curve_order));
	s=Lagrange_j(L,i,k)*(c*ai*privatekey_xi);
	for j in [0.._MU-1]:
		s=s+(vec_nonces[j])*Fq(b)^j;
	return [R,s, c];




