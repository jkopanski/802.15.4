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
//  File Revision       : 123769
//
//  Date                :  2012-01-18 14:46:52 +0000 (Wed, 18 Jan 2012)
//  
//  Release Information : BP065-BU-01000-r0p1-00rel0
//  
//  ----------------------------------------------------------------------------
//  Purpose             : ACE SV Protocol Assertions Error Message unundefs
//  ========================================================================--


`ifdef ACEPC_MESSAGES
  `undef ACEPC_MESSAGES
  `include "Axi4PC_ace_message_undefs.v"
  `undef ERRM_AWDOMAIN_STABLE
  `undef ERRM_AWSNOOP_STABLE
  `undef ERRM_AWBAR_STABLE
  `undef ERRM_ARDOMAIN_STABLE
  `undef ERRM_ARSNOOP_STABLE
  `undef ERRM_ARBAR_STABLE
  `undef ERRM_AR_BARRIER_ID
  `undef ERRM_AW_BARRIER_ID
  `undef ERRM_AWCACHE_DEVICE
  `undef ERRM_ARCACHE_DEVICE
  `undef ERRM_AWCACHE_SYSTEM
  `undef ERRM_ARCACHE_SYSTEM
  `undef ERRM_DVM_CTL
  `undef ERRM_DVM_COMPLETE_CTL
  `undef ERRS_DVM_COMPLETE_CTL
  `undef ERRM_R_W_BARRIER_CTL
  `undef ERRM_AR_NORMAL_ID
  `undef ERRM_AW_NORMAL_ID
  `undef ERRM_R_BARRIER_NUM
  `undef ERRM_W_BARRIER_NUM
  `undef AUX_CACHE_LINE_SIZE
  `undef AUX_CACHE_DATA_WIDTH32
  `undef AUX_CACHE_DATA_WIDTH64
  `undef AUX_CACHE_DATA_WIDTH128
  `undef AUX_CACHE_DATA_WIDTH256
  `undef AUX_CACHE_DATA_WIDTH512
  `undef AUX_CACHE_DATA_WIDTH1024
  `undef AUX_CD_DATA_WIDTH
  `undef RECM_ACREADY_MAX_WAIT
  `undef RECS_CRREADY_MAX_WAIT
  `undef RECS_CDREADY_MAX_WAIT
  `undef AUX_MAXCBURSTS
  `undef ERRS_RRESP_IN_SNOOP
  `undef REC_SW_RRESP_IN_SNOOP
  `undef ERRS_AC_IN_RRESP
  `undef REC_SW_AC_IN_RRESP
  `undef ERRS_BRESP_IN_SNOOP
  `undef REC_SW_BRESP_IN_SNOOP
  `undef ERRS_AC_IN_BRESP
  `undef REC_SW_AC_IN_BRESP
  `undef ERRM_CRRESP_IN_WB_WC
  `undef ERRM_AR_IN_CMAINT
  `undef ERRM_AW_IN_CMAINT
  `undef ERRM_CMAINT_IN_READ
  `undef ERRM_CMAINT_IN_WRITE
  `undef ERRM_CRRESP_DVM_ERROR
  `undef ERRM_CRRESP_DVM
  `undef ERRM_DVM_SYNC
  `undef ERRS_DVM_COMPLETE
  `undef ERRM_DVM_COMPLETE
  `undef ERRM_DVM_TYPES
  `undef ERRS_DVM_TYPES
  `undef ERRM_DVM_RESVD_1
  `undef ERRM_DVM_RESVD_2
  `undef ERRM_DVM_RESVD_3
  `undef ERRM_DVM_RESVD_4
  `undef ERRM_DVM_MULTIPART_ID
  `undef ERRM_DVM_MULTIPART_SUCCESSIVE
  `undef ERRS_DVM_MULTIPART_SUCCESSIVE
  `undef ERRM_DVM_ID
  `undef ERRS_DVM_RESVD_1
  `undef ERRS_DVM_RESVD_2
  `undef ERRS_DVM_RESVD_3
  `undef ERRS_DVM_RESVD_4
  `undef ERRM_DVM_TLB_INV
  `undef ERRS_DVM_TLB_INV
  `undef ERRM_DVM_BP_INV
  `undef ERRS_DVM_BP_INV
  `undef ERRM_DVM_PHY_INV
  `undef ERRS_DVM_PHY_INV
  `undef ERRM_DVM_VIR_INV
  `undef ERRS_DVM_VIR_INV
  `undef ERRS_DVM_MULTIPART_RRESP
  `undef ERRM_DVM_MULTIPART_CRRESP
  `undef ERRS_RRESP_DVM_ERROR
  `undef ERRS_RRESP_DVM
  `undef ERRM_AWSNOOP
  `undef ERRM_AW_BLOCK_1
  `undef ERRM_AW_BLOCK_2
  `undef ERRM_AW_FULL_LINE
  `undef ERRM_AW_SHAREABLE_ALIGN_INCR
  `undef ERRM_AW_SHAREABLE_ALIGN_WRAP
  `undef ERRM_AW_SHAREABLE_LOCK
  `undef ERRM_AW_SHAREABLE_CTL
  `undef ERRM_AW_DOMAIN_1
  `undef ERRM_AW_DOMAIN_2
  `undef ERRM_WB_WC_CACHE_LINE_BOUNDARY_INCR
  `undef ERRM_WB_WC_CACHE_LINE_BOUNDARY_WRAP
  `undef RECM_W_R_HAZARD
  `undef RECM_W_W_HAZARD
  `undef ERRM_AWDOMAIN_X
  `undef ERRM_AWBAR_X
  `undef ERRM_AWSNOOP_X
  `undef ERRM_WLU_STRB
  `undef ERRS_BRESP_WNS_EXOKAY
  `undef ERRS_BRESP_BAR
  `undef ERRS_BRESP_AW_WLAST
  `undef ERRM_WACK_X
  `undef ERRM_ARSNOOP
  `undef ERRM_AR_FULL_LINE
  `undef ERRM_AR_SHAREABLE_LOCK
  `undef ERRM_AR_SHAREABLE_CTL
  `undef ERRM_AR_DOMAIN_2
  `undef ERRM_AR_DOMAIN_1
  `undef ERRM_AR_SHAREABLE_ALIGN_INCR
  `undef RECM_R_W_HAZARD
  `undef ERRM_ARDOMAIN_X
  `undef ERRM_ARBAR_X
  `undef ERRM_ARSNOOP_X
  `undef ERRS_RRESP_SHARED
  `undef ERRS_RRESP_DIRTY
  `undef ERRS_RRESP_RNSD
  `undef ERRS_RRESP_ACE_EXOKAY
  `undef ERRS_RRESP_BAR
  `undef ERRS_DVM_LAST
  `undef ERRS_R_BARRIER_LAST
  `undef ERRS_RDATALESS
  `undef ERRS_RRESP_CONST
  `undef ERRM_RACK_X
  `undef ERRS_AC_ALIGN
  `undef ERRS_ACSNOOP
  `undef ERRS_ACVALID_RESET
  `undef ERRS_ACVALID_STABLE
  `undef ERRS_ACADDR_STABLE
  `undef ERRS_ACSNOOP_STABLE
  `undef ERRS_ACPROT_STABLE
  `undef ERRS_ACVALID_X
  `undef ERRM_ACREADY_X
  `undef ERRS_ACADDR_X
  `undef ERRS_ACPROT_X
  `undef ERRS_ACSNOOP_X
  `undef ERRM_CR_ORDER
  `undef ERRM_CRRESP_DIRTY
  `undef ERRM_CRRESP_SHARED
  `undef ERRM_CRVALID_RESET
  `undef ERRM_CRVALID_STABLE
  `undef ERRM_CRRESP_STABLE
  `undef ERRM_CRVALID_X
  `undef ERRS_CRREADY_X
  `undef ERRM_CRRESP_X
  `undef ERRM_CDDATA_NUM
  `undef ERRM_CD_ORDER
  `undef ERRM_CDVALID_RESET
  `undef ERRM_CDVALID_STABLE
  `undef ERRM_CDDATA_STABLE
  `undef ERRM_CDLAST_STABLE
  `undef ERRM_CDVALID_X
  `undef ERRS_CDREADY_X
  `undef ERRM_CDLAST_X
  `undef ERRM_CDDATA_X
  `undef AUX_ACCAM_OVERFLOW
  `undef AUX_ACCAM_UNDERFLOW
  `undef ERRM_RACK
  `undef AUX_ARCAM_OVERFLOW
  `undef AUX_ARCAM_UNDERFLOW
  `undef ERRM_AR_BARRIER_CTL
  `undef ERRM_AW_BARRIER_CTL
  `undef ERRM_WACK
  `undef AUX_AWCAM_OVERFLOW
  `undef AUX_AWCAM_UNDERFLOW
  `undef ERRM_R_W_BARRIER_EOS
  `undef ERRM_RACK_EOS
  `undef ERRM_WACK_EOS
  `undef ERRM_AC_EOS
  `undef ERR_W_EOS
  `undef ERRM_ARSNOOP_LITE
  `undef ERRM_AWSNOOP_LITE
  `undef ERRM_XSTORE_IN_XSEQ
  `undef AUX_MAX_BARRIERS_LITE

`endif
// --========================= End ===========================================--
