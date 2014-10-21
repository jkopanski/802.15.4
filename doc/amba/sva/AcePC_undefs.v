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


// Defines for ARSNOOP values
`undef ACEPC_ARSNOOP_READONCE           
`undef ACEPC_ARSNOOP_READSHARED         
`undef ACEPC_ARSNOOP_READCLEAN          
`undef ACEPC_ARSNOOP_READNOTSHAREDDIRTY 
`undef ACEPC_ARSNOOP_READUNIQUE         
`undef ACEPC_ARSNOOP_CLEANSHARED        
`undef ACEPC_ARSNOOP_CLEANINVALID       
`undef ACEPC_ARSNOOP_CLEANUNIQUE        
`undef ACEPC_ARSNOOP_MAKEUNIQUE         
`undef ACEPC_ARSNOOP_MAKEINVALID        

`undef ACEPC_ARSNOOP_DVMCOMPLETE       
`undef ACEPC_ARSNOOP_DVMMESSAGE        


// Defines for AWSNOOP values
`undef ACEPC_AWSNOOP_WRITEUNIQUE       
`undef ACEPC_AWSNOOP_WRITELINEUNIQUE   
`undef ACEPC_AWSNOOP_WRITECLEAN        
`undef ACEPC_AWSNOOP_WRITEBACK         
`undef ACEPC_AWSNOOP_WRITEEVICT        

// Defines for AXDOMAIN values
`undef ACEPC_AXDOMAIN_NONSHAREABLE     
`undef ACEPC_AXDOMAIN_INNER_DOMAIN     
`undef ACEPC_AXDOMAIN_OUTER_DOMAIN     
`undef ACEPC_AXDOMAIN_SYS_DOMAIN       


// Upper bits of RRESP
`undef ACEPC_RRESP_UNIQUECLEAN 
`undef ACEPC_RRESP_UNIQUEDIRTY 
`undef ACEPC_RRESP_SHAREDCLEAN 
`undef ACEPC_RRESP_SHAREDDIRTY 



// Lower bits of RRESP
`undef ACEPC_RRESP_OKAY   
`undef ACEPC_RRESP_EXOKAY 
`undef ACEPC_RRESP_SLVERR 
`undef ACEPC_RRESP_DECERR 



// Defines for ACSNOOP values
`undef ACEPC_ACSNOOP_READONCE           
`undef ACEPC_ACSNOOP_READSHARED         
`undef ACEPC_ACSNOOP_READCLEAN          
`undef ACEPC_ACSNOOP_READNOTSHAREDDIRTY 
`undef ACEPC_ACSNOOP_READUNIQUE         
`undef ACEPC_ACSNOOP_CLEANSHARED        
`undef ACEPC_ACSNOOP_CLEANINVALID       
`undef ACEPC_ACSNOOP_MAKEINVALID        

`undef ACEPC_ACSNOOP_DVMCOMPLETE       
`undef ACEPC_ACSNOOP_DVMMESSAGE        

// Defines for indexing the CRRESP
`undef ACEPC_CRRESP_DATATRANSFER 
`undef ACEPC_CRRESP_ERROR        
`undef ACEPC_CRRESP_PASSDIRTY    
`undef ACEPC_CRRESP_ISSHARED     
`undef ACEPC_CRRESP_WASUNIQUE    

// Defines for indexing the DVM message types
`undef ACEPC_DVM_TLB_INVALIDATE             
`undef ACEPC_DVM_BRAN_PRED_INVALIDATE       
`undef ACEPC_DVM_PHY_INST_CACHE_INVALIDATE  
`undef ACEPC_DVM_VIR_INST_CACHE_INVALIDATE  
`undef ACEPC_DVM_SYNC                       
`undef ACEPC_DVM_HINT                       

`undef ACEPC_TYPES


