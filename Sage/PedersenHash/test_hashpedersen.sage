##*************************************************************************************/
##/* Copyright (C) 2022 - Renaud Dubois - This file is part of cy_lib project	 */
##/* License: This software is licensed under a dual BSD and GPL v2 license. 	 */
##/* See LICENSE file at the root folder of the project.				 */
##/* FILE: test_hashpedersen.sage							         */
##/* 											 */
##/* 											 */
##/* DESCRIPTION: Pedersen Hash modified Stark version as coded in */
##/* https://github.com/starkware-libs/cairo-lang/blob/master/src/starkware/crypto/signature/fast_pedersen_hash.py
##/* spec is here:https://docs.starkware.co/starkex/pedersen-hash-function.html
##/source code 		 */
##/**************************************************************************************/

#### IMPORT
load('pedersen_hashpoint.sage');
load('../common/io_conversions.sage');

from time import time
import sage.all
import subprocess
from sage.misc.sage_ostools import redirection

### OUTPUT FILE
C_filepath='test_vector_hashpedersen.c';
filep = open(C_filepath,'w');
filep.write("/* File automatically generated using test_hashpedersen.sage, the  : ");
with redirection(sys.stdout, filep):
		subprocess.call('date');
filep = open(C_filepath,'a');

### STARK CURVE INIT
curve_characteristic=2^251+17*2^192+1     
is_prime(curve_characteristic); #should return true
beta = 0x6f21413efbe40de150e596d72f7a8c5609ad26c15c915c1f4cdfcb99cee9e89
Stark_order=0x800000000000010ffffffffffffffffb781126dcae7b2321e66a241adc64d2f
GEN_X = 0x1ef15c18599971b7beced415a40f0c7deacfd9b0d1819e03d723d8bc943cfca;
GEN_Y = 0x5668060aa49730b7be4801df46ec62de53ecd11abe43a32873000c36e8dc1f;	
[Curve,curve_Generator, P0, P1, P2, P3, Shift]=Init_Stark(curve_characteristic,1, beta,GEN_X, GEN_Y,Stark_order) ;



########### MAIN
message=[0x616c6c657a206269656e20766f757320666169726520656e63756c65722021 ,0x617220756e643262616e6465206465206cc3a967696f6e6e61697265732013];
name="m0";
fprint_c_MSB(filep, "\n /*"+name+"*/",name, int(message[0]),8,"");
name="m1";
fprint_c_MSB(filep, "\n /*"+name+"*/",name, int(message[1]),8,"");
	
	
#computing test vector for testing Cairo implementation of pedersen hash:


print("\n\n********************************************************* \n*******************SAGEMATH:Pedersen hash and chain hash test_vector generation\n");
pedersen_hash_res=pedersen(message[0], message[1]); #1507473129754433389303589648688410091651017934427319142210890580198758665242
print("Result of hash  (m0,m1)     :",pedersen_hash_res);

name="core_pedersen";
fprint_c_MSB(filep, "\n /*"+"h(m0,m1)"+"*/",name, int(pedersen_hash_res),8,"");

result=pedersen_hash(message,2);
print("Result of hash chain : h(h(h(0, x1), x2), 2)=",result);

name="full_pedersen";
fprint_c_MSB(filep, "\n /*"+"full pedersen with padding result"+"*/",name, result,8,"");





