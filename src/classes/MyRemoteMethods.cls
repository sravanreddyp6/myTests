//do not make this without sharing... or else it would not return the correct list of programs for the logged in user
public with sharing class MyRemoteMethods {
	private transient TxnQueueResponseController parentCntrller;

    class Im_partyData{
        Id id;
        String DT_RowId;
        String name;
        String type;
        String action = '<a class="btn AddEvent" href="javascript:void(0);">Add Events</a>';
        Im_partyData(Im_InvolvedParty__c party){
            this.involvedParty = party;
            this.DT_RowId = String.valueOf(party.id);
            this.id = party.id;
            this.type = party.Type__c;
            if (party.Type__c == 'Person Being Served') this.name = party.Person_Being_Served_Involved__r.pbsFirstName__c + ' ' + party.Person_Being_Served_Involved__r.pbsLastName__c;
            else if (party.Type__c == 'Staff') this.name = party.Staff_Involved__r.name;
            else this.name = party.name;
        }
        Im_InvolvedParty__c involvedParty;
    }
    
	@ReadOnly @RemoteAction public static list<Im_partyData> getInvolvedParties(String EventId) {
        Id event = (EventId instanceof Id) ? (Id) EventId : null;
        list<Im_partyData> dataObj = new list<Im_partyData>();
        for (Im_InvolvedParty__c imPrty : [select id, Type__c, name, Person_Being_Served_Involved__r.pbsFirstName__c, Person_Being_Served_Involved__r.pbsLastName__c, 
        									Staff_Involved__r.name from Im_InvolvedParty__c where Im_Incident__c =: event order by Type__c]){
            dataObj.add(new Im_partyData(imPrty));
        }
        return dataObj;		 
    }

    public list<SelectOption> getMyService_Locations(){
        list<SelectOption> programslist = new list<SelectOption>();
        if (parentCntrller != null &&  String.isEmpty(parentCntrller.incident.event.Service_Location)) programslist.add(new SelectOption('','') );
        list<AggregateResult> slPrgms = [SELECT service_location__r.id slID, service_location__r.Alias__c alias, service_location__r.program__c prgm
                                         FROM service_assignment__c
                                         GROUP BY service_location__r.id, service_location__r.program__c, service_location__r.Alias__c 
                                         HAVING COUNT(service_location__r.id) > 0
                                         ORDER BY service_location__r.program__c];
        for (AggregateResult slPrgm : slPrgms) {
            programslist.add(new SelectOption((Id)slPrgm.get('slID'), String.valueOf(slPrgm.get('alias')) + '-' + String.valueOf(slPrgm.get('prgm')) ));
        }
        return programslist;
    }
    

    
    public MyRemoteMethods(TxnQueueResponseController controller){
    	this.parentCntrller = controller;
    }
    public MyRemoteMethods(){}
    
    class SelOption {
        String id;
        String text;
        String email;
        String jobTitle;
        sobject obj;
        SelOption(sobject obj){
            this.id = String.valueOf(obj.get('Id'));
			if (obj instanceof TMN_User__c){
            	TMN_User__c tmnUser = (TMN_User__c) obj;
	            this.text = tmnUser.name;
	            this.email = tmnUser.email__c;
	            this.jobTitle = tmnUser.job_title__c;
            }
            else if (obj instanceof Service_Assignment__c){
//  					obj.put('HelloThere','HelloThere');          		
            }
            this.obj = obj;
        }
    }
    
    @RemoteAction public static list<SelOption> getPBSFortheProgram(String params){
        map<String, String> values = (Map<String, String>) JSON.deserialize(params, map<String, String>.class);
        if ((!values.keySet().contains('programLocation') || String.IsEmpty(values.get('programLocation')) || !(values.get('programLocation') instanceof Id) )) { throw new CustomException('Missing program location.'); return null; }
        Id sl = ( (Id) values.get('programLocation') );
        String searchTerm = '%' + String.ValueOf(values.get('q')).trim() + '%' ;
        
        list<SelOption> retVal = new list<SelOption>();
        map<Id, Service_Assignment__c> pbsSASet = new map<Id, Service_Assignment__c>();

        list<Service_Assignment__c> sAs = [select Id, person_being_served__c, pbsLastName__c, pbsFirstName__c, person_being_served__r.Age_Text__c, person_being_served__r.Gender__c 
        									 from Service_Assignment__c 
        									where service_location__c =: sl and Status__c = 'Active' 
        									 and (pbsFirstName__c like : searchTerm OR pbsLastName__c like : searchTerm) order by Name];
		for(Service_Assignment__c sa : sAs){
			pbsSASet.put(sa.person_being_served__c, sa);
			retVal.add(new SelOption(sa));
		}        
        for(Attachment headShot : [SELECT Id, Name,  ParentId from Attachment where Name LIKE 'HeadShot-Current%' and ParentId IN : pbsSASet.keySet()]){
			Service_Assignment__c sa = (Service_Assignment__c) pbsSASet.get(headShot.ParentId);
			//chose a dummy on the SA object to carrry the pbs headShot attachment id 
			sa.Flavor__c = '/servlet/servlet.FileDownload?file=' + headShot.id;
        }        
        return retVal;
    }
    
        
    class CustomException extends Exception {}
    
    @RemoteAction public static list<SelOption> getStaffFortheProgram(String params){
        map<String, String> values = (Map<String, String>) JSON.deserialize(params, map<String, String>.class);
        if ((!values.keySet().contains('programLocation') || String.IsEmpty(values.get('programLocation')) || !(values.get('programLocation') instanceof Id) )) { throw new CustomException('Missing program location.'); return null; }   
        Id sl = ( (Id) values.get('programLocation') );
        Id aliasForPrgram = [select Alias_lookup__c from Service_Location__c where id =: sl limit 1].Alias_lookup__c;
        String searchTerm = '%' + String.ValueOf(values.get('q')).trim() + '%' ;
        
        list<SelOption> retVal = new list<SelOption>();
        // get the list of tmn users for the alias based on the service location user must have proviced to call this method else throw exception.  
        for (TMN_User__c t : [select Id, Name, email__c, job_title__c from TMN_User__c where Alias_Lookup__c =: aliasForPrgram and Job_Status__c = 'Active' and Name like : searchTerm order by Name]){
            retVal.add(new SelOption(t));
        } 
        //return JSON.serialize(retVal);
        return retVal;
    }
    
    @RemoteAction public static list<SelOption> getEventReviewerForProgram(String params){
        map<String, String> values = (Map<String, String>) JSON.deserialize(params, map<String, String>.class);
        if ((!values.keySet().contains('programLocation') || String.IsEmpty(values.get('programLocation')) || !(values.get('programLocation') instanceof Id) )) { throw new CustomException('Missing program location.'); return null; }   
        Id sl = ( (Id) values.get('programLocation') );
        Id aliasForPrgram = [select Alias_lookup__c from Service_Location__c where id =: sl limit 1].Alias_lookup__c;
        String searchTerm = '%' + String.ValueOf(values.get('q')).trim() + '%' ;
        
        list<SelOption> retVal = new list<SelOption>();
        // get the list of tmn users for the alias based on the service location user must have proviced to call this method else throw exception.  
        for (TMN_User__c t : [select Id, Name, email__c, job_title__c from TMN_User__c 
                              where Salesforce_User_Account__c != null 
                              and Salesforce_User_Account__c !=: UserInfo.getUserId()
                              and Job_Status__c = 'Active' 
                              and Alias_Lookup__c =: aliasForPrgram
                              and Approval_Level__c > 2 
                              and Name like : searchTerm 
                              order by Name] ){
                                  retVal.add(new SelOption(t));
                              } 
        //return JSON.serialize(retVal);
        return retVal;
    }
    
}