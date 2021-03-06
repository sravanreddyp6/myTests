public with sharing class Referral_byStatus_rpt {
	public string Results {get; set;}
	public string status {get; set;}
	public date StartDate {get; set;}
	public date EndDate { get; set;}
	public list<Referral__c> Referral_results {get; set;}
	public Referral_byStatus_rpt (){
		Referral_results = new list<Referral__c>();
		status = 'New';
	}

	public pageReference run(){
		Referral_results = [
			SELECT id, name,  Name_PBR__c, Street_1__c , Street_2__c,  city__c,
			       Person_Being_Referred__r.age__c, Person_Being_Referred__r.Age_year__c,
			       Person_Being_Referred__r.Age_month__c, Person_Being_Referred__r.Age_days__c,
			       Person_Being_Referred__r.Age_text__c, Person_Being_Referred__r.Gender__c,
			       Mobility__c, Referral_Date__c, Service_Location__r.name,
			       Service_Location_Program__c, Referral_Status__c , Referral_Name__c ,
			       Referral_Phone_Number__c , Referral_Source_Type__c, Person_Being_Referred__c,
			       Person_Being_Referred__r.Home_County__c, Case_Manager_Name__c ,
			       Case_Manager_Phone__c , Services_Requested__c, Assigned_Users__c
			  FROM referral__c
			 WHERE createdDate > :StartDate AND createdDate < :EndDate
			   AND Referral_Status__c = :Status
		];

		for (Referral__c ref:Referral_results) {
			if (ref.Person_Being_Referred__c != null) {
				ref.Person_Being_Referred__r.Age_month__c  = ref.Person_Being_Referred__r.Age_text__c;
			}
		}


		return null;
	}
}