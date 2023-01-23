##*************************************************************************************/
##/* Copyright (C) 2022 - Renaud Dubois - This file is part of cairo_musig2 project	 */
##/* License: This software is licensed under a dual BSD and GPL v2 license. 	 */
##/* See LICENSE file at the root folder of the project.				 */
##/* FILE: altbn128.py							             	  */
##/* 											  */
##/* 											  */
##/* DESCRIPTION: altbn_128 Ethereum curve*/
##/* https://ethereum.github.io/yellowpaper/paper.pdf
##/* This is a high level simulation for validation purpose				  */
##/* 
#/* note that some constant aggregating values could be precomputed			  */
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
from external.Pairings.pairing_bn import final_exp_hard_bn
from external.Pairings.pairing import *
from external.Pairings.tests.test_pairing import *

#
u0=0x44e992b44a6909f1
t=6*(u0**2)+1

#preparse("QQx.<x> = QQ[]")
QQx = QQ['x']; (x,) = QQx._first_ngens(1)

p=  21888242871839275222246405745257275088696311157297823662689037894645226208583;
#curve order
r= 21888242871839275222246405745257275088548364400416034343698204186575808495617;

#(p^12-1)/r
fexp=(p^12-1)/r;


b=3;

#defining group G1    
Fp = GF(p, proof=False);
Fpz = Fp['z']; (z,) = Fpz._first_ngens(1)
E1= EllipticCurve([Fp(0), Fp(b)]);

Gen1=E1([1,2]);



#defining group G2    
Fp2 = Fp.extension(z**2 + 1, names=('i',));(i,) = Fp2._first_ngens(1)
Fp2s = Fp2['s']; (s,) = Fp2s._first_ngens(1)

xiD=i+9;
#alt bn uses a D-twist so b'=b/(xiD)
b_twist=266929791119991161246907387137283842545076965332900288569378510910307636690*i + 19485874751759354771024239261021720505790618469301721065564631296452457478373;

E2 = EllipticCurve([Fp2(0), Fp2(b_twist)]);

Gen2=E2([11559732032986387107991004021392285783925812861821192530917403151452391805634*i
+10857046999023057135944570762232829481370756359578518086990519993285655852781,
4082367875863433681332203403145435568316851327593401208105741076214120093531*i+
8495653923123431417604973247489272438418190587263600148770280649306958101930
]);
#G1 cofactor

c = 1
#G2 cofactor
c2 = 21888242871839275222246405745257275088844257914179612981679871602714643921549

#  ED = EllipticCurve([Fp2(0), Fp2(btwD)])
#    Fp12D = Fp2.extension(s**6 - xiD, names=('wD',)); (wD,) = Fp12D._first_ngens(1)
#    Fq6D = Fp12D
 
Fq6D = Fp2.extension(s**6 - xiD, names=('wD',)); (wD,) = Fq6D._first_ngens(1)

#  Fp12D_A = Fp.extension((z**6 - i0D)**2 - i1D**2*a, names=('SD',)); (SD,) = Fp12D_A._first_ngens(1)   
Fp12D = Fp.extension((z**6 - 9)**2 +1, names=('SD',)); (SD,) = Fp12D._first_ngens(1)
i0D=9;i1D=1;

E12 = EllipticCurve([Fp12D(0), Fp12D(b)])

def map_Fp2_Fp12D(x):
   # evaluate elements of Fq=Fp[i] at i=s^6-1 = S^6-1
 return x.polynomial()((SD**6-i0D)/i1D)

def map_Fq6D_Fp12D(x):
 return sum([xi.polynomial()((SD**6-i0D)/i1D) * SD**e for e,xi in enumerate(x.list())])
    

def final_exp_bn(m, u):
 g = final_exp_easy_k12(m)
 h = final_exp_hard_bn(g, u)
 return h
 
def ate_pairing_bn_aklgl(Q,P,b_t,u0,Fq6,map_Fq6D_Fp12D,D_twist=True):
    m,S = miller_function_ate_2naf_aklgl(Q,P,b_t,t-1,Fq6,D_twist=True,m0=1)
    # convert m from tower field to absolute field
    m = map_Fq6D_Fp12D(m)
    f = final_exp_bn(m,u0)
    return f


#this is the function you want:
def e(P,Q):
 f= ate_pairing_bn_aklgl(Q, P, E2.a6(), u0, Fq6D, map_Fq6D_Fp12D, True)
   
 return f


def local2_test_ate_pairing_bn254_aklgl():
    set_random_seed(0)
    P = c*E1.random_element()
    while P == E1(0) or r*P != E1(0):
        P = c * E2.random_element()
    Q = c2*E2.random_element()
    while Q == E2(0) or r*Q != E2(0):
        Q = c2 * E2.random_element()
    f = _e(P,Q);
    
    print("P, Q, f",P, Q, f);
    
    ok = True
    bb = 1
    while ok and bb < 4:
        Qb = bb*Q
        aa = 1
        while ok and aa < 4:
            Pa = aa*P 
            fab = _e(Pa,Qb);
            fab_expected = f**(aa*bb)
            ok = fab == fab_expected
            aa += 1
        bb += 1
    print("test_ate_pairing_bn_aklgl (bilinear): {} ({} tests)".format(ok, (aa-1)*(bb-1)))
    return ok

if __name__ == "__main__":
    arithmetic(False)
   
    print("\ntest pairing")
    print(" E, E2, Fq6D, xiD, r, c, c2, t-1",E1, E2, Fq6D, xiD, r, c, c2, t-1);
   
    test_miller_function_ate_aklgl(E1,E2,Fq6D,xiD,r,c,c2,t-1,D_twist=True)
  
    local2_test_ate_pairing_bn254_aklgl()
   




    
    
