public with sharing class OneAppSearchController {

	//declaring variables
	public String firstName{ get; set; }
	public String lastName{ get; set; }
	public List<String> excludeSAList { get; set; } // list of SAs to excluded from search
	public List<String> excludePBSList { get; set; } // list of PBS to exclude from search
	
	public transient List<SearchResult> searchResults = new List<SearchResult>();

	// constructor
	public OneAppSearchController() {
		firstName = ApexPages.currentPage().getParameters().get('FirstNM');
		lastName = ApexPages.currentPage().getParameters().get('LastNM');

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

		if (searchPbs) {
			
			
			if ( activeOnly ) {
				
				string activeQuery = 'SELECT Id, service_assignment__r.person_being_served__r.firstname, service_assignment__r.person_being_served__r.lastname,' +  
					' service_assignment__r.person_being_served__r.age__c, service_assignment__r.Person_Being_Served__c, service_assignment__r.admission__r.state__c, service_assignment__r.admission__c, ' + 
					' service_assignment__c, service_assignment__r.Service_Location__r.location_nickname__c, ' + 
			       ' service_assignment__r.Service_Location__r.Alias__c,' + 
			       ' effective_date__c,' + 
			       ' Status__c ' +
			  ' FROM Action_Plan__c ' +
			 ' WHERE ' +  
			 		' service_assignment__r.status__c = \'Active\' ' + 
			 ' and	status__c = \'Active Final\' ' + 
			 ' and ' +   buildCriteria(lastName, firstName, 'service_assignment__r.person_Being_served__r.lastname', 'service_assignment__r.person_Being_served__r.firstname', false);
			 
			 // if there are service assignments to exclude, those take precedence over PBS
			 if ( excludeSAList != null )
			 	activeQuery += ' and service_assignment__c not in :excludeSAList';
			 
			 // no SAs to exclude so just exclude all of the PBS 
			 if ( excludeSAList == null && excludePBSList != null )
			 	activeQuery += ' and service_assignment__r.person_being_served__c not in :excludePBSList'; 
			 
			 system.debug(activeQuery);
			 for ( Action_plan__c ap : database.Query(activeQuery)) {
			 	searchResults.add( new SearchResult( ap.service_assignment__r.person_Being_served__r.firstname, ap.service_assignment__r.person_Being_served__r.lastname,
			 						string.valueof(ap.service_assignment__r.person_being_served__r.age__c), ap.service_assignment__r.admission__r.state__c, 'Person Being Served',
			 						ap.service_assignment__r.person_being_served__c, ap.service_assignment__r.admission__c, ap.service_assignment__c, ap.Id, ap.service_assignment__r.service_location__r.alias__c,
			 						ap.service_assignment__r.service_location__r.location_nickname__c ));
			 }
				
			} else {
				
				String conQuery = 'select Id, Name, FirstName, LastName, MailingStateCode, Age__c from Contact where ' + buildCriteria(lastName, firstName, 'lastname', 'firstname', false);
				
				for(Contact cnt:database.Query(conQuery)) {
					
					firstNames = cnt.FirstName;
					LastNames = cnt.LastName;
					age = String.valueof(cnt.Age__c);
					state = cnt.MailingStateCode;
					types = 'Person Being Served';
					personId = cnt.Id;
					searchResults.add(new SearchResult(firstNames, LastNames, age, state, types, personId));
					
				}
			}

		}
/*
		if (searchPbr) {
			String pbrQuery = 'select Id,Name,First_Name__c,First_Name_SoundEx_Key__c,Last_Name__c,Last_Name_SoundEx_Key__c,Full_Name__c,Age__c,State__c,(select Name,State_for_Preferred_Service__c,Name_PBR__c,Person_Being_Referred__r.Name,Person_Being_Referred__c from Referrals__r) from Person_Being_Referred__c where ' +buildCriteria(lastName, firstName, 'last_name__c', 'first_name__c');
			system.debug(pbrQuery);

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

				searchResults.add(new SearchResult(firstNames,LastNames,age,state,types,recordId));
			}
		}

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
		

		public SearchResult(String firstName, String LastName, String age, String state, String types, Id recordId) {
			this(firstName, LastName, age, state, types, recordId, null, null, null, null, null);
		}
		public SearchResult(String firstName, String LastName, String age, String state, String types, Id recordId, ID adm, ID sa, ID ap, string al, string pgm) {
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