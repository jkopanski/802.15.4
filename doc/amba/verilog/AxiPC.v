//============================================================================--
//  This confidential and proprietary software may be used only as
//  authorised by a licensing agreement from ARM Limited
//    (C) COPYRIGHT 2003-2009 ARM Limited
//        ALL RIGHTS RESERVED
//  The entire notice above must be reproduced on all authorised
//  copies and copies may only be made to the extent permitted
//  by a licensing agreement from ARM Limited.
//
//
//------------------------------------------------------------------------------
//  Version and Release Control Information:
//
//  File Name           : AxiPC.v,v
//  File Revision       : 66203
//
//  Release Information : BP062-VL-70002-r0p1-00rel0
//
//------------------------------------------------------------------------------
//  Purpose             : This is the AXI Protocol Checker using OVL
//
//                        Supports bus widths of 32, 64, 128, 256, 512, 1024 bit
//                        Parameterisable write interleave depth
//                        Supports a single outstanding exclusive read per ID
//============================================================================--

//----------------------------------------------------------------------------
// CONTENTS
// ========
//  300.  Module: AxiPC
//  367.    1) Parameters
//  371.         - Configurable (user can set)
//  425.         - Calculated (user should not override)
//  498.    2) Inputs (no outputs)
//  502.         - Global Signals 
//  508.         - Write Address Channel
//  523.         - Write Data Channel
//  534.         - Write Response Channel
//  543.         - Read Address Channel
//  558.         - Read Data Channel
//  568.         - Low Power Interface
//  576.    3) Wire and Reg Declarations
//  723.    4) Verilog Defines
//  727.         - Lock FSM States
//  736.         - Clock and Reset
//  768.         - OVL Version Specific Macros
//  810.    5) Initialize simulation 
//  815.         - Format for time reporting
//  821.         - Indicate version and release state of AxiPC
//  826.         - Warn if any/some recommended rules are disabled
//  846.         - Warn if any/some channel rules are ignored
//  862. 
//  863.  AXI Rules: Write Address Channel (*_AW*)
//  868.    1) Functional Rules
//  872.         - AXI_ERRM_AWADDR_BOUNDARY 
//  896.         - AXI_ERRM_AWADDR_WRAP_ALIGN
//  908.         - AXI_ERRM_AWBURST
//  920.         - AXI_ERRM_AWCACHE
//  932.         - AXI_ERRM_AWLEN_WRAP
//  947.         - AXI_ERRM_AWLOCK
//  959.         - AXI_ERRM_AWLOCK_END 
//  976.         - AXI_ERRM_AWLOCK_ID 
//  998.         - AXI_ERRM_AWLOCK_LAST 
// 1016.         - AXI_ERRM_AWLOCK_START 
// 1034.         - AXI_ERRM_AWSIZE
// 1048.         - AXI_ERRM_AWVALID_RESET 
// 1060.         - AXI_RECM_AWLOCK_BOUNDARY
// 1085.         - AXI_RECM_AWLOCK_CTRL  
// 1109.         - AXI_RECM_AWLOCK_NUM
// 1133.    2) Handshake Rules
// 1137.         - AXI_ERRM_AWADDR_STABLE
// 1150.         - AXI_ERRM_AWBURST_STABLE
// 1163.         - AXI_ERRM_AWCACHE_STABLE
// 1176.         - AXI_ERRM_AWID_STABLE
// 1189.         - AXI_ERRM_AWLEN_STABLE
// 1202.         - AXI_ERRM_AWLOCK_STABLE
// 1215.         - AXI_ERRM_AWPROT_STABLE
// 1228.         - AXI_ERRM_AWSIZE_STABLE
// 1241.         - AXI_ERRM_AWVALID_STABLE
// 1253.         - AXI_RECS_AWREADY_MAX_WAIT 
// 1269.    3) X-Propagation Rules
// 1275.         - AXI_ERRM_AWADDR_X 
// 1287.         - AXI_ERRM_AWBURST_X
// 1299.         - AXI_ERRM_AWCACHE_X
// 1311.         - AXI_ERRM_AWID_X
// 1323.         - AXI_ERRM_AWLEN_X
// 1335.         - AXI_ERRM_AWLOCK_X
// 1347.         - AXI_ERRM_AWPROT_X
// 1359.         - AXI_ERRM_AWSIZE_X
// 1371.         - AXI_ERRM_AWVALID_X
// 1383.         - AXI_ERRS_AWREADY_X
// 1398. 
// 1399.  AXI Rules: Write Data Channel (*_W*)
// 1404.    1) Functional Rules
// 1408.         - AXI_ERRM_WDATA_NUM
// 1423.         - AXI_ERRM_WDATA_ORDER
// 1434.         - AXI_ERRM_WDEPTH 
// 1446.         - AXI_ERRM_WSTRB
// 1457.         - AXI_ERRM_WVALID_RESET
// 1470.    2) Handshake Rules
// 1474.         - AXI_ERRM_WDATA_STABLE
// 1487.         - AXI_ERRM_WID_STABLE
// 1500.         - AXI_ERRM_WLAST_STABLE
// 1513.         - AXI_ERRM_WSTRB_STABLE
// 1526.         - AXI_ERRM_WVALID_STABLE
// 1538.         - AXI_RECS_WREADY_MAX_WAIT  
// 1554.    3) X-Propagation Rules
// 1560.         - AXI_ERRM_WDATA_X
// 1572.         - AXI_ERRM_WID_X
// 1584.         - AXI_ERRM_WLAST_X
// 1596.         - AXI_ERRM_WSTRB_X
// 1608.         - AXI_ERRM_WVALID_X
// 1620.         - AXI_ERRS_WREADY_X
// 1635. 
// 1636.  AXI Rules: Write Response Channel (*_B*)
// 1641.    1) Functional Rules
// 1645.         - AXI_ERRS_BRESP 
// 1656.         - AXI_ERRS_BRESP_ALL_DONE_EOS
// 1673.         - AXI_ERRS_BRESP_EXOKAY
// 1684.         - AXI_ERRS_BVALID_RESET
// 1696.         - AXI_RECS_BRESP 
// 1708.    2) Handshake Rules
// 1712.         - AXI_ERRS_BID_STABLE
// 1725.         - AXI_ERRS_BRESP_STABLE
// 1738.         - AXI_ERRS_BVALID_STABLE
// 1750.         - AXI_RECM_BREADY_MAX_WAIT  
// 1766.    3) X-Propagation Rules
// 1772.         - AXI_ERRM_BREADY_X
// 1784.         - AXI_ERRS_BID_X
// 1796.         - AXI_ERRS_BRESP_X
// 1808.         - AXI_ERRS_BVALID_X
// 1823. 
// 1824.  AXI Rules: Read Address Channel (*_AR*)
// 1829.    1) Functional Rules
// 1833.         - AXI_ERRM_ARADDR_BOUNDARY 
// 1857.         - AXI_ERRM_ARADDR_WRAP_ALIGN
// 1869.         - AXI_ERRM_ARBURST
// 1881.         - AXI_ERRM_ARCACHE
// 1893.         - AXI_ERRM_ARLEN_WRAP
// 1908.         - AXI_ERRM_ARLOCK
// 1920.         - AXI_ERRM_ARLOCK_END 
// 1937.         - AXI_ERRM_ARLOCK_ID
// 1959.         - AXI_ERRM_ARLOCK_LAST 
// 1976.         - AXI_ERRM_ARLOCK_START 
// 1994.         - AXI_ERRM_ARSIZE
// 2006.         - AXI_ERRM_ARVALID_RESET
// 2018.         - AXI_RECM_ARLOCK_BOUNDARY
// 2043.         - AXI_RECM_ARLOCK_CTRL 
// 2067.         - AXI_RECM_ARLOCK_NUM
// 2091.    2) Handshake Rules
// 2095.         - AXI_ERRM_ARADDR_STABLE
// 2108.         - AXI_ERRM_ARBURST_STABLE
// 2121.         - AXI_ERRM_ARCACHE_STABLE
// 2134.         - AXI_ERRM_ARID_STABLE
// 2147.         - AXI_ERRM_ARLEN_STABLE
// 2160.         - AXI_ERRM_ARLOCK_STABLE
// 2173.         - AXI_ERRM_ARPROT_STABLE
// 2186.         - AXI_ERRM_ARSIZE_STABLE
// 2199.         - AXI_ERRM_ARVALID_STABLE
// 2211.         - AXI_RECS_ARREADY_MAX_WAIT  
// 2227.    3) X-Propagation Rules
// 2233.         - AXI_ERRM_ARADDR_X
// 2245.         - AXI_ERRM_ARBURST_X
// 2257.         - AXI_ERRM_ARCACHE_X
// 2269.         - AXI_ERRM_ARID_X
// 2281.         - AXI_ERRM_ARLEN_X
// 2293.         - AXI_ERRM_ARLOCK_X
// 2305.         - AXI_ERRM_ARPROT_X
// 2317.         - AXI_ERRM_ARSIZE_X
// 2329.         - AXI_ERRM_ARVALID_X
// 2341.         - AXI_ERRS_ARREADY_X
// 2356. 
// 2357.  AXI Rules: Read Data Channel (*_R*)
// 2362.    1) Functional Rules
// 2366.         - AXI_ERRS_RDATA_NUM 
// 2380.         - AXI_ERRS_RLAST_ALL_DONE_EOS 
// 2397.         - AXI_ERRS_RID 
// 2410.         - AXI_ERRS_RRESP_EXOKAY 
// 2422.         - AXI_ERRS_RVALID_RESET
// 2435.    2) Handshake Rules
// 2439.         - AXI_ERRS_RDATA_STABLE 
// 2454.         - AXI_ERRS_RID_STABLE
// 2467.         - AXI_ERRS_RLAST_STABLE
// 2480.         - AXI_ERRS_RRESP_STABLE
// 2493.         - AXI_ERRS_RVALID_STABLE
// 2505.         - AXI_RECM_RREADY_MAX_WAIT  
// 2521.    3) X-Propagation Rules 
// 2527.         - AXI_ERRS_RDATA_X
// 2539.         - AXI_ERRM_RREADY_X
// 2551.         - AXI_ERRS_RID_X
// 2563.         - AXI_ERRS_RLAST_X
// 2575.         - AXI_ERRS_RRESP_X
// 2587.         - AXI_ERRS_RVALID_X
// 2602. 
// 2603.  AXI Rules: Low Power Interface (*_C*)
// 2608.    1) Functional Rules (none for Low Power signals)
// 2613.    2) Handshake Rules (asynchronous to ACLK)
// 2620.         - AXI_ERRL_CSYSACK_FALL
// 2631.         - AXI_ERRL_CSYSACK_RISE
// 2642.         - AXI_ERRL_CSYSREQ_FALL
// 2653.         - AXI_ERRL_CSYSREQ_RISE
// 2665.    3) X-Propagation Rules
// 2671.         - AXI_ERRL_CACTIVE_X 
// 2683.         - AXI_ERRL_CSYSACK_X 
// 2695.         - AXI_ERRL_CSYSREQ_X 
// 2710. 
// 2711.  AXI Rules: Exclusive Access
// 2719.    1) Functional Rules
// 2721.         - 
// 2724.         - AXI_ERRM_EXCL_ALIGN
// 2745.         - AXI_ERRM_EXCL_LEN
// 2763.         - AXI_RECM_EXCL_MATCH 
// 2786.         - AXI_ERRM_EXCL_MAX
// 2807.         - AXI_RECM_EXCL_PAIR 
// 2824. 
// 2825.  AXI Rules: USER_* Rules (extension to AXI)
// 2833.    1) Functional Rules (none for USER signals)
// 2838.    2) Handshake Rules
// 2842.         - AXI_ERRM_AWUSER_STABLE
// 2855.         - AXI_ERRM_WUSER_STABLE
// 2868.         - AXI_ERRS_BUSER_STABLE
// 2881.         - AXI_ERRM_ARUSER_STABLE
// 2894.         - AXI_ERRS_RUSER_STABLE
// 2908.    3) X-Propagation Rules
// 2914.         - AXI_ERRM_AWUSER_X
// 2926.         - AXI_ERRM_WUSER_X
// 2938.         - AXI_ERRS_BUSER_X
// 2950.         - AXI_ERRM_ARUSER_X
// 2962.         - AXI_ERRS_RUSER_X
// 2977. 
// 2978.  Auxiliary Logic
// 2983.    1) Rules for Auxiliary Logic
// 2988.       a) Master (AUXM*)
// 2992.         - AXI_AUXM_DATA_WIDTH
// 3007.         - AXI_AUXM_ADDR_WIDTH
// 3018.         - AXI_AUXM_AWUSER_WIDTH
// 3029.         - AXI_AUXM_WUSER_WIDTH
// 3040.         - AXI_AUXM_BUSER_WIDTH
// 3051.         - AXI_AUXM_ARUSER_WIDTH
// 3062.         - AXI_AUXM_RUSER_WIDTH
// 3073.         - AXI_AUXM_ID_WIDTH
// 3084.         - AXI_AUXM_EXMON_WIDTH
// 3095.         - AXI_AUXM_WDEPTH
// 3106.         - AXI_AUXM_MAXRBURSTS
// 3117.         - AXI_AUXM_MAXWBURSTS
// 3128.         - AXI_AUXM_RCAM_OVERFLOW
// 3139.         - AXI_AUXM_RCAM_UNDERFLOW
// 3150.         - AXI_AUXM_WCAM_OVERFLOW
// 3161.         - AXI_AUXM_WCAM_UNDERFLOW
// 3172.         - AXI_AUXM_EXCL_OVERFLOW
// 3184.    2) Combinatorial Logic
// 3189.       a) Masks
// 3193.            - AlignMaskR 
// 3215.            - AlignMaskW
// 3237.            - ExclMask
// 3245.            - WdataMask
// 3258.            - RdataMask
// 3264.       b) Increments
// 3268.            - ArAddrIncr 
// 3276.            - AwAddrIncr
// 3285.       c) Conversions
// 3289.            - ArLenInBytes
// 3297.            - ArSizeInBits
// 3305.            - AwSizeInBits
// 3314.       d) Other
// 3318.            - ArExclPending
// 3324.            - ArLenPending
// 3329.            - ArCountPending
// 3336.    3) EXCL & LOCK Accesses
// 3340.         - Exclusive Access ID Lookup
// 3466.         - Exclusive Access Storage
// 3521.         - Lock State Machine
// 3562.         - Lock State Register
// 3585.         - Lock Property Logic
// 3695.    4) Content addressable memories (CAMs)
// 3699.         - Read CAMSs (CAM+Shift) 
// 3839.         - Write CAMs (CAM+Shift)
// 4223.         - Write Depth array
// 4317.    5) Verilog Functions
// 4321.         - CheckBurst
// 4420.         - CheckStrb
// 4458.         - ReadDataMask
// 4478.         - ByteShift
// 4573.         - ByteCount
// 4620. 
// 4621.  End of File
// 4626.    1) Clear Verilog Defines
// 4663.    2) End of module
//----------------------------------------------------------------------------

`timescale 1ns/1ns

//------------------------------------------------------------------------------
// AXI Standard Defines
//------------------------------------------------------------------------------
`include "Axi.v"


//------------------------------------------------------------------------------
// INDEX: Module: AxiPC
//------------------------------------------------------------------------------
module AxiPC
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
   AWPROT,
   AWUSER,
   AWVALID,
   AWREADY,

   // Write Channel
   WID,
   WLAST,
   WDATA,
   WSTRB,
   WUSER,
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
   ARLEN,
   ARSIZE,
   ARBURST,
   ARLOCK,
   ARCACHE,
   ARPROT,
   ARUSER,
   ARVALID,
   ARREADY,

   // Read Channel
   RID,
   RLAST,
   RDATA,
   RRESP,
   RUSER,
   RVALID,
   RREADY,

   // Low power interface
   CACTIVE,
   CSYSREQ,
   CSYSACK
   );


//------------------------------------------------------------------------------
// INDEX:   1) Parameters
//------------------------------------------------------------------------------


  // INDEX:        - Configurable (user can set)
  // =====
  // Parameters below can be set by the user.

  // Set DATA_WIDTH to the data-bus width required
  parameter DATA_WIDTH = 64;         // data bus width, default = 64-bit

  // Select the number of channel ID bits required
  parameter ID_WIDTH = 4;          // (A|W|R|B)ID width

  // Select the size of the USER buses, default = 32-bit
  parameter AWUSER_WIDTH = 32; // width of the user AW sideband field
  parameter WUSER_WIDTH  = 32; // width of the user W  sideband field
  parameter BUSER_WIDTH  = 32; // width of the user B  sideband field
  parameter ARUSER_WIDTH = 32; // width of the user AR sideband field
  parameter RUSER_WIDTH  = 32; // width of the user R  sideband field

  // Write-interleave Depth of monitored slave interface
  parameter WDEPTH = 1;

  // Size of CAMs for storing outstanding read bursts, this should match or
  // exceed the number of outstanding read addresses accepted into the slave
  // interface
  parameter MAXRBURSTS = 16;

  // Size of CAMs for storing outstanding write bursts, this should match or
  // exceed the number of outstanding write bursts into the slave  interface
  parameter MAXWBURSTS = 16;

  // Maximum number of cycles between VALID -> READY high before a warning is
  // generated
  parameter MAXWAITS = 16;

  // OVL instances property_type parameter (0=assert, 1=assume, 2=ignore)
  parameter AXI_ERRM_PropertyType = 0; // default: assert Master is AXI compliant
  parameter AXI_RECM_PropertyType = 0; // default: assert Master is AXI compliant
  parameter AXI_AUXM_PropertyType = 0; // default: assert Master auxiliary logic checks
  //
  parameter AXI_ERRS_PropertyType = 0; // default: assert Slave is AXI compliant
  parameter AXI_RECS_PropertyType = 0; // default: assert Slave is AXI compliant
  parameter AXI_AUXS_PropertyType = 0; // default: assert Slave auxiliary logic checks
  //
  parameter AXI_ERRL_PropertyType = 0; // default: assert LP Int is AXI compliant

  // Recommended Rules Enable
  parameter RecommendOn   = 1'b1;   // enable/disable reporting of all  AXI_REC*_* rules
  parameter RecMaxWaitOn  = 1'b1;   // enable/disable reporting of just AXI_REC*_MAX_WAIT rules

  // Set ADDR_WIDTH to the address-bus width required
  parameter ADDR_WIDTH = 32;         // address bus width, default = 32-bit

  // Set EXMON_WIDTH to the exclusive access monitor width required
  parameter EXMON_WIDTH = 4;         // exclusive access width, default = 4-bit

  // INDEX:        - Calculated (user should not override)
  // =====
  // Do not override the following parameters: they must be calculated exactly
  // as shown below
  parameter DATA_MAX   = DATA_WIDTH-1; // data max index
  parameter ADDR_MAX   = ADDR_WIDTH-1; // address max index
  parameter STRB_WIDTH = DATA_WIDTH/8; // WSTRB width
  parameter STRB_MAX   = STRB_WIDTH-1; // WSTRB max index
  parameter STRB_1     = {{STRB_MAX{1'b0}}, 1'b1};  // value 1 in strobe width
  parameter ID_MAX     = ID_WIDTH-1;   // ID max index
  parameter EXMON_MAX  = EXMON_WIDTH-1;       // EXMON max index
  parameter EXMON_HI   = {EXMON_WIDTH{1'b1}}; // EXMON max value

  parameter AWUSER_MAX = AWUSER_WIDTH-1; // AWUSER max index
  parameter  WUSER_MAX =  WUSER_WIDTH-1; // WUSER  max index
  parameter  BUSER_MAX =  BUSER_WIDTH-1; // BUSER  max index
  parameter ARUSER_MAX = ARUSER_WIDTH-1; // ARUSER max index
  parameter  RUSER_MAX =  RUSER_WIDTH-1; // RUSER  max index

  // FLAGLL/LO/UN WSTRB16...WSTRB1 ID BURST ASIZE ALEN LOCKED EXCL LAST ADDR[6:0]
  parameter ADDRLO   = 0;                 // ADDRLO   =   0
  parameter ADDRHI   = 6;                 // ADDRHI   =   6
  parameter EXCL     = ADDRHI + 1;        // Transaction is exclusive
  parameter LOCKED   = EXCL + 1;          // Transaction is locked
  parameter ALENLO   = LOCKED + 1;        // ALENLO   =   9
  parameter ALENHI   = ALENLO + 3;        // ALENHI   =  12
  parameter ASIZELO  = ALENHI + 1;        // ASIZELO  =  13
  parameter ASIZEHI  = ASIZELO + 2;       // ASIZEHI  =  15
  parameter BURSTLO  = ASIZEHI + 1;       // BURSTLO  =  16
  parameter BURSTHI  = BURSTLO + 1;       // BURSTHI  =  17
  parameter IDLO     = BURSTHI + 1;       // IDLO     =  18
  parameter IDHI     = IDLO+ID_MAX;       // IDHI     =  21 if ID_WIDTH=4
  parameter STRB1LO  = IDHI+1;            // STRB1LO  =  22 if ID_WIDTH=4 & STRB_MAX=7
  parameter STRB1HI  = STRB1LO+STRB_MAX;  // STRB1HI  =  29 if ID_WIDTH=4 & STRB_MAX=7
  parameter STRB2LO  = STRB1HI+1;         // STRB2LO  =  30 if ID_WIDTH=4 & STRB_MAX=7
  parameter STRB2HI  = STRB2LO+STRB_MAX;  // STRB2HI  =  37 if ID_WIDTH=4 & STRB_MAX=7
  parameter STRB3LO  = STRB2HI+1;         // STRB3LO  =  38 if ID_WIDTH=4 & STRB_MAX=7
  parameter STRB3HI  = STRB3LO+STRB_MAX;  // STRB3HI  =  45 if ID_WIDTH=4 & STRB_MAX=7
  parameter STRB4LO  = STRB3HI+1;         // STRB4LO  =  46 if ID_WIDTH=4 & STRB_MAX=7
  parameter STRB4HI  = STRB4LO+STRB_MAX;  // STRB4HI  =  53 if ID_WIDTH=4 & STRB_MAX=7
  parameter STRB5LO  = STRB4HI+1;         // STRB5LO  =  54 if ID_WIDTH=4 & STRB_MAX=7
  parameter STRB5HI  = STRB5LO+STRB_MAX;  // STRB5HI  =  61 if ID_WIDTH=4 & STRB_MAX=7
  parameter STRB6LO  = STRB5HI+1;         // STRB6LO  =  62 if ID_WIDTH=4 & STRB_MAX=7
  parameter STRB6HI  = STRB6LO+STRB_MAX;  // STRB6HI  =  69 if ID_WIDTH=4 & STRB_MAX=7
  parameter STRB7LO  = STRB6HI+1;         // STRB7LO  =  70 if ID_WIDTH=4 & STRB_MAX=7
  parameter STRB7HI  = STRB7LO+STRB_MAX;  // STRB7HI  =  77 if ID_WIDTH=4 & STRB_MAX=7
  parameter STRB8LO  = STRB7HI+1;         // STRB8LO  =  78 if ID_WIDTH=4 & STRB_MAX=7
  parameter STRB8HI  = STRB8LO+STRB_MAX;  // STRB8HI  =  85 if ID_WIDTH=4 & STRB_MAX=7
  parameter STRB9LO  = STRB8HI+1;         // STRB9LO  =  86 if ID_WIDTH=4 & STRB_MAX=7
  parameter STRB9HI  = STRB9LO+STRB_MAX;  // STRB9HI  =  93 if ID_WIDTH=4 & STRB_MAX=7
  parameter STRB10LO = STRB9HI+1;         // STRB10LO =  94 if ID_WIDTH=4 & STRB_MAX=7
  parameter STRB10HI = STRB10LO+STRB_MAX; // STRB10HI = 101 if ID_WIDTH=4 & STRB_MAX=7
  parameter STRB11LO = STRB10HI+1;        // STRB11LO = 102 if ID_WIDTH=4 & STRB_MAX=7
  parameter STRB11HI = STRB11LO+STRB_MAX; // STRB11HI = 109 if ID_WIDTH=4 & STRB_MAX=7
  parameter STRB12LO = STRB11HI+1;        // STRB12LO = 110 if ID_WIDTH=4 & STRB_MAX=7
  parameter STRB12HI = STRB12LO+STRB_MAX; // STRB12HI = 117 if ID_WIDTH=4 & STRB_MAX=7
  parameter STRB13LO = STRB12HI+1;        // STRB13LO = 118 if ID_WIDTH=4 & STRB_MAX=7
  parameter STRB13HI = STRB13LO+STRB_MAX; // STRB13HI = 125 if ID_WIDTH=4 & STRB_MAX=7
  parameter STRB14LO = STRB13HI+1;        // STRB14LO = 126 if ID_WIDTH=4 & STRB_MAX=7
  parameter STRB14HI = STRB14LO+STRB_MAX; // STRB14HI = 133 if ID_WIDTH=4 & STRB_MAX=7
  parameter STRB15LO = STRB14HI+1;        // STRB15LO = 134 if ID_WIDTH=4 & STRB_MAX=7
  parameter STRB15HI = STRB15LO+STRB_MAX; // STRB15HI = 141 if ID_WIDTH=4 & STRB_MAX=7
  parameter STRB16LO = STRB15HI+1;        // STRB16LO = 142 if ID_WIDTH=4 & STRB_MAX=7
  parameter STRB16HI = STRB16LO+STRB_MAX; // STRB16HI = 149 if ID_WIDTH=4 & STRB_MAX=7
  parameter FLAGUN   = STRB16HI+1;        // Seen coincident with unlocked transactions
  parameter FLAGLO   = FLAGUN+1;          // Seen coincident with locked transactions
  parameter FLAGLL   = FLAGLO+1;          // Seen coincident with lock last transaction

  parameter WBURSTMAX = FLAGLL; // Write burst register array maximum
  parameter RBURSTMAX = IDHI;   // Read burst register array maximum


//------------------------------------------------------------------------------
// INDEX:   2) Inputs (no outputs)
//------------------------------------------------------------------------------


  // INDEX:        - Global Signals 
  // =====
  input                ACLK;        // AXI Clock
  input                ARESETn;     // AXI Reset


  // INDEX:        - Write Address Channel
  // =====
  input     [ID_MAX:0] AWID;
  input   [ADDR_MAX:0] AWADDR;
  input          [3:0] AWLEN;
  input          [2:0] AWSIZE;
  input          [1:0] AWBURST;
  input          [3:0] AWCACHE;
  input          [2:0] AWPROT;
  input          [1:0] AWLOCK;
  input [AWUSER_MAX:0] AWUSER;
  input                AWVALID;
  input                AWREADY;


  // INDEX:        - Write Data Channel
  // =====
  input     [ID_MAX:0] WID;
  input   [DATA_MAX:0] WDATA;
  input   [STRB_MAX:0] WSTRB;
  input  [WUSER_MAX:0] WUSER;
  input                WLAST;
  input                WVALID;
  input                WREADY;


  // INDEX:        - Write Response Channel
  // =====
  input     [ID_MAX:0] BID;
  input          [1:0] BRESP;
  input  [BUSER_MAX:0] BUSER;
  input                BVALID;
  input                BREADY;


  // INDEX:        - Read Address Channel
  // =====
  input     [ID_MAX:0] ARID;
  input   [ADDR_MAX:0] ARADDR;
  input          [3:0] ARLEN;
  input          [2:0] ARSIZE;
  input          [1:0] ARBURST;
  input          [3:0] ARCACHE;
  input          [2:0] ARPROT;
  input          [1:0] ARLOCK;
  input [ARUSER_MAX:0] ARUSER;
  input                ARVALID;
  input                ARREADY;


  // INDEX:        - Read Data Channel
  // =====
  input     [ID_MAX:0] RID;
  input   [DATA_MAX:0] RDATA;
  input          [1:0] RRESP;
  input  [RUSER_MAX:0] RUSER;
  input                RLAST;
  input                RVALID;
  input                RREADY;

  // INDEX:        - Low Power Interface
  // =====
  input                CACTIVE;
  input                CSYSREQ;
  input                CSYSACK;


//------------------------------------------------------------------------------
// INDEX:   3) Wire and Reg Declarations
//------------------------------------------------------------------------------

  // User signal definitions are defined as weak pull-down in the case
  // that they are unconnected.
  tri0 [AWUSER_MAX:0] AWUSER;
  tri0  [WUSER_MAX:0] WUSER;
  tri0  [BUSER_MAX:0] BUSER;
  tri0 [ARUSER_MAX:0] ARUSER;
  tri0  [RUSER_MAX:0] RUSER;

  // Low power interface signals are defined as weak pull-up in the case
  // that they are unconnected.
  tri1                CACTIVE;
  tri1                CSYSREQ;
  tri1                CSYSACK;

  // Write CAMs
  integer            WIndex;
  reg  [WBURSTMAX:0] WBurstCam[1:MAXWBURSTS]; // store outstanding write bursts
  reg          [4:0] WCountCam[1:MAXWBURSTS]; // number of write data stored
  reg                WLastCam[1:MAXWBURSTS];  // WLAST for outstanding writes
  reg                WAddrCam[1:MAXWBURSTS];  // flag for valid write addr
  reg                BRespCam[1:MAXWBURSTS];  // flag for valid write resp
  reg                nWAddrTrans;    // flag for an empty WAddrCam
  reg                UnlockedInWCam; // At least one unlocked read in WBurstCam
  reg                LockedInWCam;   // At least one locked read in WBurstCam
  reg                FlagUNInWCam;   // At least one write transaction has FLAGUN set
  reg                FlagLOInWCam;   // At least one write transaction has FLAGLO set
  reg                FlagLLInWCam;   // At least one write transaction has FLAGLL set

  // WDepth array
  reg     [ID_MAX:0] WdepthId[WDEPTH:0]; // Write ID lookup table
  reg     [WDEPTH:0] WdepthIdValid;      // Write ID lookup table entry valid
  reg                WdepthIdDelta;      // Write ID lookup table has changed
  wire               WdepthIdFull;       // Write ID lookup table is full
  reg         [15:0] WdepthIdFreePtr;    // Write ID lookup table next free entry
  wire        [15:0] WdepthIdWrPtr;      // Write ID lookup table write pointer
  reg                WdepthWMatch;       // Write ID lookup table WID match found
  reg         [15:0] WdepthWId;          // Write ID lookup table matching WID reference
  integer            WidDepth;           // Number of write data IDs currently in use

  // Read CAMs
  reg  [RBURSTMAX:0] RBurstCam[1:MAXRBURSTS];
  reg          [4:0] RCountCam[1:MAXRBURSTS];
  integer            RIndex;
  integer            RIndexNext;
  wire               RPop;
  wire               RPush;
  wire               nROutstanding;  // flag for an empty RBurstCam
  reg                RIdCamDelta;    // flag indicates that RidCam has changed
  reg                UnlockedInRCam; // flag for unlocked reads in RBurstCam
  reg                LockedInRCam;   // flag for locked reads in RBurstCam

  // Protocol error flags
  wire               WriteDataNumError; // flag for AXI_ERRM_WDATA_NUM rule
  reg                AWDataNumError;  // flag to derive WriteDataNumError
  reg                WDataNumError;   // flag to derive WriteDataNumError
  reg                WDataOrderError; // flag for AXI_ERRM_WDATA_ORDER rule
  reg                BrespError;      // flag for AXI_ERRS_BRESP rule
  reg                BrespExokError;  // flag for AXI_ERRS_BRESP_EXOKAY rule
  wire               StrbError;       // flag for AXI_ERRM_WSTRB rule
  reg                AWStrbError;     // flag to derive StrbError
  reg                BStrbError;      // flag to derive StrbError

  // Protocol recommendation flags
  reg                BrespLeadingRec; // flag for AXI_RECS_BRESP rule

  // signals for checking for match in ID CAMs
  integer            AidMatch;
  integer            WidMatch;
  integer            RidMatch;
  integer            BidMatch;

  reg          [6:0] AlignMaskR; // mask for checking read address alignment
  reg          [6:0] AlignMaskW; // mask for checking write address alignment

  // signals for Address Checking
  reg   [ADDR_MAX:0] ArAddrIncr;
  reg   [ADDR_MAX:0] AwAddrIncr;

  // signals for Data Checking
  wire  [DATA_MAX:0] RdataMask;
  reg   [DATA_MAX:0] WdataMask;
  reg         [10:0] ArSizeInBits;
  reg         [10:0] AwSizeInBits;
  reg         [11:0] ArLenInBytes;
  wire         [4:0] ArLenPending;
  wire         [4:0] ArCountPending;
  wire               ArExclPending;

  // Lock signals
  wire               AWLockNew;     // Initial locking write address valid for a locked sequence
  wire               ARLockNew;     // Initial locking read address valid for a locked sequence
  wire               AWLockLastNew; // Unlocking write address valid for a locked sequence
  wire               ARLockLastNew; // Unlocking read address valid for a locked sequence
  wire               LockedRead;    // At least one locked read on the bus
  wire               UnlockedRead;  // At least one unlocked read on the bus
  wire               LockedWrite;   // At least one locked write on the bus
  wire               UnlockedWrite; // At least one unlocked write on the bus
  reg                PrevAWVALID;   // Prev cycle had AWVALID=1
  reg                PrevAWREADY;   // Prev cycle had AWREADY=1
  reg                PrevARVALID;   // Prev cycle had ARVALID=1
  reg                PrevARREADY;   // Prev cycle had ARREADY=1
  wire               AWNew;         // New valid write address in current cycle
  wire               ARNew;         // New valid read address in current cycle
  reg          [1:0] LockState;
  reg          [1:0] LockStateNext;
  reg     [ID_MAX:0] LockIdNext;
  reg     [ID_MAX:0] LockId;
  reg          [3:0] LockCacheNext;
  reg          [3:0] LockCache;
  reg          [2:0] LockProtNext;
  reg          [2:0] LockProt;
  reg   [ADDR_MAX:0] LockAddrNext;
  reg   [ADDR_MAX:0] LockAddr;

  // arrays to store exclusive access control info
  reg     [ID_MAX:0] ExclId[EXMON_HI:0];
  reg                ExclIdDelta;
  reg   [EXMON_HI:0] ExclIdValid;
  wire               ExclIdFull;
  wire               ExclIdOverflow;
  reg  [EXMON_MAX:0] ExclIdFreePtr;
  wire [EXMON_MAX:0] ExclIdWrPtr;
  reg  [EXMON_MAX:0] ExclAwId;
  reg                ExclAwMatch;
  reg  [EXMON_MAX:0] ExclArId;
  reg                ExclArMatch;
  reg  [EXMON_MAX:0] ExclRId;
  reg                ExclRMatch;
  reg                ExclReadAddr[EXMON_HI:0]; // tracks excl read addr
  reg                ExclReadData[EXMON_HI:0]; // tracks excl read data
  reg   [ADDR_MAX:0] ExclAddr[EXMON_HI:0];
  reg          [2:0] ExclSize[EXMON_HI:0];
  reg          [3:0] ExclLen[EXMON_HI:0];
  reg          [1:0] ExclBurst[EXMON_HI:0];
  reg          [3:0] ExclCache[EXMON_HI:0];
  reg          [2:0] ExclProt[EXMON_HI:0];
  reg [AWUSER_MAX:0] ExclUser[EXMON_HI:0];
  reg         [10:0] ExclMask; // mask to check alignment of exclusive address

  // Signals to avoid feeding parameters directly into assertions as this can
  // stop assertions triggering in some cases
  reg                i_RecommendOn;
  reg                i_RecMaxWaitOn;


//------------------------------------------------------------------------------
// INDEX:   4) Verilog Defines
//------------------------------------------------------------------------------


  // INDEX:        - Lock FSM States
  // =====
  // Lock FSM States (3-state FSM, so one state encoding is not used)
  `define AXI_AUX_ST_UNLOCKED  2'b00
  `define AXI_AUX_ST_LOCKED    2'b01
  `define AXI_AUX_ST_LOCK_LAST 2'b10
  `define AXI_AUX_ST_NOT_USED  2'b11


  // INDEX:        - Clock and Reset
  // =====
  // Can be overridden by user for a clock enable.
  //
  // Can also be used to clock OVL on negedge (to avoid race hazards with
  // auxiliary logic) by compiling with the override:
  //
  //   +define+AXI_OVL_CLK=~ACLK
  // 
  // OVL: Assertion Instances
  `ifdef AXI_OVL_CLK
  `else
     `define AXI_OVL_CLK ACLK
  `endif
  //
  `ifdef AXI_OVL_RSTn
  `else
     `define AXI_OVL_RSTn ARESETn
  `endif
  // 
  // AUX: Auxiliary Logic
  `ifdef AXI_AUX_CLK
  `else
     `define AXI_AUX_CLK ACLK
  `endif
  //
  `ifdef AXI_AUX_RSTn
  `else
     `define AXI_AUX_RSTn ARESETn
  `endif


  // INDEX:        - OVL Version Specific Macros
  // =====
  `ifdef AXI_USE_OLD_OVL
     // Old OVL library from April 2003
     // ===============================
     // severity_level
     `define AXI_SimFatal   0
     `define AXI_SimError   1
     `define AXI_SimWarning 2
     //
     // assert_implication typo
     `define AXI_ANTECEDENT .antecendent_expr
     //
     // assert_quiescent_state switch for EOS
     `ifdef  ASSERT_END_OF_SIMULATION
        `define AXI_END_OF_SIMULATION `ASSERT_END_OF_SIMULATION
     `endif
  `else
     // Accellera V1.0 and later
     // ========================
     `include "std_ovl_defines.h"
     // severity_level
     `define AXI_SimFatal   `OVL_FATAL
     `define AXI_SimError   `OVL_ERROR
     `define AXI_SimWarning `OVL_WARNING
     //
     // assert_implication with correct spelling
     `define AXI_ANTECEDENT .antecedent_expr
     //
     // assert_quiescent_state switch for EOS
     `ifdef     OVL_END_OF_SIMULATION
        `define AXI_END_OF_SIMULATION `OVL_END_OF_SIMULATION
     `endif
     //
     // Disable for X-checking
     `ifdef     OVL_XCHECK_OFF
        `define AXI_XCHECK_OFF
     `endif
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


       // INDEX:        - Indicate version and release state of AxiPC
       // =====
       $display("AXI_INFO: Running AxiPC version BP062-BU-01000-r0p1-00rel0");


       // INDEX:        - Warn if any/some recommended rules are disabled
       // =====
       if (~RecommendOn)
         // All AXI_REC*_* rules disabled
         $display("AXI_WARN: All recommended AXI rules have been disabled by the RecommendOn parameter");
       else if (~RecMaxWaitOn)
         // Just AXI_REC*_MAX_WAIT rules disabled
         $display("AXI_WARN: Five recommended MAX_WAIT rules have been disabled by the RecMaxWaitOn parameter");

       if (RecommendOn)
         i_RecommendOn = 1'b1;
       else
         i_RecommendOn = 1'b0;

       if (RecMaxWaitOn)
         i_RecMaxWaitOn = 1'b1;
       else
         i_RecMaxWaitOn = 1'b0;


       // INDEX:        - Warn if any/some channel rules are ignored
       // =====
       if (AXI_ERRM_PropertyType == 2) $display("AXI_WARN: All AXI_ERRM_* rules have been ignored by the AXI_ERRM_PropertyType parameter");
       if (AXI_RECM_PropertyType == 2) $display("AXI_WARN: All AXI_RECM_* rules have been ignored by the AXI_RECM_PropertyType parameter");
       if (AXI_AUXM_PropertyType == 2) $display("AXI_WARN: All AXI_AUXM_* rules have been ignored by the AXI_AUXM_PropertyType parameter");
       //
       if (AXI_ERRS_PropertyType == 2) $display("AXI_WARN: All AXI_ERRS_* rules have been ignored by the AXI_ERRS_PropertyType parameter");
       if (AXI_RECS_PropertyType == 2) $display("AXI_WARN: All AXI_RECS_* rules have been ignored by the AXI_RECS_PropertyType parameter");
       if (AXI_AUXS_PropertyType == 2) $display("AXI_WARN: All AXI_AUXS_* rules have been ignored by the AXI_AUXS_PropertyType parameter");
       //
       if (AXI_ERRL_PropertyType == 2) $display("AXI_WARN: All AXI_ERRL_* rules have been ignored by the AXI_ERRL_PropertyType parameter");

    end


//------------------------------------------------------------------------------
// INDEX:
// INDEX: AXI Rules: Write Address Channel (*_AW*)
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// INDEX:   1) Functional Rules
//------------------------------------------------------------------------------


  // INDEX:        - AXI_ERRM_AWADDR_BOUNDARY 
  // =====
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
  assert_implication #(`AXI_SimError, AXI_ERRM_PropertyType,
    "AXI_ERRM_AWADDR_BOUNDARY. A write burst cannot cross a 4kbyte boundary. Spec: section 4.1 on page 4-2."
  )  axi_errm_awaddr_boundary
     (.clk              (`AXI_OVL_CLK),
      .reset_n          (`AXI_OVL_RSTn),
      `AXI_ANTECEDENT   (AWVALID & (AWBURST == `AXI_ABURST_INCR)),
      .consequent_expr  (AwAddrIncr[ADDR_MAX:12] == AWADDR[ADDR_MAX:12])
      );


  // INDEX:        - AXI_ERRM_AWADDR_WRAP_ALIGN
  // =====
  assert_implication #(`AXI_SimError, AXI_ERRM_PropertyType,
    "AXI_ERRM_AWADDR_WRAP_ALIGN. A write transaction with burst type WRAP must have an aligned address. Spec: section 4.4.3 on page 4-6."
  )  axi_errm_awaddr_wrap_align
     (.clk              (`AXI_OVL_CLK),
      .reset_n          (`AXI_OVL_RSTn),
      `AXI_ANTECEDENT   (AWVALID & (AWBURST == `AXI_ABURST_WRAP)),
      .consequent_expr  ((AWADDR[6:0] & AlignMaskW) == AWADDR[6:0])
      );


  // INDEX:        - AXI_ERRM_AWBURST
  // =====
  assert_implication #(`AXI_SimError, AXI_ERRM_PropertyType,
    "AXI_ERRM_AWBURST. When AWVALID is high, a value of 2'b11 on AWBURST is not permitted. Spec: table 4-3 on page 4-5."
  )  axi_errm_awburst
     (.clk              (`AXI_OVL_CLK),
      .reset_n          (`AXI_OVL_RSTn),
      `AXI_ANTECEDENT   (AWVALID),
      .consequent_expr  (AWBURST != 2'b11)
      );


  // INDEX:        - AXI_ERRM_AWCACHE
  // =====
  assert_implication #(`AXI_SimError, AXI_ERRM_PropertyType,
    "AXI_ERRM_AWCACHE. When AWVALID is high, if AWCACHE[1] is low then AWCACHE[3] and AWCACHE[2] must also be low. Spec: table 5-1 on page 5-3."
  )  axi_errm_awcache
     (.clk              (`AXI_OVL_CLK),
      .reset_n          (`AXI_OVL_RSTn),
      `AXI_ANTECEDENT   (AWVALID & ~AWCACHE[1]),
      .consequent_expr  (AWCACHE[3:2] == 2'b00)
      );


  // INDEX:        - AXI_ERRM_AWLEN_WRAP
  // =====
  assert_implication #(`AXI_SimError, AXI_ERRM_PropertyType,
    "AXI_ERRM_AWLEN_WRAP. A write transaction with burst type WRAP must have length 2, 4, 8 or 16. Spec: section 4.4.3 on page 4-6."
  )  axi_errm_awlen_wrap
     (.clk              (`AXI_OVL_CLK),
      .reset_n          (`AXI_OVL_RSTn),
      `AXI_ANTECEDENT   (AWVALID & (AWBURST == `AXI_ABURST_WRAP)),
      .consequent_expr  (AWLEN == `AXI_ALEN_2 ||
                         AWLEN == `AXI_ALEN_4 ||
                         AWLEN == `AXI_ALEN_8 ||
                         AWLEN == `AXI_ALEN_16)
      );


  // INDEX:        - AXI_ERRM_AWLOCK
  // =====
  assert_implication #(`AXI_SimError, AXI_ERRM_PropertyType,
    "AXI_ERRM_AWLOCK. When AWVALID is high, a value of 2'b11 on AWLOCK is not permitted. Spec: table 6-1 on page 6-2."
  )  axi_errm_awlock
     (.clk              (`AXI_OVL_CLK),
      .reset_n          (`AXI_OVL_RSTn),
      `AXI_ANTECEDENT   (AWVALID),
      .consequent_expr  (AWLOCK != 2'b11)
      );


  // INDEX:        - AXI_ERRM_AWLOCK_END 
  // =====
  assert_implication #(`AXI_SimError, AXI_ERRM_PropertyType,
    "AXI_ERRM_AWLOCK_END. A master must wait for an unlocked transaction at the end of a locked sequence to complete before issuing another write transaction. Spec: section 6.3 on page 6-7."
  )  axi_errm_awlock_end
     (.clk              (`AXI_OVL_CLK),
      .reset_n          (`AXI_OVL_RSTn),
      `AXI_ANTECEDENT   ((LockState == `AXI_AUX_ST_LOCK_LAST) & // the unlocking transfer has begun and should have completed
                         AWNew                                  // new valid write address
                        ),
      .consequent_expr  (nROutstanding &                        // no outstanding reads
                         nWAddrTrans &                          // no writes other than leading write data (checked separately)
                         !FlagLLInWCam                          // no leading write transactions from previous lock last period
                        )
      );


  // INDEX:        - AXI_ERRM_AWLOCK_ID 
  // =====
  assert_always #(`AXI_SimError, AXI_ERRM_PropertyType,
    "AXI_ERRM_AWLOCK_ID. A sequence of locked transactions must use a single ID. Spec: section 6.3 on page 6-7."
  )  axi_errm_awlock_id
     (.clk        (`AXI_OVL_CLK),
      .reset_n    (`AXI_OVL_RSTn),
      .test_expr  (// case for in lock or going into lock last
                   !(AWNew && (LockState == `AXI_AUX_ST_LOCKED) && // new valid write address in a locked sequence
                    (AWID != LockId)                               // id value does not match current lock id
                   ) &&
                   // case for going into lock from either unlocked or lock last with both a locked read and write
                   !(AWNew && (AWLOCK == `AXI_ALOCK_LOCKED) &&     // new valid locked write
                    ARNew && (ARLOCK == `AXI_ALOCK_LOCKED) &&      // new valid locked read
                    ((LockState == `AXI_AUX_ST_UNLOCKED) ||
                     (LockState == `AXI_AUX_ST_LOCK_LAST)) &&      // in unlocked or lock last state
                    (AWID != ARID)                                 // lock id values do not agree
                   )
                  )
      );


  // INDEX:        - AXI_ERRM_AWLOCK_LAST 
  // =====
  assert_implication #(`AXI_SimError, AXI_ERRM_PropertyType,
    "AXI_ERRM_AWLOCK_LAST. A master must wait for all locked transactions to complete before issuing an unlocking write transaction. Spec: section 6.3 on page 6-7."
  )  axi_errm_awlock_last
     (.clk              (`AXI_OVL_CLK),
      .reset_n          (`AXI_OVL_RSTn),
      `AXI_ANTECEDENT   (AWLockLastNew   // going into lock last with a locked write
                        ),
      .consequent_expr  (nROutstanding & // no outstanding reads
                         nWAddrTrans &   // no writes other than leading write data (checked separately)
                         (WIndex <= 2) & // at most there can only be one leading write transaction
                         ~ARVALID &      // no read activity
                         !FlagLOInWCam   // no leading write transactions from previous locked period
                        )
      );


  // INDEX:        - AXI_ERRM_AWLOCK_START 
  // =====
  assert_implication #(`AXI_SimError, AXI_ERRM_PropertyType,
    "AXI_ERRM_AWLOCK_START. A master must wait for all outstanding transactions to complete before issuing a write transaction which is the first in a locked sequence. Spec: section 6.3 on page 6-7."
  )  axi_errm_awlock_start
     (.clk              (`AXI_OVL_CLK),
      .reset_n          (`AXI_OVL_RSTn),
      `AXI_ANTECEDENT   (AWLockNew                                    // going into locked with a locked write
                        ),
      .consequent_expr  (nROutstanding &                              // no outstanding reads
                         nWAddrTrans &                                // no writes other than leading write data (checked separately)
                         !(ARVALID & (ARLOCK != `AXI_ALOCK_LOCKED)) & // allow a new read but only if it is locked
                         !FlagUNInWCam &                              // no leading write transactions from previous unlocked period
                         !FlagLLInWCam                                // no leading write transactions from previous lock last period
                        )
      );


  // INDEX:        - AXI_ERRM_AWSIZE
  // =====
  // Deliberately keeping AwSizeInBits logic outside of OVL instance, to
  // simplify formal-proofs flow.
  assert_implication #(`AXI_SimError, AXI_ERRM_PropertyType,
    "AXI_ERRM_AWSIZE. The size of a write transfer must not exceed the width of the data port. Spec: section 4.3 on page 4-4."
  )  axi_errm_awsize
     (.clk              (`AXI_OVL_CLK),
      .reset_n          (`AXI_OVL_RSTn),
      `AXI_ANTECEDENT   (AWVALID),
      .consequent_expr  (AwSizeInBits <= DATA_WIDTH)
      );


  // INDEX:        - AXI_ERRM_AWVALID_RESET 
  // =====
  assert_always_on_edge #(`AXI_SimError, 1, AXI_ERRM_PropertyType,
    "AXI_ERRM_AWVALID_RESET. AWVALID must be low in the cycle when ARESETn first goes high. Spec: section 11.1.2 on page 11-2."
  )  axi_errm_awvalid_reset
     (.clk            (`AXI_OVL_CLK),
      .reset_n        (1'b1), // check whilst in reset
      .sampling_event (`AXI_OVL_RSTn),
      .test_expr      (!AWVALID)
      );


  // INDEX:        - AXI_RECM_AWLOCK_BOUNDARY
  // =====
  // 4kbyte boundary: only bottom twelve bits (11 to 0) can change
  assert_implication #(`AXI_SimWarning, AXI_RECM_PropertyType,
    "AXI_RECM_AWLOCK_BOUNDARY. It is recommended that all locked transaction sequences are kept within the same 4KB address region. Spec: section 6.3 on page 6-7."
  )  axi_recm_awlock_boundary
     (.clk              (`AXI_OVL_CLK),
      .reset_n          (`AXI_OVL_RSTn),
      `AXI_ANTECEDENT   (i_RecommendOn                        // Parameter that can disable all AXI_REC*_* rules
                        ),
      .consequent_expr  (// case for in lock or going into lock last
                         !(AWNew && (LockState == `AXI_AUX_ST_LOCKED) && // new valid write address in a locked sequence
                          (AWADDR[ADDR_MAX:12] != LockAddr[ADDR_MAX:12]) // address does not match current lock region
                         ) &&
                         // case for going into lock from either unlocked or lock last with both a locked read and write
                         !(AWNew && (AWLOCK == `AXI_ALOCK_LOCKED) &&     // new valid locked write
                          ARNew && (ARLOCK == `AXI_ALOCK_LOCKED) &&      // new valid locked read
                          ((LockState == `AXI_AUX_ST_UNLOCKED) ||
                           (LockState == `AXI_AUX_ST_LOCK_LAST)) &&      // in unlocked or lock last state
                          (AWADDR[ADDR_MAX:12] != ARADDR[ADDR_MAX:12])   // lock address region values do not agree
                         )
                        )
      );


  // INDEX:        - AXI_RECM_AWLOCK_CTRL  
  // =====
  assert_implication #(`AXI_SimWarning, AXI_RECM_PropertyType,
    "AXI_RECM_AWLOCK_CTRL. It is recommended that a master should not change AxPROT or AxCACHE during a sequence of locked accesses. Spec: section 6.3 on page 6-7."
  )  axi_recm_awlock_ctrl
     (.clk              (`AXI_OVL_CLK),
      .reset_n          (`AXI_OVL_RSTn),
      `AXI_ANTECEDENT   (i_RecommendOn                        // Parameter that can disable all AXI_REC*_* rules
                        ),
      .consequent_expr  (// case for in lock or going into lock last
                         !(AWNew && (LockState == `AXI_AUX_ST_LOCKED) &&   // new valid write address in a locked sequence
                          ((AWPROT != LockProt) || (AWCACHE != LockCache)) // PROT or CACHE values do not match current lock
                         ) &&
                         // case for going into lock from either unlocked or lock last with both a locked read and write
                         !(AWNew && (AWLOCK == `AXI_ALOCK_LOCKED) &&       // new valid locked write
                          ARNew && (ARLOCK == `AXI_ALOCK_LOCKED) &&        // new valid locked read
                          ((LockState == `AXI_AUX_ST_UNLOCKED) ||
                           (LockState == `AXI_AUX_ST_LOCK_LAST)) &&        // in unlocked or lock last state
                          ((AWPROT != ARPROT) || (AWCACHE != ARCACHE))     // lock PROT or CACHE values do not agree
                         )
                        )
      );


  // INDEX:        - AXI_RECM_AWLOCK_NUM
  // =====
  assert_implication #(`AXI_SimWarning, AXI_RECM_PropertyType,
    "AXI_RECM_AWLOCK_NUM. It is recommended that locked transaction sequences are limited to two transactions. Spec: section 6.3 on page 6-7."
  )  axi_recm_awlock_num
     (.clk              (`AXI_OVL_CLK),
      .reset_n          (`AXI_OVL_RSTn),
      `AXI_ANTECEDENT   (i_RecommendOn                        // Parameter that can disable all AXI_REC*_* rules
                        ),
      .consequent_expr  (// case for in lock or going into lock last
                         !(AWNew && (LockState == `AXI_AUX_ST_LOCKED) && // new valid write address in a locked sequence
                          (AWLOCK == `AXI_ALOCK_LOCKED)                  // write is locked
                         ) &&
                         // case for going into lock from either unlocked or lock last with both a locked read and write
                         !(AWNew && (AWLOCK == `AXI_ALOCK_LOCKED) &&     // new valid locked write
                          ARNew && (ARLOCK == `AXI_ALOCK_LOCKED) &&      // new valid locked read
                          ((LockState == `AXI_AUX_ST_UNLOCKED) ||
                           (LockState == `AXI_AUX_ST_LOCK_LAST))         // in unlocked or lock last state
                         )
                        )
      );


//------------------------------------------------------------------------------
// INDEX:   2) Handshake Rules
//------------------------------------------------------------------------------


  // INDEX:        - AXI_ERRM_AWADDR_STABLE
  // =====
  assert_win_unchange #(`AXI_SimError, ADDR_WIDTH, AXI_ERRM_PropertyType,
    "AXI_ERRM_AWADDR_STABLE. AWADDR must remain stable when AWVALID is asserted and AWREADY low. Spec: section 3.1, and figure 3-1, on page 3-2."
  )  axi_errm_awaddr_stable
     (.clk          (`AXI_OVL_CLK),
      .reset_n      (`AXI_OVL_RSTn),
      .start_event  (AWVALID & !AWREADY),
      .test_expr    (AWADDR),
      .end_event    (!(AWVALID & !AWREADY)) // Inverse of start_event
      );


  // INDEX:        - AXI_ERRM_AWBURST_STABLE
  // =====
  assert_win_unchange #(`AXI_SimError, 2, AXI_ERRM_PropertyType,
    "AXI_ERRM_AWBURST_STABLE. AWBURST must remain stable when AWVALID is asserted and AWREADY low. Spec: section 3.1, and figure 3-1, on page 3-2."
  )  axi_errm_awburst_stable
     (.clk          (`AXI_OVL_CLK),
      .reset_n      (`AXI_OVL_RSTn),
      .start_event  (AWVALID & !AWREADY),
      .test_expr    (AWBURST),
      .end_event    (!(AWVALID & !AWREADY)) // Inverse of start_event
      );


  // INDEX:        - AXI_ERRM_AWCACHE_STABLE
  // =====
  assert_win_unchange #(`AXI_SimError, 4, AXI_ERRM_PropertyType,
    "AXI_ERRM_AWCACHE_STABLE. AWCACHE must remain stable when AWVALID is asserted and AWREADY low. Spec: section 3.1, and figure 3-1, on page 3-2."
  )  axi_errm_awcache_stable
     (.clk          (`AXI_OVL_CLK),
      .reset_n      (`AXI_OVL_RSTn),
      .start_event  (AWVALID & !AWREADY),
      .test_expr    (AWCACHE),
      .end_event    (!(AWVALID & !AWREADY)) // Inverse of start_event
      );


  // INDEX:        - AXI_ERRM_AWID_STABLE
  // =====
  assert_win_unchange #(`AXI_SimError, ID_WIDTH, AXI_ERRM_PropertyType,
    "AXI_ERRM_AWID_STABLE. AWID must remain stable when AWVALID is asserted and AWREADY low. Spec: section 3.1, and figure 3-1, on page 3-2."
  )  axi_errm_awid_stable
     (.clk          (`AXI_OVL_CLK),
      .reset_n      (`AXI_OVL_RSTn),
      .start_event  (AWVALID & !AWREADY),
      .test_expr    (AWID),
      .end_event    (!(AWVALID & !AWREADY)) // Inverse of start_event
      );


  // INDEX:        - AXI_ERRM_AWLEN_STABLE
  // =====
  assert_win_unchange #(`AXI_SimError, 4, AXI_ERRM_PropertyType,
    "AXI_ERRM_AWLEN_STABLE. AWLEN must remain stable when AWVALID is asserted and AWREADY low. Spec: section 3.1, and figure 3-1, on page 3-2."
  )  axi_errm_awlen_stable
     (.clk          (`AXI_OVL_CLK),
      .reset_n      (`AXI_OVL_RSTn),
      .start_event  (AWVALID & !AWREADY),
      .test_expr    (AWLEN),
      .end_event    (!(AWVALID & !AWREADY)) // Inverse of start_event
      );


  // INDEX:        - AXI_ERRM_AWLOCK_STABLE
  // =====
  assert_win_unchange #(`AXI_SimError, 2, AXI_ERRM_PropertyType,
    "AXI_ERRM_AWLOCK_STABLE. AWLOCK must remain stable when AWVALID is asserted and AWREADY low. Spec: section 3.1, and figure 3-1, on page 3-2."
  )  axi_errm_awlock_stable
     (.clk          (`AXI_OVL_CLK),
      .reset_n      (`AXI_OVL_RSTn),
      .start_event  (AWVALID & !AWREADY),
      .test_expr    (AWLOCK),
      .end_event    (!(AWVALID & !AWREADY)) // Inverse of start_event
      );


  // INDEX:        - AXI_ERRM_AWPROT_STABLE
  // =====
  assert_win_unchange #(`AXI_SimError, 3, AXI_ERRM_PropertyType,
    "AXI_ERRM_AWPROT_STABLE. AWPROT must remain stable when AWVALID is asserted and AWREADY low. Spec: section 3.1, and figure 3-1, on page 3-2."
  )  axi_errm_awprot_stable
     (.clk          (`AXI_OVL_CLK),
      .reset_n      (`AXI_OVL_RSTn),
      .start_event  (AWVALID & !AWREADY),
      .test_expr    (AWPROT),
      .end_event    (!(AWVALID & !AWREADY)) // Inverse of start_event
      );


  // INDEX:        - AXI_ERRM_AWSIZE_STABLE
  // =====
  assert_win_unchange #(`AXI_SimError, 3, AXI_ERRM_PropertyType,
    "AXI_ERRM_AWSIZE_STABLE. AWSIZE must remain stable when AWVALID is asserted and AWREADY low. Spec: section 3.1, and figure 3-1, on page 3-2."
  )  axi_errm_awsize_stable
     (.clk          (`AXI_OVL_CLK),
      .reset_n      (`AXI_OVL_RSTn),
      .start_event  (AWVALID & !AWREADY),
      .test_expr    (AWSIZE),
      .end_event    (!(AWVALID & !AWREADY)) // Inverse of start_event
      );


  // INDEX:        - AXI_ERRM_AWVALID_STABLE
  // =====
  assert_next #(`AXI_SimError, 1, 1, 0, AXI_ERRM_PropertyType,
    "AXI_ERRM_AWVALID_STABLE. Once AWVALID is asserted, it must remain asserted until AWREADY is high. Spec: section 3.1.1 on page 3-2."
  )  axi_errm_awvalid_stable
     (.clk         (`AXI_OVL_CLK),
      .reset_n     (`AXI_OVL_RSTn),
      .start_event (AWVALID & !AWREADY),
      .test_expr   (AWVALID)
      );


  // INDEX:        - AXI_RECS_AWREADY_MAX_WAIT 
  // =====
  // Note: this rule does not error if VALID goes low (breaking VALID_STABLE rule)
  assert_frame #(`AXI_SimWarning, 0, MAXWAITS, 0, AXI_RECS_PropertyType,
    "AXI_RECS_AWREADY_MAX_WAIT. AWREADY should be asserted within MAXWAITS cycles of AWVALID being asserted."
  )  axi_recs_awready_max_wait
     (.clk         (`AXI_OVL_CLK),
      .reset_n     (`AXI_OVL_RSTn),
      .start_event (i_RecommendOn  &       // Parameter that can disable all  AXI_REC*_* rules
                    i_RecMaxWaitOn &       // Parameter that can disable just AXI_REC*_MAX_WAIT rules
                   !AWREADY &  AWVALID),
      .test_expr   (AWREADY | !AWVALID)    // READY=1 within MAXWAITS cycles (or VALID=0)
      );


//------------------------------------------------------------------------------
// INDEX:   3) X-Propagation Rules
//------------------------------------------------------------------------------
`ifdef AXI_XCHECK_OFF
`else  // X-Checking on by default


  // INDEX:        - AXI_ERRM_AWADDR_X 
  // =====
  assert_never_unknown #(`AXI_SimError, ADDR_WIDTH, AXI_ERRM_PropertyType,
    "AXI_ERRM_AWADDR_X. When AWVALID is high, a value of X on AWADDR is not permitted. Spec: section 3.1.1 on page 3-3."
  )  axi_errm_awaddr_x
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .qualifier (AWVALID),
      .test_expr (AWADDR)
      );


  // INDEX:        - AXI_ERRM_AWBURST_X
  // =====
  assert_never_unknown #(`AXI_SimError, 2, AXI_ERRM_PropertyType,
    "AXI_ERRM_AWBURST_X. When AWVALID is high, a value of X on AWBURST is not permitted. Spec: section 3.1.1 on page 3-3."
  )  axi_errm_awburst_x
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .qualifier (AWVALID),
      .test_expr (AWBURST)
      );


  // INDEX:        - AXI_ERRM_AWCACHE_X
  // =====
  assert_never_unknown #(`AXI_SimError, 4, AXI_ERRM_PropertyType,
    "AXI_ERRM_AWCACHE_X. When AWVALID is high, a value of X on AWCACHE is not permitted. Spec: section 3.1.1 on page 3-3."
  )  axi_errm_awcache_x
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .qualifier (AWVALID),
      .test_expr (AWCACHE)
      );


  // INDEX:        - AXI_ERRM_AWID_X
  // =====
  assert_never_unknown #(`AXI_SimError, ID_WIDTH, AXI_ERRM_PropertyType,
    "AXI_ERRM_AWID_X. When AWVALID is high, a value of X on AWID is not permitted. Spec: section 3.1.1 on page 3-3."
  )  axi_errm_awid_x
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .qualifier (AWVALID),
      .test_expr (AWID)
      );


  // INDEX:        - AXI_ERRM_AWLEN_X
  // =====
  assert_never_unknown #(`AXI_SimError, 4, AXI_ERRM_PropertyType,
    "AXI_ERRM_AWLEN_X. When AWVALID is high, a value of X on AWLEN is not permitted. Spec: section 3.1.1 on page 3-3."
  )  axi_errm_awlen_x
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .qualifier (AWVALID),
      .test_expr (AWLEN)
      );


  // INDEX:        - AXI_ERRM_AWLOCK_X
  // =====
  assert_never_unknown #(`AXI_SimError, 2, AXI_ERRM_PropertyType,
    "AXI_ERRM_AWLOCK_X. When AWVALID is high, a value of X on AWLOCK is not permitted. Spec: section 3.1.1 on page 3-3."
  )  axi_errm_awlock_x
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .qualifier (AWVALID),
      .test_expr (AWLOCK)
      );


  // INDEX:        - AXI_ERRM_AWPROT_X
  // =====
  assert_never_unknown #(`AXI_SimError, 3, AXI_ERRM_PropertyType,
    "AXI_ERRM_AWPROT_X. When AWVALID is high, a value of X on AWPROT is not permitted. Spec: section 3.1.1 on page 3-3."
  )  axi_errm_awprot_x
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .qualifier (AWVALID),
      .test_expr (AWPROT)
      );


  // INDEX:        - AXI_ERRM_AWSIZE_X
  // =====
  assert_never_unknown #(`AXI_SimError, 3, AXI_ERRM_PropertyType,
    "AXI_ERRM_AWSIZE_X. When AWVALID is high, a value of X on AWSIZE is not permitted. Spec: section 3.1.1 on page 3-3."
  )  axi_errm_awsize_x
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .qualifier (AWVALID),
      .test_expr (AWSIZE)
      );


  // INDEX:        - AXI_ERRM_AWVALID_X
  // =====
  assert_never_unknown #(`AXI_SimError, 1, AXI_ERRM_PropertyType,
    "AXI_ERRM_AWVALID_X. When not in reset, a value of X on AWVALID is not permitted."
  )  axi_errm_awvalid_x
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .qualifier (1'b1),
      .test_expr (AWVALID)
      );


  // INDEX:        - AXI_ERRS_AWREADY_X
  // =====
  assert_never_unknown #(`AXI_SimError, 1, AXI_ERRS_PropertyType,
    "AXI_ERRS_AWREADY_X. When not in reset, a value of X on AWREADY is not permitted."
  )  axi_errs_awready_x
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .qualifier (1'b1),
      .test_expr (AWREADY)
      );

`endif // AXI_XCHECK_OFF


//------------------------------------------------------------------------------
// INDEX:
// INDEX: AXI Rules: Write Data Channel (*_W*)
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// INDEX:   1) Functional Rules
//------------------------------------------------------------------------------


  // INDEX:        - AXI_ERRM_WDATA_NUM
  // =====
  // This will fire in one of the following situations:
  // 1) Write data arrives and WLAST set and WDATA count is not equal to AWLEN
  // 2) Write data arrives and WLAST not set and WDATA count is equal to AWLEN
  // 3) ADDR arrives, WLAST already received and WDATA count not equal to AWLEN
  assert_always #(`AXI_SimError, AXI_ERRM_PropertyType,
    "AXI_ERRM_WDATA_NUM. The number of write data items must match AWLEN for the corresponding address. Spec: table 4-1 on page 4-3."
  )  axi_errm_wdata_num
     (.clk        (`AXI_OVL_CLK),
      .reset_n    (`AXI_OVL_RSTn),
      .test_expr  (~WriteDataNumError)
      );


  // INDEX:        - AXI_ERRM_WDATA_ORDER
  // =====
  assert_always #(`AXI_SimError, AXI_ERRM_PropertyType,
    "AXI_ERRM_WDATA_ORDER. The order in which addresses and the first write data item are produced must match. Spec: section 8.5 on page 8-6."
  )  axi_errm_wdata_order
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .test_expr (~WDataOrderError)
      );


  // INDEX:        - AXI_ERRM_WDEPTH 
  // =====
  assert_implication #(`AXI_SimError, AXI_ERRM_PropertyType,
    "AXI_ERRM_WDEPTH. A master can interleave a maximum of WDEPTH write data bursts. Spec: section 8.5 on page 8-6."
  )  axi_errm_wdepth
     (.clk              (`AXI_OVL_CLK),
      .reset_n          (`AXI_OVL_RSTn),
      `AXI_ANTECEDENT   (WVALID & WREADY),
      .consequent_expr  (WidDepth <= WDEPTH)
      );


  // INDEX:        - AXI_ERRM_WSTRB
  // =====
  assert_always #(`AXI_SimError, AXI_ERRM_PropertyType,
    "AXI_ERRM_WSTRB. Write strobes must only be asserted for the correct byte lanes as determined from start address, transfer size and beat number. Spec: section 9.2 on page 9-3."
  )  axi_errm_wstrb
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .test_expr (~StrbError)
      );


  // INDEX:        - AXI_ERRM_WVALID_RESET
  // =====
  assert_always_on_edge #(`AXI_SimError, 1, AXI_ERRM_PropertyType,
    "AXI_ERRM_WVALID_RESET. WVALID must be low in the cycle when ARESETn first goes high. Spec: section 11.1.2 on page 11-2."
  )  axi_errm_wvalid_reset
     (.clk            (`AXI_OVL_CLK),
      .reset_n        (1'b1), // check whilst in reset
      .sampling_event (`AXI_OVL_RSTn),
      .test_expr      (!WVALID)
      );


//------------------------------------------------------------------------------
// INDEX:   2) Handshake Rules
//------------------------------------------------------------------------------


  // INDEX:        - AXI_ERRM_WDATA_STABLE
  // =====
  assert_win_unchange #(`AXI_SimError, DATA_WIDTH, AXI_ERRM_PropertyType,
    "AXI_ERRM_WDATA_STABLE. WDATA must remain stable when WVALID is asserted and WREADY low. Spec: section 3.1, and figure 3-1, on page 3-2."
  )  axi_errm_wdata_stable
     (.clk         (`AXI_OVL_CLK),
      .reset_n     (`AXI_OVL_RSTn),
      .start_event (WVALID & !WREADY),
      .test_expr   (WDATA & WdataMask),
      .end_event   (!(WVALID & !WREADY)) // Inverse of start_event
      );


  // INDEX:        - AXI_ERRM_WID_STABLE
  // =====
  assert_win_unchange #(`AXI_SimError, ID_WIDTH, AXI_ERRM_PropertyType,
    "AXI_ERRM_WID_STABLE. WID must remain stable when WVALID is asserted and WREADY low. Spec: section 3.1, and figure 3-1, on page 3-2."
  )  axi_errm_wid_stable
     (.clk         (`AXI_OVL_CLK),
      .reset_n     (`AXI_OVL_RSTn),
      .start_event (WVALID & !WREADY),
      .test_expr   (WID),
      .end_event   (!(WVALID & !WREADY)) // Inverse of start_event
      );


  // INDEX:        - AXI_ERRM_WLAST_STABLE
  // =====
  assert_win_unchange #(`AXI_SimError, 1, AXI_ERRM_PropertyType,
    "AXI_ERRM_WLAST_STABLE. WLAST must remain stable when WVALID is asserted and WREADY low. Spec: section 3.1, and figure 3-1, on page 3-2."
  )  axi_errm_wlast_stable
     (.clk         (`AXI_OVL_CLK),
      .reset_n     (`AXI_OVL_RSTn),
      .start_event (WVALID & !WREADY),
      .test_expr   (WLAST),
      .end_event   (!(WVALID & !WREADY)) // Inverse of start_event
      );


  // INDEX:        - AXI_ERRM_WSTRB_STABLE
  // =====
  assert_win_unchange #(`AXI_SimError, STRB_WIDTH, AXI_ERRM_PropertyType,
    "AXI_ERRM_WSTRB_STABLE. WSTRB must remain stable when WVALID is asserted and WREADY low. Spec: section 3.1, and figure 3-1, on page 3-2."
  )  axi_errm_wstrb_stable
     (.clk         (`AXI_OVL_CLK),
      .reset_n     (`AXI_OVL_RSTn),
      .start_event (WVALID & !WREADY),
      .test_expr   (WSTRB),
      .end_event   (!(WVALID & !WREADY)) // Inverse of start_event
      );


  // INDEX:        - AXI_ERRM_WVALID_STABLE
  // =====
  assert_next #(`AXI_SimError, 1, 1, 0, AXI_ERRM_PropertyType,
    "AXI_ERRM_WVALID_STABLE. Once WVALID is asserted, it must remain asserted until WREADY is high. Spec: section 3.1.2 on page 3-4."
  )  axi_errm_wvalid_stable
     (.clk          (`AXI_OVL_CLK),
      .reset_n      (`AXI_OVL_RSTn),
      .start_event  (WVALID & !WREADY),
      .test_expr    (WVALID)
      );


  // INDEX:        - AXI_RECS_WREADY_MAX_WAIT  
  // =====
  // Note: this rule does not error if VALID goes low (breaking VALID_STABLE rule)
  assert_frame #(`AXI_SimWarning, 0, MAXWAITS, 0, AXI_RECS_PropertyType,
    "AXI_RECS_WREADY_MAX_WAIT. WREADY should be asserted within MAXWAITS cycles of WVALID being asserted."
  )  axi_recs_wready_max_wait
     (.clk         (`AXI_OVL_CLK),
      .reset_n     (`AXI_OVL_RSTn),
      .start_event (i_RecommendOn  &       // Parameter that can disable all  AXI_REC*_* rules
                    i_RecMaxWaitOn &       // Parameter that can disable just AXI_REC*_MAX_WAIT rules
                   !WREADY &  WVALID),
      .test_expr   (WREADY | !WVALID)      // READY=1 within MAXWAITS cycles (or VALID=0)
      );


//------------------------------------------------------------------------------
// INDEX:   3) X-Propagation Rules
//------------------------------------------------------------------------------
`ifdef AXI_XCHECK_OFF
`else  // X-Checking on by default


  // INDEX:        - AXI_ERRM_WDATA_X
  // =====
  assert_never_unknown #(`AXI_SimError, DATA_WIDTH, AXI_ERRM_PropertyType,
    "AXI_ERRM_WDATA_X. When WVALID is high, a value of X on active byte lanes of WDATA is not permitted."
  )  axi_errm_wdata_x
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .qualifier (WVALID),
      .test_expr (WDATA & WdataMask)
      );


  // INDEX:        - AXI_ERRM_WID_X
  // =====
  assert_never_unknown #(`AXI_SimError, ID_WIDTH, AXI_ERRM_PropertyType,
    "AXI_ERRM_WID_X. When WVALID is high, a value of X on WID is not permitted. Spec: section 3.1.2 on page 3-4."
  )  axi_errm_wid_x
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .qualifier (WVALID),
      .test_expr (WID)
      );


  // INDEX:        - AXI_ERRM_WLAST_X
  // =====
  assert_never_unknown #(`AXI_SimError, 1, AXI_ERRM_PropertyType,
    "AXI_ERRM_WLAST_X. When WVALID is high, a value of X on WLAST is not permitted."
  )  axi_errm_wlast_x
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .qualifier (WVALID),
      .test_expr (WLAST)
      );


  // INDEX:        - AXI_ERRM_WSTRB_X
  // =====
  assert_never_unknown #(`AXI_SimError, STRB_WIDTH, AXI_ERRM_PropertyType,
    "AXI_ERRM_WSTRB_X. When WVALID is high, a value of X on WSTRB is not permitted."
  )  axi_errm_wstrb_x
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .qualifier (WVALID),
      .test_expr (WSTRB)
      );


  // INDEX:        - AXI_ERRM_WVALID_X
  // =====
  assert_never_unknown #(`AXI_SimError, 1, AXI_ERRM_PropertyType,
    "AXI_ERRM_WVALID_X. When not in reset, a value of X on WVALID is not permitted."
  )  axi_errm_wvalid_x
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .qualifier (1'b1),
      .test_expr (WVALID)
      );


  // INDEX:        - AXI_ERRS_WREADY_X
  // =====
  assert_never_unknown #(`AXI_SimError, 1, AXI_ERRS_PropertyType,
    "AXI_ERRS_WREADY_X. When not in reset, a value of X on WREADY is not permitted."
  )  axi_errs_wready_x
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .qualifier (1'b1),
      .test_expr (WREADY)
      );

`endif // AXI_XCHECK_OFF


//------------------------------------------------------------------------------
// INDEX:
// INDEX: AXI Rules: Write Response Channel (*_B*)
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// INDEX:   1) Functional Rules
//------------------------------------------------------------------------------


  // INDEX:        - AXI_ERRS_BRESP 
  // =====
  assert_always #(`AXI_SimError, AXI_ERRS_PropertyType,
    "AXI_ERRS_BRESP. A slave must only give a write response after the last write data item is transferred. Spec: section 3.3 on page 3-7, and figure 3-5 on page 3-8."
  )  axi_errs_bresp
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .test_expr (~BrespError)
      );


  // INDEX:        - AXI_ERRS_BRESP_ALL_DONE_EOS
  // =====
  // EOS: End-Of-Simulation check (not suitable for formal proofs).
  // Use +define+OVL_END_OF_SIMULATION=tb.EOS_signal when compiling.
`ifdef AXI_END_OF_SIMULATION
  assert_quiescent_state #(`AXI_SimError, 1, AXI_ERRS_PropertyType,
    "AXI_ERRS_BRESP_ALL_DONE_EOS. All write transaction addresses must have been matched with corresponding write response."
  )  axi_errs_bresp_all_done_eos
     (.clk          (`AXI_OVL_CLK),
      .reset_n      (`AXI_OVL_RSTn),
      .state_expr   (WIndex == 1),
      .check_value  (1'b1),
      .sample_event (1'b0)
      );
`endif


  // INDEX:        - AXI_ERRS_BRESP_EXOKAY
  // =====
  assert_always #(`AXI_SimError, AXI_ERRS_PropertyType,
    "AXI_ERRS_BRESP_EXOKAY. An EXOKAY write response can only be given to an exclusive write access. Spec: section 6.2.3 on page 6-4."
  )  axi_errs_bresp_exokay
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .test_expr (~BrespExokError)
      );


  // INDEX:        - AXI_ERRS_BVALID_RESET
  // =====
  assert_always_on_edge #(`AXI_SimError, 1, AXI_ERRS_PropertyType,
    "AXI_ERRS_BVALID_RESET. BVALID must be low in the cycle when ARESETn first goes high. Spec: section 11.1.2 on page 11-2."
  )  axi_errs_bvalid_reset
     (.clk            (`AXI_OVL_CLK),
      .reset_n        (1'b1), // check whilst in reset
      .sampling_event (`AXI_OVL_RSTn),
      .test_expr      (!BVALID)
      );


  // INDEX:        - AXI_RECS_BRESP 
  // =====
  assert_always #(`AXI_SimWarning, AXI_RECS_PropertyType,
    "AXI_RECS_BRESP. A slave should not give a write response before the write address. ARM FAQs: 11424"
  )  axi_recs_bresp
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .test_expr (!(i_RecommendOn && BrespLeadingRec))
      );


//------------------------------------------------------------------------------
// INDEX:   2) Handshake Rules
//------------------------------------------------------------------------------


  // INDEX:        - AXI_ERRS_BID_STABLE
  // =====
  assert_win_unchange #(`AXI_SimError, ID_WIDTH, AXI_ERRS_PropertyType,
    "AXI_ERRS_BID_STABLE. BID must remain stable when BVALID is asserted and BREADY low. Spec: section 3.1, and figure 3-1, on page 3-2."
  )  axi_errs_bid_stable
     (.clk          (`AXI_OVL_CLK),
      .reset_n      (`AXI_OVL_RSTn),
      .start_event  (BVALID & !BREADY),
      .test_expr    (BID),
      .end_event    (!(BVALID & !BREADY)) // Inverse of start_event
      );


  // INDEX:        - AXI_ERRS_BRESP_STABLE
  // =====
  assert_win_unchange #(`AXI_SimError, 2, AXI_ERRS_PropertyType,
    "AXI_ERRS_BRESP_STABLE. BRESP must remain stable when BVALID is asserted and BREADY low. Spec: section 3.1, and figure 3-1, on page 3-2."
  )  axi_errs_bresp_stable
     (.clk          (`AXI_OVL_CLK),
      .reset_n      (`AXI_OVL_RSTn),
      .start_event  (BVALID & !BREADY),
      .test_expr    (BRESP),
      .end_event    (!(BVALID & !BREADY)) // Inverse of start_event
      );


  // INDEX:        - AXI_ERRS_BVALID_STABLE
  // =====
  assert_next #(`AXI_SimError, 1, 1, 0, AXI_ERRS_PropertyType,
    "AXI_ERRS_BVALID_STABLE. Once BVALID is asserted, it must remain asserted until BREADY is high. Spec: section 3.1.3 on page 3-4."
  )  axi_errs_bvalid_stable
     (.clk           (`AXI_OVL_CLK),
      .reset_n       (`AXI_OVL_RSTn),
      .start_event   (BVALID & !BREADY),
      .test_expr     (BVALID)
      );


  // INDEX:        - AXI_RECM_BREADY_MAX_WAIT  
  // =====
  // Note: this rule does not error if VALID goes low (breaking VALID_STABLE rule)
  assert_frame #(`AXI_SimWarning, 0, MAXWAITS, 0, AXI_RECM_PropertyType,
    "AXI_RECM_BREADY_MAX_WAIT. BREADY should be asserted within MAXWAITS cycles of BVALID being asserted."
  )  axi_recm_bready_max_wait
     (.clk         (`AXI_OVL_CLK),
      .reset_n     (`AXI_OVL_RSTn),
      .start_event (i_RecommendOn  &       // Parameter that can disable all  AXI_REC*_* rules
                    i_RecMaxWaitOn &       // Parameter that can disable just AXI_REC*_MAX_WAIT rules
                   !BREADY &  BVALID),
      .test_expr   (BREADY | !BVALID)      // READY=1 within MAXWAITS cycles (or VALID=0)
      );


//------------------------------------------------------------------------------
// INDEX:   3) X-Propagation Rules
//------------------------------------------------------------------------------
`ifdef AXI_XCHECK_OFF
`else  // X-Checking on by default


  // INDEX:        - AXI_ERRM_BREADY_X
  // =====
  assert_never_unknown #(`AXI_SimError, 1, AXI_ERRM_PropertyType,
    "AXI_ERRM_BREADY_X. When not in reset, a value of X on BREADY is not permitted."
  )  axi_errm_bready_x
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .qualifier (1'b1),
      .test_expr (BREADY)
      );


  // INDEX:        - AXI_ERRS_BID_X
  // =====
  assert_never_unknown #(`AXI_SimError, ID_WIDTH, AXI_ERRS_PropertyType,
    "AXI_ERRS_BID_X. When BVALID is high, a value of X on BID is not permitted."
  )  axi_errs_bid_x
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .qualifier (BVALID),
      .test_expr (BID)
      );


  // INDEX:        - AXI_ERRS_BRESP_X
  // =====
  assert_never_unknown #(`AXI_SimError, 2, AXI_ERRS_PropertyType,
    "AXI_ERRS_BRESP_X. When BVALID is high, a value of X on BRESP is not permitted.  Spec: section 3.1.3 on page 3-4."
  )  axi_errs_bresp_x
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .qualifier (BVALID),
      .test_expr (BRESP)
      );


  // INDEX:        - AXI_ERRS_BVALID_X
  // =====
  assert_never_unknown #(`AXI_SimError, 1, AXI_ERRS_PropertyType,
    "AXI_ERRS_BVALID_X. When not in reset, a value of X on BVALID is not permitted."
  )  axi_errs_bvalid_x
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .qualifier (1'b1),
      .test_expr (BVALID)
      );

`endif // AXI_XCHECK_OFF


//------------------------------------------------------------------------------
// INDEX:
// INDEX: AXI Rules: Read Address Channel (*_AR*)
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// INDEX:   1) Functional Rules
//------------------------------------------------------------------------------


  // INDEX:        - AXI_ERRM_ARADDR_BOUNDARY 
  // =====
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
  assert_implication #(`AXI_SimError, AXI_ERRM_PropertyType,
    "AXI_ERRM_ARADDR_BOUNDARY. A read burst cannot cross a 4kbyte boundary. Spec: section 4.1 on page 4-2."
  )  axi_errm_araddr_boundary
     (.clk              (`AXI_OVL_CLK),
      .reset_n          (`AXI_OVL_RSTn),
      `AXI_ANTECEDENT   (ARVALID & (ARBURST == `AXI_ABURST_INCR)),
      .consequent_expr  (ArAddrIncr[ADDR_MAX:12] == ARADDR[ADDR_MAX:12])
      );


  // INDEX:        - AXI_ERRM_ARADDR_WRAP_ALIGN
  // =====
  assert_implication #(`AXI_SimError, AXI_ERRM_PropertyType,
    "AXI_ERRM_ARADDR_WRAP_ALIGN. A read transaction with burst type WRAP must have an aligned address. Spec: section 4.4.3 on page 4-6."
  )  axi_errm_araddr_wrap_align
     (.clk              (`AXI_OVL_CLK),
      .reset_n          (`AXI_OVL_RSTn),
      `AXI_ANTECEDENT   (ARVALID & (ARBURST == `AXI_ABURST_WRAP)),
      .consequent_expr  ((ARADDR[6:0] & AlignMaskR) == ARADDR[6:0])
   );


  // INDEX:        - AXI_ERRM_ARBURST
  // =====
  assert_implication #(`AXI_SimError, AXI_ERRM_PropertyType,
    "AXI_ERRM_ARBURST. When ARVALID is high, a value of 2'b11 on ARBURST is not permitted. Spec: table 4-3 on page 4-5."
  )  axi_errm_arburst
     (.clk              (`AXI_OVL_CLK),
      .reset_n          (`AXI_OVL_RSTn),
      `AXI_ANTECEDENT   (ARVALID),
      .consequent_expr  (ARBURST != 2'b11)
      );


  // INDEX:        - AXI_ERRM_ARCACHE
  // =====
  assert_implication #(`AXI_SimError, AXI_ERRM_PropertyType,
    "AXI_ERRM_ARCACHE. When ARVALID is high, if ARCACHE[1] is low then ARCACHE[3] and ARCACHE[2] must also be low. Spec: table 5-1 on page 5-3."
  )  axi_errm_arcache
     (.clk              (`AXI_OVL_CLK),
      .reset_n          (`AXI_OVL_RSTn),
      `AXI_ANTECEDENT   (ARVALID & ~ARCACHE[1]),
      .consequent_expr  (ARCACHE[3:2] == 2'b00)
      );


  // INDEX:        - AXI_ERRM_ARLEN_WRAP
  // =====
  assert_implication #(`AXI_SimError, AXI_ERRM_PropertyType,
    "AXI_ERRM_ARLEN_WRAP. A read transaction with burst type WRAP must have length 2, 4, 8 or 16. Spec: section 4.4.3 on page 4-6."
  )  axi_errm_arlen_wrap
     (.clk              (`AXI_OVL_CLK),
      .reset_n          (`AXI_OVL_RSTn),
      `AXI_ANTECEDENT   (ARVALID & (ARBURST == `AXI_ABURST_WRAP)),
      .consequent_expr  (ARLEN == `AXI_ALEN_2 ||
                         ARLEN == `AXI_ALEN_4 ||
                         ARLEN == `AXI_ALEN_8 ||
                         ARLEN == `AXI_ALEN_16)
      );


  // INDEX:        - AXI_ERRM_ARLOCK
  // =====
  assert_implication #(`AXI_SimError, AXI_ERRM_PropertyType,
    "AXI_ERRM_ARLOCK. When ARVALID is high, a value of 2'b11 on ARLOCK is not permitted. Spec: table 6-1 on page 6-2."
  )  axi_errm_arlock
     (.clk              (`AXI_OVL_CLK),
      .reset_n          (`AXI_OVL_RSTn),
      `AXI_ANTECEDENT   (ARVALID),
      .consequent_expr  (ARLOCK != 2'b11)
      );


  // INDEX:        - AXI_ERRM_ARLOCK_END 
  // =====
  assert_implication #(`AXI_SimError, AXI_ERRM_PropertyType,
    "AXI_ERRM_ARLOCK_END. A master must wait for an unlocked transaction at the end of a locked sequence to complete before issuing another read transaction. Spec: section 6.3 on page 6-7."
  )  axi_errm_arlock_end
     (.clk              (`AXI_OVL_CLK),
      .reset_n          (`AXI_OVL_RSTn),
      `AXI_ANTECEDENT   ((LockState == `AXI_AUX_ST_LOCK_LAST) & // the unlocking transfer has begun and should have completed
                         ARNew                                  // new valid read address
                        ),
      .consequent_expr  (nROutstanding &                        // no outstanding reads
                         nWAddrTrans &                          // no writes other than leading write data (checked separately)
                         !FlagLLInWCam                          // no leading write transactions from previous lock last period
                        )
      );


  // INDEX:        - AXI_ERRM_ARLOCK_ID
  // =====
  assert_always #(`AXI_SimError, AXI_ERRM_PropertyType,
    "AXI_ERRM_ARLOCK_ID. A sequence of locked transactions must use a single ID. Spec: section 6.3 on page 6-7."
  )  axi_errm_arlock_id
     (.clk        (`AXI_OVL_CLK),
      .reset_n    (`AXI_OVL_RSTn),
      .test_expr  (// case for in lock or going into lock last
                   !(ARNew && (LockState == `AXI_AUX_ST_LOCKED) && // new valid read address in a locked sequence
                    (ARID != LockId)                               // id value does not match current lock id
                   ) &&
                   // case for going into lock from either unlocked or lock last with both a locked read and write
                   !(AWNew && (AWLOCK == `AXI_ALOCK_LOCKED) &&     // new valid locked write
                    ARNew && (ARLOCK == `AXI_ALOCK_LOCKED) &&      // new valid locked read
                    ((LockState == `AXI_AUX_ST_UNLOCKED) ||
                     (LockState == `AXI_AUX_ST_LOCK_LAST)) &&      // in unlocked or lock last state
                    (AWID != ARID)                                 // lock id values do not agree
                   )
                  )
      );


  // INDEX:        - AXI_ERRM_ARLOCK_LAST 
  // =====
  assert_implication #(`AXI_SimError, AXI_ERRM_PropertyType,
    "AXI_ERRM_ARLOCK_LAST. A master must wait for all locked transactions to complete before issuing an unlocking read transaction. Spec: section 6.3 on page 6-7."
  )  axi_errm_arlock_last
     (.clk              (`AXI_OVL_CLK),
      .reset_n          (`AXI_OVL_RSTn),
      `AXI_ANTECEDENT   (ARLockLastNew        // going into lock last with a locked read
                        ),
      .consequent_expr  (nROutstanding &      // no outstanding reads
                         (WIndex == 1) &      // no writes (including leading write data)
                         ~AWVALID & ~WVALID & // no activity on write channels
                         !FlagLOInWCam        // no leading write transactions from previous locked period
                        )
      );


  // INDEX:        - AXI_ERRM_ARLOCK_START 
  // =====
  assert_implication #(`AXI_SimError, AXI_ERRM_PropertyType,
    "AXI_ERRM_ARLOCK_START. A master must wait for all outstanding transactions to complete before issuing a read transaction which is the first in a locked sequence. Spec: section 6.3 on page 6-7."
  )  axi_errm_arlock_start
     (.clk              (`AXI_OVL_CLK),
      .reset_n          (`AXI_OVL_RSTn),
      `AXI_ANTECEDENT   (ARLockNew                                    // going into locked with a locked read
                        ),
      .consequent_expr  (nROutstanding &                              // no outstanding reads
                         nWAddrTrans &                                // no writes other than leading write data (checked separately)
                         !(AWVALID & (AWLOCK != `AXI_ALOCK_LOCKED)) & // allow a new write but only if it is locked
                         !FlagUNInWCam &                              // no leading write transactions from previous unlocked period
                         !FlagLLInWCam                                // no leading write transactions from previous lock last period
                        )
      );


  // INDEX:        - AXI_ERRM_ARSIZE
  // =====
  assert_implication #(`AXI_SimError, AXI_ERRM_PropertyType,
    "AXI_ERRM_ARSIZE. The size of a read transfer must not exceed the width of the data port. Spec: section 4.3 on page 4-4."
  )  axi_errm_arsize
     (.clk              (`AXI_OVL_CLK),
      .reset_n          (`AXI_OVL_RSTn),
      `AXI_ANTECEDENT   (ARVALID),
      .consequent_expr  (ArSizeInBits <= DATA_WIDTH)
      );


  // INDEX:        - AXI_ERRM_ARVALID_RESET
  // =====
  assert_always_on_edge #(`AXI_SimError, 1, AXI_ERRM_PropertyType,
    "AXI_ERRM_ARVALID_RESET. ARVALID must be low in the cycle when ARESETn first goes high. Spec: section 11.1.2 on page 11-2."
  )  axi_errm_arvalid_reset
     (.clk            (`AXI_OVL_CLK),
      .reset_n        (1'b1), // check whilst in reset
      .sampling_event (`AXI_OVL_RSTn),
      .test_expr      (!ARVALID)
      );


  // INDEX:        - AXI_RECM_ARLOCK_BOUNDARY
  // =====
  // 4kbyte boundary: only bottom twelve bits (11 to 0) can change
  assert_implication #(`AXI_SimWarning, AXI_RECM_PropertyType,
    "AXI_RECM_ARLOCK_BOUNDARY. It is recommended that all locked transaction sequences are kept within the same 4KB address region. Spec: section 6.3 on page 6-7."
  )  axi_recm_arlock_boundary
     (.clk              (`AXI_OVL_CLK),
      .reset_n          (`AXI_OVL_RSTn),
      `AXI_ANTECEDENT   (i_RecommendOn                        // Parameter that can disable all AXI_REC*_* rules
                        ),
      .consequent_expr  (// case for in lock or going into lock last
                         !(ARNew && (LockState == `AXI_AUX_ST_LOCKED) && // new valid read address in a locked sequence
                          (ARADDR[ADDR_MAX:12] != LockAddr[ADDR_MAX:12]) // address does not match current lock region
                         ) &&
                         // case for going into lock from either unlocked or lock last with both a locked read and write
                         !(AWNew && (AWLOCK == `AXI_ALOCK_LOCKED) &&     // new valid locked write
                          ARNew && (ARLOCK == `AXI_ALOCK_LOCKED) &&      // new valid locked read
                          ((LockState == `AXI_AUX_ST_UNLOCKED) ||
                           (LockState == `AXI_AUX_ST_LOCK_LAST)) &&      // in unlocked or lock last state
                          (AWADDR[ADDR_MAX:12] != ARADDR[ADDR_MAX:12])   // lock address region values do not agree
                         )
                        )
      );


  // INDEX:        - AXI_RECM_ARLOCK_CTRL 
  // =====
  assert_implication #(`AXI_SimWarning, AXI_RECM_PropertyType,
    "AXI_RECM_ARLOCK_CTRL. It is recommended that a master should not change AxPROT or AxCACHE during a sequence of locked accesses. Spec: section 6.3 on page 6-7."
  )  axi_recm_arlock_ctrl
     (.clk              (`AXI_OVL_CLK),
      .reset_n          (`AXI_OVL_RSTn),
      `AXI_ANTECEDENT   (i_RecommendOn                        // Parameter that can disable all AXI_REC*_* rules
                        ),
      .consequent_expr  (// case for in lock or going into lock last
                         !(ARNew && (LockState == `AXI_AUX_ST_LOCKED) &&   // new valid read address in a locked sequence
                          ((ARPROT != LockProt) || (ARCACHE != LockCache)) // PROT or CACHE values do not match current lock
                         ) &&
                         // case for going into lock from either unlocked or lock last with both a locked read and write
                         !(AWNew && (AWLOCK == `AXI_ALOCK_LOCKED) &&       // new valid locked write
                          ARNew && (ARLOCK == `AXI_ALOCK_LOCKED) &&        // new valid locked read
                          ((LockState == `AXI_AUX_ST_UNLOCKED) ||
                           (LockState == `AXI_AUX_ST_LOCK_LAST)) &&        // in unlocked or lock last state
                          ((AWPROT != ARPROT) || (AWCACHE != ARCACHE))     // lock PROT or CACHE values do not agree
                         )
                        )
      );


  // INDEX:        - AXI_RECM_ARLOCK_NUM
  // =====
  assert_implication #(`AXI_SimWarning, AXI_RECM_PropertyType,
    "AXI_RECM_ARLOCK_NUM. It is recommended that locked transaction sequences are limited to two transactions. Spec: section 6.3 on page 6-7."
  )  axi_recm_arlock_num
     (.clk              (`AXI_OVL_CLK),
      .reset_n          (`AXI_OVL_RSTn),
      `AXI_ANTECEDENT   (i_RecommendOn                        // Parameter that can disable all AXI_REC*_* rules
                        ),
      .consequent_expr  (// case for in lock or going into lock last
                         !(ARNew && (LockState == `AXI_AUX_ST_LOCKED) && // new valid read address in a locked sequence
                          (ARLOCK == `AXI_ALOCK_LOCKED)                  // read is locked
                         ) &&
                         // case for going into lock from either unlocked or lock last with both a locked read and write
                         !(AWNew && (AWLOCK == `AXI_ALOCK_LOCKED) &&     // new valid locked write
                          ARNew && (ARLOCK == `AXI_ALOCK_LOCKED) &&      // new valid locked read
                          ((LockState == `AXI_AUX_ST_UNLOCKED) ||
                           (LockState == `AXI_AUX_ST_LOCK_LAST))         // in unlocked or lock last state
                         )
                        )
      );


//------------------------------------------------------------------------------
// INDEX:   2) Handshake Rules
//------------------------------------------------------------------------------


  // INDEX:        - AXI_ERRM_ARADDR_STABLE
  // =====
  assert_win_unchange #(`AXI_SimError, ADDR_WIDTH, AXI_ERRM_PropertyType,
    "AXI_ERRM_ARADDR_STABLE. ARADDR must remain stable when ARVALID is asserted and ARREADY low. Spec: section 3.1, and figure 3-1, on page 3-2."
  )  axi_errm_araddr_stable
     (.clk         (`AXI_OVL_CLK),
      .reset_n     (`AXI_OVL_RSTn),
      .start_event (ARVALID & !ARREADY),
      .test_expr   (ARADDR),
      .end_event   (!(ARVALID & !ARREADY)) // Inverse of start_event
      );


  // INDEX:        - AXI_ERRM_ARBURST_STABLE
  // =====
  assert_win_unchange #(`AXI_SimError, 2, AXI_ERRM_PropertyType,
    "AXI_ERRM_ARBURST_STABLE. ARBURST must remain stable when ARVALID is asserted and ARREADY low. Spec: section 3.1, and figure 3-1, on page 3-2."
  )  axi_errm_arburst_stable
     (.clk         (`AXI_OVL_CLK),
      .reset_n     (`AXI_OVL_RSTn),
      .start_event (ARVALID & !ARREADY),
      .test_expr   (ARBURST),
      .end_event   (!(ARVALID & !ARREADY)) // Inverse of start_event
      );


  // INDEX:        - AXI_ERRM_ARCACHE_STABLE
  // =====
  assert_win_unchange #(`AXI_SimError, 4, AXI_ERRM_PropertyType,
    "AXI_ERRM_ARCACHE_STABLE. ARCACHE must remain stable when ARVALID is asserted and ARREADY low. Spec: section 3.1, and figure 3-1, on page 3-2."
  )  axi_errm_arcache_stable
     (.clk         (`AXI_OVL_CLK),
      .reset_n     (`AXI_OVL_RSTn),
      .start_event (ARVALID & !ARREADY),
      .test_expr   (ARCACHE),
      .end_event   (!(ARVALID & !ARREADY)) // Inverse of start_event
      );


  // INDEX:        - AXI_ERRM_ARID_STABLE
  // =====
  assert_win_unchange #(`AXI_SimError, ID_WIDTH, AXI_ERRM_PropertyType,
    "AXI_ERRM_ARID_STABLE. ARID must remain stable when ARVALID is asserted and ARREADY low. Spec: section 3.1, and figure 3-1, on page 3-2."
  )  axi_errm_arid_stable
     (.clk         (`AXI_OVL_CLK),
      .reset_n     (`AXI_OVL_RSTn),
      .start_event (ARVALID & !ARREADY),
      .test_expr   (ARID),
      .end_event   (!(ARVALID & !ARREADY)) // Inverse of start_event
      );


  // INDEX:        - AXI_ERRM_ARLEN_STABLE
  // =====
  assert_win_unchange #(`AXI_SimError, 4, AXI_ERRM_PropertyType,
    "AXI_ERRM_ARLEN_STABLE. ARLEN must remain stable when ARVALID is asserted and ARREADY low. Spec: section 3.1, and figure 3-1, on page 3-2."
  )  axi_errm_arlen_stable
     (.clk         (`AXI_OVL_CLK),
      .reset_n     (`AXI_OVL_RSTn),
      .start_event (ARVALID & !ARREADY),
      .test_expr   (ARLEN),
      .end_event   (!(ARVALID & !ARREADY)) // Inverse of start_event
      );


  // INDEX:        - AXI_ERRM_ARLOCK_STABLE
  // =====
  assert_win_unchange #(`AXI_SimError, 2, AXI_ERRM_PropertyType,
    "AXI_ERRM_ARLOCK_STABLE. ARLOCK must remain stable when ARVALID is asserted and ARREADY low. Spec: section 3.1, and figure 3-1, on page 3-2."
  )  axi_errm_arlock_stable
     (.clk         (`AXI_OVL_CLK),
      .reset_n     (`AXI_OVL_RSTn),
      .start_event (ARVALID & !ARREADY),
      .test_expr   (ARLOCK),
      .end_event   (!(ARVALID & !ARREADY)) // Inverse of start_event
      );


  // INDEX:        - AXI_ERRM_ARPROT_STABLE
  // =====
  assert_win_unchange #(`AXI_SimError, 3, AXI_ERRM_PropertyType,
    "AXI_ERRM_ARPROT_STABLE. ARPROT must remain stable when ARVALID is asserted and ARREADY low. Spec: section 3.1, and figure 3-1, on page 3-2."
  )  axi_errm_arprot_stable
     (.clk         (`AXI_OVL_CLK),
      .reset_n     (`AXI_OVL_RSTn),
      .start_event (ARVALID & !ARREADY),
      .test_expr   (ARPROT),
      .end_event   (!(ARVALID & !ARREADY)) // Inverse of start_event
      );


  // INDEX:        - AXI_ERRM_ARSIZE_STABLE
  // =====
  assert_win_unchange #(`AXI_SimError, 3, AXI_ERRM_PropertyType,
    "AXI_ERRM_ARSIZE_STABLE. ARSIZE must remain stable when ARVALID is asserted and ARREADY low. Spec: section 3.1, and figure 3-1, on page 3-2."
  )  axi_errm_arsize_stable
     (.clk         (`AXI_OVL_CLK),
      .reset_n     (`AXI_OVL_RSTn),
      .start_event (ARVALID & !ARREADY),
      .test_expr   (ARSIZE),
      .end_event   (!(ARVALID & !ARREADY)) // Inverse of start_event
      );


  // INDEX:        - AXI_ERRM_ARVALID_STABLE
  // =====
  assert_next #(`AXI_SimError, 1, 1, 0, AXI_ERRM_PropertyType,
    "AXI_ERRM_ARVALID_STABLE. Once ARVALID is asserted, it must remain asserted until ARREADY is high. Spec: section 3.1.4 on page 3-4."
  )  axi_errm_arvalid_stable
     (.clk         (`AXI_OVL_CLK),
      .reset_n     (`AXI_OVL_RSTn),
      .start_event (ARVALID & !ARREADY),
      .test_expr   (ARVALID)
      );


  // INDEX:        - AXI_RECS_ARREADY_MAX_WAIT  
  // =====
  // Note: this rule does not error if VALID goes low (breaking VALID_STABLE rule)
  assert_frame #(`AXI_SimWarning, 0, MAXWAITS, 0, AXI_RECS_PropertyType,
    "AXI_RECS_ARREADY_MAX_WAIT. ARREADY should be asserted within MAXWAITS cycles of ARVALID being asserted."
  )  axi_recs_arready_max_wait
     (.clk         (`AXI_OVL_CLK),
      .reset_n     (`AXI_OVL_RSTn),
      .start_event (i_RecommendOn  &       // Parameter that can disable all  AXI_REC*_* rules
                    i_RecMaxWaitOn &       // Parameter that can disable just AXI_REC*_MAX_WAIT rules
                   !ARREADY &  ARVALID),
      .test_expr   (ARREADY | !ARVALID)    // READY=1 within MAXWAITS cycles (or VALID=0)
      );


//------------------------------------------------------------------------------
// INDEX:   3) X-Propagation Rules
//------------------------------------------------------------------------------
`ifdef AXI_XCHECK_OFF
`else  // X-Checking on by default


  // INDEX:        - AXI_ERRM_ARADDR_X
  // =====
  assert_never_unknown #(`AXI_SimError, ADDR_WIDTH, AXI_ERRM_PropertyType,
    "AXI_ERRM_ARADDR_X. When ARVALID is high, a value of X on ARADDR is not permitted. Spec: section 3.1.4 on page 3-4."
  )  axi_errm_araddr_x
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .qualifier (ARVALID),
      .test_expr (ARADDR)
      );


  // INDEX:        - AXI_ERRM_ARBURST_X
  // =====
  assert_never_unknown #(`AXI_SimError, 2, AXI_ERRM_PropertyType,
    "AXI_ERRM_ARBURST_X. When ARVALID is high, a value of X on ARBURST is not permitted. Spec: section 3.1.4 on page 3-4."
  )  axi_errm_arburst_x
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .qualifier (ARVALID),
      .test_expr (ARBURST)
      );


  // INDEX:        - AXI_ERRM_ARCACHE_X
  // =====
  assert_never_unknown #(`AXI_SimError, 4, AXI_ERRM_PropertyType,
    "AXI_ERRM_ARCACHE_X. When ARVALID is high, a value of X on ARCACHE is not permitted. Spec: section 3.1.4 on page 3-4."
  )  axi_errm_arcache_x
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .qualifier (ARVALID),
      .test_expr (ARCACHE)
      );


  // INDEX:        - AXI_ERRM_ARID_X
  // =====
  assert_never_unknown #(`AXI_SimError, ID_WIDTH, AXI_ERRM_PropertyType,
    "AXI_ERRM_ARID_X. When ARVALID is high, a value of X on ARID is not permitted. Spec: section 3.1.4 on page 3-4."
  )  axi_errm_arid_x
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .qualifier (ARVALID),
      .test_expr (ARID)
      );


  // INDEX:        - AXI_ERRM_ARLEN_X
  // =====
  assert_never_unknown #(`AXI_SimError, 4, AXI_ERRM_PropertyType,
    "AXI_ERRM_ARLEN_X. When ARVALID is high, a value of X on ARLEN is not permitted. Spec: section 3.1.4 on page 3-4."
  )  axi_errm_arlen_x
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .qualifier (ARVALID),
      .test_expr (ARLEN)
      );


  // INDEX:        - AXI_ERRM_ARLOCK_X
  // =====
  assert_never_unknown #(`AXI_SimError, 2, AXI_ERRM_PropertyType,
    "AXI_ERRM_ARLOCK_X. When ARVALID is high, a value of X on ARLOCK is not permitted. Spec: section 3.1.4 on page 3-4."
  )  axi_errm_arlock_x
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .qualifier (ARVALID),
      .test_expr (ARLOCK)
      );


  // INDEX:        - AXI_ERRM_ARPROT_X
  // =====
  assert_never_unknown #(`AXI_SimError, 3, AXI_ERRM_PropertyType,
    "AXI_ERRM_ARPROT_X. When ARVALID is high, a value of X on ARPROT is not permitted. Spec: section 3.1.4 on page 3-4."
  )  axi_errm_arprot_x
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .qualifier (ARVALID),
      .test_expr (ARPROT)
      );


  // INDEX:        - AXI_ERRM_ARSIZE_X
  // =====
  assert_never_unknown #(`AXI_SimError, 3, AXI_ERRM_PropertyType,
    "AXI_ERRM_ARSIZE_X. When ARVALID is high, a value of X on ARSIZE is not permitted. Spec: section 3.1.4 on page 3-4."
  )  axi_errm_arsize_x
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .qualifier (ARVALID),
      .test_expr (ARSIZE)
      );


  // INDEX:        - AXI_ERRM_ARVALID_X
  // =====
  assert_never_unknown #(`AXI_SimError, 1, AXI_ERRM_PropertyType,
    "AXI_ERRM_ARVALID_X. When not in reset, a value of X on ARVALID is not permitted."
  )  axi_errm_arvalid_x
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .qualifier (1'b1),
      .test_expr (ARVALID)
      );


  // INDEX:        - AXI_ERRS_ARREADY_X
  // =====
  assert_never_unknown #(`AXI_SimError, 1, AXI_ERRS_PropertyType,
    "AXI_ERRS_ARREADY_X. When not in reset, a value of X on ARREADY is not permitted."
  )  axi_errs_arready_x
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .qualifier (1'b1),
      .test_expr (ARREADY)
      );

`endif // AXI_XCHECK_OFF


//------------------------------------------------------------------------------
// INDEX:
// INDEX: AXI Rules: Read Data Channel (*_R*)
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// INDEX:   1) Functional Rules
//------------------------------------------------------------------------------


  // INDEX:        - AXI_ERRS_RDATA_NUM 
  // =====
  assert_implication #(`AXI_SimError, AXI_ERRS_PropertyType,
    "AXI_ERRS_RDATA_NUM. The number of read data items must match the corresponding ARLEN. Spec: table 4-1 on page 4-3."
  )  axi_errs_rdata_num
     (.clk              (`AXI_OVL_CLK),
      .reset_n          (`AXI_OVL_RSTn),
      `AXI_ANTECEDENT   (RVALID & RREADY),
      .consequent_expr  (((ArCountPending == ArLenPending) & RLAST)  //     Last RDATA and RLAST is     asserted
                        |((ArCountPending != ArLenPending) & ~RLAST) // Not last RDATA and RLAST is not asserted
                        )
      );


  // INDEX:        - AXI_ERRS_RLAST_ALL_DONE_EOS 
  // =====
  // EOS: End-Of-Simulation check (not suitable for formal proofs).
  // Use +define+OVL_END_OF_SIMULATION=tb.EOS_signal when compiling.
`ifdef AXI_END_OF_SIMULATION
  assert_quiescent_state #(`AXI_SimError, 1, AXI_ERRS_PropertyType,
    "AXI_ERRS_RLAST_ALL_DONE_EOS. All outstanding read bursts must have completed."
  )  axi_errs_rlast_all_done_eos
     (.clk          (`AXI_OVL_CLK),
      .reset_n      (`AXI_OVL_RSTn),
      .state_expr   (nROutstanding),
      .check_value  (1'b1),
      .sample_event (1'b0)
      );
`endif


  // INDEX:        - AXI_ERRS_RID 
  // =====
  // Read data must always follow the address that it relates to.
  assert_implication #(`AXI_SimError, AXI_ERRS_PropertyType,
    "AXI_ERRS_RID. A slave can only give read data with an ID to match an outstanding read transaction. Spec: section 8.3 on page 8-4."
  )  axi_errs_rid
     (.clk              (`AXI_OVL_CLK),
      .reset_n          (`AXI_OVL_RSTn),
      `AXI_ANTECEDENT   (RVALID),
      .consequent_expr  (RidMatch > 0)
      );


  // INDEX:        - AXI_ERRS_RRESP_EXOKAY 
  // =====
  assert_implication #(`AXI_SimError, AXI_ERRS_PropertyType,
    "AXI_ERRS_RRESP_EXOKAY. An EXOKAY read response can only be given to an exclusive read access. Spec: section 6.2.3 on page 6-4."
  )  axi_errs_rresp_exokay
     (.clk              (`AXI_OVL_CLK),
      .reset_n          (`AXI_OVL_RSTn),
      `AXI_ANTECEDENT   (RVALID & RREADY & (RRESP == `AXI_RESP_EXOKAY)),
      .consequent_expr  (ArExclPending)
      );


  // INDEX:        - AXI_ERRS_RVALID_RESET
  // =====
  assert_always_on_edge #(`AXI_SimError, 1, AXI_ERRS_PropertyType,
    "AXI_ERRS_RVALID_RESET. RVALID must be low in the cycle when ARESETn first goes high. Spec: section 11.1.2 on page 11-2."
  )  axi_errs_rvalid_reset
     (.clk            (`AXI_OVL_CLK),
      .reset_n        (1'b1), // check whilst in reset
      .sampling_event (`AXI_OVL_RSTn),
      .test_expr      (!RVALID)
      );


//------------------------------------------------------------------------------
// INDEX:   2) Handshake Rules
//------------------------------------------------------------------------------


  // INDEX:        - AXI_ERRS_RDATA_STABLE 
  // =====
  assert_win_unchange #(`AXI_SimError, DATA_WIDTH, AXI_ERRS_PropertyType,
    "AXI_ERRS_RDATA_STABLE. RDATA must remain stable when RVALID is asserted and RREADY low. Spec: section 3.1, and figure 3-1, on page 3-2."
  )  axi_errs_rdata_stable
     (.clk         (`AXI_OVL_CLK),
      .reset_n     (`AXI_OVL_RSTn),
      .start_event (RVALID & !RREADY),
      .test_expr   (RDATA
                      | ~RdataMask
                   ),
      .end_event   (!(RVALID & !RREADY)) // Inverse of start_event
      );


  // INDEX:        - AXI_ERRS_RID_STABLE
  // =====
  assert_win_unchange #(`AXI_SimError, ID_WIDTH, AXI_ERRS_PropertyType,
    "AXI_ERRS_RID_STABLE. RID must remain stable when RVALID is asserted and RREADY low. Spec: section 3.1, and figure 3-1, on page 3-2."
  )  axi_errs_rid_stable
     (.clk         (`AXI_OVL_CLK),
      .reset_n     (`AXI_OVL_RSTn),
      .start_event (RVALID & !RREADY),
      .test_expr   (RID),
      .end_event   (!(RVALID & !RREADY)) // Inverse of start_event
      );


  // INDEX:        - AXI_ERRS_RLAST_STABLE
  // =====
  assert_win_unchange #(`AXI_SimError, 1, AXI_ERRS_PropertyType,
    "AXI_ERRS_RLAST_STABLE. RLAST must remain stable when RVALID is asserted and RREADY low. Spec: section 3.1, and figure 3-1, on page 3-2."
  )  axi_errs_rlast_stable
     (.clk         (`AXI_OVL_CLK),
      .reset_n     (`AXI_OVL_RSTn),
      .start_event (RVALID & !RREADY),
      .test_expr   (RLAST),
      .end_event   (!(RVALID & !RREADY)) // Inverse of start_event
      );


  // INDEX:        - AXI_ERRS_RRESP_STABLE
  // =====
  assert_win_unchange #(`AXI_SimError, 2, AXI_ERRS_PropertyType,
    "AXI_ERRS_RRESP_STABLE. RRESP must remain stable when RVALID is asserted and RREADY low. Spec: section 3.1, and figure 3-1, on page 3-2."
  )  axi_errs_rresp_stable
     (.clk         (`AXI_OVL_CLK),
      .reset_n     (`AXI_OVL_RSTn),
      .start_event (RVALID & !RREADY),
      .test_expr   (RRESP),
      .end_event   (!(RVALID & !RREADY)) // Inverse of start_event
      );


  // INDEX:        - AXI_ERRS_RVALID_STABLE
  // =====
  assert_next #(`AXI_SimError, 1, 1, 0, AXI_ERRS_PropertyType,
    "AXI_ERRS_RVALID_STABLE. Once RVALID is asserted, it must remain asserted until RREADY is high. Spec: section 3.1.5 on page 3-5."
  )  axi_errs_rvalid_stable
     (.clk         (`AXI_OVL_CLK),
      .reset_n     (`AXI_OVL_RSTn),
      .start_event (RVALID & !RREADY),
      .test_expr   (RVALID)
      );


  // INDEX:        - AXI_RECM_RREADY_MAX_WAIT  
  // =====
  // Note: this rule does not error if VALID goes low (breaking VALID_STABLE rule)
  assert_frame #(`AXI_SimWarning, 0, MAXWAITS, 0, AXI_RECM_PropertyType,
    "AXI_RECM_RREADY_MAX_WAIT. RREADY should be asserted within MAXWAITS cycles of RVALID being asserted."
  )  axi_recm_rready_max_wait
     (.clk         (`AXI_OVL_CLK),
      .reset_n     (`AXI_OVL_RSTn),
      .start_event (i_RecommendOn  &       // Parameter that can disable all  AXI_REC*_* rules
                    i_RecMaxWaitOn &       // Parameter that can disable just AXI_REC*_MAX_WAIT rules
                   !RREADY &  RVALID),
      .test_expr   (RREADY | !RVALID)      // READY=1 within MAXWAITS cycles (or VALID=0)
      );


//------------------------------------------------------------------------------
// INDEX:   3) X-Propagation Rules 
//------------------------------------------------------------------------------
`ifdef AXI_XCHECK_OFF
`else  // X-Checking on by default


  // INDEX:        - AXI_ERRS_RDATA_X
  // =====
  assert_never_unknown #(`AXI_SimError, DATA_WIDTH, AXI_ERRS_PropertyType,
    "AXI_ERRS_RDATA_X. When RVALID is high, a value of X on RDATA valid byte lanes is not permitted."
  )  axi_errs_rdata_x
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .qualifier (RVALID),
      .test_expr (RDATA | ~RdataMask)
      );


  // INDEX:        - AXI_ERRM_RREADY_X
  // =====
  assert_never_unknown #(`AXI_SimError, 1, AXI_ERRM_PropertyType,
    "AXI_ERRM_RREADY_X. When not in reset, a value of X on RREADY is not permitted."
  )  axi_errm_rready_x
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .qualifier (1'b1),
      .test_expr (RREADY)
      );


  // INDEX:        - AXI_ERRS_RID_X
  // =====
  assert_never_unknown #(`AXI_SimError, ID_WIDTH, AXI_ERRS_PropertyType,
    "AXI_ERRS_RID_X. When RVALID is high, a value of X on RID is not permitted."
  )  axi_errs_rid_x
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .qualifier (RVALID),
      .test_expr (RID)
      );


  // INDEX:        - AXI_ERRS_RLAST_X
  // =====
  assert_never_unknown #(`AXI_SimError, 1, AXI_ERRS_PropertyType,
    "AXI_ERRS_RLAST_X. When RVALID is high, a value of X on RLAST is not permitted."
  )  axi_errs_rlast_x
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .qualifier (RVALID),
      .test_expr (RLAST)
      );


  // INDEX:        - AXI_ERRS_RRESP_X
  // =====
  assert_never_unknown #(`AXI_SimError, 2, AXI_ERRS_PropertyType,
    "AXI_ERRS_RRESP_X. When RVALID is high, a value of X on RRESP is not permitted."
  )  axi_errs_rresp_x
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .qualifier (RVALID),
      .test_expr (RRESP)
      );


  // INDEX:        - AXI_ERRS_RVALID_X
  // =====
  assert_never_unknown #(`AXI_SimError, 1, AXI_ERRS_PropertyType,
    "AXI_ERRS_RVALID_X. When not in reset, a value of X on RVALID is not permitted."
  )  axi_errs_rvalid_x
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .qualifier (1'b1),
      .test_expr (RVALID)
      );

`endif // AXI_XCHECK_OFF


//------------------------------------------------------------------------------
// INDEX:
// INDEX: AXI Rules: Low Power Interface (*_C*)
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// INDEX:   1) Functional Rules (none for Low Power signals)
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// INDEX:   2) Handshake Rules (asynchronous to ACLK)
// =====
// The low-power handshake rules below use rising/falling edges on REQ and ACK,
// in order to detect changes within ACLK cycles (including low power state).
//------------------------------------------------------------------------------


  // INDEX:        - AXI_ERRL_CSYSACK_FALL
  // =====
  assert_always #(`AXI_SimError, AXI_ERRL_PropertyType,
    "AXI_ERRL_CSYSACK_FALL. When CSYSACK transitions from high to low, CSYSREQ must be low. Spec: figure 12-1 on page 12-3."
  )  axi_errl_csysack_fall
     (.clk         (~CSYSACK), // falling edge of CSYSACK
      .reset_n     (`AXI_OVL_RSTn),
      .test_expr   (~CSYSREQ)  // CSYSREQ low
      );


  // INDEX:        - AXI_ERRL_CSYSACK_RISE
  // =====
  assert_always #(`AXI_SimError, AXI_ERRL_PropertyType,
    "AXI_ERRL_CSYSACK_RISE. When CSYSACK transitions from low to high, CSYSREQ must be high. Spec: figure 12-1 on page 12-3."
  )  axi_errl_csysack_rise
     (.clk         (CSYSACK),  // rising edge of CSYSACK
      .reset_n     (`AXI_OVL_RSTn),
      .test_expr   (CSYSREQ)   // CSYSREQ high
      );


  // INDEX:        - AXI_ERRL_CSYSREQ_FALL
  // =====
  assert_always #(`AXI_SimError, AXI_ERRL_PropertyType,
    "AXI_ERRL_CSYSREQ_FALL. When CSYSREQ transitions from high to low, CSYSACK must be high. Spec: figure 12-1 on page 12-3."
  )  axi_errl_csysreq_fall
     (.clk         (~CSYSREQ), // falling edge of CSYSREQ
      .reset_n     (`AXI_OVL_RSTn),
      .test_expr   (CSYSACK)   // CSYSACK high
      );


  // INDEX:        - AXI_ERRL_CSYSREQ_RISE
  // =====
  assert_always #(`AXI_SimError, AXI_ERRL_PropertyType,
    "AXI_ERRL_CSYSREQ_RISE. When CSYSREQ transitions from low to high, CSYSACK must be low. Spec: figure 12-1 on page 12-3."
  )  axi_errl_csysreq_rise
     (.clk         (CSYSREQ),  // rising edge of CSYSREQ
      .reset_n     (`AXI_OVL_RSTn),
      .test_expr   (~CSYSACK)  // CSYSACK low
      );


//------------------------------------------------------------------------------
// INDEX:   3) X-Propagation Rules
//------------------------------------------------------------------------------
`ifdef AXI_XCHECK_OFF
`else  // X-Checking on by default


  // INDEX:        - AXI_ERRL_CACTIVE_X 
  // =====
  assert_never_unknown #(`AXI_SimError, 1, AXI_ERRL_PropertyType,
    "AXI_ERRL_CACTIVE_X. When not in reset, a value of X on CACTIVE is not permitted."
  )  axi_errl_cactive_x
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .qualifier (1'b1),
      .test_expr (CACTIVE)
      );


  // INDEX:        - AXI_ERRL_CSYSACK_X 
  // =====
  assert_never_unknown #(`AXI_SimError, 1, AXI_ERRL_PropertyType,
    "AXI_ERRL_CSYSACK_X. When not in reset, a value of X on CSYSACK is not permitted."
  )  axi_errl_csysack_x
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .qualifier (1'b1),
      .test_expr (CSYSACK)
      );


  // INDEX:        - AXI_ERRL_CSYSREQ_X 
  // =====
  assert_never_unknown #(`AXI_SimError, 1, AXI_ERRL_PropertyType,
    "AXI_ERRL_CSYSREQ_X. When not in reset, a value of X on CSYSREQ is not permitted."
  )  axi_errl_csysreq_x
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .qualifier (1'b1),
      .test_expr (CSYSREQ)
      );

`endif // AXI_XCHECK_OFF


//------------------------------------------------------------------------------
// INDEX:
// INDEX: AXI Rules: Exclusive Access
// =====
// These are inter-channel rules.
// Supports one outstanding exclusive access per ID
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// INDEX:   1) Functional Rules
//------------------------------------------------------------------------------
// INDEX:        - 


  // INDEX:        - AXI_ERRM_EXCL_ALIGN
  // =====
  // Burst lengths that are not a power of two are not checked here, because
  // these will violate EXCLLEN. Checked for excl reads only as AXI_RECM_EXCL_PAIR
  // or AXI_RECM_EXCL_MATCH will fire if an excl write violates.
  assert_implication #(`AXI_SimError, AXI_ERRM_PropertyType,
    "AXI_ERRM_EXCL_ALIGN. The address of an exclusive access must be aligned to the total number of bytes in the transaction. Spec: section 6.2.4 on page 6-5."
  )  axi_errm_excl_align
     (.clk              (`AXI_OVL_CLK),
      .reset_n          (`AXI_OVL_RSTn),
      `AXI_ANTECEDENT   (ARVALID &                       // valid address
                         (ARLOCK == `AXI_ALOCK_EXCL) &   // exclusive transaction
                         (ARLEN == `AXI_ALEN_1 ||        // length is power of 2
                          ARLEN == `AXI_ALEN_2 ||
                          ARLEN == `AXI_ALEN_4 ||
                          ARLEN == `AXI_ALEN_8 ||
                          ARLEN == `AXI_ALEN_16)),
      .consequent_expr  ((ARADDR[10:0] & ExclMask) == ARADDR[10:0])// address aligned
      );


  // INDEX:        - AXI_ERRM_EXCL_LEN
  // =====
  // Checked for excl reads only as AXI_RECM_EXCL_PAIR or AXI_RECM_EXCL_MATCH will
  // fire if an excl write violates.
  assert_implication #(`AXI_SimError, AXI_ERRM_PropertyType,
    "AXI_ERRM_EXCL_LEN. The number of bytes to be transferred in an exclusive access burst must be a power of 2. Spec: section 6.2.4 on page 6-5."
  )  axi_errm_excl_len
     (.clk              (`AXI_OVL_CLK),
      .reset_n          (`AXI_OVL_RSTn),
      `AXI_ANTECEDENT   (ARVALID & (ARLOCK == `AXI_ALOCK_EXCL)),
      .consequent_expr  ((ARLEN == `AXI_ALEN_1)  ||
                         (ARLEN == `AXI_ALEN_2)  ||
                         (ARLEN == `AXI_ALEN_4)  ||
                         (ARLEN == `AXI_ALEN_8)  ||
                         (ARLEN == `AXI_ALEN_16))
      );


  // INDEX:        - AXI_RECM_EXCL_MATCH 
  // =====
  // Recommendation as it can be affected by software, e.g. if a dummy STREX is used to clear any outstanding exclusive accesses.
  assert_implication #(`AXI_SimWarning, AXI_RECM_PropertyType,
    "AXI_RECM_EXCL_MATCH. The address, size and length of an exclusive write should be the same as the preceding exclusive read with the same ID. Spec: section 6.2.4 on page 6-5."
  )  axi_recm_excl_match
     (.clk              (`AXI_OVL_CLK),
      .reset_n          (`AXI_OVL_RSTn),
      `AXI_ANTECEDENT   (i_RecommendOn // Parameter that can disable all AXI_REC*_* rules
                         & AWVALID & AWREADY &
                         (AWLOCK == `AXI_ALOCK_EXCL) & ExclReadAddr[ExclAwId] // excl write & excl read outstanding
                         & ExclAwMatch),
      .consequent_expr  ((ExclAddr[ExclAwId] == AWADDR) &
                         (ExclSize[ExclAwId] == AWSIZE) &
                         (ExclLen[ExclAwId]  == AWLEN)  &
                         (ExclBurst[ExclAwId]== AWBURST)&
                         (ExclCache[ExclAwId]== AWCACHE)&
                         (ExclProt[ExclAwId] == AWPROT) &
                         (ExclUser[ExclAwId] == AWUSER)
                         )
      );


  // INDEX:        - AXI_ERRM_EXCL_MAX
  // =====
  // Burst lengths that are not a power of two are not checked here, because
  // these will violate EXCLLEN. Bursts of length 1 can never violate this
  // rule. Checked for excl reads only as AXI_RECM_EXCL_PAIR or AXI_RECM_EXCL_MATCH will
  // fire if an excl write violates.
  assert_implication #(`AXI_SimError, AXI_ERRM_PropertyType,
    "AXI_ERRM_EXCL_MAX. The maximum number of bytes that can be transferred in an exclusive burst is 128. Spec: section 6.2.4 on page 6-5."
  )  axi_errm_excl_max
     (.clk              (`AXI_OVL_CLK),
      .reset_n          (`AXI_OVL_RSTn),
      `AXI_ANTECEDENT   (ARVALID &                      // valid address
                         (ARLOCK == `AXI_ALOCK_EXCL) &  // exclusive transaction
                         (ARLEN == `AXI_ALEN_2 ||       // length is power of 2
                          ARLEN == `AXI_ALEN_4 ||
                          ARLEN == `AXI_ALEN_8 ||
                          ARLEN == `AXI_ALEN_16)),
      .consequent_expr  (ArLenInBytes <= 128 )          // max 128 bytes transferred
      );


  // INDEX:        - AXI_RECM_EXCL_PAIR 
  // =====
  // Recommendation as it can be affected by software, e.g. if a dummy STREX is used to clear any outstanding exclusive accesses.
  assert_implication #(`AXI_SimWarning, AXI_RECM_PropertyType,
    "AXI_RECM_EXCL_PAIR. An exclusive write should have an earlier outstanding completed exclusive read with the same ID. Spec: section 6.2.2 on page 6-4."
  )  axi_recm_excl_pair
     (.clk              (`AXI_OVL_CLK),
      .reset_n          (`AXI_OVL_RSTn),
      `AXI_ANTECEDENT   (i_RecommendOn                                       // Parameter that can disable all AXI_REC*_* rules
                         & AWVALID & AWREADY & (AWLOCK == `AXI_ALOCK_EXCL)), // excl write
      .consequent_expr  (ExclAwMatch &&
                         ExclReadAddr[ExclAwId] &&
                         ExclReadData[ExclAwId])                             // excl read with same ID complete
      );


//------------------------------------------------------------------------------
// INDEX:
// INDEX: AXI Rules: USER_* Rules (extension to AXI)
// =====
// The USER signals are user-defined extensions to the AXI spec, so have been
// located separately from the channel-specific rules.
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// INDEX:   1) Functional Rules (none for USER signals)
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// INDEX:   2) Handshake Rules
//------------------------------------------------------------------------------


  // INDEX:        - AXI_ERRM_AWUSER_STABLE
  // =====
  assert_win_unchange #(`AXI_SimError, AWUSER_WIDTH, AXI_ERRM_PropertyType,
    "AXI_ERRM_AWUSER_STABLE. AWUSER must remain stable when AWVALID is asserted and AWREADY low. Spec: section 3.1, and figure 3-1, on page 3-2."
  )  axi_errm_awuser_stable
     (.clk          (`AXI_OVL_CLK),
      .reset_n      (`AXI_OVL_RSTn),
      .start_event  (AWVALID & !AWREADY),
      .test_expr    (AWUSER),
      .end_event    (!(AWVALID & !AWREADY)) // Inverse of start_event
      );


  // INDEX:        - AXI_ERRM_WUSER_STABLE
  // =====
  assert_win_unchange #(`AXI_SimError, WUSER_WIDTH, AXI_ERRM_PropertyType,
    "AXI_ERRM_WUSER_STABLE. WUSER must remain stable when WVALID is asserted and WREADY low. Spec: section 3.1, and figure 3-1, on page 3-2."
  )  axi_errm_wuser_stable
     (.clk         (`AXI_OVL_CLK),
      .reset_n     (`AXI_OVL_RSTn),
      .start_event (WVALID & !WREADY),
      .test_expr   (WUSER),
      .end_event   (!(WVALID & !WREADY)) // Inverse of start_event
      );


  // INDEX:        - AXI_ERRS_BUSER_STABLE
  // =====
  assert_win_unchange #(`AXI_SimError, BUSER_WIDTH, AXI_ERRS_PropertyType,
    "AXI_ERRS_BUSER_STABLE. BUSER must remain stable when BVALID is asserted and BREADY low. Spec: section 3.1, and figure 3-1, on page 3-2."
  )  axi_errs_buser_stable
     (.clk          (`AXI_OVL_CLK),
      .reset_n      (`AXI_OVL_RSTn),
      .start_event  (BVALID & !BREADY),
      .test_expr    (BUSER),
      .end_event    (!(BVALID & !BREADY)) // Inverse of start_event
      );


  // INDEX:        - AXI_ERRM_ARUSER_STABLE
  // =====
  assert_win_unchange #(`AXI_SimError, ARUSER_WIDTH, AXI_ERRM_PropertyType,
    "AXI_ERRM_ARUSER_STABLE. ARUSER must remain stable when ARVALID is asserted and ARREADY low. Spec: section 3.1, and figure 3-1, on page 3-2."
  )  axi_errm_aruser_stable
     (.clk         (`AXI_OVL_CLK),
      .reset_n     (`AXI_OVL_RSTn),
      .start_event (ARVALID & !ARREADY),
      .test_expr   (ARUSER),
      .end_event   (!(ARVALID & !ARREADY)) // Inverse of start_event
      );


  // INDEX:        - AXI_ERRS_RUSER_STABLE
  // =====
  assert_win_unchange #(`AXI_SimError, RUSER_WIDTH, AXI_ERRS_PropertyType,
    "AXI_ERRS_RUSER_STABLE. RUSER must remain stable when RVALID is asserted and RREADY low. Spec: section 3.1, and figure 3-1, on page 3-2."
  )  axi_errs_ruser_stable
     (.clk         (`AXI_OVL_CLK),
      .reset_n     (`AXI_OVL_RSTn),
      .start_event (RVALID & !RREADY),
      .test_expr   (RUSER),
      .end_event   (!(RVALID & !RREADY)) // Inverse of start_event
      );


//------------------------------------------------------------------------------
// INDEX:   3) X-Propagation Rules
//------------------------------------------------------------------------------
`ifdef AXI_XCHECK_OFF
`else  // X-Checking on by default


  // INDEX:        - AXI_ERRM_AWUSER_X
  // =====
  assert_never_unknown #(`AXI_SimError, AWUSER_WIDTH, AXI_ERRM_PropertyType,
    "AXI_ERRM_AWUSER_X. When AWVALID is high, a value of X on AWUSER is not permitted. Spec: section 3.1.1 on page 3-3."
  )  axi_errm_awuser_x
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .qualifier (AWVALID),
      .test_expr (AWUSER)
      );


  // INDEX:        - AXI_ERRM_WUSER_X
  // =====
  assert_never_unknown #(`AXI_SimError, WUSER_WIDTH, AXI_ERRM_PropertyType,
    "AXI_ERRM_WUSER_X. When WVALID is high, a value of X on WUSER is not permitted."
  )  axi_errm_wuser_x
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .qualifier (WVALID),
      .test_expr (WUSER)
      );


  // INDEX:        - AXI_ERRS_BUSER_X
  // =====
  assert_never_unknown #(`AXI_SimError, BUSER_WIDTH, AXI_ERRS_PropertyType,
    "AXI_ERRS_BUSER_X. When BVALID is high, a value of X on BUSER is not permitted."
  )  axi_errs_buser_x
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .qualifier (BVALID),
      .test_expr (BUSER)
      );


  // INDEX:        - AXI_ERRM_ARUSER_X
  // =====
  assert_never_unknown #(`AXI_SimError, ARUSER_WIDTH, AXI_ERRM_PropertyType,
    "AXI_ERRM_ARUSER_X. When ARVALID is high, a value of X on ARUSER is not permitted. Spec: section 3.1.4 on page 3-4."
  )  axi_errm_aruser_x
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .qualifier (ARVALID),
      .test_expr (ARUSER)
      );


  // INDEX:        - AXI_ERRS_RUSER_X
  // =====
  assert_never_unknown #(`AXI_SimError, RUSER_WIDTH, AXI_ERRS_PropertyType,
    "AXI_ERRS_RUSER_X. When RVALID is high, a value of X on RUSER is not permitted."
  )  axi_errs_ruser_x
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .qualifier (RVALID),
      .test_expr (RUSER)
      );

`endif // AXI_XCHECK_OFF


//------------------------------------------------------------------------------
// INDEX:
// INDEX: Auxiliary Logic
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// INDEX:   1) Rules for Auxiliary Logic
//------------------------------------------------------------------------------


  //----------------------------------------------------------------------------
  // INDEX:      a) Master (AUXM*)
  //----------------------------------------------------------------------------


  // INDEX:        - AXI_AUXM_DATA_WIDTH
  // =====
  assert_always #(`AXI_SimFatal, AXI_AUXM_PropertyType,
    "AXI_AUXM_DATA_WIDTH. Parameter DATA_WIDTH must be 32, 64, 128, 256, 512 or 1024"
  )  axi_auxm_data_width
     (.clk        (`AXI_OVL_CLK),
      .reset_n    (1'b1),
      .test_expr  (DATA_WIDTH ==   32 ||
                   DATA_WIDTH ==   64 ||
                   DATA_WIDTH ==  128 ||
                   DATA_WIDTH ==  256 ||
                   DATA_WIDTH ==  512 ||
                   DATA_WIDTH == 1024)
      );

  // INDEX:        - AXI_AUXM_ADDR_WIDTH
  // =====
  assert_always #(`AXI_SimFatal, AXI_AUXM_PropertyType,
    "AXI_AUXM_ADDR_WIDTH. Parameter ADDR_WIDTH must be between 32 and 64 bits inclusive"
  )  axi_auxm_addr_width
     (.clk        (`AXI_OVL_CLK),
      .reset_n    (1'b1),
      .test_expr  (ADDR_WIDTH >= 32 && ADDR_WIDTH <= 64)
      );


  // INDEX:        - AXI_AUXM_AWUSER_WIDTH
  // =====
  assert_always #(`AXI_SimFatal, AXI_AUXM_PropertyType,
    "AXI_AUXM_AWUSER_WIDTH. Parameter AWUSER_WIDTH must be greater than or equal to 1"
  )  axi_auxm_awuser_width
     (.clk        (`AXI_OVL_CLK),
      .reset_n    (1'b1),
      .test_expr  (AWUSER_WIDTH >= 1)
      );


  // INDEX:        - AXI_AUXM_WUSER_WIDTH
  // =====
  assert_always #(`AXI_SimFatal, AXI_AUXM_PropertyType,
    "AXI_AUXM_WUSER_WIDTH. Parameter WUSER_WIDTH must be greater than or equal to 1"
  )  axi_auxm_wuser_width
     (.clk        (`AXI_OVL_CLK),
      .reset_n    (1'b1),
      .test_expr  (WUSER_WIDTH >= 1)
      );


  // INDEX:        - AXI_AUXM_BUSER_WIDTH
  // =====
  assert_always #(`AXI_SimFatal, AXI_AUXM_PropertyType,
    "AXI_AUXM_BUSER_WIDTH. Parameter BUSER_WIDTH must be greater than or equal to 1"
  )  axi_auxm_buser_width
     (.clk        (`AXI_OVL_CLK),
      .reset_n    (1'b1),
      .test_expr  (BUSER_WIDTH >= 1)
      );


  // INDEX:        - AXI_AUXM_ARUSER_WIDTH
  // =====
  assert_always #(`AXI_SimFatal, AXI_AUXM_PropertyType,
    "AXI_AUXM_ARUSER_WIDTH. Parameter ARUSER_WIDTH must be greater than or equal to 1"
  )  axi_auxm_aruser_width
     (.clk        (`AXI_OVL_CLK),
      .reset_n    (1'b1),
      .test_expr  (ARUSER_WIDTH >= 1)
      );


  // INDEX:        - AXI_AUXM_RUSER_WIDTH
  // =====
  assert_always #(`AXI_SimFatal, AXI_AUXM_PropertyType,
    "AXI_AUXM_RUSER_WIDTH. Parameter RUSER_WIDTH must be greater than or equal to 1"
  )  axi_auxm_ruser_width
     (.clk        (`AXI_OVL_CLK),
      .reset_n    (1'b1),
      .test_expr  (RUSER_WIDTH >= 1)
      );


  // INDEX:        - AXI_AUXM_ID_WIDTH
  // =====
  assert_always #(`AXI_SimFatal, AXI_AUXM_PropertyType,
    "AXI_AUXM_ID_WIDTH. Parameter ID_WIDTH must be greater than or equal to 1"
  )  axi_auxm_id_width
     (.clk        (`AXI_OVL_CLK),
      .reset_n    (1'b1),
      .test_expr  (ID_WIDTH >= 1)
      );


  // INDEX:        - AXI_AUXM_EXMON_WIDTH
  // =====
  assert_always #(`AXI_SimFatal, AXI_AUXM_PropertyType,
    "AXI_AUXM_EXMON_WIDTH. Parameter EXMON_WIDTH must be greater than or equal to 1"
  )  axi_auxm_exmon_width
     (.clk        (`AXI_OVL_CLK),
      .reset_n    (1'b1),
      .test_expr  (EXMON_WIDTH >= 1)
      );


  // INDEX:        - AXI_AUXM_WDEPTH
  // =====
  assert_always #(`AXI_SimFatal, AXI_AUXM_PropertyType,
    "AXI_AUXM_WDEPTH. Parameter WDEPTH must be greater than or equal to 1"
  )  axi_auxm_wdepth
     (.clk        (`AXI_OVL_CLK),
      .reset_n    (1'b1),
      .test_expr  (WDEPTH >= 1)
      );


  // INDEX:        - AXI_AUXM_MAXRBURSTS
  // =====
  assert_always #(`AXI_SimFatal, AXI_AUXM_PropertyType,
    "AXI_AUXM_MAXRBURSTS. Parameter MAXRBURSTS must be greater than or equal to 1"
  )  axi_auxm_maxrbursts
     (.clk        (`AXI_OVL_CLK),
      .reset_n    (1'b1),
      .test_expr  (MAXRBURSTS >= 1)
      );


  // INDEX:        - AXI_AUXM_MAXWBURSTS
  // =====
  assert_always #(`AXI_SimFatal, AXI_AUXM_PropertyType,
    "AXI_AUXM_MAXWBURSTS. Parameter MAXWBURSTS must be greater than or equal to 1"
  )  axi_auxm_maxwbursts
     (.clk        (`AXI_OVL_CLK),
      .reset_n    (1'b1),
      .test_expr  (MAXWBURSTS >= 1)
      );


  // INDEX:        - AXI_AUXM_RCAM_OVERFLOW
  // =====
  assert_always #(`AXI_SimFatal, AXI_AUXM_PropertyType,
    "AXI_AUXM_RCAM_OVERFLOW. Read CAM overflow, increase MAXRBURSTS parameter."
  )  axi_auxm_rcam_overflow
     (.clk        (`AXI_OVL_CLK),
      .reset_n    (`AXI_OVL_RSTn),
      .test_expr  (RIndex <= (MAXRBURSTS+1))
      );


  // INDEX:        - AXI_AUXM_RCAM_UNDERFLOW
  // =====
  assert_always #(`AXI_SimFatal, AXI_AUXM_PropertyType,
    "AXI_AUXM_RCAM_UNDERFLOW. Read CAM underflow."
  )  axi_auxm_rcam_underflow
     (.clk        (`AXI_OVL_CLK),
      .reset_n    (`AXI_OVL_RSTn),
      .test_expr  (RIndex > 0)
      );


  // INDEX:        - AXI_AUXM_WCAM_OVERFLOW
  // =====
  assert_always #(`AXI_SimFatal, AXI_AUXM_PropertyType,
    "AXI_AUXM_WCAM_OVERFLOW. Write CAM overflow, increase MAXWBURSTS parameter."
  )  axi_auxm_wcam_overflow
     (.clk        (`AXI_OVL_CLK),
      .reset_n    (`AXI_OVL_RSTn),
      .test_expr  (WIndex <= (MAXWBURSTS+1))
      );


  // INDEX:        - AXI_AUXM_WCAM_UNDERFLOW
  // =====
  assert_always #(`AXI_SimFatal, AXI_AUXM_PropertyType,
    "AXI_AUXM_WCAM_UNDERFLOW. Write CAM underflow"
  )  axi_auxm_wcam_underflow
     (.clk       (`AXI_OVL_CLK),
      .reset_n   (`AXI_OVL_RSTn),
      .test_expr (WIndex > 0)
      );


  // INDEX:        - AXI_AUXM_EXCL_OVERFLOW
  // =====
  assert_always #(`AXI_SimFatal, AXI_AUXM_PropertyType,
    "AXI_AUXM_EXCL_OVERFLOW. Exclusive access monitor overflow, increase EXMON_WIDTH parameter."
  )  axi_auxm_excl_overflow
     (.clk        (`AXI_OVL_CLK),
      .reset_n    (`AXI_OVL_RSTn),
      .test_expr  (!ExclIdOverflow)
      );


//------------------------------------------------------------------------------
// INDEX:   2) Combinatorial Logic
//------------------------------------------------------------------------------


  //----------------------------------------------------------------------------
  // INDEX:      a) Masks
  //----------------------------------------------------------------------------


  // INDEX:           - AlignMaskR 
  // =====
  // Calculate wrap mask for read address
  always @(ARSIZE or ARVALID)
  begin
    if (ARVALID)
      case (ARSIZE)
        `AXI_ASIZE_1024:  AlignMaskR = 7'b0000000;
        `AXI_ASIZE_512:   AlignMaskR = 7'b1000000;
        `AXI_ASIZE_256:   AlignMaskR = 7'b1100000;
        `AXI_ASIZE_128:   AlignMaskR = 7'b1110000;
        `AXI_ASIZE_64:    AlignMaskR = 7'b1111000;
        `AXI_ASIZE_32:    AlignMaskR = 7'b1111100;
        `AXI_ASIZE_16:    AlignMaskR = 7'b1111110;
        `AXI_ASIZE_8:     AlignMaskR = 7'b1111111;
        default:          AlignMaskR = 7'b1111111;
      endcase
    else
      AlignMaskR = 7'b1111111;
  end


  // INDEX:           - AlignMaskW
  // =====
  // Calculate wrap mask for write address
  always @(AWSIZE or AWVALID)
  begin
    if (AWVALID)
      case (AWSIZE)
        `AXI_ASIZE_1024:  AlignMaskW = 7'b0000000;
        `AXI_ASIZE_512:   AlignMaskW = 7'b1000000;
        `AXI_ASIZE_256:   AlignMaskW = 7'b1100000;
        `AXI_ASIZE_128:   AlignMaskW = 7'b1110000;
        `AXI_ASIZE_64:    AlignMaskW = 7'b1111000;
        `AXI_ASIZE_32:    AlignMaskW = 7'b1111100;
        `AXI_ASIZE_16:    AlignMaskW = 7'b1111110;
        `AXI_ASIZE_8:     AlignMaskW = 7'b1111111;
        default:          AlignMaskW = 7'b1111111;
      endcase // case(AWSIZE)
    else
      AlignMaskW = 7'b1111111;
  end


  // INDEX:           - ExclMask
  // =====
  always @(ARLEN or ARSIZE)
  begin : p_ExclMaskComb
    ExclMask = ~((({7'b000_0000, ARLEN} + 11'b000_0000_0001) << ARSIZE) - 11'b000_0000_0001);
  end // block: p_ExclMaskComb


  // INDEX:           - WdataMask
  // =====
  always @(WSTRB)
  begin : p_WdataMaskComb
    integer i;  // data byte loop counter
    integer j;  // data bit loop counter

    for (i = 0; i < STRB_WIDTH; i = i + 1)
      for (j = i * 8; j <= (i * 8) + 7; j = j + 1)
        WdataMask[j] = WSTRB[i];
  end


  // INDEX:           - RdataMask
  // =====
  assign RdataMask = ReadDataMask(RBurstCam[RidMatch], RCountCam[RidMatch]);


  //----------------------------------------------------------------------------
  // INDEX:      b) Increments
  //----------------------------------------------------------------------------


  // INDEX:           - ArAddrIncr 
  // =====
  always @(ARSIZE or ARLEN or ARADDR)
  begin : p_RAddrIncrComb
    ArAddrIncr = ARADDR + (ARLEN << ARSIZE);  // The final address of the burst
  end


  // INDEX:           - AwAddrIncr
  // =====
  always @(AWSIZE or AWLEN or AWADDR)
  begin : p_WAddrIncrComb
    AwAddrIncr = AWADDR + (AWLEN << AWSIZE);  // The final address of the burst
  end


  //----------------------------------------------------------------------------
  // INDEX:      c) Conversions
  //----------------------------------------------------------------------------


  // INDEX:           - ArLenInBytes
  // =====
  always @(ARSIZE or ARLEN)
  begin : p_ArLenInBytes
    ArLenInBytes = (({8'h00, ARLEN} + 12'h001) << ARSIZE); // bytes = (ARLEN+1) data transfers x ARSIZE bytes
  end


  // INDEX:           - ArSizeInBits
  // =====
  always @(ARSIZE)
  begin : p_ArSizeInBits
    ArSizeInBits = (11'b000_0000_1000 << ARSIZE); // bits = 8 x ARSIZE bytes
  end


  // INDEX:           - AwSizeInBits
  // =====
  always @(AWSIZE)
  begin : p_AwSizeInBits
    AwSizeInBits = (11'b000_0000_1000 << AWSIZE); // bits = 8 x AWSIZE bytes
  end


  //----------------------------------------------------------------------------
  // INDEX:      d) Other
  //----------------------------------------------------------------------------


  // INDEX:           - ArExclPending
  // =====
  // Avoid putting on assertion directly as index is an integer
  assign ArExclPending = RBurstCam[RidMatch][EXCL];


  // INDEX:           - ArLenPending
  // =====
  // Avoid putting on assertion directly as index is an integer
  assign ArLenPending = {1'b0, RBurstCam[RidMatch][ALENHI:ALENLO]};

  // INDEX:           - ArCountPending
  // =====
  // Avoid putting on assertion directly as index is an integer
  assign ArCountPending = RCountCam[RidMatch];


//------------------------------------------------------------------------------
// INDEX:   3) EXCL & LOCK Accesses
//------------------------------------------------------------------------------


  // INDEX:        - Exclusive Access ID Lookup
  // =====
  // Map transaction IDs to the available exclusive access storage loactions

  // Lookup table for IDs used by the exclusive access monitor
  // Each location in the table has a valid flag to indicate if the ID is in use
  // The location of an ID flagged as valid is used as a virtual ID in the
  // exclusive access monitor checks
  always @(negedge `AXI_AUX_RSTn or posedge `AXI_AUX_CLK)
  begin : p_ExclIdSeq
    integer i;  // loop counter
    if (!`AXI_AUX_RSTn)
    begin
      ExclIdValid <= {EXMON_HI+1{1'b0}};
      ExclIdDelta <= 1'b0;
      for (i = 0; i <= EXMON_HI; i = i + 1)
      begin
        ExclId[i] <= {ID_WIDTH{1'b0}};
      end
    end
    else // clk edge
    begin
      // exclusive read address transfer
      if (ARVALID && ARREADY && (ARLOCK == `AXI_ALOCK_EXCL) &&
          !ExclIdFull)
      begin
        ExclId[ExclIdWrPtr] <= ARID;
        ExclIdValid[ExclIdWrPtr] <= 1'b1;
        ExclIdDelta <= ~ExclIdDelta;
      end
      // exclusive write
      if (AWVALID && AWREADY && (AWLOCK == `AXI_ALOCK_EXCL) &&
          ExclAwMatch)
      begin
        ExclIdValid[ExclAwId] <= 1'b0;
        ExclIdDelta <= ~ExclIdDelta;
      end
    end // else: !if(!`AXI_AUX_RSTn)
  end // block: p_ExclIdSeq

  // Lookup table is full when all valid bits are set
  assign ExclIdFull = &ExclIdValid;

  // Lookup table overflows when it is full and another exclusive read happens
  // with an ID that does not match any already being monitored
  assign ExclIdOverflow = ExclIdFull &&
                          ARVALID && ARREADY && (ARLOCK == `AXI_ALOCK_EXCL) &&
                          !ExclRMatch;

  // New IDs are written to the highest location
  // that does not have the valid flag set 
  always @(ExclIdValid or ExclIdDelta)
  begin : p_ExclIdFreePtrComb
    integer i;  // loop counter
    ExclIdFreePtr = 0;
    for (i = 0; i <= EXMON_HI; i = i + 1)
    begin
      if (ExclIdValid[i] == 1'b0)
      begin
        ExclIdFreePtr = i;
      end
    end
  end // p_ExclIdFreePtrComb

  // If the ID is already being monitored then reuse the location
  // New IDs are written to the highest location
  // that does not have the valid flag set 
  assign ExclIdWrPtr = ExclArMatch ? ExclArId : ExclIdFreePtr;

  // Write address ID comparator
  always @(AWVALID or AWID or ExclIdValid or ExclIdDelta)
  begin : p_ExclAwMatchComb
    integer i;  // loop counter
    ExclAwMatch = 1'b0;
    ExclAwId = {EXMON_WIDTH{1'b0}};
    if (AWVALID)
    begin
      for (i = 0; i <= EXMON_HI; i = i + 1)
      begin
        if (ExclIdValid[i] && (AWID == ExclId[i]))
        begin
          ExclAwMatch = 1'b1;
          ExclAwId = i;
        end
      end
    end
  end // p_ExclAwMatchComb

  // Read address ID comparator
  always @(ARVALID or ARID or ExclIdValid or ExclIdDelta)
  begin : p_ExclArMatchComb
    integer i;  // loop counter
    ExclArMatch = 1'b0;
    ExclArId = {EXMON_WIDTH{1'b0}};
    if (ARVALID)
    begin
      for (i = 0; i <= EXMON_HI; i = i + 1)
      begin
        if (ExclIdValid[i] && (ARID == ExclId[i]))
        begin
          ExclArMatch = 1'b1;
          ExclArId = i;
        end
      end
    end
  end // p_ExclArMatchComb

  // Read data ID comparator
  always @(RVALID or RID or ExclIdValid or ExclIdDelta)
  begin : p_ExclRMatchComb
    integer i;  // loop counter
    ExclRMatch = 1'b0;
    ExclRId = {EXMON_WIDTH{1'b0}};
    if (RVALID)
    begin
      for (i = 0; i <= EXMON_HI; i = i + 1)
      begin
        if (ExclIdValid[i] && (RID == ExclId[i]))
        begin
          ExclRMatch = 1'b1;
          ExclRId = i;
        end
      end
    end
  end // p_ExclRMatchComb

  // INDEX:        - Exclusive Access Storage
  // =====
  // Store exclusive control info on each read for checking against write

  always @(negedge `AXI_AUX_RSTn or posedge `AXI_AUX_CLK)
  begin : p_ExclCtrlSeq
    integer i;  // loop counter

    if (!`AXI_AUX_RSTn)
      for (i = 0; i <= EXMON_HI; i = i + 1)
      begin
        ExclReadAddr[i] <= 1'b0;
        ExclReadData[i] <= 1'b0;
        ExclAddr[i]     <= {ADDR_WIDTH{1'b0}};
        ExclSize[i]     <= 3'b000;
        ExclLen[i]      <= 4'h0;
        ExclBurst[i]    <= 2'b00;
        ExclCache[i]    <= 4'h0;
        ExclProt[i]     <= 3'b000;
        ExclUser[i]     <= {ARUSER_WIDTH{1'b0}};
      end
    else // clk edge
    begin
      // exclusive read address transfer
      if (ARVALID && ARREADY && (ARLOCK == `AXI_ALOCK_EXCL) &&
          !ExclIdFull)
      begin
        ExclReadAddr[ExclIdWrPtr] <= 1'b1; // set exclusive read addr flag for ARID
        ExclReadData[ExclIdWrPtr] <= 1'b0; // reset exclusive read data flag for ARID
        ExclAddr[ExclIdWrPtr]     <= ARADDR;
        ExclSize[ExclIdWrPtr]     <= ARSIZE;
        ExclLen[ExclIdWrPtr]      <= ARLEN;
        ExclBurst[ExclIdWrPtr]    <= ARBURST;
        ExclCache[ExclIdWrPtr]    <= ARCACHE;
        ExclProt[ExclIdWrPtr]     <= ARPROT;
        ExclUser[ExclIdWrPtr]     <= ARUSER;
      end
      // exclusive write
      if (AWVALID && AWREADY && (AWLOCK == `AXI_ALOCK_EXCL) &&
          ExclAwMatch)
      begin
        ExclReadAddr[ExclAwId] <= 1'b0; // reset exclusive address flag for AWID
        ExclReadData[ExclAwId] <= 1'b0; // reset exclusive read data flag for AWID
      end
      // completion of exclusive read data transaction
      if ((RVALID && RREADY && RLAST && ExclReadAddr[ExclRId] &&
           ExclRMatch) &&
           // check the read CAM that this is part of an exclusive transfer
           RBurstCam[RidMatch][EXCL]
         )
        ExclReadData[ExclRId]  <= 1'b1; // set exclusive read data flag for RID
    end // else: !if(!`AXI_AUX_RSTn)
  end // block: p_ExclCtrlSeq


  // INDEX:        - Lock State Machine
  // =====
  // The state machine transitions when address valid
  always @( ARLOCK or ARNew or
            AWLOCK or AWNew or
            LockState)
  begin : p_LockStateNextComb
    case (LockState)
      `AXI_AUX_ST_UNLOCKED :
        if ((ARNew & (ARLOCK == `AXI_ALOCK_LOCKED)) ||
            (AWNew & (AWLOCK == `AXI_ALOCK_LOCKED)))
          LockStateNext = `AXI_AUX_ST_LOCKED;
        else
          LockStateNext = `AXI_AUX_ST_UNLOCKED;

      `AXI_AUX_ST_LOCKED :
        if ((ARNew & (ARLOCK != `AXI_ALOCK_LOCKED)) ||
            (AWNew & (AWLOCK != `AXI_ALOCK_LOCKED)))
          LockStateNext = `AXI_AUX_ST_LOCK_LAST;
        else
          LockStateNext = `AXI_AUX_ST_LOCKED;

      `AXI_AUX_ST_LOCK_LAST :
        if ((ARNew & (ARLOCK == `AXI_ALOCK_LOCKED)) ||
            (AWNew & (AWLOCK == `AXI_ALOCK_LOCKED)))
          LockStateNext = `AXI_AUX_ST_LOCKED;

        else if ((ARNew & (ARLOCK != `AXI_ALOCK_LOCKED)) ||
                 (AWNew & (AWLOCK != `AXI_ALOCK_LOCKED)))
          LockStateNext = `AXI_AUX_ST_UNLOCKED;
        else
          LockStateNext = `AXI_AUX_ST_LOCK_LAST;

      `AXI_AUX_ST_NOT_USED : LockStateNext = 2'bXX;
                // Unreachable encoding, so X assigned for synthesis don't-care

      default            : LockStateNext = 2'bXX; // X-propagation
    endcase // case(LockState)
  end // always p_LockStateNextComb


  // INDEX:        - Lock State Register
  // =====
  always @(negedge `AXI_AUX_RSTn or posedge `AXI_AUX_CLK)
  begin : p_LockStateSeq
    if (!`AXI_AUX_RSTn)
    begin
      LockState <= `AXI_AUX_ST_UNLOCKED;
      LockId    <= {ID_WIDTH{1'b0}};
      LockCache <= 4'b0000;
      LockProt  <= 3'b000;
      LockAddr  <= {ADDR_WIDTH{1'b0}};
    end
    else
    begin
      LockState <= LockStateNext;
      LockId    <= LockIdNext;
      LockCache <= LockCacheNext;
      LockProt  <= LockProtNext;
      LockAddr  <= LockAddrNext;
    end
  end


  // INDEX:        - Lock Property Logic
  // =====

  // registering write/read ready/valid values
  always @(negedge `AXI_AUX_RSTn or posedge `AXI_AUX_CLK)
  begin : p_ValidReadyReg
    if (!`AXI_AUX_RSTn)
    begin
      PrevAWVALID <= 1'b0;
      PrevAWREADY <= 1'b0;
      PrevARVALID <= 1'b0;
      PrevARREADY <= 1'b0;
    end
    else
    begin
      PrevAWVALID <= AWVALID;
      PrevAWREADY <= AWREADY;
      PrevARVALID <= ARVALID;
      PrevARREADY <= ARREADY;
    end
  end

  // AWNew=1 for the first cycle valid of a write address
  assign AWNew = (AWVALID & ~PrevAWVALID) |
                 (AWVALID & PrevAWVALID & PrevAWREADY);

  // ARNew=1 for the first cycle valid of a read address
  assign ARNew = (ARVALID & ~PrevARVALID) |
                 (ARVALID & PrevARVALID & PrevARREADY);

  // AWLockNew=1 for the first cycle of the initial locking write address
  // valid for a locked sequence
  assign AWLockNew  = (
                        (LockState == `AXI_AUX_ST_UNLOCKED) ||
                        (LockState == `AXI_AUX_ST_LOCK_LAST)
                      ) & AWNew & (AWLOCK == `AXI_ALOCK_LOCKED);

  // ARLockNew=1 for the first cycle of the initial locking read address
  // valid for a locked sequence
  assign ARLockNew  = (
                        (LockState == `AXI_AUX_ST_UNLOCKED) ||
                        (LockState == `AXI_AUX_ST_LOCK_LAST)
                      ) & ARNew & (ARLOCK == `AXI_ALOCK_LOCKED);

  // AWLockLastNew=1 for the first cycle of the unlocking write address
  // valid for a locked sequence
  assign AWLockLastNew  = (LockState == `AXI_AUX_ST_LOCKED) &
                          AWNew & (AWLOCK != `AXI_ALOCK_LOCKED);

  // ARLockLastNew=1 for the first cycle of the unlocking read address
  // valid for a locked sequence
  assign ARLockLastNew  = (LockState == `AXI_AUX_ST_LOCKED) &
                          ARNew & (ARLOCK != `AXI_ALOCK_LOCKED);


  // Store the ID of the first locked transfer
  always @(AWLockNew or ARLockNew or
            LockId or AWID or ARID)
  begin : p_LockIdNextComb
    case ({ARLockNew,AWLockNew})
      2'b00 : LockIdNext = LockId;      // No new locked burst
      2'b01 : LockIdNext = AWID;        // New locked write burst
      2'b10 : LockIdNext = ARID;        // New locked read burst
      2'b11 : LockIdNext = AWID;        // Both new locked write and read bursts
      default : LockIdNext = {ID_WIDTH{1'bx}};  // X propagation
    endcase
  end // p_LockIdNextComb

  // Store the AxCACHE of the first locked transfer
  always @(AWLockNew or ARLockNew or
            LockCache or AWCACHE or ARCACHE)
  begin : p_LockCacheNextComb
    case ({ARLockNew,AWLockNew})
      2'b00 : LockCacheNext = LockCache;// No new locked burst
      2'b01 : LockCacheNext = AWCACHE;  // New locked write burst
      2'b10 : LockCacheNext = ARCACHE;  // New locked read burst
      2'b11 : LockCacheNext = AWCACHE;  // Both new locked write and read bursts
      default : LockCacheNext = 4'bxxxx;  // X propagation
    endcase
  end // p_LockCacheNextComb


  // Store the AxPROT of the first locked transfer
  always @(AWLockNew or ARLockNew or
            LockProt or AWPROT or ARPROT)
  begin : p_LockProtNextComb
    case ({ARLockNew,AWLockNew})
      2'b00 : LockProtNext = LockProt;  // No new locked burst
      2'b01 : LockProtNext = AWPROT;    // New locked write burst
      2'b10 : LockProtNext = ARPROT;    // New locked read burst
      2'b11 : LockProtNext = AWPROT;    // Both new locked write and read bursts
      default : LockProtNext = 3'bxxx;    // X propagation
    endcase
  end // p_LockProtNextComb

  // Store the AxADDR of the first locked transfer
  always @(AWLockNew or ARLockNew or
            LockAddr or AWADDR or ARADDR)
  begin : p_LockAddrNextComb
    case ({ARLockNew,AWLockNew})
      2'b00 : LockAddrNext = LockAddr;  // No new locked burst
      2'b01 : LockAddrNext = AWADDR;    // New locked write burst
      2'b10 : LockAddrNext = ARADDR;    // New locked read burst
      2'b11 : LockAddrNext = AWADDR;    // Both new locked write and read bursts
      default : LockAddrNext = {ADDR_WIDTH{1'bX}};  // X propagation
    endcase
  end // p_LockAddrNextComb


//------------------------------------------------------------------------------
// INDEX:   4) Content addressable memories (CAMs)
//------------------------------------------------------------------------------


  // INDEX:        - Read CAMSs (CAM+Shift) 
  // =====
  // New entries are added at the end of the CAM.
  // Elements may be removed from any location in the CAM, determined by the
  // first matching RID. When an element is removed, remaining elements
  // with a higher index are shifted down to fill the empty space.

  // Read CAMs store all outstanding addresses for read transactions
  assign RPush  = ARVALID & ARREADY;        // Push on address handshake
  assign RPop   = RVALID & RREADY & RLAST;  // Pop on last handshake

  // Flag when there are no outstanding read transactions
  assign nROutstanding = (RIndex == 1);

  // Find the index of the first item in the CAM that matches the current RID
  // (Note that RIdCamDelta is used to determine when RIdCam has changed)
  always @(RID or RIndex or RIdCamDelta)
  begin : p_RidMatch
    integer i;  // loop counter
    RidMatch = 0;
    for (i=MAXRBURSTS; i>0; i=i-1)
      if ((i < RIndex) && (RID == RBurstCam[i][IDHI:IDLO]))
        RidMatch = i;
  end

  // Update the flags indicating if RBurstCam contains locked/unlocked
  // transactions
  // (Note that RIdCamDelta is used to determine when RIdCam has changed)
  always @(RIndex or RIdCamDelta)
  begin : p_TxxRcamUpdate
    integer i; // loop counter
    UnlockedInRCam = 1'b0;
    LockedInRCam = 1'b0;
    for (i=MAXRBURSTS; i>0; i=i-1)
    begin
      if (i < RIndex)
      begin
        if (RBurstCam[i][LOCKED])
          LockedInRCam = 1'b1;
        else
          UnlockedInRCam = 1'b1;
      end
    end
  end

  // Combine cam flags with current bus state to drive the flags
  // indicating which types of lock read transactions are present
  // on the bus (if any)
  assign LockedRead   = LockedInRCam ||
                        (ARVALID && (ARLOCK == `AXI_ALOCK_LOCKED));
  assign UnlockedRead = UnlockedInRCam ||
                        (ARVALID && (ARLOCK != `AXI_ALOCK_LOCKED));

  // Calculate the index of the next free element in the CAM
  always @(RIndex or RPop or RPush)
  begin : p_RIndexNextComb
    case ({RPush,RPop})
      2'b00   : RIndexNext = RIndex;      // no push, no pop
      2'b01   : RIndexNext = RIndex - 1;  // pop, no push
      2'b10   : RIndexNext = RIndex + 1;  // push, no pop
      2'b11   : RIndexNext = RIndex;      // push and pop
      default : RIndexNext = 'bX;         // X-propagation
    endcase
  end
  //
  // RIndex Register
  always @(negedge `AXI_AUX_RSTn or posedge `AXI_AUX_CLK)
  begin : p_RIndexSeq
    if (!`AXI_AUX_RSTn)
      RIndex <= 1;
    else
      RIndex <= RIndexNext;
  end
  //
  // CAM Implementation
  always @(negedge `AXI_AUX_RSTn or posedge `AXI_AUX_CLK)
  begin : p_ReadCam
    reg [RBURSTMAX:0] Burst; // temporary store for burst data structure
    if (!`AXI_AUX_RSTn)
    begin : p_ReadCamReset
      integer i;  // loop counter
      // Reset all the entries in the CAM
      for (i=1; i<=MAXRBURSTS; i=i+1)
      begin
        RBurstCam[i] <= {RBURSTMAX+1{1'b0}};
        RCountCam[i] <= 5'h0;
        RIdCamDelta  <= 1'b0;
      end
    end
    else

    begin

      // Pop item from the CAM, at location determined by RidMatch
      if (RPop)
      begin : p_ReadCamPop
        integer i;  // loop counter
        // Delete item by shifting remaining items
        for (i=1; i<MAXRBURSTS; i=i+1)
          if (i >= RidMatch)
          begin
            RBurstCam[i] <= RBurstCam[i+1];
            RCountCam[i] <= RCountCam[i+1];
            RIdCamDelta <= ~RIdCamDelta;
          end
      end
      else
        // if not last data item, increment beat count
        if (RVALID & RREADY)
          RCountCam[RidMatch] <= RCountCam[RidMatch] + 5'h01;

      Burst[ADDRHI:ADDRLO]   = ARADDR[ADDRHI:ADDRLO];
      Burst[EXCL]            = (ARLOCK == `AXI_ALOCK_EXCL);
      Burst[LOCKED]          = (ARLOCK == `AXI_ALOCK_LOCKED);
      Burst[BURSTHI:BURSTLO] = ARBURST;
      Burst[ALENHI:ALENLO]   = ARLEN;
      Burst[ASIZEHI:ASIZELO] = ARSIZE;
      Burst[IDHI:IDLO]       = ARID;

      // Push item at end of the CAM
      // Note that the value of the final index in the CAM is depends on
      // whether another item has been popped
      if (RPush)
      begin
        if (RPop)
        begin
          RBurstCam[RIndex-1] <= Burst;
          RCountCam[RIndex-1] <= 5'h00;
        end
        else
        begin
          RBurstCam[RIndex]   <= Burst;
          RCountCam[RIndex]   <= 5'h00;
        end // else: !if(RPop)
        RIdCamDelta <= ~RIdCamDelta;
      end // if (RPush)
    end // else: if(!`AXI_AUX_RSTn)
  end // always @(negedge `AXI_AUX_RSTn or posedge `AXI_AUX_CLK)


  // INDEX:        - Write CAMs (CAM+Shift)
  // =====
  // New entries are added at the end of the CAM.
  // Elements may be removed from any location in the CAM, determined by the
  // first matching WID and/or BID. When an element is removed, remaining
  // elements with a higher index are shifted down to fill the empty space.


  // Write bursts stored in single structure for checking when complete.
  // This avoids the problem of early write data.
  always @(negedge `AXI_AUX_RSTn or posedge `AXI_AUX_CLK)
  begin : p_WriteCam
    reg [WBURSTMAX:0] Burst; // temporary store for burst data structure
    integer i;               // loop counter
    if (!`AXI_AUX_RSTn)
    begin : p_WriteCamReset
      for (i=1; i<=MAXWBURSTS; i=i+1)
      begin
        WBurstCam[i]  = {WBURSTMAX+1{1'b0}}; // initialise to zero on reset
        WCountCam[i]  = 5'b0; // initialise beat counters to zero
        WLastCam[i]   = 1'b0;
        WAddrCam[i]   = 1'b0;
        BRespCam[i]   = 1'b0;
      end
      WIndex   = 1;
      AidMatch = 1;
      BidMatch = 1;
      WidMatch = 1;
      Burst    = {WBURSTMAX+1{1'b0}};
      AWDataNumError  <= 1'b0;
      WDataNumError   <= 1'b0;
      WDataOrderError <= 1'b0;
      BrespError      <= 1'b0;
      BrespExokError  <= 1'b0;
      AWStrbError     <= 1'b0;
      BStrbError      <= 1'b0;
      BrespLeadingRec <= 1'b0;
      nWAddrTrans     <= 1'b1;
      UnlockedInWCam  <= 1'b0;
      LockedInWCam    <= 1'b0;
      FlagUNInWCam    <= 1'b0;
      FlagLOInWCam    <= 1'b0;
      FlagLLInWCam    <= 1'b0;
   end
    else
    begin
      // default is no errors
      AWDataNumError  <= 1'b0;
      WDataNumError   <= 1'b0;
      WDataOrderError <= 1'b0;
      BrespError      <= 1'b0;
      BrespExokError  <= 1'b0;
      AWStrbError     <= 1'b0;
      BStrbError      <= 1'b0;
      BrespLeadingRec <= 1'b0;

      // -----------------------------------------------------------------------
      // Valid write response
      if (BVALID)
      begin

        // Find matching burst
        begin : p_WriteCamMatchB

          BidMatch = WIndex; // default is no match
          for (i=MAXWBURSTS; i>0; i=i-1)
            if (i < WIndex) // only consider valid entries in WBurstCam
            begin
              Burst = WBurstCam[i];
              if (BID == Burst[IDHI:IDLO] && // BID matches, and
                  ~BRespCam[i]) // write response not already transferred
                BidMatch = i;
            end
        end // p_WriteCamMatchB

        Burst = WBurstCam[BidMatch];  // set temporary burst signal

        BRespCam[BidMatch] = BREADY;  // record if write response completed


        // Check that BID matches outstanding WID or AWID
        if (~(BidMatch < WIndex))
          BrespError <= 1'b1;         // trigger AXI_ERRS_BRESP 

        // The following checks are only performed if the write response matches
        // an existing burst
        else begin

          // Check all write data in burst is complete
          // Note: this test must occur before the WLastCam is updated
          if (~WLastCam[BidMatch]) // last data not received
            BrespError <= 1'b1;         // trigger AXI_ERRS_BRESP

          // Check for EXOKAY response to non-exclusive transaction
          if (Burst[EXCL] == 1'b0 && BRESP == `AXI_RESP_EXOKAY)
            BrespExokError <= 1'b1;

          // Check if a write address has not been received and
          // flag that this not recommended
          // This must be done before the CAMs are popped when the
          // the address has been received
          if (!WAddrCam[BidMatch])
            BrespLeadingRec <= 1'b1;

          // Write response handshake completes burst when write address has
          // already been received, and triggers protocol checking
          if (BREADY & WAddrCam[BidMatch])
          begin : p_WriteCamPopB
            // Check WSTRB
            BStrbError <= CheckBurst(WBurstCam[BidMatch], WCountCam[BidMatch]);

            // pop completed burst from CAM
            for (i = 1; i < MAXWBURSTS; i = i+1)
            begin
              if (i >= BidMatch) // only shift items after popped burst
              begin
                WBurstCam[i]   = WBurstCam[i+1];
                WCountCam[i]   = WCountCam[i+1];
                WLastCam[i]    = WLastCam[i+1];
                WAddrCam[i]    = WAddrCam[i+1];
                BRespCam[i]    = BRespCam[i+1];
              end
            end

            WIndex = WIndex - 1; // decrement index

            // Reset flags on new empty element
            WBurstCam[WIndex]  = {WBURSTMAX+1{1'b0}};
            WCountCam[WIndex]  = 5'b0;
            WLastCam[WIndex]   = 1'b0;
            WAddrCam[WIndex]   = 1'b0;
            BRespCam[WIndex]   = 1'b0;

          end // if (BREADY & WAddrCam[BidMatch])

        end // else !(~(BidMatch < WIndex))
      end // if (BVALID)

      // -----------------------------------------------------------------------
      // Valid write data
      if (WVALID)
      begin : p_WriteCamWValid

        // find matching burst in progress
        WidMatch = WIndex; // default - no match
        for (i = MAXWBURSTS; i > 0; i = i-1)
          if (i < WIndex) // only consider valid entries in WBurstCam
          begin
            Burst = WBurstCam[i];
            if (WID == Burst[IDHI:IDLO] &&  // ID matches
                ~WLastCam[i])             // not already received last data item
              WidMatch = i;
          end

        Burst = WBurstCam[WidMatch]; // temp store for 2-D burst lookup

        // if last data item or correct number of data items received already,
        // check number of data items and WLAST against AWLEN.
        // WCountCam hasn't yet incremented so can be compared with AWLEN
        if  ( WAddrCam[WidMatch] & // Only perform test if address is known
              ( (WLAST & (WCountCam[WidMatch] != {1'b0,Burst[ALENHI:ALENLO]})) |
                (~WLAST & (WCountCam[WidMatch] == {1'b0,Burst[ALENHI:ALENLO]}))
              )
            )
          WDataNumError <= 1'b1;

        // if 1st data item, check that earlier bursts have all got 1st data
        // item to enforce the AXI_ERRM_WDATA_ORDER protocol rule
        if (WCountCam[WidMatch] == 5'b0)
        begin
          for (i = 1; i <= MAXWBURSTS; i = i+1)
            if (i < WidMatch)
              if (WCountCam[i] == 0)
                WDataOrderError <= 1'b1;
        end

        // need to use full case statement to occupy WSTRB as in Verilog the
        // bit slice range must be bounded by constant expressions
        case (WCountCam[WidMatch])
          5'h0 : Burst[STRB1HI:STRB1LO]   = WSTRB;
          5'h1 : Burst[STRB2HI:STRB2LO]   = WSTRB;
          5'h2 : Burst[STRB3HI:STRB3LO]   = WSTRB;
          5'h3 : Burst[STRB4HI:STRB4LO]   = WSTRB;
          5'h4 : Burst[STRB5HI:STRB5LO]   = WSTRB;
          5'h5 : Burst[STRB6HI:STRB6LO]   = WSTRB;
          5'h6 : Burst[STRB7HI:STRB7LO]   = WSTRB;
          5'h7 : Burst[STRB8HI:STRB8LO]   = WSTRB;
          5'h8 : Burst[STRB9HI:STRB9LO]   = WSTRB;
          5'h9 : Burst[STRB10HI:STRB10LO] = WSTRB;
          5'hA : Burst[STRB11HI:STRB11LO] = WSTRB;
          5'hB : Burst[STRB12HI:STRB12LO] = WSTRB;
          5'hC : Burst[STRB13HI:STRB13LO] = WSTRB;
          5'hD : Burst[STRB14HI:STRB14LO] = WSTRB;
          5'hE : Burst[STRB15HI:STRB15LO] = WSTRB;
          5'hF : Burst[STRB16HI:STRB16LO] = WSTRB;
          default : Burst[STRB16HI:STRB16LO] = {STRB_WIDTH{1'bx}};
        endcase

        // Store the WID in the CAM
        Burst[IDHI:IDLO] = WID; // record ID in case address not yet received
        WBurstCam[WidMatch] = Burst; // copy back from temp store

        // when write data transfer completes, determine if last
        WLastCam[WidMatch] = WLAST & WREADY; // record whether last data completed

        // When transfer completes, increment the count
        WCountCam[WidMatch] =
          WREADY ? WCountCam[WidMatch] + 5'b00001:    // inc count
                   WCountCam[WidMatch];


        if (WidMatch == WIndex) // if new burst, increment CAM index
          WIndex = WIndex + 1;

      end // if (WVALID)

      // -----------------------------------------------------------------------
      // Valid write address
      if (AWVALID)
      begin

        // find matching burst in progress
        begin : p_WriteCamMatchAw

          AidMatch = WIndex; // assume no match

          for (i = MAXWBURSTS; i > 0; i = i-1)
            if (i < WIndex) // only consider valid entries in WBurstCam
            begin
              Burst = WBurstCam[i];
              if (AWID == Burst[IDHI:IDLO] &&  // AWID matches, and
                  ~WAddrCam[i]) // write address not already transferred
                AidMatch = i;
            end
        end // p_WriteCamMatchAw

        Burst = WBurstCam[AidMatch];

        Burst[ADDRHI:ADDRLO]   = AWADDR[ADDRHI:ADDRLO];
        Burst[EXCL]            = AWLOCK[0];
        Burst[LOCKED]          = (AWLOCK == `AXI_ALOCK_LOCKED);
        Burst[BURSTHI:BURSTLO] = AWBURST;
        Burst[ALENHI:ALENLO]   = AWLEN;
        Burst[ASIZEHI:ASIZELO] = AWSIZE;
        Burst[IDHI:IDLO]       = AWID;

        WBurstCam[AidMatch] = Burst;  // copy back from temp store

        WAddrCam[AidMatch] = AWREADY; // record if write address completed

        // assert protocol error flag if address received after leading write
        // data and:
        // - WLAST was asserted when the beat count is less than AWLEN
        // - WLAST was not asserted when the beat count is equal to AWLEN
        // - the beat count is greater than AWLEN
        if ((WLastCam[AidMatch] &
              (({1'b0, Burst[ALENHI:ALENLO]} + 5'b00001) > WCountCam[AidMatch])) ||
            (~WLastCam[AidMatch] &
              (({1'b0, Burst[ALENHI:ALENLO]} + 5'b00001) == WCountCam[AidMatch])) ||
            (({1'b0, Burst[ALENHI:ALENLO]} + 5'b00001) < WCountCam[AidMatch]))
          AWDataNumError <= 1'b1;

        // Check that earlier bursts have all got address to enforce the
        // AXI_ERRM_WDATA_ORDER protocol rule
        begin : p_WriteCamWdataOrder

          for (i = 1; i <= MAXWBURSTS; i=i+1)
            begin
              if (i < AidMatch)             // check all earlier bursts
                if (WAddrCam[i] != 1'b1)    // address not yet received
                  WDataOrderError <= 1'b1;  // trigger assertion
            end
        end // p_WriteCamWdataOrder

        // If new burst, increment CAM index
        if (AidMatch == WIndex)
          WIndex = WIndex + 1;

        // Write address handshake completes burst when write response has
        // already been received, and triggers protocol checking
        else if (AWREADY & BRespCam[AidMatch])
        begin : p_WriteCamPopAw
          // Check WSTRB
          AWStrbError <= CheckBurst(WBurstCam[AidMatch], WCountCam[AidMatch]);

          // pop completed burst from CAM
          for (i = 1; i < MAXWBURSTS; i = i+1)
            if (i >= AidMatch) // only shift items after popped burst
            begin
              WBurstCam[i]    = WBurstCam[i+1];
              WCountCam[i]    = WCountCam[i+1];
              WLastCam[i]     = WLastCam[i+1];
              WAddrCam[i]     = WAddrCam[i+1];
              BRespCam[i]     = BRespCam[i+1];
            end

          WIndex = WIndex - 1; // decrement index

          // Reset flags on new empty element
          WBurstCam[WIndex]  = {WBURSTMAX+1{1'b0}};
          WCountCam[WIndex]  = 5'b0;
          WLastCam[WIndex]   = 1'b0;
          WAddrCam[WIndex]   = 1'b0;
          BRespCam[WIndex]   = 1'b0;

        end // if (AWREADY & BRespCam[AidMatch])

      end // new write address

      // Update all write transactions with the coincident transaction info
      // given by the locked/unlocked flags and the lock state of the
      // current cycle
      for (i = 1; i <= MAXWBURSTS; i = i+1)
      begin
        if (i < WIndex) // only consider valid entries in WBurstCam
        begin
          case (LockStateNext)
            `AXI_AUX_ST_UNLOCKED :
            begin
              if (UnlockedRead | UnlockedWrite)
                WBurstCam[i][FLAGUN] = 1'b1;
              if (LockedRead | LockedWrite)
                WBurstCam[i][FLAGLO] = 1'b1;
            end
            `AXI_AUX_ST_LOCKED :
            begin
              if (UnlockedRead | UnlockedWrite)
                WBurstCam[i][FLAGUN] = 1'b1;
              if (LockedRead | LockedWrite)
                WBurstCam[i][FLAGLO] = 1'b1;
            end
            `AXI_AUX_ST_LOCK_LAST :
            begin
              if (UnlockedRead | UnlockedWrite)
                WBurstCam[i][FLAGLL] = 1'b1;
              if (LockedRead | LockedWrite)
                WBurstCam[i][FLAGLO] = 1'b1;
            end
            `AXI_AUX_ST_NOT_USED :
              ; // Unreachable, don't-care
            default : ; // Unreachable, don't-care
          endcase // case (LockState)
        end
      end

      // Check for an empty WAddrCam, clearing the nWAddrTrans flag
      // if any write addresses are present
      // Update the flags indicating if WBurstCam contains locked/unlocked
      // transactions and bus state flags
      nWAddrTrans    <= 1'b1;
      UnlockedInWCam <= 1'b0;
      LockedInWCam   <= 1'b0;
      FlagUNInWCam   <= 1'b0;
      FlagLOInWCam   <= 1'b0;
      FlagLLInWCam   <= 1'b0;
      for (i = 1; i <= MAXWBURSTS; i = i+1)
      begin
        if (i < WIndex) // only consider valid entries in WBurstCam
        begin
          if (WBurstCam[i][FLAGUN])
            FlagUNInWCam <= 1'b1;
          if (WBurstCam[i][FLAGLO])
            FlagLOInWCam <= 1'b1;
          if (WBurstCam[i][FLAGLL])
            FlagLLInWCam <= 1'b1;
          if (WAddrCam[i])
          begin
            nWAddrTrans <= 1'b0;
            if (WBurstCam[i][LOCKED])
              LockedInWCam <= 1'b1;
            else
              UnlockedInWCam <= 1'b1;
          end
        end
      end

    end // else: !if(!`AXI_AUX_RSTn)
  end // always @(negedge `AXI_AUX_RSTn or posedge `AXI_AUX_CLK)

  // Combine cam flags with current bus state to drive the flags
  // indicating which types of lock write transactions are present
  // on the bus (if any)
  assign LockedWrite   = LockedInWCam ||
                        (AWVALID && (AWLOCK == `AXI_ALOCK_LOCKED));
  assign UnlockedWrite = UnlockedInWCam ||
                        (AWVALID && (AWLOCK != `AXI_ALOCK_LOCKED));

  assign StrbError = AWStrbError | BStrbError;

  assign WriteDataNumError = AWDataNumError | WDataNumError;


  // INDEX:        - Write Depth array
  // =====
  // Array monitors interleaved write data

  // Lookup table for IDs used by the exclusive access monitor
  // Each location in the table has a valid flag to indicate if the ID is in use
  always @(negedge `AXI_AUX_RSTn or posedge `AXI_AUX_CLK)
  begin : p_WdepthIdSeq
    integer i;  // loop counter
    if (!`AXI_AUX_RSTn)
    begin
      WdepthIdValid <= {WDEPTH+1{1'b0}};
      WdepthIdDelta <= 1'b0;
      for (i = 0; i <= WDEPTH; i = i + 1)
      begin
        WdepthId[i] <= {ID_WIDTH{1'b0}};
      end
    end
    else // clk edge
    begin
      // write transfer
      if (WVALID && WREADY &&
          !WdepthIdFull)
      begin
        WdepthId[WdepthIdWrPtr] <= WID;
        WdepthIdValid[WdepthIdWrPtr] <= !WLAST;
        WdepthIdDelta <= ~WdepthIdDelta;
      end
    end // else: !if(!`AXI_AUX_RSTn)
  end // block: p_WdepthIdSeq

  // Lookup table is full when all valid bits are set
  assign WdepthIdFull = &WdepthIdValid;

  // New IDs are written to the highest location
  // that does not have the valid flag set 
  always @(WdepthIdValid or WdepthIdDelta)
  begin : p_WdepthIdFreePtrComb
    integer i;  // loop counter
    WdepthIdFreePtr = 0;
    for (i = 0; i <= WDEPTH; i = i + 1)
    begin
      if (WdepthIdValid[i] == 1'b0)
      begin
        WdepthIdFreePtr = i;
      end
    end
  end // p_WdepthIdFreePtrComb

  // If the ID is already being monitored then reuse the location
  // New IDs are written to the highest location
  // that does not have the valid flag set 
  assign WdepthIdWrPtr = WdepthWMatch ? WdepthWId : WdepthIdFreePtr;

  // Write address ID comparator
  always @(WVALID or WID or WdepthIdValid or WdepthIdDelta)
  begin : p_WdepthWMatchComb
    integer i;  // loop counter
    WdepthWMatch = 1'b0;
    WdepthWId = {WDEPTH+1{1'b0}};
    if (WVALID)
    begin
      for (i = 0; i <= WDEPTH; i = i + 1)
      begin
        if (WdepthIdValid[i] && (WID == WdepthId[i]))
        begin
          WdepthWMatch = 1'b1;
          WdepthWId = i;
        end
      end
    end
  end // p_WdepthWMatchComb

  // Sum the bits from the WidInUse register to give the current write depth
  always @(WdepthIdValid or WdepthWMatch or WVALID)
  begin : p_WidDepthComb
    integer id; // loop counter
    WidDepth = 0;
    for (id = 0; id <= WDEPTH; id = id + 1)
    begin
      if (WdepthIdValid[id] == 1'b1)
      begin
        WidDepth = 1 + WidDepth;
      end
    end
    // Add one if a new WID is in use
    if (WVALID && !WdepthWMatch)
    begin
      WidDepth = WidDepth + 1'b1;
    end
  end // p_WidDepthComb


//------------------------------------------------------------------------------
// INDEX:   5) Verilog Functions
//------------------------------------------------------------------------------


  // INDEX:        - CheckBurst
  // =====
  // Inputs: Burst (burst data structure)
  //         Count (number of data items)
  // Returns: High is any of the write strobes are illegal
  // Calls CheckStrb to test each WSTRB value.
  //------------------------------------------------------------------------------
  function CheckBurst;
    input [WBURSTMAX:0] Burst;         // burst vector
    input         [5:0] Count;         // number of beats in the burst
    integer             loop;          // general loop counter
    integer             NumBytes;      // number of bytes in the burst
    reg           [6:0] StartAddr;     // start address of burst
    reg           [6:0] StrbAddr;      // address used to check WSTRB
    reg           [2:0] StrbSize;      // size used to check WSTRB
    reg           [3:0] StrbLen;       // length used to check WSTRB
    reg    [STRB_MAX:0] Strb;          // WSTRB to be checked
    reg           [9:0] WrapMaskWide;  // address mask for wrapping bursts
    reg           [6:0] WrapMask;      // relevant bits WrapMaskWide
  begin

    StartAddr   = Burst[ADDRHI:ADDRLO];
    StrbAddr    = StartAddr; // incrementing address initialises to start addr
    StrbSize    = Burst[ASIZEHI:ASIZELO];
    StrbLen     = Burst[ALENHI:ALENLO];
    CheckBurst  = 1'b0;

    // Initialize to avoid latch warnings (not really latches as they are set in loop)
    Strb         = {STRB_WIDTH{1'bX}};
    WrapMask     =          {7{1'bX}};
    WrapMaskWide =         {10{1'bX}};

    // determine the number of bytes in the burst for wrapping purposes
    NumBytes = (StrbLen + 1) << StrbSize;

    // Check the strobe for each write data transfer
    for (loop=1; loop<=16; loop=loop+1)
    begin
      if (loop <= Count) // Only consider entries up to burst length
      begin

        // Need to use full case statement to index WSTRB as in Verilog the
        // bit slice range must be bounded by constant expressions
        case (loop)
          1  : Strb = Burst[STRB1HI:STRB1LO];
          2  : Strb = Burst[STRB2HI:STRB2LO];
          3  : Strb = Burst[STRB3HI:STRB3LO];
          4  : Strb = Burst[STRB4HI:STRB4LO];
          5  : Strb = Burst[STRB5HI:STRB5LO];
          6  : Strb = Burst[STRB6HI:STRB6LO];
          7  : Strb = Burst[STRB7HI:STRB7LO];
          8  : Strb = Burst[STRB8HI:STRB8LO];
          9  : Strb = Burst[STRB9HI:STRB9LO];
          10 : Strb = Burst[STRB10HI:STRB10LO];
          11 : Strb = Burst[STRB11HI:STRB11LO];
          12 : Strb = Burst[STRB12HI:STRB12LO];
          13 : Strb = Burst[STRB13HI:STRB13LO];
          14 : Strb = Burst[STRB14HI:STRB14LO];
          15 : Strb = Burst[STRB15HI:STRB15LO];
          16 : Strb = Burst[STRB16HI:STRB16LO];
          default : Strb = {STRB_WIDTH{1'bx}};
        endcase

        // returns high if any strobes are illegal
        if (CheckStrb(StrbAddr, StrbSize, Strb))
        begin
          CheckBurst = 1'b1;
        end

        // -----------------------------------------------------------------------
        // Increment aligned StrbAddr
        if (Burst[BURSTHI:BURSTLO] != `AXI_ABURST_FIXED)
          // fixed bursts don't increment or align the address
        begin
          // align and increment address,
          // Address is incremented from an aligned version
          StrbAddr = StrbAddr &
            (7'b111_1111 - (7'b000_0001 << StrbSize) + 7'b000_0001);
                                                                // align to size
          StrbAddr = StrbAddr + (7'b000_0001 << StrbSize);      // increment
        end // if (Burst[BURSTHI:BURSTLO] != `AXI_ABURST_FIXED)

        // for wrapping bursts the top bits of the strobe address remain fixed
        if (Burst[BURSTHI:BURSTLO] == `AXI_ABURST_WRAP)
        begin
          WrapMaskWide = (10'b11_1111_1111 - NumBytes + 10'b00_0000_0001);
                                            // To wrap the address, need 10 bits
          WrapMask = WrapMaskWide[6:0];
                    // Only 7 bits of address are necessary to calculate strobe
          StrbAddr = (StartAddr & WrapMask) | (StrbAddr & ~WrapMask);
                // upper bits remain stable for wrapping bursts depending on the
                // number of bytes in the burst
        end
      end // if (loop < Count)
    end // for (loop=1; loop<=WDEPTH; loop=loop+1)
  end
  endfunction // CheckBurst


  // INDEX:        - CheckStrb
  // =====
  function CheckStrb;
    input        [6:0] StrbAddr;
    input        [2:0] StrbSize;
    input [STRB_MAX:0] Strb;
    reg   [STRB_MAX:0] StrbMask;
  begin

    // The basic strobe for an aligned address
    StrbMask = (STRB_1 << (STRB_1 << StrbSize)) - STRB_1;

    // Zero the unaligned byte lanes
    // Note: the number of unaligned byte lanes is given by:
    // (StrbAddr & ((1 << StrbSize) - 1)), i.e. the unaligned part of the
    // address with respect to the transfer size
    //
    // Note! {{STRB_MAX{1'b0}}, 1'b1} gives 1 in the correct vector length

    StrbMask = StrbMask &                   // Mask off unaligned byte lanes
      (StrbMask <<                          // shift the strb mask left by
        (StrbAddr & ((STRB_1 << StrbSize) -  STRB_1))
                                            // the number of unaligned byte lanes
      );

    // Shift mask into correct byte lanes
    // Note: (STRB_MAX << StrbSize) & STRB_MAX is used as a mask on the address
    // to pick out the bits significant bits, with respect to the bus width and
    // transfer size, for shifting the mask to the correct byte lanes.
    StrbMask = StrbMask << (StrbAddr & ((STRB_MAX << StrbSize) & STRB_MAX));

    // check for strobe error
    CheckStrb = (|(Strb & ~StrbMask));

  end
  endfunction // CheckStrb


  // INDEX:        - ReadDataMask
  // =====
  // Inputs: Burst (Burst data structure)
  //         Beat  (Data beat number)
  // Returns: Read data mask for valid byte lanes.
  //------------------------------------------------------------------------------
  function [DATA_MAX:0] ReadDataMask;
    input [STRB16HI:0] Burst;         // burst vector
    input [5:0]        Beat;          // beat number in the burst (0-15)
    reg   [11:0] bit_count;
    reg   [DATA_MAX+1:0] byte_mask;
  begin
    bit_count = ByteCount(Burst, Beat) << 3;
    byte_mask = (1'b1 << bit_count) - 1;
    // Result is the valid byte mask shifted by the calculated bit shift
    ReadDataMask = byte_mask[DATA_MAX:0] << (ByteShift(Burst, Beat)*8);
  end
  endfunction // ReadDataMask


  // INDEX:        - ByteShift
  // =====
  // Inputs: Burst (Burst data structure)
  //         Beat  (Data beat number)
  // Returns: Byte Shift for valid byte lanes.
  //------------------------------------------------------------------------------
  function [DATA_MAX:0] ByteShift;
    input [STRB16HI:0] Burst;         // burst vector
    input [5:0]        Beat;          // beat number in the burst (0-15)
    reg   [6:0]        axaddr;
    reg   [2:0]        axsize;
    reg   [3:0]        axlen;
    reg   [1:0]        axburst;
    integer bus_data_bytes;
    integer length;
    integer unaligned_byte_shift;
    integer beat_addr_inc;
    integer addr_trans_bus;
    integer addr_trans_bus_inc;
    integer wrap_point;
    integer transfer_byte_shift;
  begin
    axaddr  = Burst[ADDRHI:ADDRLO];
    axsize  = Burst[ASIZEHI:ASIZELO];
    axlen   = Burst[ALENHI:ALENLO];
    axburst = Burst[BURSTHI:BURSTLO];

    bus_data_bytes = STRB_WIDTH;

    length = axlen + 1;

    // Number of bytes that the data needs to be shifted when
    // the address is unaligned
    unaligned_byte_shift =
      axaddr &               // Byte address
      ((1<<axsize)-1);       //   masked by the number of bytes
                             //   in a transfer

    // Burst beat address increment
    beat_addr_inc = 0;
    // For a FIXED burst ther is no increment
    // For INCR and WRAP it is the beat number minus 1
    if (axburst != 0)
    begin
      beat_addr_inc = Beat;
    end

    // Transfer address within data bus
    // The root of the transfer address within the data bus is byte address
    // divided by the number of bytes in each transfer. This is also masked
    // so that the upper bits that do not control the byte shift are not
    // included.
    addr_trans_bus = (axaddr & (bus_data_bytes - 1))>>axsize;

    // The address may increment with each beat. The increment will be zero
    // for a FIXED burst.
    addr_trans_bus_inc = addr_trans_bus + beat_addr_inc;

    // Modify the byte shift for wrapping bursts
    if (axburst == 2)
    begin
      // The upper address of the transfer before wrapping
      wrap_point = length + (addr_trans_bus & ~(length - 1));
      // If adding the beat number to the transfer address causes it to
      // pass the upper wrap address then wrap to the lower address.
      if (addr_trans_bus_inc >= wrap_point)
      begin
        addr_trans_bus_inc = addr_trans_bus_inc - length;
      end
    end

    // Address calculation may exceed the number of transfers that can fit
    // in the data bus for INCR bursts. So the calculation is truncated to
    // make the byte shift wrap round to zero. 
    addr_trans_bus_inc = addr_trans_bus_inc & ((bus_data_bytes-1)>>axsize);

    // Number of bytes that the data needs to be shifted when
    // the transfer size is less than the data bus width
    transfer_byte_shift = (1<<axsize) *     // Number of bytes in a transfer
                          addr_trans_bus_inc;// Transfer address within data bus

    // For a FIXED burst or on the frist beat of an INCR burst
    // shift the data if the address is unaligned
    if ((axburst == 0) || ((axburst == 1) && (Beat == 0)))
    begin
      ByteShift = transfer_byte_shift + unaligned_byte_shift;
    end
    else
    begin
      ByteShift = transfer_byte_shift;
    end
  end
  endfunction // ByteShift


  // INDEX:        - ByteCount
  // =====
  // Inputs: Burst (Burst data structure)
  //         Beat  (Data beat number)
  // Returns: Byte Count of valid byte lanes.
  //------------------------------------------------------------------------------
  function [7:0] ByteCount;
    input [STRB16HI:0] Burst;         // burst vector
    input [5:0]        Beat;          // beat number in the burst (0-15)
    reg   [6:0]        axaddr;
    reg   [2:0]        axsize;
    reg   [3:0]        axlen;
    reg   [1:0]        axburst;
    integer bus_data_bytes;
    integer unaligned_byte_shift;
  begin
    axaddr  = Burst[ADDRHI:ADDRLO];
    axsize  = Burst[ASIZEHI:ASIZELO];
    axlen   = Burst[ALENHI:ALENLO];
    axburst = Burst[BURSTHI:BURSTLO];

    bus_data_bytes = STRB_WIDTH;

    // Number of bytes that the data needs to be shifted when
    // the address is unaligned
    unaligned_byte_shift =
      axaddr &              // Byte address
      ((1<<axsize)-1);      //   masked by the number of bytes
                            //   in a transfer

    // The number of valid bits depends on the transfer size.
    ByteCount = (1<<axsize);

    // For FIXED bursts or on the first beat of an INCR burst
    // if the address is unaligned modify the number of
    // valid strobe bits
    if ((axburst == 0) || (Beat == 0))
    begin
      // The number of valid bits depends on the transfer size
      // and the offset of the unaligned address.
      ByteCount = ByteCount - unaligned_byte_shift;
    end
  end
  endfunction // ByteCount


//------------------------------------------------------------------------------
// INDEX:
// INDEX: End of File
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// INDEX:   1) Clear Verilog Defines
//------------------------------------------------------------------------------

  // Lock FSM States (3-state FSM, so one state encoding is not used)
  `undef AXI_AUX_ST_UNLOCKED
  `undef AXI_AUX_ST_LOCKED
  `undef AXI_AUX_ST_LOCK_LAST
  `undef AXI_AUX_ST_NOT_USED

  // Clock and Reset
  `undef AXI_AUX_CLK
  `undef AXI_OVL_CLK
  `undef AXI_AUX_RSTn
  `undef AXI_OVL_RSTn

  // OVL Severity levels
  `undef AXI_SimFatal
  `undef AXI_SimError
  `undef AXI_SimWarning

  // Others
  `undef AXI_ANTECEDENT
  `ifdef AXI_USE_OLD_OVL
    `ifdef ASSERT_END_OF_SIMULATION
      `undef AXI_END_OF_SIMULATION
    `endif
  `else
    `ifdef OVL_END_OF_SIMULATION
      `undef AXI_END_OF_SIMULATION
    `endif
    `ifdef OVL_XCHECK_OFF
      `undef AXI_XCHECK_OFF
    `endif
  `endif


//------------------------------------------------------------------------------
// INDEX:   2) End of module
//------------------------------------------------------------------------------

endmodule // AxiPC
