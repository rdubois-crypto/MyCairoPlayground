##*************************************************************************************/
##/* Copyright (C) 2022 - Renaud Dubois - This file is part of cairo_musig2 project	 */
##/* License: This software is licensed under a dual BSD and GPL v2 license. 	 */
##/* See LICENSE file at the root folder of the project.				 */
##/* FILE: test_ecdaa.py							             	  */
##/* 											  */
##/* 											  */
##/* DESCRIPTION: ECDAA algorithm testing file*/
##/* This is a high level simulation for validation purpose				  */
##/* 
##https://fidoalliance.org/specs/fido-v2.0-id-20180227/fido-ecdaa-algorithm-v2.0-id-20180227.html#ecdaa-join-algorithm           				  */
##/* note that some constant aggregating values could be precomputed			  */
##**************************************************************************************/
from sage.all_cmdline import *   # import sage library

from sage.rings.integer_ring import ZZ
from sage.rings.rational_field import QQ
from sage.misc.functional import cyclotomic_polynomial
from sage.rings.finite_rings.finite_field_constructor import FiniteField, GF
from sage.schemes.elliptic_curves.constructor import EllipticCurve
# this is much much faster with this statement:
# proof.arithmetic(False)
from sage.structure.proof.all import arithmetic
from sage.crypto.util import bin_to_ascii
from hashlib import *

#this is the ethereum version of pre-sha3 standard:
from sha3 import keccak_256    
from ECDAA.ecdaa import *



def test_ethereum_hash():
 
 #first attempt: use ascci encoding
 res=keccak_256('Hello world!'.encode()).hexdigest()
 print("1. keccak('Hello world!)'",  hex(int('0x'+res,16)));
 #second attempt, convert to numbers, lsb:
 h_in=8031924123371070792+2^64*560229490;
 ctx= keccak_256(); 
 ctx=H_Zp_update(ctx, h_in, 12);	
 print("2. keccak('Hello world!)", ctx.hexdigest());
 
 #third attempt, convert to numbers, msb:
 h_in=8031924123371070792*2^64+560229490;
 ctx= keccak_256(); 
 ctx=H_Zp_update(ctx, h_in, 12);	
 print("3. keccak('Hello world!)", ctx.hexdigest());
 
 
 digeste=keccak_256('testing'.encode()).hexdigest()
 #vector extracted from https://ethereum.stackexchange.com/questions/550/which-cryptographic-hash-function-does-ethereum-use
 if(digeste!='5f16f4c7f149ac4f9510d9cf8cf384038ad348b3bcdc01915f95de12df9d1b02'):
    return false;
 
 ctx= keccak_256(); 
 ctx=H_Zp_update(ctx, 0x616263, 3);	
 #vector extracted from https://gist.github.com/miguelmota/97b3a46291bc41a9b3054e75609d1dbf
 if(ctx.hexdigest()=='4e03657aea45a94fc7d47ba826c8d667c0d1e6e33a64a036ec44f58fa12d6c45'):
  return true;
 else:
  return false;
 
 
 
#vector extracted from https://www.di-mgt.com.au/sha_testvectors.html
def test_sha512():
    ctx= sha512(); 
    ctx=H_Zp_update(ctx, 0x616263, 3);	
    if(ctx.hexdigest()=='ddaf35a193617abacc417349ae20413112e6fa4e89a97ea20a9eeee64b55d39a2192992a274fc1a836ba3c23a3feebbd454d4423643ce80e2a9ac94fa54ca49f'):
      return true;
    else:
      return false;
      
def test_sha256():   
 ctx= sha256(); 
 ctx=H_Zp_update(ctx, 0x616263, 3);	
 if(ctx.hexdigest()=='ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad'):
      return true;
 else:
      return false;


def test_ethereum_keccak():   
 ctx= sha256(); 
 ctx=H_Zp_update(ctx, 0x616263, 3);	
 if(ctx.hexdigest()=='ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad'):
      return true;
 else:
      return false;
      
#mathematical validity checking (formulae consistency)
def test_CheckSetup():
  isk_x,isk_y, r_x, r_y=SetUp_Priv();
  X,Y,i_c,s_x, s_y = SetUp_DerivPub(isk_x,isk_y, r_x, r_y);
  return CheckSetup(X,Y,i_c,s_x, s_y);

#mathematical validity checking (formulae consistency)
def test_Proof_of_possesion():
  isk_x,isk_y, r_x, r_y=SetUp_Priv();
  X,Y,i_c,s_x, s_y = SetUp_DerivPub(isk_x,isk_y, r_x, r_y);
  sc, yc=Issuer_Join_Generate_B();
  m=sc//2^32;
  
  B=Deriv_B(sc,yc);
  _,Q, i_c1, s1, n= Authenticator_Join_GenPriv(sc,yc);
  res=Check_Proof(Q, B, m, i_c1, s1, n);
  
  return res;

def test_CheckCredentials():
  isk_x,isk_y, r_x, r_y=SetUp_Priv();
  X,Y,i_c,s_x, s_y = SetUp_DerivPub(isk_x,isk_y, r_x, r_y);
  sc, yc=Issuer_Join_Generate_B();
  m=sc//2^32;
  B=Deriv_B(sc,yc);
  _,Q, i_c1, s1, n= Authenticator_Join_GenPriv(sc,yc);
  A,B,C,D = Issuer_Gen_Credentials(isk_x, isk_y, m, B, Q, i_c1, s1, n)
  res=Check_Credentials(A,B,C,D, X, Y);
 
  return res;

#Check consistency of signing/verifying process
def test_SigVerif():
  isk_x,isk_y, r_x, r_y=SetUp_Priv();
  X,Y,i_c,s_x, s_y = SetUp_DerivPub(isk_x,isk_y, r_x, r_y);
  sc, yc=Issuer_Join_Generate_B();
  m=sc//2^32;
  B=Deriv_B(sc,yc);
  sk,Q, i_c1, s1, n= Authenticator_Join_GenPriv(sc,yc);
  A,B,C,D = Issuer_Gen_Credentials(isk_x, isk_y, m, B, Q, i_c1, s1, n)
  Data=0x616263;
  
  h_KRD=get_ZPnonce()%(2^256);
  
  i_c,s,R,S,T,W,n=ECDAA_Sign(sk, A, B, C, D, Data, 3, h_KRD, 32);
  res=true;
  res=ECDAA_Verify(X,Y, Data, 3, h_KRD, 32,  i_c,s,R,S,T,W,n)

  return res;

if __name__ == "__main__":
    arithmetic(False)
   
    print("\n\n######## Test ECDAA with curve:", curve_name);
   
    print("---- Test Encodings:");
   
    print("test_ethereum_hash:",test_ethereum_hash());
    print("test_sha256:",test_sha512());
    print("test_sha512:",test_sha512());
    
    print("---- Test SetUp:");        
    print("test_CheckSetUp:",test_CheckSetup());
    print("---- Test Join:");        
    print("test_Proof_of_possesion:",test_Proof_of_possesion());
    print("test_CheckCredentials:",test_CheckCredentials());
    print("test_SigVerif:",test_SigVerif());




