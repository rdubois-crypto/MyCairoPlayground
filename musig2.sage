##*************************************************************************************/
##/* Copyright (C) 2	022 - Renaud Dubois - This file is part of cy_lib project	 */
##/* License: This software is licensed under a dual BSD and GPL v2 license. 	 */
##/* See LICENSE file at the root folder of the project.				 */
##/* FILE: cy_hybridsig.h							         */
##/* 											 */
##/* 											 */
##/* DESCRIPTION: 2 round_multisignature Musig2 signatures verification smart contract*/
##/source code 		 */
##/* https:##eprint.iacr.org/2020/1261.pdf             				 */
##/* note that some constant aggregating values could be precomputed			 */
##**************************************************************************************/
##** sagemath is a usefull algebraic toolbox, you may install it or run directly the following lines without the "## comments" in https:##sagecell.sagemath.org/
## Stark curve parameters extracted from https:##github.com/starkware-libs/cairo-lang/blob/master/src/starkware/cairo/common/ec.cairo


def StringToHex(String):
	return String.encode('utf-8').hex();

def Hexa_from_Point(comment, Point):
	print("local ", comment,":(felt, felt)=(", hex(Point[0]), ",",hex(Point[1]),");");
	return 0;

p = p=2^251+17*2^192+1     
is_prime(p); #should return true
beta = 0x6f21413efbe40de150e596d72f7a8c5609ad26c15c915c1f4cdfcb99cee9e89
Fp=GF(p)
Stark_curve=EllipticCurve(Fp, [1, beta])
Stark_order=0x800000000000010ffffffffffffffffb781126dcae7b2321e66a241adc64d2f
GEN_X = 0x1ef15c18599971b7beced415a40f0c7deacfd9b0d1819e03d723d8bc943cfca;
GEN_Y = 0x5668060aa49730b7be4801df46ec62de53ecd11abe43a32873000c36e8dc1f;
Generator=Stark_curve([GEN_X, GEN_Y]); 
Stark_order*Generator  #this should be equal to (0,1,0) (infty point)

R=7*Generator;## (0x743829e0a179f8afe223fc8112dfc8d024ab6b235fd42283c4f5970259ce7b7, 0xe67a0a63cc493225e45b9178a3375596ea2a1d7012628a328dbc14c78cd1b7)
Hexa_from_Point("R:",R);

X=12*Generator;##dummy value for debug

Hexa_from_Point("X:",X);

S=5;
GpowS=S*Generator;##dummy value for test
Hexa_from_Point("g_pow_S:",GpowS);

user1=9*Generator;
Hexa_from_Point("User1:",user1);

user2=11*Generator;
Hexa_from_Point("User2:",user2);

