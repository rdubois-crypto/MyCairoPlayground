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

from ECDAA.ecdaa import *

 
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
    print("test_sha256:",test_sha512());
    print("test_sha512:",test_sha512());
    
    print("---- Test SetUp:");        
    print("test_CheckSetUp:",test_CheckSetup());
    print("---- Test Join:");        
    print("test_Proof_of_possesion:",test_Proof_of_possesion());
    print("test_CheckCredentials:",test_CheckCredentials());
    print("test_SigVerif:",test_SigVerif());



