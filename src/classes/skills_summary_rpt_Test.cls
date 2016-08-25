@isTest
public class skills_summary_rpt_Test{
	
	private static Action_Plan__c testplan;
    private static Action_Plan_Goal__c testGoal;
    public static Action_Plan_Objective__c testObjective;
    public static Id personId;
    public static TMN_Generic_Core_TestData myData;
    
static testMethod void testReport() {

    DateTime startDateTime = DateTime.NewInstance(2014,11,1,12,0,0);
    DateTime endDateTime = DateTime.NewInstance(2014,12,31,12,0,0);
    createObjects();

 	PageReference ref = new PageReference('/apex/skills_summary_rpt');
    Test.setCurrentPage(ref); 
    skills_summary_rpt cntl = new skills_summary_rpt();

    cntl.startdate =  Date.newInstance(2014,11,1);
	cntl.enddate = Date.newInstance(2014,10,1);

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
    
	cntl.runPDF();
	
    cntl.select2PrmIds.Add( cntl.selectedprograms[0]);
    cntl.RemovePrograms();

   	
}

private static Action_Plan__c createObjects(){

	    myData = new TMN_Generic_Core_TestData();
	    myData.theSA.Service_Location__c =  Referral_CreateTestData.createServiceLocation('11111').Id;
	    upsert myData.theSA;

       testplan = new Action_Plan__c();
       testplan.Service_Assignment__c = mydata.thesa.id;
       insert testPlan;
       
       testGoal = new Action_Plan_Goal__c();
       testGoal.Action_Plan__c = testPlan.Id;
       testGoal.Description__c = 'Just a testobject';
       insert testGoal;
       
       testObjective = new Action_Plan_Objective__c();
       testObjective.Action_Plan_Goal__c = testGoal.Id;
       testObjective.Description__c = 'Just a testobject';
       testObjective.Status__c = 'In Progress';
       testObjective.Type__c = 'Skill';
       testObjective.Effective_Date__c = Date.parse('10/10/2013');
       testObjective.Target_End_Date__c = Date.parse('10/31/2015');
       
       insert testObjective;
       
       return testplan;
   }
   
}