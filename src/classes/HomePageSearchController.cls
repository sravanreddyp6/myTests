public with sharing class HomePageSearchController{

	//declaring variables
	public String firstName{ get; set; }
	public String lastName{ get; set; }
	public transient List<SearchResult> searchResults = new List<SearchResult>();

	// constructor
	public HomePageSearchController() {
		firstName = ApexPages.currentPage().getParameters().get('FirstNM');
		lastName = ApexPages.currentPage().getParameters().get('LastNM');

	}

	//wrapper return method
	public List<SearchResult> getTotalList() {
		return getSearchResults(true, true, true);
	}

	public List<SearchResult> getSearchResults(Boolean searchPbs, Boolean searchPbr, Boolean searchTMNContact) {
		searchResults = new List<SearchResult>();
		String firstNames;
		String LastNames;
		String age;
		String state;
		String types;
		Id recordId;

		if (searchPbs) {
			String conQuery = 'select Id,Name,FirstName,LastName,Age_Text__c,Age__c,Age_year__c,Age_month__c,Age_days__c,Account.First_Name_SoundEx_Key__c,Account.Last_Name_SoundEx_Key__c,MailingState,(select Person_Being_Served__r.Name,Person_Being_Served__c,State__c from Episodes__r) from Contact where ' + buildCriteria(lastName, firstName, 'lastname', 'firstname');
			system.debug(conQuery);

			for(Contact cnt:database.Query(conQuery)) {
				firstNames = cnt.FirstName;
				LastNames = cnt.LastName;
				//age = Utility.getAge(String.valueOf(cnt.Age_year__c),cnt.Age_month__c,cnt.Age_days__c); 
				age = cnt.Age_Text__c;
				for(Admission__c adm:cnt.Episodes__r) {
					if( adm.State__c!=null) {
						// convert state code to name
						state = Utility.getStateNameFromCode( adm.State__c );
					} else {
						state = cnt.MailingState;
					}
				}

				types = 'Person Being Served';
				recordId = cnt.Id;

				searchResults.add(new SearchResult(firstNames, LastNames, age, state, types, recordId, cnt.AccountId));
			}
		}

		if (searchPbr) {
			String pbrQuery = 'select Id,Name,First_Name__c,Age_Text__c,Age_year__c,Age_month__c,Age_days__c,First_Name_SoundEx_Key__c,Last_Name__c,Last_Name_SoundEx_Key__c,Full_Name__c,Age__c,State__c,(select Name,State_for_Preferred_Service__c,Name_PBR__c,Person_Being_Referred__r.Name,Person_Being_Referred__c from Referrals__r) from Person_Being_Referred__c where ' +buildCriteria(lastName, firstName, 'last_name__c', 'first_name__c');
			system.debug(pbrQuery);

			for(Person_Being_Referred__c pbr:database.Query(pbrQuery)) {
				firstNames = pbr.First_Name__c;
				LastNames = pbr.Last_Name__c;
				age = pbr.Age_Text__c;   
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

		return searchResults;
	}

	public class SearchResult{
		public String firstName { get; set; }
		public String lastName { get; set; }
		public String Age { get; set; }
		public String State { get; set; }
		public String Type { get; set; }
		public Id recordId { get; set; }
		public String Names { get; set; }
		public Id accountId { get; set; }  // only applies to PBS

		public SearchResult(String firstName, String LastName, String age, String state, String types, Id recordId) {
			this(firstName, LastName, age, state, types, recordId, null);
		}
		public SearchResult(String firstName, String LastName, String age, String state, String types, Id recordId, Id accountId) {
			this.firstName = firstName;
			this.lastName = lastName;
			this.Age = age;
			this.State = state;
			this.Type = types;
			this.recordId = recordId;
			this.accountId = accountId;
		}
	}

	public static String buildCriteria(String lastname, String firstname, String lastnamefield, String firstnamefield) {
		String lNameSearch='', fNameSearch='', criteria='(';

		if (lastname!=null && lastname!='') {
			if (lastname.contains('*')) {
				lNameSearch+=' ('+lastnamefield +' like \''+
					String.escapeSingleQuotes(lastname.replace('*','%'))+'\')';
			} else {
				lNameSearch+=' ('+lastnamefield +' like \''+
					String.escapeSingleQuotes(lastname)+'%\''+
					' or last_name_soundex_key__c =\''+
					String.escapeSingleQuotes(SoundEx.ToSoundEx(lastname))+'\') ';
			}
			criteria += lNameSearch;
		}
		if (firstname!=null && firstname!='') {
			if (lastname!=null && lastname!='') {
				criteria+= ' and ';
			}
			if (firstname.contains('*')) {
				fNameSearch+=' ('+firstnamefield+' like \''+
					String.escapeSingleQuotes(firstname.replace('*','%'))+'\')';
			}else{
				fNameSearch+=' ('+firstnamefield+' like \''+
					String.escapeSingleQuotes(firstname)+'%\''+
					' or first_name_soundex_key__c =\''+
					String.escapeSingleQuotes(SoundEx.ToSoundEx(firstname))+'\')';
			}
			criteria += fNameSearch;
		}
		criteria += ')';
		system.debug(criteria);
		return criteria;
	}

}