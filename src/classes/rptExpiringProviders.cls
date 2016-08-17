public with sharing class rptExpiringProviders{
    
    public date fromDate {get; set;}
    public date toDate {get; set;}
    
    public list<SelectOption> brokerageList = new list<SelectOption>();
    public list<SelectOption> getBrokerageList(){ return brokerageList; }
    public List<Id> selectedBrokerage {get; set;}
    public List<id> select2Brokerage {get; set;}
    public list<SelectOption> selectedBroList = new list<SelectOption>();
    public list<SelectOption> getSelectedBroList(){ return selectedBroList; }
    
    public transient list<TMN_Provider__c> rptData {get; set;}
    
    public rptExpiringProviders() {
        Service_Location__c[] locations = [
            SELECT Id, Name, Alias__c, Alias_lookup__c, ProgramId__c, Location_Nickname__c
            FROM Service_Location__c
            WHERE State__c = 'OR'
            AND Service_Type__c = 'CM - Case Management'
            ORDER BY ProgramId__c
        ];
        for (Service_Location__c location: locations) {
            brokerageList.add(new SelectOption(location.Id, location.ProgramId__c + ' - ' + location.Location_Nickname__c));
        } 

    }
    
     public pagereference AddBrokerage(){
        for (Id p :select2Brokerage){
            for(Integer i=0; i < selectedBroList.size(); i++){
                if (selectedBroList.get(i).getValue() == p) {
                    brokerageList.add(new SelectOption(selectedBroList.get(i).getValue(), selectedBroList.get(i).getLabel()));
                    selectedBroList.remove(i);
                    break;
                }
            }
        }
        return null;
    }
    public pagereference RemoveBrokerage(){
        for (Id p :selectedBrokerage){
            for(Integer i=0; i < brokerageList.size(); i++){
                if (brokerageList.get(i).getValue() == p) {
                    selectedBroList.add(new SelectOption(brokerageList.get(i).getValue(), brokerageList.get(i).getLabel()));
                    brokerageList.remove(i);
                    break;
                }
            }
        }
        return null;
    }
    
    public list<SelectOption> provtypelist;
	public List<String> selectedTypes {get; set;}
	public List<String> selected2Types {get; set;}
    public list<SelectOption> selectTypeList = new list<SelectOption>();
    public list<SelectOption> getSelectTypeList(){ return selectTypeList; }	
    
	public List<SelectOption> getTypeList() {
		if (provtypelist != null) {
			return provtypelist;
		}
		provtypelist = new List<SelectOption>();
		selectTypeList = new List<SelectOption>();
		
		// set all to selected at first
		selectTypeList.add(new SelectOption('Car Insurance Expiration Date','Car Insurance Expiration Date'));
		selectTypeList.add(new SelectOption('CHC Expiration Date', 'CHC Expiration Date'));
		selectTypeList.add(new SelectOption('Driver\'s License Expiration Date', 'Driver\'s License Expiration Date'));
		selectTypeList.add(new SelectOption('PEAA/PEI Expiration Date', 'PEAA/PEI Expiration Date'));
		
		return provtypelist;
	}
	
	public pagereference AddTypes(){
		for (String p : selectedTypes ){
			for(Integer i=0; i < provTypeList.size(); i++){
				if (provtypelist.get(i).getValue() == p) {
	    			selectTypeList.add(new SelectOption(provtypelist.get(i).getValue(), provtypelist.get(i).getLabel()));
	    			provtypelist.remove(i);
					break;
	    		}
			}
		}
        return null;
    }

	public pagereference RemoveTypes(){
		for (String p :selected2Types ){
			for(Integer i=0; i < selectTypeList.size(); i++){
				if (selectTypeList.get(i).getValue() == p) {
	    			provtypelist.add(new SelectOption(selectTypeList.get(i).getValue(), selectTypeList.get(i).getLabel()));
	    			selectTypeList.remove(i);
					break;
	    		}
			}
		}
        return null;
    }
	
	public void UpdateTypeSelections(){
		selected2Types = new List<String>();
		for (selectOption so : selectTypeList){
			selected2Types.add(so.getValue());
		}
	}
    
     public PageReference runRpt() {
         boolean inputErr = false;
         ApexPages.getMessages().clear();
         
         UpdateTypeSelections();
         
         if(brokerageList.isEmpty()) {
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                    'Please choose at least one Brokerage');
             ApexPages.addMessage(myMsg);
             inputErr = true;
         }
         if ( selected2Types.isEmpty() ) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                    'Please choose at least one Filter Approved Providers By');
                    ApexPages.addMessage(myMsg);
                    inputErr = true;
    	}
        if(fromDate == null || toDate == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                    'Please choose valid From and To dates');
                    ApexPages.addMessage(myMsg);
                    inputErr = true;
    	} else if ( fromDate > toDate ) {
                   ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                    'Please choose valid start and end dates');
                    ApexPages.addMessage(myMsg);
                    inputErr = true;
    	}
         
         if ( inputErr ) {
			return null;
		}
         
         String[] criterias = new String[]{};
             
             if(selected2Types.size() > 0 ){
                 for(String str:selected2Types){   
                     if (str.contains('Car Insurance Expiration Date')) {
                         criterias.add('(Car_Insurance_Expiration_Date__c >=  :fromDate AND Car_Insurance_Expiration_Date__c <=  :toDate)');
                     }
                     if (str.contains('CHC Expiration Date')) {
                         criterias.add('(CHC_Expiration_Date__c >=  :fromDate AND CHC_Expiration_Date__c <=  :toDate)');
                     }
                     if (str.contains('Driver\'s License Expiration Date')) {
                         criterias.add('(Driver_License_Expiration_Date__c >=  :fromDate AND Driver_License_Expiration_Date__c <=  :toDate)');
                     }
                     if (str.contains('PEAA/PEI Expiration Date')) {
                         criterias.add('(PEAA_PEI_Expiration_Date__c >=  :fromDate AND PEAA_PEI_Expiration_Date__c <=  :toDate)');
                     }
                 }
             }
         
         String criteria;
         if (criterias.size() > 0) {
             criteria =  String.join(criterias, ' OR ');
         }
         
         String query =
             'SELECT Id, First_Name__c, Last_Name__c, Company_Agency_Name__c, Provider_Type__c, Brokerage__c, Brokerage__r.ProgramID__c, Brokerage__r.Location_Nickname__c, Car_Insurance_Expiration_Date__c, CHC_Expiration_Date__c, Driver_License_Expiration_Date__c, PEAA_PEI_Expiration_Date__c, Address_Street_1__c, Address_Street_2__c, City__c, State__c, Zip__c, Phone_1__c, Phone_2__c, Fax__c, Primary_Email__c, Status__c' +
             '  FROM Tmn_Provider__c WHERE Status__c = \'Approved\'  AND ' + '(' +
             (criteria != null ? criteria : '') + ')' +
             ' ORDER BY First_Name__c, Last_Name__c  ASC';
         system.debug(query);
         
         rptData = Database.query(query);
         
         return null;
     }
    
    public PageReference Reset() {
    	PageReference pageRef = new PageReference('/apex/rptExpiring_Providers');
    	pageRef.setRedirect(true);
    	return pageRef;
    }
    

}