##*************************************************************************************/
##/* Copyright (C) 2022 - Renaud Dubois - This file is part of cy_lib project	 */
##/* License: This software is licensed under a dual BSD and GPL v2 license. 	 */
##/* See LICENSE file at the root folder of the project.				 */
##/* FILE: test_musig2.sage							             	  */
##/* 											  */
##/* 											  */
##/* DESCRIPTION: 2 round_multisignature Musig2 signatures verification sage simulation*/
##/* This is a high level simulation for validation purpose				  */
##/* https:##eprint.iacr.org/2020/1261.pdf             				  */
##/* note that some constant aggregating values could be precomputed			  */
##**************************************************************************************/

load('musig2.sage');


#### Product_Test_Vector_Verif_MusigCore

# this function produces a test vector in Cairo syntax for the Musig 2 core functions i.e veryfing g^s=XR^c
# the values are dummy values only aimed at validating the Musig2_Verif_core function
# the hash value is considered as Random Oracle output instead of true hash

def Product_Test_Vector_Verif_MusigCore(curve_characteristic, curve_a, curve_b, Gx, Gy, curve_Order, index):
	Fp=GF(curve_characteristic); 				#Initialize Prime field of Point
	Fq=GF(curve_Order);					#Initialize Prime field of scalars
	Curve=EllipticCurve(Fp, [curve_a, curve_b]);		#Initialize Elliptic curve
	c=lift(Fq.random_element());					#Consider hash as random oracle
	s=lift(Fq.random_element());	
	curve_Generator=Curve([Gx, Gy]); 				
	Gpows=s*curve_Generator;
	
	X=Curve.random_element();
	Xpowc=c*X;
		
	R=Gpows-Xpowc;						#Producing X compliant with validity formulae 
	
	print("local message:(felt, felt,felt)=(", lift(Fq.random_element()), ",", lift(Fq.random_element()), ",",lift(Fq.random_element()),");");
	
        #print("local message:(felt, felt, felt)=(",s ,",", s , "," , s ,");" );
        #print("local message:(felt, felt, felt)=" );
        
	CairoDeclare_from_Point("X_"+index,X);
	CairoDeclare_from_Point("R_"+index,R);
	CairoDeclare_from_sacalar("s_"+index,s);
	CairoDeclare_from_sacalar("c_"+index,c);
	
	#verify compliance
	print (Gpows==R+Xpowc);
	
	return [R,s,X,c];
#### Gen_Testvector_Stark_Musig2

#Produce the test vectors for verification using Stark Curve as defined at https://docs.starkware.co/starkex/stark-curve.html
#order extracted elsewhere, can be checked by order*Generator=infty point

def Gen_Testvector_Stark_Musig2(nb_vectors):
	p = p=2^251+17*2^192+1     
	is_prime(p); #should return true
	beta = 0x6f21413efbe40de150e596d72f7a8c5609ad26c15c915c1f4cdfcb99cee9e89
	Stark_order=0x800000000000010ffffffffffffffffb781126dcae7b2321e66a241adc64d2f
	GEN_X = 0x1ef15c18599971b7beced415a40f0c7deacfd9b0d1819e03d723d8bc943cfca;
	GEN_Y = 0x5668060aa49730b7be4801df46ec62de53ecd11abe43a32873000c36e8dc1f;
	for index in [1..nb_vectors]:	
		[R,s,X,c]=Product_Test_Vector_Verif_MusigCore(p,1, beta, GEN_X, GEN_Y, Stark_order, str(index) );
	return [R,s,X,c];


	
########### MAIN
message=[0x616c6c657a206269656e20766f757320666169726520656e63756c65722021 ,0x617220756e643262616e6465206465206cc3a967696f6e6e61697265732013];

#computing test vector for testing Cairo implementation of pedersen hash:


print("\n\n********************************************************* \n*******************SAGEMATH:Pedersen hash and chain hash test_vector generation\n");
pedersen_hash_res=pedersen(message[0], message[1]); #1507473129754433389303589648688410091651017934427319142210890580198758665242
print("Result of hash       :",pedersen_hash_res);

print("Result of hash chain : h(h(h(0, x1), x2), 2)=",pedersen_hash(message,2));

print("\n\n********************************************************* \n*******************SAGEMATH:Hsig hash for Musig2 test_vector\n");



#stark curve parameters from https://docs.starkware.co/starkex/stark-curve.html

curve_characteristic=2^251+17*2^192+1     
is_prime(curve_characteristic); #should return true
beta = 0x6f21413efbe40de150e596d72f7a8c5609ad26c15c915c1f4cdfcb99cee9e89
Stark_order=0x800000000000010ffffffffffffffffb781126dcae7b2321e66a241adc64d2f
GEN_X = 0x1ef15c18599971b7beced415a40f0c7deacfd9b0d1819e03d723d8bc943cfca;
GEN_Y = 0x5668060aa49730b7be4801df46ec62de53ecd11abe43a32873000c36e8dc1f;	
message=[0x616c6c657a206269656e20766f757320666169726520656e63756c65722021 ,0x617220756e643262616e6465206465206cc3a967696f6e6e61697265732013];
[Curve,curve_Generator, P0, P1, P2, P3, Shift]=Init_Stark(curve_characteristic,1, beta,GEN_X, GEN_Y,Stark_order) ;

#computing test vector for testing Cairo implementation of pedersen hash:


print("\n\n********************************************************* \n*******************SAGEMATH:Pedersen hash and chain hash test_vector generation:\n");
pedersen_hash_res=pedersen(message[0], message[1]); #1507473129754433389303589648688410091651017934427319142210890580198758665242
print("Result of hash       :",pedersen_hash_res);

print("Result of hash chain : h(h(h(0, x1), x2), 2)=",pedersen_hash(message,2));

print("\n\n********************************************************* \n*******************SAGEMATH:Musig2 test_vector generation\n");

[Curve,curve_Generator, P0, P1, P2, P3, Shift]=Init_Stark(curve_characteristic,1, beta,GEN_X, GEN_Y,Stark_order);
[R,s,X,c]=Gen_Testvector_Stark_Musig2(1);
flag=Musig_Verif_Core(Curve, curve_Generator,R,s,X, c);
print("Verification:", flag);
if (flag==True):
	print("\nTest Vector Generation Success");
else:
	print("\nTest Vector GenerationFailure");	

print("\n*********************************************************\n");




