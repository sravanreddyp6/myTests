public with sharing class rptProvider_Applications_InProcessExt {
	public list<SelectOption> brokerageList = new list<SelectOption>();
    public list<SelectOption> getBrokerageList(){ return brokerageList; }
    public List<Id> selectedBrokerage {get; set;}
    public List<id> select2Brokerage {get; set;}
    public list<SelectOption> selectedBroList = new list<SelectOption>();
    public list<SelectOption> getSelectedBroList(){ return selectedBroList; }
    set<String> locationIds = new set<String>();
    
    public transient list<TMN_Provider_Application__c> rptData {get; set;}
    
    public rptProvider_Applications_InProcessExt() {
        Service_Location__c[] locations = [
            SELECT Id, Name, Alias__c, Alias_lookup__c, ProgramId__c, Location_Nickname__c
            FROM Service_Location__c
            WHERE State__c = 'OR'
            AND Service_Type__c = 'CM - Case Management'
            ORDER BY ProgramId__c
        ];
        for (Service_Location__c location: locations) {
            brokerageList.add(new SelectOption(location.Id, location.ProgramId__c + ' - ' + location.Location_Nickname__c));
            locationIds.add(location.Id);
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
         updateLocations();
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
         updateLocations();
        return null;
    }
    public void updateLocations(){
		locationIds = new Set<String>();
        for (selectOption so : brokerageList){
            locationIds.add(so.getValue());
		}
    }
    public PageReference runRpt() {
         boolean inputErr = false;
         ApexPages.getMessages().clear();
         
         if(brokerageList.isEmpty()) {
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                    'Please choose at least one Brokerage');
             ApexPages.addMessage(myMsg);
             inputErr = true;
         }
         
         if ( inputErr ) {
			return null;
		}
         
         rptData = [SELECT Id, Name,Provider__c, Application_Date__c, Address_Street_1__c, City__c, Address_Street_2__c, State__c, Zip__c, Phone_1__c,
         				Phone_2__c, Fax__c, Primary_Email__c, Provider__r.First_Name__c,Provider__r.Last_Name__c, Provider__r.Company_Agency_Name__c, Provider__r.Provider_Type__c, Provider__r.Brokerage__c, Provider__r.Brokerage__r.ProgramID__c, 
         				Provider__r.Brokerage__r.Location_Nickname__c  FROM TMN_Provider_Application__c WHERE Status__c = 'Pending Approval' AND Provider__r.Brokerage__c In :locationIds ORDER BY Provider__r.First_Name__c, Provider__r.Last_Name__c, Application_Date__c];
         
         
         return null;
     }
    
    public PageReference Reset() {
    	PageReference pageRef = new PageReference('/apex/rptProvider_Applications_InProcess');
    	pageRef.setRedirect(true);
    	return pageRef;
    }
    
    
}