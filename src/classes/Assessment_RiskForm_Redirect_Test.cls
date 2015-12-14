@isTest
private class Assessment_RiskForm_Redirect_Test {    
    
    static testMethod void myUnitTest() {
        TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();        
        
        System.assertNotEquals(null, myData);
            
        Assessment__c assessment;    
        List<String> assessmentList = new List<String>{'CANS','Risk','FAD Summary', 'ISSA'}; 
        PageReference myPage; 
         
        for(String item: assessmentList) {             
                
            if (item == 'CANS') {         
                assessment = TMN_Generic_Core_TestData.createAssessment(myData.theAdm, myData.theSA, 'CANS', null, null, false);                                                                                             
                Assessment_RiskForm_Redirect redirectObj = new Assessment_RiskForm_Redirect(new ApexPages.StandardController(assessment));
                myPage = redirectObj.assessmentRedirect(); 
            } 
            
            if (item == 'Risk') {         
                assessment = TMN_Generic_Core_TestData.createAssessment(myData.theAdm, myData.theSA, 'Risk', null, null, false);                                                                              
                Assessment_RiskForm_Redirect redirectObj = new Assessment_RiskForm_Redirect(new ApexPages.StandardController(assessment)); 
                myPage = redirectObj.assessmentRedirect(); 
            }           
                        
            if (item == 'FAD Summary') {            	
                assessment = TMN_Generic_Core_TestData.createAssessment(myData.theAdm, myData.theSA, 'FAD Summary', null, null, false);                                                                              
                Assessment_RiskForm_Redirect redirectObj = new Assessment_RiskForm_Redirect(new ApexPages.StandardController(assessment)); 
                myPage = redirectObj.assessmentRedirect(); 
            }
            
    	    if (item == 'ISSA') {
    	        assessment = TMN_Generic_Core_TestData.createAssessment(myData.theAdm, myData.theSA, 'ISSA', null, null, false);                                                                              
                Assessment_RiskForm_Redirect redirectObj = new Assessment_RiskForm_Redirect(new ApexPages.StandardController(assessment)); 
                myPage = redirectObj.assessmentRedirect(); 
    	    }    
    	    
    	    Test.setCurrentPage(myPage);    
        }      
                
    }
}