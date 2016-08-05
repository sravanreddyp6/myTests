@isTest
private class PlanOfCareTest {
    static TMN_Generic_Core_TestData myData;
    static assessment__c assessment; 
    

     static testMethod void testNoRiskAssessment() {
        createData();
        PageReference pageRef = Page.PlanOfCare;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', myData.contactID);
        
        PlanOfCare controller = new PlanOfCare();
        system.assert(true, Apexpages.hasMessages(ApexPages.Severity.ERROR));
    }
    
    static testMethod void myTestWithActionPlan() {
        createData();
        
        Assessment_Response__c assessRsp = [SELECT Description_of_Risk__c, Plan_to_reduce_Risk__c, Response__c, Yes_No__c, Response_Has_Value__c, Age__c from Assessment_Response__c];
        assessRsp.Rating__c = 'Presents a Risk';
        assessRsp.Plan_to_reduce_Risk__c = 'test Plan_to_reduce_Risk';
        assessRsp.Description_of_Risk__c = 'test Description';
        update assessRsp;
        
        assessment.Status__c = 'Active Final';
        assessment.Approval_Date__c = myData.theSA.Start_Date__c;
        assessment.Approval_Status__c = 'Approved';
        assessment.Staffing_Supervision_Needs__c = 'Person needs 24 hour plan of care (May not require supervision at all times but there is someone identified/assigned that is responsible and accessible to the consumer in case of emergency. 24 hour plan of care required for individiual in ICF-MR and waiver eligible individuals);Person requires overnight supervision;Person requires 24 hour awake supervision;';
        update assessment; 
                                  
        PageReference pageRef = Page.PlanOfCare;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', myData.contactID);
        
        PlanOfCare controller = new PlanOfCare();
        system.assert(true, controller.GETplanStuff().values().size() > 0);
    }    
    
    
    private static Action_Plan__c createData(){
        myData = new TMN_Generic_Core_TestData();

        Action_Plan__c ap = new Action_Plan__c(
                Service_Assignment__c = myData.theSA.id,
                Target_Date__c = myData.theSA.Start_Date__c.addDays(1),
                Effective_Date__c = myData.theSA.start_Date__c
                );
        insert ap;

        Action_Plan_Goal__c apg = new Action_Plan_Goal__c(
                Description__c = 'a goal',
                Action_Plan__c = ap.id,
                sort_order__c = 'g'
                );
        insert apg;

        Action_Plan_Objective__c apos = new Action_Plan_Objective__c(
                Action_Plan_Goal__c = apg.id,
                Status__c = 'In Progress',
                Description__c = 'an Objective',
                Type__c = 'skill',
                Target_End_Date__c = myData.theSA.Start_Date__c.addDays(1),
                Effective_Date__c = myData.theSA.Start_Date__c,
                sort_order__c = 'o'
                );
        insert apos;
        Action_Plan_Objective__c apob = new Action_Plan_Objective__c(
                Action_Plan_Goal__c = apg.id,
                Status__c = 'In Progress',
                Description__c = 'Behavior Count Objective',
                Type__c = 'Behavior - Count',
                Target_End_Date__c = myData.theSA.Start_Date__c.addDays(1),
                Effective_Date__c = myData.theSA.Start_Date__c,
                sort_order__c = 'o'
                );
        insert apob;
        Action_Plan_Objective__c apon = new Action_Plan_Objective__c(
                Action_Plan_Goal__c = apg.id,
                Status__c = 'In Progress',
                Description__c = 'Narrative Objective',
                Type__c = 'Narrative',
                Target_End_Date__c = myData.theSA.Start_Date__c.addDays(1),
                Effective_Date__c = myData.theSA.Start_Date__c,
                sort_order__c = 'o'
                );
        insert apon;

        Action_Plan_Action__c apa = new Action_Plan_Action__c (
                Action_Plan_Objective__c = apos.id,
                Description__c = 'action',
                sort_order__c = 'a',
                Start_Date__c = myData.theSA.Start_Date__c,
                End_Date__c = myData.theSA.Start_Date__c.addDays(1),
                Status__c = 'New'
                );
        insert apa;

        insert new Seizure__c(
                Start_DateTime__c = DateTime.now(),
                End_DateTime__c = DateTime.now().addMinutes(3),
                Service_Assignment__c = ap.Service_Assignment__c,
                Observed_By__c = UserInfo.getUserId()
                );
        List<RecordType> rt = [select id from RecordType where DeveloperName = 'Isolation_Event' and sObjectType = 'Evaluation_Response__c' limit 1];
        insert new Evaluation_Response__c(
                Isolation_Event_Start_Date__c = DateTime.now(),
                Isolation_Event_End_Date__c = DateTime.now().addMinutes(3),
                Isolation_Status__c = 'Status',
                Isolation_Type__c = 'Type',
                Service_Assignment__c = ap.Service_Assignment__c,
                RecordTypeId = rt[0].Id
                );
        rt = [select id from RecordType where DeveloperName = 'RestraintEvent' and sObjectType = 'Evaluation__c' limit 1];
        insert new Evaluation__c(
                Shift_Start_Time__c = DateTime.now(),
                Shift_End_Time__c = DateTime.now().addMinutes(60),
                ServiceAssignment__c = ap.Service_Assignment__c,
                RecordTypeId = rt[0].Id
                );

        Eval_type__c evalType = new Eval_Type__c(
                Name = 'Test Type',
                Category__c = 'Care Meridian'
                );
        insert evalType;

        Evaluation__c evaluation = new Evaluation__c(
                ServiceAssignment__c = ap.Service_Assignment__c
                );
        insert evaluation;
        Eval__c[] evals = new Eval__c[] {
                new Eval__c(
                    Eval_Type__c = evalType.Id,
                    Category__c = 'Diagnostics',
                    Sub_Category__c = 'Vitals Signs',
                    Field_Name__c = 'Blood Pressure',
                    htmlid__c = 'bp'
                    ),
                new Eval__c(
                    Eval_Type__c = evalType.Id,
                    Category__c = 'Diagnostics',
                    Sub_Category__c = 'Vitals Signs',
                    Field_Name__c = 'Heart Rate',
                    htmlid__c = 'hr'
                    ),
                new Eval__c(
                    Eval_Type__c = evalType.Id,
                    Category__c = 'Diagnostics',
                    Sub_Category__c = 'Vitals Signs',
                    Field_Name__c = 'O2 Saturation',
                    htmlid__c = 'o2'
                    ),
                new Eval__c(
                    Eval_Type__c = evalType.Id,
                    Category__c = 'Diagnostics',
                    Sub_Category__c = 'Vitals Signs',
                    Field_Name__c = 'Temperature',
                    htmlid__c = 'temp'
                    ),
                new Eval__c(
                    Eval_Type__c = evalType.Id,
                    Category__c = 'Diagnostics',
                    Sub_Category__c = 'Vitals Signs',
                    Field_Name__c = 'Date',
                    htmlid__c = 'date'
                    )
        };
        insert evals;

        insert new Eval_Value__c[] {
                new Eval_Value__c(
                        Eval__c = evals[0].Id,
                        Text_Under_250__c = 'BP',
                        What_Id_Object__c = 'Evaluation__c',
                        Eval_Section_Id__c = 'section',
                        What_Id__c = evaluation.Id
                        ),
                new Eval_Value__c(
                        Eval__c = evals[1].Id,
                        Number_No_Decimal__c = 10,
                        What_Id_Object__c = 'Evaluation__c',
                        Eval_Section_Id__c = 'section',
                        What_Id__c = evaluation.Id
                        ),
                new Eval_Value__c(
                        Eval__c = evals[2].Id,
                        Number_No_Decimal__c = 10,
                        What_Id_Object__c = 'Evaluation__c',
                        Eval_Section_Id__c = 'section',
                        What_Id__c = evaluation.Id
                        ),
                new Eval_Value__c(
                        Eval__c = evals[3].Id,
                        Text_Under_250__c = 'Temp',
                        What_Id_Object__c = 'Evaluation__c',
                        Eval_Section_Id__c = 'section',
                        What_Id__c = evaluation.Id
                        ),
                new Eval_Value__c(
                        Eval__c = evals[4].Id,
                        Date_Time__c = DateTime.now(),
                        What_Id_Object__c = 'Evaluation__c',
                        Eval_Section_Id__c = 'section',
                        What_Id__c = evaluation.Id
                        )
        };

        insert new Action_Skill_Result__c(
                Action_Plan_Objective__c = apos.Id,
                Met_Objective__c = 'Y',
                Day__c = ap.Effective_Date__c,
                Attempts__c = 2,
                Status__c='I'
                );

        insert new Action_Behavior_Result__c(
                Action_Plan_Objective__c = apob.Id,
                Day_Time__c = ap.Effective_Date__c,
                Occurrences__c = 5,
                Occurred__c = true
                );

        insert new Action_Narrative_Result__c(
                Action_Plan_Objective__c = apon.Id,
                Description__c = 'Test Narrative'
                );

        ap.Status__c = 'Active Final';
        upsert ap;

        
        Assessment_Type__c testAssmtType = new Assessment_Type__c(
            Name = 'RISK'           
        );
        insert testAssmtType;
        
        Assessment_Domain__c testDomain = new Assessment_Domain__c(
            Name = 'TEST DOMAIN',
            Assessment_Type__c = testAssmtType.Id
        );
        insert testDomain;
        
        Assessment_Question__c testQuestion = new Assessment_Question__c(
            Question_Title__c = 'TEST QUESTION',
            Question_Description__c = 'A TEST QUESTION',
            Question_Domain__c = testDomain.Id
        );
        insert testQuestion;
   
        assessment = new assessment__c(Assessment_Type__c = testAssmtType.id, Admission__c = myData.theAdm.id, Assessment_Date__c = myData.theSA.Start_Date__c, Service_Assignment__c = myData.theSA.id);      
        insert (assessment);
        
   
        return ap;
    }        
}