##*************************************************************************************/
##/* Copyright (C) 2022 - Renaud Dubois - This file is part of cy_lib project	 */
##/* License: This software is licensed under a dual BSD and GPL v2 license. 	 */
##/* See LICENSE file at the root folder of the project.				 */
##/* FILE: test_musig2.sage							             	  */
##/* 											  */
##/* 											  */
##/* DESCRIPTION: 2 round_multisignature Musig2 signatures 				  */
##/* This is a high level simulation for validation purpose				  */
##/* This file emulates a n-users aggregation and signatures, n being an input of sage */

##/* https:##eprint.iacr.org/2020/1261.pdf             				  */
##/* note that some constant aggregating values could be precomputed			  */
##**************************************************************************************/


load('musig2.sage');


print("\n\n********************************************************* \n*******************SAGEMATH:Simulation of a full Sign/Verif of Musig2:\n");
print("Simulation for a set of users of size:", nb_users);

print("\n*******************Generating Message of size",size_message,":\n");
Fq=GF(Stark_order);
message=[1..size_message];
for i in [1..size_message]:
	message[i-1]=int(Fq.random_element());
print(message);


print("\n*******************Generating Public Keys:\n");
L=[];
for i in [1..nb_users]:
	P=Musig2_KeyGen(Curve, curve_Generator, Stark_order)[1];#Concatenation of public keys
	print("*Public key user",i,":\n",P);
	L=L+[int(P[0]),int(P[1])];	

print("\n ***Serialized public keys L:\n",L);


print("\n ***Computing Aggregating coeffs ai:\n",L);	
for i in [0..nb_users-1]:	
	ai=H_agg(L, i, L[2*i], L[2*i+1]);	
	print("a[",i,"]=\n",ai);


	
print("\n*******************Aggregating Public Keys:\n");
KeyAgg=Musig2_KeyAggCoeff(Curve, curve_Generator, L, nb_users);
print("Aggregated Key:", KeyAgg);

print("\n*******************Signature Round1:\n");
infty_point=0*curve_Generator;

Aggregated_Ri=[1..nb_users];
nonces_i=[1..nb_users];	##of course nonces are kept secret by users(simulation convenience)

for i in [0..nb_users-1]:
	Aggregated_Ri[i]=infty_point;
	
for i in [0..nb_users-1]:
	X_pub=Curve(L[2*i], L[2*i+1]);
	[nonces, Ri]=Musig2_Sign_Round1(Stark_order, nb_users,X_pub);	#compute i-th contribution
	for j in [0..nb_users-1]:				#sum the contribution to previous ones
		Aggregated_Ri[j]+=Ri[j];

print("Aggregated Signature=", Aggregated_Ri);	
	
print("\n*******************Signature Round2:\n");
	
for i in [0..nb_users-1]:
	vec_nonces=nonces[i];
	H_non(KeyAgg, nb_users, Aggregated_Ri, message, size_message);

print("\n*******************Verification :\n");

