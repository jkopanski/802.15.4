//  ========================================================================--
//  The confidential and proprietary information contained in this file may
//  only be used by a person authorised under and to the extent permitted
//  by a subsisting licensing agreement from ARM Limited.
//  
//                   (C) COPYRIGHT 2011 ARM Limited.
//                           ALL RIGHTS RESERVED
//  
//  This entire notice must be reproduced on all copies of this file
//  and copies of this file may only be made by a person if such person is
//  permitted to do so under the terms of a subsisting license agreement
//  from ARM Limited.
//  
//  ----------------------------------------------------------------------------
//  Version and Release Control Information:
//  
//  File Revision       : 108469
//
//  Date                :  2011-04-05 21:28:59 +0100 (Tue, 05 Apr 2011)
//  
//  Release Information : BP065-BU-01000-r0p1-00rel0
//  
//  ----------------------------------------------------------------------------
`ifndef AXI4PC_TYPES
  `include "Axi4PC_ace_defs.v"
`endif

`ifndef ACEPC_TYPES
`define ACEPC_TYPES
// Defines for ARSNOOP values
`define ACEPC_ARSNOOP_READONCE           4'b0000
`define ACEPC_ARSNOOP_READSHARED         4'b0001
`define ACEPC_ARSNOOP_READCLEAN          4'b0010
`define ACEPC_ARSNOOP_READNOTSHAREDDIRTY 4'b0011
`define ACEPC_ARSNOOP_READUNIQUE         4'b0111
`define ACEPC_ARSNOOP_CLEANSHARED        4'b1000
`define ACEPC_ARSNOOP_CLEANINVALID       4'b1001
`define ACEPC_ARSNOOP_CLEANUNIQUE        4'b1011
`define ACEPC_ARSNOOP_MAKEUNIQUE         4'b1100
`define ACEPC_ARSNOOP_MAKEINVALID        4'b1101

`define ACEPC_ARSNOOP_DVMCOMPLETE       4'b1110
`define ACEPC_ARSNOOP_DVMMESSAGE        4'b1111


// Defines for AWSNOOP values
`define ACEPC_AWSNOOP_WRITEUNIQUE       3'b000
`define ACEPC_AWSNOOP_WRITELINEUNIQUE   3'b001
`define ACEPC_AWSNOOP_WRITECLEAN        3'b010
`define ACEPC_AWSNOOP_WRITEBACK         3'b011
`define ACEPC_AWSNOOP_WRITEEVICT        3'b100

// Defines for AXDOMAIN values
`define ACEPC_AXDOMAIN_NONSHAREABLE     2'b00
`define ACEPC_AXDOMAIN_INNER_DOMAIN     2'b01
`define ACEPC_AXDOMAIN_OUTER_DOMAIN     2'b10
`define ACEPC_AXDOMAIN_SYS_DOMAIN       2'b11


// Upper bits of RRESP
`define ACEPC_RRESP_UNIQUECLEAN 2'b00
`define ACEPC_RRESP_UNIQUEDIRTY 2'b01
`define ACEPC_RRESP_SHAREDCLEAN 2'b10
`define ACEPC_RRESP_SHAREDDIRTY 2'b11



// Lower bits of RRESP
`define ACEPC_RRESP_OKAY   2'b00
`define ACEPC_RRESP_EXOKAY 2'b01
`define ACEPC_RRESP_SLVERR 2'b10
`define ACEPC_RRESP_DECERR 2'b11



// Defines for ACSNOOP values
`define ACEPC_ACSNOOP_READONCE           4'b0000
`define ACEPC_ACSNOOP_READSHARED         4'b0001
`define ACEPC_ACSNOOP_READCLEAN          4'b0010
`define ACEPC_ACSNOOP_READNOTSHAREDDIRTY 4'b0011
`define ACEPC_ACSNOOP_READUNIQUE         4'b0111
`define ACEPC_ACSNOOP_CLEANSHARED        4'b1000
`define ACEPC_ACSNOOP_CLEANINVALID       4'b1001
`define ACEPC_ACSNOOP_MAKEINVALID        4'b1101

`define ACEPC_ACSNOOP_DVMCOMPLETE       4'b1110
`define ACEPC_ACSNOOP_DVMMESSAGE        4'b1111

// Defines for indexing the CRRESP
`define ACEPC_CRRESP_DATATRANSFER 0
`define ACEPC_CRRESP_ERROR        1
`define ACEPC_CRRESP_PASSDIRTY    2
`define ACEPC_CRRESP_ISSHARED     3
`define ACEPC_CRRESP_WASUNIQUE    4

// Defines for indexing the DVM message types
`define ACEPC_DVM_TLB_INVALIDATE             3'b000
`define ACEPC_DVM_BRAN_PRED_INVALIDATE       3'b001
`define ACEPC_DVM_PHY_INST_CACHE_INVALIDATE  3'b010
`define ACEPC_DVM_VIR_INST_CACHE_INVALIDATE  3'b011
`define ACEPC_DVM_SYNC                       3'b100
`define ACEPC_DVM_HINT                       3'b110


`endif

