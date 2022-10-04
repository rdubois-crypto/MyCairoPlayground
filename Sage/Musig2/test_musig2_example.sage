##*************************************************************************************/
##/* Copyright (C) 2022 - Renaud Dubois - This file is part of cairo_musig2 project	 */
##/* License: This software is licensed under a dual BSD and GPL v2 license. 	 */
##/* See LICENSE file at the root folder of the project.				 */
##/* FILE: test_musig2.sage						             	  */
##/* 											  */
##/* 											  */
##/* DESCRIPTION: 2 round_multisignature Musig2 signatures 				  */
##/* This is a high level simulation for validation purpose				  */
##/* This file emulates a n-users aggregation and signatures, n being an input of sage */

##/* https:##eprint.iacr.org/2020/1261.pdf             				  */
##**************************************************************************************/

#note that the program expects the following value to be defined (currently done by makefile)
#to execute independtly, uncomment the following line:
#_MU=4;nb_users=3; size_message=2;seed=0;

from time import time
import sage.all
import subprocess
from sage.misc.sage_ostools import redirection

load('musig2.sage');
load('../common/io_conversions.sage');

C_filepath='test_vec/test_vector_musig2.c';
filep = open(C_filepath,'a');


def DisplaySave(comment, varname, counter, var):
	print(comment, var);
	name=varname+str(counter);
	print(name, hex(var), "*/");
	fprint_c_MSB(filep, "\n /*"+name+"*/",name, int(var),8,"");

		


with open(C_filepath, 'w') as file_out:

	
	filep.write("/* File automatically generated using test_musig2_example.sage, the  : ");
	with redirection(sys.stdout, filep):
		subprocess.call('date');
	filep = open(C_filepath,'a');

	print("\n\n********************************************************* \n*******************SAGEMATH:Simulation of a full Sign/Verif of Musig2:\n");
	print("Simulation for a set of users of size:", nb_users);


	##***********************IO functions**********************************************/
	print("\n*******************Generating Message of size",size_message,":\n");
	Fq=GF(Stark_order);
	message=[0..size_message-1];
	for i in [0..size_message-1]:
		message[i]=int(Fq.random_element());
	print(message);


	##***********************Key Generation and Aggregate******************************/

	print("\n*******************Generating Keys:\n");
	L=[];
	secrets=[];
	for i in [0..nb_users-1]:
		print("\n***** user",i);
		[x,P]=Musig2_KeyGen(Curve, curve_Generator, Stark_order);#Concatenation of public keys
		
		DisplaySave("/*Secret key user", 'SecretKey_', i, x)
		
		DisplaySave("/*Public key ", 'PublicKey_X', i, int(P[0]))
		
		DisplaySave("/*", 'PublicKey_Y', i, int(P[1]))
		
		
#		print("/*Public key user",i,":\n",P,"*/");
#		name='PubX_'+str(i);
#		print(name, hex(var));
#		name='PubY_'+str(i);
#		print(name, hex(var));
		
		
		L=L+[int(P[0]),int(P[1])];	
		secrets=secrets+[x]; ##of course private keys are kept secret by users(simulation convenience)
		
	print("\n /***Serialized public keys L:\n",L, "*/");
	print("\n /***Serialized secret keys :\n",secrets, "*/");


	print("\n ***Computing Aggregating coeffs ai:\n",L);	
	vec_a=[0..nb_users-1];
	for i in [0..nb_users-1]:	
		vec_a[i]=H_agg(L, nb_users, L[2*i], L[2*i+1], Stark_order);	
		print("a[",i,"]=\n",vec_a[i]);
		name="a_"+str(i);
		fprint_c_MSB(filep, "\n /*"+name+"*/",name, int(vec_a[i]),8,"");
	

		
	print("\n*******************Aggregating Public Keys:\n");
	KeyAgg=Musig2_KeyAgg(Curve, curve_Generator, L, nb_users, Stark_order);
	print("Aggregated Key:", KeyAgg);
	if(int(KeyAgg[1])&1==1): 
		print("Wrong Key Agg, change Seed from", seed);
		exit();
	
	print("/*Aggregated Key: */");
	name='Key_Agg_X';
	Print_C_MSB("\n /*"+name+"*/",name, int(KeyAgg[0]),8,"");
	fprint_c_MSB(filep, "\n /*"+name+"*/",name, int(KeyAgg[0]),8,"");
	
	name='Key_Agg_Y';
	Print_C_MSB("\n /*"+name+"*/",name, int(KeyAgg[1]),8,"");
	fprint_c_MSB(filep, "\n /*"+name+"*/",name, int(KeyAgg[1]),8,"");
	

	##***********************Round 1 functions******************************/
	print("\n*******************Signature Round1:\n");
	infty_point=0*curve_Generator;

	vec_Rj=[0..nb_users-1];
	vec_nonces=[0..nb_users-1];	##of course nonces are kept secret by users(simulation convenience)


			
	for i in [0..nb_users-1]:#compute each users contribution
		[vec_nonces[i], vec_Rj[i]]=Musig2_Sign_Round1(Stark_order, nb_users,curve_Generator);	
		
	#Aggregate Round1 contributions	
	vec_R=Musig2_Sig1Agg(vec_Rj);
		
	print("All nonces:",vec_nonces);

	print("Aggregated Signature=", vec_Rj);	

		
	##***********************Round 2 functions******************************/
	print("\n*******************Signature Round2:\n");

	vec_s=[0..nb_users-1];

	for i in [0..nb_users-1]:
		print("\n***** User",i);
		[R,vec_s[i], c]=Musig2_Sign_Round2_all( 
			Curve, curve_Generator,Stark_order, nb_users, KeyAgg,#common parameters
			vec_a[i], secrets[i],					#user's data
			vec_R, vec_nonces[i],				#First round output
			message,  size_message);
		print("s_",i,":", vec_s[i]);
			
	s=Musig2_Sig2Agg(vec_s);
			
	print("Final Signature: \n R=", R,"\n s=", s,"\n c=", c);
	print("With Key Agg:",KeyAgg);

	##***********************Verification functions******************************/
	print("\n*******************Verification :\n");
	print("/*Public KeyAgg */");
	print(hex(int(KeyAgg[0])));

	
	print("/*R part */");
	name='R_x';
	print(hex(int(R[0])));
	fprint_c_MSB(filep, "\n /*"+name+"*/",name, int(R[0]),8,"");
	
	name='R_y';
	
	fprint_c_MSB(filep, "\n /*"+name+"*/",name, int(R[1]),8,"");
	
	print("/*s part */");
	print(hex(int(s)));
	
	name='s';
	fprint_c_MSB(filep, "\n /*"+name+"*/",name, int(s),8,"");
	
	print("/*c part */");
	print(hex(int(c)));
	name='c';
	fprint_c_MSB(filep, "\n /*"+name+"*/",name, int(c),8,"");
	

	res_verif=Musig_Verif_Core(Curve, curve_Generator,R,s,KeyAgg, int(c));
	print(res_verif);
	
	filep.close();




