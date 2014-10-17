@isTest
private class proj_nr_form_test {

    static testMethod void myUnitTest() {

        project__c proj = new project__c();

		// START: NPROJ-20:  Added record type information to test to support change for this ticket.  Just did enough to get the test to pass with the previously-expected record type.
		// J. Gilliam, 10/16/14.
        RecordType rt = [ SELECT Id FROM RecordType WHERE DeveloperName = 'Neuro_Restorative' ];
        proj.RecordType = rt;
        // END: NPROJ-20:  Added record type information to test to support change for this ticket.
        
        PageReference pageRef = Page.proj_nr_form;
        
        // START: NPROJ-20:  Added record type information to test to support change for this ticket.
        pageRef.getParameters().put('RecordType', rt.Id);
        Test.setCurrentPage(pageRef);
        // END: NPROJ-20:  Added record type information to test to support change for this ticket.	
        
        ApexPages.StandardController sc = new ApexPages.StandardController(proj);
        proj_nr_form proj_control = new proj_nr_form (sc) ;   
        
        proj_control.getStartOptions();
         
        proj_control.showChatter();
        proj_control.blankRef();
        
        proj_control.cur_proj.name = 'project';
        proj_control.cur_proj.isTemplate__c = true;
        
        proj_control.AddProjectTask();
        
        string taskID = proj_control.projTree.root.nodes[0].key;
        proj_control.projTree.root.nodes[0].ProjTask.name = 'task';
        
        proj_control.PTid = taskID;
        proj_control.AddProjectTaskActivity();
        proj_control.projTree.root.nodes[0].nodes[0].ProjTaskAct.name='activity';
        
        proj_control.save();
        
        project__c p = [select name from project__c limit 1];
        project_task__c pt = [select name from project_Task__c limit 1];
        project_task_activity__c pta = [select name from project_task_activity__c];
        system.assertEquals(p.name, 'project');
        system.assertEquals(pt.name, 'task');
        system.assertEquals(pta.name, 'activity');
        
        ApexPages.StandardController sc2 = new ApexPages.StandardController(p);
        proj_nr_form proj_control2 = new proj_nr_form (sc2) ;   
        
        
        proj_control2.save();
        
        
        
        project__c newP = new Project__c();
        ApexPages.StandardController sc3 = new ApexPages.StandardController(newP);
        proj_nr_form proj_control3 = new proj_nr_form (sc3) ;         
        
        
        List<SelectOption> temps = proj_control3.getTemplates(); 
        proj_control3.selectedTemplate = temps[1].getValue();
        proj_control3.CopyFromTemp();
        proj_control3.cur_proj.name = 'new project name';   
        proj_control3.cur_proj.isTemplate__c = false;
        proj_control3.cur_proj.status__c = 'Active';
           
        //task size   
        system.assertEquals(proj_control3.projTree.root.nodes.size(), 1);   
        //activty size
        system.assertEquals(proj_control3.projTree.root.nodes[0].nodes.size(), 1); 
        proj_control3.save();
        
        proj_control3.PTid = proj_control3.projTree.root.nodes[0].key;

        proj_control3.DeleteProjectTask();        
        
        
         
        proj_nr_activity_rpt rptCnt = new proj_nr_activity_rpt () ;   

        
        
        
    }

}