@isTest
private class ChatRetentionTest2 {

    static testMethod void myUnitTest() {
    	
    	     	
     	   String ProfileId = [select ProfileId from User where (Department='Operations Systems') LIMIT 1].ProfileId;
     
           User usr = new User(USERNAME='Steve.Test@thementornetwork.com',
                               LASTNAME = 'Test',
                               FIRSTNAME = 'Steve',
                               EMAIL = 'Steve.Test@thementornetwork.com',
                               ALIAS = 'stest',
                               COMMUNITYNICKNAME = 'steve.test',
                               TIMEZONESIDKEY = 'America/New_York',
                               LOCALESIDKEY = 'en_US', 
                               EMAILENCODINGKEY = 'ISO-8859-1',
                               PROFILEID = ProfileId,
                               LANGUAGELOCALEKEY = 'en_US',                                
                               ISACTIVE = true,
                               legal_custodian__c=true);
                               
           insert usr;
                               
           List<User> testUsr = [Select Id from  user u WHERE Id = :usr.Id];        
           System.Debug('What is in testUsr: ' + testUsr);        
           Id uUserid = testUsr[0].Id;
           
           FeedItem fi = new FeedItem(PARENTID = uUserID,
                                      Body = 'Test Post by steve'
           
           );
           insert fi;          
           
           
           String ParentID = [select ParentID from Feeditem where (Type='TextPost') LIMIT 1].ParentID;
     
           
           FeedItem fi1 = new FeedItem(PARENTID = ParentID,
                                      Body = 'Test Post by steve2'
           
           );
           insert fi1;     
           
            string before = 'Testing base 64 encode';
 			Blob resBody =Blob.valueOf(before);     
 			FeedItem fi2 = new FeedItem(ParentID = ParentID, ContentData = resBody, ContentFileName='test file post');
			insert fi2;          
          
           
           
           
            List<FeedItem> testFeedItem = [Select Id From FeedItem I WHERE Id = :fi.Id];        
           //System.Debug('What is in testAcct: ' + testAcct);        
           Id iItemid = testFeedItem[0].Id;
           
           
           FeedComment fc = new FeedComment(FEEDITEMID = iItemid,
                                            COMMENTBODY = 'Test comment by steve',
                                            COMMENTTYPE = 'TextComment'
           );
           insert fc;
           
           FeedComment fc2 = new FeedComment(FEEDITEMID = iItemid,
                                            COMMENTBODY = 'Test comment by steve #save',
                                            COMMENTTYPE = 'TextComment'
           );
          
           insert fc2;
    	
    	   FeedComment fc3 = new FeedComment(FEEDITEMID = iItemid,
                                            COMMENTTYPE = 'ContentComment'
           );
          
           insert fc3;
    	
    	ChatterRetention myobj = new ChatterRetention('Select f.Type, f.CommentCount, f.Body, f.Title, f.Id, f.CreatedById, f.ParentId, f.LastModifiedDate, f.CreatedDate From FeedItem f');
        ID batchprocessid = Database.executeBatch(myobj, 200);
        
        
    }
}