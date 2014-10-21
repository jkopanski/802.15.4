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
//  File Revision       : 114591
//
//  Date                :  2011-07-06 12:02:01 +0100 (Wed, 06 Jul 2011)
//
//  Release Information : BP065-BU-01000-r0p1-00rel0

//
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Abstract : Top level AceLite Protocol Checker
//------------------------------------------------------------------------------
//
// Overview
// --------
//
// This is the top level AceLite Protocol checker block. It comprises a wrapper  
// around the AcePC and instantion the simple checks on AxSnoop
//
//------------------------------------------------------------------------------

//----------------------------------------------------------------------------
// CONTENTS
// ========
// 100.  Module: AceLitePC
// 177.    1) Parameters
// 180.         - Configurable (user can set)
// 234.         - Calculated (user should not override)
// 254.    2) Inputs (no outputs)
// 257.         - Global Signals
// 262.         - Write Address Channel
// 282.         - Write Data Channel
// 292.         - Write Response Channel
// 302.         - Read Address Channel
// 322.         - Read Data Channel
// 332.         - Low Power Interface
// 342.    4) Verilog Defines
// 345.         - Clock and Reset
// 379.    5) Initialize simulation
// 384.         - Format for time reporting
// 390.         - Indicate version of AceLitePC
// 397.    5) Artificially generate the RACK and WACK
// 412.    6) AceLite rule set
// 415.         - ACELITE_ERRM_AWSNOOP
// 430.         - ACELITE_ERRM_ARSNOOP
// 446.         - ACELITE_AUX_MAX_BARRIERS 
// 456.    7) Instantiate the AcePC to check all Ace rules
// 576.    8) Clear Verilog Defines
// 589.    9) End of module
// 598. 
// 599.  End of File
//----------------------------------------------------------------------------

`ifndef ACELITEPC_OFF


`ifndef ACEPC
  `include "AcePC.sv"
`endif

`ifndef ACEPC_TYPES
  `include "AcePC_defs.v"
`endif

`ifndef ACEPC_MESSAGES
  `include "AcePC_message_defs.v"
`endif



//------------------------------------------------------------------------------
// ACE Standard Defines
//------------------------------------------------------------------------------

`ifndef ARM_AMBA4_PC_MSG_ERR
  `define ARM_AMBA4_PC_MSG_ERR $error
`endif

`ifndef ARM_AMBA4_PC_MSG_WARN
  `define ARM_AMBA4_PC_MSG_WARN $warning
`endif

//------------------------------------------------------------------------------
// INDEX: Module: AceLitePC
//------------------------------------------------------------------------------
`ifndef ACELITEPC
  `define ACELITEPC
module AceLitePC
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

  // Low Power Interface
  CACTIVE,
  CSYSREQ,
  CSYSACK //,
   );
  
//------------------------------------------------------------------------------
// INDEX:   1) Parameters
//------------------------------------------------------------------------------
 
  // INDEX:        - Configurable (user can set)
  // =====
  // Parameters below can be set by the user.
  
  
  parameter ADDR_WIDTH = 64;
 
  // Set DATA_WIDTH to the data-bus width required
  parameter DATA_WIDTH = 64;         // data bus width, default = 64-bit

  // Select the number of channel ID bits required for read channel
  parameter RID_WIDTH = 4;          // (AR|R)ID width
 
  // Select the number of channel ID bits required for write channel
  parameter WID_WIDTH = 4;          // (AW|W|B)ID width 

  // Size of CAMs for storing outstanding reads, this should match or
  // exceed the number of reads into the slave interface
  parameter MAXRBURSTS = 16;

  // Size of CAMs for storing outstanding reads, this should match or
  // exceed the number of reads into the slave interface
  parameter MAXWBURSTS = 16;

  // Select the size of the USER buses, default = 32-bit
  parameter AWUSER_WIDTH = 32; // width of the user AW sideband field
  parameter WUSER_WIDTH  = 32; // width of the user W  sideband field
  parameter BUSER_WIDTH  = 32; // width of the user B  sideband field
  parameter ARUSER_WIDTH = 32; // width of the user AR sideband field
  parameter RUSER_WIDTH  = 32; // width of the user R  sideband field

  // Set the protocol - used to disable some AXI4 checks for ACE
  parameter PROTOCOL = `AXI4PC_AMBA_ACE_LITE;


  // Maximum number of cycles between VALID -> READY high before a warning is
  // generated
  parameter MAXWAITS = 16;

  // Recommended Rules Enable
  // enable/disable reporting of all  REC*_* rules
  parameter RecommendOn   = 1'b1;   
  // enable/disable reporting of just REC*_MAX_WAIT rules
  parameter RecMaxWaitOn  = 1'b1;   

  // set the cache line size in beats
  parameter CACHE_LINE_SIZE_BYTES = 64;        

  // Set EXMON_WIDTH to the exclusive access monitor width required
  parameter EXMON_WIDTH = 4;        // exclusive access width, default = 4-bit

  //set the maximum number of barrier pairs
  parameter MAX_BARRIERS = 256;

  // INDEX:        - Calculated (user should not override)
  // =====
  // Do not override the following parameters: they must be calculated exactly
  // as shown below
  localparam ADDR_MAX    = ADDR_WIDTH-1; // ADDR max index
  localparam DATA_MAX    = DATA_WIDTH-1; // data max index
  localparam STRB_WIDTH  = DATA_WIDTH/8; // WSTRB width
  localparam STRB_MAX    = STRB_WIDTH-1; // WSTRB max index
  localparam STRB_1      = {{STRB_MAX{1'b0}}, 1'b1};  // value 1 in strobe width
  localparam ID_MAX_R     = RID_WIDTH? RID_WIDTH-1:0;    // ID max index
  localparam ID_MAX_W     = WID_WIDTH? WID_WIDTH-1:0;    // ID max index


  localparam AWUSER_MAX = AWUSER_WIDTH ? AWUSER_WIDTH-1:0; // AWUSER max index
  localparam WUSER_MAX  = WUSER_WIDTH ? WUSER_WIDTH-1:0;   // WUSER  max index
  localparam BUSER_MAX  = BUSER_WIDTH ? BUSER_WIDTH-1:0;   // BUSER  max index
  localparam ARUSER_MAX = ARUSER_WIDTH ? ARUSER_WIDTH-1:0; // ARUSER max index
  localparam RUSER_MAX  = RUSER_WIDTH ? RUSER_WIDTH-1:0;   // RUSER  max index

//------------------------------------------------------------------------------
// INDEX:   2) Inputs (no outputs)
//------------------------------------------------------------------------------
   
  // INDEX:        - Global Signals
  // =====
  input wire                ACLK;        // AXI Clock
  input wire                ARESETn;     // AXI Reset

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


  // INDEX:        - Write Data Channel
  // =====
  input wire   [DATA_MAX:0] WDATA;
  input wire   [STRB_MAX:0] WSTRB;
  input wire  [WUSER_MAX:0] WUSER;
  input wire                WLAST;
  input wire                WVALID;
  input wire                WREADY;


  // INDEX:        - Write Response Channel
  // =====
  input wire     [ID_MAX_W:0] BID;
  input wire          [1:0] BRESP;
  input wire  [BUSER_MAX:0] BUSER;
  input wire                BVALID;
  input wire                BREADY;
  


  // INDEX:        - Read Address Channel
  // =====
  input wire    [ID_MAX_R:0] ARID;
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


  // INDEX:        - Read Data Channel
  // =====
  input wire    [ID_MAX_R:0] RID;
  input wire                RLAST;
  input wire   [DATA_MAX:0] RDATA;
  input wire          [1:0] RRESP;
  input wire  [RUSER_MAX:0] RUSER;
  input wire                RVALID;
  input wire                RREADY;
  
  // INDEX:        - Low Power Interface
  // =====
  input wire                CACTIVE;
  input wire                CSYSREQ;
  input wire                CSYSACK;

  reg                  RACK_AcePC;
  reg                  WACK_AcePC;
  
//------------------------------------------------------------------------------
// INDEX:   4) Verilog Defines
//------------------------------------------------------------------------------

  // INDEX:        - Clock and Reset
  // =====
  // Can be overridden by user for a clock enable.
  //
  // Can also be used to clock SVA on negedge (to avoid race hazards with
  // auxiliary logic) by compiling with the override:
  //
  //   +define+ACE_SVA_CLK=~ACLK
  // 
  // SVA: Assertions
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


       // INDEX:        - Indicate version of AceLitePC
       // =====
       $display("ACELITEPC_INFO: Running AceLitePC version BP065-BU-01000-r0p1-00rel0 (SVA implementation)");

    end
 
//------------------------------------------------------------------------------
// INDEX:   5) Artificially generate the RACK and WACK
//------------------------------------------------------------------------------
always @(posedge `ACE_AUX_CLK)
begin
  if (RLAST && RVALID && RREADY)
    RACK_AcePC <= 1'b1;
  else
    RACK_AcePC <= 1'b0;
  if (BVALID && BREADY)
    WACK_AcePC <= 1'b1;
  else
    WACK_AcePC <= 1'b0;

end
//------------------------------------------------------------------------------
// INDEX:   6) AceLite rule set
//------------------------------------------------------------------------------
  // =====
  // INDEX:        - ACELITE_ERRM_AWSNOOP
  // =====
  // AWSNOOP value must be legal
  property ACELITE_ERRM_AWSNOOP;
    @(posedge `ACE_SVA_CLK) 
    `ACE_SVA_RSTn && !($isunknown({AWVALID,AWSNOOP})) &&
      AWVALID
      |-> (AWSNOOP == `ACEPC_AWSNOOP_WRITEUNIQUE) || 
        (AWSNOOP == `ACEPC_AWSNOOP_WRITELINEUNIQUE);
  endproperty
   acelite_errm_awsnoop: assert property(ACELITE_ERRM_AWSNOOP) else 
     `ARM_AMBA4_PC_MSG_ERR(`ERRM_AWSNOOP_LITE);


  // =====
  // INDEX:        - ACELITE_ERRM_ARSNOOP
  // =====
  // ARSNOOP value must be legal
  property ACELITE_ERRM_ARSNOOP;
    @(posedge `ACE_SVA_CLK) 
    `ACE_SVA_RSTn && !($isunknown({ARVALID,ARSNOOP})) &&
      ARVALID
      |-> (ARSNOOP == `ACEPC_ARSNOOP_READONCE) || 
        (ARSNOOP == `ACEPC_ARSNOOP_CLEANSHARED) || 
        (ARSNOOP == `ACEPC_ARSNOOP_CLEANINVALID) || 
        (ARSNOOP == `ACEPC_ARSNOOP_MAKEINVALID); 
  endproperty
   acelite_errm_arsnoop: assert property(ACELITE_ERRM_ARSNOOP) else 
     `ARM_AMBA4_PC_MSG_ERR(`ERRM_ARSNOOP_LITE);

  // =====
  // INDEX:        - ACELITE_AUX_MAX_BARRIERS 
  // =====
  property ACELITE_AUX_MAX_BARRIERS;
    @(posedge `ACE_SVA_CLK)
      (MAX_BARRIERS >= 1);
  endproperty
  acelite_aux_max_barriers: assert property (ACELITE_AUX_MAX_BARRIERS) else
    `ARM_AMBA4_PC_MSG_ERR(`AUX_MAX_BARRIERS_LITE);

//------------------------------------------------------------------------------
// INDEX:   7) Instantiate the AcePC to check all Ace rules
//------------------------------------------------------------------------------

  AcePC #(
   .DATA_WIDTH   (DATA_WIDTH),
   .ADDR_WIDTH   (ADDR_WIDTH),
   .RID_WIDTH   (RID_WIDTH),
   .WID_WIDTH   (WID_WIDTH),
   .AWUSER_WIDTH (AWUSER_WIDTH),
   .WUSER_WIDTH  (WUSER_WIDTH),
   .BUSER_WIDTH  (BUSER_WIDTH),
   .ARUSER_WIDTH (ARUSER_WIDTH),
   .RUSER_WIDTH  (RUSER_WIDTH),
   .CACHE_LINE_SIZE_BYTES (CACHE_LINE_SIZE_BYTES),
   .EXMON_WIDTH  (EXMON_WIDTH),
   .MAXRBURSTS   (MAXRBURSTS),
   .MAXWBURSTS   (MAXWBURSTS),
   .MAXWAITS     (MAXWAITS),
   .PROTOCOL     (`AXI4PC_AMBA_ACE_LITE),
   .MAX_BARRIERS_LITE  (MAX_BARRIERS),
   .RecommendOn  (RecommendOn),
   .RecMaxWaitOn (RecMaxWaitOn)
  )
  u_ace_pc
  (
   .ACLK    (ACLK),
   .ARESETn (ARESETn),

   // Write Address Channel
   .AWID    (AWID),
   .AWADDR  (AWADDR),
   .AWLEN   (AWLEN),
   .AWSIZE  (AWSIZE),
   .AWBURST (AWBURST),
   .AWLOCK  (AWLOCK),
   .AWCACHE (AWCACHE),
   .AWSNOOP (AWSNOOP),
   .AWPROT  (AWPROT),
   .AWUSER  (AWUSER),
   .AWQOS   (AWQOS),
   .AWBAR   (AWBAR),
   .AWDOMAIN    (AWDOMAIN),
   .AWREGION    (AWREGION),
   .AWVALID (AWVALID),
   .AWREADY (AWREADY),

   // Write Channel
   .WDATA   (WDATA),
   .WSTRB   (WSTRB),
   .WUSER   (WUSER),
   .WLAST   (WLAST),
   .WVALID  (WVALID),
   .WREADY  (WREADY),

   // Write Response Channel
   .BID (BID),
   .BRESP   (BRESP),
   .BUSER   (BUSER),
   .BVALID  (BVALID),
   .BREADY  (BREADY),
    
   .WACK    (WACK_AcePC),

   // Read Address Channel
   .ARID    (ARID),
   .ARADDR  (ARADDR),
   .ARREGION    (ARREGION),
   .ARLEN   (ARLEN),
   .ARSIZE  (ARSIZE),
   .ARBURST (ARBURST),
   .ARLOCK  (ARLOCK),
   .ARCACHE (ARCACHE),
   .ARSNOOP (ARSNOOP),
   .ARPROT  (ARPROT),
   .ARUSER  (ARUSER),
   .ARQOS   (ARQOS),
   .ARBAR   (ARBAR),
   .ARDOMAIN    (ARDOMAIN),
   .ARVALID (ARVALID),
   .ARREADY (ARREADY),

   //  Read Channel
   .RID (RID),
   .RLAST   (RLAST),
   .RDATA   (RDATA),
   .RRESP   ({2'b0,RRESP}),
   .RUSER   (RUSER),
   .RVALID  (RVALID),
   .RREADY  (RREADY),

   .RACK    (RACK_AcePC),
   // Snoop Address Channel
   .ACADDR  ({ADDR_WIDTH{1'b0}}),
   .ACPROT  (3'b0),
   .ACSNOOP (4'b0),
   .ACVALID (1'b0),
   .ACREADY (1'b0),
    
   // Snoop Response Channel
   .CRRESP  (5'b0),
   .CRVALID (1'b0),
   .CRREADY (1'b0),
    
   // .Snoop Data Channel
   .CDVALID (1'b0),
   .CDREADY (1'b0),
   .CDLAST  (1'b0),
   .CDDATA  ({DATA_WIDTH{1'b0}}),
    
  // Low Power Interface
  .CACTIVE  (CACTIVE),
  .CSYSREQ  (CSYSREQ),
  .CSYSACK  (CSYSACK) //,

   );




//------------------------------------------------------------------------------
// INDEX:   8) Clear Verilog Defines
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
// INDEX:   9) End of module
//------------------------------------------------------------------------------

endmodule // AceLitePC
`endif
`include "AcePC_message_undefs.v"
`include "AcePC_undefs.v"
`endif
//------------------------------------------------------------------------------
// INDEX:
// INDEX: End of File
//------------------------------------------------------------------------------
