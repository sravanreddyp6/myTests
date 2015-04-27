@isTest
private class Assessment_RiskFormTest{

    static testMethod void myUnitTest() {
        Assessment__c ass = createAssessment();
    
        Assessment_RiskForm controller = new Assessment_RiskForm(new ApexPages.StandardController(ass));
          
       // ApexPages.StandardController sc = new ApexPages.StandardController(ass);
       // Assessment_RiskForm testACE = new Assessment_RiskForm (sc);
        //  controller.save();
          
        PageReference pgref= Page.Assessment_RiskForm; 
        Test.setCurrentPage(pgref);
        
        List<Assessment_Response__c> tmpRes = new List<Assessment_Response__c>();
        tmpRes = controller.mapCurrentResps.values();
        tmpRes[0].Rating__c = 'Presents a Risk';
        controller.mysave();
        
        tmpRes[0].Rating__c = 'does not present a Risk';
        controller.mysave();


        ass.Staffing_Supervision_Needs__c = 'Test';
    //    ass.Recommended_Day_Services_Staffing_Ratio__c = 'Test';
        ass.Support_Required_Level_Residential__c = 'Support person on premises at all times when individual is home;Can be unsupervised at home for__13Minutes;Can be unsupervised in the community for__14Hours;Specific Plan__15;';
        ass.Services_Required_Level_Day_Services__c = 'Current level of services required for health and safety supports__Full Day;Can be without caregiver for__12Minutes;Other;Specific Plan__tes;';
        ass.Recommended_Day_Services_Staffing_Ratio__c = '1 to 4;1 to 6;1 to 8;Other__8_7;';
        ass.Staffing_Supervision_Needs__c = 'Person accesses support as needed;Person requires some services, doesn\'t require 24 hours of care;Person requires 24 hour awake supervision;';
        controller = new Assessment_RiskForm(new ApexPages.StandardController(ass));
        controller.mysave();
/*
   //     ass.Recommended_Day_Services_Staffing_Ratio__c = '1 to 8';
        ass.Support_Required_Level_Residential__c = 'Can be unsupervised at home for 1 minutes';
        ass.Services_Required_Level_Day_Services__c = 'Test';
        controller = new Assessment_RiskForm(new ApexPages.StandardController(ass));
        controller.mysave();

        ass.Services_Required_Level_Day_Services__c = 'Other';
        ass.Support_Required_Level_Residential__c = 'Can be unsupervised in the community for 1 hours';
        controller = new Assessment_RiskForm(new ApexPages.StandardController(ass));
        controller.mysave();

        ass.Services_Required_Level_Day_Services__c = 'Current level of services required for health and safety supports 3 days';
        ass.Support_Required_Level_Residential__c = 'Test';
        controller = new Assessment_RiskForm(new ApexPages.StandardController(ass));
        controller.mysave();
        
        ass.Support_Required_Level_Residential__c = 'Can be unsupervised at home for 1 day';  // should show in specific plan
        ass.Services_Required_Level_Day_Services__c = 'Can be without caregiver for 2 minutes';
        controller = new Assessment_RiskForm(new ApexPages.StandardController(ass));  
       */ 
        controller = new Assessment_RiskForm(new ApexPages.StandardController(ass));
        controller.myEdit();
        boolean b ;
            b= controller.showConfirmationButton;
            b= controller.canEditRisk;
            b= controller.canFinalize;
            b= controller.dayServicesInFlavor;
            b= controller.staffingRatioInFlavor;
        //  b= controller.
        controller.getdisplayLevel_Required_DayServices();
        controller.getdisplayLevel_Required_ResidentialServices();
        controller.getLevel_Required_DayServices();
        controller.getLevel_Required_ResidentialServices();
        controller.getSOLevel_Required_DayServices();
        controller.getSOLevel_Required_ResidentialServices();
        controller.getSOrecommendedDayServicesStaffingRatio();
        controller.getCurrentResps();
        controller.getRecDayServicesStaffingRatio();
        controller.getStaffing_Supervision_Needs();
        controller.getMapOptions();
        controller.getMapQuestions();
        controller.getDomainsInScope();
        controller.getmapDomainHasRisk();

        
        //controller.get
        
        controller.mysave();   
        
        assessment_response__c ar = [select rating__c from assessment_response__c limit 1];
        ar.Rating__c = 'Does Not Present a Risk';
        update ar;
        
        controller.mySave();
        
        list<string> tmpLst = new list<string>();
        
        tmpLst.clear();
        tmpLst.add('Can be without caregiver for 1 Minutes');        
        controller.setLevel_Required_DayServices(tmpLst);
        
        tmpLst.clear();
        tmpLst.add('Support person on premises at all times when individual is home'); 
        tmpLst.add('Can be unsupervised at home for__13Minutes');
        tmpLst.add('Can be unsupervised in the community for__14Hours');
        tmpLst.add('Specific Plan__15');
        controller.setLevel_Required_ResidentialServices(tmpLst);
        
        tmpLst.clear();
        tmpLst.add('1 to 4');          
        controller.setRecDayServicesStaffingRatio(tmpLst);
        
        tmpLst.clear();
        tmpLst.add('Person accesses support as needed');          
        controller.setStaffing_Supervision_Needs(tmpLst);
        
        
        controller.getLevel_Required_DayServices();
        controller.getLevel_Required_ResidentialServices();
        controller.getRecDayServicesStaffingRatio();
        controller.getStaffing_Supervision_Needs();
        
        
        controller.mySave();

        controller.myApprove();

        controller.myConfirm();

        controller.myRevise();

       // ass = [Select id, Admission__c, Assessment_Type__c from Assessment__c where id != :ass.id];
       // controller = new Assessment_RiskForm(new ApexPages.StandardController(ass)); 

        controller.myApprove();
       
      //   controller.notifyNewAssessmentVersion();
        
        
     //   boolean canEdit = controlle
        boolean canRevise = controller.getCanReviseAssess();
        controller.clearStaffNeeds();
        controller.clearStaffRatio();
        controller.notifyNewAssessmentVersion();
        
        controller.mycancel();


















/*

          //controller.save();
          

            controller = new Assessment_RiskForm(new ApexPages.StandardController(ass));
          //  controller.save();
            

          //  controller.save();
    

           // controller.save();
    

         //   controller.save();
        }
        
        static testmethod void testInsertTasks() {
          Assessment__c ass = createAssessment();
          ass.Status__c = 'Locked';
          update ass;
          Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
          User u = new User(
              Alias = 'testing', Email='testduser@testorg.com', 
                LastName='Testing', UserName='iamatestuser@testorg.com',
                EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles'
            );
            insert u;
            Assessment_Confirmation__c c = new Assessment_Confirmation__c(
                Assessment__c = ass.ID,
                User__c = u.ID
            );
            insert c;
            Assessment__c ass1 = new Assessment__c(
                Name='Test Assessment',
                Admission__c=ass.Admission__c,
                Assessment_Type__c=ass.Assessment_Type__c,
                AccountPerson__c=ass.AccountPerson__c,
                TFC_Family_Vistas__c='Yes',
                Interval__c='Quarterly',
                Quarter__c=1,
                Previous__c=ass.Id,
                Status__c='Locked'
            );
            Integer numTasksBefore = [SELECT ID FROM Task].size();
            insert ass1;
            Assessment_RiskForm controller = new Assessment_RiskForm(new ApexPages.StandardController(ass1));
            controller.notifyNewAssessmentVersion();
            Integer numTasksAfter = [SELECT ID FROM Task].size();
            System.assertEquals(numTasksBefore + 1, numTasksAfter);
        */ 
        }
          
        static Assessment__c createAssessment() {
        /*
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
            */
            TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
            
            Assessment_Type__c ast = createRiskData();
            //insert ast;
            Assessment__c ass = new Assessment__c(
                Name='Test Assessment',
                Admission__c=myData.theAdm.ID,
                Assessment_Type__c=ast.ID,
                AccountPerson__c=myData.theAccount.ID,
                TFC_Family_Vistas__c='Yes',
                Interval__c='Intake'
            );
            insert ass;
            return ass; 
            
            
    }
    
    static Assessment_Type__c createRiskData(){
    
        Assessment_Type__c ast = new Assessment_Type__c(Name='Risk');
        insert ast;
        
        Assessment_Domain__c ad = new Assessment_Domain__c(name = 'test doamin', Assessment_Type__c = ast.id);        
        insert ad;
        
        Assessment_Question__c aq = new Assessment_Question__c(Question_Title__c = 'test question', Question_Domain__c = ad.id);  
        insert aq;
        
        Assessment_Question_Option__c aqo1 = new Assessment_Question_Option__c (Rating__c = 'Presents a Risk', Question__c= aq.id); 
        insert aqo1; 
        Assessment_Question_Option__c aqo2 = new Assessment_Question_Option__c (Rating__c = 'Does Not a Risk', Question__c= aq.id); 
        insert aqo2;         
        
        
        
        
        return ast;
        
        
    
    
    }
    
}