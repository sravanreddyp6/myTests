public with sharing class rptCurrentPersonalAgentAssignments {
    public date fromDate {get; set;}
    public date toDate {get; set;}
    
    public list<SelectOption> brokerageList = new list<SelectOption>();
    public list<SelectOption> getBrokerageList(){ return brokerageList; }
    public List<Id> selectedBrokerage {get; set;}
    public List<id> select2Brokerage {get; set;}
    public list<SelectOption> selectedBroList = new list<SelectOption>();
    public list<SelectOption> getSelectedBroList(){ return selectedBroList; }	
    
    
    public list<SelectOption> pAgentList = new list<SelectOption>();
    public list<SelectOption> getPAgentList(){ return pAgentList ;}
    public List<id> selectedPA {get; set;}
	public List<id> select3PA {get; set;}
    public list<SelectOption> selectedPAList = new list<SelectOption>();
    public list<SelectOption> getSelectedPAList(){ return selectedPAList; }
    
    Map<id,String> servLocAlookup = new Map<id,String>();
    set<id> pAgentsIds = new set<id>();
    
    public transient list<rptRow> rptData { get; private set;}
    
    public pageReference runRpt(){
        rptData = new list<rptRow>();
        boolean inputErr = false;
        ApexPages.getMessages().clear();
        
        if(brokerageList.isEmpty()) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                    'Please choose at least one Brokerage');
                    ApexPages.addMessage(myMsg);
                    inputErr = true;
    	}
    	else if (pAgentList.isEmpty()) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                    'Please choose at least one Personal Agent');
                    ApexPages.addMessage(myMsg);
                    inputErr = true;
    	}
       
		if ( inputErr ) {
			return null;
		}
        
        Service_Assignment_Personal_Agent__c[] saPAgent  = [SELECT Id,Personal_Agent__c,Service_Assignment__c, Personal_Agent__r.name,
                                                           Service_Assignment__r.Person_Being_Served__r.Name, Service_Assignment__r.Name,
                                                           Service_Assignment__r.service_location__r.programid__c,
                                                           Service_Assignment__r.service_location__r.Location_Nickname__c
                                                           FROM Service_Assignment_Personal_Agent__c
                                                           WHERE Service_Assignment__r.Status__c = 'Active'
                                                           AND Personal_Agent__c In :pAgentsIds
                                                           order by Personal_Agent__r.name ASC
                                                          ];
        
        Map<id, Case_Management_plan__c> cmMap = new Map<id, Case_Management_Plan__c>();
        set<id> sAssignIds = new set<id>();
        for(Service_Assignment_Personal_Agent__c saPA: saPAgent){
            sAssignIds.add(saPA.Service_Assignment__c);
            cmMap.put(saPa.Service_Assignment__c, new case_Management_Plan__c());
        }
        Case_Management_Plan__c[] caseMgmt = [SELECT Id,  Service_Assignment__c,
                                              Service_Assignment__r.Name, PD_Start__c, PD_End__c
                                              FROM Case_Management_Plan__c
                                              WHERE RecordType.DeveloperName = 'OR_Combined_ISP' 
                                              AND Status__c = 'Active Final'
                                              AND Service_Assignment__c In :sAssignIds
                                              AND (PD_End__c >=  :fromDate AND PD_End__c <=  :toDate)
                                             ];
        
        for(Case_Management_Plan__c cm: caseMgmt){
            if(cmMap.containsKey(cm.Service_Assignment__c)){
				cmMap.put(cm.Service_Assignment__c, cm);              
            }
        }        
        
        if (saPAgent != null) {
            for(Service_Assignment_Personal_Agent__c s: saPAgent) {
               		rptRow r = new rptRow();
                	r.paName = s.Personal_Agent__r.Name;
                	r.pbsName = s.Service_Assignment__r.Person_being_Served__r.Name;
                	r.pbsId = s.Service_Assignment__r.Person_being_Served__c;
                	r.saName = s.Service_Assignment__r.name;
                	r.saId = s.Service_Assignment__c; 
                	r.Brokerage = s.Service_Assignment__r.service_location__r.programid__c + ' - ' + s.Service_Assignment__r.service_location__r.Location_Nickname__c;                     
                    r.stDate = cmMap.get(s.Service_Assignment__c).PD_Start__c;
                	r.enDate = cmMap.get(s.Service_Assignment__c).PD_End__c;
                
                	rptData.add(r);
                }
                
            }
    return null; 
}
    
    public class rptRow{
        public string paName {get; set;}
        public string pbsName {get; set;}
        public string pbsID {get; set;}
        public string saName {get; set;}
        public string saID {get; set;}
        public Date stDate {get; set;}
        public Date enDate {get; set;}
        public string brokerage {get; set;}
        
 
        public rptRow(){
      
        }
    }
    


    public rptCurrentPersonalAgentAssignments() {
        Service_Location__c[] locations = [
            SELECT Id, Name, Alias__c, Alias_lookup__c, ProgramId__c, Location_Nickname__c
            FROM Service_Location__c
            WHERE State__c = 'OR'
            AND Service_Type__c = 'CM - Case Management'
            ORDER BY ProgramId__c
        ];
        for (Service_Location__c location: locations) {
            brokerageList.add(new SelectOption(location.Id, location.ProgramId__c + ' - ' + location.Location_Nickname__c));
            servLocAlookup.put(location.Id, location.Alias_lookup__c);
        }              
        UpdatePersonalAgents();
        
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
        UpdatePersonalAgents();
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
        UpdatePersonalAgents();
        return null;
    }
   
    public void UpdatePersonalAgents(){
        set<id> selectedAliasLup = new set<id>();
		for (selectOption so : brokerageList){
            selectedAliasLup.add(servLocAlookup.get(so.getValue()));
		}	
       TMN_User__c[] tmnUsers = [SELECT Id, Name FROM TMN_User__c 
                             				 WHERE (Job_Title__c = 'Case Manager' OR Professional_Title__c = 'Case Manager')
                             				 AND Alias_lookup__c In :selectedAliasLup 
                                 			 order by Name Asc
                                ];
        pAgentList.clear();     
        selectedPAList.clear();
        pAgentsIds.clear();
        for (TMN_User__c tmnUser: tmnUsers) {
            pAgentList.add(new SelectOption(tmnUser.Id, tmnUser.name));
            pAgentsIds.add(tmnUser.Id);
        }
    }
	 
	public pagereference AddPAgent(){
        for (Id p :select3PA){
            for(Integer i=0; i < selectedPAList.size(); i++){
                if (selectedPAList.get(i).getValue() == p) {
                    pAgentList.add(new SelectOption(selectedPAList.get(i).getValue(), selectedPAList.get(i).getLabel()));
                    pAgentsIds.add(selectedPAList.get(i).getValue());
                    selectedPAList.remove(i);
                    break;
                }
            }
        }
        return null;
    }
    public pagereference RemovePAgent(){
        for (Id p :selectedPA){
            for(Integer i=0; i < pAgentList.size(); i++){
                if (pAgentList.get(i).getValue() == p) {
                    selectedPAList.add(new SelectOption(pAgentList.get(i).getValue(), pAgentList.get(i).getLabel()));
                    pAgentsIds.remove(pAgentList.get(i).getValue());
                    pAgentList.remove(i);
                    break;
                }
            }
        }
        return null;
    }
    public PageReference Reset() {
    	PageReference pageRef = new PageReference('/apex/rptCurrent_PersonalAgent_Assignments');
    	pageRef.setRedirect(true);
    	return pageRef;
    }
    
    
}