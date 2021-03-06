public with sharing class PBS_Controller {

  public Account personBeingServed { get; set; }
  public Id relatedPartyId;
  public Related_Party__c relParty { get; set; }
  public List<Related_Party__c> relParties { get; set; }
  public ApexPages.StandardController stdController;
  public string fname { get { return this.personbeingserved.FirstName; } set { system.debug('setting fname=' + value); this.personbeingserved.FirstName = value; } }
  public string lname { get { return this.personbeingserved.LastName; } set { this.personbeingserved.LastName = value;} }
  public Boolean isUserLevel1or2 { get { return PBS_controller_helper.isUserLevel1or2();} set; }
 

  private Id personBeingServedId {get; set;}
  public Id pBSId { get; set; }
  public boolean isEditor{get; set;}
public Boolean showDiagnosis { get {
        if (TMNUser == null) {
            return false;
        }

        return TMNUser.Operating_Group__c=='Redwood'
        	|| TMNUser.Operating_Group__c=='Cambridge';
    }}	

public boolean canViewFamilyInfo { 
	get {
		return TMNUser == null ? false : TMNUser.Operating_Group__c == 'Cambridge';
	}}

// Filter some of the Additional Info Fields
public string dontShowFields {
	get {
		system.debug('OpGroup:' + TMNUser.Operating_Group__c);
		List<string> dontshow = new List<string>();
		if (TMNUser == null || TMNUser.Operating_Group__c != 'Cambridge'){
			dontshow.Add('Current_Medications__pc');
		}
        if ( (TMNUser.Operating_Group__c.indexOf('Care') < 0) && (TMNUser.Operating_Group__c.indexOf('Meridian') < 0) ) {
            dontshow.Add('Advanced_Directives__pc');
            dontshow.Add('Code_Status__pc');
            dontshow.Add('Code_Status_Other__pc');
        }
		return ' ' + String.Join(dontshow, ',');
	}
}

private TMN_User__c TMNUser_internal;
private boolean TMNUser_set = false;
//Using @TestVisible annotation will allow us to access the private members of the class in the test class - Sravan: 07/15/2014 1:03PM.
@TestVisible private TMN_User__c TMNUser {
	get {
		if (!TMNUser_set) {
			TMN_User__c[] users = [
            	SELECT ID, Operating_Group__c FROM TMN_User__c WHERE Salesforce_User_Account__c= :UserInfo.getUserId() LIMIT 1
        	];
        	if (users.size() == 0) {
        		TMNUser_internal = null;
        	} else {
        		TMNUser_internal = users[0];
        	}
        	TMNUser_set = true;
		}
		return TMNUser_internal;
	}}
  	
  public PBS_Controller(ApexPages.standardController ctl){
    	system.debug('in constructor');

		this.stdController = ctl;	
		
	    ID pbsaccount = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName ='Person_Being_Served' limit 1].Id;
		this.personbeingserved = (Account) ctl.getRecord();
    
        this.personbeingserved.recordtypeId = pbsaccount;
	    this.relParty = new Related_Party__c( type__c='Guardian');
	    
		
  }
  
public pageReference savePBS() {

	// if a guardian is entered, cheat an add it to the guardian1 fields
	if ( !String.isEmpty( relParty.Name)) {
		this.personbeingserved.guardian1_name__pc = relParty.Name;
		this.personbeingserved.guardian_phone_number__pc = relParty.Phone__c;
		this.personbeingserved.guardian_1_e_mail__pc = relparty.email__c;
	}  

	// insert the new account record, and check for its validity
	decimal age = math.FLOOR(this.personbeingserved.personbirthdate.daysBetween(system.today())/365.2425);
	system.debug( 'age is: ' + string.valueOf(age));	
	if ( (age < 18.0 ) && ( this.personbeingserved.guardian1_name__pc == '' || this.personbeingserved.guardian1_name__pc == null)) {
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
        'The person being served is younger than 18 years old. Please add Guardian\'s information in the last section at the bottom of this page.' ));
        return null;
	} else 	{
		try {
			insert this.personBeingServed;
			
			this.personBeingServed = [ select id, personcontactid from account where id = :this.personbeingserved.Id];
			system.debug(' new id is ' + this.personbeingserved.id + ', personaccount=' + personbeingserved.personcontactid);
			
			// now insert the related party
			relParty.Person_Being_Served__c = this.personBeingServed.personContactId;
			
			if ( !string.isEmpty( relParty.Name) ) 
				insert relParty;
			
			return new PageReference( '/' + this.personbeingserved.personContactId  );
     
  		} catch (Exception e) {
  			
  			if ( e.getMessage().Contains('DUPLICATE_VALUE')) {
  				
  				try {
				// look up the duplicate
				Contact cDup = [select id, owner.name from Contact where firstname = :this.personBeingServed.firstName and 
																		 lastname = :this.personBeingServed.lastName and
																		 birthdate = :this.personBeingServed.PersonBirthDate limit 1];
				
					if (cDup != null) {
						personbeingserved.AddError('This Person Being Served already exists, and is owned by ' + cDup.Owner.Name);
					} else {
		     		 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
		        	'An error occurred saving this record. ' + e.getMessage()));
					}
  				} catch (Exception e2) {
  					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You have attempted to create a Person Being Served that already exists in the database but is currently saved outside of your account Role. Contact the IT Service Desk (1-888-774-4872) for assistance with this issue.'));
  				}
  			} else if (e.getMessage().Contains('The Other ID and Other ID Description fields')) {
  			     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
	        	    'The Other ID and Other ID Description fields must be filled in for a person being served with a Mailing State of North Carolina.'));  			 
  			} else if (e.getMessage().Contains('Gender Identity')) {
  			     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
	        	    'Gender Identity is required when the person identifies with a gender other than the legal gender'));  			 
  			}
  				 
  			else {
  				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
        	'An error occurred saving this record. ' + e.getMessage()));
  				
  			}
  			
			return null;
    	}
	} 

}
}