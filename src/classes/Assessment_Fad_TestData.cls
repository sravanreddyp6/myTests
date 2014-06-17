public class Assessment_Fad_TestData {
    
    
    public static List<Assessment_Question__c> Questions = new List<Assessment_Question__c>();
    public List<Assessment_Question__c> getQuestions(){return Questions;}
    
    public static String[] questionDevName = new List<String>{'CG_Could_Not_complete','CG_Could_Not_complete_reason','PBS_Could_Not_complete','PBS_Could_Not_complete_reason',
                                            'PBS_Problem_Solving','PBS_Communication','PBS_Roles','PBS_Affective_Responses','PBS_Affective_Involvement',
                                            'PBS_Behavior_Control','PBS_General_Functioning','CG_Problem_Solving','CG_Communication','CG_Roles',
                                            'CG_Affective_Responses','CG_Affective_Involvement','CG_Behavior_Control','CG_General_Functioning',
                                            'CG_is_same_as_other_assessment', 'Caregiver_Who_Completed_Assessment', 'PC_Highest_Edu', 'PC_Employment',
                                            'Caregiver_Who_Completed_Assessment', 'SC_No_SC', 'SC_Received_FCT_before', 'PC_Received_FCT_before', 'SC_Occupation', 'PC_Occupation',
                                            'PC_Name', 'SC_Name', 'PC_Relationship_to_PBS', 'SC_Relationship_to_PBS', 'PC_Relationship_to_PBS_Other', 'SC_Relationship_to_PBS_Other',
                                            'SC_Highest_Edu', 'PC_Highest_Edu', 'SC_Employment', 'PC_Employment'};    

    public static void createTestData(){

        Assessment_Domain__c assessmentDomain = new Assessment_Domain__c();
        assessmentDomain.name = 'test1';
        assessmentDomain.Assessment_Type2__c = 'FAD Summary';
        
        List<Assessment_Domain__c> assessmentDomains = new List<  Assessment_Domain__c>() ;
        assessmentDomains.add(assessmentDomain);
        insert assessmentDomains;
        
        for (String devName : questionDevName) {
            Assessment_Question__c Question = new Assessment_Question__c();
            Question.Question_Domain__c = assessmentDomain.id;
            Question.Dev_Name__c = devName;
            Questions.add(Question);    
        }    
        insert Questions;
    }
    
    public static Assessment__c createAssessment() {
          String RecTypeId = [select Id from RecordType where (DeveloperName='Person_Being_Served') and (SobjectType='Account') Limit 1].Id;
            Account Accnt = new Account(
                RecordTypeID=RecTypeId,
                FirstName= 'Test FName',
                LastName='Test LName',
                PersonMailingStreet='test@yahoo.com',
                PersonMailingPostalCode='12345',
                PersonMailingCity='SFO',
                PersonMailingStateCode='NC',
                PersonEmail='test@yahoo.com',
                PersonHomePhone='1234567',
                PersonMobilePhone='12345678'
            );
            insert Accnt;
            Accnt = [
                SELECT ID, PersonContactId FROM Account WHERE ID=:Accnt.ID LIMIT 1
            ];
            Admission__c admission = new Admission__c(
                Name='TestName',
                Person_Being_Served__c=Accnt.PersonContactId
            );
            insert admission;
            //insert ast;
            Assessment__c ass = new Assessment__c(
                Name='Test Assessment',
                Admission__c=admission.ID,
                AccountPerson__c=Accnt.ID,
                TFC_Family_Vistas__c='Yes',
                Interval__c='Intake'
            );
            insert ass;
            return ass; 
       
    }    
}