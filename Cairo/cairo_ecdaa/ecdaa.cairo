
%builtins range_check bitwise

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bitwise import bitwise_and, bitwise_or, bitwise_xor
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.cairo_keccak.packed_keccak import BLOCK_SIZE, packed_keccak_func
from starkware.cairo.common.math import (
    assert_lt,
    assert_nn,
    assert_nn_le,
    assert_not_zero,
    split_felt,
    unsigned_div_rem,
)
from starkware.cairo.common.memcpy import memcpy
from starkware.cairo.common.memset import memset
from starkware.cairo.common.pow import pow
from starkware.cairo.common.uint256 import Uint256, uint256_reverse_endian


//import Nethermind bls12 library (available here:https://github.com/NethermindEth/optimized_ecc_cairo)

from lib.fq12 import FQ12, fq12_lib
from lib.g1 import G1Point, g1_lib
from lib.g2 import G2Point, g2_lib
from lib.uint384 import Uint384, uint384_lib
from lib.fq import fq_lib
from lib.fq2 import FQ2, fq2_lib
from lib.uint384_extension import Uint768
from starkware.cairo.common.registers import get_label_location

from starkware.cairo.common.registers import get_fp_and_pc

from starkware.cairo.common.cairo_keccak.keccak import keccak, finalize_keccak


func main{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}()
{
  alloc_locals;
  let (__fp__, _) = get_fp_and_pc();

  let (keccak_ptr: felt*) = alloc();
  local keccak_ptr_start: felt* = keccak_ptr;
 
 //generators specification from (MSB representation)
 // https://github.com/zcash/librustzcash/blob/6e0364cd42a2b3d2b958a54771ef51a8db79dd29/pairing/src/bls12_381/README.md

//Gen1=E1([0x17F1D3A73197D7942695638C4FA9AC0F C3688C4F9774B905A14E3A3F171BAC58 6C55E83FF97A1AEFFB3AF00ADB22C6BB, 
//         0x08B3F481E3AAA0F1A09E30ED741D8AE4 FCF5E095D5D00AF600DB18CB2C04B3ED D03CC744A2888AE40CAA232946C5E7E1]);

  //LSB representation 
  let G1x=Uint384(d0=0x6C55E83FF97A1AEFFB3AF00ADB22C6BB, d1=0xC3688C4F9774B905A14E3A3F171BAC58, d2=0x17F1D3A73197D7942695638C4FA9AC0F );
  let G1y=Uint384(d0=0xD03CC744A2888AE40CAA232946C5E7E1, d1=0xFCF5E095D5D00AF600DB18CB2C04B3ED, d2=0x08B3F481E3AAA0F1A09E30ED741D8AE4  );
  let G1z=Uint384(d0=1, d1=0, d2=0);
  
  let G=G1Point(G1x, G1y, G1z);
  let (res:felt)=g1_lib.is_on_curve{range_check_ptr=range_check_ptr, bitwise_ptr=bitwise_ptr}(G);
  %{ print("\n G1 on Curve=",ids.res) %}
  
  local inputs  :(felt, felt)=(8031924123371070792, 560229490);
  with keccak_ptr {
  let res2:Uint256=keccak{range_check_ptr=range_check_ptr,bitwise_ptr=bitwise_ptr }(&inputs, 12);
  }
  //0xbee3f45550c2d2f12a198ea908e1d0ec 0xabea1f2503529a21734e2077c8b584d7
  let res3=res2.low;
  let res4=res2.high;
 
  %{ print("\n keccak_256('Hello word') from cairo=",hex(ids.res3), hex(ids.res4)) %}
  
  
  finalize_keccak(keccak_ptr_start=keccak_ptr_start, keccak_ptr_end=keccak_ptr);

  return();
}



