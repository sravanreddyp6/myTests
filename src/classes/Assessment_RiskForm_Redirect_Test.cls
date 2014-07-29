
@isTest
public class Assessment_RiskForm_Redirect_Test {    
    
    static testMethod void myUnitTest() {
        TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();        
        
        System.assertNotEquals(null, myData);
            
        Assessment__c assessment;    
        List<String> assessmentList = new List<String>{'CANS','Risk','FAD Summary', 'ISSA'}; 
        PageReference myPage; 
         
        for(String item: assessmentList) {             
                
            if (item == 'CANS') {         
                assessment = TMN_Generic_Core_TestData.createAssessment(myData.theAdm, myData.theSA, 'CANS', 'Inactive Draft', 'Locked', false);                
                myPage = new PageReference('/apex/Assessment_RiskForm_Redirect?id=' + assessment.id);
                //System.assertEquals(myPage, myPage.getURL());
            } 
            
            if (item == 'Risk') {         
                assessment = TMN_Generic_Core_TestData.createAssessment(myData.theAdm, myData.theSA, 'Risk', 'Inactive Draft', 'Locked', false);
                myPage = new PageReference('/apex/Assessment_RiskForm_Redirect?id=' + assessment.id);
            }           
                        
            if (item == 'FAD Summary') {            	
                assessment = TMN_Generic_Core_TestData.createAssessment(myData.theAdm, myData.theSA, 'FAD Summary', 'Inactive Draft', 'Locked', false);
                myPage = new PageReference('/apex/Assessment_RiskForm_Redirect?id=' + assessment.id);
            }
            
    	    if (item == 'ISSA') {
    	        assessment = TMN_Generic_Core_TestData.createAssessment(myData.theAdm, myData.theSA, 'ISSA', 'Inactive Draft', 'Locked', false);
    	        myPage = new PageReference('/apex/Assessment_RiskForm_Redirect?id=' + assessment.id); 
    	    }    
    	    
    	    Test.setCurrentPageReference(myPage);    
        }      
                
    }
}