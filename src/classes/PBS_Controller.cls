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
        'The person being served is younger than 18 years old.  Please enter the name of a guardian.' ));
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
  			} else {
  				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
        	'An error occurred saving this record. ' + e.getMessage()));
  				
  			}
  			
			return null;
    	}
	} 

}
}