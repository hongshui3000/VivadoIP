`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: audio_buffer
// Author: Tinghui Wang
//
// Copyright @ 2017 RealDigital.org
//
// Description:
//   audio_buffer implements an 16-bit audio buffer of length 1024 word length.
//   The audio buffer is designed to store 16-bit PCM audio signal sampled at
//   48KHz.
//   The design utilized Xilinx True-Dual Port (TDP) 18Kb Block RAM resource.
//   Port A of the block RAM is a random addressible memory interface, while
//   Port B is read-only and serve as a FIFO-like interface.
//
// History:
//   11/12/17: Created
//
// License: BSD 3-Clause
//
// Redistribution and use in source and binary forms, with or without 
// modification, are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this 
//    list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice, 
//    this list of conditions and the following disclaimer in the documentation 
//    and/or other materials provided with the distribution.
//
// 3. Neither the name of the copyright holder nor the names of its contributors 
//    may be used to endorse or promote products derived from this software 
//    without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//////////////////////////////////////////////////////////////////////////////////


module audio_buffer(
    input clkA,
    input [9:0] addrA,
    input [15:0] diA,
    output [15:0] doA,
    input enA,
    input weA,
    input rstA,
    input clkB,
    output [15:0] doB,
    input enB,
    input rstB
    );

	wire [1:0] bweA;
    assign bweA = {weA, weA};
   
    reg [9:0] addrB;
 
    BRAM_TDP_MACRO #(
          .BRAM_SIZE("18Kb"), // Target BRAM: "18Kb" or "36Kb" 
          .DEVICE("7SERIES"), // Target device: "7SERIES" 
          .DOA_REG(0),        // Optional port A output register (0 or 1)
          .DOB_REG(0),        // Optional port B output register (0 or 1)
          .INIT_A(16'h0000000),  // Initial values on port A output port
          .INIT_B(16'h00000000), // Initial values on port B output port
          .INIT_FILE ("NONE"),
          .READ_WIDTH_A (16),   // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
          .READ_WIDTH_B (16),   // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
          .SIM_COLLISION_CHECK ("ALL"), // Collision check enable "ALL", "WARNING_ONLY", 
                                        //   "GENERATE_X_ONLY" or "NONE" 
          .SRVAL_A(16'h00000000), // Set/Reset value for port A output
          .SRVAL_B(16'h00000000), // Set/Reset value for port B output
          .WRITE_MODE_A("WRITE_FIRST"), // "WRITE_FIRST", "READ_FIRST", or "NO_CHANGE" 
          .WRITE_MODE_B("READ_FIRST"), // "WRITE_FIRST", "READ_FIRST", or "NO_CHANGE" 
          .WRITE_WIDTH_A(16), // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
          .WRITE_WIDTH_B(16), // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
          .INIT_00(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_01(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_02(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_03(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_04(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_05(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_06(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_07(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_08(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_09(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_0A(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_0B(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_0C(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_0D(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_0E(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_0F(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_10(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_11(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_12(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_13(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_14(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_15(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_16(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_17(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_18(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_19(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_1A(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_1B(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_1C(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_1D(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_1E(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_1F(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_20(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_21(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_22(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_23(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_24(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_25(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_26(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_27(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_28(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_29(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_2A(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_2B(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_2C(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_2D(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_2E(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_2F(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_30(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_31(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_32(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_33(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_34(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_35(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_36(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_37(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_38(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_39(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_3A(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_3B(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_3C(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_3D(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_3E(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_3F(256'h0000000000000000000000000000000000000000000000000000000000000000),
          
          // The next set of INIT_xx are valid when configured as 36Kb
          .INIT_40(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_41(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_42(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_43(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_44(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_45(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_46(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_47(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_48(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_49(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_4A(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_4B(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_4C(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_4D(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_4E(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_4F(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_50(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_51(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_52(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_53(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_54(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_55(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_56(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_57(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_58(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_59(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_5A(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_5B(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_5C(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_5D(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_5E(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_5F(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_60(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_61(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_62(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_63(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_64(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_65(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_66(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_67(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_68(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_69(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_6A(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_6B(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_6C(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_6D(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_6E(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_6F(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_70(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_71(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_72(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_73(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_74(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_75(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_76(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_77(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_78(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_79(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_7A(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_7B(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_7C(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_7D(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_7E(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INIT_7F(256'h0000000000000000000000000000000000000000000000000000000000000000),
         
          // The next set of INITP_xx are for the parity bits
          .INITP_00(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INITP_01(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INITP_02(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INITP_03(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INITP_04(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INITP_05(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INITP_06(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INITP_07(256'h0000000000000000000000000000000000000000000000000000000000000000),
          
          // The next set of INITP_xx are valid when configured as 36Kb
          .INITP_08(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INITP_09(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INITP_0A(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INITP_0B(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INITP_0C(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INITP_0D(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INITP_0E(256'h0000000000000000000000000000000000000000000000000000000000000000),
          .INITP_0F(256'h0000000000000000000000000000000000000000000000000000000000000000)
       ) BRAM_TDP_MACRO_inst (
          .DOA(doA),       // Output port-A data, width defined by READ_WIDTH_A parameter
          .DOB(doB),       // Output port-B data, width defined by READ_WIDTH_B parameter
          .ADDRA(addrA),   // Input port-A address, width defined by Port A depth
          .ADDRB(addrB),   // Input port-B address, width defined by Port B depth
          .CLKA(clkA),     // 1-bit input port-A clock
          .CLKB(clkB),     // 1-bit input port-B clock
          .DIA(diA),       // Input port-A data, width defined by WRITE_WIDTH_A parameter
          .DIB(16'h0),     // Input port-B data, width defined by WRITE_WIDTH_B parameter
          .ENA(enA),       // 1-bit input port-A enable
          .ENB(enB),       // 1-bit input port-B enable
          .REGCEA(1'b1),   // 1-bit input port-A output register enable
          .REGCEB(1'b1),   // 1-bit input port-B output register enable
          .RSTA(rstA),     // 1-bit input port-A reset
          .RSTB(1'b0),     // 1-bit input port-B reset
          .WEA(bweA),       // Input port-A write enable, width defined by Port A depth
          .WEB(2'b0)       // Input port-B write enable, width defined by Port B depth
       );


	// Port B is a FIFO-like interface for PDM generation
    // It does not check the overflow or underflow of the FIFO - so no guarantee on the sequence of data
    // But goes through the FIFO without synchronizing with the write side.
    always @ (posedge clkB or posedge rstB)
    begin
        if (rstB == 1'b1)
            addrB <= 10'h0;
        else
        begin
            if (enB == 1'b1)
                addrB <= addrB + 1'b1;
            else
                addrB <= addrB; 
        end
    end 

endmodule
