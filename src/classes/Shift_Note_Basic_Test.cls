@isTest
public class Shift_Note_Basic_Test{
    private static Progress_Note__c pn;
 	private static Action_plan__c ap;
    private static Action_plan_Goal__c apg;
    private static Action_plan_Objective__c apo;
    private static Action_plan_Action__c apa;
    
	static testMethod void myUnitTest() {
	
	  createData();
	  
	  PageReference pageRef = Page.shiftnote_basic_form;
	   Test.setCurrentPage(pageRef);
	   pageRef.getParameters().put('retURL','%2F'+pn.id);
	   
	  ApexPages.StandardController sc = new ApexPages.StandardController(pn);  
	    
	  Shift_Note_Basic contrl = new Shift_Note_Basic(sc);
	  
	    contrl.myEdit();
	    system.assert(contrl.editMode);
	    contrl.myCancel();
	    contrl.myEdit();
	    Shift_Note_Basic.clsPlan_Goal tmpclsG =  new Shift_Note_Basic.clsPlan_Goal(apg);
	    contrl.mySave();
	    string nextpage = contrl.myFinal().getUrl();
	    system.assertEquals('/p/process/Submit?id='+pn.id+'&retURL=%2F'+pn.id, nextpage);
	    pn.Signature_on_File__c = 'Y';
	    update pn;
	    contrl.myFinal();
	    pn.Number_of_Required_Signatures__c = 0;
	    pn.Locked__c = false;
	    update pn;
	    contrl.myCheckB4Final();
	    contrl.myFinal();
	    contrl.GETallgoals();
	    contrl.getchildrenScope();
	    contrl.getGoals();
	    
	    
	}

//Testing the creation of new Record
	static testMethod void myUnitTest2() {
		TMN_Generic_Core_TestData testData2 = new TMN_Generic_Core_TestData();
		 Action_Plan__c ap2 = new Action_Plan__c(
	          Service_Assignment__c = testData2.theSA.id,
	          Target_Date__c = system.today(),
	          Effective_Date__c = system.today()-365
	        );        
	      insert ap2;
	       
	     Progress_Note__c pn2 = new Progress_Note__c(Service_Assignment__c=testData2.theSA.Id,Admission__c=testData2.theAdm.Id,Service_Code__c=testData2.theServiceCode.Id,Person_Being_Served__c=testData2.contactID,Start_Time__c=DateTime.newInstance(Date.Today(),time.newinstance(0,0,0,0)),End_Time__c=DateTime.newInstance(Date.Today(),time.newinstance(0,30,0,0)));
	   
		PageReference pageRef2 = Page.shiftnote_basic_form;
		Test.setCurrentPage(pageRef2);
		pageRef2.getParameters().put('planId',ap2.Id);
		pageRef2.getParameters().put('saID',testData2.theSA.id);
		pageRef2.getparameters().put('admID',testData2.theAdm.Id);
		ApexPages.StandardController sc = new ApexPages.StandardController(pn2);
		Shift_Note_Basic contrl = new Shift_Note_Basic(sc);
		
		contrl.myEdit();
		contrl.mySave();
		pn2.Signature_on_file__c = 'n';
		update pn2;
		contrl.myCheckB4Final();
		system.assert(!contrl.canFinalize);
				
	}
    
     private static Action_Plan__c createData(){
     	
      TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();
      ap = new Action_Plan__c(
          Service_Assignment__c = testData.theSA.id,
          Target_Date__c = system.today(),
          Effective_Date__c = system.today()-365
        );        
      insert ap; 
        
        apg = new Action_Plan_Goal__c(
          Description__c = 'a goal',
          Action_Plan__c = ap.id,
            sort_order__c = 'g'
        );
        insert apg;
        
        apo = new Action_Plan_Objective__c(
          Action_Plan_Goal__c = apg.id,
          Status__c = 'In Progress',
          Description__c = 'an Objective',
          Type__c = 'skill',
          Target_End_Date__c = system.today(),
          Effective_Date__c = system.today()-365,
            sort_order__c = 'o'
        );
        insert apo;
        
        apa = new Action_Plan_Action__c ();
        apa.Action_Plan_Objective__c = apo.id;
        apa.Description__c = 'action';
        apa.sort_order__c = 'a';
        apa.start_Date__c = system.today()-365;
        apa.End_Date__c = system.today();
        apa.Status__c = 'New';
        insert apa;
        
        pn = TMN_Generic_Core_TestData.createProgressNote(testData.theSA,testData.theAdm,testData.theServiceCode,testData.contactID,DateTime.newInstance(Date.Today(),time.newinstance(0,0,0,0)),DateTime.newInstance(Date.Today(),time.newinstance(0,30,0,0)));
        pn.action_plan__c = ap.id;
        update pn;
        
        ProgressNote_ActionPlanChildren_mjo__c jo = new ProgressNote_ActionPlanChildren_mjo__c(
        	goal__c = apg.id,
            progress_note__c = pn.id
        
        );
        insert jo;
        return ap;   
    } 

}