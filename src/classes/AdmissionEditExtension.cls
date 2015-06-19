public with sharing class AdmissionEditExtension {
    public Admission__c admission { get; set; }
    public Boolean showPersonalCard { get; set; }
    
	// EC-185 - capturing service discharge info - only applicable for CM to start
    public boolean useDischargeSection { get; set; }
        
    public ApexPages.StandardController stdController;
    public AdmissionEditExtension(ApexPages.StandardController stdController) {
        this.stdController = stdController;
        // Salesforce Bug: addFields cannot be called when tests are running:
        // http://bobbuzzard.blogspot.com/2011/04/dynamic-visualforce-bindings-and.html
        if(!Test.isRunningTest()) {
            this.stdController.addFields(new String[] {'Name', 'Effective_Date__c','Admission_Effective_DateTime__c',
                'Status__c', 'Discharged_Date__c', 'Discharged_Date_Time__c',
                'Network_Offering__c', 'Reason_for_Discharge__c', 'State__c',
                'Referred_Out_Date__c', 'Referred_Out_Agency_Name__c', 'Referred_Out_Reason__c',
                'Person_Being_Served__c', 'Discharged_Status__c', 'Planned_Discharge__c','Discharged_to_category__c','Discharged_to_subcategory__c','Discharged_to_additional__c', 'Discharged_to_other__c', 'Discharged_to_desc__c',
                'Discharged_Reason__c','Discharged_Reason_subcategory__c', 'Discharged_Reason_Additional__c', 'Additional_Discharge_info__c'});
        }
        this.admission = (Admission__c) stdController.getRecord();
        if ( this.admission.Id == null ) {
	        if (ApexPages.currentPage().getParameters().get('pbsId')==null) {
	            showPersonalCard = false;
	        } else {
	            showPersonalCard = true;
	            this.admission.Person_Being_Served__c = ApexPages.currentPage().getParameters().get('pbsId');
	        }
	        this.admission.Name = '(autofilled on save)';
        } else {
        	showPersonalCard = true;
        
        }
        
        
        // EC-185 get operating group for whether to show new discharge section
        useDischargeSection = false;
        for(TMN_User__c TU: [select Operating_Group__c from TMN_User__c Where Salesforce_User_Account__r.id = :UserInfo.getUserId() limit 1]){
         	if (TU.Operating_Group__c == 'Care Meridian') { 
         		useDischargeSection = true;
         	} 
        }
        
        	
    }
    
    
    public pageReference saveAdmission () {

		setDischargeFields();
    		
		List<string> messages = new List<string>();
		    
    	// EC-185 - if a discharge for CM, check required fields
    	if ( useDischargeSection && admission.status__c == 'Discharged') {
    		
    		
    		admission.discharged_status__c = 'Neutral';
    		
    		
    		if ( admission.discharged_date_time__c == null )
    			messages.add('Discharged Date/Time');
    		else
    			admission.discharged_date__c = admission.discharged_date_time__c.date();
    			
    		if ( String.IsBlank(admission.planned_discharge__c))
    			messages.add('Planned Discharge');		

			if ( String.IsBlank(admission.discharged_to_category__c))	
				messages.add('Discharged To');
			
			if ( String.IsBlank(admission.discharged_to_other__c) && admission.discharged_to_subcategory__c == 'Other') 
				messages.add('Discharged To Other');   		
    		
    		if ( String.IsBlank(admission.referred_out_agency_name__c ) && admission.discharged_to_category__c == 'Another Facility')
    			messages.add('Facility Name');
    			
    		if ( String.IsBlank(admission.discharged_reason__c))
    			messages.add('Discharged Reason');
    		
    		if ( String.IsBlank(admission.reason_for_discharge__c)) {
    			if (admission.discharged_reason_subcategory__c == 'Other' || admission.discharged_reason_additional__c == 'Other') 
					messages.add('Discharged Reason Other');   
				else
					admission.reason_for_discharge__c = '.'; // allows it to save without validation error		
    		}
	    	for ( String msg : messages )	{
	    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill in the following fields to discharge the admission.'));
	    		for ( string s : messages ) {
               		ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, s));
            	}	
	    	}
	    	
	    	if ( messages.size() > 0)
	    		return null;
	    	
	    } 
	 
	 	try {
			upsert admission;
			return new PageReference('/' + admission.id);
		}
		catch( Exception e) {
			return null;
		}
	    		 
    }
    
    public void setDischargeFields() {
    	
    	if (admission.status__c != 'Discharged') {
    		admission.discharged_date__c = null;	
    		admission.discharged_date_time__c = null;
    		admission.discharged_status__c = '';
    		admission.discharged_to_category__c = '';
    		admission.planned_discharge__c = '';
    		admission.discharged_to_desc__c = '';
    		admission.discharged_to_other__c = '';
    		admission.referred_out_agency_name__c = '';
    		admission.discharged_to_subcategory__c = '';
    		admission.discharged_to_additional__c = '';
    		admission.discharged_reason__c = '';
    		admission.discharged_reason_subcategory__c = '';
    		admission.discharged_reason_additional__c ='';
    		admission.reason_for_discharge__c = '';
    		admission.additional_discharge_info__c = '';
    	
    	}
    		
    		
    	
    }
   }