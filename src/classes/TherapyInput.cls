public with sharing class TherapyInput {


	public list<SelectOption> locationList { get; private set;}
	public list<SelectOption> pbsList { get; private set; }
	
	private list<service_assignment__c> activeSA;
	
	public void TherapyInput() {
		
		Set<ID> locations = new set<ID>();
		Set<ID> people = new set<ID>();
		
		// get the active Service Assignments - based on current status only.  we will check dates upon submit
		activeSA = [ select id, 
							person_being_served__c, 
							person_being_served__r.name, 
							service_location__c, 
							service_location__r.programid__c, 
							service_location__r.program__c 
					from 
						service_assignment__C 
					where status__c = 'Active'];
		
		for (service_assignment__c sa: activeSA ) {
			locations.add( sa.service_location__c);
			people.add( sa.person_being_served__c);
		}
	}
}