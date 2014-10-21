//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may 
// only be used by a person authorised under and to the extent permitted 
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2011 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file 
// and copies of this file may only be made by a person if such person is 
// permitted to do so under the terms of a subsisting license agreement 
// from ARM Limited.
//
//----------------------------------------------------------------------------
//  Version and Release Control Information:
//
//  File Revision       : 125435
//
//  Date                :  2012-02-20 13:25:14 +0000 (Mon, 20 Feb 2012)
//
//  Release Information : BP065-BU-01000-r0p1-00rel0
//
//------------------------------------------------------------------------------
//  Purpose             : This is the ACE protocol checker.
//                          
//                        Supports bus widths of 32, 64, 128, 256, 512, 1024 
//                        bit
//                        Supports a single outstanding exclusive read per ID
//                        Instantiates the Axi4 Protocol checker to check the
//                        Axi4 aspects of the protocol.
//----------------------------------------------------------------------------
// CONTENTS
// ========
//  376.  Module: AcePC
//  475.    1) Parameters
//  479.         - Configurable (user can set)
//  550.         - Calculated (user should not override)
//  620.    2) Inputs (no outputs)
//  624.         - Global Signals
//  630.         - Write Address Channel
//  651.         - Write Data Channel
//  662.         - Write Response Channel
//  674.         - Read Address Channel
//  695.         - Read Data Channel
//  709.         - Snoop Address Channel
//  718.         - Snoop Response Channel
//  725.         - Snoop Data Channel
//  732.         - Low Power Interface
//  740.    3) Wire and Reg Declarations
//  790.    4) Verilog Defines
//  793.         - Clock and Reset
//  821.    5) Initialize simulation
//  826.         - Format for time reporting
//  832.         - Indicate version of AcePC
//  836.         - Warn if any/some recommended rules are disabled
//  852.    6)  Functions
//  855.         - function integer clogb2 (input integer n)
//  865.         - function bit [63:0] min_tx_address(input bit[63:0] address_, 
//  904.         - function bit [63:0] max_tx_address(input bit[63:0] address_, 
//  941.         - function bit overlapping(input bit[63:0] min_address1_, 
//  977.            - AwAddrIncr
//  985.    7)  SnoopInfo CAM
// 1389.    8)  ARInfo CAM
// 1653.    9)  AWInfo CAM
// 2112.    10) Barrier Cams
// 2412.    11) DVM Tracking
// 2597.    12) Exclusive sequence checks
// 2601.         - ACE_ERRM_XSTORE_IN_XSEQ_PROP1
// 2602.         - ACE_ERRM_XSTORE_IN_XSEQ_PROP2
// 2654.    13) Intertransaction status 
// 2901.    14) Snoop Hazard Checks
// 2904.         - ACE_ERRS_RRESP_IN_SNOOP
// 2905.         - ACE_REC_SW_RRESP_IN_SNOOP
// 2983.         - ACE_ERRS_AC_IN_RRESP
// 2984.         - ACE_REC_SW_AC_IN_RRESP
// 3052.         - ACE_REC_SW_BRESP_IN_SNOOP
// 3053.         - ACE_ERRS_BRESP_IN_SNOOP
// 3132.         - ACE_ERRS_AC_IN_BRESP
// 3133.         - ACE_REC_SW_AC_IN_BRESP
// 3199.         - ACE_ERRM_CRRESP_IN_WB_WC
// 3271.         - ACE_ERRM_AR_IN_CMAINT
// 3328.         - ACE_ERRM_AW_IN_CMAINT
// 3396.         - ACE_ERRM_CMAINT_IN_READ
// 3451.         - ACE_ERRM_CMAINT_IN_WRITE
// 3517.    15)  DVM Rules
// 3521.         - ACE_ERRM_CRRESP_DVM_ERROR
// 3538.         - ACE_ERRM_CRRESP_DVM
// 3551.         - ACE_ERRM_DVM_CTL
// 3569.         - ACE_ERRS_DVM_COMPLETE_CTL
// 3581.         - ACE_ERRM_DVM_COMPLETE_CTL
// 3593.         - ACE_ERRM_DVM_SYNC
// 3606.         - ACE_ERRS_DVM_COMPLETE
// 3619.         - ACE_ERRM_DVM_COMPLETE
// 3632.         - ACE_ERRM_DVM_TYPES
// 3649.         - ACE_ERRS_DVM_TYPES
// 3666.         - ACE_ERRM_DVM_RESVD_1
// 3678.         - ACE_ERRM_DVM_RESVD_2
// 3690.         - ACE_ERRM_DVM_RESVD_3
// 3703.         - ACE_ERRM_DVM_RESVD_4
// 3717.         - ACE_ERRM_DVM_MULTIPART_ID
// 3730.         - ACE_ERRM_DVM_MULTIPART_SUCCESSIVE
// 3742.         - ACE_ERRS_DVM_MULTIPART_SUCCESSIVE
// 3754.         - ACE_ERRM_DVM_ID
// 3767.         - ACE_ERRS_DVM_RESVD_1
// 3779.         - ACE_ERRS_DVM_RESVD_2
// 3791.         - ACE_ERRS_DVM_RESVD_3
// 3804.         - ACE_ERRS_DVM_RESVD_4
// 3818.         - ACE_ERRM_DVM_TLB_INV
// 3842.         - ACE_ERRS_DVM_TLB_INV
// 3866.         - ACE_ERRM_DVM_BP_INV
// 3881.         - ACE_ERRS_DVM_BP_INV
// 3896.         - ACE_ERRM_DVM_PHY_INV
// 3915.         - ACE_ERRS_DVM_PHY_INV
// 3933.         - ACE_ERRM_DVM_VIR_INV
// 3950.         - ACE_ERRS_DVM_VIR_INV
// 3968.         - ACE_ERRS_DVM_MULTIPART_RRESP
// 3981.         - ACE_ERRM_DVM_MULTIPART_CRRESP
// 3994.         - ACE_ERRS_RRESP_DVM_ERROR
// 4007.         - ACE_ERRS_RRESP_DVM
// 4020. 
// 4021.    20)  ACE Rules: Write Address Channel (*_AW*)
// 4025.       1) Functional Rules
// 4030.         - ACE_ERRM_AWBURST
// 4043.         - ACE_ERRM_AWADDR_BOUNDARY
// 4068.         - ACE_ERRM_AWVALID_RESET
// 4082.         - ACE_ERRM_AWCACHE_DEVICE
// 4094.         - ACE_ERRM_AWCACHE_SYSTEM
// 4106.         - ACE_ERRM_AWSNOOP
// 4124.         - ACE_ERRM_AW_BLOCK_1
// 4139.         - ACE_ERRM_AW_BLOCK_2
// 4154.         - ACE_ERRM_AW_FULL_LINE
// 4170.         - ACE_ERRM_AW_SHAREABLE_ALIGN_INCR
// 4186.         - ACE_ERRM_AW_SHAREABLE_ALIGN_WRAP
// 4202.         - ACE_ERRM_AW_SHAREABLE_LOCK
// 4215.         - ACE_ERRM_AW_SHAREABLE_CTL
// 4236.         - ACE_ERRM_AW_DOMAIN_1
// 4250.         - ACE_ERRM_AW_DOMAIN_2
// 4266.         - ACE_ERRM_WB_WC_CACHE_LINE_BOUNDARY_INCR
// 4282.         - ACE_ERRM_WB_WC_CACHE_LINE_BOUNDARY_WRAP
// 4299.         - ACE_ERRM_AWLEN_WRAP
// 4314.         - ACE_ERRM_W_R_HAZARD
// 4361.         - ACE_ERRM_W_W_HAZARD
// 4409.       2) Handshake Rules
// 4413.         - ACE_ERRM_AWVALID_STABLE
// 4427.         - ACE_ERRM_AWDOMAIN_STABLE
// 4440.         - ACE_ERRM_AWSNOOP_STABLE
// 4453.         - ACE_ERRM_AWBAR_STABLE
// 4466.         - ACE_ERRM_AWADDR_STABLE
// 4479.         - ACE_ERRM_AWBURST_STABLE
// 4492.         - ACE_ERRM_AWCACHE_STABLE
// 4505.         - ACE_ERRM_AWID_STABLE
// 4518.         - ACE_ERRM_AWLEN_STABLE
// 4531.         - ACE_ERRM_AWLOCK_STABLE
// 4544.         - ACE_ERRM_AWPROT_STABLE
// 4557.         - ACE_ERRM_AWSIZE_STABLE
// 4570.         - ACE_ERRM_AWQOS_STABLE
// 4583.         - ACE_ERRM_AWREGION_STABLE
// 4596.         - ACE_ERRM_AWUSER_STABLE
// 4609.         - ACE_RECS_AWREADY_MAX_WAIT
// 4624.       3) X-Propagation Rules
// 4629.         - ACE_ERRM_AWVALID_X
// 4642.         - ACE_ERRM_AWDOMAIN_X
// 4652.         - ACE_ERRM_AWBAR_X
// 4662.         - ACE_ERRM_AWSNOOP_X
// 4672.         - ACE_ERRM_AWADDR_X
// 4683.         - ACE_ERRM_AWBURST_X
// 4694.         - ACE_ERRM_AWCACHE_X
// 4705.         - ACE_ERRM_AWID_X
// 4716.         - ACE_ERRM_AWLEN_X
// 4727.         - ACE_ERRM_AWLOCK_X
// 4738.         - ACE_ERRM_AWPROT_X
// 4749.         - ACE_ERRM_AWSIZE_X
// 4760.         - ACE_ERRM_AWQOS_X
// 4771.         - ACE_ERRM_AWREGION_X
// 4782.         - ACE_ERRM_AWUSER_X
// 4794. 
// 4795.    16)  ACE Rules: Write Data Channel (*_W*)
// 4799.         - ACE_ERRM_WLU_STRB
// 4813.       1) Functional Rules
// 4817.       2) Handshake Rules
// 4822.       3) X-Propagation Rules
// 4827. 
// 4828.    17)  ACE Rules: Write Response Channel (*_B*) 
// 4832.       1) Functional Rules
// 4836.         - ACE_ERRS_BVALID_RESET
// 4848.         - ACE_ERRS_BRESP_WNS_EXOKAY
// 4861.         - ACE_ERRS_BRESP_BAR
// 4874.         - ACE_ERRS_BRESP_AW_WLAST
// 4886.       2) Handshake Rules
// 4890.         - ACE_ERRS_BVALID_STABLE
// 4904.         - ACE_ERRS_BID_STABLE
// 4917.         - ACE_ERRS_BRESP_STABLE
// 4930.         - ACE_ERRS_BUSER_STABLE
// 4943.         - ACE_RECM_BREADY_MAX_WAIT 
// 4958.       3) X-Propagation Rules
// 4964.         - ACE_ERRS_BID_X
// 4977.         - ACE_ERRS_BRESP_X
// 4991.         - ACE_ERRM_WACK_X
// 5002.         - ACE_ERRS_BVALID_X
// 5013.         - ACE_ERRS_BUSER_X
// 5025. 
// 5026.    18)  ACE Rules: Read Address Channel (*_AR*)
// 5030.       1) Functional Rules
// 5034.         - ACE_ERRM_ARSNOOP
// 5059.         - ACE_ERRM_ARCACHE_DEVICE
// 5072.         - ACE_ERRM_ARCACHE_SYSTEM
// 5084.         - ACE_ERRM_ARLEN_WRAP
// 5099.         - ACE_ERRM_AR_FULL_LINE
// 5119.         - ACE_ERRM_AR_SHAREABLE_LOCK
// 5137.         - ACE_ERRM_AR_SHAREABLE_CTL
// 5160.         - ACE_ERRM_AR_DOMAIN_2
// 5177.         - ACE_ERRM_AR_DOMAIN_1
// 5191.         - ACE_ERRM_AR_SHAREABLE_ALIGN_INCR
// 5213.         - ACE_ERRM_R_W_HAZARD
// 5277.       2) Handshake Rules
// 5281.         - ACE_ERRM_ARDOMAIN_STABLE
// 5294.         - ACE_ERRM_ARLEN_STABLE
// 5309.         - ACE_ERRM_ARSNOOP_STABLE
// 5322.         - ACE_ERRM_ARBAR_STABLE
// 5335.         - ACE_ERRM_ARLOCK_STABLE
// 5352.       3) X-Propagation Rules
// 5358.         - ACE_ERRM_ARDOMAIN_X
// 5369.         - ACE_ERRM_ARBAR_X
// 5380.         - ACE_ERRM_ARSNOOP_X
// 5391.         - ACE_ERRM_ARLEN_X
// 5401.         - ACE_ERRM_ARLOCK_X
// 5418. 
// 5419.    19)  ACE Rules: Read Data and Response Channel (*_R*)
// 5422.       1) Functional Rules
// 5425.         - ACE_ERRS_RRESP_SHARED
// 5445.         - ACE_ERRS_RRESP_DIRTY
// 5461.         - ACE_ERRS_RRESP_RNSD
// 5474.         - ACE_ERRS_RRESP_ACE_EXOKAY
// 5492.         - ACE_ERRS_RRESP_BAR
// 5505.         - ACE_ERRS_DVM_LAST
// 5519.         - ACE_ERRS_R_BARRIER_LAST
// 5533.         - ACE_ERRS_RDATALESS
// 5553.         - ACE_ERRS_RRESP_CONST
// 5568.       2) Handshake Rules
// 5572.         - ACE_ERRS_RRESP_STABLE
// 5585.       3) X-Propagation Rules
// 5591.         - ACE_ERRS_RRESP_X
// 5602.         - ACE_ERRM_RACK_X
// 5615. 
// 5616.    21)  ACE Rules: Snoop Address Channel (*_AC*)
// 5621.       1) Functional Rules
// 5625.         - ACE_ERRS_AC_ALIGN
// 5638.         - ACE_ERRS_ACSNOOP
// 5662.       2) Handshake Rules
// 5666.         - ACE_ERRS_ACVALID_RESET
// 5679.         - ACE_RECM_ACREADY_MAX_WAIT
// 5694.         - ACE_ERRS_ACVALID_STABLE
// 5707.         - ACE_ERRS_ACADDR_STABLE
// 5720.         - ACE_ERRS_ACSNOOP_STABLE
// 5733.         - ACE_ERRS_ACPROT_STABLE
// 5746.       3) X-Propagation Rules
// 5751.         - ACE_ERRS_ACVALID_X
// 5762.         - ACE_ERRM_ACREADY_X
// 5773.         - ACE_ERRS_ACADDR_X
// 5784.         - ACE_ERRS_ACPROT_X
// 5795.         - ACE_ERRS_ACSNOOP_X
// 5807. 
// 5808.    22)  ACE Rules: Snoop Response Channel (*_CR*)
// 5813.       1) Functional Rules
// 5817.         - ACE_ERRM_CR_ORDER
// 5834.         - ACE_ERRM_CRRESP_DIRTY
// 5849.         - ACE_ERRM_CRRESP_SHARED
// 5867.       2) Handshake Rules
// 5871.         - ACE_ERRM_CRVALID_RESET
// 5884.         - ACE_ERRM_CRVALID_STABLE
// 5897.         - ACE_ERRM_CRRESP_STABLE
// 5910.         - ACE_RECS_CRREADY_MAX_WAIT
// 5925.       3) X-Propagation Rules
// 5931.         - ACE_ERRM_CRVALID_X
// 5942.         - ACE_ERRS_CRREADY_X
// 5953.         - ACE_ERRM_CRRESP_X
// 5966. 
// 5967.    23)  ACE Rules: Snoop DATA Channel (*_CD*)
// 5971.       1) Functional Rules
// 5975.         - ACE_ERRM_CDDATA_NUM_PROP1
// 5988.         - ACE_ERRM_CDDATA_NUM_PROP2
// 6001.         - ACE_ERRM_CD_ORDER_PROP1
// 6016.         - ACE_ERRM_CD_ORDER_PROP2
// 6028.         - ACE_ERRM_CD_ORDER_PROP3
// 6039.         - ACE_ERRM_CD_ORDER_PROP4
// 6050.         - ACE_ERRM_CD_ORDER_PROP5
// 6064.         - ACE_ERRM_CD_ORDER_PROP6
// 6080.       2) Handshake Rules
// 6084.         - ACE_ERRM_CDVALID_RESET
// 6097.         - ACE_ERRM_CDVALID_STABLE
// 6110.         - ACE_ERRM_CDDATA_STABLE
// 6123.         - ACE_ERRM_CDLAST_STABLE
// 6136.         - ACE_RECS_CDREADY_MAX_WAIT
// 6150.       3) X-Propagation Rules
// 6155.         - ACE_ERRM_CDVALID_X
// 6166.         - ACE_ERRS_CDREADY_X
// 6177.         - ACE_ERRM_CDLAST_X
// 6188.         - ACE_ERRM_CDDATA_X
// 6200.    24) Snoop Cam internal rules
// 6203.         - ACE_AUX_MAXCBURSTS
// 6213.         - ACE_AUX_ACCAM_OVERFLOW
// 6226.         - ACE_AUX_ACCAM_UNDERFLOW
// 6238.    25) Rack functionality
// 6254.         - ACE_ERRM_RACK
// 6267.         - ACE_AUX_ARCAM_OVERFLOW
// 6281.         - ACE_AUX_ARCAM_UNDERFLOW
// 6294.         - ACE_ERRM_AR_BARRIER_CTL
// 6312.         - ACE_ERRM_AW_BARRIER_CTL
// 6330.         - ACE_ERRM_R_W_BARRIER_CTL_PROP1
// 6346.         - ACE_ERRM_R_W_BARRIER_CTL_PROP2
// 6362.         - ACE_ERRM_R_W_BARRIER_CTL_PROP3
// 6378.         - ACE_ERRM_BARRIER_R_NUM
// 6390.         - ACE_ERRM_BARRIER_W_NUM
// 6402.         - ACE_ERRM_AR_BARRIER_ID
// 6416.         - ACE_ERRM_AW_BARRIER_ID
// 6430.         - ACE_ERRM_AR_NORMAL_ID
// 6444.         - ACE_ERRM_AW_NORMAL_ID
// 6459.    26) Wack functionality
// 6475.         - ACE_ERRM_WACK
// 6489.         - ACE_AUX_AWCAM_OVERFLOW_PROP1
// 6504.         - ACE_AUX_AWCAM_OVERFLOW_PROP2
// 6519.         - ACE_AUX_AWCAM_OVERFLOW_PROP3
// 6535.         - ACE_AUX_AWCAM_UNDERFLOW
// 6547.    27) EOS checks
// 6554.         - ACE_ERRM_R_W_BARRIER_EOS 
// 6563.         - ACE_ERRM_RACK_EOS 
// 6572.         - ACE_ERRM_WACK_EOS 
// 6582.         - ACE_ERRM_AC_EOS 
// 6591.         - ACE_ERR_W_EOS
// 6602.    28) Cache Line size Checks
// 6605.         - ACE_AUX_CD_DATA_WIDTH
// 6620.         - ACE_AUX_CACHE_LINE_SIZE
// 6637.         - ACE_AUX_CACHE_DATA_WIDTH32
// 6648.         - ACE_AUX_CACHE_DATA_WIDTH64
// 6659.         - ACE_AUX_CACHE_DATA_WIDTH128;
// 6670.         - ACE_AUX_CACHE_DATA_WIDTH256;
// 6681.         - ACE_AUX_CACHE_DATA_WIDTH512;
// 6692.         - ACE_AUX_CACHE_DATA_WIDTH1024;
// 6703.    29) Instantiate the Axi4PC to check AXI4 channel rules
// 6707.        - Assignments to the Axi4PC
// 6803.    30) Clear Verilog Defines
// 6816.    31) End of module
// 6826. 
// 6827.  End of File
//----------------------------------------------------------------------------


`ifndef ACEPC_OFF


//------------------------------------------------------------------------------
// ACE Standard Defines
//------------------------------------------------------------------------------

`ifndef AXI4PC_ACE
  `include "Axi4PC_ace.sv"
`endif

`ifndef ACEPC_ACE_MESSAGES
  `include "AcePC_message_defs.v"
`endif

`ifndef ACEPC_TYPES
  `include "AcePC_defs.v"
`endif

`ifndef ARM_AMBA4_PC_MSG_ERR
  `define ARM_AMBA4_PC_MSG_ERR $error
`endif

`ifndef ARM_AMBA4_PC_MSG_WARN
  `define ARM_AMBA4_PC_MSG_WARN $warning
`endif

//------------------------------------------------------------------------------
// INDEX: Module: AcePC
//------------------------------------------------------------------------------
`ifndef ACEPC
module AcePC
  (
   // Global Signals
   ACLK,
   ARESETn,

   // Write Address Channel
   AWID,
   AWADDR,
   AWLEN,
   AWSIZE,
   AWBURST,
   AWLOCK,
   AWCACHE,
   AWSNOOP,
   AWPROT,
   AWUSER,
   AWQOS,
   AWBAR,
   AWDOMAIN,
   AWREGION,
   AWVALID,
   AWREADY,

   // Write Channel
   WDATA,
   WSTRB,
   WUSER,
   WLAST,
   WVALID,
   WREADY,

   // Write Response Channel
   BID,
   BRESP,
   BUSER,
   BVALID,
   BREADY,
   
   WACK,

   // Read Address Channel
   ARID,
   ARADDR,
   ARREGION,
   ARLEN,
   ARSIZE,
   ARBURST,
   ARLOCK,
   ARCACHE,
   ARSNOOP,
   ARPROT,
   ARUSER,
   ARQOS,
   ARBAR,
   ARDOMAIN,
   ARVALID,
   ARREADY,

   //  Read Channel
   RID,
   RLAST,
   RDATA,
   RRESP,
   RUSER,
   RVALID,
   RREADY,

   RACK,
   
   // Snoop Address Channel
   ACADDR,
   ACPROT,
   ACSNOOP,
   ACVALID,
   ACREADY,
   
   // Snoop Response Channel
   CRRESP,
   CRVALID,
   CRREADY,
   
   // Snoop Data Channel
   CDVALID,
   CDREADY,
   CDLAST,
   CDDATA,
    
  // Low Power Interface
  CACTIVE,
  CSYSREQ,
  CSYSACK 
   );
  
  `define ACEPC
//------------------------------------------------------------------------------
// INDEX:   1) Parameters
//------------------------------------------------------------------------------
 
  // =====
  // INDEX:        - Configurable (user can set)
  // =====
  // Parameters below can be set by the user.
  
  
  parameter ADDR_WIDTH = 64;
 
  // Set DATA_WIDTH to the data-bus width required
  parameter DATA_WIDTH = 64;         // data bus width, default = 64-bit

  // Set DATA_WIDTH to the data-bus width required
  parameter CD_DATA_WIDTH = DATA_WIDTH;         // data bus width, default = 64-bit


  // Select the number of channel ID bits required for read channel
  parameter RID_WIDTH = 4;          // (AR|R)ID width
 
  // Select the number of channel ID bits required for write channel
  parameter WID_WIDTH = 4;          // (AW|W|B)ID width 

  // Size of CAMs for storing outstanding reads, this should match or
  // exceed the number of reads into the slave interface
  parameter MAXRBURSTS = 16;

  // Size of CAMs for storing outstanding writes, this should match or
  // exceed the number of writes into the slave interface
  parameter MAXWBURSTS = 16;

  // Select the size of the USER buses, default = 32-bit
  parameter AWUSER_WIDTH = 32; // width of the user AW sideband field
  parameter WUSER_WIDTH  = 32; // width of the user W  sideband field
  parameter BUSER_WIDTH  = 32; // width of the user B  sideband field
  parameter ARUSER_WIDTH = 32; // width of the user AR sideband field
  parameter RUSER_WIDTH  = 32; // width of the user R  sideband field

  // Set the protocol - used to disable some AXI4 checks for ACE
  parameter PROTOCOL = `AXI4PC_AMBA_ACE;

  // Size of CAMs for storing outstanding snoops, this should match or
  // exceed the number of outstanding snoops into the master interface
  parameter MAXCBURSTS = 64;

  // Maximum number of cycles between VALID -> READY high before a warning is
  // generated
  parameter MAXWAITS = 16;

  // Recommended Rules Enable
  // enable/disable reporting of all  _REC_SW_* rules
  parameter RecommendOn_SW   = 1'b1;   
  // enable/disable reporting of all  _REC*_* rules
  parameter RecommendOn   = 1'b1;   
  // enable/disable reporting of just _REC*_MAX_WAIT rules
  parameter RecMaxWaitOn  = 1'b1;   

  //Exclusive check ACE_ERRM_XSTORE_IN_XSEQ can only be done for interfaces
  //with a single exclusive thread interface.
  parameter SINGLE_EXCL = 1'b1;


  // set the cache line size in bytes
  parameter CACHE_LINE_SIZE_BYTES = 64;        


  // Set EXMON_WIDTH to the exclusive access monitor width required
  parameter EXMON_WIDTH = 4;        // exclusive access width, default = 4-bit

  //set the max number of barriers for an ACELite interface
  parameter MAX_BARRIERS_LITE = 256;


  // =====
  // INDEX:        - Calculated (user should not override)
  // =====
  // Do not override the following parameters: they must be calculated exactly
  // as shown below
  localparam ADDR_MAX    = ADDR_WIDTH-1; // ADDR max index
  localparam DATA_MAX    = DATA_WIDTH-1; // data max index
  localparam CD_DATA_MAX = CD_DATA_WIDTH-1; // data max index
  localparam STRB_WIDTH  = DATA_WIDTH/8; // WSTRB width
  localparam STRB_MAX    = STRB_WIDTH-1; // WSTRB max index
  localparam STRB_1      = {{STRB_MAX{1'b0}}, 1'b1};  // value 1 in strobe width
  localparam ID_MAX_R    = RID_WIDTH? RID_WIDTH-1:0;    // ID max index
  localparam ID_MAX_W    = WID_WIDTH? WID_WIDTH-1:0;    // ID max index

  localparam ID_MAX      =  ID_MAX_W > ID_MAX_R ? ID_MAX_W : ID_MAX_R; //greater of ID_MAX_W & ID_MAX_W 
  localparam CACHE_LINE_AxLEN = CACHE_LINE_SIZE_BYTES/(DATA_WIDTH/8) -1;
  localparam CACHE_LINE_AxLEN_CD = CACHE_LINE_SIZE_BYTES/(CD_DATA_WIDTH/8) -1;
  localparam CACHE_LINE_MAXBIT = (CACHE_LINE_SIZE_BYTES == 16  ? 4 :
                            (CACHE_LINE_SIZE_BYTES == 32   ? 5 :
                            (CACHE_LINE_SIZE_BYTES == 64   ? 6 :
                            (CACHE_LINE_SIZE_BYTES == 128  ? 7 :
                            (CACHE_LINE_SIZE_BYTES == 256  ? 8 :
                            (CACHE_LINE_SIZE_BYTES == 512  ? 9 :
                            (CACHE_LINE_SIZE_BYTES == 1024 ? 10 :
                                                           11))))))) ; //2048
  localparam CACHE_LINE_MASK = (CACHE_LINE_SIZE_BYTES == 16  ? 11'b11111110000 :
                          (CACHE_LINE_SIZE_BYTES == 32   ? 11'b11111100000 :
                          (CACHE_LINE_SIZE_BYTES == 64   ? 11'b11111000000 :
                          (CACHE_LINE_SIZE_BYTES == 128  ? 11'b11110000000 :
                          (CACHE_LINE_SIZE_BYTES == 256  ? 11'b11100000000 :
                          (CACHE_LINE_SIZE_BYTES == 512  ? 11'b11000000000 :
                          (CACHE_LINE_SIZE_BYTES == 1024 ? 11'b10000000000 :
                                                           11'b0000000000))))))) ; //2048

  localparam SIZEMASK = (DATA_WIDTH == 32   ? 7'b1111100 :
                         (DATA_WIDTH == 64   ? 7'b1111000 :
                         (DATA_WIDTH == 128  ? 7'b1110000 :
                         (DATA_WIDTH == 256  ? 7'b1100000 :
                         (DATA_WIDTH == 512  ? 7'b1000000 :
                                7'b0000000)))));

  localparam SIZEMASK_CD = (CD_DATA_WIDTH == 32   ? 7'b1111100 :
                         (CD_DATA_WIDTH == 64   ? 7'b1111000 :
                         (CD_DATA_WIDTH == 128  ? 7'b1110000 :
                         (CD_DATA_WIDTH == 256  ? 7'b1100000 :
                         (CD_DATA_WIDTH == 512  ? 7'b1000000 :
                                7'b0000000)))));

  localparam CACHE_LINE_AxSIZE = DATA_WIDTH == 32 ? `AXI4PC_ASIZE_32 : 
                          (DATA_WIDTH == 64 ? `AXI4PC_ASIZE_64 : 
                          (DATA_WIDTH == 128 ? `AXI4PC_ASIZE_128 :
                          (DATA_WIDTH == 256 ? `AXI4PC_ASIZE_256 : 
                          (DATA_WIDTH == 512 ? `AXI4PC_ASIZE_512 : `AXI4PC_ASIZE_1024)))); 

  localparam CACHE_LINE_AxSIZE_CD = CD_DATA_WIDTH == 32 ? `AXI4PC_ASIZE_32 : 
                          (CD_DATA_WIDTH == 64 ? `AXI4PC_ASIZE_64 : 
                          (CD_DATA_WIDTH == 128 ? `AXI4PC_ASIZE_128 :
                          (CD_DATA_WIDTH == 256 ? `AXI4PC_ASIZE_256 : 
                          (CD_DATA_WIDTH == 512 ? `AXI4PC_ASIZE_512 : `AXI4PC_ASIZE_1024)))); 
  localparam AWUSER_MAX = AWUSER_WIDTH ? AWUSER_WIDTH-1:0; // AWUSER max index
  localparam WUSER_MAX  = WUSER_WIDTH ? WUSER_WIDTH-1:0;   // WUSER  max index
  localparam BUSER_MAX  = BUSER_WIDTH ? BUSER_WIDTH-1:0;   // BUSER  max index
  localparam ARUSER_MAX = ARUSER_WIDTH ? ARUSER_WIDTH-1:0; // ARUSER max index
  localparam RUSER_MAX  = RUSER_WIDTH ? RUSER_WIDTH-1:0;   // RUSER  max index

  // Number of bits required to represent 0:MS
  localparam AWID_OS_BITS = MAXWBURSTS > 0 ? clogb2(MAXWBURSTS) : 1;


  
//------------------------------------------------------------------------------
// INDEX:   2) Inputs (no outputs)
//------------------------------------------------------------------------------
   
  // =====
  // INDEX:        - Global Signals
  // =====
  input wire                ACLK;        // AXI Clock
  input wire                ARESETn;     // AXI Reset

  // =====
  // INDEX:        - Write Address Channel
  // =====
  input wire     [ID_MAX_W:0] AWID;
  input wire   [ADDR_MAX:0] AWADDR;
  input wire          [7:0] AWLEN;
  input wire          [2:0] AWSIZE;
  input wire          [1:0] AWBURST;
  input wire                AWLOCK;
  input wire          [3:0] AWCACHE;
  input wire          [2:0] AWSNOOP;
  input wire          [2:0] AWPROT;
  input wire [AWUSER_MAX:0] AWUSER;
  input wire          [3:0] AWQOS;
  input wire          [1:0] AWBAR;
  input wire          [1:0] AWDOMAIN;
  input wire          [3:0] AWREGION;
  input wire                AWVALID;
  input wire                AWREADY;


  // =====
  // INDEX:        - Write Data Channel
  // =====
  input wire   [DATA_MAX:0] WDATA;
  input wire   [STRB_MAX:0] WSTRB;
  input wire  [WUSER_MAX:0] WUSER;
  input wire                WLAST;
  input wire                WVALID;
  input wire                WREADY;


  // =====
  // INDEX:        - Write Response Channel
  // =====
  input wire     [ID_MAX_W:0] BID;
  input wire          [1:0] BRESP;
  input wire  [BUSER_MAX:0] BUSER;
  input wire                BVALID;
  input wire                BREADY;
  
  input wire                WACK;


  // =====
  // INDEX:        - Read Address Channel
  // =====
  input wire     [ID_MAX_R:0] ARID;
  input wire   [ADDR_MAX:0] ARADDR;
  input wire          [7:0] ARLEN;
  input wire          [2:0] ARSIZE;
  input wire          [1:0] ARBURST;
  input wire                ARLOCK;
  input wire          [3:0] ARCACHE;
  input wire          [3:0] ARSNOOP;
  input wire          [2:0] ARPROT;
  input wire [ARUSER_MAX:0] ARUSER;
  input wire          [3:0] ARQOS;
  input wire          [1:0] ARBAR;
  input wire          [1:0] ARDOMAIN;
  input wire          [3:0] ARREGION;  
  input wire                ARVALID;
  input wire                ARREADY;


  // =====
  // INDEX:        - Read Data Channel
  // =====
  input wire     [ID_MAX_R:0] RID;
  input wire                RLAST;
  input wire   [DATA_MAX:0] RDATA;
  input wire          [3:0] RRESP;
  input wire  [RUSER_MAX:0] RUSER;
  input wire                RVALID;
  input wire                RREADY;
  
  input wire                RACK;


  // =====
  // INDEX:        - Snoop Address Channel
  // =====
  input wire   [ADDR_MAX:0] ACADDR;
  input wire          [2:0] ACPROT;
  input wire          [3:0] ACSNOOP;
  input wire                ACVALID;
  input wire                ACREADY;


  // INDEX:        - Snoop Response Channel
  // =====
  input wire          [4:0] CRRESP;
  input wire                CRVALID;
  input wire                CRREADY;


  // INDEX:        - Snoop Data Channel
  // =====
  input wire                CDVALID;
  input wire                CDREADY;
  input wire                CDLAST;
  input wire   [CD_DATA_MAX:0] CDDATA;
  
  // INDEX:        - Low Power Interface
  // =====
  input wire                CACTIVE;
  input wire                CSYSREQ;
  input wire                CSYSACK;

  
//------------------------------------------------------------------------------
// INDEX:   3) Wire and Reg Declarations
//------------------------------------------------------------------------------


  wire       AWVALID_Axi4PC;
  wire       BVALID_Axi4PC;
  wire[7:0]  ARLEN_Axi4PC;
  wire       ARLOCK_Axi4PC;
  wire[1:0]  RRESP_Axi4PC;
  wire[DATA_MAX:0] RDATA_Axi4PC;

  wire       R_BAR_RESP; //indicates a read barrier response
  wire       B_BAR_RESP; //indicates a read barrier response
  wire       B_EVICT_RESP; //indicates a write evict response

  reg[ADDR_MAX:0] AwAddrIncr;

  reg        ARID_RBARInfo_isBAR;//The valid ARID exists as a barrier in RBARInfo
  reg        ARID_WBARInfo_isBAR;//The valid ARID exists as a barrier in WBARInfo
  reg        ARID_AWID_isBAR;//The valid ARID exists as a barrier currently on AWID
  wire       ARIDisBAR;
  reg        ARID_ARInfo_isNORMAL;//The valid ARID exists as a normal transaction in ARInfo
  reg        ARID_AWInfo_isNORMAL;//The valid ARID exists as a normal transaction in AWInfo
  reg        ARID_AWID_isNORMAL;//The valid ARID exists as a normal transaction currently on AWID
  wire       ARIDisNORMAL;
  reg        AWID_RBARInfo_isBAR;//The valid AWID exists as a barrier in RBARInfo
  reg        AWID_WBARInfo_isBAR;//The valid AWID exists as a barrier in WBARInfo
  reg        AWID_ARID_isBAR;//The valid AWID exists as a barrier currently on ARID
  wire       AWIDisBAR;
  reg        AWID_ARInfo_isNORMAL;//The valid AWID exists as a normal transaction in ARInfo
  reg        AWID_AWInfo_isNORMAL;//The valid AWID exists as a normal transaction in AWInfo
  reg        AWID_ARID_isNORMAL;//The valid AWID exists as a normal transaction currently on ARID
  wire       AWIDisNORMAL;
  reg        ARID_ARInfo_isDVM; //The valid ARID exists as a DVM transaction in ARINFO
  reg        AWID_ARInfo_isDVM; //The valid AWID exists as a DVM transaction in ARINFO
  reg        AWID_ARID_isDVM;   //The valid AWID exists as a DVM transaction currently on ARID
  wire       ARIDisDVM;


  reg       [63:0] min_aw_address;
  reg       [63:0] max_aw_address;
  reg       [63:0] min_ar_address;
  reg       [63:0] max_ar_address;
  reg       [63:0] min_r_address;
  reg       [63:0] max_r_address;
  reg       [63:0] min_b_address;
  reg       [63:0] max_b_address;
  reg       [63:0] min_ac_address;
  reg       [63:0] max_ac_address;
//------------------------------------------------------------------------------
// INDEX:   4) Verilog Defines
//------------------------------------------------------------------------------

  // INDEX:        - Clock and Reset
  // =====
  // Can be overridden by user for a clock enable.
  //
  `ifdef ACE_SVA_CLK
  `else
     `define ACE_SVA_CLK ACLK
  `endif
  //
  `ifdef ACE_SVA_RSTn
  `else
     `define ACE_SVA_RSTn ARESETn
  `endif
  // 
  // AUX: Auxiliary Logic
  `ifdef ACE_AUX_CLK
  `else
     `define ACE_AUX_CLK ACLK
  `endif
  //
  `ifdef ACE_AUX_RSTn
  `else
     `define ACE_AUX_RSTn ARESETn
  `endif
  


//------------------------------------------------------------------------------
// INDEX:   5) Initialize simulation
//------------------------------------------------------------------------------
  initial
    begin

      // INDEX:        - Format for time reporting
      // =====
      // Format for time reporting
      $timeformat(-9, 0, " ns", 0);


      // INDEX:        - Indicate version of AcePC
      // =====
      $display("ACEPC_INFO: Running AcePC version BP065-BU-01000-r0p1-00rel0 (SVA implementation)");

      // INDEX:        - Warn if any/some recommended rules are disabled
      // =====
      if (~RecommendOn_SW)
        // All _REC_SW rules disabled
        $display("ACE_WARN: All recommended ACE software rules have been disabled by the RecommendOn_SW parameter");
      if (~RecommendOn)
        // All _REC*_* rules disabled
        $display("ACE_WARN: All recommended ACE rules have been disabled by the RecommendOn parameter");
      else if (~RecMaxWaitOn)
        // Just _REC*_MAX_WAIT rules disabled
        $display("ACE_WARN: Five recommended MAX_WAIT rules have been disabled by the RecMaxWaitOn parameter");


    end
 
//------------------------------------------------------------------------------
// INDEX:   6)  Functions
//------------------------------------------------------------------------------ 
//-----------------------------------------------------------------------------
// INDEX:        - function integer clogb2 (input integer n)
// function to determine ceil of log2(n)
//-----------------------------------------------------------------------------
  function integer clogb2 (input integer n);
    begin
      for (clogb2=0; n>0; clogb2=clogb2+1)
        n = n >> 1;
    end
  endfunction
//-----------------------------------------------------------------------------
// INDEX:        - function bit [63:0] min_tx_address(input bit[63:0] address_, 
//                                          input bit[1:0] burst_,
//                                          input bit[3:0] len_, 
//                                          input bit[2:0] size_);
// function to determine minimum address boundary of a burst
//-----------------------------------------------------------------------------
  function bit [63:0] min_tx_address(input bit[63:0] addr_, 
                                     input bit[1:0] burst_,
                                     input bit[3:0] len_, 
                                     input bit[2:0] size_);
    int transaction_size_;
    bit [63:0] address_;
    bit [10:0] wrap_addr_mask_;
    begin
      if (burst_ != `AXI4PC_ABURST_WRAP) 
      begin
        address_ = addr_;
      end
      else  
      begin
        transaction_size_ = (1 << size_) * (len_ + 1);
        wrap_addr_mask_ = (transaction_size_ == 1   ? 11'b11111111111 :
                          (transaction_size_ == 2   ? 11'b11111111110 :
                          (transaction_size_ == 4   ? 11'b11111111100 :
                          (transaction_size_ == 8   ? 11'b11111111000 :
                          (transaction_size_ == 16  ? 11'b11111110000 :
                          (transaction_size_ == 32  ? 11'b11111100000 :
                          (transaction_size_ == 64  ? 11'b11111000000 :
                          (transaction_size_ == 128 ? 11'b11110000000 :
                          (transaction_size_ == 256 ? 11'b11100000000 :
                          (transaction_size_ == 512 ? 11'b11000000000 :
                          (transaction_size_ == 1024 ? 11'b10000000000 :
                                                           11'b0000000000))))))))))) ; //2048
        address_ =  {addr_[63:11], (addr_[10:0] & wrap_addr_mask_)};
      end
      return address_;
    end
  endfunction
//-----------------------------------------------------------------------------
// INDEX:        - function bit [63:0] max_tx_address(input bit[63:0] address_, 
//                                          input bit[1:0] burst_,
//                                          input bit[3:0] len_, 
//                                          input bit[2:0] size_);
// function to determine maximum address boundary of a burst
//-----------------------------------------------------------------------------
  function bit [63:0] max_tx_address(input bit[63:0] addr_, 
                                     input bit[1:0] burst_,
                                     input bit[3:0] len_, 
                                     input bit[2:0] size_);
    int beat_size_;
    int transaction_size_;
    bit [63:0] aligned_address_;
    bit [10:0] addr_mask_;
    beat_size_ = (1 << size_);
    transaction_size_ = (1 << size_) * (len_ + 1);
    addr_mask_ =     (beat_size_ == 1   ? 11'b11111111111 :
                     (beat_size_ == 2   ? 11'b11111111110 :
                     (beat_size_ == 4   ? 11'b11111111100 :
                     (beat_size_ == 8   ? 11'b11111111000 :
                     (beat_size_ == 16  ? 11'b11111110000 :
                     (beat_size_ == 32  ? 11'b11111100000 :
                     (beat_size_ == 64  ? 11'b11111000000 :
                     (beat_size_ == 128 ? 11'b11110000000 :
                     (beat_size_ == 256 ? 11'b11100000000 :
                     (beat_size_ == 512 ? 11'b11000000000 :
                     (beat_size_ == 1024 ? 11'b10000000000 :
                                                      11'b0000000000))))))))))) ; //2048
    aligned_address_ =  {addr_[63:11], (addr_[10:0] & addr_mask_)};
    begin
    return
      (burst_ == `AXI4PC_ABURST_WRAP) ? (min_tx_address(addr_,burst_,len_,size_) + transaction_size_ -1) :
      (burst_ == `AXI4PC_ABURST_INCR) ? (aligned_address_  + transaction_size_ -1) :
      (burst_ == `AXI4PC_ABURST_FIXED) ? (aligned_address_ + beat_size_ -1) : 64'hx;
    end
  endfunction
//-----------------------------------------------------------------
// INDEX:        - function bit overlapping(input bit[63:0] min_address1_, 
//                                          input bit[63:0] max_address1_,
//                                          input bit[63:0] min_address2_,
//                                          input bit[63:0] max_address2_)
// function to determine if two regions overlap
//-----------------------------------------------------------------------------
  function automatic bit overlapping(input bit[63:0] min_address1_, 
                                          input bit[63:0] max_address1_,
                                          input bit[63:0] min_address2_,
                                          input bit[63:0] max_address2_);
    bit  rtn_;                                    
    begin
      assert(max_address1_ >= min_address1_) ;
      assert(max_address2_ >= min_address2_) ;
      rtn_ = 1'b0;
      if ((min_address1_ >= min_address2_) && (min_address1_  <= max_address2_))
      begin
        rtn_ = 1'b1;
      end
      if ((max_address1_ >= min_address2_) && (max_address1_  <= max_address2_ ))
      begin
        rtn_ = 1'b1;
      end
      if ((min_address2_ >= min_address1_) && (min_address2_  <= max_address1_))
      begin
        rtn_ = 1'b1;
      end
      if ((max_address2_ >= min_address1_) && (max_address2_  <= max_address1_ ))
      begin
        rtn_ = 1'b1;
      end
      return rtn_;
    end
  endfunction
  
  // =====
  // INDEX:           - AwAddrIncr
  // =====
  always @(AWSIZE or AWLEN or AWADDR)
  begin : p_WAddrIncrComb
    AwAddrIncr = AWADDR + (AWLEN << AWSIZE);  // The final address of the burst
  end

//------------------------------------------------------------------------------
// INDEX:   7)  SnoopInfo CAM
//------------------------------------------------------------------------------ 
// A snoop transaction data is held in ACInfo[ACInfo_index] as soon as ACVALID is
// registered. ACInfo_index is incremented on the AC handshake. 
// The snoop Cam could have two pops in the same cycle if the CR channel
// returns a dataless response and the data channel has a handshake on its
// LAST data.
// A snoop response indicating no data causes the corresponding item to be
// popped. A data snoop will not be popped until the last item of data. For
// this reason, you know that if there are snoop data transactions in the Cam,
// they must be at the lowest indices. By counting the number of snoop data
// transactions (snoop_data_cnt), the oldest transaction that has not seen
// a response can be indexed by snoop_data_cnt + 1
//
  localparam ACADDR_LO          = 0;                  
  localparam ACADDR_HI          = ACADDR_LO + ADDR_MAX;  
  localparam AC_READUNIQUE      = ACADDR_HI + 1; 
  localparam AC_CLEANSHARED     = AC_READUNIQUE + 1; 
  localparam AC_CLEANINVALID    = AC_CLEANSHARED + 1; 
  localparam AC_MAKEINVALID     = AC_CLEANINVALID + 1; 
  localparam AC_DVM             = AC_MAKEINVALID + 1; 
  localparam ACPROT_1           = AC_DVM + 1; 
  localparam AC_DVM_ADDITIONAL  = ACPROT_1 + 1; 
  localparam AC_DVM_SYNC        = AC_DVM_ADDITIONAL + 1; 
  localparam AC_DVM_COMPLETE    = AC_DVM_SYNC + 1; 
  localparam AC_DVM_HINT        = AC_DVM_COMPLETE + 1; 
  localparam AC_DATA            = AC_DVM_HINT + 1; 
  localparam ACINFO_HI          = AC_DATA  + 1; 
  localparam ACDATA_COUNT_HI    = CACHE_LINE_AxLEN_CD == 0 ? 0 : clogb2(CACHE_LINE_AxLEN_CD) -1 ;
  localparam LOG2MAXCBURSTS     = clogb2(MAXCBURSTS);
  
  


  reg        [ACINFO_HI -1 :0] ACInfo [1:MAXCBURSTS];
  reg        [LOG2MAXCBURSTS:0] ACData_prev_AC [1:MAXCBURSTS];
  reg        [LOG2MAXCBURSTS:0] ACInfo_index; //next available location in CAM
  reg        [LOG2MAXCBURSTS:0] ACData_prev_AC_index; //next available location in datacount CAM
  reg        [LOG2MAXCBURSTS:0] AC_nonDVM; // number of outstanding data addresses that can accept data 
  reg        AC_Push; //increment the index
  wire       CR_Pop; //decrement the index
  wire       CR_Pop_valid; 
  wire       CD_Pop_valid;
  wire       CD_Pop; //decrement the index
  wire       CR_Data_Resp;
  wire       ACInfo_pop_on_CR_valid;
  wire       ACInfo_pop_on_CR;
  wire       ACInfo_pop_on_CD_valid;
  wire       ACInfo_pop_on_CD;
  reg        [ACINFO_HI -1:0] ACInfo_tmp;
  reg        [LOG2MAXCBURSTS:0] snoop_dataresp_cnt;
  reg        [1:0]AC_DVM_ADD_CRESP;
  reg        CRVALID_pulse;
  reg        CRVALID_pulse_en;
  reg        CDVALID_first_pulse_en;
  reg        CDVALID_first_pulse;
  reg        CD_ORDER_ERROR;
  reg        [ACDATA_COUNT_HI:0] ACData_count;
  reg        [LOG2MAXCBURSTS:0] CDLAST_count;
  reg        [LOG2MAXCBURSTS:0] ACData_transactions;
  reg        [LOG2MAXCBURSTS:0] AC_leading_data_resps;
  reg        [LOG2MAXCBURSTS:0] AC_leading_data;

  //pop data from ACData_prev_AC if index > 0 and data response on CR
  wire ACData_prev_AC_pop = (AC_leading_data > 0) && (CRVALID_pulse && CRRESP[0]);
  // push data onto ACData_prev_AC only when the data leads the response
  wire ACData_prev_AC_push = (AC_leading_data_resps == 0) && CDVALID_first_pulse && 
                             //not data and resp at the same time
                             !(CRVALID_pulse && CRRESP[0] && (ACData_prev_AC_index == (snoop_dataresp_cnt+1)));
  // decrement ACData_prev_AC on a non data, non dvm crresp
  wire ACData_prev_AC_dec = (ACData_prev_AC_index > 0) && (CRVALID_pulse && !CRRESP[0] && !ACInfo[snoop_dataresp_cnt+1][AC_DVM]);

  assign     AC_Push = ACVALID && ACREADY;
  assign     CR_Pop_valid = CRVALID && !CRRESP[`ACEPC_CRRESP_DATATRANSFER];
  assign     CR_Pop = CR_Pop_valid && CRREADY;
  assign     CR_Data_Resp = CRVALID && CRREADY && CRRESP[`ACEPC_CRRESP_DATATRANSFER];
  assign     ACInfo_pop_on_CR_valid = CRVALID && CRRESP[0] && (CDLAST_count >= 1) ;
  assign     ACInfo_pop_on_CR = ACInfo_pop_on_CR_valid && CRREADY;
  assign     ACInfo_pop_on_CD_valid = CDVALID && CDLAST && ((snoop_dataresp_cnt > 0) || (CRVALID && CRREADY && CRRESP[0]));
  assign     ACInfo_pop_on_CD = ACInfo_pop_on_CD_valid && CDREADY;
  assign     CD_Pop_valid = ACInfo_pop_on_CR_valid || ACInfo_pop_on_CD_valid;
  assign     CD_Pop = ACInfo_pop_on_CR || ACInfo_pop_on_CD;
  assign     min_ac_address = ACVALID ? min_tx_address(ACADDR,`AXI4PC_ABURST_WRAP,CACHE_LINE_AxLEN_CD,CACHE_LINE_AxSIZE_CD) : 64'b0;
  assign     max_ac_address = ACVALID ? max_tx_address(ACADDR,`AXI4PC_ABURST_WRAP,CACHE_LINE_AxLEN_CD,CACHE_LINE_AxSIZE_CD) : 64'b0;
  always_comb
  begin
    if(!`ACE_AUX_RSTn)
    begin
      CRVALID_pulse = 1'b0;
    end 
    else
    begin
      CRVALID_pulse = CRVALID && CRVALID_pulse_en;
    end
  end
  always_comb
  begin
    if(!`ACE_AUX_RSTn)
    begin
      CDVALID_first_pulse = 1'b0;
    end 
    else
    begin
      CDVALID_first_pulse = CDVALID && CDVALID_first_pulse_en;
    end
  end

  always_comb
  begin
    CD_ORDER_ERROR = 1'b0;
    if (ACData_prev_AC_pop)
    begin
      for (int i = 2; i <= MAXCBURSTS; i = i + 1)
      begin
        //go through the CDDATA but if CDVALID_first_pulse it won't be in
        //there yet
        if (i < ACData_prev_AC_index)
        begin
          if (ACData_prev_AC[i] < i) 
          begin
            CD_ORDER_ERROR = 1'b1;
          end
        end
      end
    end
    else if (ACData_prev_AC_dec) 
    begin
      for (int i = 1; i <= MAXCBURSTS; i = i + 1)
      begin
        if (i < ACData_prev_AC_index)
        begin
          if (ACData_prev_AC[i] <= i) 
          begin
            CD_ORDER_ERROR = 1'b1;
          end
        end
      end
    end
  end
  always @(posedge `ACE_AUX_CLK or negedge `ACE_AUX_RSTn)
  begin
    if(!`ACE_AUX_RSTn)
    begin
      AC_leading_data_resps <= '0;
      AC_leading_data <= '0;
    end 
    else
    begin
      if ((AC_leading_data_resps == 0) && AC_leading_data == 0)
      begin
        if (CRVALID_pulse && CRRESP[0] && !CDVALID_first_pulse)
        begin
          AC_leading_data_resps <= AC_leading_data_resps + 1;
        end
        else if (!(CRVALID_pulse && CRRESP[0]) && CDVALID_first_pulse)
        begin
          AC_leading_data <= AC_leading_data + 1;
        end
      end
      else if (|AC_leading_data_resps)
      begin
        AC_leading_data_resps <= AC_leading_data_resps - CDVALID_first_pulse + (CRVALID_pulse && CRRESP[0]);
      end
      else
      begin
        AC_leading_data <= AC_leading_data + CDVALID_first_pulse - (CRVALID_pulse && CRRESP[0]);
      end
    end
  end



  always @(posedge `ACE_AUX_CLK or negedge `ACE_AUX_RSTn)
  begin
    if(!`ACE_AUX_RSTn)
    begin
      CRVALID_pulse_en <= 1'b1;
    end 
    else
    begin
      if (CRVALID)
      begin
        if (CRREADY)
        begin
          CRVALID_pulse_en <= 1'b1;
        end
        else
        begin
          CRVALID_pulse_en <= 1'b0;
        end
      end 
    end
  end
  always @(posedge `ACE_AUX_CLK or negedge `ACE_AUX_RSTn)
  begin
    if(!`ACE_AUX_RSTn)
    begin
      CDVALID_first_pulse_en <= 1'b1;
    end 
    else
    begin
      if (CDVALID)
      begin
        if (CDLAST && CDREADY)
        begin
          CDVALID_first_pulse_en <= 1'b1;
        end
        else
        begin
          CDVALID_first_pulse_en <= 1'b0;
        end
      end 
    end
  end
  ////track the number of non DVM addresses in the CAM
  always @(posedge `ACE_AUX_CLK or negedge `ACE_AUX_RSTn)
  begin
    if(!`ACE_AUX_RSTn)
    begin
      AC_nonDVM <= '0;
    end 
    else
    begin
      AC_nonDVM <= AC_nonDVM + (ACVALID && ACREADY && ~&ACSNOOP[3:1])
                   //non data response
                   - (CRVALID_pulse && !ACInfo[snoop_dataresp_cnt+1][AC_DVM] && !CRRESP[0])
                   //data and response for same snoop in same cyle
                   - (CRVALID_pulse && (!ACInfo[snoop_dataresp_cnt+1][AC_DVM] && ( CRRESP[0] && ((AC_leading_data == 0) && (AC_leading_data_resps == 0) && CDVALID_first_pulse))))
                   //response for old data
                   - (CRVALID_pulse && (!ACInfo[snoop_dataresp_cnt+1][AC_DVM] && ( CRRESP[0] && (AC_leading_data > 0) )))
                   //data for old reponse
                   - (CDVALID_first_pulse && (AC_leading_data_resps > 0)) ;
    end
  end
//track the number of address that can accept data 
  //track the number of snoop transactions with data
  always @(posedge `ACE_AUX_CLK or negedge `ACE_AUX_RSTn)
  begin
    if(!`ACE_AUX_RSTn)
    begin
      snoop_dataresp_cnt <= '0;
    end 
    else
    begin
      snoop_dataresp_cnt <= snoop_dataresp_cnt + CR_Data_Resp - CD_Pop;
    end
  end
  //track the number of transactions of snoop data including unclocked first cdvalid
  always @(posedge `ACE_AUX_CLK or negedge `ACE_AUX_RSTn)
  begin
    if(!`ACE_AUX_RSTn)
    begin
      ACData_transactions <= '0;
    end 
    else
    begin
      ACData_transactions <= ACData_transactions + CDVALID_first_pulse - CD_Pop;
    end
  end
  //update the info index values
  always @(posedge `ACE_AUX_CLK or negedge `ACE_AUX_RSTn)
  begin
    if(!`ACE_AUX_RSTn)
    begin
      ACInfo_index <= 1;
    end 
    else
    begin
      ACInfo_index <= ACInfo_index + AC_Push - CR_Pop - CD_Pop;
    end
  end


  //Update the data counts
  always @(posedge `ACE_AUX_CLK or negedge `ACE_AUX_RSTn)
  begin
    integer    i; //loop counter
    if(!`ACE_AUX_RSTn)
    begin
      for (i = 1; i <= MAXCBURSTS; i = i + 1)
      begin
        ACData_prev_AC[i] <= '0;
        ACData_prev_AC_index <= 1;
      end
    end 
    else
    begin
      for (i = 1; i < MAXCBURSTS; i = i + 1)
      begin
        if (i < ACData_prev_AC_index )
        begin
          ACData_prev_AC[i] <= ACData_prev_AC[i+ACData_prev_AC_pop] - (ACData_prev_AC_dec || ACData_prev_AC_pop);
        end
      end
      if (ACData_prev_AC_pop)
      begin
        ACData_prev_AC[ACData_prev_AC_index -1] <= '0;
      end
      if (ACData_prev_AC_push)
      begin
        ACData_prev_AC[ACData_prev_AC_index - ACData_prev_AC_pop] <= AC_nonDVM - (CRVALID_pulse && !ACInfo[snoop_dataresp_cnt+1][AC_DVM]) ; 
      end
      ACData_prev_AC_index <= ACData_prev_AC_index + ACData_prev_AC_push - ACData_prev_AC_pop;
    end
  end


  always @(posedge `ACE_AUX_CLK or negedge `ACE_AUX_RSTn)
  begin
    if(!`ACE_AUX_RSTn)
    begin
      ACData_count <= '0;
      CDLAST_count <= '0;
    end 
    else
    begin
      if (CDVALID && CDREADY)
      begin
        if (CDLAST)
        begin
          ACData_count <= '0;
        end
        else
        begin
          ACData_count <= ACData_count + 1;
        end
      end 
      CDLAST_count <= CDLAST_count + (CDVALID && CDREADY && CDLAST ) - (CD_Pop );
    end
  end


  //register the snoop transaction data as soon as ACVALID goes high
  always_comb
  begin
    if (!`ACE_AUX_RSTn)
    begin
      ACInfo_tmp =  '0;
    end
    else if (ACVALID)
    begin
      ACInfo_tmp[ACADDR_HI:ACADDR_LO] = ACADDR;
      ACInfo_tmp[AC_DVM] = &ACSNOOP[3:1];
      ACInfo_tmp[ACPROT_1] = ACPROT[1];
      ACInfo_tmp[AC_DVM_ADDITIONAL] = &ACSNOOP[3:1] && ACADDR[0];
      ACInfo_tmp[AC_DVM_SYNC] = &ACSNOOP[3:0] && (ACADDR[14:12] == `ACEPC_DVM_SYNC);
      ACInfo_tmp[AC_DVM_COMPLETE] = (ACSNOOP == `ACEPC_ACSNOOP_DVMCOMPLETE);
      ACInfo_tmp[AC_DVM_HINT] = &ACSNOOP[3:0] && (ACADDR[14:12] == `ACEPC_DVM_HINT);
      ACInfo_tmp[AC_READUNIQUE] = (ACSNOOP == `ACEPC_ACSNOOP_READUNIQUE);
      ACInfo_tmp[AC_CLEANSHARED] = (ACSNOOP == `ACEPC_ACSNOOP_CLEANSHARED);
      ACInfo_tmp[AC_CLEANINVALID] = (ACSNOOP == `ACEPC_ACSNOOP_CLEANINVALID);
      ACInfo_tmp[AC_MAKEINVALID] = (ACSNOOP == `ACEPC_ACSNOOP_MAKEINVALID);
      ACInfo_tmp[AC_DATA] = 1'b0;

    end
    else
      ACInfo_tmp =  '0;
  end
  
  // Snoop CAM Implementation
  always @(posedge `ACE_AUX_CLK or negedge `ACE_AUX_RSTn)
  begin
  integer    i; //loop counter
    if (!`ACE_AUX_RSTn)
    begin
      for (i = 1; i <= MAXCBURSTS; i = i + 1)
      begin
        ACInfo[i] <= '0;
      end
    end
    else
    begin
      //Could possibly have to do two pops in the same cycle if CRRESP
      //indicates no data at the same time as CDLAST is valid
      if (CD_Pop)
      begin
        ACInfo[MAXCBURSTS] <= '0;
        for (i = 1; i < MAXCBURSTS; i = i + 1)
        begin
          ACInfo[i] <= ACInfo[i+1];//data pop must be oldest transaction
        end
      end
      if (CR_Pop)
      begin
        ACInfo[MAXCBURSTS] <= '0;
        for (i = 1  ; i < MAXCBURSTS; i = i + 1)
        //for (i = 1 + snoop_dataresp_cnt -CD_Pop ; i < MAXCBURSTS; i = i + 1)
        begin
          if (i > snoop_dataresp_cnt -CD_Pop)
          begin
            ACInfo[i] <= ACInfo[i+1+CD_Pop];//resp pop must be first one after
                                           //the known data transactions
          end
        end
      end
      if (AC_Push)
      begin
        ACInfo[ACInfo_index - CR_Pop - CD_Pop ] <= ACInfo_tmp;
      end
    end
  end


//------------------------------------------------------------------------------
// INDEX:   8)  ARInfo CAM
//------------------------------------------------------------------------------ 
  localparam ARID_LO           = 0;
  localparam ARID_HI           = ARID_LO + ID_MAX_R;
  localparam ARADDR_LO         = ARID_HI + 1;                  
  localparam ARADDR_HI         = ARADDR_LO + ADDR_MAX;                  
  localparam ARBURST_LO        = ARADDR_HI + 1;                  
  localparam ARBURST_HI        = ARBURST_LO + 1;                  
  localparam ARLEN_LO          = ARBURST_HI + 1;                  
  localparam ARLEN_HI          = ARLEN_LO + 7;                  
  localparam ARSIZE_LO         = ARLEN_HI + 1;                  
  localparam ARSIZE_HI         = ARSIZE_LO + 2;                  
  localparam ARSNOOP_LO        = ARSIZE_HI + 1;
  localparam ARSNOOP_HI        = ARSNOOP_LO + 3;
  localparam ARDOMAIN_LO       = ARSNOOP_HI + 1;
  localparam ARDOMAIN_HI       = ARDOMAIN_LO + 1;
  localparam ARPROT_1          = ARDOMAIN_HI + 1;
  localparam AR_BARRIER        = ARPROT_1 + 1;
  localparam AR_DVM            = AR_BARRIER + 1;
  localparam AR_DVMSYNC        = AR_DVM + 1;
  localparam AR_DVMCOMPLETE    = AR_DVMSYNC + 1;
  localparam AR_DVMHINT        = AR_DVMCOMPLETE + 1;
  localparam AR_DVM_ADDITIONAL = AR_DVMHINT + 1;
  localparam AR_SHAREABLE      = AR_DVM_ADDITIONAL + 1;
  localparam AR_NC             = AR_SHAREABLE + 1;
  localparam AR_LOCK           = AR_NC + 1;
  localparam AR_RRESPLO        = AR_LOCK + 1;
  localparam AR_RRESPHI        = AR_RRESPLO + 1;
  localparam AR_R_FIRST        = AR_RRESPHI + 1;
  localparam AR_R_LAST         = AR_R_FIRST + 1;
  localparam ARINFO_HI         = AR_R_LAST + 1 ;
  localparam LOG2MAXRBURSTS  = clogb2(MAXRBURSTS);

  
  
  reg        [LOG2MAXRBURSTS:0] ARIndex; //next available location in CAM
  reg        [LOG2MAXRBURSTS:0] RIDMatch; //location of oldest transaction in Cam matching RID
  reg        [LOG2MAXRBURSTS:0] RIDMatch_next; //location of oldest transaction in Cam matching RID
                    //after next clock edge
  wire       ArPush;
  reg        ArPop;
  reg        [LOG2MAXRBURSTS:0] ArPopLocation;
  reg        Valid_ArPopLocation;
  reg        [ARINFO_HI -1:0] ARInfo [1:MAXRBURSTS];
  wire       [ARINFO_HI -1:0] CurrentRInfo;
  reg        INFO_AR_PUSH;
  reg        INFO_AR_R_FIRST;
  reg        INFO_AR_R_LAST;
  reg        INFO_AR_POP;
  wire       [3:0] ARInfo_Delta;
  reg        [ID_MAX_R:0] RLAST_ID  [1:MAXRBURSTS];
  reg        [LOG2MAXRBURSTS:0] RLAST_ID_Index;
  
  
  
  assign ArPush = ARVALID && ARREADY;
  assign ArPop = PROTOCOL == `AXI4PC_AMBA_ACE ? RACK : RVALID && RREADY && RLAST;
  assign R_BAR_RESP = RVALID && CurrentRInfo[AR_BARRIER];
  assign ARInfo_Delta = {INFO_AR_PUSH,INFO_AR_R_FIRST,INFO_AR_R_LAST,INFO_AR_POP};

  always @(ARVALID or ARADDR or ARBURST or ARLEN or ARSIZE)
  begin
    if (ARVALID)
    begin
      min_ar_address = min_tx_address(ARADDR,ARBURST,ARLEN,ARSIZE);
      max_ar_address = max_tx_address(ARADDR,ARBURST,ARLEN,ARSIZE);
    end
    else
    begin
      min_ar_address = 64'b0;
      max_ar_address = 64'b0;
    end
  end

  always @(RVALID or CurrentRInfo)
  begin
    if (RVALID)
    begin
      min_r_address =  min_tx_address(CurrentRInfo[ARADDR_HI:ARADDR_LO],
                                        CurrentRInfo[ARBURST_HI:ARBURST_LO],
                                        CurrentRInfo[ARLEN_HI:ARLEN_LO],
                                        CurrentRInfo[ARSIZE_HI:ARSIZE_LO]);
      max_r_address =  max_tx_address(CurrentRInfo[ARADDR_HI:ARADDR_LO],
                                        CurrentRInfo[ARBURST_HI:ARBURST_LO],
                                        CurrentRInfo[ARLEN_HI:ARLEN_LO],
                                        CurrentRInfo[ARSIZE_HI:ARSIZE_LO]);
    end
    else
    begin
      min_r_address =  64'b0;
      max_r_address =  64'b0;
    end
  end

  //Determining what to pop from the ARInfo Cam
  //Collect the IDs of the RLAST in order
   always @(posedge `ACE_AUX_CLK or negedge `ACE_AUX_RSTn)
   begin
     integer    i; //loop counter
     if(!`ACE_AUX_RSTn)
     begin
       for (i = 1; i <= MAXRBURSTS; i = i + 1)
       begin
        RLAST_ID[i] <= '0;
        RLAST_ID_Index <= 1;
       end 
     end
     else
     if (PROTOCOL == `AXI4PC_AMBA_ACE)
     begin
       if (RACK)
       begin
         for (i = 1; i <= MAXRBURSTS; i = i + 1)
         begin
           if (i < RLAST_ID_Index)
           begin
             if (i == MAXRBURSTS)
             begin
               RLAST_ID[i] <= '0;
             end
             else
             begin
               RLAST_ID[i] <= RLAST_ID[i+1];
             end
           end
         end
       end
       if (RVALID && RREADY && RLAST)
       begin
         RLAST_ID[RLAST_ID_Index - RACK] <= RID;
       end
       RLAST_ID_Index <= RLAST_ID_Index +  (RVALID && RREADY && RLAST) - RACK;
     end
   end
  //ACE: find the oldest read transaction that has had RLAST
  //ACELite: use RIDMatch
   always @(ARInfo_Delta or ArPush or ArPop or ARIndex or RIDMatch)
   begin
     ArPopLocation = '0;
     Valid_ArPopLocation = 1'b0;
     if (PROTOCOL == `AXI4PC_AMBA_ACE_LITE)
     begin
           Valid_ArPopLocation = 1'b1;
           ArPopLocation = RIDMatch;
     end
     else
     begin
       for (int i = MAXRBURSTS; i >= 1; i = i - 1)
       begin
         if ((i < ARIndex) && (ARInfo[i][ARID_HI:ARID_LO] == RLAST_ID[1]))
         begin
           Valid_ArPopLocation = 1'b1;
           ArPopLocation = i;
         end
       end
     end
   end

   // Update the Index values
   always @(posedge `ACE_AUX_CLK or negedge `ACE_AUX_RSTn)
   begin
     if(!`ACE_AUX_RSTn)
     begin
       ARIndex <= 1;
     end else
     begin
       ARIndex <= ARIndex + ArPush - ArPop;
     end
   end
  
  // Find the index of the first item in the CAM that matches the current RID
  // that has not seen RLAST
  always @(RID or  ARInfo_Delta  or ArPush or ArPop or ARIndex)
  begin : p_RidMatch
  integer    i;  // loop counter
    RIDMatch = '0;
    for (i=MAXRBURSTS; i>0 ; i=i-1)
      if ((i < ARIndex) && (RID == ARInfo[i][ARID_HI:ARID_LO]) && !ARInfo[i][AR_R_LAST] )
        RIDMatch = i;
  end

   // AR Payload CAM
  always @(posedge `ACE_AUX_CLK or negedge `ACE_AUX_RSTn)
  begin
   integer    i; //loop counter
   reg [ARINFO_HI -1:0] ARInfo_tmp;
   if (!`ACE_AUX_RSTn)
   begin
     for (i = 1; i <= MAXRBURSTS; i = i + 1)
     begin
       ARInfo[i] <= '0;
       INFO_AR_PUSH <= 1'b0;
       INFO_AR_R_FIRST <= 1'b0;
       INFO_AR_R_LAST <= 1'b0;
       INFO_AR_POP <= 1'b0;
     end
   end
   else
   begin
     if (ArPop)
     begin : p_ReadCamPop
       INFO_AR_POP <= ~INFO_AR_POP;
       ARInfo[MAXRBURSTS] <= '0;
       for (int i = 1; i < MAXRBURSTS; i = i + 1)
       begin
         if (Valid_ArPopLocation )
           begin
           if (i >= ArPopLocation && i < ARIndex)
           begin
             ARInfo[i] <= ARInfo[i+1];
           end
           ARInfo[ARIndex] <= '0;
         end
       end
     end//if (ArPop)

     if (ARVALID)
     begin
       ARInfo_tmp[ARADDR_HI:ARADDR_LO] = ARADDR;
       ARInfo_tmp[ARBURST_HI:ARBURST_LO] = ARBURST;
       ARInfo_tmp[ARLEN_HI:ARLEN_LO] = ARLEN;
       ARInfo_tmp[ARSIZE_HI:ARSIZE_LO] = ARSIZE;
       ARInfo_tmp[ARID_HI:ARID_LO] = ARID;
       ARInfo_tmp[ARSNOOP_HI:ARSNOOP_LO] = ARSNOOP;
       ARInfo_tmp[ARDOMAIN_HI:ARDOMAIN_LO] = ARDOMAIN;
       ARInfo_tmp[ARPROT_1] = ARPROT[1];
       ARInfo_tmp[AR_BARRIER] = ARBAR[0];
       ARInfo_tmp[AR_DVM] = &ARSNOOP[3:1] ;
       ARInfo_tmp[AR_DVM_ADDITIONAL] = &ARSNOOP[3:1] && ARADDR[0]; 
       ARInfo_tmp[AR_DVMSYNC] = &ARSNOOP[3:0] && (ARADDR[14:12] == `ACEPC_DVM_SYNC);
       ARInfo_tmp[AR_DVMCOMPLETE] = (ARSNOOP[3:0] == `ACEPC_ARSNOOP_DVMCOMPLETE);
       ARInfo_tmp[AR_DVMHINT] = &ARSNOOP[3:0] && (ARADDR[14:12] == `ACEPC_DVM_HINT);
       ARInfo_tmp[AR_NC] = ~(|ARCACHE[3:2]);
       ARInfo_tmp[AR_LOCK] = ARLOCK;
       ARInfo_tmp[AR_SHAREABLE] = ^ARDOMAIN;
       ARInfo_tmp[AR_RRESPHI:AR_RRESPLO] = 2'b00;
       ARInfo_tmp[AR_R_FIRST] = 1'b0;
       ARInfo_tmp[AR_R_LAST] = 1'b0;
       if (ArPush)
       begin
         INFO_AR_PUSH <= ~INFO_AR_PUSH;
         ARInfo[ARIndex - ArPop] <= ARInfo_tmp;
       end//if (ARPush)
     end//if (ARVALID)
     RIDMatch_next = RIDMatch;
     if (ArPop && Valid_ArPopLocation && (ArPopLocation < RIDMatch))
       RIDMatch_next = RIDMatch -1;
     if (RVALID)
     begin
       INFO_AR_R_FIRST <= ~INFO_AR_R_FIRST;
       ARInfo[RIDMatch_next][AR_R_FIRST] <= 1'b1;
       ARInfo[RIDMatch_next][AR_RRESPHI:AR_RRESPLO] <= RRESP[3:2];
       if (RLAST && RREADY && (PROTOCOL == `AXI4PC_AMBA_ACE))
       begin
         INFO_AR_R_LAST <= ~INFO_AR_R_LAST;
         ARInfo[RIDMatch_next][AR_R_LAST] <= 1'b1;
       end
     end
   end
 end
 
 assign CurrentRInfo = RVALID ? ARInfo[RIDMatch] : '0;

//------------------------------------------------------------------------------
// INDEX:   9)  AWInfo CAM
//------------------------------------------------------------------------------ 
  localparam AWID_LO       = 0;
  localparam AWID_HI       = AWID_LO + ID_MAX_W;
  localparam AWADDR_LO     = AWID_HI + 1;                  
  localparam AWADDR_HI     = AWADDR_LO + ADDR_MAX;                  
  localparam AWBURST_LO    = AWADDR_HI + 1;                  
  localparam AWBURST_HI    = AWBURST_LO + 1;                  
  localparam AWLEN_LO      = AWBURST_HI + 1;                  
  localparam AWLEN_HI      = AWLEN_LO + 7;                  
  localparam AWSIZE_LO     = AWLEN_HI + 1;                  
  localparam AWSIZE_HI     = AWSIZE_LO + 2;                  
  localparam AWPROT_1      = AWSIZE_HI + 1;                  
  localparam AW_BARRIER    = AWPROT_1 + 1;
  localparam AW_WNS        = AW_BARRIER + 1;
  localparam AW_WLU        = AW_WNS + 1; 
  localparam AW_WU         = AW_WLU + 1;
  localparam AW_WC         = AW_WU + 1;
  localparam AW_WB         = AW_WC + 1;
  localparam AW_EVICT      = AW_WB + 1;
  localparam AW_SHAREABLE  = AW_EVICT + 1;
  localparam AWID_OS_LO    = AW_SHAREABLE + 1; //number of transactions with same ID that are older
  localparam AWID_OS_HI    = AWID_OS_LO + AWID_OS_BITS -1;
  localparam AW_ADDR       = AWID_OS_HI + 1; //everything below here is written on AWPush
  localparam AW_W_FIRST    = AW_ADDR + 1;
  localparam AW_W_LAST     = AW_W_FIRST + 1;
  localparam AW_BRESP      = AW_W_LAST + 1;
  localparam AW_BRESP_hsk  = AW_BRESP + 1;
  localparam AWINFO_HI     = AW_BRESP_hsk + 1 ;
  localparam LOG2MAXWBURSTS  = clogb2(MAXWBURSTS);

  
  
  reg        [LOG2MAXWBURSTS:0] AWIndex; //next available location in CAM
  reg        [LOG2MAXWBURSTS:0] AWIDMatch_data;//location of oldest transaction in Cam that has not seen AWADDR
                    //that has seen leading write
  reg        [LOG2MAXWBURSTS:0] WIDMatch; //location of oldest transaction in Cam that has not seen WLAST
  reg        [LOG2MAXWBURSTS:0] BIDMatch; //location of oldest transaction in Cam matching BID
  reg        [LOG2MAXWBURSTS:0] WIDMatch_next; //location of oldest transaction in Cam that has not seen WLAST
                    //after next clock edge
  reg        [LOG2MAXWBURSTS:0] BIDMatch_next; //location of oldest transaction in Cam matching BID
  reg        [LOG2MAXWBURSTS:0] ID_OSMatch_next; //used to update the number of outstanding transactions for a given ID
  wire       AwPush;
  wire       AwPush_data;
  wire       AwPush_data_valid;
  wire       AwPush_data_la;
  wire       AwPush_dataless;
  wire       AwPush_dataless_valid;
  
  wire       LWData_v_first;
  wire       BWURESP;
  wire       BWCRESP;
  wire       BWBRESP;
  wire       AWIDisDVM;
  reg        AwPop;
  reg        [LOG2MAXWBURSTS:0] AwPopLocation;
  reg        Valid_AwPopLocation;
  reg        [AWINFO_HI -1:0] AWInfo [1:MAXWBURSTS];
  reg        [AWINFO_HI -1:0] AWInfo_tmp ;
  wire       [AWINFO_HI -1:0] CurrentWInfo;
  wire       [AWINFO_HI -1:0] CurrentBInfo;
  reg        INFO_AW_PUSH;
  reg        INFO_AW_W_FIRST;
  reg        INFO_AW_W_LAST;
  reg        INFO_AW_BRESP;
  reg        INFO_AW_POP;
  wire       [4:0] AWInfo_Delta;
  reg        [AWID_OS_BITS -1:0]AWID_Outstanding;
  
  
  
  assign AwPush = AWVALID && AWREADY;
  assign AwPush_dataless_valid = AWVALID && (AWBAR[0] || (AWSNOOP == `ACEPC_AWSNOOP_WRITEEVICT));
  assign AwPush_dataless = AwPush_dataless_valid && AWREADY ;
  assign AwPush_data_valid = AWVALID && !(AWBAR[0] || (AWSNOOP == `ACEPC_AWSNOOP_WRITEEVICT));
  assign AwPush_data = AwPush_data_valid && AWREADY ;
  assign AwPush_data_la =  AwPush_data && ((AWIDMatch_data > MAXWBURSTS) ? 1'b1 : (!AWInfo[AWIDMatch_data][AW_W_FIRST]));
  assign LWData_v_first = WVALID && 
        ((WIDMatch > MAXWBURSTS) ? 1'b1 : (!AWInfo[WIDMatch][AW_ADDR] &&  !AWInfo[WIDMatch][AW_W_FIRST])) ;
  assign AwPop = PROTOCOL == `AXI4PC_AMBA_ACE ? WACK : BVALID && BREADY ;
  assign B_BAR_RESP = BVALID && CurrentBInfo[AW_BARRIER];
  assign B_EVICT_RESP = BVALID && CurrentBInfo[AW_EVICT];
  assign BWURESP = BVALID && BREADY && (CurrentBInfo[AW_WU] || CurrentBInfo[AW_WLU]) ;
  assign BWCRESP = BVALID && BREADY && CurrentBInfo[AW_WC];
  assign BWBRESP = BVALID && BREADY && CurrentBInfo[AW_WB];
  assign AWInfo_Delta = {INFO_AW_PUSH,INFO_AW_W_FIRST,INFO_AW_W_LAST,INFO_AW_BRESP,INFO_AW_POP};

  always @(AWVALID or AWBURST or AWLEN or AWSIZE or AWADDR)
  begin
    if(AWVALID)
    begin
      min_aw_address = min_tx_address(AWADDR,AWBURST,AWLEN,AWSIZE);
      max_aw_address = max_tx_address(AWADDR,AWBURST,AWLEN,AWSIZE);
    end
    else
    begin
      min_aw_address = 64'b0;
      max_aw_address = 64'b0;
    end
  end

  //determine how many transactions with the same ID are already in the CAM
  //that have not seem BRESP
  always @(AWID or AWIndex or AWVALID or BVALID or BID or BREADY or AWInfo_Delta)
  begin
    AWID_Outstanding = '0;
    for (int i = MAXWBURSTS; i >= 1; i = i - 1)
    begin
      if ((i < AWIndex) && (AWInfo[i][AWID_HI:AWID_LO] == AWID) && AWInfo[i][AW_ADDR] && !AWInfo[i][AW_BRESP_hsk] && AWVALID)
      begin
        AWID_Outstanding = AWID_Outstanding +1;
      end
    end
    if (BVALID && BREADY && (BID == AWID))
    begin
      AWID_Outstanding = AWID_Outstanding -1;
    end
  end
  //Determining what to pop from the AWInfo Cam
  //Collect the IDs of the BRESP in order
  reg    [LOG2MAXWBURSTS:0] Pop_Order [1:MAXWBURSTS];
  reg    [LOG2MAXWBURSTS:0] Pop_Order_Index;
   always @(posedge `ACE_AUX_CLK or negedge `ACE_AUX_RSTn)
   begin
     integer    i; //loop counter
     if(!`ACE_AUX_RSTn)
     begin
       for (i = 1; i <= MAXWBURSTS; i = i + 1)
       begin
        Pop_Order[i] <= '0;
        Pop_Order_Index <= 1;
       end 
     end
     else
     if (PROTOCOL == `AXI4PC_AMBA_ACE)
     begin
       if (WACK)
       begin
         for (i = 1; i <= MAXWBURSTS; i = i + 1)
         begin
           if (i < Pop_Order_Index)
           begin
             if (i == MAXWBURSTS)
             begin
               Pop_Order[i] <= '0;
             end
             else
             begin
               if (Pop_Order[i+1] > Pop_Order[1] )
               begin
                 Pop_Order[i] <= Pop_Order[i+1] -1;
               end
               else
               begin
                 Pop_Order[i] <= Pop_Order[i+1];
               end
             end
           end
         end
       end
       if (BVALID && BREADY)
       begin
         if (WACK)
         begin
           //item will be popped from lower in cam - hence deduct 1 from BIDMatch
           if (Pop_Order[1] < BIDMatch)
           begin
             Pop_Order[Pop_Order_Index - 1] <= BIDMatch -1;
           end
           else
           begin
             Pop_Order[Pop_Order_Index - 1] <= BIDMatch ;
           end
         end
         else
         begin
           Pop_Order[Pop_Order_Index] <= BIDMatch ;
         end
       end
       Pop_Order_Index <= Pop_Order_Index +  (BVALID && BREADY) - WACK;
       if (`ACE_SVA_RSTn)
       begin
         assert ((Pop_Order_Index +  (BVALID && BREADY) - WACK) > 0);
       end 
     end
   end

  //ACE: find the oldest read transaction that has had BRESP
  //ACELite: use BIDMatch
   always @(AWInfo_Delta or AwPush or AwPop or AWIndex or BIDMatch)
   begin
     AwPopLocation = '0;
     Valid_AwPopLocation = 1'b0;
     if (PROTOCOL == `AXI4PC_AMBA_ACE_LITE)
     begin
       Valid_AwPopLocation = 1'b1;
       AwPopLocation = BIDMatch;
     end
     else
     begin
       Valid_AwPopLocation =  1'b1;
       AwPopLocation = Pop_Order[1];
     end
   end


   // Update the Index values
  always @(negedge `ACE_AUX_RSTn or posedge `ACE_AUX_CLK)
   begin
     if(!`ACE_AUX_RSTn)
     begin
       AWIndex <= 1;
     end 
     else
     begin
       //increment on 
       AWIndex <= AWIndex + 
                  (AwPush_dataless ) +
                  ((AwPush_data_la ) ||
                  (LWData_v_first )) 
                   - AwPop;
     end
   end
  
  // Find the index of the first item in the CAM 
  // that has not seen WLAST, that is not an evict or a barrier
  always @(AWInfo_Delta or AWIndex or AwPush or AwPop)
  begin : p_WidMatch
  integer    i;  // loop counter
    WIDMatch = AWIndex;
    for (i=MAXWBURSTS; i>0 ; i=i-1)
      if ((i < AWIndex) &&  !AWInfo[i][AW_W_LAST] && !AWInfo[i][AW_EVICT] && !AWInfo[i][AW_BARRIER] )
        WIDMatch = i ;//case where you have leading write at the same time as
                       //a write evict or a write barrier
  end
  // Find the index of the first item in the CAM 
  // that has not seen AWADDR.
  always @(AWInfo_Delta or AWIndex or AwPush or AwPop)
  begin : p_AWidMatch_data
  integer    i;  // loop counter
    AWIDMatch_data = AWIndex;
    for (i=MAXWBURSTS; i>0 ; i=i-1)
      if ((i < AWIndex) &&  !AWInfo[i][AW_ADDR] )
        AWIDMatch_data = i;
  end


  // Find the index of the first item in the CAM that matches the current BID
  // that has seen WLAST
  // if it is a write evict or a barrier, then we won't see wlast
  // AWInfo[AWID_OS_HI:AWID_OS_LO] tells how many transactions with the same
  // ID are ahead. This is needed for the scenario where you have had leading
  // write data.
  always @(AWInfo_Delta or BID or AWIndex or AwPush or AwPop)

  begin : p_BidMatch
  integer    i;  // loop counter
    BIDMatch = '0;
    for (i = MAXWBURSTS; i > 0 ; i = i - 1)
    begin
      if ((i < AWIndex) && (BID == AWInfo[i][AWID_HI:AWID_LO]) && 
          (AWInfo[i][AW_W_LAST] || AWInfo[i][AW_EVICT] || AWInfo[i][AW_BARRIER] ) 
          && AWInfo[i][AW_ADDR] && !AWInfo[i][AW_BRESP_hsk] 
          && (AWInfo[i][AWID_OS_HI:AWID_OS_LO] == 0))
      begin
        BIDMatch = i;
      end 
    end
  end
   
  
   // AW Payload CAM
  always @(posedge `ACE_AUX_CLK or negedge `ACE_AUX_RSTn)
  begin
    integer    i; //loop counter
    if (!`ACE_AUX_RSTn)
    begin
      INFO_AW_PUSH <= 1'b0;
      INFO_AW_W_FIRST <= 1'b0;
      INFO_AW_W_LAST <= 1'b0;
      INFO_AW_BRESP <= 1'b0;
      INFO_AW_POP <= 1'b0;
 
      for (i = 1; i <= MAXWBURSTS; i = i + 1)
      begin
        AWInfo[i] <= '0;
      end
    end
    else
    begin
      if (AwPop)
      begin : p_WriteCamPop
        INFO_AW_POP <= ~INFO_AW_POP;
        AWInfo[MAXWBURSTS] <= '0;
        assert(AwPopLocation > 0);
        for (int i = 1; i < MAXWBURSTS; i = i + 1)
        begin
          if (Valid_AwPopLocation)
          begin
            if (i >= AwPopLocation && i < AWIndex)
            begin
              AWInfo[i] <= AWInfo[i+1];
            end
            AWInfo[AWIndex] <= '0;
          end
        end
      end//if (AwPop)
 
      if (AWVALID)
      begin
        AWInfo_tmp[AWADDR_HI:AWADDR_LO] = AWADDR;
        AWInfo_tmp[AWBURST_HI:AWBURST_LO] = AWBURST;
        AWInfo_tmp[AWLEN_HI:AWLEN_LO] = AWLEN;
        AWInfo_tmp[AWSIZE_HI:AWSIZE_LO] = AWSIZE;
        AWInfo_tmp[AWID_HI:AWID_LO] = AWID;
        AWInfo_tmp[AWPROT_1] = AWPROT[1];
        AWInfo_tmp[AW_BARRIER] = AWBAR[0];
        AWInfo_tmp[AW_WNS] = (AWSNOOP == `ACEPC_AWSNOOP_WRITEUNIQUE) && ~^AWDOMAIN && !AWBAR[0];
        AWInfo_tmp[AW_WLU] = AWSNOOP == `ACEPC_AWSNOOP_WRITELINEUNIQUE; 
        AWInfo_tmp[AW_WU] = ( AWSNOOP == `ACEPC_AWSNOOP_WRITEUNIQUE) && ^AWDOMAIN && !AWBAR[0];
        AWInfo_tmp[AW_WC] = (AWSNOOP == `ACEPC_AWSNOOP_WRITECLEAN );
        AWInfo_tmp[AW_WB] = (AWSNOOP == `ACEPC_AWSNOOP_WRITEBACK );
        AWInfo_tmp[AW_EVICT] = (AWSNOOP == `ACEPC_AWSNOOP_WRITEEVICT);
        AWInfo_tmp[AW_SHAREABLE] = ^AWDOMAIN;
        AWInfo_tmp[AW_ADDR] = 1'b1;
        if (AwPush)
        begin
          AWInfo_tmp[AWID_OS_HI:AWID_OS_LO] = AWID_Outstanding;
          //could have been leading write data so don't 
          //assign a datales tx to a slot with data
          INFO_AW_PUSH <= ~INFO_AW_PUSH;
          if ((AWSNOOP == `ACEPC_AWSNOOP_WRITEEVICT) || AWBAR[0])
          begin
            AWInfo[AWIndex - (AwPop && Valid_AwPopLocation)][AW_ADDR:0] 
                               <= AWInfo_tmp[AW_ADDR:0];
          end
          else
          begin
            AWInfo[AWIDMatch_data - (AwPop && Valid_AwPopLocation && 
                                    (AwPopLocation < AWIDMatch_data))][AW_ADDR:0] 
                                    <= AWInfo_tmp[AW_ADDR:0];
          end
 
        end//if (AWPush)
      end//if (AWVALID)
      WIDMatch_next = WIDMatch;
      if (AwPop && Valid_AwPopLocation && (AwPopLocation < WIDMatch))
        WIDMatch_next = WIDMatch -1;
      if (AwPush_dataless && LWData_v_first)// if have an evict or barrier push
        WIDMatch_next = WIDMatch_next +1;   // data will use next slot
      if (WVALID)
      begin
        AWInfo[WIDMatch_next][AW_W_FIRST] <= 1'b1;
        INFO_AW_W_FIRST <= ~INFO_AW_W_FIRST;
        if (WLAST && WREADY)
        begin
          AWInfo[WIDMatch_next][AW_W_LAST] <= 1'b1;
          INFO_AW_W_LAST <= ~INFO_AW_W_LAST;
        end
      end
      BIDMatch_next = BIDMatch;
      if (AwPop && Valid_AwPopLocation && (AwPopLocation < BIDMatch))
        BIDMatch_next = BIDMatch -1;
      //only set the BRESP flag for ACE, not AceLite as it will be popped
      //now for AceLite
      if (BVALID)
      begin
        AWInfo[BIDMatch_next][AW_BRESP] <= 1'b1;
        INFO_AW_BRESP <= ~INFO_AW_BRESP;
        if (BREADY)
        begin
          if (PROTOCOL == `AXI4PC_AMBA_ACE)
          begin
            AWInfo[BIDMatch_next][AW_BRESP_hsk] <= 1'b1;
          end
          for (int i = MAXWBURSTS; i >= 1; i = i - 1)
          begin
            //update all the transactions that have the same id, and have not
            //seen bresp to reflect that a bresp has been seen.
            if ((i < AWIndex) && (AWInfo[i][AWID_HI:AWID_LO] == BID) && 
                (i != BIDMatch) && AWInfo[i][AW_ADDR] && !AWInfo[i][AW_BRESP_hsk])
            begin
              ID_OSMatch_next = i;
              if (AwPop && Valid_AwPopLocation && (AwPopLocation <= i))
              begin
                ID_OSMatch_next = i -1;
              end
              AWInfo[ID_OSMatch_next][AWID_OS_HI:AWID_OS_LO] <= AWInfo[i][AWID_OS_HI:AWID_OS_LO] -1;
            end
          end
        end
      end
    end
  end
 
  //WriteUnique tracking 
  reg    [LOG2MAXWBURSTS:0] wu_ctr;
  always @(posedge `ACE_AUX_CLK or negedge `ACE_AUX_RSTn)
  begin: p_wu_ctr
    if(!`ACE_AUX_RSTn)
    begin
      wu_ctr <= '0;
    end else
    begin
      wu_ctr <= wu_ctr + (AWVALID && AWREADY && (AWSNOOP == `ACEPC_AWSNOOP_WRITEUNIQUE || 
                          AWSNOOP == `ACEPC_AWSNOOP_WRITELINEUNIQUE) && ^AWDOMAIN && !AWBAR[0]) - BWURESP;
    end
  end
  //WriteClean tracking
  reg    [LOG2MAXWBURSTS:0] wc_ctr;
  always @(posedge `ACE_AUX_CLK or negedge `ACE_AUX_RSTn)
  begin: p_wc_ctr
    if(!`ACE_AUX_RSTn)
    begin
      wc_ctr <= '0;
    end else
    begin
      wc_ctr <= wc_ctr + (AWVALID && AWREADY && (AWSNOOP == `ACEPC_AWSNOOP_WRITECLEAN)) - BWCRESP;
    end
  end
  //WriteBack tracking
  reg    [LOG2MAXWBURSTS:0]  wb_ctr;
  always @(posedge `ACE_AUX_CLK or negedge `ACE_AUX_RSTn)
  begin: p_wb_ctr
    if(!`ACE_AUX_RSTn)
    begin
      wb_ctr <= '0;
    end else
    begin
      wb_ctr <= wb_ctr + (AWVALID && AWREADY && (AWSNOOP == `ACEPC_AWSNOOP_WRITEBACK)) - BWBRESP;
    end
  end

  assign CurrentWInfo = WVALID ? AWInfo[WIDMatch] : '0;
  assign CurrentBInfo = BVALID ? AWInfo[BIDMatch] : '0;

  always @(BVALID,CurrentBInfo)
  begin
    if (BVALID)
    begin
      min_b_address = min_tx_address(CurrentBInfo[AWADDR_HI:AWADDR_LO],
                                            CurrentBInfo[AWBURST_HI:AWBURST_LO],
                                            CurrentBInfo[AWLEN_HI:AWLEN_LO],
                                            CurrentBInfo[AWSIZE_HI:AWSIZE_LO]);
      max_b_address = max_tx_address(CurrentBInfo[AWADDR_HI:AWADDR_LO],
                                        CurrentBInfo[AWBURST_HI:AWBURST_LO],
                                        CurrentBInfo[AWLEN_HI:AWLEN_LO],
                                        CurrentBInfo[AWSIZE_HI:AWSIZE_LO]);
    end
    else
    begin
      min_b_address = 64'b0;
      max_b_address = 64'b0;
    end
  end

 

//------------------------------------------------------------------------------ 
// INDEX:   10) Barrier Cams
//------------------------------------------------------------------------------ 
// Read barriers and write barriers are held in separate Cams. neither Cam can
// be popped until the corresponding xRESP has been seen on the other Cam.
// Because barrier pairs arrive in the same order the index of the
// corresponding pairs are the same. However, the RESPs may arrive out
// of order.
// If BRESP and RRESP are simultaneous, they may or may not correspond to the
// same barrier pair. They may cause 1 or two barrier pairs to be popped.

  localparam BAR_IDLO       = 0;
  localparam BAR_IDHI       = BAR_IDLO + ID_MAX;
  localparam BAR_PROTLO     = BAR_IDHI + 1;
  localparam BAR_PROTHI     = BAR_PROTLO + 2;
  localparam BAR_DOMAIN_LO  = BAR_PROTHI + 1;
  localparam BAR_DOMAIN_HI  = BAR_DOMAIN_LO + 1;
  localparam BAR_BAR1       = BAR_DOMAIN_HI + 1;
  localparam BAR_RESP       = BAR_BAR1  + 1;
  localparam BARINFOMAX     = BAR_RESP + 1;
  localparam MAX_BARRIERS   = (PROTOCOL == `AXI4PC_AMBA_ACE_LITE) ? MAX_BARRIERS_LITE : 256;
  localparam LOG2MAXBARRIERS  = clogb2(MAX_BARRIERS);


  reg        [BARINFOMAX -1:0] RBARInfo [1:MAX_BARRIERS];
  reg        [BARINFOMAX -1:0] WBARInfo [1:MAX_BARRIERS];
  reg        [1:MAX_BARRIERS]  BAR_Pop_vector;
  reg        [1:MAX_BARRIERS]  BAR_Pop_vector_mask;
  wire       WBARPush;
  wire       RBARPush;
  reg        [LOG2MAXBARRIERS:0] RBARIndex;
  reg        [LOG2MAXBARRIERS:0] WBARIndex;
  reg        INFO_W_BAR_PUSH;
  reg        INFO_R_BAR_PUSH;
  reg        INFO_W_BAR_RESP;
  reg        INFO_R_BAR_RESP;
  reg        INFO_BAR_POP;
  reg        [4:0]BARInfo_Delta;
  wire       R_BAR_RESP_hsk;
  wire       W_BAR_RESP_hsk;
  // barriers are pushed regardless of whether
  // the other half of the pair is current on the other Address channel
  assign BARInfo_Delta = {INFO_W_BAR_PUSH,INFO_R_BAR_PUSH,INFO_W_BAR_RESP,INFO_R_BAR_RESP,INFO_BAR_POP };
  assign RBARPush = ARVALID && ARREADY && ARBAR[0] ; 
  assign WBARPush = AWVALID && AWREADY && AWBAR[0] ;

  assign R_BAR_RESP_hsk = R_BAR_RESP && RREADY;
  assign W_BAR_RESP_hsk = B_BAR_RESP && BREADY;

  reg        [1:0] BAR_pops_num ;
  reg        [LOG2MAXBARRIERS:0] R_BAR_RESP_Match;
  reg        [LOG2MAXBARRIERS:0] W_BAR_RESP_Match;
  reg        [LOG2MAXBARRIERS:0] BARIndex_max;
  reg        [LOG2MAXBARRIERS:0] BARIndex_min;
  assign  BARIndex_max = RBARIndex > WBARIndex ? RBARIndex : WBARIndex;
  assign  BARIndex_min = RBARIndex < WBARIndex ? RBARIndex : WBARIndex;

  always @(*)
  begin
    BAR_Pop_vector = '0;

    //determine if there need to be any pops. There could be pops at two
    //locations if you have had BRESP and RRESP at the same time
    if (R_BAR_RESP_hsk || W_BAR_RESP_hsk)
    begin
      logic R_BAR_POP_found;
      logic W_BAR_POP_found;
      R_BAR_POP_found = 1'b0;
      W_BAR_POP_found = 1'b0;
      for (int i = 1; i <= MAX_BARRIERS; i++)
      begin
        if (i < BARIndex_min)
        begin
          //case where you have RRESP and BRESP at the same time for the same
          //barrier pair
          if (R_BAR_RESP_hsk && W_BAR_RESP_hsk && 
            ~|BAR_Pop_vector && //not already found a match for bresp
            (RID == RBARInfo[i][BAR_IDHI:BAR_IDLO]) && //The IDS all match
            (BID == WBARInfo[i][BAR_IDHI:BAR_IDLO]) && 
            (!RBARInfo[i][BAR_RESP] && (i < RBARIndex)) && //
            (!WBARInfo[i][BAR_RESP] && (i < WBARIndex)))
          begin
            BAR_Pop_vector[i] = 1'b1;
          end
          else
          begin
            //RESPs are not for the same barrier
            if (R_BAR_RESP_hsk && WBARInfo[i][BAR_RESP] && 
               (RID == WBARInfo[i][BAR_IDHI:BAR_IDLO]) && (i < WBARIndex) &&
               !R_BAR_POP_found )
            begin
              BAR_Pop_vector[i] = 1'b1;
              R_BAR_POP_found = 1'b1;
            end
            if (W_BAR_RESP_hsk && RBARInfo[i][BAR_RESP] && 
               (BID == RBARInfo[i][BAR_IDHI:BAR_IDLO])&& (i < RBARIndex) &&
               !W_BAR_POP_found )
            begin
              BAR_Pop_vector[i] = 1'b1;
              W_BAR_POP_found = 1'b1;
            end
          end
        end
      end
    end
  end
  always @(R_BAR_RESP_hsk or W_BAR_RESP_hsk or RID or BID or BARInfo_Delta)
  begin
    R_BAR_RESP_Match = '0;
    W_BAR_RESP_Match = '0;
    if (R_BAR_RESP_hsk )
    begin
      //find the location that the rresp belongs to 
      for (int i = 1; i<= MAX_BARRIERS; i++)
      begin
        if (i <= BARIndex_max)
        begin
          if (!R_BAR_RESP_Match)
          begin
            if ((RID == RBARInfo[i][BAR_IDHI:BAR_IDLO]) && 
                !RBARInfo[i][BAR_RESP] && (i < RBARIndex))
            begin
              R_BAR_RESP_Match = i;
            end
          end
        end
      end
    end

    if (W_BAR_RESP_hsk )
    begin
      //find the location that the BRESP belongs to 
      for (int i = 1; i<= MAX_BARRIERS; i++)
      begin
        if (i <= BARIndex_max)
        begin
          if (!W_BAR_RESP_Match)
          begin
            if ((BID == WBARInfo[i][BAR_IDHI:BAR_IDLO]) && 
                !WBARInfo[i][BAR_RESP] && (i < WBARIndex))
            begin
              W_BAR_RESP_Match = i;
            end
          end
        end
      end
    end
  end
  
  reg[1:0] previous_pops;
  always @(posedge `ACE_AUX_CLK or negedge `ACE_AUX_RSTn)
  begin
    if (!`ACE_AUX_RSTn)
    begin
      RBARIndex <= 1;
      WBARIndex <= 1;
      BAR_pops_num = '0;
      for (int i = 1; i<=MAX_BARRIERS; i++)
      begin
        RBARInfo[i] <= '0;
        WBARInfo[i] <= '0;
        INFO_W_BAR_PUSH <= 1'b0;
        INFO_R_BAR_PUSH <= 1'b0;
        INFO_W_BAR_RESP <= 1'b0;
        INFO_R_BAR_RESP <= 1'b0;
        INFO_BAR_POP    <= 1'b0;
      end
    end
    else
    begin
      reg [LOG2MAXBARRIERS:0] RBARIndex_next;
      reg [LOG2MAXBARRIERS:0] WBARIndex_next;
      BAR_pops_num = '0;
      BAR_Pop_vector_mask = '0;
      for (int b = 1; b<=MAX_BARRIERS; b++)
      begin
        if (BAR_Pop_vector[b])
          BAR_pops_num = BAR_pops_num + 1;
      end
      if (|BAR_Pop_vector) 
      begin
        INFO_BAR_POP    <= ~INFO_BAR_POP;
      end
      if (R_BAR_RESP_hsk)
      begin
        INFO_R_BAR_RESP <= ~INFO_R_BAR_RESP;
        assert(R_BAR_RESP_Match != 0);
      end 
      if (W_BAR_RESP_hsk)
      begin
        INFO_W_BAR_RESP <= ~INFO_W_BAR_RESP;
        assert(W_BAR_RESP_Match != 0);
      end
      RBARIndex_next = RBARIndex + RBARPush - BAR_pops_num;
      WBARIndex_next = WBARIndex + WBARPush - BAR_pops_num;
      
      for (int b = 1; b<=MAX_BARRIERS; b++)
      begin
        previous_pops = 2'b00;
        if (|(BAR_Pop_vector & BAR_Pop_vector_mask))
        begin
          //determine if there are one or two pops lower down
          //there can't be more than 2
          if (^(BAR_Pop_vector & BAR_Pop_vector_mask))//there is one
          begin
           previous_pops = 2'b01;
          end
          else
          begin
           previous_pops = 2'b10;
          end
        end
        if ((previous_pops == 2'b01) && (b < MAX_BARRIERS))
          assert(!(BAR_Pop_vector[b] && BAR_Pop_vector[b+1]));
        if (previous_pops == 2'b10) begin
          if (b < MAX_BARRIERS) assert(!BAR_Pop_vector[b+1]);
        end
        case ({previous_pops,BAR_Pop_vector[b],((b < MAX_BARRIERS) ? BAR_Pop_vector[b+1] : 1'b0)})
          4'b0010, 4'b0100:
          begin
            //shift
            if (b < MAX_BARRIERS)
            begin
              WBARInfo[b] <= WBARInfo[b + 1 ];
              RBARInfo[b] <= RBARInfo[b + 1 ];
              if ((b + 1) == W_BAR_RESP_Match)
              begin
                WBARInfo[b][BAR_RESP] <= 1'b1;
                INFO_W_BAR_RESP <= ~INFO_W_BAR_RESP;
              end
              if ((b + 1) == R_BAR_RESP_Match)
              begin
                RBARInfo[b][BAR_RESP] <= 1'b1;
                INFO_R_BAR_RESP <= ~INFO_R_BAR_RESP;
              end
            end
          end
          4'b0011, 4'b1000, 4'b0101, 4'b0110, 4'b1000:
          begin
            //shift
            if ((b+2) <= MAX_BARRIERS)
            begin
              WBARInfo[b] <= WBARInfo[b + 2 ];
              RBARInfo[b] <= RBARInfo[b + 2 ];
            end
          end
          default:
          begin
            WBARInfo[b] <= WBARInfo[b];
            RBARInfo[b] <= RBARInfo[b];
            if ((b) == W_BAR_RESP_Match)
            begin
              WBARInfo[b][BAR_RESP] <= 1'b1;
              INFO_W_BAR_RESP <= ~INFO_W_BAR_RESP;
            end
            if ((b) == R_BAR_RESP_Match)
            begin
              RBARInfo[b][BAR_RESP] <= 1'b1;
              INFO_R_BAR_RESP <= ~INFO_R_BAR_RESP;
            end
          end
        endcase
        BAR_Pop_vector_mask[b] = 1'b1;
        if (b >= WBARIndex_next)
        begin
          WBARInfo[b] <= '0;
        end
        if (b >= RBARIndex_next)
        begin
          RBARInfo[b] <= '0;
        end
      end
      //count the number of pops

      assert ($countones(BAR_Pop_vector) <= 2);
      if (RBARPush)
      begin
        RBARInfo[RBARIndex - BAR_pops_num][BAR_IDHI:BAR_IDLO] <= ARID;
        RBARInfo[RBARIndex - BAR_pops_num][BAR_PROTHI:BAR_PROTLO] <= ARPROT;
        RBARInfo[RBARIndex - BAR_pops_num][BAR_DOMAIN_HI:BAR_DOMAIN_LO] <= ARDOMAIN;
        RBARInfo[RBARIndex - BAR_pops_num][BAR_BAR1] <= ARBAR[1];
        RBARInfo[RBARIndex - BAR_pops_num][BAR_RESP] <= 1'b0;
        INFO_R_BAR_PUSH <= ~INFO_R_BAR_PUSH;
      end
      if (WBARPush)
      begin
        WBARInfo[WBARIndex - BAR_pops_num][BAR_IDHI:BAR_IDLO] <= AWID;
        WBARInfo[WBARIndex - BAR_pops_num][BAR_PROTHI:BAR_PROTLO] <= AWPROT;
        WBARInfo[WBARIndex - BAR_pops_num][BAR_DOMAIN_HI:BAR_DOMAIN_LO] <= AWDOMAIN;
        WBARInfo[WBARIndex - BAR_pops_num][BAR_BAR1] <= AWBAR[1];
        WBARInfo[WBARIndex - BAR_pops_num][BAR_RESP] <= 1'b0;
        INFO_W_BAR_PUSH <= ~INFO_W_BAR_PUSH;
      end


      RBARIndex <= RBARIndex_next;
      WBARIndex <= WBARIndex_next;

    end
  end
//------------------------------------------------------------------------------
// INDEX:   11) DVM Tracking
//------------------------------------------------------------------------------ 
  localparam DVM_ADDITIONAL_ID_LO      = 0;
  localparam DVM_ADDITIONAL_ID_HI      = DVM_ADDITIONAL_ID_LO + ID_MAX_R;
  localparam DVM_ADDITIONAL_RRESP_FIRST  = DVM_ADDITIONAL_ID_HI + 1;
  localparam DVM_ADDITIONAL_RRESP_1_  = DVM_ADDITIONAL_RRESP_FIRST + 1;
  localparam DVM_ADDITIONAL_INFO_HI   = DVM_ADDITIONAL_RRESP_1_ + 1 ;

  reg        [LOG2MAXRBURSTS:0] dvm_sync_ar_ctr;
  reg        [8:0] dvm_sync_ac_ctr;
  reg        ar_dvm_msg_additional_trans;
  reg        ac_dvm_msg_additional_trans;
  reg        [ID_MAX_R:0] ar_dvm_msg_additional_trans_id;
  wire       dvm_sync_ar = ARVALID && ARREADY && (ARSNOOP == `ACEPC_ARSNOOP_DVMMESSAGE) && ARADDR[15] && !ar_dvm_msg_additional_trans;
  wire       dvm_complete_ac = ACVALID && ACREADY && (ACSNOOP == `ACEPC_ACSNOOP_DVMCOMPLETE);
  wire       dvm_sync_ac = ACVALID && ACREADY && (ACSNOOP == `ACEPC_ACSNOOP_DVMMESSAGE) && ACADDR[15] && !ac_dvm_msg_additional_trans;
  wire       dvm_complete_ar = ARVALID && ARREADY && (ARSNOOP == `ACEPC_ARSNOOP_DVMCOMPLETE);
  reg        AR_DVM_ADDITONAL_INFO_PUSH;
  reg        AR_DVM_ADDITONAL_INFO_POP;
  reg        AR_DVM_ADDITONAL_INFO_RESP;
  wire       [2:0] AR_DVM_ADDITIONAL_Info_Delta;
  assign     AR_DVM_ADDITIONAL_Info_Delta = {AR_DVM_ADDITONAL_INFO_PUSH,AR_DVM_ADDITONAL_INFO_POP,AR_DVM_ADDITONAL_INFO_RESP};
  reg        [DVM_ADDITIONAL_INFO_HI -1:0] AR_DVM_ADDITIONAL_Info[1:MAXRBURSTS];
  
  reg        [LOG2MAXRBURSTS:0] AR_DVM_ADDITIONAL_Index; //next available location in CAM
  reg        [LOG2MAXRBURSTS:0] AR_DVM_ADDITIONAL_RIDMatch1; //location of oldest transaction in Cam matching RID for first part of a DVM additional
  reg        [LOG2MAXRBURSTS:0] AR_DVM_ADDITIONAL_RIDMatch2; //location of oldest transaction in Cam matching RID for second part of a DVM additional
  wire       AR_DVM_ADDITIONAL_Push ;
  assign     AR_DVM_ADDITIONAL_Push = ARVALID && ARREADY && (ARSNOOP == `ACEPC_ARSNOOP_DVMMESSAGE) 
                                   && ARADDR[0] && !ar_dvm_msg_additional_trans ;
  wire       AR_DVM_ADDITIONAL_Pop ;
  assign     AR_DVM_ADDITIONAL_Pop = RVALID && RREADY && AR_DVM_ADDITIONAL_RIDMatch2 && 
             (RID == AR_DVM_ADDITIONAL_Info[AR_DVM_ADDITIONAL_RIDMatch2][DVM_ADDITIONAL_ID_HI:DVM_ADDITIONAL_ID_LO]) &&
             AR_DVM_ADDITIONAL_Info[AR_DVM_ADDITIONAL_RIDMatch2][DVM_ADDITIONAL_RRESP_FIRST] ;



   // Update the Index values
  always @(posedge `ACE_AUX_CLK or negedge `ACE_AUX_RSTn)
  begin
    if(!`ACE_AUX_RSTn)
    begin
      AR_DVM_ADDITIONAL_Index <= 1;
    end else
    begin
      AR_DVM_ADDITIONAL_Index <= AR_DVM_ADDITIONAL_Index + AR_DVM_ADDITIONAL_Push - AR_DVM_ADDITIONAL_Pop;
    end
  end
  // Find the index of the first item in the CAM that matches the current RID
  always @(RID or  AR_DVM_ADDITIONAL_Info_Delta  or AR_DVM_ADDITIONAL_Push or AR_DVM_ADDITIONAL_Pop or 
           AR_DVM_ADDITIONAL_Index or RIDMatch)
  begin : p_AR_DVM_ADDITIONAL_RIDMatch 
    integer    i;  // loop counter
    AR_DVM_ADDITIONAL_RIDMatch1 = '0;
    AR_DVM_ADDITIONAL_RIDMatch2 = '0;
    for (i=MAXRBURSTS; i>0 ; i=i-1)
    begin
      if (i < AR_DVM_ADDITIONAL_Index) 
      begin
        if ((RID ==  AR_DVM_ADDITIONAL_Info[i][DVM_ADDITIONAL_ID_HI:DVM_ADDITIONAL_ID_LO]) )
        begin
          if (ARInfo[RIDMatch][AR_DVM_ADDITIONAL]) 
          begin
            AR_DVM_ADDITIONAL_RIDMatch1 = i;
          end
          else if (AR_DVM_ADDITIONAL_Info[i][DVM_ADDITIONAL_RRESP_FIRST])
          begin
            AR_DVM_ADDITIONAL_RIDMatch2 = i;
          end
        end
      end
    end

  end

  always @(posedge `ACE_AUX_CLK or negedge `ACE_AUX_RSTn)
  begin
    integer    i; //loop counter
    if (!`ACE_AUX_RSTn)
    begin
      for (i = 1; i <= MAXRBURSTS; i = i + 1)
      begin
        AR_DVM_ADDITIONAL_Info[i] <= '0;
      end
      AR_DVM_ADDITONAL_INFO_PUSH <= 1'b0;
      AR_DVM_ADDITONAL_INFO_POP <= 1'b0;
      AR_DVM_ADDITONAL_INFO_RESP <= 1'b0;
    end
    else
    begin
      if (RVALID && RREADY)
      begin
        AR_DVM_ADDITIONAL_Info[AR_DVM_ADDITIONAL_RIDMatch1][DVM_ADDITIONAL_RRESP_FIRST] <= 1'b1;
        AR_DVM_ADDITIONAL_Info[AR_DVM_ADDITIONAL_RIDMatch1][DVM_ADDITIONAL_RRESP_1_] <= RRESP[1];
        AR_DVM_ADDITONAL_INFO_RESP <= ~AR_DVM_ADDITONAL_INFO_RESP;
      end
      if (AR_DVM_ADDITIONAL_Pop)
      begin : p_AR_DVM_ADDITIONAL_Pop
        AR_DVM_ADDITONAL_INFO_POP <= ~AR_DVM_ADDITONAL_INFO_POP;
        AR_DVM_ADDITIONAL_Info[MAXRBURSTS] <= '0;
        for (int i = 1; i < MAXRBURSTS; i = i + 1)
        begin
          if (i >= AR_DVM_ADDITIONAL_RIDMatch2 && i < AR_DVM_ADDITIONAL_Index)
          begin
            AR_DVM_ADDITIONAL_Info[i] <= AR_DVM_ADDITIONAL_Info[i+1];
          end
        end
        AR_DVM_ADDITIONAL_Info[AR_DVM_ADDITIONAL_Index] <= '0;
      end//if (DVM_ADDITIONAL_Pop)
 
 
      if (AR_DVM_ADDITIONAL_Push)
      begin
        AR_DVM_ADDITIONAL_Info[AR_DVM_ADDITIONAL_Index - AR_DVM_ADDITIONAL_Pop][DVM_ADDITIONAL_ID_HI:DVM_ADDITIONAL_ID_LO] <= ARID;
        AR_DVM_ADDITIONAL_Info[AR_DVM_ADDITIONAL_Index - AR_DVM_ADDITIONAL_Pop][DVM_ADDITIONAL_RRESP_FIRST] <= 1'b0;
        AR_DVM_ADDITIONAL_Info[AR_DVM_ADDITIONAL_Index - AR_DVM_ADDITIONAL_Pop][DVM_ADDITIONAL_RRESP_1_] <= 1'b0;
        AR_DVM_ADDITONAL_INFO_PUSH <= ~AR_DVM_ADDITONAL_INFO_PUSH;
      end//if (DVM_ADDITIONAL_Push)
      
    end
  end

  
  always @(posedge `ACE_AUX_CLK or negedge `ACE_AUX_RSTn)
  begin: p_dvm_sync_ar_ctr
    if(!`ACE_AUX_RSTn)
    begin
      dvm_sync_ar_ctr <= '0;
      dvm_sync_ac_ctr <= '0;
    end else
    begin
      dvm_sync_ar_ctr <= dvm_sync_ar_ctr + dvm_sync_ar - dvm_complete_ac;
      dvm_sync_ac_ctr <= dvm_sync_ac_ctr + dvm_sync_ac - dvm_complete_ar;
    end
  end
  
  always @(posedge `ACE_AUX_CLK or negedge `ACE_AUX_RSTn)
  begin: p_dvm_msg_requires_completion
    if(!`ACE_AUX_RSTn)
    begin
      ar_dvm_msg_additional_trans <= 0;
      ac_dvm_msg_additional_trans <= 0;
    end else
    begin
      if ( ARVALID && ARREADY && (ARSNOOP == `ACEPC_ARSNOOP_DVMMESSAGE) && ARADDR[0] && !ar_dvm_msg_additional_trans )
      begin
        ar_dvm_msg_additional_trans <= 1;
        ar_dvm_msg_additional_trans_id <= ARID;
      end

      if ( ARVALID && ARREADY && (ARSNOOP == `ACEPC_ARSNOOP_DVMMESSAGE) && !ARADDR[0] && ar_dvm_msg_additional_trans )
        ar_dvm_msg_additional_trans <= 0;

      if ( ACVALID && ACREADY && (ACSNOOP == `ACEPC_ACSNOOP_DVMMESSAGE) && ACADDR[0] && !ac_dvm_msg_additional_trans )
        ac_dvm_msg_additional_trans <= 1;

      if ( ACVALID && ACREADY && (ACSNOOP == `ACEPC_ACSNOOP_DVMMESSAGE) && !ACADDR[0] && ac_dvm_msg_additional_trans )
        ac_dvm_msg_additional_trans <= 0;
    end
  end
  //simpler case for tracking DVM's with additional transactions on the snoop
  //response channel
  always @(posedge `ACE_AUX_CLK or negedge `ACE_AUX_RSTn)
  begin
    if (!`ACE_AUX_RSTn)
    begin
      AC_DVM_ADD_CRESP <= 2'b00;
    end
    else
    begin
      if (CRVALID && CRREADY)
      begin
        if (ACInfo[snoop_dataresp_cnt + 1][AC_DVM_ADDITIONAL])
        begin
          AC_DVM_ADD_CRESP[1] <= 1'b1;
          AC_DVM_ADD_CRESP[0] <= CRRESP[1];
        end
        else
        begin
          AC_DVM_ADD_CRESP[1] <= 1'b0;
        end
      end
    end
  end
//------------------------------------------------------------------------------
// INDEX:   12) Exclusive sequence checks
//------------------------------------------------------------------------------ 

   // =====
   // INDEX:        - ACE_ERRM_XSTORE_IN_XSEQ_PROP1
   // INDEX:        - ACE_ERRM_XSTORE_IN_XSEQ_PROP2
   // =====
  reg        [LOG2MAXRBURSTS-1:0] locked_seqs_in_progress_cnt;
  reg        store_in_progress;

  always @(posedge `ACE_AUX_CLK or negedge `ACE_AUX_RSTn)
  begin
    if(!`ACE_AUX_RSTn)
    begin
      locked_seqs_in_progress_cnt <= '0;
    end 
    else
    begin
      locked_seqs_in_progress_cnt <= locked_seqs_in_progress_cnt + (ARVALID && ARREADY && ARLOCK && ^ARDOMAIN) 
                                   - (RVALID && RREADY && RLAST && ARInfo[RIDMatch][AR_LOCK] && ARInfo[RIDMatch][AR_SHAREABLE]);
    end
  end
  always @(posedge `ACE_AUX_CLK or negedge `ACE_AUX_RSTn)
  begin
    if(!`ACE_AUX_RSTn)
    begin
      store_in_progress <= 1'b0;
    end 
    else
    begin
      store_in_progress <=  store_in_progress + 
                           (ARVALID && ARREADY && ARLOCK && (ARSNOOP == `ACEPC_ARSNOOP_CLEANUNIQUE)) 
                                   - (RVALID && RREADY && RLAST && ARInfo[RIDMatch][AR_LOCK] && 
                                          (ARInfo[RIDMatch][ARSNOOP_HI:ARSNOOP_LO] == `ACEPC_ARSNOOP_CLEANUNIQUE));
    end
  end
  
  property ACE_ERRM_XSTORE_IN_XSEQ_PROP1;    
    @(posedge `ACE_SVA_CLK) 
    `ACE_SVA_RSTn && !($isunknown({locked_seqs_in_progress_cnt,ARVALID,ARLOCK,ARSNOOP })) && SINGLE_EXCL
     && ARVALID && ARLOCK && (ARSNOOP == `ACEPC_ARSNOOP_CLEANUNIQUE)
     |-> ~|locked_seqs_in_progress_cnt;
  endproperty
  ace_errm_xstore_in_xseq_prop1: assert property(ACE_ERRM_XSTORE_IN_XSEQ_PROP1) else
  `ARM_AMBA4_PC_MSG_ERR(`ERRM_XSTORE_IN_XSEQ);

  property ACE_ERRM_XSTORE_IN_XSEQ_PROP2;    
    @(posedge `ACE_SVA_CLK) 
    `ACE_SVA_RSTn && !($isunknown({ARVALID,store_in_progress,ARLOCK,ARDOMAIN})) && SINGLE_EXCL
     && store_in_progress && ARVALID && ^ARDOMAIN 
     |-> !ARLOCK;
  endproperty
  ace_errm_xstore_in_xseq_prop2: assert property(ACE_ERRM_XSTORE_IN_XSEQ_PROP2) else
  `ARM_AMBA4_PC_MSG_ERR(`ERRM_XSTORE_IN_XSEQ);


//------------------------------------------------------------------------------
// INDEX:   13) Intertransaction status 
//------------------------------------------------------------------------------ 
  //wires to indicate if the current valid ARID is already present as
  //a barrier in the ARInfo, AWInfo, RBARInfo or WBARInfo Cams
  //On ARVALID, there is an existing barrier/normal transaction of 
  //the same ID currently in the read Cam
  reg        ERROR_AC_IN_RRESP;       //signal indicating a snoop hazard error
  reg        SW_ERROR_AC_IN_RRESP;    //signal indicating a snoop hazard error
  reg        ERROR_RRESP_IN_SNOOP;    //signal indicating a snoop hazard error
  reg        SW_ERROR_RRESP_IN_SNOOP; //signal indicating a snoop hazard error
  reg        ERROR_AC_IN_BRESP;       //signal indicating a snoop hazard error
  reg        SW_ERROR_AC_IN_BRESP;    //signal indicating a snoop hazard error
  reg        ERROR_BRESP_IN_SNOOP;    //signal indicating a snoop hazard error
  reg        SW_ERROR_BRESP_IN_SNOOP; //signal indicating a snoop hazard error
  reg        ERROR_CRRESP_IN_WB_WC;   //signal indicating a hazard for CRRESP_IN_WB_WC
  reg        ERROR_AR_IN_CMAINT;      //signal indicating a hazard during cache maintenance
  reg        ERROR_AW_IN_CMAINT;      //signal indicating a hazard during cache maintenance
  reg        ERROR_CMAINT_IN_READ;    //signal indicating a hazardous cache maintenance
  reg        ERROR_CMAINT_IN_WRITE;   //signal indicating a hazardous cache maintenance
  reg        REC_R_W_HAZARD;          //signal indicating a read_write hazard
  reg        REC_W_R_HAZARD;          //signal indicating a read_write hazard
  reg        REC_W_W_HAZARD;          //signal indicating a read_write hazard

  always @(ARInfo_Delta or ARVALID or ARID or ArPush or ArPop)
  begin
    ARID_ARInfo_isNORMAL = 1'b0;
    ARID_ARInfo_isDVM = 1'b0;
    if (ARVALID)
    begin
      for (int i = 1; i<=MAXRBURSTS; i++)
      begin
        if (i < ARIndex)
        begin
          if (ARID == ARInfo[i][ARID_HI:ARID_LO] && !ARInfo[i][AR_R_LAST]) 
          begin
            if (ARInfo[i][AR_DVM] )
            begin
              ARID_ARInfo_isDVM = 1'b1;
            end
            else if (!ARInfo[i][AR_BARRIER])
            begin
              ARID_ARInfo_isNORMAL = 1'b1;
            end
          end
        end
      end
    end
  end
  //On ARVALID, there is an existing barrier/normal transaction of the 
  //same ID currently in the write Cam
  always @(AWInfo_Delta or ARVALID or ARID)
  begin
    ARID_AWInfo_isNORMAL = 1'b0;
    if (ARVALID)
    begin
      for (int i = 1; i<=MAXWBURSTS; i++)
      begin
        if (i < AWIndex)
        begin
        if (ARID == AWInfo[i][AWID_HI:AWID_LO] && AWInfo[i][AW_ADDR] && !AWInfo[i][AW_BRESP_hsk])
          begin
            if (!AWInfo[i][AW_BARRIER])
            begin
              ARID_AWInfo_isNORMAL = 1'b1;
            end
          end
        end
      end
    end
  end
  //On ARVALID, there is an existing barrier of the same 
  //ID currently in the read barrier fifo
  always @(BARInfo_Delta or ARVALID or ARID)
  begin
    ARID_RBARInfo_isBAR = 1'b0;
    if (ARVALID)
    begin
      for (int i = 1; i<=MAXRBURSTS; i++)
      begin
        if (i < RBARIndex)
        begin
          if (ARID == RBARInfo[i][BAR_IDHI:BAR_IDLO] )
          begin
            ARID_RBARInfo_isBAR = 1'b1;
          end
        end
      end
    end
  end
  //On ARVALID, there is an existing barrier of the same ID currently in the write barrier
  //fifo
  always @(BARInfo_Delta or ARVALID or ARID)
  begin
    ARID_WBARInfo_isBAR = 1'b0;
    if (ARVALID)
    begin
      for (int i = 1; i<=MAXWBURSTS; i++)
      begin
        if (i < WBARIndex)
        begin
          if (ARID == WBARInfo[i][BAR_IDHI:BAR_IDLO] )
          begin
            ARID_WBARInfo_isBAR = 1'b1;
          end
        end
      end
    end
  end
  //On ARVALID or AWVALID, there is an existing barrier/normal transaction of the same ID currently on the AW address
  //channel
  always @(ARVALID or ARID or AWVALID or AWID or AWBAR or ARBAR or ARSNOOP)
  begin
    ARID_AWID_isBAR = 1'b0;
    ARID_AWID_isNORMAL = 1'b0;
    AWID_ARID_isBAR = 1'b0;
    AWID_ARID_isNORMAL = 1'b0;
    AWID_ARID_isDVM = 1'b0;
    if (ARVALID && AWVALID && (ARID == AWID))
    begin
      if (AWBAR[0])
      begin
        ARID_AWID_isBAR = 1'b1;
      end
      else
      begin
        ARID_AWID_isNORMAL = 1'b1;
      end
      if (ARBAR[0])
      begin
        AWID_ARID_isBAR = 1'b1;
      end
      else if (&ARSNOOP[3:1])
      begin
        AWID_ARID_isDVM = 1'b1;
      end
      else 
      begin
        AWID_ARID_isNORMAL = 1'b1;
      end
    end
  end

  assign ARIDisBAR =  ARID_RBARInfo_isBAR || ARID_WBARInfo_isBAR || ARID_AWID_isBAR;
  assign ARIDisNORMAL = ARID_ARInfo_isNORMAL || ARID_AWInfo_isNORMAL || ARID_AWID_isNORMAL;
  assign ARIDisDVM = ARID_ARInfo_isDVM ;


  //Wires to indicate if the current valid AWID is already present as
  //a barrier in the ARInfo, AWInfo, RBARInfo or WBARInfo Cams
  //
  //On AWVALID, there is an existing barrier/normal transaction of 
  //the same ID currently in the read Cam
  always @(ARInfo_Delta or AWVALID or AWID or ArPush or ArPop)
  begin
    AWID_ARInfo_isNORMAL = 1'b0;
    AWID_ARInfo_isDVM = 1'b0;
    if (AWVALID)
    begin
      for (int i = 1; i<=MAXRBURSTS; i++)
      begin
        if (i < ARIndex)
        begin
          if (AWID == ARInfo[i][ARID_HI:ARID_LO] && !ARInfo[i][AR_R_LAST]) 
          begin
            if (ARInfo[i][AR_DVM])
            begin
              AWID_ARInfo_isDVM = 1'b1;
            end
            else if (!ARInfo[i][AR_BARRIER])
            begin
              AWID_ARInfo_isNORMAL = 1'b1;
            end
          end
        end
      end
    end
  end
  //On AWVALID, there is an existing barrier/normal transaction of the 
  //same ID currently in the write Cam
  always @(AWInfo_Delta or AWVALID or AWID)
  begin
    AWID_AWInfo_isNORMAL = 1'b0;
    if (AWVALID)
    begin
      for (int i = 1; i<=MAXWBURSTS; i++)
      begin
        if (i < AWIndex)
        begin
          if (AWID == AWInfo[i][AWID_HI:AWID_LO] && AWInfo[i][AW_ADDR] && !AWInfo[i][AW_BRESP_hsk] )
          begin
            if (!AWInfo[i][AW_BARRIER])
            begin
              AWID_AWInfo_isNORMAL = 1'b1;
            end
          end
        end
      end
    end
  end
  //On AWVALID, there is an existing barrier of the same 
  //ID currently in the read barrier fifo
  always @(BARInfo_Delta or AWVALID or AWID)
  begin
    AWID_RBARInfo_isBAR = 1'b0;
    if (AWVALID)
    begin
      for (int i = 1; i<=MAXRBURSTS; i++)
      begin
        if (i < RBARIndex)
        begin
          if (AWID == RBARInfo[i][BAR_IDHI:BAR_IDLO] )
          begin
            AWID_RBARInfo_isBAR = 1'b1;
          end
        end
      end
    end
  end
  //On AWVALID, there is an existing barrier of the same ID currently in the write barrier
  //fifo
  always @(BARInfo_Delta or AWVALID or AWID)
  begin
    AWID_WBARInfo_isBAR = 1'b0;
    if (AWVALID)
    begin
      for (int i = 1; i<=MAXWBURSTS; i++)
      begin
        if (i < WBARIndex)
        begin
          if (AWID == WBARInfo[i][BAR_IDHI:BAR_IDLO] )
          begin
            AWID_WBARInfo_isBAR = 1'b1;
          end
        end
      end
    end
  end

  assign AWIDisBAR =  AWID_RBARInfo_isBAR || AWID_WBARInfo_isBAR || AWID_ARID_isBAR;
  assign AWIDisNORMAL = AWID_ARInfo_isNORMAL || AWID_AWInfo_isNORMAL || AWID_ARID_isNORMAL;
  assign AWIDisDVM = AWID_ARInfo_isDVM ||  AWID_ARID_isDVM;





//------------------------------------------------------------------------------
// INDEX:   14) Snoop Hazard Checks
//------------------------------------------------------------------------------ 
   // =====
   // INDEX:        - ACE_ERRS_RRESP_IN_SNOOP
   // INDEX:        - ACE_REC_SW_RRESP_IN_SNOOP
   // =====
  always @(`ACE_AUX_RSTn or RVALID or CurrentRInfo or AC_Push or CR_Pop or CD_Pop or 
            snoop_dataresp_cnt or ACInfo_tmp or ACVALID or ACSNOOP or min_r_address or max_r_address or
                          min_ac_address or max_ac_address)
  begin
    integer    i; //loop counter
    if (!`ACE_AUX_RSTn || !(RVALID ))
    begin
      ERROR_RRESP_IN_SNOOP = 1'b0;
      SW_ERROR_RRESP_IN_SNOOP = 1'b0;
    end
    else 
    begin
      ERROR_RRESP_IN_SNOOP = 1'b0;
      SW_ERROR_RRESP_IN_SNOOP = 1'b0;
      if (!CurrentRInfo[AR_BARRIER] && !CurrentRInfo[AR_DVM])
      begin
        if ( (ACSNOOP[3:1] != 3'b111) && ACVALID)
        begin
          if (overlapping(min_r_address, max_r_address,
                          min_ac_address, max_ac_address) && (ACPROT[1] == CurrentRInfo[ARPROT_1]))
          begin
            if (CurrentRInfo[AR_SHAREABLE])
            begin
              ERROR_RRESP_IN_SNOOP = 1'b1;
            end
            else
            begin
              SW_ERROR_RRESP_IN_SNOOP = 1'b1;
            end
          end
        end
        for (i = 1; i <= MAXCBURSTS; i = i + 1)
        begin
          if (i < ACInfo_index)
          begin
            if (!ACInfo[i][AC_DVM] && (i > snoop_dataresp_cnt))
            begin
              if (overlapping(min_r_address,max_r_address,
                               min_tx_address(ACInfo[i][ACADDR_HI:ACADDR_LO],`AXI4PC_ABURST_WRAP,CACHE_LINE_AxLEN_CD,CACHE_LINE_AxSIZE_CD), 
                               max_tx_address(ACInfo[i][ACADDR_HI:ACADDR_LO],`AXI4PC_ABURST_WRAP,CACHE_LINE_AxLEN_CD,CACHE_LINE_AxSIZE_CD))
                  && (ACInfo[i][ACPROT_1] == CurrentRInfo[ARPROT_1])) 
              begin
                if (CurrentRInfo[AR_SHAREABLE])
                begin
                  ERROR_RRESP_IN_SNOOP = 1'b1;
                end
                else
                begin
                  SW_ERROR_RRESP_IN_SNOOP = 1'b1;
                end
              end
            end
          end
        end
      end
    end
  end
         
  property ACE_ERRS_RRESP_IN_SNOOP;    
    @(posedge `ACE_SVA_CLK) 
    `ACE_SVA_RSTn && !($isunknown({ERROR_RRESP_IN_SNOOP})) 
     |-> !ERROR_RRESP_IN_SNOOP;
  endproperty
  ace_errs_rresp_in_snoop: assert property(ACE_ERRS_RRESP_IN_SNOOP) else
  `ARM_AMBA4_PC_MSG_ERR(`ERRS_RRESP_IN_SNOOP);

  property ACE_REC_SW_RRESP_IN_SNOOP;    
     @(posedge `ACE_SVA_CLK) 
     `ACE_SVA_RSTn && !($isunknown({SW_ERROR_RRESP_IN_SNOOP})) &&
      RecommendOn_SW 
      |-> !SW_ERROR_RRESP_IN_SNOOP;
  endproperty
  ace_rec_sw_rresp_in_snoop: assert property(ACE_REC_SW_RRESP_IN_SNOOP) else
  `ARM_AMBA4_PC_MSG_WARN(`REC_SW_RRESP_IN_SNOOP);

   // =====
   // INDEX:        - ACE_ERRS_AC_IN_RRESP
   // INDEX:        - ACE_REC_SW_AC_IN_RRESP
   // =====
  always @(`ACE_AUX_RSTn or ACVALID or ACSNOOP or ACInfo_tmp or ARInfo_Delta or ACPROT or
          AC_Push or CD_Pop or CR_Pop or min_ac_address or max_ac_address)
  begin
    integer    i; //loop counter
    if (!`ACE_AUX_RSTn || !ACVALID)
    begin
      ERROR_AC_IN_RRESP = 1'b0;
      SW_ERROR_AC_IN_RRESP = 1'b0;
    end
    else 
    begin
      ERROR_AC_IN_RRESP = 1'b0;
      SW_ERROR_AC_IN_RRESP = 1'b0;
      if ( (ACSNOOP != `ACEPC_ACSNOOP_DVMMESSAGE) && 
           (ACSNOOP != `ACEPC_ACSNOOP_DVMCOMPLETE))
      begin
        for (i = 1; i <= MAXRBURSTS; i = i + 1)
        begin
          if (i < ARIndex)
          begin
            if (ARInfo[i][AR_R_FIRST] && !ARInfo[i][AR_BARRIER] && !ARInfo[i][AR_DVM])
            begin
              if (overlapping(min_tx_address(ARInfo[i][ARADDR_HI:ARADDR_LO],
                                             ARInfo[i][ARBURST_HI:ARBURST_LO],
                                             ARInfo[i][ARLEN_HI:ARLEN_LO],
                                             ARInfo[i][ARSIZE_HI:ARSIZE_LO]),
                              max_tx_address(ARInfo[i][ARADDR_HI:ARADDR_LO],
                                             ARInfo[i][ARBURST_HI:ARBURST_LO],
                                             ARInfo[i][ARLEN_HI:ARLEN_LO],
                                             ARInfo[i][ARSIZE_HI:ARSIZE_LO]),
                              min_ac_address, max_ac_address) 
                  && (ARInfo[i][ARPROT_1] == ACPROT[1])) 
              begin
                if (ARInfo[i][AR_SHAREABLE])
                begin
                  ERROR_AC_IN_RRESP = 1'b1;
                end
                else
                begin
                  SW_ERROR_AC_IN_RRESP = 1'b1;
                end
              end
            end
          end
        end
      end
    end
  end
  property ACE_ERRS_AC_IN_RRESP;
     @(posedge `ACE_SVA_CLK) 
     `ACE_SVA_RSTn && !($isunknown(ERROR_AC_IN_RRESP)) 
      |-> !ERROR_AC_IN_RRESP;
  endproperty
  ace_errs_ac_in_rresp: assert property (ACE_ERRS_AC_IN_RRESP) else
  `ARM_AMBA4_PC_MSG_ERR(`ERRS_AC_IN_RRESP);
  
  property ACE_REC_SW_AC_IN_RRESP;    
     @(posedge `ACE_SVA_CLK) 
     `ACE_SVA_RSTn && !($isunknown({SW_ERROR_AC_IN_RRESP})) &&
      RecommendOn_SW 
      |-> !SW_ERROR_AC_IN_RRESP;
  endproperty
  ace_rec_sw_ac_in_rresp: assert property(ACE_REC_SW_AC_IN_RRESP) else
  `ARM_AMBA4_PC_MSG_WARN(`REC_SW_AC_IN_RRESP);

   // =====
   // INDEX:        - ACE_REC_SW_BRESP_IN_SNOOP
   // INDEX:        - ACE_ERRS_BRESP_IN_SNOOP
   // =====
  always @(`ACE_AUX_RSTn or BVALID or CurrentBInfo or AC_Push or CR_Pop or CD_Pop or 
            snoop_dataresp_cnt or ACInfo_tmp or ACVALID or WACK or min_b_address or max_b_address 
            or ACPROT or min_ac_address or max_ac_address)
  begin
    integer    i; //loop counter
    if (!`ACE_AUX_RSTn || !BVALID)
    begin
      ERROR_BRESP_IN_SNOOP = 1'b0;
      SW_ERROR_BRESP_IN_SNOOP = 1'b0;
    end
    else
    begin
      ERROR_BRESP_IN_SNOOP = 1'b0;
      SW_ERROR_BRESP_IN_SNOOP = 1'b0;
      if (!CurrentBInfo[AW_BARRIER] )
      begin
        if (ACVALID && (ACSNOOP[3:1] != 3'b111))
        begin
          if(overlapping(min_b_address,max_b_address,
                         min_ac_address, max_ac_address)
             && (ACPROT[1] == CurrentBInfo[AWPROT_1])) 
          begin
            if (CurrentBInfo[AW_WU] || CurrentBInfo[AW_WLU] )
            begin
              ERROR_BRESP_IN_SNOOP = 1'b1;
            end
            else
            begin
              SW_ERROR_BRESP_IN_SNOOP = 1'b1;
            end
          end
        end
        for (i = 1; i <= MAXCBURSTS; i = i + 1)
        begin
          if (i < ACInfo_index)
          begin
            if (overlapping(min_b_address,max_b_address,
                            min_tx_address(ACInfo[i][ACADDR_HI:ACADDR_LO],`AXI4PC_ABURST_WRAP,CACHE_LINE_AxLEN_CD,CACHE_LINE_AxSIZE_CD), 
                            max_tx_address(ACInfo[i][ACADDR_HI:ACADDR_LO],`AXI4PC_ABURST_WRAP,CACHE_LINE_AxLEN_CD,CACHE_LINE_AxSIZE_CD)) 
              && (i > snoop_dataresp_cnt)//data snoops have had their responses and are at the bottom
              && !ACInfo[i][AC_DVM] 
              && (CurrentBInfo[AWPROT_1] == ACInfo[i][ACPROT_1])) 
            begin
              if (CurrentBInfo[AW_WU] || CurrentBInfo[AW_WLU] )
              begin
                ERROR_BRESP_IN_SNOOP = 1'b1;
              end
              else
              begin
                SW_ERROR_BRESP_IN_SNOOP = 1'b1;
              end
            end
          end
        end
      end
    end
  end
         
  property ACE_ERRS_BRESP_IN_SNOOP;    
     @(posedge `ACE_SVA_CLK)
     `ACE_SVA_RSTn && !($isunknown({ERROR_BRESP_IN_SNOOP})) 
      |-> !ERROR_BRESP_IN_SNOOP;
  endproperty
  ace_errs_bresp_in_snoop: assert property(ACE_ERRS_BRESP_IN_SNOOP) else
  `ARM_AMBA4_PC_MSG_ERR(`ERRS_BRESP_IN_SNOOP);

  property ACE_REC_SW_BRESP_IN_SNOOP;    
     @(posedge `ACE_SVA_CLK)
     `ACE_SVA_RSTn && !($isunknown({SW_ERROR_BRESP_IN_SNOOP})) &&
     RecommendOn_SW 
      |-> !SW_ERROR_BRESP_IN_SNOOP;
  endproperty
  ace_rec_sw_bresp_in_snoop: assert property(ACE_REC_SW_BRESP_IN_SNOOP) else
  `ARM_AMBA4_PC_MSG_WARN(`REC_SW_BRESP_IN_SNOOP);
   
   
   // =====
   // INDEX:        - ACE_ERRS_AC_IN_BRESP
   // INDEX:        - ACE_REC_SW_AC_IN_BRESP
   // =====
  always @(`ACE_AUX_RSTn or ACVALID or ACSNOOP or ACInfo_tmp or AWInfo_Delta or 
          AC_Push or CD_Pop or CR_Pop or min_ac_address or max_ac_address or ACPROT)
  begin
    integer    i; //loop counter
    if (!`ACE_AUX_RSTn || !ACVALID)
    begin
      ERROR_AC_IN_BRESP = 1'b0;
      SW_ERROR_AC_IN_BRESP = 1'b0;
    end
    else 
    begin
      ERROR_AC_IN_BRESP = 1'b0;
      SW_ERROR_AC_IN_BRESP = 1'b0;
      if ( (ACSNOOP != `ACEPC_ACSNOOP_DVMMESSAGE) && (ACSNOOP != `ACEPC_ACSNOOP_DVMCOMPLETE))
      begin
        for (i = 1; i <= MAXWBURSTS; i = i + 1)
        begin
          if (i < AWIndex)
          begin
            if (overlapping(min_tx_address(AWInfo[i][AWADDR_HI:AWADDR_LO],
                                           AWInfo[i][AWBURST_HI:AWBURST_LO],
                                           AWInfo[i][AWLEN_HI:AWLEN_LO],
                                           AWInfo[i][AWSIZE_HI:AWSIZE_LO]),
                            max_tx_address(AWInfo[i][AWADDR_HI:AWADDR_LO],
                                           AWInfo[i][AWBURST_HI:AWBURST_LO],
                                           AWInfo[i][AWLEN_HI:AWLEN_LO],
                                           AWInfo[i][AWSIZE_HI:AWSIZE_LO]),           
                            min_ac_address, max_ac_address) 
                && AWInfo[i][AW_BRESP] 
                && (AWInfo[i][AWPROT_1] == ACPROT[1])  )
            begin
              if (AWInfo[i][AW_WU] || AWInfo[i][AW_WLU])
              begin
                ERROR_AC_IN_BRESP = 1'b1;
              end
              else
              begin
                SW_ERROR_AC_IN_BRESP = 1'b1;
              end
            end
          end
        end
      end
    end
  end
  property ACE_ERRS_AC_IN_BRESP;
     @(posedge `ACE_SVA_CLK) 
     `ACE_SVA_RSTn && !($isunknown(ERROR_AC_IN_BRESP)) 
      |-> !ERROR_AC_IN_BRESP;
  endproperty
  ace_errs_ac_in_bresp: assert property (ACE_ERRS_AC_IN_BRESP) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRS_AC_IN_BRESP);
  
  property ACE_REC_SW_AC_IN_BRESP;    
     @(posedge `ACE_SVA_CLK) 
     `ACE_SVA_RSTn && !($isunknown({SW_ERROR_AC_IN_BRESP})) &&
     RecommendOn_SW 
      |-> !SW_ERROR_AC_IN_BRESP;
  endproperty
  ace_rec_sw_ac_in_bresp: assert property(ACE_REC_SW_AC_IN_BRESP) else
  `ARM_AMBA4_PC_MSG_WARN(`REC_SW_AC_IN_BRESP);


  // =====
  // INDEX:        - ACE_ERRM_CRRESP_IN_WB_WC
  // =====
  always @(`ACE_AUX_RSTn or AWInfo_Delta or AC_Push or CD_Pop or CR_Pop or 
          CRVALID or AWVALID or AWSNOOP or snoop_dataresp_cnt or min_aw_address or 
          max_aw_address or AWPROT)
  begin
    integer    i; //loop counter
    logic[63:0] min_cr_address;
    logic[63:0] max_cr_address;
    if (!`ACE_AUX_RSTn || !CRVALID)
    begin
      ERROR_CRRESP_IN_WB_WC = 1'b0;
    end
    else 
    begin
      ERROR_CRRESP_IN_WB_WC = 1'b0;
      if (!ACInfo[snoop_dataresp_cnt +1][AC_DVM] ) 
      begin
        min_cr_address = min_tx_address(ACInfo[snoop_dataresp_cnt +1][ACADDR_HI:ACADDR_LO],`AXI4PC_ABURST_WRAP,CACHE_LINE_AxLEN_CD,CACHE_LINE_AxSIZE_CD); 
        max_cr_address = max_tx_address(ACInfo[snoop_dataresp_cnt +1][ACADDR_HI:ACADDR_LO],`AXI4PC_ABURST_WRAP,CACHE_LINE_AxLEN_CD,CACHE_LINE_AxSIZE_CD);

        if (AWVALID && (AWSNOOP == `ACEPC_AWSNOOP_WRITECLEAN || AWSNOOP == `ACEPC_AWSNOOP_WRITEBACK))
        begin
          if (overlapping(min_aw_address, max_aw_address,
                           min_cr_address, max_cr_address)
              && (AWPROT[1] == ACInfo[snoop_dataresp_cnt +1][ACPROT_1]))
          begin
            if (!CRRESP[`ACEPC_CRRESP_ISSHARED] || CRRESP[`ACEPC_CRRESP_PASSDIRTY])
            begin
              ERROR_CRRESP_IN_WB_WC = 1'b1;
            end
          end
        end
        for (i = 1; i <= MAXWBURSTS; i = i + 1)
        begin
          if (i < AWIndex)
          begin
            if((AWInfo[i][AW_WC] || AWInfo[i][AW_WB]) && !AWInfo[i][AW_BRESP_hsk])  //check current AW address info
            begin
              if (overlapping(min_tx_address(AWInfo[i][AWADDR_HI:AWADDR_LO],
                                              AWInfo[i][AWBURST_HI:AWBURST_LO],
                                              AWInfo[i][AWLEN_HI:AWLEN_LO],
                                              AWInfo[i][AWSIZE_HI:AWSIZE_LO]),
                               max_tx_address(AWInfo[i][AWADDR_HI:AWADDR_LO],
                                              AWInfo[i][AWBURST_HI:AWBURST_LO],
                                              AWInfo[i][AWLEN_HI:AWLEN_LO],
                                              AWInfo[i][AWSIZE_HI:AWSIZE_LO]),
                               min_cr_address, max_cr_address) 
                   && (AWInfo[i][AWPROT_1] == ACInfo[snoop_dataresp_cnt +1][ACPROT_1]))
              begin
                if (!CRRESP[`ACEPC_CRRESP_ISSHARED] || CRRESP[`ACEPC_CRRESP_PASSDIRTY])
                begin
                  ERROR_CRRESP_IN_WB_WC = 1'b1;
                end
              end
            end
          end
        end
      end
    end
  end
  property ACE_ERRM_CRRESP_IN_WB_WC;
     @(posedge `ACE_SVA_CLK) 
     `ACE_SVA_RSTn && !($isunknown({ERROR_CRRESP_IN_WB_WC,CRVALID})) && 
      CRVALID 
      |-> !ERROR_CRRESP_IN_WB_WC;
  endproperty
  ace_errm_crresp_in_wb_wc: assert property (ACE_ERRM_CRRESP_IN_WB_WC) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_CRRESP_IN_WB_WC);

  
   // =====
   // INDEX:        - ACE_ERRM_AR_IN_CMAINT
   // =====

  always @(`ACE_AUX_RSTn or ARInfo_Delta or ARVALID or ARSNOOP or min_ar_address or max_ar_address or ARDOMAIN or ARBAR or ARPROT)
  begin
    integer    i; //loop counter
    if (!`ACE_AUX_RSTn || !ARVALID )
    begin
      ERROR_AR_IN_CMAINT = 1'b0;
    end
    else 
    begin 
      ERROR_AR_IN_CMAINT = 1'b0;
      if ((ARSNOOP != `ACEPC_ARSNOOP_DVMCOMPLETE) && 
                     (ARSNOOP != `ACEPC_ARSNOOP_DVMMESSAGE) && !ARBAR[0] && ^ARDOMAIN)
      begin
        for (i = 1; i <= MAXRBURSTS; i = i + 1)
        begin
          begin
            if (i < ARIndex)
            begin
              if (ARInfo[i][ARSNOOP_HI:ARSNOOP_LO] == `ACEPC_ARSNOOP_CLEANSHARED || 
                  ARInfo[i][ARSNOOP_HI:ARSNOOP_LO] == `ACEPC_ARSNOOP_CLEANINVALID ||
                  ARInfo[i][ARSNOOP_HI:ARSNOOP_LO] == `ACEPC_ARSNOOP_MAKEINVALID ) 
              begin
                if (overlapping(min_tx_address(ARInfo[i][ARADDR_HI:ARADDR_LO], 
                                               ARInfo[i][ARBURST_HI:ARBURST_LO],
                                               ARInfo[i][ARLEN_HI:ARLEN_LO],
                                               ARInfo[i][ARSIZE_HI:ARSIZE_LO]),
                                max_tx_address(ARInfo[i][ARADDR_HI:ARADDR_LO], 
                                               ARInfo[i][ARBURST_HI:ARBURST_LO],
                                               ARInfo[i][ARLEN_HI:ARLEN_LO],
                                               ARInfo[i][ARSIZE_HI:ARSIZE_LO]),
                                min_ar_address, max_ar_address)
                     && (ARInfo[i][ARPROT_1] == ARPROT[1]) 
                     && !(ARInfo[i][AR_R_LAST]))
                begin
                  ERROR_AR_IN_CMAINT = 1'b1;
                end
              end
            end
          end
        end
      end
    end
  end
  property ACE_ERRM_AR_IN_CMAINT;
     @(posedge `ACE_SVA_CLK) 
     `ACE_SVA_RSTn && !($isunknown({ERROR_AR_IN_CMAINT,ARVALID})) && 
      ARVALID 
      |-> !ERROR_AR_IN_CMAINT;
  endproperty
  ace_errm_ar_in_cmaint: assert property (ACE_ERRM_AR_IN_CMAINT) else
  `ARM_AMBA4_PC_MSG_ERR(`ERRM_AR_IN_CMAINT);

  
   // =====
   // INDEX:        - ACE_ERRM_AW_IN_CMAINT
   // =====

  always @(`ACE_AUX_RSTn or ARInfo_Delta or 
            AWVALID or min_aw_address or max_aw_address or AWBAR or AWDOMAIN or AWPROT
            or ARVALID or min_ar_address or max_ar_address or ARSNOOP or ARPROT )
  begin
    integer    i; //loop counter
    if (!`ACE_AUX_RSTn || !AWVALID )
    begin
      ERROR_AW_IN_CMAINT = 1'b0;
    end
    else 
    begin 
      ERROR_AW_IN_CMAINT = 1'b0;
      if ( !AWBAR[0] && ^AWDOMAIN)
      begin

        if (ARVALID && (ARSNOOP == `ACEPC_ARSNOOP_CLEANSHARED || 
                        ARSNOOP == `ACEPC_ARSNOOP_CLEANINVALID || 
                        ARSNOOP == `ACEPC_ARSNOOP_MAKEINVALID)) 
        begin
          if (overlapping(min_ar_address, max_ar_address,
                          min_aw_address, max_aw_address)
              && (ARPROT[1] == AWPROT[1])) 
          begin
            ERROR_AW_IN_CMAINT = 1'b1;
          end
        end
        else
        for (i = 1; i <= MAXRBURSTS; i = i + 1)
        begin
          if (i < ARIndex)
          begin
            if (ARInfo[i][ARSNOOP_HI:ARSNOOP_LO] == `ACEPC_ARSNOOP_CLEANSHARED || 
                ARInfo[i][ARSNOOP_HI:ARSNOOP_LO] == `ACEPC_ARSNOOP_CLEANINVALID ||
                ARInfo[i][ARSNOOP_HI:ARSNOOP_LO] == `ACEPC_ARSNOOP_MAKEINVALID )
            begin
              if (overlapping(min_tx_address(ARInfo[i][ARADDR_HI:ARADDR_LO], 
                                             ARInfo[i][ARBURST_HI:ARBURST_LO],
                                             ARInfo[i][ARLEN_HI:ARLEN_LO],
                                             ARInfo[i][ARSIZE_HI:ARSIZE_LO]),
                              max_tx_address(ARInfo[i][ARADDR_HI:ARADDR_LO], 
                                             ARInfo[i][ARBURST_HI:ARBURST_LO],
                                             ARInfo[i][ARLEN_HI:ARLEN_LO],
                                             ARInfo[i][ARSIZE_HI:ARSIZE_LO]),
                              min_aw_address, max_aw_address)
                   && (ARInfo[i][ARPROT_1] == AWPROT[1]) 
                   && !(ARInfo[i][AR_R_LAST]))
              begin
                ERROR_AW_IN_CMAINT = 1'b1;
              end
            end
          end
        end
      end
    end
  end
  property ACE_ERRM_AW_IN_CMAINT;
     @(posedge `ACE_SVA_CLK) 
     `ACE_SVA_RSTn && !($isunknown({ERROR_AW_IN_CMAINT,AWVALID}) && 
      AWVALID) 
      |-> !ERROR_AW_IN_CMAINT;
  endproperty
  ace_errm_aw_in_cmaint: assert property (ACE_ERRM_AW_IN_CMAINT) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AW_IN_CMAINT);

  
   // INDEX:        - ACE_ERRM_CMAINT_IN_READ
   // =====

  always @(`ACE_AUX_RSTn or ARInfo_Delta or ARVALID or min_ar_address or max_ar_address or ARSNOOP or ARPROT)
  begin
    integer    i; //loop counter
    if (!`ACE_AUX_RSTn || !ARVALID)
    begin
      ERROR_CMAINT_IN_READ = 1'b0;
    end
    else 
    begin
      ERROR_CMAINT_IN_READ = 1'b0;
      if ((ARSNOOP == `ACEPC_ARSNOOP_CLEANSHARED) ||  
          (ARSNOOP == `ACEPC_ARSNOOP_CLEANINVALID) || 
          (ARSNOOP == `ACEPC_ARSNOOP_MAKEINVALID)) 
      begin
        for (i = 1; i <= MAXRBURSTS; i = i + 1)
        begin
          if (i < ARIndex)
          begin
            if (!ARInfo[i][AR_DVM] && !ARInfo[i][AR_BARRIER] && ARInfo[i][AR_SHAREABLE])
            begin
              if (overlapping(min_tx_address(ARInfo[i][ARADDR_HI:ARADDR_LO], 
                                             ARInfo[i][ARBURST_HI:ARBURST_LO],
                                             ARInfo[i][ARLEN_HI:ARLEN_LO],
                                             ARInfo[i][ARSIZE_HI:ARSIZE_LO]),
                              max_tx_address(ARInfo[i][ARADDR_HI:ARADDR_LO], 
                                             ARInfo[i][ARBURST_HI:ARBURST_LO],
                                             ARInfo[i][ARLEN_HI:ARLEN_LO],
                                             ARInfo[i][ARSIZE_HI:ARSIZE_LO]),
                              min_ar_address, max_ar_address)
                   && (ARInfo[i][ARPROT_1] == ARPROT[1])
                   && !(ARInfo[i][AR_R_LAST]))
              begin
                ERROR_CMAINT_IN_READ = 1'b1;
              end
            end
          end
        end
      end
    end
  end
  property ACE_ERRM_CMAINT_IN_READ;
     @(posedge `ACE_SVA_CLK) 
     `ACE_SVA_RSTn && !($isunknown({ERROR_CMAINT_IN_READ,ARVALID})) && 
      ARVALID 
      |-> !ERROR_CMAINT_IN_READ;
  endproperty
  ace_errm_cmaint_in_read: assert property (ACE_ERRM_CMAINT_IN_READ) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_CMAINT_IN_READ);

  
  
   // =====
   // INDEX:        - ACE_ERRM_CMAINT_IN_WRITE
   // =====

  always @(`ACE_AUX_RSTn or AWInfo_Delta or 
           ARVALID or min_ar_address or max_ar_address or ARSNOOP or ARPROT or
           AWVALID or min_aw_address or max_aw_address or AWBAR or AWDOMAIN or AWPROT)
  begin
    integer    i; //loop counter
    if (!`ACE_AUX_RSTn || !ARVALID)
    begin
      ERROR_CMAINT_IN_WRITE = 1'b0;
    end
    else 
    begin
      ERROR_CMAINT_IN_WRITE = 1'b0;
      if ((ARSNOOP == `ACEPC_ARSNOOP_CLEANSHARED) || 
          (ARSNOOP == `ACEPC_ARSNOOP_CLEANINVALID) || 
          (ARSNOOP == `ACEPC_ARSNOOP_MAKEINVALID) ) 
      begin
        if (AWVALID && !AWBAR[0] && ^AWDOMAIN)
        begin 
          if (overlapping(min_aw_address,max_aw_address,
                                   min_ar_address,max_ar_address)
              && (AWPROT[1] == ARPROT[1]))
          begin
            ERROR_CMAINT_IN_WRITE = 1'b1;
          end
        end

        for (i = 1; i <= MAXWBURSTS; i = i + 1)
        begin
          if ((i < AWIndex) && AWInfo[i][AW_ADDR])
          begin
            if (!AWInfo[i][AW_BARRIER] && AWInfo[i][AW_SHAREABLE])
            begin
              if (overlapping(min_tx_address(AWInfo[i][AWADDR_HI:AWADDR_LO], 
                                             AWInfo[i][AWBURST_HI:AWBURST_LO],
                                             AWInfo[i][AWLEN_HI:AWLEN_LO],
                                             AWInfo[i][AWSIZE_HI:AWSIZE_LO]),
                              max_tx_address(AWInfo[i][AWADDR_HI:AWADDR_LO], 
                                             AWInfo[i][AWBURST_HI:AWBURST_LO],
                                             AWInfo[i][AWLEN_HI:AWLEN_LO],
                                             AWInfo[i][AWSIZE_HI:AWSIZE_LO]),
                              min_ar_address,max_ar_address)
                   && (ARPROT[1] == AWInfo[i][AWPROT_1])
                   && !(AWInfo[i][AW_BRESP_hsk])) 
              begin
                ERROR_CMAINT_IN_WRITE = 1'b1;
              end
            end
          end
        end
      end
    end
  end
  property ACE_ERRM_CMAINT_IN_WRITE;
     @(posedge `ACE_SVA_CLK) 
     `ACE_SVA_RSTn && !($isunknown({ERROR_CMAINT_IN_WRITE,ARVALID})) && 
      ARVALID 
      |-> !ERROR_CMAINT_IN_WRITE;
  endproperty
  ace_errm_cmaint_in_write: assert property (ACE_ERRM_CMAINT_IN_WRITE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_CMAINT_IN_WRITE);

  
//------------------------------------------------------------------------------
// INDEX:   15)  DVM Rules
//------------------------------------------------------------------------------ 

  // =====
  // INDEX:        - ACE_ERRM_CRRESP_DVM_ERROR
  // =====
  // When CRVALID is asserted for a DVM Sync or DVM Complete transaction CRRESP must be 0
  property ACE_ERRM_CRRESP_DVM_ERROR;
    @(posedge `ACE_SVA_CLK) 
    `ACE_SVA_RSTn && !($isunknown({CRVALID,CRRESP,ACInfo[snoop_dataresp_cnt + 1][AC_DVM_SYNC],
                                   ACInfo[snoop_dataresp_cnt + 1][AC_DVM_COMPLETE],
                                   ACInfo[snoop_dataresp_cnt + 1][AC_DVM_HINT],AC_DVM_ADD_CRESP})) &&
      CRVALID && ((ACInfo[snoop_dataresp_cnt + 1][AC_DVM_SYNC] == 1'b1) || 
                  (ACInfo[snoop_dataresp_cnt + 1][AC_DVM_COMPLETE] == 1'b1) || 
                  (ACInfo[snoop_dataresp_cnt + 1][AC_DVM_HINT] == 1'b1)) && !AC_DVM_ADD_CRESP[1]
      |-> (CRRESP == 5'b00000);
  endproperty
  ace_errm_crresp_dvm_error : assert property(ACE_ERRM_CRRESP_DVM_ERROR) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_CRRESP_DVM_ERROR);

  // =====
  // INDEX:        - ACE_ERRM_CRRESP_DVM
  // =====
  // When RVALID is asserted for a DVM transaction CRRESP[4:0] must be 4'b000x0
  property ACE_ERRM_CRRESP_DVM;
    @(posedge `ACE_SVA_CLK) 
    `ACE_SVA_RSTn && !($isunknown({CRVALID,CRRESP,ACInfo[snoop_dataresp_cnt + 1][AC_DVM]})) &&
      CRVALID && (ACInfo[snoop_dataresp_cnt + 1][AC_DVM] == 1'b1) 
      |-> ((CRRESP[4:2] == 3'b000) && (CRRESP[0] == 1'b0));
  endproperty
  ace_errm_crresp_dvm : assert property(ACE_ERRM_CRRESP_DVM) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_CRRESP_DVM);

  // =====
  // INDEX:        - ACE_ERRM_DVM_CTL
  // =====
  property ACE_ERRM_DVM_CTL;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn && !($isunknown({ARVALID,ARSNOOP,ARDOMAIN,ARBURST,ARLEN,ARSIZE,ARCACHE,ARLOCK,ARBAR})) &&
      ARVALID && (ARSNOOP == `ACEPC_ARSNOOP_DVMCOMPLETE || ARSNOOP == `ACEPC_ARSNOOP_DVMMESSAGE)
      |-> (^ARDOMAIN &&
           ARBURST == `AXI4PC_ABURST_INCR &&
           ARLEN == 8'b00000000 &&
           ARSIZE == CACHE_LINE_AxSIZE &&
           ARCACHE == 4'b0010 &&
           ARLOCK == 1'b0 &&
           ARBAR[0] == 1'b0);
  endproperty
  ace_errm_dvm_ctl: assert property (ACE_ERRM_DVM_CTL) else
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_DVM_CTL);
    
  // =====
  // INDEX:        - ACE_ERRS_DVM_COMPLETE_CTL
  // =====
  property ACE_ERRS_DVM_COMPLETE_CTL;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn && !($isunknown({ACVALID,ACSNOOP,ACADDR})) &&
      ACVALID && (ACSNOOP == `ACEPC_ACSNOOP_DVMCOMPLETE )
      |-> ( ACADDR == {ADDR_WIDTH{1'b0}});
  endproperty
  ace_errs_dvm_complete_ctl: assert property (ACE_ERRS_DVM_COMPLETE_CTL) else
    `ARM_AMBA4_PC_MSG_ERR(`ERRS_DVM_COMPLETE_CTL);

  // =====
  // INDEX:        - ACE_ERRM_DVM_COMPLETE_CTL
  // =====
  property ACE_ERRM_DVM_COMPLETE_CTL;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn && !($isunknown({ARVALID,ARSNOOP,ARADDR})) &&
      ARVALID && (ARSNOOP == `ACEPC_ARSNOOP_DVMCOMPLETE )
      |-> ( ARADDR == {ADDR_WIDTH{1'b0}});
  endproperty
  ace_errm_dvm_complete_ctl: assert property (ACE_ERRM_DVM_COMPLETE_CTL) else
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_DVM_COMPLETE_CTL);

  // =====
  // INDEX:        - ACE_ERRM_DVM_SYNC
  // =====
  // Can only have one outstanding DVM message that requires a completion message
  property ACE_ERRM_DVM_SYNC;
    @(posedge `ACE_SVA_CLK)
      `ACE_SVA_RSTn && !($isunknown({dvm_sync_ar,dvm_sync_ar_ctr})) &&
       ARVALID && (ARSNOOP == `ACEPC_ARSNOOP_DVMMESSAGE) && ARADDR[15] && !ar_dvm_msg_additional_trans
      |-> (dvm_sync_ar_ctr == 0);
  endproperty
  ace_errm_dvm_sync: assert property(ACE_ERRM_DVM_SYNC) else
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_DVM_SYNC);

  // =====
  // INDEX:        - ACE_ERRS_DVM_COMPLETE
  // =====
  // DVM complete message received but there is no outstanding DVM message that requires a completion message
  property ACE_ERRS_DVM_COMPLETE;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn && !($isunknown({ACVALID,ACSNOOP,dvm_sync_ar_ctr})) &&
       ACVALID && (ACSNOOP == `ACEPC_ACSNOOP_DVMCOMPLETE )
      |-> (dvm_sync_ar_ctr > 0);
  endproperty
  ace_errs_dvm_complete : assert property (ACE_ERRS_DVM_COMPLETE) else
    `ARM_AMBA4_PC_MSG_ERR(`ERRS_DVM_COMPLETE);
        
  // =====
  // INDEX:        - ACE_ERRM_DVM_COMPLETE
  // =====
  // DVM complete message received but there is no outstanding DVM message that requires a completion message
  property ACE_ERRM_DVM_COMPLETE;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn && !($isunknown({ARVALID,ARSNOOP,dvm_sync_ac_ctr})) &&
       ARVALID && (ARSNOOP == `ACEPC_ARSNOOP_DVMCOMPLETE )
      |-> (dvm_sync_ac_ctr > 0);
  endproperty
  ace_errm_dvm_complete : assert property (ACE_ERRM_DVM_COMPLETE) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_DVM_COMPLETE);

  // =====
  // INDEX:        - ACE_ERRM_DVM_TYPES
  // =====
  property ACE_ERRM_DVM_TYPES;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn && !($isunknown({ARVALID,ARSNOOP,ar_dvm_msg_additional_trans,ARADDR})) &&
      ARVALID && (ARSNOOP == `ACEPC_ARSNOOP_DVMMESSAGE) && !ar_dvm_msg_additional_trans
      |-> (ARADDR[14:12] == `ACEPC_DVM_TLB_INVALIDATE) || 
        (ARADDR[14:12] == `ACEPC_DVM_BRAN_PRED_INVALIDATE) || 
        (ARADDR[14:12] == `ACEPC_DVM_PHY_INST_CACHE_INVALIDATE)  || 
        (ARADDR[14:12] == `ACEPC_DVM_VIR_INST_CACHE_INVALIDATE) || 
        (ARADDR[14:12] == `ACEPC_DVM_SYNC)  || 
        (ARADDR[14:12] == `ACEPC_DVM_HINT);
  endproperty
  ace_errm_dvm_types : assert property (ACE_ERRM_DVM_TYPES) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_DVM_TYPES);

  // =====
  // INDEX:        - ACE_ERRS_DVM_TYPES
  // =====
  property ACE_ERRS_DVM_TYPES;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn && !($isunknown({ACVALID,ACSNOOP,ac_dvm_msg_additional_trans,ACADDR})) &&
      ACVALID && (ACSNOOP == `ACEPC_ACSNOOP_DVMMESSAGE) && !ac_dvm_msg_additional_trans
      |-> (ACADDR[14:12] == `ACEPC_DVM_TLB_INVALIDATE) || 
        (ACADDR[14:12] == `ACEPC_DVM_BRAN_PRED_INVALIDATE) || 
        (ACADDR[14:12] == `ACEPC_DVM_PHY_INST_CACHE_INVALIDATE)  || 
        (ACADDR[14:12] == `ACEPC_DVM_VIR_INST_CACHE_INVALIDATE) || 
        (ACADDR[14:12] == `ACEPC_DVM_SYNC)  || 
        (ACADDR[14:12] == `ACEPC_DVM_HINT);
  endproperty
   ace_errs_dvm_types : assert property (ACE_ERRS_DVM_TYPES) else 
     `ARM_AMBA4_PC_MSG_ERR(`ERRS_DVM_TYPES);

  // =====
  // INDEX:        - ACE_ERRM_DVM_RESVD_1
  // =====
  property ACE_ERRM_DVM_RESVD_1;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn && !($isunknown({ARVALID,ARSNOOP,ar_dvm_msg_additional_trans,ARADDR})) &&
      ARVALID && (ARSNOOP == `ACEPC_ARSNOOP_DVMMESSAGE) && !ar_dvm_msg_additional_trans && (ARADDR[14:12] != `ACEPC_DVM_HINT)
      |-> ( ~|ARADDR[4:1]  && !ARADDR[7] ); 
  endproperty
  ace_errm_dvm_resvd_1 : assert property(ACE_ERRM_DVM_RESVD_1) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_DVM_RESVD_1);
   
  // =====
  // INDEX:        - ACE_ERRM_DVM_RESVD_2
  // =====
  property ACE_ERRM_DVM_RESVD_2;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn && !($isunknown({ARVALID,ARSNOOP,ar_dvm_msg_additional_trans,ARADDR})) &&
      ARVALID && (ARSNOOP == `ACEPC_ARSNOOP_DVMMESSAGE) && ar_dvm_msg_additional_trans
      |-> ~|ARADDR[3:0] ;
  endproperty
  ace_errm_dvm_resvd_2 : assert property(ACE_ERRM_DVM_RESVD_2) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_DVM_RESVD_2);
   
  // =====
  // INDEX:        - ACE_ERRM_DVM_RESVD_3
  // =====
  property ACE_ERRM_DVM_RESVD_3;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn && !($isunknown({ARVALID,ARSNOOP,ar_dvm_msg_additional_trans,ARADDR})) &&
      ARVALID && (ARSNOOP == `ACEPC_ARSNOOP_DVMMESSAGE) &&  !ar_dvm_msg_additional_trans &&
      (ARADDR[14:12] ==  `ACEPC_DVM_SYNC) 
      |-> ARADDR[15] &&  ~|ARADDR[11:0] ;
  endproperty
  ace_errm_dvm_resvd_3 : assert property(ACE_ERRM_DVM_RESVD_3) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_DVM_RESVD_3);
   
  // =====
  // INDEX:        - ACE_ERRM_DVM_RESVD_4
  // =====
  property ACE_ERRM_DVM_RESVD_4;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn && !($isunknown({ARVALID,ARSNOOP,ar_dvm_msg_additional_trans,ARADDR})) &&
      ARVALID && (ARSNOOP == `ACEPC_ARSNOOP_DVMMESSAGE) && !ar_dvm_msg_additional_trans &&
      (ARADDR[14:12] !=  `ACEPC_DVM_SYNC) 
      |-> !ARADDR[15] ;
  endproperty
  ace_errm_dvm_resvd_4 : assert property(ACE_ERRM_DVM_RESVD_4) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_DVM_RESVD_4);
   
   
  // =====
  // INDEX:        - ACE_ERRM_DVM_MULTIPART_ID
  // =====
  // 
  property ACE_ERRM_DVM_MULTIPART_ID;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn && !($isunknown({ARVALID,ARSNOOP,ar_dvm_msg_additional_trans,ar_dvm_msg_additional_trans_id,ARID})) &&
      ARVALID && (ARSNOOP == `ACEPC_ARSNOOP_DVMMESSAGE) && ar_dvm_msg_additional_trans
      |-> (ARID == ar_dvm_msg_additional_trans_id) ;
  endproperty
  ace_errm_dvm_multipart_id : assert property(ACE_ERRM_DVM_MULTIPART_ID) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_DVM_MULTIPART_ID);
   
  // =====
  // INDEX:        - ACE_ERRM_DVM_MULTIPART_SUCCESSIVE
  // =====
  property ACE_ERRM_DVM_MULTIPART_SUCCESSIVE;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn && !($isunknown({ARVALID,ARSNOOP,ar_dvm_msg_additional_trans})) &&
      ARVALID  && ar_dvm_msg_additional_trans
      |-> ARSNOOP == `ACEPC_ARSNOOP_DVMMESSAGE;
  endproperty
  ace_errm_dvm_multipart_successive : assert property(ACE_ERRM_DVM_MULTIPART_SUCCESSIVE) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_DVM_MULTIPART_SUCCESSIVE);
   
  // =====
  // INDEX:        - ACE_ERRS_DVM_MULTIPART_SUCCESSIVE
  // =====
  property ACE_ERRS_DVM_MULTIPART_SUCCESSIVE;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn && !($isunknown({ACVALID,ACSNOOP,ac_dvm_msg_additional_trans})) &&
      ACVALID  && ac_dvm_msg_additional_trans
      |-> ACSNOOP == `ACEPC_ACSNOOP_DVMMESSAGE;
  endproperty
  ace_errs_dvm_multipart_successive : assert property(ACE_ERRS_DVM_MULTIPART_SUCCESSIVE) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRS_DVM_MULTIPART_SUCCESSIVE);
   
  // =====
  // INDEX:        - ACE_ERRM_DVM_ID
  // =====
  // check on a new dvm transaction that a non dvm transaction does not exist
  property ACE_ERRM_DVM_ID;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn && !($isunknown({ARVALID,ARSNOOP,ARIDisBAR,ARID_ARInfo_isNORMAL})) &&
      ARVALID && ((ARSNOOP == `ACEPC_ARSNOOP_DVMMESSAGE) || (ARSNOOP == `ACEPC_ARSNOOP_DVMCOMPLETE))
      |-> (!ARIDisBAR && !ARID_ARInfo_isNORMAL) ;
  endproperty
  ace_errm_dvm_id : assert property(ACE_ERRM_DVM_ID) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_DVM_ID);
  
  // =====
  // INDEX:        - ACE_ERRS_DVM_RESVD_1
  // =====
  property ACE_ERRS_DVM_RESVD_1;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn && !($isunknown({ACVALID,ACSNOOP,ac_dvm_msg_additional_trans,ACADDR})) &&
      ACVALID && (ACSNOOP == `ACEPC_ACSNOOP_DVMMESSAGE) && !ac_dvm_msg_additional_trans && (ACADDR[14:12] != `ACEPC_DVM_HINT)
      |-> ( ~|ACADDR[4:1]  && !ACADDR[7] );
  endproperty
  ace_errs_dvm_resvd_1 : assert property(ACE_ERRS_DVM_RESVD_1) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRS_DVM_RESVD_1);
   
  // =====
  // INDEX:        - ACE_ERRS_DVM_RESVD_2
  // =====
  property ACE_ERRS_DVM_RESVD_2;
  @(posedge `ACE_SVA_CLK) 
    `ACE_SVA_RSTn && !($isunknown({ACVALID,ACSNOOP,ac_dvm_msg_additional_trans,ACADDR})) &&
    ACVALID && (ACSNOOP == `ACEPC_ACSNOOP_DVMMESSAGE) && ac_dvm_msg_additional_trans
    |-> ~|ACADDR[3:0] ;
  endproperty
  ace_errs_dvm_resvd_2 : assert property (ACE_ERRS_DVM_RESVD_2)else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRS_DVM_RESVD_2);
   
  // =====
  // INDEX:        - ACE_ERRS_DVM_RESVD_3
  // =====
  property ACE_ERRS_DVM_RESVD_3;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn && !($isunknown({ACVALID,ACSNOOP,ac_dvm_msg_additional_trans,ACADDR})) &&
      ACVALID && (ACSNOOP == `ACEPC_ACSNOOP_DVMMESSAGE) &&  !ac_dvm_msg_additional_trans &&
      (ACADDR[14:12] ==  `ACEPC_DVM_SYNC) 
      |-> ACADDR[15] &&  ~|ACADDR[11:0] ;
  endproperty
  ace_errs_dvm_resvd_3 : assert property(ACE_ERRS_DVM_RESVD_3) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRS_DVM_RESVD_3);
   
  // =====
  // INDEX:        - ACE_ERRS_DVM_RESVD_4
  // =====
  // 
  property ACE_ERRS_DVM_RESVD_4;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn && !($isunknown({ACVALID,ACSNOOP,ac_dvm_msg_additional_trans,ACADDR})) &&
      ACVALID && (ACSNOOP == `ACEPC_ACSNOOP_DVMMESSAGE) && !ac_dvm_msg_additional_trans &&
      (ACADDR[14:12] !=  `ACEPC_DVM_SYNC) 
      |-> !ACADDR[15]  ;
  endproperty
  ace_errs_dvm_resvd_4 : assert property(ACE_ERRS_DVM_RESVD_4) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRS_DVM_RESVD_4);
   
  // =====
  // INDEX:        - ACE_ERRM_DVM_TLB_INV
  // =====
  property ACE_ERRM_DVM_TLB_INV;
    @(posedge `ACE_SVA_CLK) 
    `ACE_SVA_RSTn && !($isunknown({ARVALID,ARSNOOP,ARADDR,ar_dvm_msg_additional_trans})) &&
      ARVALID && (ARSNOOP == `ACEPC_ARSNOOP_DVMMESSAGE) && 
      (ARADDR[14:12] == `ACEPC_DVM_TLB_INVALIDATE) && 
      !ar_dvm_msg_additional_trans
      |-> ((ARADDR[15] == 1'b0) && (ARADDR[11:8] == 4'b1010) && (ARADDR[6:5] == 2'b00) && (ARADDR[0] == 1'b0))
       || ((ARADDR[15] == 1'b0) && (ARADDR[11:8] == 4'b1010) && (ARADDR[6:5] == 2'b00) && (ARADDR[0] == 1'b1))
       || ((ARADDR[15] == 1'b0) && (ARADDR[11:8] == 4'b1010) && (ARADDR[6:5] == 2'b01) && (ARADDR[0] == 1'b0))
       || ((ARADDR[15] == 1'b0) && (ARADDR[11:8] == 4'b1010) && (ARADDR[6:5] == 2'b01) && (ARADDR[0] == 1'b1))
       || ((ARADDR[15] == 1'b0) && (ARADDR[11:8] == 4'b1011) && (ARADDR[6:5] == 2'b00) && (ARADDR[0] == 1'b0))       
       || ((ARADDR[15] == 1'b0) && (ARADDR[11:8] == 4'b1011) && (ARADDR[6:5] == 2'b10) && (ARADDR[0] == 1'b0))
       || ((ARADDR[15] == 1'b0) && (ARADDR[11:8] == 4'b1011) && (ARADDR[6:5] == 2'b10) && (ARADDR[0] == 1'b1))       
       || ((ARADDR[15] == 1'b0) && (ARADDR[11:8] == 4'b1011) && (ARADDR[6:5] == 2'b11) && (ARADDR[0] == 1'b0))
       || ((ARADDR[15] == 1'b0) && (ARADDR[11:8] == 4'b1011) && (ARADDR[6:5] == 2'b11) && (ARADDR[0] == 1'b1))
       || ((ARADDR[15] == 1'b0) && (ARADDR[11:8] == 4'b1111) && (ARADDR[6:5] == 2'b00) && (ARADDR[0] == 1'b0))
       || ((ARADDR[15] == 1'b0) && (ARADDR[11:8] == 4'b1111) && (ARADDR[6:5] == 2'b00) && (ARADDR[0] == 1'b1));
  endproperty
  ace_errm_dvm_tlb_inv : assert property (ACE_ERRM_DVM_TLB_INV) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_DVM_TLB_INV);
   
  // =====
  // INDEX:        - ACE_ERRS_DVM_TLB_INV
  // =====
  property ACE_ERRS_DVM_TLB_INV;
    @(posedge `ACE_SVA_CLK) 
    `ACE_SVA_RSTn && !($isunknown({ACVALID,ACSNOOP,ACADDR,ac_dvm_msg_additional_trans})) &&
      ACVALID && (ACSNOOP == `ACEPC_ACSNOOP_DVMMESSAGE) && 
        (ACADDR[14:12] == `ACEPC_DVM_TLB_INVALIDATE) && 
        !ac_dvm_msg_additional_trans
      |-> ((ACADDR[15] == 1'b0) && (ACADDR[11:8] == 4'b1010) && (ACADDR[6:5] == 2'b00) && (ACADDR[0] == 1'b0))
       || ((ACADDR[15] == 1'b0) && (ACADDR[11:8] == 4'b1010) && (ACADDR[6:5] == 2'b00) && (ACADDR[0] == 1'b1))
       || ((ACADDR[15] == 1'b0) && (ACADDR[11:8] == 4'b1010) && (ACADDR[6:5] == 2'b01) && (ACADDR[0] == 1'b0))
       || ((ACADDR[15] == 1'b0) && (ACADDR[11:8] == 4'b1010) && (ACADDR[6:5] == 2'b01) && (ACADDR[0] == 1'b1))
       || ((ACADDR[15] == 1'b0) && (ACADDR[11:8] == 4'b1011) && (ACADDR[6:5] == 2'b00) && (ACADDR[0] == 1'b0))       
       || ((ACADDR[15] == 1'b0) && (ACADDR[11:8] == 4'b1011) && (ACADDR[6:5] == 2'b10) && (ACADDR[0] == 1'b0))
       || ((ACADDR[15] == 1'b0) && (ACADDR[11:8] == 4'b1011) && (ACADDR[6:5] == 2'b10) && (ACADDR[0] == 1'b1))       
       || ((ACADDR[15] == 1'b0) && (ACADDR[11:8] == 4'b1011) && (ACADDR[6:5] == 2'b11) && (ACADDR[0] == 1'b0))
       || ((ACADDR[15] == 1'b0) && (ACADDR[11:8] == 4'b1011) && (ACADDR[6:5] == 2'b11) && (ACADDR[0] == 1'b1))
       || ((ACADDR[15] == 1'b0) && (ACADDR[11:8] == 4'b1111) && (ACADDR[6:5] == 2'b00) && (ACADDR[0] == 1'b0))
       || ((ACADDR[15] == 1'b0) && (ACADDR[11:8] == 4'b1111) && (ACADDR[6:5] == 2'b00) && (ACADDR[0] == 1'b1));
  endproperty
  ace_errs_dvm_tlb_inv : assert property (ACE_ERRS_DVM_TLB_INV) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRS_DVM_TLB_INV);

  // =====
  // INDEX:        - ACE_ERRM_DVM_BP_INV
  // =====
  property ACE_ERRM_DVM_BP_INV;
    @(posedge `ACE_SVA_CLK) 
    `ACE_SVA_RSTn && !($isunknown({ARVALID,ARSNOOP,ARADDR,ar_dvm_msg_additional_trans})) &&
      ARVALID && (ARSNOOP == `ACEPC_ARSNOOP_DVMMESSAGE) && 
      (ARADDR[14:12] == `ACEPC_DVM_BRAN_PRED_INVALIDATE) && 
      !ar_dvm_msg_additional_trans
      |-> ((ARADDR[15] == 1'b0) && (ARADDR[11:8] == 4'b0000) && (ARADDR[6:5] == 2'b00) && (ARADDR[0] == 1'b0))
       || ((ARADDR[15] == 1'b0) && (ARADDR[11:8] == 4'b0000) && (ARADDR[6:5] == 2'b00) && (ARADDR[0] == 1'b1));
  endproperty
  ace_errm_dvm_bp_inv : assert property (ACE_ERRM_DVM_BP_INV) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_DVM_BP_INV);
    
  // =====
  // INDEX:        - ACE_ERRS_DVM_BP_INV
  // =====
  property ACE_ERRS_DVM_BP_INV;
    @(posedge `ACE_SVA_CLK) 
    `ACE_SVA_RSTn && !($isunknown({ACVALID,ACSNOOP,ACADDR,ac_dvm_msg_additional_trans})) &&
      ACVALID && (ACSNOOP == `ACEPC_ACSNOOP_DVMMESSAGE) && 
      (ACADDR[14:12] == `ACEPC_DVM_BRAN_PRED_INVALIDATE) && 
      !ac_dvm_msg_additional_trans
      |-> ((ACADDR[15] == 1'b0) && (ACADDR[11:8] == 4'b0000) && (ACADDR[6:5] == 2'b00) && (ACADDR[0] == 1'b0))
       || ((ACADDR[15] == 1'b0) && (ACADDR[11:8] == 4'b0000) && (ACADDR[6:5] == 2'b00) && (ACADDR[0] == 1'b1));
  endproperty
  ace_errs_dvm_bp_inv : assert property (ACE_ERRS_DVM_BP_INV) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRS_DVM_BP_INV);
 
  // =====
  // INDEX:        - ACE_ERRM_DVM_PHY_INV
  // =====
  property ACE_ERRM_DVM_PHY_INV;
    @(posedge `ACE_SVA_CLK) 
    `ACE_SVA_RSTn && !($isunknown({ARVALID,ARSNOOP,ARADDR,ar_dvm_msg_additional_trans})) &&
      ARVALID && (ARSNOOP == `ACEPC_ARSNOOP_DVMMESSAGE) && 
      (ARADDR[14:12] == `ACEPC_DVM_PHY_INST_CACHE_INVALIDATE) && 
      !ar_dvm_msg_additional_trans
      |-> ((ARADDR[15] == 1'b0) && (ARADDR[11:8] == 4'b0010) && (ARADDR[6:5] == 2'b00) && (ARADDR[0] == 1'b0))
       || ((ARADDR[15] == 1'b0) && (ARADDR[11:8] == 4'b0010) && (ARADDR[6:5] == 2'b00) && (ARADDR[0] == 1'b1))
       || ((ARADDR[15] == 1'b0) && (ARADDR[11:8] == 4'b0010) && (ARADDR[6:5] == 2'b11) && (ARADDR[0] == 1'b1))
       || ((ARADDR[15] == 1'b0) && (ARADDR[11:8] == 4'b0011) && (ARADDR[6:5] == 2'b00) && (ARADDR[0] == 1'b0))  
       || ((ARADDR[15] == 1'b0) && (ARADDR[11:8] == 4'b0011) && (ARADDR[6:5] == 2'b00) && (ARADDR[0] == 1'b1))  
       || ((ARADDR[15] == 1'b0) && (ARADDR[11:8] == 4'b0011) && (ARADDR[6:5] == 2'b11) && (ARADDR[0] == 1'b1));
  endproperty
  ace_errm_dvm_phy_inv : assert property (ACE_ERRM_DVM_PHY_INV) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_DVM_PHY_INV);
    
  // =====
  // INDEX:        - ACE_ERRS_DVM_PHY_INV
  // =====
  property ACE_ERRS_DVM_PHY_INV;
    @(posedge `ACE_SVA_CLK) 
    `ACE_SVA_RSTn && !($isunknown({ACVALID,ACSNOOP,ACADDR,ac_dvm_msg_additional_trans})) &&
      ACVALID && (ACSNOOP == `ACEPC_ACSNOOP_DVMMESSAGE) && 
      (ACADDR[14:12] == `ACEPC_DVM_PHY_INST_CACHE_INVALIDATE) && !ac_dvm_msg_additional_trans
      |-> ((ACADDR[15] == 1'b0) && (ACADDR[11:8] == 4'b0010) && (ACADDR[6:5] == 2'b00) && (ACADDR[0] == 1'b0))
       || ((ACADDR[15] == 1'b0) && (ACADDR[11:8] == 4'b0010) && (ACADDR[6:5] == 2'b00) && (ACADDR[0] == 1'b1))
       || ((ACADDR[15] == 1'b0) && (ACADDR[11:8] == 4'b0010) && (ACADDR[6:5] == 2'b11) && (ACADDR[0] == 1'b1))
       || ((ACADDR[15] == 1'b0) && (ACADDR[11:8] == 4'b0011) && (ACADDR[6:5] == 2'b00) && (ACADDR[0] == 1'b0))  
       || ((ACADDR[15] == 1'b0) && (ACADDR[11:8] == 4'b0011) && (ACADDR[6:5] == 2'b00) && (ACADDR[0] == 1'b1))  
       || ((ACADDR[15] == 1'b0) && (ACADDR[11:8] == 4'b0011) && (ACADDR[6:5] == 2'b11) && (ACADDR[0] == 1'b1));
  endproperty
  ace_errs_dvm_phy_inv : assert property(ACE_ERRS_DVM_PHY_INV) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRS_DVM_PHY_INV);
    
  // =====
  // INDEX:        - ACE_ERRM_DVM_VIR_INV
  // =====
  property ACE_ERRM_DVM_VIR_INV;
    @(posedge `ACE_SVA_CLK) 
    `ACE_SVA_RSTn && !($isunknown({ARVALID,ARSNOOP,ARADDR,ar_dvm_msg_additional_trans})) &&
      ARVALID && (ARSNOOP == `ACEPC_ARSNOOP_DVMMESSAGE) && (ARADDR[14:12] == `ACEPC_DVM_VIR_INST_CACHE_INVALIDATE) && !ar_dvm_msg_additional_trans
      |-> ((ARADDR[15] == 1'b0) && (ARADDR[11:8] == 4'b0000) && (ARADDR[6:5] == 2'b00) && (ARADDR[0] == 1'b0))
       || ((ARADDR[15] == 1'b0) && (ARADDR[11:8] == 4'b0011) && (ARADDR[6:5] == 2'b00) && (ARADDR[0] == 1'b0))
       || ((ARADDR[15] == 1'b0) && (ARADDR[11:8] == 4'b1010) && (ARADDR[6:5] == 2'b01) && (ARADDR[0] == 1'b1))  
       || ((ARADDR[15] == 1'b0) && (ARADDR[11:8] == 4'b1011) && (ARADDR[6:5] == 2'b10) && (ARADDR[0] == 1'b0)) 
       || ((ARADDR[15] == 1'b0) && (ARADDR[11:8] == 4'b1011) && (ARADDR[6:5] == 2'b11) && (ARADDR[0] == 1'b1)) 
       || ((ARADDR[15] == 1'b0) && (ARADDR[11:8] == 4'b1111) && (ARADDR[6:5] == 2'b00) && (ARADDR[0] == 1'b1));
  endproperty
  ace_errm_dvm_vir_inv : assert property (ACE_ERRM_DVM_VIR_INV) else 
     `ARM_AMBA4_PC_MSG_ERR(`ERRM_DVM_VIR_INV);
    
  // =====
  // INDEX:        - ACE_ERRS_DVM_VIR_INV
  // =====
  property ACE_ERRS_DVM_VIR_INV;
    @(posedge `ACE_SVA_CLK) 
    `ACE_SVA_RSTn && !($isunknown({ACVALID,ACSNOOP,ACADDR,ac_dvm_msg_additional_trans})) &&
      ACVALID && (ACSNOOP == `ACEPC_ACSNOOP_DVMMESSAGE) && 
      (ACADDR[14:12] == `ACEPC_DVM_VIR_INST_CACHE_INVALIDATE) && !ac_dvm_msg_additional_trans
      |-> ((ACADDR[15] == 1'b0) && (ACADDR[11:8] == 4'b0000) && (ACADDR[6:5] == 2'b00) && (ACADDR[0] == 1'b0))
       || ((ACADDR[15] == 1'b0) && (ACADDR[11:8] == 4'b0011) && (ACADDR[6:5] == 2'b00) && (ACADDR[0] == 1'b0))
       || ((ACADDR[15] == 1'b0) && (ACADDR[11:8] == 4'b1010) && (ACADDR[6:5] == 2'b01) && (ACADDR[0] == 1'b1))  
       || ((ACADDR[15] == 1'b0) && (ACADDR[11:8] == 4'b1011) && (ACADDR[6:5] == 2'b10) && (ACADDR[0] == 1'b0)) 
       || ((ACADDR[15] == 1'b0) && (ACADDR[11:8] == 4'b1011) && (ACADDR[6:5] == 2'b11) && (ACADDR[0] == 1'b1)) 
       || ((ACADDR[15] == 1'b0) && (ACADDR[11:8] == 4'b1111) && (ACADDR[6:5] == 2'b00) && (ACADDR[0] == 1'b1));
  endproperty
    ace_errs_dvm_vir_inv : assert property (ACE_ERRS_DVM_VIR_INV) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRS_DVM_VIR_INV);
    
  // =====
  // INDEX:        - ACE_ERRS_DVM_MULTIPART_RRESP
  // =====
  // Response given to all parts of a multi part DVM must be the same
  property ACE_ERRS_DVM_MULTIPART_RRESP;
    @(posedge `ACE_SVA_CLK) 
    `ACE_SVA_RSTn && !($isunknown({RVALID,RRESP,RID,AR_DVM_ADDITIONAL_Info[AR_DVM_ADDITIONAL_RIDMatch2],AR_DVM_ADDITIONAL_RIDMatch2})) &&
      RVALID && AR_DVM_ADDITIONAL_RIDMatch2 && AR_DVM_ADDITIONAL_Info[AR_DVM_ADDITIONAL_RIDMatch2][DVM_ADDITIONAL_RRESP_FIRST]
      |-> (RRESP[1] == AR_DVM_ADDITIONAL_Info[AR_DVM_ADDITIONAL_RIDMatch2][DVM_ADDITIONAL_RRESP_1_]);
  endproperty
  ace_errs_dvm_multipart_rresp : assert property(ACE_ERRS_DVM_MULTIPART_RRESP) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRS_DVM_MULTIPART_RRESP);

  // =====
  // INDEX:        - ACE_ERRM_DVM_MULTIPART_CRRESP
  // =====
  // Response given to all parts of a multi part DVM must be the same
  property ACE_ERRM_DVM_MULTIPART_CRRESP;
    @(posedge `ACE_SVA_CLK) 
    `ACE_SVA_RSTn && !($isunknown({CRVALID,CRRESP,ACInfo[snoop_dataresp_cnt +1][AC_DVM],AC_DVM_ADD_CRESP})) &&
      CRVALID && ACInfo[snoop_dataresp_cnt +1][AC_DVM] && AC_DVM_ADD_CRESP[1]
      |-> (CRRESP[1] == AC_DVM_ADD_CRESP[0]);
  endproperty
  ace_errm_dvm_multipart_crresp : assert property(ACE_ERRM_DVM_MULTIPART_CRRESP) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_DVM_MULTIPART_CRRESP);

  // =====
  // INDEX:        - ACE_ERRS_RRESP_DVM_ERROR
  // =====
  // When RVALID is asserted for a DVM Sync or DVM Complete transaction RRESP must be 0
  property ACE_ERRS_RRESP_DVM_ERROR;
    @(posedge `ACE_SVA_CLK) 
    `ACE_SVA_RSTn && !($isunknown({RVALID,RRESP,CurrentRInfo[AR_DVMSYNC],CurrentRInfo[AR_DVMCOMPLETE],CurrentRInfo[AR_DVMHINT],AR_DVM_ADDITIONAL_RIDMatch2})) &&
      RVALID && (CurrentRInfo[AR_DVMSYNC] || CurrentRInfo[AR_DVMCOMPLETE] || CurrentRInfo[AR_DVMHINT]) && !AR_DVM_ADDITIONAL_RIDMatch2  
      |-> (RRESP == 5'b00000);
  endproperty
  ace_errs_rresp_dvm_error : assert property(ACE_ERRS_RRESP_DVM_ERROR) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRS_RRESP_DVM_ERROR);

  // =====
  // INDEX:        - ACE_ERRS_RRESP_DVM
  // =====
  // When RVALID is asserted for a DVM transaction RRESP[3:0] must be 4'b00x0
  property ACE_ERRS_RRESP_DVM;
    @(posedge `ACE_SVA_CLK) 
    `ACE_SVA_RSTn && !($isunknown({RVALID,RRESP,CurrentRInfo[AR_DVM]})) &&
      RVALID && (CurrentRInfo[AR_DVM] == 1'b1) 
      |-> ~|RRESP[3:2] && !RRESP[0] ;
  endproperty
  ace_errs_rresp_dvm : assert property(ACE_ERRS_RRESP_DVM) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRS_RRESP_DVM);

//------------------------------------------------------------------------------
// INDEX:
// INDEX:   20)  ACE Rules: Write Address Channel (*_AW*)
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// INDEX:      1) Functional Rules
//------------------------------------------------------------------------------


  // =====
  // INDEX:        - ACE_ERRM_AWBURST
  // =====
  property ACE_ERRM_AWBURST;
    @(posedge `ACE_SVA_CLK)
      !($isunknown({AWVALID,AWBURST})) &
      AWVALID
      |-> (AWBURST != 2'b11);
  endproperty
  ace_errm_awburst: assert property (ACE_ERRM_AWBURST) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWBURST);


  // =====
  // INDEX:        - ACE_ERRM_AWADDR_BOUNDARY
  // =====
  // duplicated from AXI4PC to check barriers and write evicts
  // 4kbyte boundary: only bottom twelve bits (11 to 0) can change
  //
  // Only need to check INCR bursts since:
  //
  //   a) FIXED bursts cannot violate the 4kB boundary by definition
  //
  //   b) WRAP bursts always stay within a <4kB region because of the wrap
  //      address boundary.  The biggest WRAP burst possible has length 16,
  //      size 128 bytes (1024 bits), so it can transfer 2048 bytes. The
  //      individual transfer addresses wrap at a 2048 byte address boundary,
  //      and the max data transferred in also 2048 bytes, so a 4kB boundary
  //      can never be broken.
  property ACE_ERRM_AWADDR_BOUNDARY;
    @(posedge `ACE_SVA_CLK)
    !($isunknown({AWVALID,AWBURST,AWADDR,AwAddrIncr})) &&
      AWVALID && (AWBURST == `AXI4PC_ABURST_INCR)
      |-> (AwAddrIncr[ADDR_MAX:12] == AWADDR[ADDR_MAX:12]);
  endproperty
  ace_errm_awaddr_boundary: assert property (ACE_ERRM_AWADDR_BOUNDARY) else
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWADDR_BOUNDARY);

  // =====
  // INDEX:        - ACE_ERRM_AWVALID_RESET
  // =====
  // this rule has been effectively disabled in the axi4pc for barriers and
  // evicts and so is duplicated here.
  property ACE_ERRM_AWVALID_RESET;
    @(posedge `ACE_SVA_CLK)
      !(`ACE_SVA_RSTn) && !($isunknown(`ACE_SVA_RSTn))
      ##1   `ACE_SVA_RSTn
      |-> !AWVALID;
  endproperty
  ace_errm_awvalid_reset: assert property (ACE_ERRM_AWVALID_RESET) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWVALID_RESET);
  
  // =====
  // INDEX:        - ACE_ERRM_AWCACHE_DEVICE
  // =====
  property ACE_ERRM_AWCACHE_DEVICE;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn && !($isunknown({AWVALID,AWCACHE,AWDOMAIN})) &&
      AWVALID && !AWCACHE[1]
      |-> (AWDOMAIN == `ACEPC_AXDOMAIN_SYS_DOMAIN);
  endproperty
  ace_errm_awcache_device: assert property (ACE_ERRM_AWCACHE_DEVICE) else
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWCACHE_DEVICE);
   
  // =====
  // INDEX:        - ACE_ERRM_AWCACHE_SYSTEM
  // =====
  property ACE_ERRM_AWCACHE_SYSTEM;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn && !($isunknown({AWVALID,AWCACHE,AWDOMAIN})) &&
      AWVALID && |AWCACHE[3:2]
      |-> (AWDOMAIN != `ACEPC_AXDOMAIN_SYS_DOMAIN);
  endproperty
  ace_errm_awcache_system: assert property (ACE_ERRM_AWCACHE_SYSTEM) else
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWCACHE_SYSTEM);
   
  // =====
  // INDEX:        - ACE_ERRM_AWSNOOP
  // =====
  // AWSNOOP value must be legal
  property ACE_ERRM_AWSNOOP;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn && !($isunknown({AWVALID,AWSNOOP})) &&
      AWVALID
      |-> (AWSNOOP == `ACEPC_AWSNOOP_WRITEUNIQUE) || 
        (AWSNOOP == `ACEPC_AWSNOOP_WRITELINEUNIQUE) || 
        (AWSNOOP == `ACEPC_AWSNOOP_WRITECLEAN) || 
        (AWSNOOP == `ACEPC_AWSNOOP_WRITEBACK) || 
        (AWSNOOP == `ACEPC_AWSNOOP_WRITEEVICT);
  endproperty
  ace_errm_awsnoop : assert property(ACE_ERRM_AWSNOOP) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWSNOOP);
  

   // =====
   // INDEX:        - ACE_ERRM_AW_BLOCK_1
   // =====
   // Must not issue a WriteClean or WriteBack if a WriteUnique is in progress.
   // ---
   property ACE_ERRM_AW_BLOCK_1;
     @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn && !($isunknown({AWVALID,AWSNOOP,wu_ctr})) &&
       AWVALID  && !AWBAR[0] &&
       ((AWSNOOP == `ACEPC_AWSNOOP_WRITECLEAN) || (AWSNOOP == `ACEPC_AWSNOOP_WRITEBACK))
       |-> wu_ctr == 0;
  endproperty
  ace_errm_aw_block_1 : assert property(ACE_ERRM_AW_BLOCK_1) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_AW_BLOCK_1);

   // =====
   // INDEX:        - ACE_ERRM_AW_BLOCK_2
   // =====
   // Must not issue a WriteUnique if a WriteClean or WriteBack is in progress.
   property ACE_ERRM_AW_BLOCK_2;
     @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn && !($isunknown({AWVALID,AWSNOOP,AWDOMAIN,wc_ctr,wb_ctr})) && !AWBAR[0] &&
       AWVALID  && (AWDOMAIN == `ACEPC_AXDOMAIN_INNER_DOMAIN || AWDOMAIN == `ACEPC_AXDOMAIN_OUTER_DOMAIN) &&
       ((AWSNOOP == `ACEPC_AWSNOOP_WRITEUNIQUE) || (AWSNOOP == `ACEPC_AWSNOOP_WRITELINEUNIQUE)) 
       |-> (wc_ctr == 0 && wb_ctr == 0);
  endproperty
  ace_errm_aw_block_2 : assert property(ACE_ERRM_AW_BLOCK_2) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_AW_BLOCK_2);


  // =====
  // INDEX:        - ACE_ERRM_AW_FULL_LINE
  // =====
  // The WriteLineUnique and WriteEvict transactions are required to be a full
  // cache line size
  // specific ctl
  property ACE_ERRM_AW_FULL_LINE;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn && `ACE_SVA_RSTn && !($isunknown({AWVALID,AWSNOOP,AWLEN,AWSIZE})) &&
      AWVALID && (AWSNOOP == `ACEPC_AWSNOOP_WRITELINEUNIQUE ||
                  AWSNOOP == `ACEPC_AWSNOOP_WRITEEVICT)
      |-> ((AWLEN == CACHE_LINE_AxLEN) && (AWSIZE == CACHE_LINE_AxSIZE));
  endproperty
  ace_errm_aw_full_line : assert property(ACE_ERRM_AW_FULL_LINE) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_AW_FULL_LINE);

  // =====
  // INDEX:        - ACE_ERRM_AW_SHAREABLE_ALIGN_INCR
  // =====
  // The WriteLineUnique and WriteEvict transactions with AWBURST = INCR must
  // be aligned to the cache line size
  property ACE_ERRM_AW_SHAREABLE_ALIGN_INCR;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn && !($isunknown({AWVALID,AWSNOOP,AWBURST,AWADDR})) &&
      AWVALID && (AWSNOOP == `ACEPC_AWSNOOP_WRITELINEUNIQUE ||
                  AWSNOOP == `ACEPC_AWSNOOP_WRITEEVICT) 
                  && AWBURST == `AXI4PC_ABURST_INCR
      |-> ((AWADDR[10:0] & CACHE_LINE_MASK) == AWADDR[10:0]);
  endproperty
  ace_errm_aw_shareable_align_incr : assert property(ACE_ERRM_AW_SHAREABLE_ALIGN_INCR) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_AW_SHAREABLE_ALIGN_INCR);

  // =====
  // INDEX:        - ACE_ERRM_AW_SHAREABLE_ALIGN_WRAP
  // =====
  // The WriteLineUnique and WriteEvict transactions with AWBURST = WRAP must
  // be aligned to the data width of the bus
  property ACE_ERRM_AW_SHAREABLE_ALIGN_WRAP;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn && !($isunknown({AWVALID,AWSNOOP,AWBURST,AWADDR})) &&
      AWVALID && (AWSNOOP == `ACEPC_AWSNOOP_WRITELINEUNIQUE ||
                  AWSNOOP == `ACEPC_AWSNOOP_WRITEEVICT) 
                  && AWBURST == `AXI4PC_ABURST_WRAP
      |-> ((AWADDR[6:0] & SIZEMASK) == AWADDR[6:0]);
  endproperty
  ace_errm_aw_shareable_align_wrap : assert property(ACE_ERRM_AW_SHAREABLE_ALIGN_WRAP) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_AW_SHAREABLE_ALIGN_WRAP);

  // =====
  // INDEX:        - ACE_ERRM_AW_SHAREABLE_LOCK
  // =====
  property ACE_ERRM_AW_SHAREABLE_LOCK;
    @(posedge `ACE_SVA_CLK) 
    `ACE_SVA_RSTn && !($isunknown({AWVALID,AWLOCK,AWDOMAIN})) &&
      AWVALID && (AWDOMAIN == `ACEPC_AXDOMAIN_INNER_DOMAIN ||
                  AWDOMAIN == `ACEPC_AXDOMAIN_OUTER_DOMAIN)
      |-> !AWLOCK;
  endproperty
  ace_errm_aw_shareable_lock : assert property(ACE_ERRM_AW_SHAREABLE_LOCK) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_AW_SHAREABLE_LOCK);

  // =====
  // INDEX:        - ACE_ERRM_AW_SHAREABLE_CTL
  // =====
  // The WriteUnique, WriteLineUnique,WriteClean,WriteBack and WriteEvict 
  // transactions are required to have specific ctl
  property ACE_ERRM_AW_SHAREABLE_CTL;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn && !($isunknown({AWVALID,AWSNOOP,AWBURST,AWCACHE,AWLOCK,AWDOMAIN,AWBAR})) &&
      AWVALID && ((AWSNOOP == `ACEPC_AWSNOOP_WRITEUNIQUE && ^AWDOMAIN && !AWBAR[0]) ||
                  (AWSNOOP == `ACEPC_AWSNOOP_WRITELINEUNIQUE) ||
                  (AWSNOOP == `ACEPC_AWSNOOP_WRITEBACK) ||
                  (AWSNOOP == `ACEPC_AWSNOOP_WRITECLEAN) ||
                  (AWSNOOP == `ACEPC_AWSNOOP_WRITEEVICT))
      |-> (AWBURST != `AXI4PC_ABURST_FIXED) &&
           !AWBAR[0] &&
          AWCACHE[1] &&
          !AWLOCK;
  endproperty
  ace_errm_aw_shareable_ctl : assert property(ACE_ERRM_AW_SHAREABLE_CTL) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_AW_SHAREABLE_CTL);

  // =====
  // INDEX:        - ACE_ERRM_AW_DOMAIN_1
  // =====
  // The WriteClean,WriteBack transactions must not be system shareable
  property ACE_ERRM_AW_DOMAIN_1;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn && !($isunknown({AWVALID,AWSNOOP,AWDOMAIN})) &&
      AWVALID && ((AWSNOOP == `ACEPC_AWSNOOP_WRITEBACK) ||
                  (AWSNOOP == `ACEPC_AWSNOOP_WRITECLEAN))
      |-> (AWDOMAIN != `ACEPC_AXDOMAIN_SYS_DOMAIN);
  endproperty
  ace_errm_aw_domain_1 : assert property(ACE_ERRM_AW_DOMAIN_1) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_AW_DOMAIN_1);

  // =====
  // INDEX:        - ACE_ERRM_AW_DOMAIN_2
  // =====
  // The WriteUnique, WriteLineUnique and WriteEvict transactions must be to
  // the inner or outer shareable domains
  property ACE_ERRM_AW_DOMAIN_2;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn && !($isunknown({AWVALID,AWSNOOP,AWDOMAIN})) &&
      AWVALID && ( (AWSNOOP == `ACEPC_AWSNOOP_WRITELINEUNIQUE) ||
                  (AWSNOOP == `ACEPC_AWSNOOP_WRITEEVICT))
      |-> (AWDOMAIN == `ACEPC_AXDOMAIN_INNER_DOMAIN) ||
          (AWDOMAIN == `ACEPC_AXDOMAIN_OUTER_DOMAIN);
  endproperty
  ace_errm_aw_domain_2 : assert property(ACE_ERRM_AW_DOMAIN_2) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_AW_DOMAIN_2);

  // =====
  // INDEX:        - ACE_ERRM_WB_WC_CACHE_LINE_BOUNDARY_INCR
  // =====
  // The WriteClean,WriteBack transactions must not cross a cache line
  // boundary
  property ACE_ERRM_WB_WC_CACHE_LINE_BOUNDARY_INCR;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn && !($isunknown({AWVALID,AWSNOOP,AwAddrIncr,AWBURST,AWADDR})) &&
      AWVALID && (((AWSNOOP == `ACEPC_AWSNOOP_WRITEBACK) ||
                  (AWSNOOP == `ACEPC_AWSNOOP_WRITECLEAN)) &&
                   AWBURST == `AXI4PC_ABURST_INCR)
      |-> (AwAddrIncr[ADDR_MAX:CACHE_LINE_MAXBIT] == AWADDR[ADDR_MAX:CACHE_LINE_MAXBIT]  );
  endproperty
  ace_errm_wb_wc_cache_line_boundary_incr : assert property(ACE_ERRM_WB_WC_CACHE_LINE_BOUNDARY_INCR) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_WB_WC_CACHE_LINE_BOUNDARY_INCR);

  // =====
  // INDEX:        - ACE_ERRM_WB_WC_CACHE_LINE_BOUNDARY_WRAP
  // =====
  // The WriteClean,WriteBack transactions must not cross a cache line
  // boundary
  // So the total number of bytes must not exceed the cache line size in bytes
  property ACE_ERRM_WB_WC_CACHE_LINE_BOUNDARY_WRAP;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn && !($isunknown({AWVALID,AWSNOOP,AWSIZE,AWLEN,AWBURST})) &&
      AWVALID && (((AWSNOOP == `ACEPC_AWSNOOP_WRITEBACK) ||
                  (AWSNOOP == `ACEPC_AWSNOOP_WRITECLEAN)) &&
                   (AWBURST == `AXI4PC_ABURST_WRAP))
      |->  (({8'h00, AWLEN} + 16'h001) << AWSIZE) <=  CACHE_LINE_SIZE_BYTES;
  endproperty
  ace_errm_wb_wc_cache_line_boundary_wrap : assert property(ACE_ERRM_WB_WC_CACHE_LINE_BOUNDARY_WRAP) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_WB_WC_CACHE_LINE_BOUNDARY_WRAP);
  
  // =====
  // INDEX:        - ACE_ERRM_AWLEN_WRAP
  // =====
  property ACE_ERRM_AWLEN_WRAP;
    @(posedge `ACE_SVA_CLK) 
      !($isunknown({AWVALID,AWBURST,AWLEN})) &&
      AWVALID && (AWBURST == `AXI4PC_ABURST_WRAP) 
      |-> ( AWLEN == `AXI4PC_ALEN_2 ||
           AWLEN == `AXI4PC_ALEN_4 ||
           AWLEN == `AXI4PC_ALEN_8 ||
           AWLEN == `AXI4PC_ALEN_16);
  endproperty
  ace_errm_awlen_wrap: assert property (ACE_ERRM_AWLEN_WRAP) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWLEN_WRAP);

   // =====
   // INDEX:        - ACE_ERRM_W_R_HAZARD
   // =====

  always @(`ACE_AUX_RSTn or AWVALID or AWBAR or min_aw_address or max_aw_address)
  begin
  integer    i; //loop counter
    if (!`ACE_AUX_RSTn || !AWVALID )
    begin
      REC_W_R_HAZARD = 1'b0;
    end
    else 
    begin 
      REC_W_R_HAZARD = 1'b0;
      if (!AWBAR[0])
      begin
        for (i = 1; i <= MAXRBURSTS; i = i + 1)
        begin
          if (i < ARIndex)
          begin
            if (overlapping(min_tx_address(ARInfo[i][ARADDR_HI:ARADDR_LO], 
                                           ARInfo[i][ARBURST_HI:ARBURST_LO],
                                           ARInfo[i][ARLEN_HI:ARLEN_LO],
                                           ARInfo[i][ARSIZE_HI:ARSIZE_LO]),
                            max_tx_address(ARInfo[i][ARADDR_HI:ARADDR_LO], 
                                           ARInfo[i][ARBURST_HI:ARBURST_LO],
                                           ARInfo[i][ARLEN_HI:ARLEN_LO],
                                           ARInfo[i][ARSIZE_HI:ARSIZE_LO]),
                            min_aw_address, max_aw_address)
                          && !ARInfo[i][AR_BARRIER] && !ARInfo[i][AR_DVM] && (ARInfo[i][ARPROT_1] == AWPROT[1])) 
            begin
              REC_W_R_HAZARD = 1'b1;
            end
          end
        end
      end
    end
  end
  property ACE_RECM_W_R_HAZARD;
     @(posedge `ACE_SVA_CLK) 
     `ACE_SVA_RSTn && !($isunknown({REC_W_R_HAZARD,AWVALID})) && 
      AWVALID && RecommendOn 
      |-> !REC_W_R_HAZARD;
  endproperty
  ace_recm_w_r_hazard: assert property (ACE_RECM_W_R_HAZARD) else
   `ARM_AMBA4_PC_MSG_WARN(`RECM_W_R_HAZARD);
 
   // =====
   // INDEX:        - ACE_ERRM_W_W_HAZARD
   // =====

  always @(`ACE_AUX_RSTn or AWVALID or AWBAR or min_aw_address or max_aw_address)
  begin
  integer    i; //loop counter
    if (!`ACE_AUX_RSTn || !AWVALID )
    begin
      REC_W_W_HAZARD = 1'b0;
    end
    else 
    begin 
      REC_W_W_HAZARD = 1'b0;
      if (!AWBAR[0])
      begin
        for (i = 1; i <= MAXWBURSTS; i = i + 1)
        begin
          if (i < AWIndex)
          begin
            if (overlapping(min_tx_address(AWInfo[i][AWADDR_HI:AWADDR_LO], 
                                           AWInfo[i][AWBURST_HI:AWBURST_LO],
                                           AWInfo[i][AWLEN_HI:AWLEN_LO],
                                           AWInfo[i][AWSIZE_HI:AWSIZE_LO]),
                            max_tx_address(AWInfo[i][AWADDR_HI:AWADDR_LO], 
                                           AWInfo[i][AWBURST_HI:AWBURST_LO],
                                           AWInfo[i][AWLEN_HI:AWLEN_LO],
                                           AWInfo[i][AWSIZE_HI:AWSIZE_LO]),
                            min_aw_address, max_aw_address)
                          && !AWInfo[i][AW_BARRIER] &&  (AWInfo[i][AWPROT_1] == AWPROT[1])) 
            begin
              REC_W_W_HAZARD = 1'b1;
            end
          end
        end
      end
    end
  end
  property ACE_RECM_W_W_HAZARD;
     @(posedge `ACE_SVA_CLK) 
     `ACE_SVA_RSTn && !($isunknown({REC_W_W_HAZARD,AWVALID})) && 
      AWVALID && RecommendOn 
      |-> !REC_W_W_HAZARD;
  endproperty
  ace_recm_w_w_hazard: assert property (ACE_RECM_W_W_HAZARD) else
   `ARM_AMBA4_PC_MSG_WARN(`RECM_W_W_HAZARD);
 

//------------------------------------------------------------------------------
// INDEX:      2) Handshake Rules
//------------------------------------------------------------------------------

  // =====
  // INDEX:        - ACE_ERRM_AWVALID_STABLE
  // =====
  // this rule is effectively disabled for evicts and barriers in the axi4pc
  // so is duplicated here.
  property ACE_ERRM_AWVALID_STABLE;
    @(posedge `ACE_SVA_CLK)
      `ACE_SVA_RSTn && AWVALID && !AWREADY && !($isunknown({AWVALID,AWREADY}))
      ##1 `ACE_SVA_RSTn
      |-> AWVALID;
  endproperty
  ace_errm_awvalid_stable: assert property (ACE_ERRM_AWVALID_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWVALID_STABLE);

  // =====
  // INDEX:        - ACE_ERRM_AWDOMAIN_STABLE
  // =====
  property ACE_ERRM_AWDOMAIN_STABLE;
    @(posedge `ACE_SVA_CLK)
      !($isunknown({AWVALID,AWREADY,AWDOMAIN})) &&
      `ACE_SVA_RSTn && AWVALID && !AWREADY
      ##1 `ACE_SVA_RSTn
      |-> $stable(AWDOMAIN);
  endproperty
  ace_errm_awdomain_stable: assert property (ACE_ERRM_AWDOMAIN_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWDOMAIN_STABLE);

  // =====
  // INDEX:        - ACE_ERRM_AWSNOOP_STABLE
  // =====
  property ACE_ERRM_AWSNOOP_STABLE;
    @(posedge `ACE_SVA_CLK)
      !($isunknown({AWVALID,AWREADY,AWSNOOP})) &&
      `ACE_SVA_RSTn && AWVALID && !AWREADY
      ##1 `ACE_SVA_RSTn
      |-> $stable(AWSNOOP);
  endproperty
  ace_errm_awsnoop_stable: assert property (ACE_ERRM_AWSNOOP_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWSNOOP_STABLE);

  // =====
  // INDEX:        - ACE_ERRM_AWBAR_STABLE
  // =====
  property ACE_ERRM_AWBAR_STABLE;
    @(posedge `ACE_SVA_CLK)
      !($isunknown({AWVALID,AWREADY,AWBAR})) &&
      `ACE_SVA_RSTn && AWVALID && !AWREADY
      ##1 `ACE_SVA_RSTn
      |-> $stable(AWBAR);
  endproperty
  ace_errm_awbar_stable: assert property (ACE_ERRM_AWBAR_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWBAR_STABLE);

  // =====
  // INDEX:        - ACE_ERRM_AWADDR_STABLE
  // =====
  property ACE_ERRM_AWADDR_STABLE;
    @(posedge `ACE_SVA_CLK)
      !($isunknown({AWVALID,AWREADY,AWADDR})) &&
      `ACE_SVA_RSTn && AWVALID && !AWREADY
      ##1 `ACE_SVA_RSTn
      |-> $stable(AWADDR);
  endproperty
  ace_errm_awaddr_stable: assert property (ACE_ERRM_AWADDR_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWADDR_STABLE);

  // =====
  // INDEX:        - ACE_ERRM_AWBURST_STABLE
  // =====
  property ACE_ERRM_AWBURST_STABLE;
    @(posedge `ACE_SVA_CLK)
      !($isunknown({AWVALID,AWREADY,AWBURST})) &&
      `ACE_SVA_RSTn && AWVALID && !AWREADY
      ##1 `ACE_SVA_RSTn
      |-> $stable(AWBURST);
  endproperty
  ace_errm_awburst_stable: assert property (ACE_ERRM_AWBURST_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWBURST_STABLE);

  // =====
  // INDEX:        - ACE_ERRM_AWCACHE_STABLE
  // =====
  property ACE_ERRM_AWCACHE_STABLE;
    @(posedge `ACE_SVA_CLK)
      !($isunknown({AWVALID,AWREADY,AWCACHE})) &&
      `ACE_SVA_RSTn && AWVALID && !AWREADY
      ##1 `ACE_SVA_RSTn
      |-> $stable(AWCACHE);
  endproperty
  ace_errm_awcache_stable: assert property (ACE_ERRM_AWCACHE_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWCACHE_STABLE);

  // =====
  // INDEX:        - ACE_ERRM_AWID_STABLE
  // =====
  property ACE_ERRM_AWID_STABLE;
    @(posedge `ACE_SVA_CLK)
      !($isunknown({AWVALID,AWREADY,AWID})) &&
      `ACE_SVA_RSTn && AWVALID && !AWREADY
      ##1 `ACE_SVA_RSTn
      |-> $stable(AWID);
  endproperty
  ace_errm_awid_stable: assert property (ACE_ERRM_AWID_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWID_STABLE);

  // =====
  // INDEX:        - ACE_ERRM_AWLEN_STABLE
  // =====
  property ACE_ERRM_AWLEN_STABLE;
    @(posedge `ACE_SVA_CLK)
      !($isunknown({AWVALID,AWREADY,AWLEN})) &&
      `ACE_SVA_RSTn && AWVALID && !AWREADY
      ##1 `ACE_SVA_RSTn
      |-> $stable(AWLEN);
  endproperty
  ace_errm_awlen_stable: assert property (ACE_ERRM_AWLEN_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWLEN_STABLE);

  // =====
  // INDEX:        - ACE_ERRM_AWLOCK_STABLE
  // =====
  property ACE_ERRM_AWLOCK_STABLE;
    @(posedge `ACE_SVA_CLK)
      !($isunknown({AWVALID,AWREADY,AWLOCK})) &&
      `ACE_SVA_RSTn && AWVALID && !AWREADY
      ##1 `ACE_SVA_RSTn
      |-> $stable(AWLOCK);
  endproperty
  ace_errm_awlock_stable: assert property (ACE_ERRM_AWLOCK_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWLOCK_STABLE);

  // =====
  // INDEX:        - ACE_ERRM_AWPROT_STABLE
  // =====
  property ACE_ERRM_AWPROT_STABLE;
    @(posedge `ACE_SVA_CLK)
      !($isunknown({AWVALID,AWREADY,AWPROT})) &&
      `ACE_SVA_RSTn && AWVALID && !AWREADY
      ##1 `ACE_SVA_RSTn
      |-> $stable(AWPROT);
  endproperty
  ace_errm_awprot_stable: assert property (ACE_ERRM_AWPROT_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWPROT_STABLE);

  // =====
  // INDEX:        - ACE_ERRM_AWSIZE_STABLE
  // =====
  property ACE_ERRM_AWSIZE_STABLE;
    @(posedge `ACE_SVA_CLK)
      !($isunknown({AWVALID,AWREADY,AWSIZE})) &&
      `ACE_SVA_RSTn && AWVALID && !AWREADY
      ##1 `ACE_SVA_RSTn
      |-> $stable(AWSIZE);
  endproperty
  ace_errm_awsize_stable: assert property (ACE_ERRM_AWSIZE_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWSIZE_STABLE);

  // =====
  // INDEX:        - ACE_ERRM_AWQOS_STABLE
  // =====
  property ACE_ERRM_AWQOS_STABLE;
    @(posedge `ACE_SVA_CLK)
      !($isunknown({AWVALID,AWREADY,AWQOS})) &&
      `ACE_SVA_RSTn && AWVALID && !AWREADY
      ##1 `ACE_SVA_RSTn
      |-> $stable(AWQOS);
  endproperty
  ace_errm_awqos_stable: assert property (ACE_ERRM_AWQOS_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWQOS_STABLE);

  // =====
  // INDEX:        - ACE_ERRM_AWREGION_STABLE
  // =====
  property ACE_ERRM_AWREGION_STABLE;
    @(posedge `ACE_SVA_CLK)
      !($isunknown({AWVALID,AWREADY,AWREGION})) &&
      `ACE_SVA_RSTn && AWVALID && !AWREADY
      ##1 `ACE_SVA_RSTn
      |-> $stable(AWREGION);
  endproperty
  ace_errm_awregion_stable: assert property (ACE_ERRM_AWREGION_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWREGION_STABLE);

  // =====
  // INDEX:        - ACE_ERRM_AWUSER_STABLE
  // =====
  property ACE_ERRM_AWUSER_STABLE;
    @(posedge `ACE_SVA_CLK)
      !($isunknown({AWVALID,AWREADY,AWUSER})) &&
      `ACE_SVA_RSTn && AWVALID && !AWREADY
      ##1 `ACE_SVA_RSTn
      |-> $stable(AWUSER);
  endproperty
  ace_errm_awuser_stable: assert property (ACE_ERRM_AWUSER_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWUSER_STABLE);

  // =====
  // INDEX:        - ACE_RECS_AWREADY_MAX_WAIT
  // =====
  // Note: this rule does not error if VALID goes low (breaking VALID_STABLE rule)
  property   ACE_RECS_AWREADY_MAX_WAIT;
    @(posedge `ACE_SVA_CLK)
      `ACE_SVA_RSTn && !($isunknown({AWVALID,AWREADY})) &&
      RecommendOn  && // Parameter that can disable all ACE_REC*_* rules
      RecMaxWaitOn && // Parameter that can disable just ACE_REC*_MAX_WAIT rules
      ( AWVALID && !AWREADY)  // READY=1 within MAXWAITS cycles (or VALID=0)
      |-> ##[1:MAXWAITS] (!AWVALID |  AWREADY); 
  endproperty
  ace_recs_awready_max_wait: assert property (ACE_RECS_AWREADY_MAX_WAIT) else
   `ARM_AMBA4_PC_MSG_WARN(`RECS_AWREADY_MAX_WAIT);  

//------------------------------------------------------------------------------
// INDEX:      3) X-Propagation Rules
//------------------------------------------------------------------------------
`ifdef AXI4_XCHECK_OFF
`else  // X-Checking on by default
  // =====
  // INDEX:        - ACE_ERRM_AWVALID_X
  // =====
  // This rule is effectively disabled in the axi4pc for barriers and evicts
  // and so is duplicated here
  property ACE_ERRM_AWVALID_X;
    @(posedge `ACE_SVA_CLK)
      `ACE_SVA_RSTn
      |-> ! $isunknown(AWVALID);
  endproperty
  ace_errm_awvalid_x: assert property (ACE_ERRM_AWVALID_X) else
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWVALID_X);

  // =====
  // INDEX:        - ACE_ERRM_AWDOMAIN_X
  // =====
  property ACE_ERRM_AWDOMAIN_X;
    @(posedge `ACE_SVA_CLK) 
        `ACE_SVA_RSTn && AWVALID |-> ! $isunknown(AWDOMAIN);
  endproperty
  ace_errm_awdomain_x : assert property(ACE_ERRM_AWDOMAIN_X) else 
     `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWDOMAIN_X);
   
  // =====
  // INDEX:        - ACE_ERRM_AWBAR_X
  // =====
  property ACE_ERRM_AWBAR_X;
    @(posedge `ACE_SVA_CLK) 
        `ACE_SVA_RSTn && AWVALID |-> ! $isunknown(AWBAR);
  endproperty
  ace_errm_awbar_x : assert property(ACE_ERRM_AWBAR_X) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWBAR_X); 

  // =====
  // INDEX:        - ACE_ERRM_AWSNOOP_X
  // =====
  property ACE_ERRM_AWSNOOP_X;
    @(posedge `ACE_SVA_CLK) 
        `ACE_SVA_RSTn && AWVALID |-> ! $isunknown(AWSNOOP);
  endproperty
  ace_errm_awsnoop_x :  assert property(ACE_ERRM_AWSNOOP_X) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWSNOOP_X); 
      
  // =====
  // INDEX:        - ACE_ERRM_AWADDR_X
  // =====
  property ACE_ERRM_AWADDR_X;
    @(posedge `ACE_SVA_CLK)
      `ACE_SVA_RSTn && AWVALID
      |-> ! $isunknown(AWADDR);
  endproperty
  ace_errm_awaddr_x: assert property (ACE_ERRM_AWADDR_X) else
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWADDR_X);

  // =====
  // INDEX:        - ACE_ERRM_AWBURST_X
  // =====
  property ACE_ERRM_AWBURST_X;
    @(posedge `ACE_SVA_CLK)
      `ACE_SVA_RSTn && AWVALID
      |-> ! $isunknown(AWBURST);
  endproperty
  ace_errm_awburst_x: assert property (ACE_ERRM_AWBURST_X) else
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWBURST_X);

  // =====
  // INDEX:        - ACE_ERRM_AWCACHE_X
  // =====
  property ACE_ERRM_AWCACHE_X;
    @(posedge `ACE_SVA_CLK)
      `ACE_SVA_RSTn && AWVALID
      |-> ! $isunknown(AWCACHE);
  endproperty
  ace_errm_awcache_x: assert property (ACE_ERRM_AWCACHE_X) else
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWCACHE_X);

  // =====
  // INDEX:        - ACE_ERRM_AWID_X
  // =====
  property ACE_ERRM_AWID_X;
    @(posedge `ACE_SVA_CLK)
      `ACE_SVA_RSTn && AWVALID
      |-> ! $isunknown(AWID);
  endproperty
  ace_errm_awid_x: assert property (ACE_ERRM_AWID_X) else
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWID_X);

  // =====
  // INDEX:        - ACE_ERRM_AWLEN_X
  // =====
  property ACE_ERRM_AWLEN_X;
    @(posedge `ACE_SVA_CLK)
      `ACE_SVA_RSTn && AWVALID
      |-> ! $isunknown(AWLEN);
  endproperty
  ace_errm_awlen_x: assert property (ACE_ERRM_AWLEN_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWLEN_X);

  // =====
  // INDEX:        - ACE_ERRM_AWLOCK_X
  // =====
  property ACE_ERRM_AWLOCK_X;
    @(posedge `ACE_SVA_CLK)
      `ACE_SVA_RSTn && AWVALID
      |-> ! $isunknown(AWLOCK);
  endproperty
  ace_errm_awlock_x: assert property (ACE_ERRM_AWLOCK_X) else
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWLOCK_X);

  // =====
  // INDEX:        - ACE_ERRM_AWPROT_X
  // =====
  property ACE_ERRM_AWPROT_X;
    @(posedge `ACE_SVA_CLK)
      `ACE_SVA_RSTn && AWVALID
      |-> ! $isunknown(AWPROT);
  endproperty
  ace_errm_awprot_x: assert property (ACE_ERRM_AWPROT_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWPROT_X);

  // =====
  // INDEX:        - ACE_ERRM_AWSIZE_X
  // =====
  property ACE_ERRM_AWSIZE_X;
    @(posedge `ACE_SVA_CLK)
      `ACE_SVA_RSTn && AWVALID
      |-> ! $isunknown(AWSIZE);
  endproperty
  ace_errm_awsize_x: assert property (ACE_ERRM_AWSIZE_X) else
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWSIZE_X);

  // =====
  // INDEX:        - ACE_ERRM_AWQOS_X
  // =====
  property ACE_ERRM_AWQOS_X;
    @(posedge `ACE_SVA_CLK)
      `ACE_SVA_RSTn && AWVALID
      |-> ! $isunknown(AWQOS);
  endproperty
  ace_errm_awqos_x: assert property (ACE_ERRM_AWQOS_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWQOS_X);

  // =====
  // INDEX:        - ACE_ERRM_AWREGION_X
  // =====
  property ACE_ERRM_AWREGION_X;
    @(posedge `ACE_SVA_CLK)
      `ACE_SVA_RSTn && AWVALID
      |-> ! $isunknown(AWREGION);
  endproperty
  ace_errm_awregion_x: assert property (ACE_ERRM_AWREGION_X) else
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWREGION_X);

  // =====
  // INDEX:        - ACE_ERRM_AWUSER_X
  // =====
  property ACE_ERRM_AWUSER_X;
    @(posedge `ACE_SVA_CLK)
      `ACE_SVA_RSTn && AWVALID
      |-> ! $isunknown(AWUSER);
  endproperty
  ace_errm_awuser_x: assert property (ACE_ERRM_AWUSER_X) else
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWUSER_X);

`endif // AXI4_XCHECK_OFF
//------------------------------------------------------------------------------
// INDEX:
// INDEX:   16)  ACE Rules: Write Data Channel (*_W*)
//------------------------------------------------------------------------------

  // =====
  // INDEX:        - ACE_ERRM_WLU_STRB
  // =====
  // WriteLineUnique transactions are not permitted to have sparse strobes
  property ACE_ERRM_WLU_STRB;
    @(posedge `ACE_SVA_CLK) 
    `ACE_SVA_RSTn && !($isunknown({WVALID,WSTRB,CurrentWInfo})) &&
      WVALID && CurrentWInfo[AW_WLU]
      |-> &WSTRB;
  endproperty
  ace_errm_wlu_strb : assert property(ACE_ERRM_WLU_STRB) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_WLU_STRB);


//------------------------------------------------------------------------------
// INDEX:      1) Functional Rules
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// INDEX:      2) Handshake Rules
//------------------------------------------------------------------------------
// The handshake rules for the W channel are all handled by the Axi4 PC since
// none of the signals are gated on this channel
//------------------------------------------------------------------------------
// INDEX:      3) X-Propagation Rules
//------------------------------------------------------------------------------
// The X-Propagation rules for the W channel are all handled by the Axi4 PC since
// none of the signals are gated on this channel
//------------------------------------------------------------------------------
// INDEX:
// INDEX:   17)  ACE Rules: Write Response Channel (*_B*) 
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// INDEX:      1) Functional Rules
//------------------------------------------------------------------------------

  // =====
  // INDEX:        - ACE_ERRS_BVALID_RESET
  // =====
  property ACE_ERRS_BVALID_RESET;
    @(posedge `ACE_SVA_CLK) 
      !(`ACE_SVA_RSTn) && !($isunknown(`ACE_SVA_RSTn))
      ##1  `ACE_SVA_RSTn
      |-> !BVALID;
  endproperty
  ace_errs_bvalid_reset: assert property (ACE_ERRS_BVALID_RESET) else
    `ARM_AMBA4_PC_MSG_ERR(`ERRS_BVALID_RESET);

  // =====
  // INDEX:        - ACE_ERRS_BRESP_WNS_EXOKAY
  // =====
  // An EXOKAY response can only be given to a writenosnoop
  property ACE_ERRS_BRESP_WNS_EXOKAY;
    @(posedge `ACE_SVA_CLK) 
    `ACE_SVA_RSTn && !($isunknown({BVALID,BRESP,CurrentBInfo})) &&
      BVALID && (BRESP == `AXI4PC_RESP_EXOKAY) 
      |-> CurrentBInfo[AW_WNS];
  endproperty
  ace_errs_bresp_wns_exokay: assert property(ACE_ERRS_BRESP_WNS_EXOKAY) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRS_BRESP_WNS_EXOKAY);

  // =====
  // INDEX:        - ACE_ERRS_BRESP_BAR
  // =====
  // When BVALID is asserted for a barrier transaction the BRESP[3:2] bits must be 00
  property ACE_ERRS_BRESP_BAR;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn && !($isunknown({BVALID,CurrentBInfo[AW_BARRIER],BRESP})) &&
      BVALID && (CurrentBInfo[AW_BARRIER] == 1'b1) 
      |-> BRESP == `AXI4PC_RESP_OKAY;
  endproperty
  ace_errs_bresp_bar: assert property (ACE_ERRS_BRESP_BAR) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRS_BRESP_BAR);

  // =====
  // INDEX:        - ACE_ERRS_BRESP_AW_WLAST
  // =====
  // BVALID must only be asserted after WLAST and AW for non barrier transactions or non write evict transactions
  property ACE_ERRS_BRESP_AW_WLAST;
    @(posedge `ACE_SVA_CLK)
      `ACE_SVA_RSTn && !($isunknown({BVALID,BIDMatch})) && BVALID
      |-> BIDMatch != 0;
  endproperty
  ace_errs_bresp_aw_wlast: assert property (ACE_ERRS_BRESP_AW_WLAST) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRS_BRESP_AW_WLAST);

//------------------------------------------------------------------------------
// INDEX:      2) Handshake Rules
//------------------------------------------------------------------------------

  // =====
  // INDEX:        - ACE_ERRS_BVALID_STABLE
  // =====
  // this rule is effectively disabled in the Axi4PC by the BVALID_Axi4PC
  // logic so it must be duplicated here
  property ACE_ERRS_BVALID_STABLE;
    @(posedge `ACE_SVA_CLK)
      `ACE_SVA_RSTn && BVALID && !BREADY && !($isunknown({BVALID,BREADY}))
      ##1 `ACE_SVA_RSTn
      |-> BVALID;
  endproperty
  ace_errs_bvalid_stable: assert property (ACE_ERRS_BVALID_STABLE) else
    `ARM_AMBA4_PC_MSG_ERR(`ERRS_BVALID_STABLE);
 
  // =====
  // INDEX:        - ACE_ERRS_BID_STABLE
  // =====
  property ACE_ERRS_BID_STABLE;
    @(posedge `ACE_SVA_CLK)
      !($isunknown({BVALID,BREADY,BID})) &&
      `ACE_SVA_RSTn && BVALID && !BREADY
      ##1 `ACE_SVA_RSTn
      |-> $stable(BID);
  endproperty
  ace_errs_bid_stable: assert property (ACE_ERRS_BID_STABLE) else
    `ARM_AMBA4_PC_MSG_ERR(`ERRS_BID_STABLE);

  // =====
  // INDEX:        - ACE_ERRS_BRESP_STABLE
  // =====
  property ACE_ERRS_BRESP_STABLE;
    @(posedge `ACE_SVA_CLK)
      !($isunknown({BVALID,BREADY,BRESP})) &&
      `ACE_SVA_RSTn && BVALID && !BREADY
      ##1 `ACE_SVA_RSTn
      |-> $stable(BRESP);
  endproperty
  ace_errs_bresp_stable: assert property (ACE_ERRS_BRESP_STABLE) else
    `ARM_AMBA4_PC_MSG_ERR(`ERRS_BRESP_STABLE);

  // =====
  // INDEX:        - ACE_ERRS_BUSER_STABLE
  // =====
  property ACE_ERRS_BUSER_STABLE;
    @(posedge `ACE_SVA_CLK)
      !($isunknown({BVALID,BREADY,BUSER})) &&
      `ACE_SVA_RSTn && BVALID && !BREADY
      ##1 `ACE_SVA_RSTn
      |-> $stable(BUSER);
  endproperty
  ace_errs_buser_stable: assert property (ACE_ERRS_BUSER_STABLE) else
    `ARM_AMBA4_PC_MSG_ERR(`ERRS_BUSER_STABLE);

  // =====
  // INDEX:        - ACE_RECM_BREADY_MAX_WAIT 
  // =====
  // Note: this rule does not error if VALID goes low (breaking VALID_STABLE rule)
  property   ACE_RECM_BREADY_MAX_WAIT;
    @(posedge `ACE_SVA_CLK)
      `ACE_SVA_RSTn && !($isunknown({BVALID,BREADY})) &&
      RecommendOn  && // Parameter that can disable all ACE_REC*_* rules
      RecMaxWaitOn && // Parameter that can disable just ACE_REC*_MAX_WAIT rules
      ( BVALID && !BREADY) // READY=1 within MAXWAITS cycles (or VALID=0)
      |-> ##[1:MAXWAITS] (!BVALID |  BREADY);    
  endproperty
  ace_recm_bready_max_wait: assert property (ACE_RECM_BREADY_MAX_WAIT) else
   `ARM_AMBA4_PC_MSG_WARN(`RECM_BREADY_MAX_WAIT);

//------------------------------------------------------------------------------
// INDEX:      3) X-Propagation Rules
//------------------------------------------------------------------------------
`ifdef AXI4_XCHECK_OFF
`else  // X-Checking on by default

  // =====
  // INDEX:        - ACE_ERRS_BID_X
  // =====
  // this rule is effectively disabled in the Axi4PC by the BVALID_Axi4PC
  // logic so it must be duplicated here
  property ACE_ERRS_BID_X;
    @(posedge `ACE_SVA_CLK)
      `ACE_SVA_RSTn && BVALID
      |-> ! $isunknown(BID);
  endproperty
  ace_errs_bid_x: assert property (ACE_ERRS_BID_X) else
    `ARM_AMBA4_PC_MSG_ERR(`ERRS_BID_X);
                         
  // =====
  // INDEX:        - ACE_ERRS_BRESP_X
  // =====
  // this rule is effectively disabled in the Axi4PC by the BVALID_Axi4PC
  // logic so it must be duplicated here
  property ACE_ERRS_BRESP_X;
    @(posedge `ACE_SVA_CLK)
      `ACE_SVA_RSTn && BVALID
      |-> ! $isunknown(BRESP);
  endproperty
  ace_errs_bresp_x: assert property (ACE_ERRS_BRESP_X) else
    `ARM_AMBA4_PC_MSG_ERR(`ERRS_BRESP_X);
                         

  // =====
  // INDEX:        - ACE_ERRM_WACK_X
  // =====
  property ACE_ERRM_WACK_X;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn
        |-> ! $isunknown(WACK);
  endproperty
  ace_errm_wack_x : assert property(ACE_ERRM_WACK_X) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_WACK_X);         

  // =====
  // INDEX:        - ACE_ERRS_BVALID_X
  // =====
  property ACE_ERRS_BVALID_X;
    @(posedge `ACE_SVA_CLK)
      `ACE_SVA_RSTn
      |-> ! $isunknown(BVALID);
  endproperty
  ace_errs_bvalid_x: assert property (ACE_ERRS_BVALID_X) else
    `ARM_AMBA4_PC_MSG_ERR(`ERRS_BVALID_X);

  // =====
  // INDEX:        - ACE_ERRS_BUSER_X
  // =====
  property ACE_ERRS_BUSER_X;
    @(posedge `ACE_SVA_CLK)
      `ACE_SVA_RSTn && BVALID
      |-> ! $isunknown(BUSER);
  endproperty
  ace_errs_buser_x: assert property (ACE_ERRS_BUSER_X) else
    `ARM_AMBA4_PC_MSG_ERR(`ERRS_BUSER_X);

`endif // AXI4_XCHECK_OFF
//------------------------------------------------------------------------------
// INDEX:
// INDEX:   18)  ACE Rules: Read Address Channel (*_AR*)
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// INDEX:      1) Functional Rules
//------------------------------------------------------------------------------

  // =====
  // INDEX:        - ACE_ERRM_ARSNOOP
  // =====
  // ARSNOOP value must be legal
  property ACE_ERRM_ARSNOOP;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn && !($isunknown({ARVALID,ARSNOOP})) &&
      ARVALID
      |-> (ARSNOOP == `ACEPC_ARSNOOP_READONCE) || 
        (ARSNOOP == `ACEPC_ARSNOOP_READCLEAN) || 
        (ARSNOOP == `ACEPC_ARSNOOP_READSHARED) || 
        (ARSNOOP == `ACEPC_ARSNOOP_READNOTSHAREDDIRTY) || 
        (ARSNOOP == `ACEPC_ARSNOOP_READUNIQUE) || 
        (ARSNOOP == `ACEPC_ARSNOOP_CLEANSHARED) || 
        (ARSNOOP == `ACEPC_ARSNOOP_CLEANUNIQUE) || 
        (ARSNOOP == `ACEPC_ARSNOOP_CLEANINVALID) || 
        (ARSNOOP == `ACEPC_ARSNOOP_MAKEUNIQUE) || 
        (ARSNOOP == `ACEPC_ARSNOOP_MAKEINVALID) ||  
        (ARSNOOP == `ACEPC_ARSNOOP_DVMCOMPLETE) || 
        (ARSNOOP == `ACEPC_ARSNOOP_DVMMESSAGE);
  endproperty
  ace_errm_arsnoop : assert property(ACE_ERRM_ARSNOOP) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARSNOOP);


  // =====
  // INDEX:        - ACE_ERRM_ARCACHE_DEVICE
  // =====
  property ACE_ERRM_ARCACHE_DEVICE;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn && !($isunknown({ARVALID,ARCACHE,ARDOMAIN})) &&
      ARVALID && !ARCACHE[1]
      |-> (ARDOMAIN == `ACEPC_AXDOMAIN_SYS_DOMAIN);
  endproperty
  ace_errm_arcache_device: assert property (ACE_ERRM_ARCACHE_DEVICE) else
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARCACHE_DEVICE);


  // =====
  // INDEX:        - ACE_ERRM_ARCACHE_SYSTEM
  // =====
  property ACE_ERRM_ARCACHE_SYSTEM;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn && !($isunknown({ARVALID,ARCACHE,ARDOMAIN})) &&
      ARVALID && |ARCACHE[3:2]
      |-> (ARDOMAIN != `ACEPC_AXDOMAIN_SYS_DOMAIN);
  endproperty
  ace_errm_arcache_system: assert property (ACE_ERRM_ARCACHE_SYSTEM) else
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARCACHE_SYSTEM); 
   
  // =====
  // INDEX:        - ACE_ERRM_ARLEN_WRAP
  // =====
  property ACE_ERRM_ARLEN_WRAP;
    @(posedge `ACE_SVA_CLK) 
      !($isunknown({ARVALID,ARBURST,ARLEN})) &&
      ARVALID && (ARBURST == `AXI4PC_ABURST_WRAP) 
      |-> ( ARLEN == `AXI4PC_ALEN_2 ||
           ARLEN == `AXI4PC_ALEN_4 ||
           ARLEN == `AXI4PC_ALEN_8 ||
           ARLEN == `AXI4PC_ALEN_16);
  endproperty
  ace_errm_arlen_wrap: assert property (ACE_ERRM_ARLEN_WRAP) else
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARLEN_WRAP);

  // =====
  // INDEX:        - ACE_ERRM_AR_FULL_LINE
  // =====
  property ACE_ERRM_AR_FULL_LINE;
    @(posedge `ACE_SVA_CLK) 
    `ACE_SVA_RSTn && !($isunknown({ARVALID,ARSNOOP,ARLEN,ARSIZE})) &&
      ARVALID && (ARSNOOP == `ACEPC_ARSNOOP_READSHARED ||
                  ARSNOOP == `ACEPC_ARSNOOP_READCLEAN ||
                  ARSNOOP == `ACEPC_ARSNOOP_READNOTSHAREDDIRTY ||
                  ARSNOOP == `ACEPC_ARSNOOP_READUNIQUE ||
                  ARSNOOP == `ACEPC_ARSNOOP_CLEANSHARED ||
                  ARSNOOP == `ACEPC_ARSNOOP_CLEANINVALID ||
                  ARSNOOP == `ACEPC_ARSNOOP_CLEANUNIQUE ||
                  ARSNOOP == `ACEPC_ARSNOOP_MAKEUNIQUE ||
                  ARSNOOP == `ACEPC_ARSNOOP_MAKEINVALID )
      |-> (ARLEN == CACHE_LINE_AxLEN) && (ARSIZE == CACHE_LINE_AxSIZE);
  endproperty
  ace_errm_ar_full_line :  assert property(ACE_ERRM_AR_FULL_LINE) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_AR_FULL_LINE);

  // =====
  // INDEX:        - ACE_ERRM_AR_SHAREABLE_LOCK
  // =====
  property ACE_ERRM_AR_SHAREABLE_LOCK;
    @(posedge `ACE_SVA_CLK) 
    `ACE_SVA_RSTn && !($isunknown({ARVALID,ARSNOOP,ARLOCK})) &&
      ARVALID && ( ARSNOOP == `ACEPC_ARSNOOP_READNOTSHAREDDIRTY ||
                  (ARSNOOP == `ACEPC_ARSNOOP_READONCE && ^ARDOMAIN) ||
                  ARSNOOP == `ACEPC_ARSNOOP_READUNIQUE ||
                  ARSNOOP == `ACEPC_ARSNOOP_CLEANSHARED ||
                  ARSNOOP == `ACEPC_ARSNOOP_CLEANINVALID ||
                  ARSNOOP == `ACEPC_ARSNOOP_MAKEUNIQUE ||
                  ARSNOOP == `ACEPC_ARSNOOP_MAKEINVALID )
      |-> !ARLOCK;
  endproperty
  ace_errm_ar_shareable_lock : assert property(ACE_ERRM_AR_SHAREABLE_LOCK) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_AR_SHAREABLE_LOCK);

  // =====
  // INDEX:        - ACE_ERRM_AR_SHAREABLE_CTL
  // =====
  property ACE_ERRM_AR_SHAREABLE_CTL;
    @(posedge `ACE_SVA_CLK) 
    `ACE_SVA_RSTn && !($isunknown({ARVALID,ARSNOOP,ARBURST,ARBAR,ARCACHE,ARLOCK,ARDOMAIN})) &&
      ARVALID && (ARSNOOP == `ACEPC_ARSNOOP_READONCE && !ARBAR[0] && ^ARDOMAIN ||
                  ARSNOOP == `ACEPC_ARSNOOP_READSHARED ||
                  ARSNOOP == `ACEPC_ARSNOOP_READCLEAN ||
                  ARSNOOP == `ACEPC_ARSNOOP_READNOTSHAREDDIRTY ||
                  ARSNOOP == `ACEPC_ARSNOOP_READUNIQUE ||
                  ARSNOOP == `ACEPC_ARSNOOP_CLEANSHARED ||
                  ARSNOOP == `ACEPC_ARSNOOP_CLEANINVALID ||
                  ARSNOOP == `ACEPC_ARSNOOP_CLEANUNIQUE ||
                  ARSNOOP == `ACEPC_ARSNOOP_MAKEUNIQUE ||
                  ARSNOOP == `ACEPC_ARSNOOP_MAKEINVALID )
      |-> (ARBURST != `AXI4PC_ABURST_FIXED) &&
           !ARBAR[0] &&
           ARCACHE[1]; 
  endproperty
  ace_errm_ar_shareable_ctl : assert property(ACE_ERRM_AR_SHAREABLE_CTL) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_AR_SHAREABLE_CTL);

  // =====
  // INDEX:        - ACE_ERRM_AR_DOMAIN_2
  // =====
  property ACE_ERRM_AR_DOMAIN_2;
    @(posedge `ACE_SVA_CLK) 
    `ACE_SVA_RSTn && !($isunknown({ARVALID,ARSNOOP,ARDOMAIN})) &&
      ARVALID && (ARSNOOP == `ACEPC_ARSNOOP_READSHARED ||
                  ARSNOOP == `ACEPC_ARSNOOP_READCLEAN ||
                  ARSNOOP == `ACEPC_ARSNOOP_READNOTSHAREDDIRTY ||
                  ARSNOOP == `ACEPC_ARSNOOP_READUNIQUE ||
                  ARSNOOP == `ACEPC_ARSNOOP_CLEANUNIQUE ||
                  ARSNOOP == `ACEPC_ARSNOOP_MAKEUNIQUE  )
      |-> ((ARDOMAIN == `ACEPC_AXDOMAIN_INNER_DOMAIN) || (ARDOMAIN == `ACEPC_AXDOMAIN_OUTER_DOMAIN)) ;
  endproperty
  ace_errm_ar_domain_2 : assert property(ACE_ERRM_AR_DOMAIN_2) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_AR_DOMAIN_2);

  // =====
  // INDEX:        - ACE_ERRM_AR_DOMAIN_1
  // =====
  property ACE_ERRM_AR_DOMAIN_1;
    @(posedge `ACE_SVA_CLK) 
    `ACE_SVA_RSTn && !($isunknown({ARVALID,ARSNOOP,ARDOMAIN})) &&
      ARVALID && (ARSNOOP == `ACEPC_ARSNOOP_CLEANINVALID ||
                  ARSNOOP == `ACEPC_ARSNOOP_CLEANSHARED ||
                  ARSNOOP == `ACEPC_ARSNOOP_MAKEINVALID  )
      |-> (ARDOMAIN != `ACEPC_AXDOMAIN_SYS_DOMAIN);
  endproperty
  ace_errm_ar_domain_1 : assert property(ACE_ERRM_AR_DOMAIN_1) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_AR_DOMAIN_1);

  // ===
  // INDEX:        - ACE_ERRM_AR_SHAREABLE_ALIGN_INCR
  // =====
  // RS,RC,RNSD,RU,CS,CI,CU,MU,MI transactions with AWBURST = INCR 
  // must be aligned to the cache line size
  property ACE_ERRM_AR_SHAREABLE_ALIGN_INCR;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn && !($isunknown({ARVALID,ARSNOOP,ARADDR,ARBURST})) &&
      ARVALID && (ARSNOOP == `ACEPC_ARSNOOP_READSHARED ||
                  ARSNOOP == `ACEPC_ARSNOOP_READCLEAN ||
                  ARSNOOP == `ACEPC_ARSNOOP_READNOTSHAREDDIRTY ||
                  ARSNOOP == `ACEPC_ARSNOOP_READUNIQUE ||
                  ARSNOOP == `ACEPC_ARSNOOP_CLEANSHARED ||
                  ARSNOOP == `ACEPC_ARSNOOP_CLEANINVALID ||
                  ARSNOOP == `ACEPC_ARSNOOP_CLEANUNIQUE ||
                  ARSNOOP == `ACEPC_ARSNOOP_MAKEUNIQUE ||
                  ARSNOOP == `ACEPC_ARSNOOP_MAKEINVALID ) &&
                  ARBURST == `AXI4PC_ABURST_INCR
      |-> (ARADDR[10:0] & CACHE_LINE_MASK) == ARADDR[10:0];
  endproperty
  ace_errm_ar_shareable_align_incr :  assert property(ACE_ERRM_AR_SHAREABLE_ALIGN_INCR) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_AR_SHAREABLE_ALIGN_INCR);

   // INDEX:        - ACE_ERRM_R_W_HAZARD
   // =====

  always @(`ACE_AUX_RSTn or ARVALID or ARSNOOP or min_ar_address or max_ar_address or
          min_aw_address or max_aw_address or AWBAR or ARBAR)
  begin
    integer    i; //loop counter
    if (!`ACE_AUX_RSTn || !ARVALID )
    begin
      REC_R_W_HAZARD = 1'b0;
    end
    else 
    begin
      REC_R_W_HAZARD = 1'b0;
      if (AWVALID)
      begin
        if (!AWBAR[0] && !ARBAR[0] && (ARSNOOP != `ACEPC_ARSNOOP_DVMCOMPLETE) && (ARSNOOP != `ACEPC_ARSNOOP_DVMMESSAGE))
        begin
          if (overlapping(min_ar_address, max_ar_address,
                          min_aw_address, max_aw_address)
              && (ARPROT[1] == AWPROT[1])) 
          begin
                  REC_R_W_HAZARD = 1'b1;
          end
        end
      end
    
      if ((ARSNOOP != `ACEPC_ARSNOOP_DVMCOMPLETE) && (ARSNOOP != `ACEPC_ARSNOOP_DVMMESSAGE) && !ARBAR[0])
      begin
        for (i = 1; i <= MAXWBURSTS; i = i + 1)
        begin
          if (i < AWIndex)
          begin
            if (overlapping(min_tx_address(AWInfo[i][AWADDR_HI:AWADDR_LO], 
                                           AWInfo[i][AWBURST_HI:AWBURST_LO],
                                           AWInfo[i][AWLEN_HI:AWLEN_LO],
                                           AWInfo[i][AWSIZE_HI:AWSIZE_LO]),
                            max_tx_address(AWInfo[i][AWADDR_HI:AWADDR_LO], 
                                           AWInfo[i][AWBURST_HI:AWBURST_LO],
                                           AWInfo[i][AWLEN_HI:AWLEN_LO],
                                           AWInfo[i][AWSIZE_HI:AWSIZE_LO]),
                            min_ar_address, max_ar_address)
                          && AWInfo[i][AW_ADDR] && !AWInfo[i][AW_BARRIER]
                 && (ARPROT[1] == AWInfo[i][AWPROT_1]))
            begin
              REC_R_W_HAZARD = 1'b1;
            end
          end
        end
      end
    end
  end
  property ACE_RECM_R_W_HAZARD;
     @(posedge `ACE_SVA_CLK) 
     `ACE_SVA_RSTn && !($isunknown({REC_R_W_HAZARD,ARVALID})) && 
      ARVALID && RecommendOn
      |-> !REC_R_W_HAZARD;
  endproperty
  ace_recm_r_w_hazard: assert property (ACE_RECM_R_W_HAZARD) else
    `ARM_AMBA4_PC_MSG_WARN(`RECM_R_W_HAZARD);
 
      

//------------------------------------------------------------------------------
// INDEX:      2) Handshake Rules
//------------------------------------------------------------------------------

  // =====
  // INDEX:        - ACE_ERRM_ARDOMAIN_STABLE
  // =====
  property ACE_ERRM_ARDOMAIN_STABLE;
    @(posedge `ACE_SVA_CLK)
      !($isunknown({ARVALID,ARREADY,ARDOMAIN})) &&
      `ACE_SVA_RSTn && ARVALID && !ARREADY
      ##1 `ACE_SVA_RSTn
      |-> $stable(ARDOMAIN);
  endproperty
  ace_errm_ardomain_stable: assert property (ACE_ERRM_ARDOMAIN_STABLE) else
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARDOMAIN_STABLE);

  // =====
  // INDEX:        - ACE_ERRM_ARLEN_STABLE
  // =====
  // this rule has been effectively disabled in the axi4pc for barriers and
  // evicts and so is duplicated here.
  property ACE_ERRM_ARLEN_STABLE;
    @(posedge `ACE_SVA_CLK)
      !($isunknown({ARVALID,ARREADY,ARLEN})) &&
      `ACE_SVA_RSTn && ARVALID && !ARREADY
      ##1 `ACE_SVA_RSTn
      |-> $stable(ARLEN);
  endproperty
  ace_errm_arlen_stable: assert property (ACE_ERRM_ARLEN_STABLE) else
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARLEN_STABLE);

  // =====
  // INDEX:        - ACE_ERRM_ARSNOOP_STABLE
  // =====
  property ACE_ERRM_ARSNOOP_STABLE;
    @(posedge `ACE_SVA_CLK)
      !($isunknown({ARVALID,ARREADY,ARSNOOP})) &&
      `ACE_SVA_RSTn && ARVALID && !ARREADY
      ##1 `ACE_SVA_RSTn
      |-> $stable(ARSNOOP);
  endproperty
  ace_errm_arsnoop_stable: assert property (ACE_ERRM_ARSNOOP_STABLE) else
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARSNOOP_STABLE);

  // =====
  // INDEX:        - ACE_ERRM_ARBAR_STABLE
  // =====
  property ACE_ERRM_ARBAR_STABLE;
    @(posedge `ACE_SVA_CLK)
      !($isunknown({ARVALID,ARREADY,ARBAR})) &&
      `ACE_SVA_RSTn && ARVALID && !ARREADY
      ##1 `ACE_SVA_RSTn
      |-> $stable(ARBAR);
  endproperty
  ace_errm_arbar_stable: assert property (ACE_ERRM_ARBAR_STABLE) else
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARBAR_STABLE);


  // INDEX:        - ACE_ERRM_ARLOCK_STABLE
  // =====
  // The Axi4pc_ace does not have visibility of the lock signal for shareable
  // reads
  property ACE_ERRM_ARLOCK_STABLE;
    @(posedge `ACE_SVA_CLK)
      !($isunknown({ARVALID,ARREADY,ARLOCK})) &
      `ACE_SVA_RSTn & ARVALID & !ARREADY
      ##1 `ACE_SVA_RSTn
      |-> $stable(ARLOCK);
  endproperty
  ace_errm_arlock_stable: assert property (ACE_ERRM_ARLOCK_STABLE) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARLOCK_STABLE);



//------------------------------------------------------------------------------
// INDEX:      3) X-Propagation Rules
//------------------------------------------------------------------------------
`ifdef AXI4_XCHECK_OFF
`else  // X-Checking on by default
 
  // =====
  // INDEX:        - ACE_ERRM_ARDOMAIN_X
  // =====
  property ACE_ERRM_ARDOMAIN_X;
    @(posedge `ACE_SVA_CLK) 
        `ACE_SVA_RSTn && ARVALID 
        |-> ! $isunknown(ARDOMAIN);
  endproperty
  ace_errm_ardomain_x : assert property(ACE_ERRM_ARDOMAIN_X) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARDOMAIN_X);        

  // =====
  // INDEX:        - ACE_ERRM_ARBAR_X
  // =====
  property ACE_ERRM_ARBAR_X;
    @(posedge `ACE_SVA_CLK) 
        `ACE_SVA_RSTn && ARVALID 
        |-> ! $isunknown(ARBAR);
  endproperty
  ace_errm_arbar_x : assert property(ACE_ERRM_ARBAR_X) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARBAR_X); 

  // =====
  // INDEX:        - ACE_ERRM_ARSNOOP_X
  // =====
  property ACE_ERRM_ARSNOOP_X;
    @(posedge `ACE_SVA_CLK) 
        `ACE_SVA_RSTn && ARVALID 
        |-> ! $isunknown(ARSNOOP);
  endproperty
  ace_errm_arsnoop_x : assert property(ACE_ERRM_ARSNOOP_X) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARSNOOP_X);

  // =====
  // INDEX:        - ACE_ERRM_ARLEN_X
  // =====
  property ACE_ERRM_ARLEN_X;
    @(posedge `ACE_SVA_CLK)
      `ACE_SVA_RSTn && ARVALID
      |-> ! $isunknown(ARLEN);
  endproperty
  ace_errm_arlen_x: assert property (ACE_ERRM_ARLEN_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARLEN_X);

  // INDEX:        - ACE_ERRM_ARLOCK_X
  // =====
  // The Axi4pc_ace does not have visibility of the lock signal for shareable
  // reads
  property ACE_ERRM_ARLOCK_X;
    @(posedge `ACE_SVA_CLK)
      `ACE_SVA_RSTn & ARVALID
      |-> ! $isunknown(ARLOCK);
  endproperty
  ace_errm_arlock_x: assert property (ACE_ERRM_ARLOCK_X) else
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARLOCK_X);



`endif // AXI4_XCHECK_OFF

//------------------------------------------------------------------------------
// INDEX:
// INDEX:   19)  ACE Rules: Read Data and Response Channel (*_R*)
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// INDEX:      1) Functional Rules
//------------------------------------------------------------------------------
  // =====
  // INDEX:        - ACE_ERRS_RRESP_SHARED
  // =====
  // Cannot give a shared reponse to a ReadUnique, CleanUnique, CleanInvalid or MakeUnique or MakeInvalid
  property ACE_ERRS_RRESP_SHARED;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn && !($isunknown({RVALID,CurrentRInfo,RRESP})) &&
      RVALID && 
      (((CurrentRInfo[ARSNOOP_HI:ARSNOOP_LO] == `ACEPC_ARSNOOP_READONCE) 
          && !CurrentRInfo[AR_BARRIER] && ~^CurrentRInfo[ARDOMAIN_HI:ARDOMAIN_LO]) || //ReadNoSnoop
       (CurrentRInfo[ARSNOOP_HI:ARSNOOP_LO] == `ACEPC_ARSNOOP_READUNIQUE) ||
       (CurrentRInfo[ARSNOOP_HI:ARSNOOP_LO] == `ACEPC_ARSNOOP_CLEANUNIQUE) ||
       (CurrentRInfo[ARSNOOP_HI:ARSNOOP_LO] == `ACEPC_ARSNOOP_CLEANINVALID)||
       (CurrentRInfo[ARSNOOP_HI:ARSNOOP_LO] == `ACEPC_ARSNOOP_MAKEUNIQUE) ||
       (CurrentRInfo[ARSNOOP_HI:ARSNOOP_LO] == `ACEPC_ARSNOOP_MAKEINVALID))
      |-> (RRESP[3:2] != `ACEPC_RRESP_SHAREDCLEAN) && (RRESP[3:2] != `ACEPC_RRESP_SHAREDDIRTY);
  endproperty
  ace_errs_rresp_shared :  assert property(ACE_ERRS_RRESP_SHARED) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRS_RRESP_SHARED);

  // =====
  // INDEX:        - ACE_ERRS_RRESP_DIRTY
  // =====
  // Can only give a dirty reponse to a ReadNotSharedDirty, ReadUnique 
  property ACE_ERRS_RRESP_DIRTY;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn && !($isunknown({RVALID,RRESP,CurrentRInfo[ARSNOOP_HI:ARSNOOP_LO]})) &&
      RVALID && ((RRESP[3:2] == `ACEPC_RRESP_UNIQUEDIRTY) || 
                  (RRESP[3:2] == `ACEPC_RRESP_SHAREDDIRTY))
      |-> ((CurrentRInfo[ARSNOOP_HI:ARSNOOP_LO] == `ACEPC_ARSNOOP_READNOTSHAREDDIRTY) || 
           (CurrentRInfo[ARSNOOP_HI:ARSNOOP_LO] == `ACEPC_ARSNOOP_READUNIQUE) || 
           (CurrentRInfo[ARSNOOP_HI:ARSNOOP_LO] == `ACEPC_ARSNOOP_READSHARED));
  endproperty
  ace_errs_rresp_dirty : assert property(ACE_ERRS_RRESP_DIRTY) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRS_RRESP_DIRTY);

  // =====
  // INDEX:        - ACE_ERRS_RRESP_RNSD
  // =====
  // Cannot give a share dirty response to a ReadNotSharedDirty
  property ACE_ERRS_RRESP_RNSD;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn && !($isunknown({RVALID,RRESP,CurrentRInfo[ARSNOOP_HI:ARSNOOP_LO]})) &&
      RVALID && (RRESP[3:2] == `ACEPC_RRESP_SHAREDDIRTY) 
      |-> (CurrentRInfo[ARSNOOP_HI:ARSNOOP_LO] != `ACEPC_ARSNOOP_READNOTSHAREDDIRTY); 
  endproperty
  ace_errs_rresp_rnsd : assert property(ACE_ERRS_RRESP_RNSD) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRS_RRESP_RNSD);

  // =====
  // INDEX:        - ACE_ERRS_RRESP_ACE_EXOKAY
  // =====
  // An EXOKAY response can only be given to a readnosnoop
  property ACE_ERRS_RRESP_ACE_EXOKAY;
    @(posedge `ACE_SVA_CLK) 
    `ACE_SVA_RSTn && !($isunknown({RVALID,RRESP,CurrentRInfo})) &&
      RVALID && (RRESP[1:0] == `AXI4PC_RESP_EXOKAY) 
      |-> ((((CurrentRInfo[ARSNOOP_HI:ARSNOOP_LO] == `ACEPC_ARSNOOP_READONCE)  &&
           !CurrentRInfo[AR_SHAREABLE] && !CurrentRInfo[AR_BARRIER]) ||
           (CurrentRInfo[ARSNOOP_HI:ARSNOOP_LO] == `ACEPC_ARSNOOP_READCLEAN) ||
           (CurrentRInfo[ARSNOOP_HI:ARSNOOP_LO] == `ACEPC_ARSNOOP_READSHARED) ||
           (CurrentRInfo[ARSNOOP_HI:ARSNOOP_LO] == `ACEPC_ARSNOOP_CLEANUNIQUE)) &&
            CurrentRInfo[AR_LOCK]) ;
  endproperty
  ace_errs_rresp_ace_exokay : assert property(ACE_ERRS_RRESP_ACE_EXOKAY) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRS_RRESP_ACE_EXOKAY);

  // =====
  // INDEX:        - ACE_ERRS_RRESP_BAR
  // =====
  // When RVALID is asserted for a barrier transaction RRESP must be 0
  property ACE_ERRS_RRESP_BAR;
    @(posedge `ACE_SVA_CLK) 
    `ACE_SVA_RSTn && !($isunknown({RVALID,RRESP,CurrentRInfo[AR_BARRIER]})) &&
      RVALID && (CurrentRInfo[AR_BARRIER] == 1'b1) 
      |-> ~|RRESP;
  endproperty
  ace_errs_rresp_bar : assert property(ACE_ERRS_RRESP_BAR) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRS_RRESP_BAR);

  // =====
  // INDEX:        - ACE_ERRS_DVM_LAST
  // =====
  // When RVALID is asserted for a DVM transaction RLAST must be
  // asserted
  property ACE_ERRS_DVM_LAST;
    @(posedge `ACE_SVA_CLK) 
    `ACE_SVA_RSTn && !($isunknown({RVALID,RLAST,CurrentRInfo[AR_DVM]})) &&
      RVALID && (CurrentRInfo[AR_DVM] == 1'b1) 
      |-> (RLAST == 1'b1);
  endproperty
  ace_errs_dvm_last : assert property(ACE_ERRS_DVM_LAST) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRS_DVM_LAST);

  // =====
  // INDEX:        - ACE_ERRS_R_BARRIER_LAST
  // =====
  // When RVALID is asserted for a barrier transaction RLAST must be
  // asserted
  property ACE_ERRS_R_BARRIER_LAST;
    @(posedge `ACE_SVA_CLK) 
    `ACE_SVA_RSTn && !($isunknown({RVALID,RLAST,CurrentRInfo[AR_BARRIER]})) &&
      RVALID && (CurrentRInfo[AR_BARRIER] == 1'b1) 
      |-> (RLAST == 1'b1);
  endproperty
  ace_errs_r_barrier_last : assert property(ACE_ERRS_R_BARRIER_LAST) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRS_R_BARRIER_LAST);

  // =====
  // INDEX:        - ACE_ERRS_RDATALESS
  // =====
  // When RVALID is asserted in response to a data-less transaction (clean or make)
  // there must only be one beat transfered
  wire       clean_make = (CurrentRInfo[ARSNOOP_HI:ARSNOOP_LO] == `ACEPC_ARSNOOP_CLEANSHARED ) ||
                    (CurrentRInfo[ARSNOOP_HI:ARSNOOP_LO] == `ACEPC_ARSNOOP_CLEANINVALID) ||
                    (CurrentRInfo[ARSNOOP_HI:ARSNOOP_LO] == `ACEPC_ARSNOOP_CLEANUNIQUE ) ||
                    (CurrentRInfo[ARSNOOP_HI:ARSNOOP_LO] == `ACEPC_ARSNOOP_MAKEUNIQUE  ) ||
                    (CurrentRInfo[ARSNOOP_HI:ARSNOOP_LO] == `ACEPC_ARSNOOP_MAKEINVALID ) ;
                    
  property ACE_ERRS_RDATALESS;
    @(posedge `ACE_SVA_CLK) 
    `ACE_SVA_RSTn && !($isunknown({RVALID,RLAST,clean_make})) &&
      RVALID && clean_make
      |-> RLAST ;
  endproperty
  ace_errs_rdataless :  assert property(ACE_ERRS_RDATALESS) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRS_RDATALESS);

  // =====
  // INDEX:        - ACE_ERRS_RRESP_CONST
  // =====
  // RRESP must remain constant for every beat of a transaction.
  // asserted
  property ACE_ERRS_RRESP_CONST;
    @(posedge `ACE_SVA_CLK) 
    `ACE_SVA_RSTn && !($isunknown({RVALID,RRESP,CurrentRInfo})) &&
      RVALID && (CurrentRInfo[AR_R_FIRST] == 1'b1) 
      |-> (RRESP[3:2] == CurrentRInfo[AR_RRESPHI:AR_RRESPLO]);
  endproperty
  ace_errs_rresp_const : assert property(ACE_ERRS_RRESP_CONST) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRS_RRESP_CONST);


 //------------------------------------------------------------------------------
 // INDEX:      2) Handshake Rules
 //------------------------------------------------------------------------------
 
  // =====
  // INDEX:        - ACE_ERRS_RRESP_STABLE
  // =====
  property ACE_ERRS_RRESP_STABLE;
    @(posedge `ACE_SVA_CLK) 
    `ACE_SVA_RSTn && !($isunknown({RVALID,RREADY,RRESP})) &&
      RVALID && !RREADY
      ##1 `ACE_SVA_RSTn
      |-> $stable(RRESP);
  endproperty
  ace_errs_rresp_stable: assert property (ACE_ERRS_RRESP_STABLE) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRS_RRESP_STABLE);
 
//------------------------------------------------------------------------------
// INDEX:      3) X-Propagation Rules
//------------------------------------------------------------------------------
`ifdef AXI4_XCHECK_OFF
`else  // X-Checking on by default

  // =====
  // INDEX:        - ACE_ERRS_RRESP_X
  // =====
  property ACE_ERRS_RRESP_X;
    @(posedge `ACE_SVA_CLK) 
    `ACE_SVA_RSTn && RVALID 
    |-> ! $isunknown(RRESP);
  endproperty
  ace_errs_rresp_x: assert property (ACE_ERRS_RRESP_X) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRS_RRESP_X);
   
  // =====
  // INDEX:        - ACE_ERRM_RACK_X
  // =====
  property ACE_ERRM_RACK_X;
    @(posedge `ACE_SVA_CLK) 
        `ACE_SVA_RSTn 
        |-> ! $isunknown(RACK);
  endproperty
  ace_errm_rack_x :  assert property(ACE_ERRM_RACK_X) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_RACK_X);

`endif // AXI4_XCHECK_OFF

//------------------------------------------------------------------------------
// INDEX:
// INDEX:   21)  ACE Rules: Snoop Address Channel (*_AC*)
//------------------------------------------------------------------------------


 //------------------------------------------------------------------------------
 // INDEX:      1) Functional Rules
 //------------------------------------------------------------------------------

  // =====
  // INDEX:        - ACE_ERRS_AC_ALIGN
  // =====
  // All snoops are wrapping and use the full width of the bus.  This means they must be aligned to a transfer.
  property ACE_ERRS_AC_ALIGN;
    @(posedge `ACE_SVA_CLK) disable iff (PROTOCOL == `AXI4PC_AMBA_ACE_LITE)  
    `ACE_SVA_RSTn && !($isunknown({ACVALID,ACSNOOP,ACADDR})) &&
          ACVALID && (ACSNOOP != `ACEPC_ACSNOOP_DVMCOMPLETE) && (ACSNOOP != `ACEPC_ACSNOOP_DVMMESSAGE)
      |-> ((ACADDR[6:0] & SIZEMASK_CD) == ACADDR[6:0]);
   endproperty
   ace_errs_ac_align: assert property (ACE_ERRS_AC_ALIGN) else 
     `ARM_AMBA4_PC_MSG_ERR(`ERRS_AC_ALIGN);
 
  // =====
  // INDEX:        - ACE_ERRS_ACSNOOP
  // =====
  // If ACVALID then ACSNOOP must be legal
  // Note: CleanUnique and MakeUnique must be converted to CleanInvalid and MakeInvalid respectively
  property ACE_ERRS_ACSNOOP;
    @(posedge `ACE_SVA_CLK) disable iff (PROTOCOL == `AXI4PC_AMBA_ACE_LITE)  
    `ACE_SVA_RSTn && !($isunknown({ACVALID,ACSNOOP})) &&
          ACVALID 
      |-> (`ACEPC_ACSNOOP_READONCE == ACSNOOP) ||
          (`ACEPC_ACSNOOP_READSHARED == ACSNOOP) ||
          (`ACEPC_ACSNOOP_READCLEAN == ACSNOOP) ||
          (`ACEPC_ACSNOOP_READNOTSHAREDDIRTY == ACSNOOP) ||
          (`ACEPC_ACSNOOP_READUNIQUE == ACSNOOP) ||
          (`ACEPC_ACSNOOP_CLEANSHARED == ACSNOOP) ||
          (`ACEPC_ACSNOOP_CLEANINVALID == ACSNOOP ) ||
          (`ACEPC_ACSNOOP_MAKEINVALID == ACSNOOP) ||
          (`ACEPC_ACSNOOP_DVMCOMPLETE == ACSNOOP) ||
          (`ACEPC_ACSNOOP_DVMMESSAGE == ACSNOOP);
   endproperty
   ace_errs_acsnoop : assert property (ACE_ERRS_ACSNOOP) else 
     `ARM_AMBA4_PC_MSG_ERR(`ERRS_ACSNOOP);
 
 
//------------------------------------------------------------------------------
// INDEX:      2) Handshake Rules
//------------------------------------------------------------------------------

  // =====
  // INDEX:        - ACE_ERRS_ACVALID_RESET
  // =====
  // ACVALID must be de-asserted in the first cycle after reset
  property ACE_ERRS_ACVALID_RESET;
     @(posedge `ACE_SVA_CLK)
          !(`ACE_SVA_RSTn) && !($isunknown(`ACE_SVA_RSTn))
          ##1   `ACE_SVA_RSTn 
      |-> !ACVALID;
  endproperty
  ace_errs_acvalid_reset: assert property (ACE_ERRS_ACVALID_RESET) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRS_ACVALID_RESET);

  // =====
  // INDEX:        - ACE_RECM_ACREADY_MAX_WAIT
  // =====
  // Note: this rule does not error if VALID goes low (breaking VALID_STABLE rule)
  property   ACE_RECM_ACREADY_MAX_WAIT;
    @(posedge `ACE_SVA_CLK) disable iff (PROTOCOL == `AXI4PC_AMBA_ACE_LITE) 
      `ACE_SVA_RSTn && !($isunknown({ACVALID,ACREADY})) &&
      RecommendOn  && // Parameter that can disable all ACE_REC*_* rules
      RecMaxWaitOn && // Parameter that can disable just ACE_REC*_MAX_WAIT rules
      ( ACVALID && !ACREADY)  // READY=1 within MAXWAITS cycles (or VALID=0)
      |-> ##[1:MAXWAITS] (!ACVALID |  ACREADY); 
  endproperty
  ace_recm_acready_max_wait: assert property (ACE_RECM_ACREADY_MAX_WAIT) else
    `ARM_AMBA4_PC_MSG_WARN(`RECM_ACREADY_MAX_WAIT);  

  // =====
  // INDEX:        - ACE_ERRS_ACVALID_STABLE
  // =====
  property ACE_ERRS_ACVALID_STABLE;
    @(posedge `ACE_SVA_CLK) disable iff (PROTOCOL == `AXI4PC_AMBA_ACE_LITE)  
    !($isunknown({ACVALID,ACREADY})) &&
      `ACE_SVA_RSTn &&  ACVALID && !ACREADY
      ##1 `ACE_SVA_RSTn
      |-> ACVALID;
    endproperty
   ace_errs_acvalid_stable: assert property (ACE_ERRS_ACVALID_STABLE) else 
     `ARM_AMBA4_PC_MSG_ERR(`ERRS_ACVALID_STABLE);

   // =====
   // INDEX:        - ACE_ERRS_ACADDR_STABLE
   // =====
   property ACE_ERRS_ACADDR_STABLE;
     @(posedge `ACE_SVA_CLK) disable iff (PROTOCOL == `AXI4PC_AMBA_ACE_LITE)  
     !($isunknown({ACVALID,ACREADY,ACADDR})) &&
     `ACE_SVA_RSTn && ACVALID && !ACREADY
      ##1 `ACE_SVA_RSTn
       |-> $stable(ACADDR);
    endproperty
    ace_errs_acaddr_stable: assert property (ACE_ERRS_ACADDR_STABLE) else 
      `ARM_AMBA4_PC_MSG_ERR(`ERRS_ACADDR_STABLE);
 
  // =====
  // INDEX:        - ACE_ERRS_ACSNOOP_STABLE
  // =====
  property ACE_ERRS_ACSNOOP_STABLE;
   @(posedge `ACE_SVA_CLK) disable iff (PROTOCOL == `AXI4PC_AMBA_ACE_LITE)  
    !($isunknown({ACVALID,ACREADY,ACSNOOP})) &&
    `ACE_SVA_RSTn && ACVALID && !ACREADY
     ##1 `ACE_SVA_RSTn
      |-> $stable(ACSNOOP);
   endproperty
   ace_errs_acsnoop_stable: assert property (ACE_ERRS_ACSNOOP_STABLE) else 
     `ARM_AMBA4_PC_MSG_ERR(`ERRS_ACSNOOP_STABLE);
 
  // =====
  // INDEX:        - ACE_ERRS_ACPROT_STABLE
  // =====
  property ACE_ERRS_ACPROT_STABLE;
    @(posedge `ACE_SVA_CLK) disable iff (PROTOCOL == `AXI4PC_AMBA_ACE_LITE)  
    !($isunknown({ACVALID,ACREADY,ACPROT})) &&
    `ACE_SVA_RSTn && ACVALID && !ACREADY
     ##1 `ACE_SVA_RSTn
      |-> $stable(ACPROT);
   endproperty
   ace_errs_acprot_stable: assert property (ACE_ERRS_ACPROT_STABLE) else 
     `ARM_AMBA4_PC_MSG_ERR(`ERRS_ACPROT_STABLE);
     
//------------------------------------------------------------------------------
// INDEX:      3) X-Propagation Rules
//------------------------------------------------------------------------------
`ifdef AXI4_XCHECK_OFF
`else  // X-Checking on by default
  // =====
  // INDEX:        - ACE_ERRS_ACVALID_X
  // =====
  property ACE_ERRS_ACVALID_X;
    @(posedge `ACE_SVA_CLK) 
        `ACE_SVA_RSTn 
        |-> ! $isunknown(ACVALID);
  endproperty
  ace_errs_acvalid_x : assert property (ACE_ERRS_ACVALID_X) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRS_ACVALID_X);

  // =====
  // INDEX:        - ACE_ERRM_ACREADY_X
  // =====
  property ACE_ERRM_ACREADY_X;
    @(posedge `ACE_SVA_CLK) 
        `ACE_SVA_RSTn 
        |-> ! $isunknown(ACREADY);
  endproperty
  ace_errm_acready_x : assert property (ACE_ERRM_ACREADY_X) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_ACREADY_X);

  // =====
  // INDEX:        - ACE_ERRS_ACADDR_X
  // =====
  property ACE_ERRS_ACADDR_X;
    @(posedge `ACE_SVA_CLK) disable iff (PROTOCOL == `AXI4PC_AMBA_ACE_LITE)  
        `ACE_SVA_RSTn && ACVALID 
        |-> ! $isunknown(ACADDR);
  endproperty
  ace_errs_acaddr_x : assert property (ACE_ERRS_ACADDR_X) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRS_ACADDR_X);

  // =====
  // INDEX:        - ACE_ERRS_ACPROT_X
  // =====
  property ACE_ERRS_ACPROT_X;
    @(posedge `ACE_SVA_CLK) disable iff (PROTOCOL == `AXI4PC_AMBA_ACE_LITE)  
        `ACE_SVA_RSTn && ACVALID 
        |-> ! $isunknown(ACPROT);
  endproperty
  ace_errs_acprot_x: assert property (ACE_ERRS_ACPROT_X) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRS_ACPROT_X);

  // =====
  // INDEX:        - ACE_ERRS_ACSNOOP_X
  // =====
  property ACE_ERRS_ACSNOOP_X;
    @(posedge `ACE_SVA_CLK) disable iff (PROTOCOL == `AXI4PC_AMBA_ACE_LITE)  
        `ACE_SVA_RSTn && ACVALID 
        |-> ! $isunknown(ACSNOOP);
  endproperty
  ace_errs_acsnoop_x: assert property (ACE_ERRS_ACSNOOP_X) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRS_ACSNOOP_X);

`endif 
//------------------------------------------------------------------------------
// INDEX:
// INDEX:   22)  ACE Rules: Snoop Response Channel (*_CR*)
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// INDEX:      1) Functional Rules
//------------------------------------------------------------------------------

  // =====
  // INDEX:        - ACE_ERRM_CR_ORDER
  // =====
  // CRVALID must not be asserted until at least the cycle after the AC handshake
//  //
  property ACE_ERRM_CR_ORDER;
    @(posedge `ACE_SVA_CLK) disable iff (PROTOCOL == `AXI4PC_AMBA_ACE_LITE)  
     `ACE_SVA_RSTn && !($isunknown({CRVALID,ACInfo_index,snoop_dataresp_cnt})) &&
          CRVALID
      |-> ACInfo_index > (snoop_dataresp_cnt + (CRVALID)) ;
  endproperty
  ace_errm_cr_order: assert property (ACE_ERRM_CR_ORDER) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_CR_ORDER);




  // =====
  // INDEX:        - ACE_ERRM_CRRESP_DIRTY
  // =====
  // When responding to a ReadOnce, ReadClean, ReadNotSharedDirty or ReadUnique with DataTransfer low, 
  // the PassDirty and IsShared bits must also be low
  // For a snoop requesting data the line cannot be kept or passed as dirty without transfering the data
  property ACE_ERRM_CRRESP_DIRTY;
    @(posedge `ACE_SVA_CLK) disable iff (PROTOCOL == `AXI4PC_AMBA_ACE_LITE)  
     `ACE_SVA_RSTn && !($isunknown({CRVALID,CRRESP})) &&
          CRVALID && CRRESP[`ACEPC_CRRESP_PASSDIRTY] 
          |-> CRRESP[`ACEPC_CRRESP_DATATRANSFER];
  endproperty
  ace_errm_crresp_dirty: assert property (ACE_ERRM_CRRESP_DIRTY) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_CRRESP_DIRTY);

  // =====
  // INDEX:        - ACE_ERRM_CRRESP_SHARED
  // =====
  // CRRESP[`ACEPC_CRRESP_ISSHARED] (IsShared) must not be asserted in response to a ReadUnique, CleanInvalid or MakeInvalid
  // A master issuing a xxxUnique transaction requires the line to be unique therefore it cannot be shared elsewhere
  property ACE_ERRM_CRRESP_SHARED;
    @(posedge `ACE_SVA_CLK) disable iff (PROTOCOL == `AXI4PC_AMBA_ACE_LITE)  
     `ACE_SVA_RSTn && !($isunknown({CRVALID,CRRESP,ACInfo[snoop_dataresp_cnt + 1]})) &&
          CRVALID && 
          (ACInfo[snoop_dataresp_cnt + 1][AC_READUNIQUE] ||
          ACInfo[snoop_dataresp_cnt + 1][AC_CLEANINVALID] ||
          ACInfo[snoop_dataresp_cnt + 1][AC_MAKEINVALID] )
          |-> !CRRESP[`ACEPC_CRRESP_ISSHARED];
  endproperty
  ace_errm_crresp_shared: assert property (ACE_ERRM_CRRESP_SHARED) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_CRRESP_SHARED);


//------------------------------------------------------------------------------
// INDEX:      2) Handshake Rules
//------------------------------------------------------------------------------

  // =====
  // INDEX:        - ACE_ERRM_CRVALID_RESET
  // =====
  // CRVALID must be de-asserted in the first cycle after reset
  property ACE_ERRM_CRVALID_RESET;
    @(posedge `ACE_SVA_CLK)
         !(`ACE_SVA_RSTn) && !($isunknown(`ACE_SVA_RSTn))
         ##1   `ACE_SVA_RSTn 
     |-> !CRVALID;
  endproperty
  ace_errm_crvalid_reset : assert property (ACE_ERRM_CRVALID_RESET) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_CRVALID_RESET);

  // =====
  // INDEX:        - ACE_ERRM_CRVALID_STABLE
  // =====
  property ACE_ERRM_CRVALID_STABLE;
    @(posedge `ACE_SVA_CLK) disable iff (PROTOCOL == `AXI4PC_AMBA_ACE_LITE)  
    !($isunknown({CRVALID,CRREADY})) &&
      `ACE_SVA_RSTn && CRVALID && !CRREADY
      ##1 `ACE_SVA_RSTn
      |-> CRVALID;
  endproperty
  ace_errm_crvalid_stable : assert property (ACE_ERRM_CRVALID_STABLE) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_CRVALID_STABLE);

  // =====
  // INDEX:        - ACE_ERRM_CRRESP_STABLE
  // =====
  property ACE_ERRM_CRRESP_STABLE;
    @(posedge `ACE_SVA_CLK) disable iff (PROTOCOL == `AXI4PC_AMBA_ACE_LITE)  
    `ACE_SVA_RSTn && !($isunknown({CRVALID,CRREADY,CRRESP})) &&
      CRVALID && !CRREADY
      ##1 `ACE_SVA_RSTn
      |-> $stable(CRRESP);
  endproperty
  ace_errm_crresp_stable: assert property (ACE_ERRM_CRRESP_STABLE) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_CRRESP_STABLE);

  // =====
  // INDEX:        - ACE_RECS_CRREADY_MAX_WAIT
  // =====
  // Note: this rule does not error if VALID goes low (breaking VALID_STABLE rule)
  property   ACE_RECS_CRREADY_MAX_WAIT;
   @(posedge `ACE_SVA_CLK) disable iff (PROTOCOL == `AXI4PC_AMBA_ACE_LITE) 
     `ACE_SVA_RSTn && !($isunknown({CRVALID,CRREADY})) &&
     RecommendOn  && // Parameter that can disable all ACE_REC*_* rules
     RecMaxWaitOn && // Parameter that can disable just ACE_REC*_MAX_WAIT rules
     ( CRVALID && !CRREADY)  // READY=1 within MAXWAITS cycles (or VALID=0)
     |-> ##[1:MAXWAITS] (!CRVALID |  CRREADY); 
  endproperty
  ace_recs_crready_max_wait: assert property (ACE_RECS_CRREADY_MAX_WAIT) else
  `ARM_AMBA4_PC_MSG_WARN(`RECS_CRREADY_MAX_WAIT);  

//------------------------------------------------------------------------------
// INDEX:      3) X-Propagation Rules
//------------------------------------------------------------------------------
`ifdef AXI4_XCHECK_OFF
`else  // X-Checking on by default

   // =====
   // INDEX:        - ACE_ERRM_CRVALID_X
   // =====
  property ACE_ERRM_CRVALID_X;
    @(posedge `ACE_SVA_CLK) 
    `ACE_SVA_RSTn
      |->  ! $isunknown(CRVALID);
  endproperty
  ace_errm_crvalid_x: assert property (ACE_ERRM_CRVALID_X) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_CRVALID_X);

  // =====
  // INDEX:        - ACE_ERRS_CRREADY_X
  // =====
  property ACE_ERRS_CRREADY_X;
    @(posedge `ACE_SVA_CLK) 
    `ACE_SVA_RSTn
     |->   ! $isunknown(CRREADY);
  endproperty
  ace_errs_crready_x: assert property (ACE_ERRS_CRREADY_X) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRS_CRREADY_X);

  // =====
  // INDEX:        - ACE_ERRM_CRRESP_X
  // =====
  property ACE_ERRM_CRRESP_X;
    @(posedge `ACE_SVA_CLK) disable iff (PROTOCOL == `AXI4PC_AMBA_ACE_LITE)  
    `ACE_SVA_RSTn && CRVALID 
    |-> ! $isunknown(CRRESP);
  endproperty
  ace_errm_crresp_x: assert property (ACE_ERRM_CRRESP_X) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_CRRESP_X);


`endif 
  //------------------------------------------------------------------------------
  // INDEX:
  // INDEX:   23)  ACE Rules: Snoop DATA Channel (*_CD*)
  //------------------------------------------------------------------------------
 
  //------------------------------------------------------------------------------
  // INDEX:      1) Functional Rules
  //------------------------------------------------------------------------------
 
  //  =====
  //  INDEX:        - ACE_ERRM_CDDATA_NUM_PROP1
  //  =====
  //  Each snoop with Data trasfer set must cause a full cache line transfer
  property ACE_ERRM_CDDATA_NUM_PROP1;
    @(posedge `ACE_SVA_CLK) disable iff (PROTOCOL == `AXI4PC_AMBA_ACE_LITE)  
      `ACE_SVA_RSTn && !($isunknown({CDLAST, CDVALID, ACData_count})) 
      && CDLAST && CDVALID
      |-> ACData_count == CACHE_LINE_AxLEN_CD ;
  endproperty
  ace_errm_cddata_num_prop1: assert property (ACE_ERRM_CDDATA_NUM_PROP1) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_CDDATA_NUM);

  //  =====
  //  INDEX:        - ACE_ERRM_CDDATA_NUM_PROP2
  //  =====
  //  Each snoop with Data trasfer set must cause a full cache line transfer
  property ACE_ERRM_CDDATA_NUM_PROP2;
    @(posedge `ACE_SVA_CLK) disable iff (PROTOCOL == `AXI4PC_AMBA_ACE_LITE)  
      `ACE_SVA_RSTn && !($isunknown({CDLAST, CDVALID, ACData_count})) 
      && CDVALID && (ACData_count == CACHE_LINE_AxLEN_CD)
      |-> CDLAST;
  endproperty
  ace_errm_cddata_num_prop2: assert property (ACE_ERRM_CDDATA_NUM_PROP2) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_CDDATA_NUM);

  // =====
  // INDEX:        - ACE_ERRM_CD_ORDER_PROP1
  // =====
  // Always allow CD when snoop_dataresp_cnt
  // otherwise there must be a slot for it
  // data slots > num outstanding data
  property ACE_ERRM_CD_ORDER_PROP1;
   @(posedge `ACE_SVA_CLK) disable iff (PROTOCOL == `AXI4PC_AMBA_ACE_LITE) 
     `ACE_SVA_RSTn && !($isunknown({CDVALID_first_pulse,AC_leading_data_resps,AC_nonDVM,AC_leading_data})) &&
      CDVALID_first_pulse  && (AC_leading_data_resps == 0) 
     |->   AC_nonDVM  > AC_leading_data;
  endproperty
  ace_errm_cd_order_prop1: assert property (ACE_ERRM_CD_ORDER_PROP1) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_CD_ORDER);

  // =====
  // INDEX:        - ACE_ERRM_CD_ORDER_PROP2
  // =====
  property ACE_ERRM_CD_ORDER_PROP2;
   @(posedge `ACE_SVA_CLK) disable iff (PROTOCOL == `AXI4PC_AMBA_ACE_LITE)  
     `ACE_SVA_RSTn && !($isunknown({CRVALID_pulse,CD_ORDER_ERROR})) &&
      CRVALID_pulse 
     |->  !CD_ORDER_ERROR ;
  endproperty
  ace_errm_cd_order_prop2: assert property (ACE_ERRM_CD_ORDER_PROP2) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_CD_ORDER);

  //=====
  // INDEX:        - ACE_ERRM_CD_ORDER_PROP3
  // =====
  property ACE_ERRM_CD_ORDER_PROP3;
   @(posedge `ACE_SVA_CLK) disable iff (PROTOCOL == `AXI4PC_AMBA_ACE_LITE)  
     `ACE_SVA_RSTn && !($isunknown({AC_leading_data,AC_nonDVM})) 
     |-> AC_nonDVM >=   AC_leading_data;
  endproperty
  ace_errm_cd_order_prop3: assert property (ACE_ERRM_CD_ORDER_PROP3) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_CD_ORDER);

  //=====
  // INDEX:        - ACE_ERRM_CD_ORDER_PROP4
  // =====
  property ACE_ERRM_CD_ORDER_PROP4;
   @(posedge `ACE_SVA_CLK) disable iff (PROTOCOL == `AXI4PC_AMBA_ACE_LITE)  
     `ACE_SVA_RSTn && !($isunknown({AC_leading_data_resps,AC_nonDVM})) 
     |-> AC_nonDVM >=  AC_leading_data_resps;
  endproperty
  ace_errm_cd_order_prop4: assert property (ACE_ERRM_CD_ORDER_PROP4) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_CD_ORDER);

  //=====
  // INDEX:        - ACE_ERRM_CD_ORDER_PROP5
  // =====
  // if the oldest data has only one preceding AC and the response is not
  // a DVM then it must pass data
  property ACE_ERRM_CD_ORDER_PROP5;
   @(posedge `ACE_SVA_CLK) disable iff (PROTOCOL == `AXI4PC_AMBA_ACE_LITE)  
     `ACE_SVA_RSTn && !($isunknown({CRVALID_pulse,ACInfo[snoop_dataresp_cnt+1],snoop_dataresp_cnt,ACData_prev_AC[snoop_dataresp_cnt+1],CRRESP})) &&
     CRVALID_pulse && !ACInfo[snoop_dataresp_cnt+1][AC_DVM] && (ACData_prev_AC[snoop_dataresp_cnt+1] == 1)
     |-> CRRESP[0];
  endproperty
  ace_errm_cd_order_prop5: assert property (ACE_ERRM_CD_ORDER_PROP5) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_CD_ORDER);

  //=====
  // INDEX:        - ACE_ERRM_CD_ORDER_PROP6
  // =====
  // if there are as many outstanding datas as there are slots, and the
  // response is not for a DVM then it must pass data
  property ACE_ERRM_CD_ORDER_PROP6;
   @(posedge `ACE_SVA_CLK) disable iff (PROTOCOL == `AXI4PC_AMBA_ACE_LITE)  
     `ACE_SVA_RSTn && !($isunknown({AC_leading_data,AC_nonDVM,CDVALID_first_pulse,CRVALID_pulse,ACInfo[snoop_dataresp_cnt+1],snoop_dataresp_cnt,CRRESP})) &&
     (AC_nonDVM == AC_leading_data + CDVALID_first_pulse) && CRVALID_pulse && !ACInfo[snoop_dataresp_cnt+1][AC_DVM]
     |-> CRRESP[0];
  endproperty
  ace_errm_cd_order_prop6: assert property (ACE_ERRM_CD_ORDER_PROP6) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_CD_ORDER);



  //------------------------------------------------------------------------------
  // INDEX:      2) Handshake Rules
  //------------------------------------------------------------------------------
 
  // =====
  // INDEX:        - ACE_ERRM_CDVALID_RESET
  // =====
  // CDVALID must be de-asserted in the first cycle after reset
  property ACE_ERRM_CDVALID_RESET;
    @(posedge `ACE_SVA_CLK) disable iff (PROTOCOL == `AXI4PC_AMBA_ACE_LITE) 
      !(`ACE_SVA_RSTn) && !($isunknown(`ACE_SVA_RSTn))
      ##1   `ACE_SVA_RSTn 
      |-> !CDVALID;
  endproperty
  ace_errm_cdvalid_reset: assert property (ACE_ERRM_CDVALID_RESET) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_CDVALID_RESET);

  // =====
  // INDEX:        - ACE_ERRM_CDVALID_STABLE
  // =====
  property ACE_ERRM_CDVALID_STABLE;
    @(posedge `ACE_SVA_CLK) disable iff (PROTOCOL == `AXI4PC_AMBA_ACE_LITE)  
    !($isunknown({CDVALID,CDREADY})) &&
      `ACE_SVA_RSTn && CDVALID && !CDREADY
       ##1   `ACE_SVA_RSTn
      |-> CDVALID;
   endproperty
   ace_errm_cdvalid_stable: assert property (ACE_ERRM_CDVALID_STABLE) else 
     `ARM_AMBA4_PC_MSG_ERR(`ERRM_CDVALID_STABLE);

  // =====
  // INDEX:        - ACE_ERRM_CDDATA_STABLE
  // =====
  property ACE_ERRM_CDDATA_STABLE;
    @(posedge `ACE_SVA_CLK) disable iff (PROTOCOL == `AXI4PC_AMBA_ACE_LITE)  
      !($isunknown({CDVALID,CDREADY,CDDATA})) &&
      `ACE_SVA_RSTn && CDVALID && !CDREADY
       ##1   `ACE_SVA_RSTn
      |-> $stable(CDDATA);
   endproperty
   ace_errm_cddata_stable: assert property (ACE_ERRM_CDDATA_STABLE) else 
     `ARM_AMBA4_PC_MSG_ERR(`ERRM_CDDATA_STABLE);
 
  // =====
  // INDEX:        - ACE_ERRM_CDLAST_STABLE
  // =====
  property ACE_ERRM_CDLAST_STABLE;
    @(posedge `ACE_SVA_CLK) disable iff (PROTOCOL == `AXI4PC_AMBA_ACE_LITE)  
      !($isunknown({CDVALID,CDREADY,CDLAST})) &&
      `ACE_SVA_RSTn && CDVALID && !CDREADY
       ##1   `ACE_SVA_RSTn
      |-> $stable(CDLAST);
   endproperty
   ace_errm_cdlast_stable: assert property (ACE_ERRM_CDLAST_STABLE) else 
     `ARM_AMBA4_PC_MSG_ERR(`ERRM_CDLAST_STABLE);
 
  // =====
  // INDEX:        - ACE_RECS_CDREADY_MAX_WAIT
  // =====
  // Note: this rule does not error if VALID goes low (breaking VALID_STABLE rule)
  property   ACE_RECS_CDREADY_MAX_WAIT;
    @(posedge `ACE_SVA_CLK) disable iff (PROTOCOL == `AXI4PC_AMBA_ACE_LITE) 
      `ACE_SVA_RSTn && !($isunknown({CDVALID,CDREADY})) &&
      RecommendOn  && // Parameter that can disable all ACE_REC*_* rules
      RecMaxWaitOn && // Parameter that can disable just ACE_REC*_MAX_WAIT rules
      ( CDVALID && !CDREADY)  // READY=1 within MAXWAITS cycles (or VALID=0)
      |-> ##[1:MAXWAITS] (!CDVALID |  CDREADY); 
  endproperty
  ace_recs_cdready_max_wait: assert property (ACE_RECS_CDREADY_MAX_WAIT) else
   `ARM_AMBA4_PC_MSG_WARN(`RECS_CDREADY_MAX_WAIT);  
 //------------------------------------------------------------------------------
// INDEX:      3) X-Propagation Rules
//------------------------------------------------------------------------------
`ifdef AXI4_XCHECK_OFF
`else  // X-Checking on by default
  // =====
  // INDEX:        - ACE_ERRM_CDVALID_X
  // =====
  property ACE_ERRM_CDVALID_X;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn
      |-> ! $isunknown(CDVALID);
    endproperty
   ace_errm_cdvalid_x: assert property (ACE_ERRM_CDVALID_X) else 
     `ARM_AMBA4_PC_MSG_ERR(`ERRM_CDVALID_X);

  // =====
  // INDEX:        - ACE_ERRS_CDREADY_X
  // =====
  property ACE_ERRS_CDREADY_X;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn
      |-> ! $isunknown(CDREADY);
  endproperty
  ace_errs_cdready_x: assert property (ACE_ERRS_CDREADY_X) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRS_CDREADY_X);

  // =====
  // INDEX:        - ACE_ERRM_CDLAST_X
  // =====
  property ACE_ERRM_CDLAST_X;
    @(posedge `ACE_SVA_CLK) disable iff (PROTOCOL == `AXI4PC_AMBA_ACE_LITE)  
      `ACE_SVA_RSTn && CDVALID 
      |-> ! $isunknown(CDLAST);
  endproperty
  ace_errm_cdlast_x: assert property (ACE_ERRM_CDLAST_X) else 
   `ARM_AMBA4_PC_MSG_ERR(`ERRM_CDLAST_X);

  // =====
  // INDEX:        - ACE_ERRM_CDDATA_X
  // =====
  property ACE_ERRM_CDDATA_X;
    @(posedge `ACE_SVA_CLK) disable iff (PROTOCOL == `AXI4PC_AMBA_ACE_LITE)  
      `ACE_SVA_RSTn && CDVALID 
      |-> ! $isunknown(CDDATA);
  endproperty
  ace_errm_cddata_x:  assert property (ACE_ERRM_CDDATA_X) else 
  `ARM_AMBA4_PC_MSG_ERR(`ERRM_CDDATA_X);

`endif 
//------------------------------------------------------------------------------
// INDEX:   24) Snoop Cam internal rules
//------------------------------------------------------------------------------   
  // =====
  // INDEX:        - ACE_AUX_MAXCBURSTS
  // =====
  property ACE_AUX_MAXCBURSTS;
    @(posedge `ACE_SVA_CLK)
      (MAXCBURSTS >= 1);
  endproperty
  ace_aux_maxcbursts: assert property (ACE_AUX_MAXCBURSTS) else
    `ARM_AMBA4_PC_MSG_ERR(`AUX_MAXCBURSTS);

  // =====
  // INDEX:        - ACE_AUX_ACCAM_OVERFLOW
  // =====
  property ACE_AUX_ACCAM_OVERFLOW;
    @(posedge `ACE_SVA_CLK) disable iff (PROTOCOL == `AXI4PC_AMBA_ACE_LITE) 
      `ACE_SVA_RSTn && !$isunknown({ACInfo_index,CD_Pop,CR_Pop,ACVALID}) &&
      ACInfo_index > (MAXCBURSTS + CD_Pop + CR_Pop) 
      |-> ~ACVALID;
  endproperty
  ace_aux_accam_overflow: assert property (ACE_AUX_ACCAM_OVERFLOW) else
    `ARM_AMBA4_PC_MSG_ERR(`AUX_ACCAM_OVERFLOW);


  // =====
  // INDEX:        - ACE_AUX_ACCAM_UNDERFLOW
  // =====
  property ACE_AUX_ACCAM_UNDERFLOW;
    @(posedge `ACE_SVA_CLK) disable iff (PROTOCOL == `AXI4PC_AMBA_ACE_LITE) 
      `ACE_SVA_RSTn && !$isunknown({ACInfo_index,CR_Pop,CD_Pop}) &&
      CR_Pop | CD_Pop
      |-> (ACInfo_index > CR_Pop + CD_Pop);
  endproperty
  ace_aux_accam_underflow: assert property (ACE_AUX_ACCAM_UNDERFLOW) else
    `ARM_AMBA4_PC_MSG_ERR(`AUX_ACCAM_UNDERFLOW);

//------------------------------------------------------------------------------
// INDEX:   25) Rack functionality
//------------------------------------------------------------------------------   

  reg        [LOG2MAXRBURSTS:0] rack_ctr; //number of transactions between RLAST and RACK
  always @(posedge `ACE_AUX_CLK or negedge `ACE_AUX_RSTn)
  begin: p_rack_ctr
    if(!`ACE_AUX_RSTn)
    begin
      rack_ctr <= '0;
    end else
    begin
      rack_ctr <= rack_ctr + (RVALID && RLAST && RREADY) - RACK;
    end
  end

  // =====
  // INDEX:        - ACE_ERRM_RACK
  // =====
  // RACK must not be asserted until the corresponding RLAST
  property ACE_ERRM_RACK;
    @(posedge `ACE_SVA_CLK) 
    `ACE_SVA_RSTn && !($isunknown({RACK,rack_ctr})) &&
      RACK 
      |-> rack_ctr > 0;
  endproperty
  ace_errm_rack : assert property(ACE_ERRM_RACK) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_RACK);

  // =====
  // INDEX:        - ACE_AUX_ARCAM_OVERFLOW
  // =====
  // There must not be more than MAXRBURST read transactions outstanding at any one time
  // Transactions are outstanding from ARVALID until RACK
  property ACE_AUX_ARCAM_OVERFLOW;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn && !$isunknown({ARIndex,ARVALID,ArPop}) 
      && (ARIndex > MAXRBURSTS + ArPop)
      |-> ~ARVALID;
  endproperty
  ace_aux_arcam_overflow : assert property(ACE_AUX_ARCAM_OVERFLOW) else 
    `ARM_AMBA4_PC_MSG_ERR(`AUX_ARCAM_OVERFLOW);
    
  // =====
  // INDEX:        - ACE_AUX_ARCAM_UNDERFLOW
  // =====
  // The read cam has underflowed
  
  property ACE_AUX_ARCAM_UNDERFLOW;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn && !($isunknown({ARIndex})) 
      |-> ARIndex > 0;
  endproperty
  ace_aux_arcam_underflow : assert property(ACE_AUX_ARCAM_UNDERFLOW) else 
    `ARM_AMBA4_PC_MSG_ERR(`AUX_ARCAM_UNDERFLOW);

  // =====
  // INDEX:        - ACE_ERRM_AR_BARRIER_CTL
  // =====
  property ACE_ERRM_AR_BARRIER_CTL;
    @(posedge `ACE_AUX_CLK) 
      `ACE_SVA_RSTn && !($isunknown({ARVALID,ARBAR,ARADDR,ARLEN,ARBURST,ARSIZE,ARSNOOP,ARCACHE,ARLOCK})) &&
      ARVALID && ARBAR[0] 
      |-> (ARADDR == {ADDR_MAX{1'b0}} &&
           ARLEN == 8'b00000000 &&
           ARBURST == `AXI4PC_ABURST_INCR &&
           ARSIZE == CACHE_LINE_AxSIZE &&
           ARSNOOP == 4'b0000 &&
           ARCACHE == 4'b0010 &&
           ARLOCK == 1'b0);
  endproperty
  ace_errm_ar_barrier_ctl : assert property (ACE_ERRM_AR_BARRIER_CTL) else
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_AR_BARRIER_CTL);

  // =====
  // INDEX:        - ACE_ERRM_AW_BARRIER_CTL
  // =====
  property ACE_ERRM_AW_BARRIER_CTL;
    @(posedge `ACE_AUX_CLK) 
      `ACE_SVA_RSTn && !($isunknown({AWVALID,AWBAR,AWADDR,AWLEN,AWBURST,AWSIZE,AWSNOOP,AWCACHE,AWLOCK})) &&
      AWVALID && AWBAR[0]
      |-> (AWADDR == {ADDR_MAX{1'b0}} &&
           AWLEN == 8'b00000000 &&
           AWBURST == `AXI4PC_ABURST_INCR &&
           AWSIZE == CACHE_LINE_AxSIZE &&
           AWSNOOP == 4'b0000 &&
           AWCACHE == 4'b0010 &&
           AWLOCK == 1'b0);
  endproperty
  ace_errm_aw_barrier_ctl : assert property (ACE_ERRM_AW_BARRIER_CTL) else
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_AW_BARRIER_CTL);

  // =====
  // INDEX:        - ACE_ERRM_R_W_BARRIER_CTL_PROP1
  // =====
  property ACE_ERRM_R_W_BARRIER_CTL_PROP1;
    @(posedge `ACE_AUX_CLK)
      !($isunknown({AWVALID,AWBAR,AWID,AWPROT,AWDOMAIN,RBARIndex,RBARInfo[1]})) &&
      (RBARIndex > WBARIndex) &&
      AWVALID && AWBAR[0] 
      |-> (RBARInfo[WBARIndex][BAR_IDHI:BAR_IDLO]  == AWID &&
        RBARInfo[WBARIndex][BAR_PROTHI:BAR_PROTLO]   == AWPROT &&
        RBARInfo[WBARIndex][BAR_DOMAIN_HI:BAR_DOMAIN_LO] == AWDOMAIN &&
        RBARInfo[WBARIndex][BAR_BAR1] == AWBAR[1]);
  endproperty
  ace_errm_r_w_barrier_ctl_prop1 : assert property (ACE_ERRM_R_W_BARRIER_CTL_PROP1) else
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_R_W_BARRIER_CTL);

  // =====
  // INDEX:        - ACE_ERRM_R_W_BARRIER_CTL_PROP2
  // =====
  property ACE_ERRM_R_W_BARRIER_CTL_PROP2;
    @(posedge `ACE_AUX_CLK)
      !($isunknown({ARVALID,ARBAR,ARID,ARPROT,ARDOMAIN,WBARIndex,WBARInfo[1]})) &&
      (WBARIndex > RBARIndex) &&
      ARVALID && ARBAR[0] 
      |-> (WBARInfo[RBARIndex][BAR_IDHI:BAR_IDLO]  == ARID &&
        WBARInfo[RBARIndex][BAR_PROTHI:BAR_PROTLO]   == ARPROT &&
        WBARInfo[RBARIndex][BAR_DOMAIN_HI:BAR_DOMAIN_LO] == ARDOMAIN &&
        WBARInfo[RBARIndex][BAR_BAR1] == ARBAR[1]);
  endproperty
  ace_errm_r_w_barrier_ctl_prop2 : assert property (ACE_ERRM_R_W_BARRIER_CTL_PROP2) else
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_R_W_BARRIER_CTL);

  // =====
  // INDEX:        - ACE_ERRM_R_W_BARRIER_CTL_PROP3
  // =====
  property ACE_ERRM_R_W_BARRIER_CTL_PROP3;
    @(posedge `ACE_AUX_CLK)
      !($isunknown({ARVALID,ARBAR,ARID,ARPROT,ARDOMAIN,WBARIndex,WBARInfo[1]})) &&
      (WBARIndex == RBARIndex) &&
      ARVALID && ARBAR[0] &&  AWVALID && AWBAR[0]
      |-> (AWID  == ARID &&
        AWPROT   == ARPROT &&
        AWDOMAIN == ARDOMAIN &&
        AWBAR[1] == ARBAR[1]);
  endproperty
  ace_errm_r_w_barrier_ctl_prop3 : assert property (ACE_ERRM_R_W_BARRIER_CTL_PROP3) else
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_R_W_BARRIER_CTL);

  // =====
  // INDEX:        - ACE_ERRM_BARRIER_R_NUM
  // =====
  property ACE_ERRM_R_BARRIER_NUM;
    @(posedge `ACE_AUX_CLK) 
      !($isunknown({RBARPush,RBARIndex,BAR_pops_num})) &&
      ARVALID && ARBAR[0] 
      |-> (RBARIndex <= MAX_BARRIERS +  BAR_pops_num );
  endproperty
  ace_errm_r_barrier_num : assert property (ACE_ERRM_R_BARRIER_NUM) else
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_R_BARRIER_NUM);

  // =====
  // INDEX:        - ACE_ERRM_BARRIER_W_NUM
  // =====
  property ACE_ERRM_W_BARRIER_NUM;
    @(posedge `ACE_AUX_CLK) 
      !($isunknown({WBARPush,WBARIndex})) &&
      AWVALID && AWBAR[0] 
      |-> (WBARIndex <= (MAX_BARRIERS + BAR_pops_num) );
  endproperty
  ace_errm_w_barrier_num : assert property (ACE_ERRM_W_BARRIER_NUM) else
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_W_BARRIER_NUM);

  // =====
  // INDEX:        - ACE_ERRM_AR_BARRIER_ID
  // =====
  //check that if we have a new read barrier there is not a non barrier
  //transaction outstanding with the same ID
  property ACE_ERRM_AR_BARRIER_ID;
    @(posedge `ACE_AUX_CLK) 
      !($isunknown({ARVALID,ARBAR,ARIDisNORMAL,ARIDisDVM})) &&
      ARVALID && ARBAR[0] 
      |-> (!ARIDisNORMAL && !ARIDisDVM);
  endproperty
  ace_errm_ar_barrier_id : assert property (ACE_ERRM_AR_BARRIER_ID) else
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_AR_BARRIER_ID);
 
  // =====
  // INDEX:        - ACE_ERRM_AW_BARRIER_ID
  // =====
  //check that if we have a new write barrier there is not a non barrier
  //transaction outstanding with the same ID
  property ACE_ERRM_AW_BARRIER_ID;
    @(posedge `ACE_AUX_CLK) 
      !($isunknown({AWVALID,AWBAR,AWIDisNORMAL,AWIDisDVM})) &&
      AWVALID && AWBAR[0] 
      |-> (!AWIDisNORMAL && !AWIDisDVM);
  endproperty
  ace_errm_aw_barrier_id : assert property (ACE_ERRM_AW_BARRIER_ID) else
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_AW_BARRIER_ID);
 
  // =====
  // INDEX:        - ACE_ERRM_AR_NORMAL_ID
  // =====
  //check that if we have a new read non barrier there is not a barrier or
  //DVM transaction outstanding with the same ID
  property ACE_ERRM_AR_NORMAL_ID;
    @(posedge `ACE_AUX_CLK) 
      !($isunknown({ARVALID,ARBAR,ARIDisBAR,ARIDisDVM,ARSNOOP})) &&
      ARVALID && !ARBAR[0] && ~&ARSNOOP[3:1] 
      |-> (!ARIDisBAR && !ARIDisDVM);
  endproperty
  ace_errm_ar_normal_id : assert property (ACE_ERRM_AR_NORMAL_ID) else
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_AR_NORMAL_ID);
 
  // =====
  // INDEX:        - ACE_ERRM_AW_NORMAL_ID
  // =====
  //check that if we have a new write non barrier there is not a barrier or
  //DVM transaction outstanding with the same ID
  property ACE_ERRM_AW_NORMAL_ID;
    @(posedge `ACE_AUX_CLK) 
      !($isunknown({AWVALID,AWBAR,AWIDisBAR})) &&
      AWVALID && !AWBAR[0] 
      |-> (!AWIDisBAR);
  endproperty
  ace_errm_aw_normal_id : assert property (ACE_ERRM_AW_NORMAL_ID) else
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_AW_NORMAL_ID);
  
    
//------------------------------------------------------------------------------
// INDEX:   26) Wack functionality
//------------------------------------------------------------------------------

  reg        [LOG2MAXWBURSTS:0] wack_ctr;
  always @(posedge `ACE_AUX_CLK or negedge `ACE_AUX_RSTn)
  begin: p_wack_ctr
    if(!`ACE_AUX_RSTn)
    begin
      wack_ctr <= '0;
    end else
    begin
      wack_ctr <= wack_ctr + (BVALID && BREADY) - WACK;
    end
  end

  // =====
  // INDEX:        - ACE_ERRM_WACK
  // =====/
  // WACK must not be asserted until after the corresponding B handshake 
  property ACE_ERRM_WACK;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn && !($isunknown({WACK,wack_ctr})) &&
      WACK 
      |-> wack_ctr > 0;
  endproperty 
  ace_errm_wack : assert property(ACE_ERRM_WACK) else 
    `ARM_AMBA4_PC_MSG_ERR(`ERRM_WACK);

    
  //====
  // INDEX:        - ACE_AUX_AWCAM_OVERFLOW_PROP1
  // =====
  // must not have AWVALID for a transfer if it will overflow the cam
  // Transactions are outstanding from AWVALID until WACK
  
  property ACE_AUX_AWCAM_OVERFLOW_PROP1;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn && !($isunknown({AWVALID,LWData_v_first,AWIndex,AWSNOOP,AWIndex})) 
                    && (AWIndex > (MAXWBURSTS + AwPop - LWData_v_first) ) && ((AWSNOOP == `ACEPC_AWSNOOP_WRITEEVICT) || AWBAR[0])
      |-> ~AWVALID;
  endproperty
  ace_aux_awcam_overflow_prop1 : assert property(ACE_AUX_AWCAM_OVERFLOW_PROP1) else 
    `ARM_AMBA4_PC_MSG_ERR(`AUX_AWCAM_OVERFLOW);
    
  // =====
  // INDEX:        - ACE_AUX_AWCAM_OVERFLOW_PROP2
  // =====
  // There must not be more than MAXWBURST write transactions outstanding at any one time
  // Transactions are outstanding from AWVALID until WACK
  
  property ACE_AUX_AWCAM_OVERFLOW_PROP2;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn && !($isunknown({WVALID,AwPush_dataless_valid,AwPop,WIDMatch})) 
                    && WIDMatch > (MAXWBURSTS + AwPop  - AwPush_dataless_valid)
      |-> ~WVALID;
  endproperty
  ace_aux_awcam_overflow_prop2 : assert property(ACE_AUX_AWCAM_OVERFLOW_PROP2) else 
    `ARM_AMBA4_PC_MSG_ERR(`AUX_AWCAM_OVERFLOW);
    
  //====
  // INDEX:        - ACE_AUX_AWCAM_OVERFLOW_PROP3
  // =====
  // must not have AWVALID for a transfer if it will overflow the cam
  // Transactions are outstanding from AWVALID until WACK
  
  property ACE_AUX_AWCAM_OVERFLOW_PROP3;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn && !($isunknown({AWVALID,AwPop,AWIDMatch_data,AWSNOOP})) 
                    && (AWIDMatch_data > (MAXWBURSTS + AwPop) ) && !((AWSNOOP == `ACEPC_AWSNOOP_WRITEEVICT) || AWBAR[0])
      |-> ~AWVALID;
  endproperty
  ace_aux_awcam_overflow_prop3 : assert property(ACE_AUX_AWCAM_OVERFLOW_PROP3) else 
    `ARM_AMBA4_PC_MSG_ERR(`AUX_AWCAM_OVERFLOW);
    
    
  // =====
  // INDEX:        - ACE_AUX_AWCAM_UNDERFLOW
  // =====
  // The write cam has underflowed
  property ACE_AUX_AWCAM_UNDERFLOW;
    @(posedge `ACE_SVA_CLK) 
      `ACE_SVA_RSTn && !($isunknown({AWIndex})) 
      |-> AWIndex > 0;
  endproperty
  ace_aux_awcam_underflow : assert property(ACE_AUX_AWCAM_UNDERFLOW) else 
    `ARM_AMBA4_PC_MSG_ERR(`AUX_AWCAM_UNDERFLOW);
    
//------------------------------------------------------------------------------
// INDEX:   27) EOS checks
//------------------------------------------------------------------------------
final
begin
  `ifndef ACEPC_EOS_OFF
  $display ("Executing ACE End Of Simulation checks");
  // =====
  // INDEX:        - ACE_ERRM_R_W_BARRIER_EOS 
  // =====
  //property ACE_ERRM_R_W_BARRIER_EOS;
  if (!($isunknown({RBARIndex,WBARIndex})))
  ace_errm_r_w_barrier_eos:
    assert ((RBARIndex == 1 ) && (WBARIndex == 1 )) else 
      `ARM_AMBA4_PC_MSG_ERR(`ERRM_R_W_BARRIER_EOS);

  // =====
  // INDEX:        - ACE_ERRM_RACK_EOS 
  // =====
  //property ACE_ERRM_RACK_EOS;
  if (!($isunknown(rack_ctr)))
  ace_errm_rack_eos:
    assert (rack_ctr == 0) else 
      `ARM_AMBA4_PC_MSG_ERR(`ERRM_RACK_EOS);

  // =====
  // INDEX:        - ACE_ERRM_WACK_EOS 
  // =====
  //property ACE_ERRM_WACK_EOS;
  if (!($isunknown(wack_ctr)))
  ace_errm_wack_eos:
    assert (wack_ctr == 0) else 
      `ARM_AMBA4_PC_MSG_ERR(`ERRM_WACK_EOS);

  //
  // =====
  // INDEX:        - ACE_ERRM_AC_EOS 
  // =====
  //property ACE_ERRM_AC_EOS;
  if (!($isunknown({ACInfo_index,ACData_prev_AC_index})))
  ace_errm_ac_eos:
    assert ((ACInfo_index == 1) && (ACData_prev_AC_index == 1)  ) else 
      `ARM_AMBA4_PC_MSG_ERR(`ERRM_AC_EOS);

  // =====
  // INDEX:        - ACE_ERR_W_EOS
  // =====
  //property ACE_ERR_W_EOS;
  if (!($isunknown(AWIndex)))
  ace_err_w_eos: 
  assert (AWIndex == 1) else
   `ARM_AMBA4_PC_MSG_ERR(`ERR_W_EOS);
  `endif
end

  //------------------------------------------------------------------------------
  // INDEX:   28) Cache Line size Checks
  //------------------------------------------------------------------------------
  // =====
  // INDEX:        - ACE_AUX_CD_DATA_WIDTH
  // =====
  property ACE_AUX_CD_DATA_WIDTH;
    @(posedge `ACE_SVA_CLK)
      (CD_DATA_WIDTH ==   32 ||
       CD_DATA_WIDTH ==   64 ||
       CD_DATA_WIDTH ==  128 ||
       CD_DATA_WIDTH ==  256 ||
       CD_DATA_WIDTH ==  512 ||
       CD_DATA_WIDTH == 1024);
  endproperty
  ace_aux_cd_data_width: assert property (ACE_AUX_CD_DATA_WIDTH) else
   `ARM_AMBA4_PC_MSG_ERR(`AUX_CD_DATA_WIDTH);

  // =====
  // INDEX:        - ACE_AUX_CACHE_LINE_SIZE
  // =====
  property ACE_AUX_CACHE_LINE_SIZE; 
    @(posedge `ACE_SVA_CLK)
      ( CACHE_LINE_SIZE_BYTES ==   16 || 
       CACHE_LINE_SIZE_BYTES ==   32 ||
       CACHE_LINE_SIZE_BYTES ==   64 ||
       CACHE_LINE_SIZE_BYTES ==  128 ||
       CACHE_LINE_SIZE_BYTES ==  256 ||
       CACHE_LINE_SIZE_BYTES ==  512 ||
       CACHE_LINE_SIZE_BYTES == 1024 ||
       CACHE_LINE_SIZE_BYTES == 2048);
  endproperty
  ace_aux_cache_line_size: assert property (ACE_AUX_CACHE_LINE_SIZE) else
    `ARM_AMBA4_PC_MSG_ERR(`AUX_CACHE_LINE_SIZE);
 
  // =====
  // INDEX:        - ACE_AUX_CACHE_DATA_WIDTH32
  // =====
  property ACE_AUX_CACHE_DATA_WIDTH32; 
    @(posedge `ACE_SVA_CLK)
      (DATA_WIDTH ==  32) || (CD_DATA_WIDTH ==  32) 
      |-> (CACHE_LINE_SIZE_BYTES >= 16) && (CACHE_LINE_SIZE_BYTES <= 64);
  endproperty
  ace_aux_cache_data_width32: assert property (ACE_AUX_CACHE_DATA_WIDTH32) else
    `ARM_AMBA4_PC_MSG_ERR(`AUX_CACHE_DATA_WIDTH32);
 
  // =====
  // INDEX:        - ACE_AUX_CACHE_DATA_WIDTH64
  // =====
  property ACE_AUX_CACHE_DATA_WIDTH64; 
    @(posedge `ACE_SVA_CLK)
      (DATA_WIDTH ==  64) || (CD_DATA_WIDTH ==  64) 
      |-> (CACHE_LINE_SIZE_BYTES >= 16) && (CACHE_LINE_SIZE_BYTES <= 128);
  endproperty
  ace_aux_cache_data_width64: assert property (ACE_AUX_CACHE_DATA_WIDTH64) else
    `ARM_AMBA4_PC_MSG_ERR(`AUX_CACHE_DATA_WIDTH64);
 
  // =====
  // INDEX:        - ACE_AUX_CACHE_DATA_WIDTH128;
  // =====
  property ACE_AUX_CACHE_DATA_WIDTH128; 
    @(posedge `ACE_SVA_CLK)
      (DATA_WIDTH ==  128) || (CD_DATA_WIDTH ==  128) 
      |-> (CACHE_LINE_SIZE_BYTES >= 16) && (CACHE_LINE_SIZE_BYTES <= 256);
  endproperty
  ace_aux_cache_data_width128: assert property (ACE_AUX_CACHE_DATA_WIDTH128) else
    `ARM_AMBA4_PC_MSG_ERR(`AUX_CACHE_DATA_WIDTH128);
 
  // =====
  // INDEX:        - ACE_AUX_CACHE_DATA_WIDTH256;
  // =====
  property ACE_AUX_CACHE_DATA_WIDTH256; 
    @(posedge `ACE_SVA_CLK)
      (DATA_WIDTH ==  256) || (CD_DATA_WIDTH ==  256) 
      |-> (CACHE_LINE_SIZE_BYTES >= 32) && (CACHE_LINE_SIZE_BYTES <= 512);
  endproperty
  ace_aux_cache_data_width256: assert property (ACE_AUX_CACHE_DATA_WIDTH256) else
    `ARM_AMBA4_PC_MSG_ERR(`AUX_CACHE_DATA_WIDTH256);
 
  // =====
  // INDEX:        - ACE_AUX_CACHE_DATA_WIDTH512;
  // =====
  property ACE_AUX_CACHE_DATA_WIDTH512; 
    @(posedge `ACE_SVA_CLK)
      (DATA_WIDTH ==  512) || (CD_DATA_WIDTH ==  512) 
      |-> (CACHE_LINE_SIZE_BYTES >= 64) && (CACHE_LINE_SIZE_BYTES <= 1024);
  endproperty
  ace_aux_cache_data_width512: assert property (ACE_AUX_CACHE_DATA_WIDTH512) else
    `ARM_AMBA4_PC_MSG_ERR(`AUX_CACHE_DATA_WIDTH512);
 
  // =====
  // INDEX:        - ACE_AUX_CACHE_DATA_WIDTH1024;
  // =====
  property ACE_AUX_CACHE_DATA_WIDTH1024; 
    @(posedge `ACE_SVA_CLK)
      (DATA_WIDTH ==  1024) || (CD_DATA_WIDTH ==  1024) 
      |-> (CACHE_LINE_SIZE_BYTES >= 128) && (CACHE_LINE_SIZE_BYTES <= 2048);
  endproperty
  ace_aux_cache_data_width1024: assert property (ACE_AUX_CACHE_DATA_WIDTH1024) else
    `ARM_AMBA4_PC_MSG_ERR(`AUX_CACHE_DATA_WIDTH1024);

//------------------------------------------------------------------------------
// INDEX:   29) Instantiate the Axi4PC to check AXI4 channel rules
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// INDEX:       - Assignments to the Axi4PC
//------------------------------------------------------------------------------
  assign  AWVALID_Axi4PC = AWVALID && ~AWBAR[0] && (AWSNOOP != `ACEPC_AWSNOOP_WRITEEVICT);
  assign  ARLEN_Axi4PC  = ARVALID && ARSNOOP[3] ?  8'b00000000 : ARLEN ;
  assign  BVALID_Axi4PC = (BIDMatch == 0) ? 1'b0 : (!B_BAR_RESP && !B_EVICT_RESP && BVALID) ;
  assign  ARLOCK_Axi4PC = ARLOCK && ~^ARDOMAIN;
  assign  RRESP_Axi4PC  = ARInfo[RIDMatch][AR_LOCK] && ARInfo[RIDMatch][AR_SHAREABLE] && 
                          (RRESP[1:0] == `ACEPC_RRESP_EXOKAY) ?
                          `ACEPC_RRESP_OKAY : RRESP[1:0];
  assign  RDATA_Axi4PC  = (RVALID && (ARInfo[RIDMatch][AR_BARRIER] || 
                                      ARInfo[RIDMatch][AR_DVM]     ||
                (ARInfo[RIDMatch][ARSNOOP_HI:ARSNOOP_LO] == `ACEPC_ARSNOOP_CLEANSHARED ) ||
                (ARInfo[RIDMatch][ARSNOOP_HI:ARSNOOP_LO] == `ACEPC_ARSNOOP_CLEANINVALID) ||
                (ARInfo[RIDMatch][ARSNOOP_HI:ARSNOOP_LO] == `ACEPC_ARSNOOP_CLEANUNIQUE ) ||
                (ARInfo[RIDMatch][ARSNOOP_HI:ARSNOOP_LO] == `ACEPC_ARSNOOP_MAKEUNIQUE  ) ||
                (ARInfo[RIDMatch][ARSNOOP_HI:ARSNOOP_LO] == `ACEPC_ARSNOOP_MAKEINVALID ))) ?
                '0 : RDATA;


  Axi4PC_ace #(
   .DATA_WIDTH   (DATA_WIDTH),
   .ADDR_WIDTH   (ADDR_WIDTH),
   .RID_WIDTH    (RID_WIDTH),
   .WID_WIDTH    (WID_WIDTH),
   .AWUSER_WIDTH (AWUSER_WIDTH),
   .WUSER_WIDTH  (WUSER_WIDTH),
   .BUSER_WIDTH  (BUSER_WIDTH),
   .ARUSER_WIDTH (ARUSER_WIDTH),
   .RUSER_WIDTH  (RUSER_WIDTH),
   .EXMON_WIDTH  (EXMON_WIDTH),
   .MAXRBURSTS   (MAXRBURSTS),
   .MAXWBURSTS   (MAXWBURSTS),
   .MAXWAITS     (MAXWAITS),
   .PROTOCOL     (PROTOCOL),
   .RecommendOn  (RecommendOn),
   .RecMaxWaitOn (RecMaxWaitOn)
  )
  u_axi4_pc
  (
    .ACLK        (ACLK),
    .ARESETn     (ARESETn),
    .AWID        (AWID),
    .AWADDR      (AWADDR),
    .AWLEN       (AWLEN),
    .AWSIZE      (AWSIZE),
    .AWBURST     (AWBURST),
    .AWLOCK      (AWLOCK),
    .AWCACHE     (AWCACHE),
    .AWPROT      (AWPROT),
    .AWQOS       (AWQOS),
    .AWREGION    (AWREGION),
    .AWUSER      (AWUSER),
    .AWVALID     (AWVALID_Axi4PC ),
    .AWREADY     (AWREADY),
    .WDATA       (WDATA),
    .WSTRB       (WSTRB),
    .WLAST       (WLAST),
    .WUSER       (WUSER),
    .WVALID      (WVALID),
    .WREADY      (WREADY),
    .BID         (BID),
    .BRESP       (BRESP),
    .BUSER       (BUSER),
    .BVALID      (BVALID_Axi4PC ),
    .BREADY      (BREADY),
    .ARID        (ARID),
    .ARADDR      (ARADDR),
    .ARLEN       (ARLEN_Axi4PC),
    .ARSIZE      (ARSIZE),
    .ARBURST     (ARBURST),
    .ARLOCK      (ARLOCK_Axi4PC),
    .ARCACHE     (ARCACHE),
    .ARPROT      (ARPROT),
    .ARQOS       (ARQOS),
    .ARREGION    (ARREGION),
    .ARUSER      (ARUSER),
    .ARVALID     (ARVALID),
    .ARREADY     (ARREADY),
    .RID         (RID),
    .RDATA       (RDATA_Axi4PC),
    .RRESP       (RRESP_Axi4PC),
    .RLAST       (RLAST),
    .RUSER       (RUSER),
    .RVALID      (RVALID),
    .RREADY      (RREADY),
    .CSYSREQ     (CSYSREQ),
    .CSYSACK     (CSYSACK),
    .CACTIVE     (CACTIVE)


   );




//------------------------------------------------------------------------------
// INDEX:   30) Clear Verilog Defines
//------------------------------------------------------------------------------
// Error and Warning Messages
  `undef ARM_AMBA4_PC_MSG_ERR
  `undef ARM_AMBA4_PC_MSG_WARN

  // Clock and Reset
  `undef ACE_AUX_CLK
  `undef ACE_AUX_RSTn
  `undef ACE_SVA_CLK
  `undef ACE_SVA_RSTn

//------------------------------------------------------------------------------
// INDEX:   31) End of module
//------------------------------------------------------------------------------

endmodule // AcePC
`include "AcePC_message_undefs.v"
`include "Axi4PC_ace_undefs.v"
`include "Axi4PC_ace_message_undefs.v"
`include "AcePC_undefs.v"

//------------------------------------------------------------------------------
// INDEX:
// INDEX: End of File
//------------------------------------------------------------------------------
`endif
`endif
