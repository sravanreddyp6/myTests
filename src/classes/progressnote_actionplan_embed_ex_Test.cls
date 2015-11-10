@isTest
public with sharing class progressnote_actionplan_embed_ex_Test{
 static testMethod void myUnitTest() {
 
        Contact testContact = new Contact(
        LastName = 'TestLastName'
      );
      insert testContact;
      
      Admission__c testAdm = new Admission__c(
            Name = 'TEST ADM',
            Person_Being_Served__c = testContact.Id,
            Effective_Date__c = date.today()
      );
      insert testAdm;
        
        Service_Assignment__c testServAssignment = new Service_Assignment__c(
          Admission__c = testAdm.Id,
          Person_Being_Served__c = testContact.Id
        );
        insert testServAssignment;
        
        Service_Code__c testServCode = new Service_Code__c(
          Service_Code__c = 'TEST SVC CODE',
          FacilityID__c = 'TEST FAC ID',
          Program_Code__c = 'TEST PROGRAM CODE' 
          
        );
        testServCode.Start_Date__c = date.newInstance(2012, 1, 1);
        insert testServCode;

     	Action_Plan__c ap = new Action_Plan__c(
         
     	);
     insert ap;
     	Action_plan_Goal__c apg = new Action_Plan_goal__c(
        	 Action_Plan__c = ap.id,
            Description__c = 'be awesome'
         );
     insert apg;
     	Action_plan_Objective__c apo = new Action_Plan_Objective__c(
        	 Action_Plan_Goal__c = apg.id
         );
     insert apo;     
     
        Progress_Note__c testPN = new Progress_Note__c(
          Service_Assignment__c = testServAssignment.Id, 
            action_plan__c = ap.id,
          Service_Code__c = testServCode.Id, 
          Admission__c = testAdm.ID,
          Start_Time__c = datetime.newInstance(2012, 1, 1, 13, 0, 0),
          End_Time__c = datetime.newInstance(2012, 1, 1, 15, 0, 0),
          Person_Being_Served__c = testContact.Id,
          No_Approval_Needed__c = true,
          Approval_Status__c = 'Approved'
        );
        insert testPN; 


        PageReference pageRef = Page.progressnote_actionplan_embed;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(testPN);
        progressnote_actionplan_embed_ex control = new progressnote_actionplan_embed_ex (sc);
     	control.MapItemInNote.put(apg.id, true);
     	control.isGoal = true;
     	control.updatingID = apg.id;
        control.myUpdate();
     
     	ApexPages.StandardController sc2 = new ApexPages.StandardController(testPN);
        ProgressNote_Esign control2 = new ProgressNote_Esign (sc2);
     
        sc = new ApexPages.StandardController(testPN);
        control = new progressnote_actionplan_embed_ex (sc);
     	control.MapItemInNote.put(apg.id, false);
     	control.isGoal = true;
     	control.updatingID = apg.id;
        control.myUpdate();     
     
}
}