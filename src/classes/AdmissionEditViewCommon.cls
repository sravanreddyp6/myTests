public class AdmissionEditViewCommon {

    //Updated for PRI-343
    public static boolean setReqAdmittedFrom(TMN_User__c u, list<Service_Assignment__c> SAs ){
			
		for(Service_Assignment__c item: SAs){
			if(null != item.Service_Location__r.Network_Offering__c &&  item.Service_Location__r.Network_Offering__c.equalsIgnoreCase('ARY') )
		    	{return true;}
	    	else{
	    		if( null != item.Service_Location__r.TMN_Scope__c && item.Service_Location__r.TMN_Scope__c.equalsIgnoreCase('residential') )
	    		{return true;}
	    	}
	    				
		}
		    	
    	return false;
    }
    public static boolean setReqDcTo(TMN_User__c u, list<Service_Assignment__c> SAs ){
    	if( u.Operating_Group__c == 'Cambridge' || u.Operating_Group__c == 'Redwood'  ){
	    	for(Service_Assignment__c item: SAs){
	    		if(null != item.Service_Location__r.Network_Offering__c && item.Service_Location__r.Network_Offering__c.equalsIgnoreCase('ARY') )
	    			{return true;}
    			else{
    				if(null != item.Service_Location__r.TMN_Scope__c && item.Service_Location__r.TMN_Scope__c.equalsIgnoreCase('residential') )
    					{return true;}
    			}
    				
	    	}
    	}    	
    
    	return false;
    }    

}