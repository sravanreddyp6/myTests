@isTest
private class OneAppSearchControllerTest {

 public static Id getAccountRecordType(){
    List<RecordType> RecTypes= [SELECT Id, Name from recordtype where SobjectType = 'Account' and IsPersonType = true and IsActive = true and Name = 'Person Being Served'];
    return RecTypes[0].id;
  }
  
  
  
    
     static User user1(){
    Profile profile = [SELECT Id FROM Profile WHERE Name='ESD General' LIMIT 1 ];
     User testUser1 = new User(
            Alias = 'standt33', 
            Email='standarduser@testorg.com3333333333333333', 
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
  
  static testMethod void searchTest() {
  	        Test.startTest();
  
  
  		TMN_Generic_Core_TestData theTest = new TMN_Generic_Core_TestData();
  		theTest.theAccount.FirstName = 'John';
  		theTest.theAccount.LastName = 'Smithson';
        update theTest.theAccount;
        Account a = [ select id, personcontactid from account where id = :theTest.theAccount.id LIMIT 1];
        
        system.debug( theTest.theAccount);	
        OneAppSearchController con = new OneAppSearchController();
        con.firstName = 'John%';
        con.lastName = 'Smith%';
        
        system.assertequals( (con.getSearchResults(true, false, false, true)).size(), 1);
		
		// set up exclusion list
		con.excludePBSList = new LIst<ID>();
		con.excludePBSList.add( a.PersoncontactId);
		system.assertequals( (con.getSearchResults(true, false, false, true)).size(), 0);
		con.excludePBSList = null;
		
		con.excludeSAList = new List<ID>();
		con.excludeSAList.Add( theTest.theSA.id);
		system.assertequals( (con.getSearchResults(true, false, false, true)).size(), 0);
        
        Test.stopTest();
    }
    
}