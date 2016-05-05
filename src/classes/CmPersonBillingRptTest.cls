@isTest
private class CmPersonBillingRptTest {
    static TMN_Generic_Core_TestData myData;

    static testMethod void myTestWithNoEval() {
        TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();

        PageReference pageRef = Page.CmPersonBillingRpt;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', testData.contactID);
        ApexPages.currentPage().getParameters().put('StartDate','01/01/2015');
        ApexPages.CurrentPage().getParameters().put('EndDate','01/08/2015');

        CmPersonBillingRpt controller = new CmPersonBillingRpt();
        system.assert(controller.nsdEvalIds.size() == 0);
    }


    static testMethod void myTestWithEval() {
        Action_Plan__c actionPlan = createData();
        Action_Summary__c summary = new Action_Summary__c(
                End_Date__c = date.newInstance(2015, 1, 3),
                Start_date__c = date.newInstance(2015, 1, 2),
                New_Version__c = true,
                Service_Assignment__c = actionPlan.Service_Assignment__c,
                Status__c = 'Final'
                );
        insert summary;

        PageReference pageRef = Page.CmPersonBillingRpt;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', myData.contactID);
        ApexPages.currentPage().getParameters().put('StartDate','01/01/2015');
        ApexPages.CurrentPage().getParameters().put('EndDate','01/08/2015');

        list<Evaluation__c> evaluations = new list<Evaluation__c>();
        evaluations.add(new Evaluation__c ( Status__c = 'Draft', RecordtypeId = Utility.getEvaluationRecordType('CMShiftAssessment'),
											Shift_Start_Time__c = datetime.newInstance(2015, 1, 2, 0, 2, 2), Shift_End_Time__c = datetime.newInstance(2015, 1, 3, 0, 2, 2),
											Head_to_Toe_Status__c = 'Final', ServiceAssignment__c = myData.theSA.Id ));

        evaluations.add(new Evaluation__c ( Status__c = 'Final', RecordtypeId = Utility.getEvaluationRecordType('CNA Workbook'),
                                            Shift_Start_Time__c = datetime.newInstance(2015, 1, 2, 0, 2, 2), Shift_End_Time__c = datetime.newInstance(2015, 1, 3, 0, 2, 2),
                                            ServiceAssignment__c = myData.theSA.Id ));
        insert evaluations;

        list<eval__c> evals = TMN_Generic_Core_TestData.getEvalTestRecords();
        Eval_Type__c evlTyp = [Select Name, id from Eval_Type__c where Name = 'Head to Toe'];
        list<Eval_Value__c> evalVals = new list<Eval_Value__c>();
        for (Eval__c e : [select id, Field_Type__c, Field_Sub_Type__c
                            from eval__c where eval_type__r.name = 'Head to Toe'
                                                   and category__c = 'TEST'
                                                   and sub_category__c = 'TEST_TEST'
                                                   and visible__c = true]){
                                                   	
            Eval_Value__c val = new Eval_Value__c(Eval__c = e.Id, Eval_Section_Id__c =  UserInfo.getUserId() + '-' + DateTime.now().formatLong(),
                                        What_ID__c = evaluations[0].id, What_ID_Object__c = 'Evaluation__c', Eval_Section_Type__c = evlTyp.Name); 
            if (e.Field_Type__c == 'Hidden' && e.Field_Sub_Type__c == 'Boolean') val.Boolean__c = true;
            else if (e.Field_Type__c == 'Hidden' && e.Field_Sub_Type__c == 'String') val.Text_Under_250__c = 'Error Message';
            else if(e.Field_Type__c == 'Boolean' && e.Field_Sub_Type__c == 'Checkbox')  val.Boolean__c = true;
            else if(e.Field_Type__c == 'Boolean' && e.Field_Sub_Type__c == 'Dropdown')  val.Boolean__c = true;
            else if(e.Field_Type__c == 'Int' )  val.Number_No_Decimal__c = 12;
            else if(e.Field_Type__c == 'Date')  val.Date_Time__c = datetime.newInstance(2013, 11, 12, 0, 0, 0);
            else if(e.Field_Type__c == 'DateTime') val.Date_Time__c = datetime.newInstance(2015, 4, 27, 18, 0, 0);
            else if(e.Field_Type__c == 'String') val.Text_Under_250__c = 'Test';
            else if(e.Field_Type__c == 'DropDown') val.Text_Under_250__c = 'Test';
            else if(e.Field_Type__c == 'Multiselect') val.Text_Over_250__c = 'TEST; Test1';
            evalVals.add(val);
        }
        
        insert evalVals;
        insert (new Evaluation_Response__c( RecordTypeId = Utility.getEvaluationResponseRecordType('Late Entry Note'),
                                            Late_Entry_Note__c = 'Test late note', Evaluation__c = evaluations[0].id ));

        CmPersonBillingRpt controller = new CmPersonBillingRpt();

        system.assert(controller.nsdEvalIds.size() == 1);
        system.assert(controller.cnaEvalIds.size() == 1);

        system.assert(!controller.getMapEvalResposes().isEmpty());
        system.assert(!controller.getmapEvalResposeFlds().isEmpty());
        system.assert(!controller.getmapEvalResposeFldLbls().isEmpty());

        system.assert(!controller.evalSectionsMap.isEmpty());
        system.assert(controller.mapEvalResposes.get(controller.nsdEvalIds[0]).get('Late Entry Note').size() > 0);
        system.assert(!controller.evalValues.get(controller.nsdEvalIds[0]).isEmpty());
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

        return ap;
    }
}