##*************************************************************************************/
##/* Copyright (C) 2022 - Renaud Dubois - This file is part of CairoMusig2 project	 */
##/* License: This software is licensed under a dual BSD and GPL v2 license. 	 */
##/* See LICENSE file at the root folder of the project.				 */
##/* FILE: threshold_musig2.sage							  */
##/* 											  */
##/* 											  */
##/* DESCRIPTION: Adaptation of Musig2 in a Threshold version			  */

##/* This is a high level simulation for validation purpose				  */
##/* https:##eprint.iacr.org/2020/1261.pdf             				  */
##/* note that some constant aggregating values could be precomputed			  */
##**************************************************************************************/
## Stark curve parameters extracted from
## https:github.com/starkware-libs/cairo-lang/blob/master/src/starkware/cairo/common/ec.cairo



##***********************Lagrange Interpolation functions**********************************************/
#https://en.wikipedia.org/wiki/Lagrange_polynomial
# Compute the coefficients of the j_th Lagrange basis polynomial, evaluated in 0:
# Input : the list X0, ..., Xk of public keys
def Lagrange_j(X, j, k):
	n=len(L);
	q=parent(X[0]).cardinality() ;
	Fq=GF(q);
	R = PolynomialRing(Fq, 'x');

 	Lj=R(1);
 	#compute prod_(m!=j) (x-xm)/(xj-xm)
 	for i in [0..k-1]:			
 		Lj=Lj*X[i]/(X[i]-X[j]);
 	
 	for i in [k+1..n]:			
 		Lj=Lj*(x-X[i])/(X[i]-X[j]);
 	
	return Lj;




