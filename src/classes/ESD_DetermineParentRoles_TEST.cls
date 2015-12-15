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
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ESD_DetermineParentRoles_TEST {

    static testMethod void myUnitTest() {
        
        Id profileID;
        List<Profile> profileList = [SELECT Id FROM Profile LIMIT 1];       
        
        for(Profile p : profileList){
            profileId = p.Id;
        }
        
        Id roleID;
        id parentRoleID;
        List<UserRole> roleList = [SELECT Id, ParentRoleId FROM UserRole WHERE ParentRoleId != NULL];
        
        for(UserRole ur : roleList){
            roleID = ur.Id;
            parentRoleID = ur.ParentRoleId;
        } 
        
        User myUser = new User(
            Username = 'test@thementornetwork.com2222222',
            LastName = 'test',
            Email = 'test@thementornetwork.com2222222',
            Alias = 'ttest',
            CommunityNickname = 'test.test',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = profileId,
            LanguageLocaleKey = 'en_US',
            UserRoleId = roleID
        );
        insert myUser;
        
        ESD_DetermineParentRoles myObj = new ESD_DetermineParentRoles(myUser.Id);
        
        Boolean parentRolePresent = false;
        
        for(Id thisParentId : myObj.allParents){
            if(thisParentId == parentRoleID){
                parentRolePresent = true;   
            }
        }
        
        System.assertEquals(parentRolePresent,true);
    }
}