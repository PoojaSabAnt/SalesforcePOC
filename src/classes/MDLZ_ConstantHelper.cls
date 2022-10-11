/***************************************************************
Name: MDLZ_ConstantHelper
======================================================
Purpose:
a. Apex class to define Constants that be used across other MDLZ classes 
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL                 Description
1.0                                      10/08/2021       Initial Development     

***************************************************************/ 
//Cmt: fixing defects: MRELKXIW-1925, MRELKXIW-1912 & MRELKXIW-1918
public class MDLZ_ConstantHelper {
    //Phases
    public static final string PhaseSentToSAP = 'Send to SAP';
    public static final string PhaseRejected = 'Rejected';
    public static final string ReceivedBySAP = 'Received By SAP';
    public static final string Delivered = 'Delivered';
    public static final string Sales = 'Sales';
    public static final string UserCockpit = 'UserCockpit';
    public static final string US01 = 'US01';
    public static final string PhaseRouted = 'Routed';
    public static final string PhaseCancelled ='Cancelled';
    public static final string EDI ='EDI';
    public static final string NOS ='NOS';
    public static final string PhaseLocked ='Locked';
    public static final string PhaseDeleted ='Deleted';
    public static final string CustomerPicklist ='Master Record';
    public static final string CreateOW ='OW';
    public static final string UserPermSR ='SR';
    public static final string UserPermSSRFT ='SSR(FTOW)';
    public static final string UserPermSSR  = 'SSR(FT/PT)';
    public static final string UserPermVacation  = 'Vacation Rep';
    public static final string UserPermDM  = 'DM';
    public static final string UserPermRMS   ='RMS';
    public static final string UserPermREM  ='REM';
    public static final string UserPermRDR ='RDR';
    public static final string UserPermSIM ='SIM';
	public static final string UserPermCBT ='CBT';
    public static final string UserPermSYSADM = 'System Administrator';
    public static final string UserPermOPSADM = 'MDLZ_DSD_OpsAdmin';
	public static final string UserPermRoleOPSADM = 'Ops Admin';
    public static final string OutboundSap = '1 outbound SAP';
    public static final string MDLZSap = 'MDLZ SAP User';
    public static final string BatchProcessed = 'Batch Processed';
    public static final string IntUpdated = 'Int Updated';
    public static final string RoleChanged = 'Role Changed';
    public static final string TTProcessed = 'TT Processed';
    public static final string RDRProcessed = 'RDR Processed';
    public static final Integer ProdLastmodate = 0;
    public static final string IntegrationUser = 'MDLZ_Integration_User';
    public Static Final String INTEGRATIONADMIN ='Admin Integration';
    public static Final String Promotion_Stage_Committed = 'Committed';
    public static Final String Template_FandD = 'F&D';
    public static Final String Template_Scripted = 'Scripted';
    public static Final String Template_Non = 'Non';
    public static Final String SSRPRofile = 'MDLZ_SSR_FTPT';
    public static Final String Territory = 'Territory';
	public static Final String mobilityRelevant = 'No';
    public static Final String KPIGroup = 'Intelligent Recommendation';
    
    //Change
    public static final string ChangeTrue = 'TRUE';
    public static final string ChangeFalse = 'FALSE';
    public static final string open = 'Open';
    public static final string Team = 'Team';
    public static final string Market_District = 'Market/District';
    public static final boolean isTrue = true;
    public static final boolean isFalse = false;
    
    public static final String Sales_Org='US01_';
    public static final String Branch='_Branch';
    public static final String Branch_Listing='listing';
    public static final String Store='_Store';
    
    //Installed Package Related
    public static final String PACKAGENAMESPACEPREFIX='ACCL';  
    
    //Metadata MDLZ_Admin_Profiles__mdt
    public static final String intUser='Integration_User';
    public static final String sysAdmin='System_Administrator';
    public static final String opsAdmin='OPS_Admin';
    
	//Flip object
    public static final String OrderAccepted='OrderAccepted';
    public static final String OrderSync='OrderSync';
    public static final String DupWrapper='DupWrapper';   
	
    //Process Names
     public static final String UPDATE_CAO_ORDERS='Update_CAO_Orders';
	 
	  //Result Status
    public static final String ResultMap_KeySuccess='Success';
    public static final String ApexError='Error';
    
    //Error Log message
    public static final string promoExportBatchSizeError = 'Cannot execute the batch for the batch size greater than 1';

}