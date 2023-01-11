//*************************************************************************************/
///* Copyright (C) 2022 - Renaud Dubois - This file is part of Cairo_musig2 project	 */
///* License: This software is licensed under a dual BSD and GPL v2 license. 	 */
///* See LICENSE file at the root folder of the project.				 */
///* FILE: ec_io.cairo						         */
///* 											 */
///* 											 */
///* DESCRIPTION:  io functions for ec over stark curve			 */
//**************************************************************************************/


func io_printPoint{range_check_ptr }(ec_G: EcPoint){
    let x=ec_G.x;
    %{ print("\n x:", ids.x) %}
    
    let y=ec_G.y;
    %{ print("\n y:", ids.y) %}
    
     return();
}
