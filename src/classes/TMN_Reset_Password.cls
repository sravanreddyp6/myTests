Public class TMN_Reset_Password {
    public class doReset{
        public doReset(List<User> myUsers){            
            for (User thisUser: myUsers){
                if(thisUser.Reset_Password__c && thisUser.isActive){
                    System.resetPassword(thisUser.id, true);
                    thisUser.Reset_Password__c = false;                    
                }
            
            }            
        } 
    
    }
 static testMethod void testMyController()
   {      
       //TMN_Reset_Password  controller = new TMN_Reset_Password ();
		String ProfileId = [select ProfileId from User where (Profile.Name='System Administrator') LIMIT 1].ProfileId;

		User usr = new User(USERNAME='test@thementornetwork.com232323',
	           LASTNAME = 'TestLastName',
	           FIRSTNAME = 'TestFirstName',
	           EMAIL = 'test@thementornetwork.com232323',
	           ALIAS = 'ttest',
	           COMMUNITYNICKNAME = 'test.test',
	           TIMEZONESIDKEY = 'America/New_York',
	           LOCALESIDKEY = 'en_US', 
	           EMAILENCODINGKEY = 'ISO-8859-1',
	           PROFILEID = ProfileId,
	           LANGUAGELOCALEKEY = 'en_US',                                
	           ISACTIVE = true,
	           legal_custodian__c=true);    
        
		insert usr;
		
       usr.Reset_Password__c = true;
       usr.isActive = true;
       
       update usr;
           
   }
}