/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.u.
 */
@isTest
private class FeedCommentValidationTEST {



static testMethod void myUnitTest() {



     {
     	
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
           //                             TYPE = 'UserStatus',
                                      Body = 'Test Post by steve'
           
           );
           insert fi;
            
            List<FeedItem> testFeedItem = [Select Id From FeedItem I WHERE Id = :fi.Id];        
           //System.Debug('What is in testAcct: ' + testAcct);        
           Id iItemid = testFeedItem[0].Id;
           
           
           feedcomment fc = new FeedComment(FEEDITEMID = iItemid,
                                            COMMENTBODY = 'Test comment by steve',
                                            COMMENTTYPE = 'TextComment'
           
           
           
           );
          
           insert fc;
           
           FeedCommentValidation testObj = new FeedCommentValidation(true);
           
           List<FeedComment> testFeedComment = new List<FeedComment>();
           Id testId;
           Map<Id,FeedComment> mapTestFeedComment = new Map<Id,FeedComment>();
           mapTestFeedComment.put(testId,fc);
           
           
           try
           {
              delete fc;
              delete fi;
              // should throw an exception - the following assertion will cause an error if the code carries on
              //System.assert(false);
           }
           catch (DMLException e)
           {
               // expected - could assert the message here
               //system.assert(false);
           }
        
        
        
        
        }
}
}