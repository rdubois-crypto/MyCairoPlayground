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

u0=0x44e992b44a6909f1

#preparse("QQx.<x> = QQ[]")
QQx = QQ['x']; (x,) = QQx._first_ngens(1)

p= 2188824287183927522224640574525727508869631115729782366268903789464522620858;

b=3;

#defining group G1    
Fp = GF(p, proof=False);
Fpz = Fp['z']; (z,) = Fpz._first_ngens(1)
E1= EllipticCurve([Fp(0), Fp(b)]);


#defining group G2    
Fp2 = Fp.extension(z**2 + 1, names=('i',));(i,) = Fp2._first_ngens(1)
Fp2s = Fp2['s']; (s,) = Fp2s._first_ngens(1)

xiD=i+9;
#alt bn uses a D-twist so b'=b/(xiD)
b_twist=266929791119991161246907387137283842545076965332900288569378510910307636690*i + 19485874751759354771024239261021720505790618469301721065564631296452457478373;

E2 = EllipticCurve([Fp2(0), Fp2(b_twist)]);

Fq6D = Fp2.extension(s**6 - xiD, names=('wD',)); (wD,) = Fq6D._first_ngens(1)   
Fp12D = Fp.extension((z**6 - i0D)**2 - i1D**2*a, names=('SD',)); (SD,) = Fp12D._first_ngens(1)
i0D=9;i1D=1;
  
def map_Fq6D_Fp12D(x, aD=None):
        if aD is None:
            aD = SD
        return sum([xi.polynomial()((aD**6-i0D)/i1D) * aD**e for e,xi in enumerate(x.list())])
    

def final_exp_bn(m, u):
 g = final_exp_easy_k12(m)
 h = final_exp_hard_bn(g, u)
 
def ate_pairing_bn_aklgl(Q,P,b_t,u0,Fq6,map_Fp12_Fp12_A,D_twist=True):
    m,S = miller_function_ate_2naf_aklgl(Q,P,b_t,u0,Fq6,D_twist=D_twist,m0=1)
    # convert m from tower field to absolute field
    m = map_Fq6D_Fp12D(m)
    f = final_exp_bn(m,u0)
    return f


def _e(P,Q):
  return ate_pairing_bn_aklgl(Q, P, E2.a6(), u0, Fq6D, map_Fq6D_Fp12D, False)


def local2_test_ate_pairing_bn254_aklgl():
    P = c*E1.random_element()
    while P == E1(0) or r*P != E1(0):
        P = c * E2.random_element()
    Q = c2*E2.random_element()
    while Q == E2(0) or r*Q != E2(0):
        Q = c2 * E2.random_element()
    f = _e(P,Q);
    
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
    print("test_ate_pairing_bls12_aklgl (bilinear): {} ({} tests)".format(ok, (aa-1)*(bb-1)))
    return ok

if __name__ == "__main__":
    arithmetic(False)
   
    print("\ntest pairing")
    local2_test_ate_pairing_bn254_aklgl()
   




    
    
