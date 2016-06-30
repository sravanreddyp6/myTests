@isTest
private class tmn_manage_groups_Test{
static testMethod void myUnitTest() {
    Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
       User testUser = new User(
            Alias = 'standt', 
            Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', 
            LastName='Testing', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='standarduser@testorg.com.tmn'
        );

        insert testUser ;
        
      Group myg = new group(Name = 'test', Developername = 'test');
      insert myg  ;
     List<id> temp = new list<id>();    
         
    
     PageReference pageRef = Page.tmn_manage_groups;
     Test.setCurrentPageReference(pageRef);
    System.currentPageReference().getParameters().put('id', testUser.Id);
    

    ApexPages.StandardController sc = new ApexPages.standardController(testUser)  ;  
    tmn_manage_groups cls = new tmn_manage_groups(sc);                
  /*  GroupMember gm = new GroupMember( );
    gm.groupid = myg.id;
    gm.userorgroupid =  testUser.id; 
    insert GM; 
    */
    temp.add(myg.id);        
     
    cls.SelectGroups = temp;    
    cls.AddtoGroups();    
    cls.DeleteFromGroups();
    
    
    temp = cls.SelectGroups;
    List<SelectOption> selOpts= cls.CurrentGroups;
    List<SelectOption> selOpts2= cls.AvailableGroups ;
    }
}