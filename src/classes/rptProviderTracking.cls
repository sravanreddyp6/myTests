public with sharing class rptProviderTracking {
	
	public list<TMN_Provider__c> rptData {get; set;}
	
	public String[] providerStatus {get; set;}
	public String brokerage {get; set;}
	
	public rptProviderTracking() {
		initProviderStatus();
	}
	
	private void initProviderStatus() {
		providerStatus = new String[] {'Pending Approval', 'Approved', 'Expired', 'Disqualified'};
	}
    
	public List<SelectOption> getStatusValues() {
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('Pending Approval', 'Pending Approval'));
		options.add(new SelectOption('Approved', 'Approved'));
		options.add(new SelectOption('Expired', 'Expired'));
		options.add(new SelectOption('Disqualified', 'Disqualified'));
		return options;
	}
    
    public PageReference runRpt() {
    	boolean inputErr = false;
    	ApexPages.getMessages().clear();
    	
    	system.debug('providerStatus=' + providerStatus);
    
    	if(providerStatus.isEmpty()) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                    'Please choose at least one status value');
                    ApexPages.addMessage(myMsg);
                    inputErr = true;
    	}
       
		if ( inputErr ) {
			return null;
		}
		
		rptData = [SELECT Id, First_Name__c, Last_Name__c, Gender__c, SPD_Number__c, eXPRS_Number__c, Address_Street_1__c,
						Address_Street_2__c, City__c, State__c, Zip__c, Phone_1__c, Phone_2__c, Fax__c, Primary_Email__c,
						Provider_Type__c, Company_Agency_Name__c, Brokerage__r.Alias__c, Counties_Served__c,  
						Services_Provided__c, Status__c, (SELECT Disqualification_Date__c, Effective_Date__c, Expiration_Date__c 
							FROM TMN_Provider_Applications__r ORDER BY Effective_Date__c DESC LIMIT 1)
					FROM TMN_Provider__c
					WHERE Status__c in :providerStatus
					];
		
    	return null; 
    }
    
    public PageReference cancelToNewRun() {
    	initProviderStatus();
    	PageReference pageRef = new PageReference('/apex/rptProvider_Tracking');
    	pageRef.setRedirect(true);
    	return pageRef;
    }
}