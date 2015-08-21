@isTest
private class HomePageTileControllerTest {
    static testMethod void userTestCase() {
        TMN_User__c tmn  = new TMN_User__c(Operating_Group__c = '', Salesforce_User_Account__c= UserInfo.getUserId() );    
        insert tmn; 
        
        HomePageTileController homeObj = new HomePageTileController();
        Map<string,string> pbsvMap = new Map<string, string>();
        pbsvMap.put('all','test');
        homeObj.personsBeingServedViews = pbsvMap;
        Map<String, String> pbsv = homeObj.personsBeingServedViews;
        
        Map<string,string> refMap = new Map<string, string>();
        refMap.put('all','test');
        homeObj.ReferralViews = refMap;
        Map<String, String> refViews = homeObj.ReferralViews;
        
        Map<string,string> docMap = new Map<string, string>();
        docMap.put('all','test');
        homeObj.DocViews = docMap;
        Map<String, String> docViews = homeObj.DocViews;
        
        Map<string,string> tmnMap = new Map<string, string>();
        tmnMap.put('all','test');
        homeObj.TMNViews = tmnMap;
        Map<String, String> tmnViews = homeObj.TMNViews;
        
    }
    static testMethod void cambridgeUser() {
        TMN_User__c tmnCB  = new TMN_User__c(Operating_Group__c = 'Cambridge', Salesforce_User_Account__c= UserInfo.getUserId() );    
        insert tmnCB;
        HomePageTileController homeObj = new HomePageTileController();    
    }
    static testMethod void careUser() {
        TMN_User__c tmnCM  = new TMN_User__c(Operating_Group__c = 'CareMeridian', Salesforce_User_Account__c= UserInfo.getUserId() );    
        insert tmnCM; 
        HomePageTileController homeObj = new HomePageTileController();
    }
    static testMethod void RedWoodUser() {
        TMN_User__c tmnRW  = new TMN_User__c(Operating_Group__c = 'Redwood', Salesforce_User_Account__c= UserInfo.getUserId() );    
        insert tmnRW;
        
        HomePageTileController homeObj = new HomePageTileController();
        Map<String, String> pbsv = homeObj.personsBeingServedViews;
        String refPref = homeObj.referralPrefix;    
        Map<String, String> refViews = homeObj.ReferralViews;
        Map<String, String> docViews = homeObj.DocViews;  
        Map<String, String> tmnViews = homeObj.TMNViews;   
        String objName = homeObj.objectName;
        
    }
    
}