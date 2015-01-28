public without sharing class Assessment_CANSdetail_Ex {	//keep this without sharing so the quarterly numbering sees all assessments regardless of ownership
    assessment__c assess = new assessment__c();
    
    public Assessment_CANSdetail_Ex(ApexPages.StandardController controller) {
        assess= (assessment__c)controller.getRecord();
        id adminID = apexpages.currentpage().getparameters().get('admission');
        assess.Admission__c = adminID ;
        assess.Assessment_Type__c = apexpages.currentpage().getparameters().get('type');
        
        assess.accountperson__c = [select id, Person_Being_Served__r.Accountid from admission__c where id = :adminID].Person_Being_Served__r.Accountid;
        
        
    }
    
  
    public void getNextQuarter( ) {
    	
    	// if interval is quarterly and it's a new assessment, default to next quarter
    	if ( assess.interval__c == 'Quarterly' && assess.id == null ) {
	    	// get list of other quarterlies for this Admission
	    	List <Assessment__c> otherQ = [select id, quarter__c from assessment__c where admission__c= :assess.Admission__c and Interval__c = 'Quarterly' and disregard__c = false order by quarter__c desc];
	    	decimal lastQ = 0;
	    	
	    	if ( otherQ.size() > 0 ) 
	    		lastQ = otherQ[0].quarter__c;
	    		
	    	assess.quarter__c = lastQ + 1;
    	} else { // either not new or not quarterly
    		if ( assess.interval__c != 'Quarterly')
    			assess.quarter__c = null;
    		// otherwise leave it unchanged
    	}
    	
    }

}