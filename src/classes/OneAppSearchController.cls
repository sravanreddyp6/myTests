public with sharing class OneAppSearchController {

	//declaring variables
	public String firstName{ get; set; }
	public String lastName{ get; set; }
	public String pgm { get; set; }
	public List<String> excludeSAList { get; set; } // list of SAs to excluded from search
	public List<String> excludePBSList { get; set; } // list of PBS to exclude from search
	
	public transient List<SearchResult> searchResults = new List<SearchResult>();

	// constructor
	public OneAppSearchController() {
		firstName = ApexPages.currentPage().getParameters().get('FirstNM');
		lastName = ApexPages.currentPage().getParameters().get('LastNM');
		pgm = '%';
	}
	
	public OneAppSearchController( string f, string l, string p ) {
		firstName = f + '%';
		lastName = l + '%';
		pgm = p + '%';
	}

	//wrapper return method
	public List<SearchResult> getSearchResults(Boolean searchPbs, Boolean searchPbr, Boolean searchTMNContact, Boolean activeOnly) {
		searchResults = new List<SearchResult>();
		String firstNames;
		String LastNames;
		String age;
		String state;
		String types;
		String alias;
		String program;
		ID personId;	// for person
		ID admId;	// for active admission 
		ID saId;	// for active SA
		ID apId;	// for active action plan


		// if program is populated, only searching for PBS
		if ( pgm != '%' ) {
			searchPbs = true;
			searchPbr = false;
		}
			
		if (searchPbs) {
			
				
			string activeQuery = 'SELECT Id, person_being_served__r.firstname, person_being_served__r.lastname,' +  
								' person_being_served__r.age__c, Person_Being_Served__c, admission__r.state__c, admission__c, ' + 
								' Service_Location__r.location_nickname__c, Service_Location__r.Alias__c,' + 
			       				' sa_start_datetime__c, Status__c ' +
			  					' FROM service_assignment__c ' + 
			  					' WHERE ';
			 
			if ( activeOnly ) {
			 	activeQuery += 'status__c = \'Active\'';
			}
			
						
			if ( !String.isBlank(firstName) || !String.isBlank( lastName)) {
				if ( !activeQuery.endsWith( ' WHERE ')) 
			 		activeQuery += ' and ';
					
			 	activeQuery += buildCriteria(lastName, firstName, 'person_Being_served__r.lastname', 'person_Being_served__r.firstname', false);
			}	
			 if ( pgm != '%') {
			 	
			 	if ( !activeQuery.endsWith( ' WHERE ')) 
			 		activeQuery += ' and ';
			 		
			 	activeQuery += ' (service_location__r.location_nickname__c like \'' + pgm + '\' or service_location__r.alias__c like \'' + pgm  + '\' or service_location__r.programid__c like \'' + pgm + '\')'; 
			 }
			 
			 // if there are service assignments to exclude, those take precedence over PBS
			 if ( excludeSAList != null )
			 	activeQuery += ' and id not in :excludeSAList';
			 
			 // no SAs to exclude so just exclude all of the PBS 
			 if ( excludeSAList == null && excludePBSList != null )
			 	activeQuery += ' and person_being_served__c not in :excludePBSList'; 
			 
			 activeQuery += ' LIMIT 1000'; 	// for collection size limitation
			 
			 system.debug('SEARCH IS: ' + activeQuery);
			 for ( Service_Assignment__c sa : database.Query(activeQuery)) {
			 	searchResults.add( new SearchResult( sa.person_Being_served__r.firstname, sa.person_Being_served__r.lastname,
			 						string.valueof(sa.person_being_served__r.age__c), sa.admission__r.state__c, 'Person Being Served',
			 						sa.person_being_served__c, sa.admission__c, sa.Id, null, 
			 						sa.service_location__r.alias__c,
			 						sa.service_location__r.location_nickname__c, sa.status__c));
			 }
			 
		}

		if (searchPbr) {
			
			String pbrQuery = 'select id, First_Name__c, Last_Name__c, Age__c, state__c, (select Name,State_for_Preferred_Service__c,Name_PBR__c,Person_Being_Referred__r.Name,Person_Being_Referred__c from Referrals__r) from Person_Being_Referred__c where ' +buildCriteria(lastName, firstName, 'last_name__c', 'first_name__c', false);
			system.debug(pbrQuery);
			ID recordID;
			for(Person_Being_Referred__c pbr:database.Query(pbrQuery)) {
				firstNames = pbr.First_Name__c;
				LastNames = pbr.Last_Name__c;
				age = String.valueOf(pbr.Age__c);
				for(Referral__c ref:pbr.Referrals__r) {
					if(ref.State_for_Preferred_Service__c!=null && ref.Person_Being_Referred__c==pbr.Id) {
						state = ref.State_for_Preferred_Service__c;
					} else {
						state = pbr.State__c;
					}
				}
				types = 'Person Being Referred';
				recordId = pbr.Id;

				searchResults.add(new SearchResult(firstNames,LastNames,age,state,types,recordId, null, null, null, null, null, null));
			}
		}
/*
		if (searchTMNContact) {
			String tmnQuery = 'select Id,Name,First_Name__c,First_Name_SoundEx_Key__c,Last_Name__c,Last_Name_SoundEx_Key__c,Full_Name__c,Age__c,State__c from TMN_Contact__c where ' + buildCriteria(lastName, firstName, 'last_name__c', 'first_name__c');
			system.debug(tmnQuery);
			for(TMN_Contact__c tmn:database.Query(tmnQuery))  {
				firstNames = tmn.First_Name__c;
				LastNames = tmn.Last_Name__c;

				age = String.valueOf(tmn.Age__c);
				state = tmn.State__c;
				types = 'Mentor';
				recordId = tmn.Id;

				searchResults.add(new SearchResult(firstNames,LastNames,age,state,types,recordId));
			}
		}
*/

		return searchResults;
	}

	public class SearchResult{
		public String firstName { get; set; }
		public String lastName { get; set; }
		public String Age { get; set; }
		public String State { get; set; }
		public String Type { get; set; }
		public Id recordId { get; set; }
		public Id admID { get; set; }	// for active-only search
		public Id saID { get; set; }
		public Id apID { get; set; }
		public String alias { get; set; }
		public String program { get; set;}
		public string status { get; set; }
		

		public SearchResult(String firstName, String LastName, String age, String state, String types, Id recordId) {
			this(firstName, LastName, age, state, types, recordId, null, null, null, null, null, null);
		}
		public SearchResult(String firstName, String LastName, String age, String state, String types, Id recordId, ID adm, ID sa, ID ap, string al, string pgm, string sastat) {
			this.firstName = firstName;
			this.lastName = lastName;
			this.Age = age;
			this.State = state;
			this.Type = types;
			this.recordId = recordId;
			this.admID = adm;
			this.saID = sa;
			this.apID = ap;
			this.alias = al;
			this.program = pgm;
			this.status = sastat;
		}
	}

	// build query conditions for name - use like search
	public static String buildCriteria(String lastname, String firstname, String lastnamefield, String firstnamefield, boolean exactmatch) {
		String lNameSearch='', fNameSearch='', criteria='(';

		if (lastname!=null && lastname!='') {
			if ( exactmatch )
				lNameSearch+=' ('+lastnamefield +' = \''+ String.escapeSingleQuotes(lastname) + '\')';
			else 			
				lNameSearch+=' ('+lastnamefield +' like \''+ String.escapeSingleQuotes(lastname.replace('*','%'))+'\')'; 
			criteria += lNameSearch;
		}
		if (firstname!=null && firstname!='') {
			if (lastname!=null && lastname!='') {
				criteria+= ' and ';
			}
			if ( exactmatch )
				fNameSearch+=' ('+firstnamefield+' = \''+ String.escapeSingleQuotes(firstname)+'\')';
			else
				fNameSearch+=' ('+firstnamefield+' like \''+ String.escapeSingleQuotes(firstname.replace('*','%'))+'\')';
			criteria += fNameSearch;
		}
		criteria += ')';
		system.debug(criteria);
		return criteria;
	}

}