@isTest
public class shiftnote_summary_rpt_Test{
static testMethod void testReport() {

    TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
    myData.theSA.Service_Location__c =  Referral_CreateTestData.createServiceLocation('11111').Id;
    upsert myData.theSA;
    
    DateTime startDateTime = DateTime.NewInstance(2014,11,1,12,0,0);
    DateTime endDateTime = DateTime.NewInstance(2014,12,31,12,0,0);
    RecordType rt = [select id from recordtype where name='Shift Note'];
    
    Progress_Note__c thisProgressNote = new Progress_Note__c(Service_Assignment__c = mydata.thesa.Id,
                                                                    Service_Code__c = mydata.theservicecode.Id, 
                                                                    Admission__c = mydata.theadm.ID,
                                                                    Start_Time__c = startDateTime,
                                                                    End_Time__c = endDateTime,
                                                                    Person_Being_Served__c = mydata.contactID,
                                                                    No_Approval_Needed__c = true,
                                                                    Approval_Status__c = 'Approved',
                                                                    recordtypeId = rt.Id,
                                                                    Status__c = 'Final');
    insert thisProgressNote;

 	PageReference ref = new PageReference('/apex/ShiftNote_summary_rpt');
    Test.setCurrentPage(ref); 
    shiftnote_summary_rpt cntl = new shiftnote_summary_rpt();

    cntl.startdate =  Date.newInstance(2014,11,1);
	cntl.enddate = Date.newInstance(2014,10,1);

    cntl.enddate = Date.newInstance(2014,12,1);

    cntl.select2PrmIds = new List<ID>();
    cntl.selectedprograms = new List<ID>();
  
    if ( cntl.getprogramsList().size() > 0) {
    	for (SelectOption p : cntl.getprogramslist() ){
	    		cntl.selectedprograms.Add(p.getValue());
			}
    }
    cntl.AddPrograms();
    
    
    System.debug( cntl.getPBSList());
    
    List<ID> pbs = new List<ID>();
    pbs.Add( cntl.getPBSList().get(0).getValue());
    
    cntl.selectedPBS = pbs;
    cntl.runReport();
	// verify an error was thrown
	List<ApexPages.Message> msgList = ApexPages.getMessages();
	
	for(ApexPages.Message msg :  ApexPages.getMessages()) {
    	System.assertEquals('Please choose valid start and end dates', msg.getSummary());
    	System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity());
	}

	cntl.enddate = Date.NewInstance( 2014, 12, 1);	
	cntl.runreport();
    
    cntl.getNote_plan_joins();
    List<Progress_Note__c> notes = cntl.getnotes();
    Map<string, List<ProgressNote_ActionPlanChildren_mjo__c>> note_goals = cntl.getNote_Goals();
    Map<string, List<ProgressNote_ActionPlanChildren_mjo__c>> note_objs = cntl.getNote_Objs();
    
    string combiKey = '';
    List<ProgressNote_ActionPlanChildren_mjo__c> currgoals, currobjs;
    
    for ( Progress_Note__c n : notes) {
    	
    	currgoals = note_goals.get((string)n.Id);
    	
    	for (ProgressNote_ActionPlanChildren_mjo__c g : currgoals ) {
    		system.debug( g.Goal__r.Description__c);
    		
    		combiKey = (string)n.id + (string)g.goal__c;
    		currobjs = note_objs.get(combiKey);
    		
    		for ( ProgressNote_ActionPlanChildren_mjo__c o : currobjs ) 
    			system.debug( o.objective__r.description__c);
    	}
    	
    }

	cntl.runPDF();
	
    cntl.select2PrmIds.Add( cntl.selectedprograms[0]);
    cntl.RemovePrograms();

   	
}
}