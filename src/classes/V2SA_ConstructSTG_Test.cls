/**
    Test class for controller V2SA_ConstructSTG.cls (Plan Management)
 */
@isTest
private class V2SA_ConstructSTG_Test {

    static testMethod void myUnitTest() {
      Date startDate = Date.today();
        Date endDate = Date.today().addDays(50);
        
        //Creation of Contact (person being served)
        Contact objContactServed = new Contact();
        objContactServed.FirstName = 'Test Person';
        objContactServed.LastName = 'Served';
        insert objContactServed;
        
        // Creation of Admission
        Admission__c objAdmission = new Admission__c();
        objAdmission.Name = 'Test Admission';
        objAdmission.Person_Being_Served__c = objContactServed.Id;
        objAdmission.Discharged_Date__c = system.today();
        objAdmission.Status__c = 'Discharged';
        objAdmission.Reason_for_Discharge__c ='just because';
        objAdmission.Discharged_Status__c = 'Positive';
        insert objAdmission;
        
        Admission__c objAdmission2 = new Admission__c();
        objAdmission2.Name = 'Test Admission';
        objAdmission2.Person_Being_Served__c = objContactServed.Id;
        
        insert objAdmission2;        
        
        // Creation of Plan
        Plan__c objPlan = new Plan__c();
        objPlan.Plan_Name__c = 'Test Plan';
        objPlan.Admission__c = objAdmission.Id;
        objPlan.Person_Being_Served__c = objContactServed.Id;
       // objPlan.Status__c = 'Active';
        objPlan.Status__c = 'Inactive';
        objPlan.Long_term_Goal_1__c = '1245dfgsd';
        insert objPlan;
        
        Plan__c objPlan2 = new Plan__c();
        objPlan2.Plan_Name__c = 'Test Plan';
        objPlan2.Admission__c = objAdmission.Id;
        objPlan2.Person_Being_Served__c = objContactServed.Id;
        objPlan2.Status__c = 'Inactive';
        objPlan2.Read_Only__c = true;
        objPlan2.Long_term_Goal_1__c = '1245dfgsd';
        insert objPlan2;



        
                
        
        // Creation of Service Assignments(select list options) - lookup to Admission
        Service_Assignment__c objServAssignment1 = new Service_Assignment__c();
        objServAssignment1.Name = 'Test Service Assignment1';
        objServAssignment1.Admission__c = objAdmission2.Id;
        objServAssignment1.Person_Being_Served__c = objContactServed.Id;
        insert objServAssignment1;
        
        Service_Assignment__c objServAssignment2 = new Service_Assignment__c();
        objServAssignment2.Name = 'Test Service Assignment2';
        objServAssignment2.Admission__c = objAdmission2.Id;
        objServAssignment2.Person_Being_Served__c = objContactServed.Id;
        insert objServAssignment2;
        
        Service_Assignment__c objServAssignment3 = new Service_Assignment__c();
        objServAssignment3.Name = 'Test Service Assignment3';
        objServAssignment3.Admission__c = objAdmission2.Id;
        objServAssignment3.Person_Being_Served__c = objContactServed.Id;
        insert objServAssignment3;
        
        // Creation of Objective (Short-term Goal) - lookup to Plan
        Short_Term_Goal__c objObjective = new Short_Term_Goal__c();
        objObjective.Name = 'Test Short-term Goal Name';
        objObjective.Short_Term_Goal_Description__c = 'Test Short-term Goal Description';
        objObjective.Plan__c = objPlan.Id;
        insert objObjective;
        
        // Creation of Plan Objective - lookup to Short Term Goal
        Objective__c objPlanObjective = new Objective__c();
        objPlanObjective.Short_Term_Goal__c = objObjective.Id;
        insert objPlanObjective;
        
        //Creation of Intervention - lookup to Objective (Short-term Goal)
        Intervention__c objIntervention = new Intervention__c();
        objIntervention.Short_Term_Goal__c = objObjective.Id;
        objIntervention.Objective__c = objPlanObjective.Id;
        insert objIntervention;
        
        System.currentPageReference().getParameters().put('id', objPlan.Id);
        V2SA_ConstructSTG stg = new V2SA_ConstructSTG();
       
        stg.Nothing();
        stg.CheckExternalPlan();
        stg.backExternal();
        stg.AddNewObjectiveCancel();
        stg.AddNewObjective();
        stg.lstInnObjective.get(0).EndEditObjective();
        
        stg.lstInnObjective.get(0).AddNewPlanObjective(); 
        stg.lstInnObjective.get(0).AddNewPlanObjectiveCancel();
        //important must add new service assignment twice first time is for fail
        stg.lstInnObjective.get(0).AddNewServiceAssignment();
        stg.lstInnObjective.get(0).newServiceAssignment =objServAssignment1.id;
        stg.lstInnObjective.get(0).AddNewServiceAssignment();
        stg.lstInnObjective.get(0).AddNewServiceAssignmentCancel();
        
        stg.lstInnObjective.get(0).lstInnPlanObjective.get(0).EndEditPlanObjective();
        stg.lstInnObjective.get(0).lstInnPlanObjective.get(0).AddNewIntervention();
        stg.lstInnObjective.get(0).lstInnPlanObjective.get(0).AddNewInterventionCancel();
        stg.lstInnObjective.get(0).lstInnPlanObjective.get(0).AddNewServiceAssignment();
        stg.lstInnObjective.get(0).lstInnPlanObjective.get(0).newServiceAssignment = objServAssignment1.id;
        stg.lstInnObjective.get(0).lstInnPlanObjective.get(0).AddNewServiceAssignment();
        stg.lstInnObjective.get(0).lstInnPlanObjective.get(0).AddNewServiceAssignmentCancel();
        
        stg.lstInnObjective.get(0).lstInnPlanObjective.get(0).lstInnIntervention.get(0).EndEditIntervention();
        stg.lstInnObjective.get(0).lstInnPlanObjective.get(0).lstInnIntervention.get(0).AddNewServiceAssignmentCancel();
        stg.lstInnObjective.get(0).lstInnPlanObjective.get(0).lstInnIntervention.get(0).AddNewServiceAssignment();
        
        stg.lstInnObjective.get(0).lstInnPlanObjective.get(0).lstInnIntervention.get(0).deleteIntervention();
        stg.lstInnObjective.get(0).lstInnPlanObjective.get(0).DeletePlanObjective();        
        stg.lstInnObjective.get(0).DeleteObjective();
        
        /*
        //start my plans view
        V2SA_MyPlans myPlans = new V2SA_MyPlans();
        myPlans.newPlan();
        System.currentPageReference().getParameters().put('id', objPlan.Id);
        myPlans.newPlan();
        */
        //end my plans view
       // Progress_Note__c thisPn = new Progress_Note__c();
       // insert thisPn ;
        //start my persons view
        
        
        
        
     /*   
       Notes_Plan_Approval npai = new Notes_Plan_Approval(objPlan);
        
        npai.MarkApproved();
        
        System.currentPageReference().getParameters().put('id', objPlan.Id);
        System.currentPageReference().getParameters().put('state', 'nc');
        Notes_ProgressNote_Create tmp = new Notes_ProgressNote_Create();
        */        
        //
        
    }
}