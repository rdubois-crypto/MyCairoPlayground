##*************************************************************************************/
##/* Copyright (C) 2022 - Renaud Dubois - This file is part of ecdaa EVM project	 */
##/* License: This software is licensed under a dual BSD and GPL v2 license. 	 */
##/* See LICENSE file at the root folder of the project.				 */
##/* FILE: test_ecdaa.py							             	  */
##/* 											  */
##/* 											  */
##/* DESCRIPTION: ECDAA algorithm solidity implementation file*/
##/* This is a high level simulation for validation purpose				  */
##/* 
##https://fidoalliance.org/specs/fido-v2.0-id-20180227/fido-ecdaa-algorithm-v2.0-id-20180227.html#ecdaa-join-algorithm           				  */
##/* note that some constant aggregating values could be precomputed			  */
##**************************************************************************************/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

// RULES: Take the control of the contract
contract ECDAA_ProofOfLedger {
    //BN254 curve prime characteristic
    uint256 public  modulusBN254= 21888242871839275222246405745257275088696311157297823662689037894645226208583;
    uint8 public constant EcPointG1_S8=2*32; //size of BN254 curves, beware of switch to BLS

    // System constants
    uint8 public constant Tag_bytesize=8;
    uint8 public constant Message_bytesize=8;
    
    
    // buffer size for H(U|S|W|AdditionalData|h_KRD) 
    uint8 public constant _BUFFER_T8=3*EcPointG1_S8+Tag_bytesize+Message_bytesize;
    //Type definition
    struct EcPointG1{
        uint256 x;
        uint256 y;
    }
    struct EcPointG2{
        uint256 x_re;
        uint256 x_im;
        uint256 y_re;
        uint256 y_im;
    }
    //Contract Storage
    EcPointG1 Pub_X;//Ledger Public key X part
    EcPointG1 Pub_Y;//Ledger Public Key Y part
    //ECDAA input signature
    struct Signature{
    	uint256 i_c;
        uint256 s;
        EcPointG1 R;
        EcPointG1 S;
        EcPointG1 T;
        EcPointG1 W;
        uint256 n;
    }

    constructor(uint256 i_Xx, uint256 i_Xy, uint256 i_Yx, uint256 i_Yy) 
    {
        Pub_X.x=i_Xx;
        Pub_X.y=i_Xx;
        Pub_Y.x=i_Yx;
        Pub_Y.y=i_Yy;
    }


    // hash buffer to Finite Field
    function HashZP(uint256 offset, uint256 buffer_bytesize) pure public {
     assembly{
      let h := keccak256(offset,buffer_bytesize )
      let hmodp:= mod(h, modulusBN254.offset)
     }
     }

    //call to ecAdd precompile
    function ecAdd(EcPointG1 memory P, EcPointG1 memory Q)  pure public returns(EcPointG1 memory res){
        EcPointG1 memory res;

        return res;
    }

    //call to ecSub precompile
  function ecMul(uint256 s, EcPointG1 memory S)  pure public returns(EcPointG1 memory res){
        EcPointG1 memory res;

        return res;
    }

    function ECDAA_Verify(uint8[Tag_bytesize] memory Tag, 
                          uint8[Message_bytesize] memory Message, Signature memory S   ) external    {

       // #3. H(n|H(S^s.W^-c|S|W|Data|H(KRD))) == c ? fail if not equal                    
     EcPointG1 memory t1=ecMul(S.s, S.S);
     uint256  rmi_c=modulusBN254-S.i_c; // should not be in storage
     EcPointG1 memory t2= ecMul(rmi_c, S.W);// U=s*S-i_c*W= s*S+(r-i_c)*W;
     EcPointG1 memory U=ecAdd(t1, t2);  
     //  #9. BigInteger c2=H(U|S|W|AdditionalData|h_KRD) 
     uint8[_BUFFER_T8] memory buffer;
     //TODO: paste everything in buffer
     //TODO: return offset of buffer
    //#11 c=H(n|c2)
    
    }
}
