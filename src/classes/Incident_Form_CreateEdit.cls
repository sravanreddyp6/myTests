@isTest
public with sharing class Incident_Form_CreateEdit {
    public Incident__c incident {get; set;}
    private Apexpages.standardController controller;
    public ID SAid = Apexpages.currentpage().getparameters().get('SAid');
    public ID recTypeId = apexpages.currentpage().getparameters().get('RecordtypeId'); 
    public string recordtypeName {get; set;}
    public boolean isNew{get; set;}
    public String personListJSON { get; set; }
    public string getprogDetail() {    	
    	if( SAid != null ){
    		return [select name, id, Program_Detail__c from service_assignment__c where id=:SAid].Program_Detail__c;
    	}
    	else if (incident.service_assignment__c != null){
    		return incident.Service_Assignment__r.Program_Detail__c;
    	
    	}
    	return '';
	}
    
    public Incident_Form_CreateEdit(ApexPages.StandardController controller) {
        this.controller = controller;
        if(!test.isRunningTest()){
            controller.addFields(new list<String>{'Recordtype.Name', 'Service_Assignment__r.Program_Detail__c'});// Add additonal fields here  
        }
        this.incident = (Incident__c)controller.getRecord();
        //New record creation
        isNew = false;
        if(Apexpages.currentpage().getparameters().get('Id') == null){
            recordtypeName = Utility.getIncidentRecordTypeName(recTypeId);
            this.incident.RecordtypeId = recTypeId;
            isNew = true;
            if(SAid != null){
                this.incident.Service_Assignment__c = SAid;
            }
        }
        //for existing records
        if(apexpages.currentpage().getparameters().get('Id') != null){
            recordtypeName = this.incident.Recordtype.Name;
            isNew = false;
        }
        loadPage();
        
    }
    public void loadPage(){
        
        
    }
    
    public pageReference saveIncident( ){
    	
    	// if we get an error return null.
        if( validateIncidentSave(incident, (Incident_Person__c[])JSON.deserialize( personListJSON, List<Incident_Person__c>.class )) )
        	{return null;}
        try{
            upsert this.incident;
            //Pagereference pg = new pagereference('/apex/Incident_Form_View?Id='+this.Incident.Id);
            // save the related people
            saveRelatedPeople();
            
            Pagereference pg = new pagereference('/'+this.Incident.Id);
            return pg;
        }
        catch(exception e){
             ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
             return null;
        }
        
        return null;
        
    }
    
    // adds new people to parent incident
	private void saveRelatedPeople () {
		List<Incident_Person__c> personList = (Incident_Person__c[])JSON.deserialize( personListJSON, List<Incident_Person__c>.class );
		for ( Incident_Person__c ip : personList) {
				ip.Incident__c = this.incident.id;
				upsert ( ip );
			}
		}
		
    
    
    public Service_Assignment__c servAssign {get{
        if(servAssign == null && this.incident.Service_Assignment__c != null){ 
            system.debug('i am in the getter');
            servAssign = [SELECT id, Admission__c, Admission__r.Person_being_served__c FROM Service_Assignment__c WHERE Id=: this.incident.Service_Assignment__c];
        }
        
        return servAssign;
    }   
    set;}
    
    public boolean validateIncidentSave(Incident__c incident, List<Incident_Person__c> personList){
        boolean hasError = false; 
		if( incident.Unknown_Date_Occurred__c == false && incident.Date_Occurred__c == null ){
            incident.Date_Occurred__c.addError('Please provide date/time incident occurred or select unknown'); hasError = true;
        }         
        if(incident.First_Reported_By__c == 'Employee' && incident.First_Reported_Staff__c == null){
            incident.First_Reported_Staff__c.addError('Staff required'); hasError = true;
        }
        if(incident.First_Reported_By__c == 'Mentor' && incident.First_Reported_Mentor__c == null){
            incident.First_Reported_Mentor__c.addError('Mentor required'); hasError = true;
        }  
        if(incident.First_Reported_By__c == 'External Party' && incident.External_Party__c == null){
            incident.External_Party__c.addError('External Party required'); hasError = true;
        }              
        if(incident.Where_incident_occurred__c == 'Other Location' && incident.Other_Location__c == null){
            incident.Where_incident_occurred__c.addError('Other location is required'); hasError = true;
        }  
        if(incident.Where_incident_occurred__c == 'Community Location' && incident.Community_Location__c == null){
            incident.Where_incident_occurred__c.addError('Community Location is required'); hasError = true;
        }
        set<string> WhereTypes = new set<string>();
        WhereTypes.add('Day Program');
        WhereTypes.add('Place of Employment');
        WhereTypes.add('Program Office');
        WhereTypes.add('Residence');
        WhereTypes.add('School');
        WhereTypes.add('Vehicle');
        WhereTypes.add('Host Home/Foster Home');
        if( WhereTypes.contains(incident.Where_incident_occurred__c)  && incident.Network_Type__c == null){
            incident.Where_incident_occurred__c.addError('Type is required'); hasError = true;
        }       
 		if( incident.First_Response_Action_Taken__c != null && incident.First_Response_Action_Taken__c.contains('Other') && incident.First_Response_Action_Taken_Other__c == null){
            incident.First_Response_Action_Taken_Other__c.addError('Other is required'); hasError = true;
        }   
        boolean hasMentor = false;
        boolean hasStaff = false;
        boolean hasOther = false;
        for(Incident_Person__c ip : personList ){
        		system.debug('pp - ' + ip.person_type__c);
        	if(ip.person_type__c =='Mentor'){hasMentor = true;}
        	if(ip.person_type__c =='Staff'){hasStaff = true;}
        	if(ip.person_type__c =='Other'){hasOther = true;}
        }
		for(Incident_Person__c ip :  [ select id, person_type__c from incident_person__c where incident__c = :incident.id ]){
    		system.debug('pp - ' + ip.person_type__c);
        	if(ip.person_type__c =='Mentor'){hasMentor = true;}
        	if(ip.person_type__c =='Staff'){hasStaff = true;}
        	if(ip.person_type__c =='Other'){hasOther = true;}			
		}
		
		        
        if(incident.Staff_Present__c == 'Yes' && !hasStaff){hasError = true; incident.Staff_Present__c.addError('Please add at least one Staff');}
        
        if(incident.Others_Present_at_Time_of_Incident__c == 'Yes' && !hasOther){hasError = true; incident.Others_Present_at_Time_of_Incident__c.addError('Please add at least one Other Person');}
        
        if(incident.Mentor_present__c == 'Yes' && !hasMentor){hasError = true; incident.Mentor_present__c.addError('Please add at least one Mentor');}               
        return hasError;
        
    }  
    public boolean validateIncidentSubmit(Incident__c incident){
    	boolean hasError = false; 
    	
		if( incident.Unknown_Date_Occurred__c == false && incident.Date_Occurred__c == null ){
            incident.Date_Occurred__c.addError('Please provide date/time incident occurred or select unknown'); hasError = true;
        }  
		if( incident.Date_Reported__c == null ){
            incident.Date_Reported__c.addError('Date/time reported is required'); hasError = true;
        }       
   		if( incident.First_Reported_By__c == null ){
            incident.First_Reported_By__c.addError('First reported by is required'); hasError = true;
        } 
   		if( incident.Where_incident_occurred__c == null ){
            incident.Where_incident_occurred__c.addError('Where did the incident occur is required'); hasError = true;
        }   
 		if( incident.First_Response_Action_Taken__c == null ){
            incident.First_Response_Action_Taken__c.addError('First Response Action Taken is required'); hasError = true;
        }   
 		if( incident.Staff_Present__c == null ){
            incident.Staff_Present__c.addError('Staff Present is required'); hasError = true;
        }      
 		if( incident.Mentor_present__c == null ){
            incident.Mentor_present__c.addError('Mentor Present is required'); hasError = true;
        }                               
        return hasError; 
    }
    
}