global class pnClinicianBatch implements Database.Batchable<sObject> 
{
	global final string targetState;
	
	global pnClinicianBatch (String st){
             targetState = st;
   }
	global Database.QueryLocator start( Database.BatchableContext BC) {
		String query = 'select id, staff_name__c, clinician__c from progress_note__c where service_assignment__r.admission__r.state__c = :targetState and clinician__c = null and staff_name__c != null and staff_name__c <> \'\'' ;
		
		system.debug( query + ', ' + targetState );
		return Database.getQueryLocator( query );
		
	}

	global void execute(Database.BatchableContext BC, List<Progress_Note__c> scope) {

		// get unique list of users for whom to get associated TMN User records
		Set<ID> userList = new Set<ID>();
		List<TMN_user__c> tmnList = new List<TMN_User__c>();
		Map<ID, ID> mapUsertoTMN = new Map<ID, ID>();
		Map<ID, String> empMap = new Map<ID, String>();

		for (Progress_Note__c p : scope ) {
			userList.add( p.staff_name__c);
		}
			
		// get the list of tmn_users so we can go from user id to tmn id
		tmnList = [ select id, salesforce_user_account__c, employee_number__c from tmn_user__c where salesforce_user_account__c in :userList];
		
		for (TMN_user__c t : tmnList ) {
			mapUsertoTMN.put( t.salesforce_user_account__c, t.id );
			empMap.put( t.salesforce_user_account__c, t.employee_number__c);
		}
		
		List<Progress_Note__c> toUpdate = new List<Progress_Note__c>();
		for ( Progress_note__c p : scope ) {
			p.clinician__c = mapUsertoTMN.get( p.staff_name__c );
			p.Clinician_Employee_ID__c = empMap.get( p.staff_name__c);
			toUpdate.add(p);
		}
		
		update toUpdate;
		
	}
	global void finish(Database.BatchableContext BC)
    {
    }
    
}

