public class ReferralSearchResults implements Comparable {
  public string Name {get;set;}
  public string FirstName {get;set;}
  public string LastName {get;set;}
  public date DateofBirth {get;set;}
  public string Gender {get;set;}
  public string Street1 {get;set;}
  public string Street2 {get;set;}
  public string City {get;set;}
  public string State {get;set;}
  public string ZipCode {get;set;}
  public Id id {get;set;}
  public string Type {get;set;}
  public Integer MatchedItems {get;set;}
  public Double Age {get;set;}
  public Id pbsonPBR {get;set;}
  public List<Referral__c> Referrals {
    get {
    	if (Referrals == null && (Type == 'Person Being Referred' || Type == 'Person Being Served')) {loadReferrals();}
    	return Referrals;
    }
  	set;
  }
     
  public ReferralSearchResults(Person_Being_Referred__c pbr, Integer matchedNum) {
      this.Name = pbr.Name;
      this.FirstName = pbr.First_Name__c;
      this.LastName = pbr.Last_Name__c;
      this.DateofBirth = pbr.Date_of_Birth__c;
      this.Gender = pbr.Gender__c;
      this.Street1 = pbr.Street_1__c;
      this.Street2 = pbr.Street_2__c;
      this.City = pbr.City__c;
      this.State = pbr.State__c;
      this.ZipCode = pbr.Zip_Code__c;
      this.id = pbr.Id;
      this.Type = 'Person Being Referred';
      this.matchedItems = matchedNum;
      this.age = pbr.Age__c;
      this.pbsonPBR = pbr.Person_Being_Served__c;
  }
  
  public ReferralSearchResults(Contact pbs, Integer matchedNum) {
      this.Name = pbs.Name;
      this.FirstName = pbs.FirstName;
      this.LastName = pbs.LastName;
      this.DateofBirth = pbs.BirthDate;
      this.Gender = pbs.Gender__c;
      this.Street1 = pbs.MailingStreet;
      this.City = pbs.MailingCity;
      this.State = pbs.MailingStateCode;
      this.ZipCode = pbs.MailingPostalCode;
      this.id = pbs.Id;
      this.Type = 'Person Being Served';
      this.matchedItems = matchedNum;
      this.age = pbs.Age__c;
  }
  
  // Implement the compareTo() method
    public Integer compareTo(Object compareTo) {
        ReferralSearchResults compareToEmp = (ReferralSearchResults)compareTo;
        if (MatchedItems == compareToEmp.MatchedItems) {
        	if (LastName == compareToEmp.LastName){
        		if (FirstName == compareToEmp.FirstName) return 0;
        		if (FirstName > compareToEmp.FirstName) return 1;
        	}
        	if (LastName > compareToEmp.LastName) return 1;
        }
 	    if (MatchedItems < compareToEmp.MatchedItems) return 1;
        
        return -1;        
    }
    
    private void loadReferrals() {
    	if (Type == 'Person Being Referred') {
    		Referrals = Database.query('select id,Name from Referral__c where Person_Being_Referred__c = :id');
    	}
    	if (Type == 'Person Being Served' ) {
    		Referrals = Database.query('select id,Name from Referral__c where Person_Being_Served__c = :id');
    	}
    }
}