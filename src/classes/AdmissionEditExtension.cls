public with sharing class AdmissionEditExtension {
    public Admission__c admission { get; set; }
    public Boolean showPersonalCard { get; set; }
    public string admEffDateTime { get; set; }

	// EC-185 - capturing service discharge info - only applicable for CM to start
    public boolean useDischargeSection { get; set; }
    public string admDischargeDateTime { get; set; }
    public TMN_User__c curUser{get;set;}
    public list<Service_Assignment__c> allSAforAdmint{get; set;}
        
    public ApexPages.StandardController stdController;
    public AdmissionEditExtension(ApexPages.StandardController stdController) {
        this.stdController = stdController;
        // Salesforce Bug: addFields cannot be called when tests are running:
        // http://bobbuzzard.blogspot.com/2011/04/dynamic-visualforce-bindings-and.html
        if(!Test.isRunningTest()) {
            this.stdController.addFields(new String[] {'Name', 'Effective_Date__c','Admission_Effective_DateTime__c',
                'Status__c', 'Discharged_Date__c', 'Discharged_Date_Time__c',
                'Network_Offering__c', 'Reason_for_Discharge__c','Reason_Other__c', 'State__c','Admitted_From__c','Discharged_To__c',
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
        allSAforAdmint = new list<Service_Assignment__c>();
        allSAforAdmint = [select id, name, Service_Location__r.Program__c, Service_Location__r.Setting__c from Service_Assignment__c where Admission__c = :this.admission.id];
        
        curUser = new TMN_User__c();
        // EC-185 get operating group for whether to show new discharge section
        useDischargeSection = false;
        for(TMN_User__c TU: [select Operating_Group__c from TMN_User__c Where Salesforce_User_Account__r.id = :UserInfo.getUserId() limit 1]){
         	curUser = TU;
         	if (TU.Operating_Group__c == 'Care Meridian') { 
         		useDischargeSection = true;
         	} 
         	
        }
        
        	
    }
    
    //PRI-218 219
    public boolean reqAdmittedFrom {get{return AdmissionEditViewCommon.setReqAdmittedFrom(curUser,allSAforAdmint);} set;}
    public boolean reqDcTo { get{ return AdmissionEditViewCommon.setReqDcTo(curUser,allSAforAdmint);} set;}
    public boolean shwDcTo { get{ return ( reqDcTo || curUser.Operating_Group__c.StartsWith('Neuro') );} set;}
    
    
    public pageReference saveAdmission () {

		
						
		setDischargeFields();
    		
		List<string> messages = new List<string>();
		try {
			admission.Admission_Effective_DateTime__c = DateTime.parse(admEffDateTime);
		}
		catch (Exception e){
			messages.add( 'Please enter a valid effective date and time.');
		}

	    if (! String.isBlank(admDischargeDateTime)) {
	    	try {
				system.debug('discharge datetime' + admDischargeDateTime);
				admission.Discharged_Date_Time__c = DateTime.parse(admDischargeDateTime);
			}
			catch (Exception e){
				messages.add('Please enter a valid discharge date and time.');
			}
 	
	    }
	    
	    
    	// EC-185 - if a discharge for CM, check required fields
    	if ( useDischargeSection && admission.status__c == 'Discharged') {
    		
    		admission.discharged_status__c = 'Neutral';
    		
    		
    		if ( admission.discharged_date_time__c == null )
    			messages.add('Please enter Discharged Date/Time');
    		else
    			admission.discharged_date__c = admission.discharged_date_time__c.date();
    			
    		if ( String.IsBlank(admission.planned_discharge__c))
    			messages.add('Please enter Planned Discharge');		

			if ( String.IsBlank(admission.discharged_to_category__c))	
				messages.add('Please enter Discharged To');
			
			if ( String.IsBlank(admission.discharged_to_other__c) && admission.discharged_to_subcategory__c == 'Other') 
				messages.add('Please enter Discharged To Other');   		
    		
    		if ( String.IsBlank(admission.referred_out_agency_name__c ) && admission.discharged_to_category__c == 'Another Facility')
    			messages.add('Please enter Facility Name');
    			
    		if ( String.IsBlank(admission.discharged_reason__c))
    			messages.add('Please enter Discharged Reason');
    		
    		if ( String.IsBlank(admission.Reason_Other__c)) {
    			if (admission.discharged_reason_subcategory__c == 'Other' || admission.discharged_reason_additional__c == 'Other' || admission.Discharged_Reason__c == 'Other') 
					messages.add('Please enter Discharged Reason Other');   
				
				/*Removed for PRI-272
				else
					admission.reason_for_discharge__c = '.'; // allows it to save without validation error		*/
    		}
    	}
    	for ( String msg : messages )	{
    		for ( string s : messages ) {
           		ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, s));
        	}	
    	}
    	
    	if ( messages.size() > 0)
    		return null;
    	
	 		
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
    		admission.Discharged_To__c = '';
    		if ( useDischargeSection )
    			admission.referred_out_agency_name__c = '';
    		admission.discharged_to_subcategory__c = '';
    		admission.discharged_to_additional__c = '';
    		admission.discharged_reason__c = '';
    		admission.discharged_reason_subcategory__c = '';
    		admission.discharged_reason_additional__c ='';
    		admission.Reason_Other__c = '';
    		admission.additional_discharge_info__c = '';
    	
    	}
    		
    		
    	
    }
   }