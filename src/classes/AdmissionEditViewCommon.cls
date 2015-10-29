public class AdmissionEditViewCommon {

    
    public static boolean setReqAdmittedFrom(TMN_User__c u, list<Service_Assignment__c> SAs ){

    	//Cambridge check
    	if( u.Operating_Group__c == 'Cambridge' ){
	    	for(Service_Assignment__c item: SAs){
	    		if(item.Service_Location__r.Program__c.contains('-ARY') )
	    			{return true;}
    			else{
    				if( item.Service_Location__r.Setting__c.equalsIgnoreCase('residential') )
    					{return true;}
    			}
    				
	    	}
    	}
	//Redwood check
    	if( u.Operating_Group__c == 'Redwood' ){
	    	for(Service_Assignment__c item: SAs){
	    		if( item.Service_Location__r.Setting__c.equalsIgnoreCase('residential') )
	    			{return true;}    				
	    	}
    	}    	
    
    	return false;
    }
    public static boolean setReqDcTo(TMN_User__c u, list<Service_Assignment__c> SAs ){
    	//Cambridge check
    	if( u.Operating_Group__c == 'Cambridge' ){
	    	for(Service_Assignment__c item: SAs){
	    		if(item.Service_Location__r.Program__c.contains('-ARY') )
	    			{return true;}
    			else{
    				if( item.Service_Location__r.Setting__c.equalsIgnoreCase('residential') )
    					{return true;}
    			}
    				
	    	}
    	}
	//Redwood check
    	if( u.Operating_Group__c == 'Redwood' ){
	    	for(Service_Assignment__c item: SAs){
	    		if( item.Service_Location__r.Setting__c.equalsIgnoreCase('residential') )
	    			{return true;}    				
	    	}
    	}    	
    
    	return false;
    }    

}