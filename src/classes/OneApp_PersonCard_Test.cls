@isTest
private class OneApp_PersonCard_Test {
    
    static testMethod void myUnitTest() {
        
        User tester = Referral_createTestData.createTestUser('astest', 'astest@test.com', 'Action', 'Summary', 'Redwood');
        tester.Operating_Group__c = 'Redwood';
        update tester;
        System.runAs(tester) {
            TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();
            OneApp_PersonCard dspPCard = new OneApp_PersonCard();
            dspPCard.populateCard('');
            system.assert(String.IsBlank(dspPCard.reqInfo));
            system.assert(String.IsBlank(dspPCard.reqType));
            system.assert(String.IsBlank(dspPCard.inputID));
            
            
            //created isolation, related party, Diagnosis and one of evaluation response types
            list<Related_Party__c> relParties = new list<Related_Party__c>();
            relParties.add(new Related_Party__c(Name='rp name', type__c = 'Guardian', Person_Being_Served__c = testData.ContactID));
            relParties.add(new Related_Party__c(Phone_1_Type__c = 'Work', Phone__c = '123-123-123', Name='Physician name', type__c = 'Physician - Primary', Person_Being_Served__c = testData.ContactID));
            insert relParties;
            
            ICD__c icd = new ICD__c(Code_Type__c = 'ICD-10', Icd_Description__c = 'testing'); insert icd;
            Diagnosis__c diag = new Diagnosis__c(Status__c = 'Active', Type__c = 'Admission', PBS__c  = testData.ContactID, ICD__c = icd.Id); insert diag;
            
            ServiceAssignment_Diagnosis_JO__c saDiag = new ServiceAssignment_Diagnosis_JO__c(Diagnosis__c = diag.Id, Ranking__c = 'Primary', Service_Assignment__c = testData.theSA.Id); insert saDiag; 
            
            List<RecordType> rt = [select id from RecordType where DeveloperName = 'Allergy' and sObjectType = 'Evaluation_Response__c' limit 1];
            insert new Evaluation_Response__c(Person_Being_Served__c = testData.ContactID, RecordTypeId = rt[0].Id, Allergy_type__c = 'Food', Allergy_Details__c = 'Rice', Life_Threatening__c = true);
            
            rt = [select id from RecordType where DeveloperName = 'Isolation_Event' and sObjectType = 'Evaluation_Response__c' limit 1];
            insert new Evaluation_Response__c(
                Isolation_Event_Start_Date__c = DateTime.now(),
                Isolation_Status__c = 'isolated',
                Isolation_Type__c = 'other',
                other__c  = 'test',
                Service_Assignment__c = testData.theSA.Id,
                RecordTypeId = rt[0].Id );
            
            dspPCard.populateCard('Seizures,'+String.valueOf(testData.contactId));
            system.assert(dspPCard.reqType == 'Seizures');
            system.assert(dspPCard.inputID == String.valueOf(testData.contactId));
            system.assert(dspPCard.guardianCount == 1);
            
            system.assert(dspPCard.isolationStatus == 'Isolated');
            system.assert(dspPCard.isolationType == 'test');
            
            
        }
        
    }
    
    static testMethod void myUnitTest2() {
        User tester = Referral_createTestData.createTestUser('astest', 'astest@test.com', 'Action', 'Summary', 'Redwood');
        tester.Operating_Group__c = 'Redwood';
        update tester;
        System.runAs(tester) {
            TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();
            Action_Plan__c ap = new Action_Plan__c( Service_Assignment__c = testData.theSA.id,
                                                   Target_Date__c = system.today(), Effective_Date__c = system.today()-365 );        
            insert ap;
            
            //created isolation, related party, Diagnosis and one of evaluation response types
            list<Related_Party__c> relParties = new list<Related_Party__c>();
            relParties.add(new Related_Party__c(Name='rp name', type__c = 'Guardian', Person_Being_Served__c = testData.ContactID));
            relParties.add(new Related_Party__c(Phone_2_Type__c = 'Work', Phone_2__c = '123-123-123', Name='rp name', type__c = 'Physician - Primary', Person_Being_Served__c = testData.ContactID));
            insert relParties;
            
            OneApp_PersonCard dspPCard = new OneApp_PersonCard();
            dspPCard.populateCard('Skill,'+String.valueOf(ap.Id));
            system.assert(dspPCard.reqType == 'Skill');
            system.assert(dspPCard.inputID == String.valueOf(ap.Id));
        }
    }
    
}