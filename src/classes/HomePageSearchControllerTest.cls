@isTest(seeAllData=true)
private class HomePageSearchControllerTest {
    public static Id getAccountRecordType(){
    List<RecordType> RecTypes= [SELECT Id, Name from recordtype where SobjectType = 'Account' and IsPersonType = true and IsActive = true and Name = 'Person Being Served'];
    return RecTypes[0].id;
  }
  public static Account newAccount(String Fname,String Lname){
    Date myDate = date.newinstance(1960, 2, 17);
    Account Accnt = new Account(
            RecordTypeID=getAccountRecordType(),
            FirstName= Fname,
            LastName= Lname,
            PersonMailingStreet= EncodingUtil.convertToHex(crypto.generateAesKey(128)).substring(1,5).toUpperCase() + '_test@yahoo.com',
            PersonBirthdate = myDate,
            PersonMailingPostalCode='12345',
            PersonMailingCity='SFO',
            PersonMailingStateCode='NC',
            PersonEmail=EncodingUtil.convertToHex(crypto.generateAesKey(128)).substring(1,5).toUpperCase() + '_test@yahoo.com',
            PersonHomePhone='1234567',
            PersonMobilePhone='12345678'
           // BillingState = 'MA'
        );
        insert Accnt;
        List<Account> testAcct = [Select Id, PersonContactId, RecordTypeID From Account a WHERE a.Id = :Accnt.Id];
        return testAcct[0];
  }
  public static Person_Being_Referred__c createPersonBeingReferred(String FirstName, String LastName, double age, Date dob) {
        Person_Being_Referred__c pbr = new Person_Being_Referred__c();
        pbr.First_Name__c = FirstName;
        pbr.Last_Name__c = LastName;
        if (age != null && age > 0) {
            pbr.Age__c = age;
        }
        if (dob != null) {
            pbr.Date_of_Birth__c = dob;
        }
        pbr.Gender__c = 'Male';
        pbr.State__c = 'MA';
        insert pbr;
        Person_Being_Referred__c testPBR = [Select Id,Name,Full_Name__c,State__c,First_Name__c, Last_Name__c, Age__c, Date_of_Birth__c From Person_Being_Referred__c a WHERE a.Id = :pbr.Id];
        return testPBR;
    }
  public static User user1(){
  	Profile profile = [SELECT Id FROM Profile WHERE Name='ESD General' LIMIT 1 ];
  	 User testUser1 = new User(
          	Alias = 'standt', 
          	Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', 
            LastName='Testing', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = profile.Id, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='alpha@testorg.com'
		);
	insert testuser1;
	return testuser1;	
  }
  public static TMN_Contact__c TMNContact(String Fname,String LName){
  	
  	TMN_Contact__c tmnaccnt = new TMN_Contact__c(
  								RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType='TMN_Contact__c' limit 1].Id,
								OwnerId = user1().Id,
								First_Name__c = Fname,
								Last_Name__c = LName,
								Related_Party_Type__c = 'Co-Applicant',
								Email__c = 'test@testuser.com',
								Date_of_Birth__c = date.newinstance(1990, 2, 17)
					);
    insert tmnaccnt;
  	List<TMN_Contact__c> testtmn = [select Id,Name,First_Name__c,Last_Name__c,Full_Name__c,Age__c,State__c from TMN_Contact__c];
  	return testtmn[0];
  }
  public static Contact newContact(String Fname,String Lname){
  	Contact cnt = new Contact(
  	                      FirstName = Fname,
  	                      LastName = Lname,
  	                      
  	                      Birthdate = date.newinstance(1990, 2, 17)
  	                    );
  	insert cnt;
  	List<Contact> testcnt = [select Id,Name,FirstName,LastName,Age__c from Contact limit 1];
  	return testcnt[0];
  }
  
  public static Admission__c newAdmission(Contact cnt1) {
        Admission__c adm = new Admission__c(
                           State__c = 'ME',
                           Name = 'TEST ADM',
			               Person_Being_Served__c = cnt1.Id,
			               Effective_Date__c = date.today(),
			               Network_Offering__c = 'ARY'
        );
        insert adm;
        
        List<Admission__c> adm1 = [SELECT ID,State__C FROM Admission__c LIMIT 1];
        return adm1[0];
    }
    static testMethod void myUnitTest() {
    	
        
    	Test.startTest();
        HomePageSearchController con = new HomePageSearchController();
        con.FirstNM = 'TestFirst';
        con.LastNM = 'TestLast';
        User testUser = Referral_CreateTestData.createTestUser('testU','ReferralTestUser@tmn.com.test','Test','Test','Redwood');
        Person_Being_Referred__c pbr = createPersonBeingReferred(con.FirstNM,con.LastNM,25, null);
        Referral__c ref = Referral_CreateTestData.createReferral('Generic', 'New', 'Test123', pbr);
        TMN_Contact__c tmn = TMNContact(con.FirstNM,con.LastNM);
        Account acnt = newAccount(con.FirstNM,con.LastNM);
        Contact cnt1 = newContact(con.FirstNM,con.LastNM);
        String adm3 = newAdmission(cnt1).State__c;
        con.getTotalList();
        Test.stopTest();
    }
}