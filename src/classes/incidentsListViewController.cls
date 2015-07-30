public with sharing class incidentsListViewController {
	
	public List<Incident__c> incidents {get{
		if(incidents == null){
			incidents = [SELECT Id, Name, Recordtype.name, Status__c FROM Incident__c];
		}
			return incidents;
		}
		set;
	}
	
	public incidentsListViewController(){
		//constructor
	}

}