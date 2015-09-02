global class saOwnershipBatch implements Database.Batchable<sObject> 
{
	global final string targetState;
	
	global saOwnershipBatch (String st){
             targetState = st;
   }
	global Database.QueryLocator start( Database.BatchableContext BC) {
		String query = 'select id from service_assignment__c where admission__r.state__c = :targetState and clinician__c = null' ;
		
		system.debug( query + ', ' + targetState );
		return Database.getQueryLocator( query );
		
	}

	global void execute(Database.BatchableContext BC, List<Service_Assignment__c> scope) {

system.debug(scope.size());

		// get unique list of users for whom to get associated TMN User records
	Set<ID> userList = new Set<ID>();
	List<TMN_user__c> tmnList = new List<TMN_User__c>();
	Map<ID, ID> mapUsertoTMN = new Map<ID, ID>(); 
system.debug( targetState);	
	if ( targetState == 'NC' || targetState == 'FL' || targetState == 'GA') {
		// SAs needing clincians that don't have finalized progress notes
		List<Service_Assignment__c> saNoClinicianList = [ select id, clinician__c, person_being_served__r.ownerid from service_assignment__c where id in :scope ];
		
		// add users who are owners of SA list
		for ( Service_Assignment__c sa : saNoClinicianList )
			userList.add( sa.person_being_served__r.ownerid );
	
		// get the list of tmn_users so we can go from user id to tmn id
		tmnList = [ select id, salesforce_user_account__c from tmn_user__c where salesforce_user_account__c in :userList];
	
		for (TMN_user__c t : tmnList ) {
			mapUsertoTMN.put( t.salesforce_user_account__c, t.id );
		}
		for ( Service_Assignment__c sa: saNoClinicianList ) 
			sa.clinician__c = mapUsertoTMN.get( sa.person_being_served__r.ownerid);
		
		system.debug('NO CLINICIAN DATA: ' +  saNoClinicianList) ;	
		update saNoClinicianList;
		
	} else {	
		
//system.debug( targetState );
		
		Set<ID> saIDSet = new Set<Id>();
		List<Progress_Note__c> pnList = new List<Progress_Note__c>();
	
		system.debug( 'CHECKING FOR: ' + targetState );
		// get progress notes associated with the SAs needing clinicians 
		pnList = [ select id, service_assignment__c, clinician__c, staff_name__c, status__c, person_Being_served__r.ownerid, lastmodifieddate from progress_note__c where service_assignment__c in :scope and service_assignment__r.clinician__c = null and status__c = 'Final' order by lastmodifieddate desc];
		
		// create a unique list of SAs with progress notes needing update
		for ( Progress_note__c p : pnList ) 
			saIDSet.add( p.service_assignment__c);
			
		// get SAs needing clincians that don't have finalized progress notes
		List<Service_Assignment__c> saNoPNList = [ select id, clinician__c, person_being_served__r.ownerid from service_assignment__c where id in :scope and id not in :saIDSet and clinician__c = null];
		
		
		Map<ID, List<Progress_Note__c>> sawithPNList = new Map<ID, List<Progress_note__c>>();
		for ( Progress_note__c p : pnList ) {
		
			// add user-lookup staff to list to later match to tmn user based lookup
			if ( !string.isBlank(p.staff_name__c))
				userList.add( p.staff_name__c);
			
			// create the map of service assignment to list of progress notes for checking status and dates
			if ( sawithPNList.containsKey( p.service_assignment__c )) {
				List<Progress_Note__c> pnl = sawithPNLIst.get( p.service_assignment__c);
				pnl.Add( p );
				sawithPNList.put( p.service_assignment__c, pnl );
			} else {
				sawithPNList.put ( p.service_assignment__c, new List<Progress_Note__c> { p } );
			}
		}
		
		// add users who are owners of SA list
		for ( Service_Assignment__c sa : saNoPNList )
			userList.add( sa.person_being_served__r.ownerid );
		
		// get the list of tmn_users so we can go from user id to tmn id
		tmnList = [ select id, salesforce_user_account__c from tmn_user__c where salesforce_user_account__c in :userList];
		mapUsertoTMN = new Map<ID, ID>(); 
		for (TMN_user__c t : tmnList ) {
			mapUsertoTMN.put( t.salesforce_user_account__c, t.id );
		}
		
		
		// service assignments with no progress notes will take the PBS owner as the clinician
		for ( Service_Assignment__c sa: saNoPNList ) 
			sa.clinician__c = mapUsertoTMN.get( sa.person_being_served__r.ownerid);
		
		//system.debug( 'NO PN DATA: ' + saNoPNList) ;
		
		update saNoPNList;
			
		// service assignments with progress notes - get staff name off the most recent note
		List<Service_Assignment__c> saToUpdate = [ select id, clinician__c from service_assignment__c where id in :saWithPNList.keyset() ];
		
		for ( Service_Assignment__c sa : saToUpdate ) {
			// skip SA with no progress notes - this shouldn't happen
			if ( sawithPNList.get( sa.ID).size() == 0 ) {
				system.debug( 'The SA with id: ' + sa.ID + ' has no progress notes' );
				continue;
			} else {
				Progress_Note__c pn = sawithPNLIst.get(sa.ID).get(0);
				//system.debug( 'Latest progress note for ' + sa.ID + ' is ' + pn + '.  Setting clinician to ' + pn.staff_name__c );
				if ( String.IsBlank(pn.staff_name__c))
					sa.clinician__c = mapUsertoTMN.get( pn.person_being_served__r.ownerid );
				else
					sa.clinician__c = mapUsertoTMN.get( pn.staff_name__c );
			}
		
		}
	
		//system.debug( 'SA WITH PN: ' + sawithPNList );
		//system.debug( 'SA WITH CLINICIAN PN: ' + saToUpdate );
	
		update saToUpdate;
		}
	}
	global void finish(Database.BatchableContext BC)
    {
    }
    
}

