//##*************************************************************************************/
//##/* Copyright (C) 2022 - Renaud Dubois - This file is part of ecdaa EVM project	 */
//##/* License: This software is licensed under a dual BSD and GPL v2 license. 	 */
//##/* See LICENSE file at the root folder of the project.				 */
//##/* FILE: ecdaa.sol							             	  */
//##/* 											  */
//##/* 											  */
//##/* DESCRIPTION: ECDAA algorithm solidity implementation file*/
//##/* 
//##https://fidoalliance.org/specs/fido-v2.0-id-20180227/fido-ecdaa-algorithm-v2.0-id-20180227.html#ecdaa-join-algorithm           				  */
//##**************************************************************************************/
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

// RULES: Take the control of the contract
contract ECDAA_ProofOfLedger {
   // ##/* DESCRIPTION: altbn_128 Ethereum curve*/
   //##/* https://ethereum.github.io/yellowpaper/paper.pdf
   
    uint256 public constant modulus= 21888242871839275222246405745257275088696311157297823662689037894645226208583; //BN254 curve prime characteristic
    uint8 public constant _MODULUS_S8=32;// curve characteristic bytesize
    uint8 public _ORDER_S8=32;  // order characteristic bytesize
    uint8 public constant EcPointG1_S8=2*32; //size of BN254 curves, beware of switch to BLS
    uint16 public constant _BUFFER_ECPAIRING_CMP= 12*32;
    // System constants
    uint8 public constant _TAG_S8=8;
    uint8 public constant _MSG_S8=8;
    // Generator of G2
    uint256 public constant P2_x_1 =11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 public constant P2_x_0 =10857046999023057135944570762232829481370756359578518086990519993285655852781;
    
    uint256 public constant P2_y_1 =4082367875863433681332203403145435568316851327593401208105741076214120093531;
    uint256 public constant P2_y_0 =8495653923123431417604973247489272438418190587263600148770280649306958101930;
    

    //Gen1=E1([1,2]);

    //Gen2=E2([11559732032986387107991004021392285783925812861821192530917403151452391805634*i
    //+10857046999023057135944570762232829481370756359578518086990519993285655852781,
    //4082367875863433681332203403145435568316851327593401208105741076214120093531*i+
    //8495653923123431417604973247489272438418190587263600148770280649306958101930
    //]);
    
    // buffer size for H(U|S|W|AdditionalData|h_KRD) 
    uint8 public constant _BUFFER_S8=3*EcPointG1_S8+_TAG_S8+_MSG_S8;
    //Type definition
    struct EcPointG1{
        uint256 x;
        uint256 y;
    }
    struct EcPointG2{
        uint256 x_im;
        uint256 x_re;
        uint256 y_im;
        uint256 y_re;
    }
    //TODO: initialize P2
    EcPointG2 public P2=EcPointG2(P2_x_1, P2_x_0, P2_y_1, P2_x_0);
/*    P2.x_im=P2_x_1;
    P2.x_re= P2_x_0;
    P2.y_im= P2_y_1;
    P2_y_re= P2_y_0;*/

    //Contract Storage
    EcPointG2 Pub_X;//Ledger Public key X part
    EcPointG2 Pub_Y;//Ledger Public Key Y part
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
/*
    constructor(uint256 [8] memory Public_Key) 
    {
        Pub_X.x_re=Public_Key[0];
        Pub_X.x_im=Public_Key[1];
        Pub_X.y_re=Public_Key[2];
        Pub_X.y_im=Public_Key[3];

        Pub_Y.x_re=Public_Key[4];
        Pub_Y.x_im=Public_Key[5];
        Pub_Y.y_re=Public_Key[6];
        Pub_Y.y_im=Public_Key[7];
    }
*/

    // hash buffer to Finite Field
    function HashZP(bytes memory b) pure public returns(uint256 hZp) {

     assembly {
            hZp := keccak256(add(b, 0x20),mload(b))
        }
        hZp=hZp%modulus;
     }

    //call to ecAdd precompile
    function ecAdd(EcPointG1 memory P, EcPointG1 memory Q)   public returns(EcPointG1 memory res){
          uint256[4] memory input;
           input[0]=P.x;
           input[1]=P.y;
           input[2]=Q.x;
           input[3]=Q.y;
           
           assembly {
          
              // TODO :how to call ecAdd precompile n06 ?
           if iszero( call(not(0), 0x06, 0, input, 0x080, res, 0x40))
           {
            revert(0, 0)
           } }
    
        
       
    }
  
   // returns e(P1, P2)==e(Q1, Q2), which is equivalent to Precompile8(P1,P2, Q1, -Q2)
   function ecPairingEquality(  EcPointG1 memory R1, EcPointG2 memory R2, EcPointG1 memory Q1, EcPointG2 memory Q2 )  public returns(bool  res)   {

       //Q1=-Q1
       Q1.y=modulus-Q1.y;
       //bufer to paste 
      uint256[12] memory input;
       input[0]=R1.x;
       input[1]=R1.y;
       input[2]=R2.x_im;
       input[3]=R2.x_re;
       input[4]=R2.y_im;
       input[5]=R2.y_re;

       input[0]=Q1.x;
       input[1]=Q1.y;
       input[2]=Q2.x_im;
       input[3]=Q2.x_re;
       input[4]=Q2.y_im;
       input[5]=Q2.y_re;


       //TODO: concatenate R1|R2|Q1|Q2 into buffer 
        assembly {
              // TODO :how to call ecPairing precompile n08 ?
            if iszero(call(not(0), 0x08, 0, input, 0x0180, res, 0x20)) {
                revert(0, 0)}
            }

        return res;
   }

    //call to ecSub precompile
  function ecMul(uint256 s, EcPointG1 memory S)   public returns(EcPointG1 memory res){
      
       uint256[3] memory input;

       input[0]=S.x;
       input[1]=S.y;
       input[2]=s;
       
       assembly {
            // call ecmul precompile
            if iszero(call(not(0), 0x07, 0, input, 0x60, res, 0x40)) {
                revert(0, 0)
            }
        }
        return res;
    }

    EcPointG1 public debugP;

    function test_ecAdd() public returns(EcPointG1 memory res)
    {
        EcPointG1 memory P1=EcPointG1(1,2);
        EcPointG1 memory mP1=EcPointG1(1,modulus-2);
      
        EcPointG1 memory m2P=EcPointG1(1368015179489954701390400359078579693043519447331113978918064868415326638035, 
        11970132820537103637166003141937572314130795164147247315533067598634108082819);

        res=ecAdd(m2P,P1);
        debugP=res;

        assert(mP1.y==res.y);

    }

    uint256 public debug_hash;

    function test_hashZp()  public returns (uint256 res)
    {
       
     
       // uint8[3] memory abc=[0x61, 0x62, 0x63];-> question for qdqd: why not working ?
        bytes memory b = new bytes(3);
        b[0]=0x61;b[1]=0x62;b[2]=0x63;

       assembly {
            res := keccak256(add(b, 0x20),mload(b))
        }
       
       //expected hash of 'abc'  from https://gist.github.com/miguelmota/97b3a46291bc41a9b3054e75609d1dbf
        assert(res==0x4e03657aea45a94fc7d47ba826c8d667c0d1e6e33a64a036ec44f58fa12d6c45);


     debug_hash=res;
    }

    bytes public debug_buffer_out = new bytes(32);
    
    function test_ToBuff() public {
        bytes memory debug_buffer = new bytes(32);
  
        debug_buffer[0]=0x61;debug_buffer[1]=0x62;debug_buffer[2]=0x63;

        uint256 offset=0x20;
        uint256 value=0x6061626364656667606162636465666760616263646566676061626364656667;
       
        //bytes memory x=abi.encodePacked(value);
        assembly { mstore(add(debug_buffer, offset), value) }
        //debug_buffer=abi.encodePacked(value);
        bytes32 b = bytes32(value);

        assert(b[0]!=0);
        for(uint i=0;i<3;i++){
            debug_buffer_out[i]=debug_buffer[i];
        }
    
        assembly { mstore(add(debug_buffer, offset), value) }
        
    }

    function ECDAA_Verify(uint256 Tag, 
                          uint256 Message, Signature memory S   ) external    {

       // #3. H(n|H(S^s.W^-c|S|W|Data|H(KRD))) == c ? fail if not equal                    
     EcPointG1 memory t1=ecMul(S.s, S.S);
     uint256  rmi_c=modulus-S.i_c; // should not be in storage
     EcPointG1 memory t2= ecMul(rmi_c, S.W);// U=s*S-i_c*W= s*S+(r-i_c)*W;
     EcPointG1 memory U=ecAdd(t1, t2);  
     //  #9. BigInteger c2=H(U|S|W|AdditionalData|h_KRD) 
    bytes memory buffer=new bytes(_BUFFER_S8);
    
    uint256  offset=32;
    uint256 temp=U.x;
    assembly { mstore(add(buffer, offset),temp) } //Ux
    offset=offset+32;

    temp=U.x;
    assembly { mstore(add(buffer, offset), temp) }//Uy
    offset=offset+32;

    temp=S.S.x;
    assembly { mstore(add(buffer, offset),temp) } //Sx
    offset=offset+32;

    temp=S.S.y;
    assembly { mstore(add(buffer, offset),temp) } //Sy
    offset=offset+32;

    temp=S.W.x;
    assembly { mstore(add(buffer, offset),temp) } //Sx
    offset=offset+32;

    temp=S.W.y;
    assembly { mstore(add(buffer, offset),temp) } //Sy
    offset=offset+32;

    temp=S.W.y;
    assembly { mstore(add(buffer, offset),temp) } //Sy
    offset=offset+32;

    assembly { mstore(add(buffer, offset),Tag) } //Tag
    assembly { mstore(add(buffer, offset),Message) } //Msg

    uint256  c2=HashZP(buffer );
    //#11 c=H(n|c2)
 //   bytes memory buffer2=new bytes(_BUFFER_S8);, would cost stack size
 // to spare stack size we reuse buffer and modify its length
    temp=2*_MODULUS_S8;
    assembly { mstore(buffer,temp) }
    offset=32;
    temp=S.n;

    assembly { mstore(add(buffer, offset),temp) } //n
    assembly { mstore(add(buffer, offset),c2) } //n
    
    uint256  c=HashZP(buffer );
    assert(c==S.i_c);
    //#4 e(R,Y)!=e(S,P2), fail if not equal
    bool res=ecPairingEquality(S.R, Pub_Y, S.S, Pub_X);
    //#5 e(T,P2)==e(R.W, X) ? fail if not equal  
    res=res && ecPairingEquality(S.T, P2, ecAdd(S.R, S.W), Pub_X);
   //#6 for all rogues, if W=S^sk, fail
   //# It is assumed that rogue checking is done prior to the call
 
    assert(res==true);
    }
}
