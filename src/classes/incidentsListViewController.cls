public with sharing class incidentsListViewController {
	
	public List<Incident__c> incidents {get; set;}
	public string selectedIncident {get; set;}
	public string userChosenIncident {get; set;}
	public boolean myIncidents {get; set;}
	public boolean allIncidents {get; set;}
	
	public incidentsListViewController(){
		//constructor
		incidents = new List<Incident__c>();
		myIncidents = false;
		allIncidents = false;
		if(Apexpages.Currentpage().getParameters().get('flag') == 'MY'){
			myIncidents = true;
		}
		if(Apexpages.Currentpage().getParameters().get('flag') == 'ALL'){
			allIncidents = true;
		}
		displayIncidents();
	}
	
	
	public List<selectOption> getIncidentTypes() {
		List<SelectOption> Options = new List<SelectOption>();
		Options.add(new SelectOption('All Incidents','All Incidents'));
		Options.add(new SelectOption('PBS','PBS'));
		Options.add(new SelectOption('Employee','Employee'));
		Options.add(new SelectOption('Location','Location'));
		Options.add(new SelectOption('Mentor','Mentor'));
		
		return options;
	}

	public void displayIncidents() {
		string SOQL;
		if(myIncidents){
			Id userId = UserInfo.getUserId();
			SOQL = 'SELECT Id, NAME, Status__c, Recordtype.Name FROM Incident__c WHERE OwnerId=: userId';
		}
		if(allIncidents){
			SOQL = 'SELECT Id, NAME, Status__c, Recordtype.Name FROM Incident__c WHERE Id != null';
		}
		
		if(selectedIncident != null && selectedIncident != 'All Incidents'){
			SOQL = SOQL + ' AND Recordtype.Name= :selectedIncident';
		
		}
		SOQL = SOQL + ' Order By CreatedDate DESC LIMIT 1000';
		//String orderStatement = '';
		incidents = Database.query(SOQL);
	}

}