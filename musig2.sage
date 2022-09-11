##*************************************************************************************/
##/* Copyright (C) 2022 - Renaud Dubois - This file is part of cy_lib project	 */
##/* License: This software is licensed under a dual BSD and GPL v2 license. 	 */
##/* See LICENSE file at the root folder of the project.				 */
##/* FILE: musig2.sage							         */
##/* 											 */
##/* 											 */
##/* DESCRIPTION: 2 round_multisignature Musig2 signatures verification smart contract*/
##/source code 		 */
##/* https:##eprint.iacr.org/2020/1261.pdf             				 */
##/* note that some constant aggregating values could be precomputed			 */
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
	privatekey=Fq.random_element();
	publickey=curve_generator*privatekey;
	
	return [int(privatekey), publickey]
	
### H_aggregate = pedersen_hash_state(L||X)
def H_agg(Coefficients, n_users, X):
	Input=Coefficients+X;#concatenate L with X
	Hagg=pedersen_hash(Input, n_users+1);
	return Hagg;	


###Computation of ai=H(L, X_i)
def Musig2_KeyAggCoeff(curve_generator, publickeys, n_users, index):
	sum=0*curve_generator;				# initiate sum at infty_point
	for i in [1..n_users]:
		ai=H_agg(publickeys, n_users, publickeys[index]);#
		sum=sum+ai*publickeys[i];
	return 0;


### Round1 from single signer view
def Musig2_Sign_Round1(curve_order, n_users,X_pub):
	Fq=GF(curve_order);	
	Rijs_Round1=[1..n_users];
	
	for i in [1..n_users]:
		Rijs_Round1[i]=Fq.random_element;
	
	return 0;	
	
def Musig2_Sign_Round2_all( n_users,
		ai, privatekey_xi,
		vec_sigagg, vec_nonces,
		message,  message_feltlength,
		 R, s_i):
		 
	return 0;
	
	
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

#Produce the test vectors using Stark Curve as defined at https://docs.starkware.co/starkex/stark-curve.html
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


#verify compliance
def Musig_Verif_Core(Curve, curve_Generator,R,s,X, c):
	Gpows=s*curve_Generator;
	Xpowc=c*X;
	
	return (Gpows==R+Xpowc);
	
#### MAIN

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






