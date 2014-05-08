@isTest
public class SearchLogicOnPBSRTest{
    static testmethod  void testing(){
        Referral_CreateTestData.createPersonBeingReferred(25, null);
        
        test.startTest();
        //Person being Referred tests
        try{
            List<ReferralSearchResults> searchResults = SearchLogicOnPBSR.search('','','',null,null,null);
        } catch(Exception e){
            System.assert(e.getMessage() == 'Both last and first name cannot be null');         
        }
        
        List<ReferralSearchResults> searchResults = SearchLogicOnPBSR.search('','','Doug',null,null,null);
        System.assert(searchResults.size() == 1);
        
        searchResults = SearchLogicOnPBSR.search('','','Do',null,null,null);
        System.assert(searchResults.size() == 1);
        
        //testing Soundex - in soundex Dog and Doug match
        searchResults = SearchLogicOnPBSR.search('','','Dog',null,null,null);
        System.assert(searchResults.size() == 1);
        
        searchResults = SearchLogicOnPBSR.search('','Surfleet','Doug',null,null,null);
        System.assert(searchResults.size() == 1);
        
        searchResults = SearchLogicOnPBSR.search('','Surfleet','',null,null,null);
        System.assert(searchResults.size() == 1);
        
        searchResults = SearchLogicOnPBSR.search('','Sur','',null,null,null);
        System.assert(searchResults.size() == 1);
        
        searchResults = SearchLogicOnPBSR.search('','','Doug',null,25,null);
        System.assert(searchResults.size() == 1);
        
        searchResults = SearchLogicOnPBSR.search('','','Doug',null,30,null);
        System.assert(searchResults.size() == 0);
        
        searchResults = SearchLogicOnPBSR.search('','Surfleet','Doug',null,30,null);
        System.assert(searchResults.size() == 1);
        
        searchResults = SearchLogicOnPBSR.search('','','Doug',null,0,'Male');
        System.assert(searchResults.size() == 1);
        
        searchResults = SearchLogicOnPBSR.search('','','Doug',null,0,'Female');
        System.assert(searchResults.size() == 0);
        
        searchResults = SearchLogicOnPBSR.search('','Surfleet','Doug',null,30,'Female');
        System.assert(searchResults.size() == 1);
        
        searchResults = SearchLogicOnPBSR.search('','','Mark',null,null,null);
        System.assert(searchResults.size() == 0);
        
        searchResults = SearchLogicOnPBSR.search('','','*g',null,null,null);
        System.assert(searchResults.size() == 1);
        
        searchResults = SearchLogicOnPBSR.search('','*t','',null,null,null);
        System.assert(searchResults.size() == 1);
        
        Referral_CreateTestData.createPersonBeingReferred(null, Date.today().addYears(-18));
  
        searchResults = SearchLogicOnPBSR.search('','','Doug',Date.today().addYears(-18),null,null);
        System.assert(searchResults.size() == 1);
        
        searchResults = SearchLogicOnPBSR.search('','Surfleet','Doug',Date.today().addYears(-25),null,null);
        System.assert(searchResults.size() == 2);
        
        searchResults = SearchLogicOnPBSR.search('','','Doug',Date.today().addYears(-25),null,null);
        System.assert(searchResults.size() == 0);
        
        //now test against Person Being Served
         Referral_CreateTestData.getAccount();
        searchResults = SearchLogicOnPBSR.search('','','test',null,null,null);
        System.assert(searchResults.size() == 1);
        
        searchResults = SearchLogicOnPBSR.search('','test','test',null,null,null);
        System.assert(searchResults.size() == 1);
        
        searchResults = SearchLogicOnPBSR.search('','test','',null,null,null);
        System.assert(searchResults.size() == 1);
        
        searchResults = SearchLogicOnPBSR.search('','','Mark',null,null,null);
        System.assert(searchResults.size() == 0);
        
        searchResults = SearchLogicOnPBSR.search('','','test',date.newinstance(1960, 2, 17),null,null);
        System.assert(searchResults.size() == 1);
        
        searchResults = SearchLogicOnPBSR.search('','test','test',Date.today().addYears(-25),null,null);
        System.assert(searchResults.size() == 1);
        
        searchResults = SearchLogicOnPBSR.search('','','test',Date.today().addYears(-25),null,null);
        System.assert(searchResults.size() == 0);
        
        //making sure both are returned.
        searchResults = SearchLogicOnPBSR.search('','*t*','',null,null,null);
        System.assert(searchResults.size() == 3);
        
        test.stopTest(); 
    }
    
    static testmethod  void ReferralNumberTest(){
        Person_Being_Referred__c pbr = Referral_CreateTestData.createPersonBeingReferred(25, null);
        Referral__c ref = Referral_CreateTestData.createReferral('California', 'New', 'Test123', 'California', pbr);
		
        List<ReferralSearchResults> searchResults = SearchLogicOnPBSR.search(ref.Name,'','',Date.today(),null,null);
        System.assert(searchResults.size() == 1);
        
        ReferralSearchResults result = searchResults[0];
        List<Referral__c> referrals = result.Referrals;
        system.assert(referrals.size() == 1);
        Referral__c referralResult = referrals[0];
        system.assert(referralResult.Id == ref.Id);
    }
}