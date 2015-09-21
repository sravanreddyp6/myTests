@isTest
public with sharing class Notes_ProgressNote_AZ_OPTTests {
	
	
  static testMethod void simpleTests() {
  	
  	 	
		User testUser = TMN_Generic_Core_TestData.createUser('ESD General','tuserAZ', 'testuserAZ@tmn.com' + System.currentTimeMillis(), 'TestAZ', 'TestAZ', 'Redwood');
		
		system.debug('calling permsetassign from simpletests');
		System.runas(new User(Id = UserInfo.getUserId())){
        	permsetAssign(new list<String>{'ESD_Notes_Common','ESD_Notes_Clinical_Data_User_Arizona'}, testUser.id);
		}
		
        system.runas( testUser ) {
      
       	TMN_Generic_Core_TestData coredata = new TMN_Generic_Core_TestData();
  	 
        coredata.loadData( 'AZ');
        
        ID newSLid1 = createServiceLocation( '123456', '123456001', 'New Service Location 1', 1, 'AZ', '1-123456' );
        ID newSLid1a = createServiceLocation( '114165', '114165002', 'New Service Location 1a', 1, 'AZ', '1-123456a' );
        coredata.theSA.service_location__c = newSLid1;
        update coredata.theSA;

		Action_Plan__c Aplan = new Action_Plan__c();
        Aplan.Date_Service_Started__c = date.today().adddays(-7);
        Aplan.Effective_Date__c = date.today().adddays(-7);
        Aplan.status__c = 'Active Final';
        Aplan.Service_Assignment__c = coredata.theSA.Id;
        Aplan.target_Date__c =date.today().adddays(17);
        Insert APLAn;
        
        
        Action_Plan_Goal__c goal1 = new Action_Plan_Goal__c();
        goal1.Action_Plan__c = APLAn.id;
        goal1.Description__c= 'test Goal1';
        insert goal1; 
        
        Action_Plan_Goal__c goal2 = new Action_Plan_Goal__c();
        goal2.Action_Plan__c = APLAn.Id;
        goal2.Description__c= 'test Goal2';
        insert goal2; 
        
        
        Action_Plan_Objective__c obj1 = new Action_Plan_Objective__c();
        obj1.description__c = 'test obj1';
        obj1.Action_Plan_Goal__c = goal1.id;
        obj1.Effective_Date__c = date.today();
        obj1.Target_End_Date__c = date.today().adddays(7);
        obj1.status__c = 'New';
        insert obj1;
        
        Action_Plan_Action__c Act1 = New Action_Plan_Action__c();
        Act1.Action_Plan_Objective__c = obj1.Id;
        Act1.Description__c = 'test Action1';
        Act1.start_date__c = date.today();
        act1.end_date__c = date.today().adddays(3);
        act1.status__c = 'New';
        insert act1;
        
        
        Progress_Note__c p = new Progress_Note__c(start_time__c = system.now().addhours(-1),end_time__c=system.now());

        ApexPages.StandardController sc = new ApexPages.StandardController(p);

        PageReference pageRef = Page.Notes_Progressnote_AZ_OPT;
        Test.setCurrentPageReference(pageRef);
        ApexPages.currentPage().getParameters().put('state', 'AZ');
        ApexPages.currentPage().getParameters().put('person', coredata.contactID);
        ApexPages.currentPage().getParameters().put('ServAssignId', coredata.theSA.ID);
        ApexPages.currentPage().getParameters().put('admission', coredata.theAdm.id);
        ApexPages.currentPage().getParameters().put('plan', Aplan.Id);
        ApexPages.currentPage().getParameters().put('Id', P.id);
        ApexPages.currentPage().getParameters().put('Mode', 'New'); 
        
        
        Progress_Note__c pt = new Progress_Note__c(start_time__c = system.now().addhours(-1),end_time__c=system.now(),Service_Assignment__c =coredata.theSA.ID,Person_Being_Served__c=coredata.contactID,action_plan__c=Aplan.Id);
        insert pt;
        
        Notes_Progressnote_AZ_OPT objNpncTest = new Notes_Progressnote_AZ_OPT(sc);
        
        list<progress_note__c> pnote = New list<progress_note__c>();
        pnote.add(pt);
        objNpncTest.loaddata(pt);

        testAZ1( objNpncTest, pnote );
        testAZ2( objNpncTest );
        /*
        sc = new ApexPages.StandardController(pt);
        
        ApexPages.currentPage().getParameters().put('Mode', 'Inlineedit'); 
        ApexPages.currentPage().getParameters().put('GoalsSelected', goal1.id);
        ApexPages.currentPage().getParameters().put('Id', Pt.id);
        Notes_Progressnote_AZ_OPT objNpncTest2 = new Notes_Progressnote_AZ_OPT(sc);
        testAZ3( objNpncTest2, goal1, goal2, obj1, pnote );
        
        ApexPages.currentPage().getParameters().put('Mode', 'Edit'); 
        
        Notes_Progressnote_AZ_OPT objNpncTest3 = new Notes_Progressnote_AZ_OPT(sc);
        //testAZ3( objNpncTest3, goal1, goal2, obj1, pnote );
        */
        }
        
        
        
  }
  
   static void testAZ1( Notes_Progressnote_AZ_OPT objnpnctest, List<Progress_Note__c> pnote  ) {     
        try{
            objnpnctest.renderselectedIds();
            objnpnctest.SubmitForApp();
            objNpncTest.validateFinalizeEsign(pnote,'NoGoal');
            objnpnctest.validateesign();
            objnpnctest.showpopup();
            objnpnctest.saveprogressnote();
            
           List<Attachment> att = objnpnctest.Attachments;
        }
        catch(exception e){
        }
        objNpncTest.showPopupComp();
        objNpncTest.editInline();
        objNpncTest.closepopup();
        objNpncTest.closepopupcomp();
        objNpncTest.cancelEditNote();
        objNpncTest.disregardnote();
      
   }
      
    
	 static void testAZ2( Notes_Progressnote_AZ_OPT objnpnctest  ) {
      
       
        try{
            objnpnctest.saveprogressnote();
        }
        catch(exception e){
        }
        
   }
     
    
    static void testAZ3(Notes_Progressnote_AZ_OPT objnpnctest, Action_Plan_Goal__c goal1, Action_Plan_Goal__c goal2, Action_Plan_Objective__c obj1, List<Progress_Note__c> pnote ) {
        
        
        List<string> GoalAndObj = New List<String>();
        goalAndObj.add(goal1.id);
        goalAndObj.add(goal2.id);
        goalAndObj.add(obj1.id);
        
        try{
            objnpnctest.saveProgressNoteInlineEdit();
        }
        catch(exception e){
        }
    }
     
    
      
      
      static void testAZ4 (Notes_Progressnote_AZ_OPT objnpnctest, Action_Plan_Goal__c goal1, Action_Plan_Goal__c goal2, Action_Plan_Objective__c obj1, List<Progress_Note__c> pnote ) {
      
        
        List<string> GoalAndObj = New List<String>();
        goalAndObj.add(goal1.id);
        goalAndObj.add(goal2.id);
        goalAndObj.add(obj1.id);
        
 		
        try{
            objnpnctest.savemodifiedprogressnote();
        }
        catch(exception e){
        }
        }
      
    
      
        
    static ID createServiceLocation( string alias, string pgmCode, string pgmVal, integer facility, string slState, string uid ) {
        
        Service_location__c newSL = new Service_location__c( alias__c = alias, programid__c = pgmCode, program__c = pgmVal, facilityid__c = facility, state__c = slState, uniqueid__c = uid);
        insert newSL;
        
        return newSL.Id;
       }
    
   		//@future
       static void permsetAssign(string[]permSets, Id assigntoId){
       	system.debug('calling permsetassign');
		List<PermissionSet> theSets = [SELECT ID, Name FROM PermissionSet WHERE Name IN :permSets];
		List<PermissionSetAssignment> thepermAssigns = new List<PermissionSetAssignment>();
		for(PermissionSet ps : theSets){
			thepermAssigns.add(new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = assigntoId));

		}
		insert thepermAssigns;

	}
	
}