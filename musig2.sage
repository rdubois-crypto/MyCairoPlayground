##*************************************************************************************/
##/* Copyright (C) 2022 - Renaud Dubois - This file is part of cy_lib project	 */
##/* License: This software is licensed under a dual BSD and GPL v2 license. 	 */
##/* See LICENSE file at the root folder of the project.				 */
##/* FILE: musig2.sage							             	  */
##/* 											  */
##/* 											  */
##/* DESCRIPTION: 2 round_multisignature Musig2 signatures verification sage simulation*/
##/* This is a high level simulation for validation purpose				  */
##/* https:##eprint.iacr.org/2020/1261.pdf             				  */
##/* note that some constant aggregating values could be precomputed			  */
##**************************************************************************************/
## Stark curve parameters extracted from
## https:github.com/starkware-libs/cairo-lang/blob/master/src/starkware/cairo/common/ec.cairo

load('pedersen_hashpoint.sage');

def StringToHex(String):
	return String.encode('utf-8').hex();

def CairoDeclare_from_Point(comment, Point):
	print("local ", comment,":(felt, felt)=(", hex(Point[0]), ",",hex(Point[1]),");");
	return 0;

def CairoDeclare_from_sacalar(comment, Scalar):
	print("local ", comment,":felt=", hex(Scalar), ";");
	return 0;


### Key generation
def Musig2_KeyGen(Curve, curve_generator, curve_order):
	Fq=GF(curve_order);
	privatekey=int(Fq.random_element());
	publickey=curve_generator*privatekey;
	
	return [int(privatekey), publickey];
	#return 0;
	
### H_aggregate = pedersen_hash_state(L||X)
# expected public keys format is (int, int)
def H_agg(Coefficients, n_users, Xx, Xy):
	#concatenate L with X, each public key is represented as a couple of felt
	Input=Coefficients+[Xx, Xy];			#Append X to L
	Hagg=pedersen_hash(Input, 2*(n_users+1));	#H(L||X)
	return Hagg;

### H_Nonce = pedersen_hash_state(Xtilde||Ris||m)
#Xtilde is the public key aggregation computed at first round
def H_non(Xtilde, nb_users, Ris, m, size_message):
	#concatenate L with X, each public key is represented as a couple of felt
	Input=[int(Xtilde[0]), int(Xtilde[1])];			#Append X, Ris and m
	
	for j in [0..nb_users-1]:
		Input=Input+[int(Ris[i][0]), int(Ris[i][1])];
	for cpt_i in [0..size_message-1]:
		Input=Input+[message[cpt_i]];
	Hnon=pedersen_hash(Input, 2*(nb_users+1)+size_message);	#H(L||X)
	return Hnon;

def H_sig(Xtilde, R, m, size_message):
	Input=[int(Xtilde[0]), int(Xtilde[1])];
	Input+=[int(R[0]), int(R[1])];
	for cpt_i in [0..size_message-1]:
		Input=Input+[m[cpt_i]];
	Hsig=pedersen_hash(Input, len(Input));
	return Hsig;

###Computation of sum Pki^ai, ai=H(L, X_i)
# expected public keys format is (int, int)
def Musig2_KeyAgg(Curve, curve_generator, L, n_users):
	sum=0*curve_generator;				# initiate sum at infty_point
	for i in [0..n_users-1]:
		ai=H_agg(L, i, L[2*i], L[2*i+1]);#i-th ai
		sum=sum+ai*Curve(L[2*i], L[2*i+1]);	#Xi^ai, where Xi is the ith public key
	return sum;


### Round1 from single signer view
# expected public key as a point
def Musig2_Sign_Round1(curve_order, n_users,curve_Generator):
	Fq=GF(curve_order);	
	Rijs_Round1=[1..n_users];
	nonces=[1..n_users];
	
	for j in [0..n_users-1]:
		nonces[j]=int(Fq.random_element());
		Rijs_Round1[j]=nonces[j]*curve_Generator;     #Rij=rij*G;
	
	return [nonces, Rijs_Round1];	
	
	
### Round2 from single signer view
def Musig2_Sign_Round2_all( 
		Curve, curve_generator,curve_order, nb_users, KeyAgg,#common parameters
		ai, privatekey_xi,					#user's data
		vec_sigagg, vec_nonces,				#First round output
		message,  message_feltlength):			#input message
	Fp=GF(curve_order);
	b=H_non(KeyAgg, nb_users, vec_sigagg, message,  message_feltlength);
	R=0*curve_generator;
	for j in [0..nb_users-1]:
		R=R+b^(j)*vec_sigagg[j] ;
	c=H_sig(KeyAgg, R, message, message_feltlength);
	s=Fp(c*ai*privatekey_xi);
	for j in [0..nb_users-1]:
		s=s+vec_nonces[j]*b^j
	return [R,s, c];
	

#verify compliance
def Musig_Verif_Core(Curve, curve_Generator,R,s,X, c):
	Gpows=s*curve_Generator;
	Xpowc=c*X;
	
	return (Gpows==R+Xpowc);
	
#stark curve parameters from https://docs.starkware.co/starkex/stark-curve.html

curve_characteristic=2^251+17*2^192+1     
is_prime(curve_characteristic); #should return true
beta = 0x6f21413efbe40de150e596d72f7a8c5609ad26c15c915c1f4cdfcb99cee9e89
Stark_order=0x800000000000010ffffffffffffffffb781126dcae7b2321e66a241adc64d2f
GEN_X = 0x1ef15c18599971b7beced415a40f0c7deacfd9b0d1819e03d723d8bc943cfca;
GEN_Y = 0x5668060aa49730b7be4801df46ec62de53ecd11abe43a32873000c36e8dc1f;	
[Curve,curve_Generator, P0, P1, P2, P3, Shift]=Init_Stark(curve_characteristic,1, beta,GEN_X, GEN_Y,Stark_order) ;






