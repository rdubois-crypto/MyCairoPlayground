##*************************************************************************************/
##/* Copyright (C) 2022 - Renaud Dubois - This file is part of cairo_musig2 project	 */
##/* License: This software is licensed under a dual BSD and GPL v2 license. 	 */
##/* See LICENSE file at the root folder of the project.				 */
##/* FILE: musig2.sage							             	  */
##/* 											  */
##/* 											  */
##/* DESCRIPTION: ECDAA algorithm*/
##/* This is a high level simulation for validation purpose				  */
##/* 
##https://fidoalliance.org/specs/fido-v2.0-id-20180227/fido-ecdaa-algorithm-v2.0-id-20180227.html#ecdaa-join-algorithm           				  */
##/* note that some constant aggregating values could be precomputed			  */
##**************************************************************************************/
from sage.crypto.util import bin_to_ascii

from hashlib import sha256

bls12_order=0x73eda753299d7d483339d80809a1d80553bda402fffe5bfeffffffff00000001;
bls12_p=0x1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaaab
bls12_b=4;
bls12_a=0;

bls12_Gx=0x17F1D3A73197D7942695638C4FA9AC0FC3688C4F9774B905A14E3A3F171BAC586C55E83FF97A1AEFFB3AF00ADB22C6BB;
bls12_Gy= 0x08B3F481E3AAA0F1A09E30ED741D8AE4FCF5E095D5D00AF600DB18CB2C04B3EDD03CC744A2888AE40CAA232946C5E7E1;

def Init_Curve(curve_characteristic,curve_a, curve_b,Gx, Gy, curve_Order):    
	Fp=GF(curve_characteristic); 				#Initialize Prime field of Point
	Fq=GF(curve_Order);					#Initialize Prime field of scalars
	Curve=EllipticCurve(Fp, [curve_a, curve_b]);		#Initialize Elliptic curve
	curve_Generator=Curve([Gx, Gy]);
	
	return [Curve,curve_Generator];
	
bls12_curve=	Init_Curve(bls12_p, bls12_a, bls12_b, bls12_Gx, bls12_Gy, bls12_order);

#bitsize of sha256 output
_SHA256_T1=256
OK=0
KO=1
##################################################################
################################# HASHING
##################################################################
#/*https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-hash-to-curve-13#name-bls12-381-g1 specifies use of SHA256 for H*/
##################################################################
##################################################################
#Convert an int to the input of sha function
def int_to_ascii_hash(int_a, length):
cpt=bin(i)[2:]).zfill(length);
bin_to_ascii(cpt).encode();

#returns a nonce in [0..Boud-1]
def get_nonce(Bound):
return random_int(0,Bound-1) 

#################################
#Hash_onG1
#################################
#Hash on curve
def Hash_onG1(String_m, q, b):
Fq=GF(q);
flag=false;

while (flag==false)
  i=0;
  cpt=(bin(i)[2:]).zfill(32);
  input=bin_to_ascii(cpt);  
  sha = hashlib.sha256()
  sha.update(input.encode())
  x=int('0x'+sha.hexdigest())
  z=Fq(x)^3+Fq(b);
  if(is_square(z)==true)
    flag=true
  else
    i=i+1
    if(i==252)
      return false
y=int(sqrt(z))
minus_y=q-y
Gy=min(y, minus_y)

return x, Gy

#################################
#Hash_pre
#################################
def HG1_pre(String_m, q, b):

Fq=GF(q);
flag=false;

while (flag==false)
  i=0;
  cpt=(bin(i)[2:]).zfill(32);
  input=bin_to_ascii(cpt);  
  sha = hashlib.sha256()
  sha.update(input.encode())
  x=int('0x'+sha.hexdigest())
  z=Fq(x)^3+Fq(b);
  if(is_square(z)==true)
    flag=true
  else
    i=i+1
    if(i==252)
      return false
y=int(sqrt(z))
minus_y=q-y
sc= bin_to_ascii(cpt)+String_m
yc=min(y, minus_y)

return sc, yc

#################################
#Deriv B
#################################
Deriv_B(sc,yc):

sha = hashlib.sha256()
sha.update(sc.encode())
x=int('0x'+sha.hexdigest())
## the following steps may be skip for low performances sdevices
z=Fq(x)^3+Fq(b);
if(is_square(z)==false)
 return 0,0 ## error, the value is not square
y=int(sqrt(z))
minus_y=q-y
if(yc!=y)
 return [0,0] ## error, the value is not expected value
B=curve([x,yc]);
return B

##################################################################
################################# SETUP
##################################################################
#Description: this function generates the secret and public parameters
# of the Issuer. All privacy security depends on the sk generated.

def SetUp(Curve,q, sk_x, sk_y):
#1. Randomly generated ECDAA Issuer private key isk=(x,y) with 
#[x,y=RAND(p)]
sk_x=



##################################################################
################################# JOIN
##################################################################
# The join algorithm is split in 4 steps:
# Step 2-3: Issuer generates credential B
# Step 4-8: Authenticator generates secret key and Proof of Knowledge
# Step 9-12: Issuers issues credential A,B,C,D
# Step 13+: ASM/Authenticator checks validity of received credentials




def Issuer_Join_Generate_B(Curve, q)):
#2.The ECDAA Issuer chooses a nonce BigInteger m=RAND(p)
nonce=get_nonce(q);
#3.The ECDAA Issuer computes the B value of the credential as B
sc, yc = HG1_pre(nonce, q, b);
B=Curve[0]([sc, yc]);





def Authenticator_Join_GenPriv( Curve, q, sc,yc):
#4. The authenticator chooses and stores the ECDAA private key BigInteger )sk=RAND(p)
sk=get_nonce(q)
#5.The authenticator re-computes B = (H(sc),yc)
B=Deriv_B(sc,yc);
#6.The authenticator computes its ECDAA public key ECPoint Q=B.​sk
​​Q=sk*B;
#7.The authenticator proves knowledge of sk as follows
#7.1.BigInteger r1​​ =RAND(p)
r1=get_nonce(q);
#7.2. ECPoint ​U1​ =B​r​1
​​U1=B*r1;
#7.3.​​BigInteger c​2​​ =H(U​1​​ ∣P​​​ ∣Q∣m)
sha = hashlib.sha256()
U1_x=int_to_ascii_hash(U1[0], 384);
sha.update(U1_x);
U1_y=int_to_ascii_hash(U1[0], 384);
sha.update(U1_y);
P1_x=int_to_ascii_hash(Curve[1][0], 384);
sha.update(p1_X);
P1_Y=int_to_ascii_hash(Curve[1][1], 384);
sha.update(P1_y);
Q_x=int_to_ascii_hash(Q[0], 384);
sha.update(Q_x);
Q_y=int_to_ascii_hash(Q[1], 384);
sha.update(Q_y);
sha.update(m);
c2=int('0x'+sha.hexdigest())
#7.4.BigInteger n=RAND(p)
n=get_nonce(q);
#7.5. BigInteger ​​ =H(n∣c​2​​ )
sha = hashlib.sha256()

nn=int_to_ascii_hash(n, 384);
cc2=int_to_ascii_hash(c2, _SHA256_T1);
sha.update(cc2);
c1=int('0x'+sha.hexdigest())
#7.6. BigInteger s​1​​ =r​1​​ +c​1​​ ⋅sk
s1=r1+c1*sk;
#8 Authenticator sends Q, c1,s1,n to Issuer
return[sk,Q, c1, s1, n]; 

#input (sk_x, sk_y): issuer secret key
def Issuer_Gen_Credentials(sk_y, m, B, Q, c1, s1, n)
#7.10 The ECDAA Issuer verifies that Q∈G​1 ​​  and verifies H(n∣H(B​s​1​​​ ⋅Q​−c​1​​ ∣P1​​ ∣Q∣m))​=​?​c​1
​​sha = hashlib.sha256()
U1=s1*B+c1*Q; ##=U1 = B​s​1​​​ ⋅Q​−c​1​​
sha = hashlib.sha256()
U1_x=int_to_ascii_hash(U1[0], 384);
sha.update(U1_x);
U1_y=int_to_ascii_hash(U1[0], 384);
sha.update(U1_y);
P1_Y=int_to_ascii_hash(Curve[1][1], 384);
sha.update(P1_y);
Q_x=int_to_ascii_hash(Q[0], 384);
sha.update(Q_x);
Q_y=int_to_ascii_hash(Q[1], 384);
sha.update(Q_y);
sha.update(m);
c2=int('0x'+sha.hexdigest())

nn=int_to_ascii_hash(n, 384);
cc2=int_to_ascii_hash(c2, _SHA256_T1);
c1_computed=int('0x'+sha.hexdigest())
if(c1_computed!=c1)
 return [KO,0,0,0,0];
#7.11 The ECDAA Issuer creates credential (A,B,C,D) as follows
#7.11.1 A=B^(1/y)
A=(Fq(sk_y)^-1)*B;
#7.11.2 B, la réponse B B=B
#7.11.3 C=(A*Q)^x;
C=sk_x*(A+Q);
return [A,C];

#
def Authenticator_CheckCredentials()
return [OK];


##################################################################
################################# SIGN
##################################################################




