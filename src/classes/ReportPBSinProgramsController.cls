public with sharing class ReportPBSinProgramsController {
	
    public List<Service_Assignment__c> servAssigns {get;set;} // for excel export - Limit 10,000
    public list<Service_Assignment__c> subServAssigns {get; set;} // for display on page - Limit 500
    public Service_Location__c sl = new Service_location__c(); // to dynamically obtain picklist values
    public Admission__c adm = new Admission__c(); // to dynamically obtain picklist values
   
    
  	public Date fDate {get; set;} //thanks to Winter'14 release
  	public Date tDate {get; set;}
    public string maxAge{get;set;}
    public string minAge{get; set;}
    public string pbsGender {get; set;}
    public string admState{get; set;}
    public string admStatus{get; set;}
    public string saStatus {get; set;}
    public string aliases{get;set;}
    public string sltmnscope {get; Set;}
    public string slserviceType {get; set;}
    public string slNetworkOffering {get; set;}
    public string populationServed {get; set;}
    public string physicalLocation {get; set;}
    public string queryString;
    
    public list<selectOption> stateValues {get{
        if(stateValues == null){
            return Utility.getPicklistValues(adm,'State__c');
        }
        return stateValues;
    }
        set;}
        
    public list<selectOption> serviceTypes {get{
        if(serviceTypes == null){
            return Utility.getPicklistValues(sl,'Service_Type__c');
        }
        return stateValues;
    }
        set;}
        
    //filter Conditions - Sravan - using public variables due to this issue - http://salesforce.stackexchange.com/questions/8408/bind-variable-with-dotted-name-not-working-in-dynamic-soql
    public integer max;
    public integer min;
    public list<string> aliasList = new list<string>();
    
    //Sum Counts
    public integer pbsCount {get; set;}
    public integer admissionCount {get; set;}
    public integer SACount {get; set;}
    
    //sortorder
    String sortOrder = ' order by Person_Being_Served__r.PBS_Identifier__c asc, admission__r.Name asc, Name asc';
    
    //Constructor
    public ReportPBSinProgramsController(){
        this.servAssigns = new list<Service_Assignment__c>();
        this.subServAssigns = new list<Service_Assignment__c>();
        //this.sl = new Service_Location__c();
      	//this.adm = new Admission__c();
        this.pbsCount = 0;
        this.admissionCount = 0;
        this.SACount = 0;
        queryString = 'SELECT Id, Person_Being_Served__c,Person_Being_Served__r.PBS_Identifier__c, Person_being_served__r.LastName,Person_being_served__r.FirstName, Person_being_served__r.Age__c, Person_being_served__r.Age_text__c, Person_being_served__r.Gender__c, Person_Being_Served__r.Does_the_person_Identify__c, Person_being_served__r.Race__c, Person_being_served__r.MailingStateCode,';
        queryString = queryString+' Admission__c, admission__r.Name, admission__r.Admission_Hidden__c, Admission__r.State__c, Admission__r.Status__c, Admission__r.Admission_Effective_DateTime__c, Admission__r.Discharged_Date__c, Name, Status__c, SA_Start_DateTime__c, End_Date__c, Alias__c, Service_Location__r.Location_Nickname__c,';
        queryString = queryString+' Service_Location__r.TMN_Scope__c, Service_location__r.ProgramId__c, Service_Location__r.Network_Offering__c,Service_Location__r.Population_Served__c, Service_Location__r.Physical_Location__c, Service_Location__r.Service_Type__c,';
        queryString = queryString+' Was_this_transfer_frm_another_ServAssig__c, Is_this_transfer_to_another_ServAssign__c,Highest_Level_of_Education_at_Start__c,Service_Began_via_Acquisition_Company__c,Service_Ended_via_Business_Divested__c,Was_dissatisfaction_reason_for_service_e__c,Who_was_dissatisfied__c, Primary_Reason_for_Dissatisfaction__c FROM Service_Assignment__c WHERE ';
        
    }
    
    //Display Results on the Page
    public pageReference run(){
    	//Browsers are inconsistent in validating the Required="true" atribute
    	if(fDate == null || tDate == null){
    		Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.INFO,'From and To Dates are required to run the report'));
    		return null;
    	}
        system.debug('full Query>>>>>>> '+queryString + generateWhereClause()+ sortOrder+' LIMIT 10000');
        //this.subServAssigns = Database.Query(queryString + generateWhereClause()+ sortOrder+' LIMIT 500');
        this.subServAssigns = new List<Service_Assignment__c>(); //Clear the State of previous results
        this.servAssigns = new List<Service_Assignment__c>(); ////Clear the State of previous results
        
        this.servAssigns = Database.Query(queryString + generateWhereClause()+ sortOrder+' LIMIT 10000');
        set<id> adms = new set<id>();
        set<id> pbs = new set<id>();
        for(Service_Assignment__c s: servAssigns){
            if(this.subServAssigns.size() < 500){
                this.subServAssigns.add(s);
            }
            if(!adms.contains(s.Admission__c)){
                adms.add(s.Admission__c);
            }
            if(!adms.contains(s.Person_being_served__c)){
                pbs.add(s.Person_being_Served__c);
            }
            
        }
        this.SACount = this.servAssigns.size();
        this.pbsCount = pbs.size();
        this.admissionCount = adms.size();
        
        if(this.servAssigns.size() == 0){
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.INFO,'No Service Assignments found for the selected criteria'));
        }else if(this.servAssigns.size() > 0 && this.servAssigns.size() <= 500 ){
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.INFO,'Showing '+this.subServAssigns.size()+' out of '+this.SACount+' Service assignments. Please click on export to excel to download the results'));
        }else if(this.servAssigns.size() > 500){
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.WARNING,'Showing '+this.subServAssigns.size()+' out of '+this.SACount+' Service assignments. Please click on export to excel to download the full results'));
        }
        this.servAssigns  = new list<Service_Assignment__c>(); //Clearing the view State
        return null;
    }
    
    //Export Results to Excel
    public pageReference exporttoExcel(){
    	//Browsers are inconsistent in validating the Required="true" atribute
    	if(fDate == null || tDate == null){
    		Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.INFO,'From and To Dates are required to run the report'));
    		return null;
    	}
        this.subServAssigns = new List<Service_Assignment__c>();//Clearing the view State from display results
        this.servAssigns  = new list<Service_Assignment__c>(); //Clearing the view State from display results 
        system.debug('full Query>>>>>>> '+queryString + generateWhereClause()+ sortOrder+' LIMIT 10000');
        this.servAssigns = Database.Query(queryString + generateWhereClause()+ sortOrder+' LIMIT 10000');
        set<id> adms = new set<id>();
        set<id> pbs = new set<id>();
        for(Service_Assignment__c s: servAssigns){
            if(!adms.contains(s.Admission__c)){
                adms.add(s.Admission__c);
            }
            if(!adms.contains(s.Person_being_served__c)){
                pbs.add(s.Person_being_Served__c);
            }
        }
        this.SACount = this.servAssigns.size();
        this.pbsCount = pbs.size();
        this.admissionCount = adms.size();
        
        PageReference pg = new pageReference('/apex/ReportPBSinProgramsExcel');
        pg.getHeaders().put('content-disposition', 'attachment;');
        pg.setRedirect(false);
        return pg;
    }
    
    //Generate the Where clause based on filter conditions
    public string generateWhereClause(){
        
        Datetime fromDate = DateTime.newInstance( this.fDate, Time.newInstance(0,0,0,0));
        Datetime toDate = DateTime.newInstance ( this.tDate, Time.newInstance(0, 0, 0, 0)); 
        string filter = '((Start_Date__c >= '+fromDate.format('yyyy-MM-dd')+' AND Start_Date__c <= '+toDate.format('yyyy-MM-dd')+')';
        filter = filter +' OR (End_Date__c >= '+fromDate.format('yyyy-MM-dd')+' AND End_Date__c <= '+toDate.format('yyyy-MM-dd')+')';
        filter = filter +' OR (Start_Date__c <= '+fromDate.format('yyyy-MM-dd')+' AND End_Date__c = null)';
        filter = filter +' OR (Start_Date__c <= '+fromDate.format('yyyy-MM-dd')+' AND End_Date__c >= '+toDate.format('yyyy-MM-dd')+'))';
        
        if(string.isNotBlank(maxAge) && maxAge.isNumeric()){
            max = integer.valueOf(maxAge);
            filter += ' AND Person_being_served__r.Age__c <= '+max;
        }
        if(string.isNotBlank(minAge) && minAge.isNumeric()){
            min = integer.valueOf(minAge);
            filter += ' AND Person_being_served__r.Age__c >= '+min;
        }
        if(string.isNotBLANK(pbsGender)){
            filter += ' AND Person_being_served__r.Gender__c = :pbsGender';
        }
        if(string.isNotBLANK(admState)){
            filter += ' AND Admission__r.State__c = :admState';
        }
        if(string.isNotBLANK(admStatus)){
            filter += ' AND Admission__r.Status__c = :admStatus';
        }
        if(string.isNOTBLANK(saStatus)){
            filter += ' AND Status__c = :saStatus';
        }
        if(string.isNOTBLANK(sltmnscope)){
            filter += ' AND Service_location__r.TMN_Scope__c = :sltmnscope';
        }
        if(String.isNOTBLANK(slserviceType)){
            filter += ' AND Service_location__r.Service_Type__c = :slserviceType';
        }
        if(string.isNOTBLANK(slNetworkOffering)){
            filter += ' AND Service_location__r.Network_offering__c = :slNetworkOffering';
        }
        if(string.isNOTBLANK(populationServed)){
            filter += ' AND Service_location__r.Population_Served__c = :populationServed';
        }
        if(string.isNOTBLANK(physicalLocation)){
            filter += ' AND Service_location__r.Population_Served__c = :physicalLocation';
        }
        if(string.isNOTBlank(aliases)){
            aliasList = aliases.split(',');
            filter += ' AND Service_Location__r.Name IN :aliasList';
        }
        if(string.isBlank(saStatus)){
            filter += ' AND Status__c IN(\'Active\',\'Inactive\')'; // Not using != 'Created due to error' as != condition will trigger full database scan and is inefficient   
        }
        
        
        return filter;
    }
    
    
    
    
/*  @RemoteAction
    //Perfroming the SOQL; string generation in Remote action as apex has built in methods to parse the data easily - Sravan - 17/11/2015
    public static Service_Assignment__c[] getServiceAssignments(string fromD, string toD, string ageMax, string ageMin, string gender,
                                                    string admissionState, string admissionStatus, string servAssignStatus,
                                                    string aliasName, string SLtmnScope, string SLserviceType, string SLnetworkLine,
                                                    string SLpopulationServed, string SLphysicalLocation  ){
                                                        
        string SOQL = 'SELECT Id, Person_Being_Served__r.PBS_Identifier__c, Person_being_served__r.LastName,Person_being_served__r.FirstName, Person_being_served__r.Age__c, Person_being_served__r.Gender__c, Person_Being_Served__r.Does_the_person_Identify__c, Person_being_served__r.Race__c, Person_being_served__r.MailingStateCode,';
                SOQL = SOQL+' admission__r.Name, Admission__r.State__c, Admission__r.Status__c, Admission__r.Admission_Effective_DateTime__c, Admission__r.Discharged_Date__c, Name, Status__c, SA_Start_DateTime__c, End_Date__c, Alias__c, Service_Location__r.Location_Nickname__c,';
                SOQL = SOQL+' Service_Location__r.TMN_Scope__c, Service_Location__r.Network_Offering__c,Service_Location__r.Population_Served__c, Service_Location__r.Physical_Location__c, Service_Location__r.Service_Type__c,';
                SOQL = SOQL+' Was_this_transfer_frm_another_ServAssig__c, Is_this_transfer_to_another_ServAssign__c,Highest_Level_of_Education_at_Start__c,Service_Began_via_Acquisition_Company__c,Service_Ended_via_Business_Divested__c,Was_dissatisfaction_reason_for_service_e__c,Who_was_dissatisfied__c, Primary_Reason_for_Dissatisfaction__c FROM Service_Assignment__c WHERE id!= null';
        
        system.debug('fromDate>>>> '+fromD);
        system.debug('todate>>>> '+toD);
        system.debug('ageMax>>>> '+ageMax);
        system.debug('ageMin>>>> '+ageMin);
        system.debug('Gender>>>> '+gender);
        system.debug('admissionState>>>> '+admissionState);
        system.debug('admissionStatus>>>> '+admissionStatus);
        system.debug('servAssignStatus>>>> '+servAssignStatus);
        system.debug('aliasName>>>> '+aliasName);
        system.debug('SLtmnScope>>>> '+SLtmnScope);
        system.debug('SLserviceType>>>> '+SLserviceType);
        system.debug('SLnetworkLine>>>> '+SLnetworkLine);
        system.debug('SLpopulationServed>>>> '+SLpopulationServed);
        system.debug('SLphysicalLocation>>>> '+SLphysicalLocation);
        
        string whereClause = '';                
        if(gender != null){
            system.debug('Gender>>>> '+gender);
            whereClause += ' AND Person_being_served__r.Gender__c = :gender';
        }
        if(admissionState != null){
            system.debug('admissionState>>>> '+admissionState);
            whereClause += ' AND Admission__r.State__c = :admissionState';
        }
        if(admissionStatus != null){
            system.debug('admissionStatus>>>> '+admissionStatus);
            whereClause += ' AND Admission__r.Status__c = :admissionStatus';
        }
        if(servAssignStatus != null){
            system.debug('servAssignStatus>>>> '+servAssignStatus);
            whereClause += ' AND Status__c = :servAssignStatus';
        }
        if(SLtmnScope != null){
            system.debug('SLtmnScope>>>> '+SLtmnScope);
            whereClause += ' AND Service_location__r.TMN_Scope__c = :SLtmnScope';
        }
        if(SLserviceType != null){
            system.debug('SLserviceType>>>> '+SLserviceType);
            whereClause += ' AND Service_location__r.Service_Type__c = :SLserviceType';
        }
        if(SLnetworkLine != null){
            system.debug('SLnetworkLine>>>> '+SLnetworkLine);
            whereClause += ' AND Service_location__r.Network_offering__c = :SLnetworkLine';
        }
        if(SLpopulationServed != null){
            system.debug('SLpopulationServed>>>> '+SLpopulationServed);
            whereClause += ' AND Service_location__r.Population_Served__c = :SLpopulationServed';
        }
        if(SLphysicalLocation != null){
            system.debug('SLphysicalLocation>>>> '+SLphysicalLocation);
            whereClause += ' AND Service_location__r.Population_Served__c = :SLphysicalLocation';
        }
                        
        System.debug('SOQL>>>>>>>>>>>>>> '+SOQL+whereClause);
        
        Service_Assignment__c[] servAssigns = Database.Query(SOQL+' LIMIT 500');
        return servAssigns;
    }*/

}