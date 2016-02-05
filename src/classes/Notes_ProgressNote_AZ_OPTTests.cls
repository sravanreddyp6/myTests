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
        ID AplanId = createActionPlan(coredata.theSA.Id);
        list<string> GoalSelStrs = createGoalsObjActions(APLanId);
        string goalId,ObjId;
        for(string s:GoalSelStrs){
            if(s!=Null && S!=''){
                if(s.contains('a1A')&& GoalId == Null){
                    GoalId=s;
                }
                else if(s.contains('a1B')){
                    ObjId=s;
                }
            }
        }
        String deselected = goalId + ',' + objId;
        Progress_Note__c p = new Progress_Note__c(start_time__c = system.now().addhours(-1),end_time__c=system.now());
        ApexPages.StandardController sc = new ApexPages.StandardController(p);
        PageReference pageRef = Page.Notes_Progressnote_AZ_OPT;
        Test.setCurrentPageReference(pageRef);
        ApexPages.currentPage().getParameters().put('state', 'AZ');
        ApexPages.currentPage().getParameters().put('person', coredata.contactID);
        ApexPages.currentPage().getParameters().put('ServAssignId', coredata.theSA.ID);
        ApexPages.currentPage().getParameters().put('admission', coredata.theAdm.id);
        ApexPages.currentPage().getParameters().put('plan', AplanId);
        ApexPages.currentPage().getParameters().put('Id', P.id);
        ApexPages.currentPage().getParameters().put('Mode', 'New'); 
        ApexPages.currentPage().getParameters().put('DeselectedKey', deselected); 
        Progress_Note__c pt = new Progress_Note__c(approval_user__c = testuser.id, Number_of_Required_Signatures__c=2, start_time__c = system.now().addMinutes(-72),end_time__c=system.now().addMinutes(-70),Service_Assignment__c =coredata.theSA.ID,Person_Being_Served__c=coredata.contactID,action_plan__c=AplanId);
        insert pt;
        ProgressNote_ActionPlanChildren_mjo__c objectJunction = createJuncObject(goalId,objId,Pt.Id);
        Notes_Progressnote_AZ_OPT objNpncTest = new Notes_Progressnote_AZ_OPT(sc);
        list<progress_note__c> pnote = New list<progress_note__c>();
        pnote.add(pt);
        objNpncTest.loaddata(pt);
        pagereference pr = objnpnctest.saveprogressnote();
        
        objNpncTest.showPopupComp();
        objNpncTest.closepopup();
        objNpncTest.closepopupcomp();
        
        List<Attachment> att = objnpnctest.Attachments;
        system.assertEquals(att.size()<1, true);
        
        Test.startTest();
        try{
            objnpnctest.showpopup();
        }
        catch(exception e){
            system.assertEquals(e.getmessage().contains('A Progress Note cannot be finalized'), true);
        }
        
        pagereference submitForApproval = objnpnctest.SubmitForApp();
        system.assertEquals((string.valueof(submitForApproval)==Null || string.valueof(submitForApproval).contains('Notes_ProgressNote_Create_Flavor_PDF')), true);
        
        list<progress_note__C> Overlappingnotes = objnpnctest.lookForOverLappingNotes(pnote[0].Id);
        system.assertEquals(Overlappingnotes.size()<1, true);
        
        pagereference disregard = objNpncTest.disregardnote();
        system.assertEquals(string.valueof(disregard).contains('Notes_ProgressNote_AddlActions'), true);
        
        pagereference editInline = objNpncTest.editInline();
        system.assertEquals(string.valueof(editInline).contains('Notes_ProgressNote_AZ_OPT'), true);
        
        pagereference cancel = objNpncTest.cancelEditNote();
        system.assertEquals(string.valueof(cancel).contains(ApexPages.currentPage().getParameters().get('ServAssignId')), true);
   
        //With multiple updates getting SOQL 101 because of the triggers.So included all in one.
        try{
        objnpnctest.validateesign();
        }
        catch (exception e){
            system.assertEquals(e.getmessage().contains('You must select a Goal before continuing.'), true);
            system.assertEquals(e.getmessage().contains('You must select a Service Location before continuing.'), true);
            system.assertEquals(e.getmessage().contains('You must select the Type of Contact before continuing.'), true);
            system.assertEquals(e.getmessage().contains('You must select a Service Code before continuing'), true);
            system.assertEquals(e.getmessage().contains('You must populate the Intervention field before continuing'), true);
            system.assertEquals(e.getmessage().contains('You must populate the Notes For Next Visit fie'), true);
            system.assertEquals(e.getmessage().contains('You must populate the Progress field before continuin'), true);
            
        }
    }
      Test.stopTest();
  }  
   static testmethod void testAZ3() {
        User testUser = TMN_Generic_Core_TestData.createUser('ESD General','tuserAZ', 'testuserAZ@tmn.com' + System.currentTimeMillis(), 'TestAZ', 'TestAZ', 'Redwood');
        system.debug('calling permsetassign from simpletests');
        System.runas(new User(Id = UserInfo.getUserId())){
            permsetAssign(new list<String>{'ESD_Notes_Common','ESD_Notes_Clinical_Data_User_Arizona'}, testUser.id);
        }
        Test.startTest();
        system.runas( testUser ) {
            TMN_Generic_Core_TestData coredata = new TMN_Generic_Core_TestData();
            coredata.loadData( 'AZ');
            ID newSLid1 = createServiceLocation( '123456', '123456001', 'New Service Location 1', 1, 'AZ', '1-123456' );
            ID newSLid1a = createServiceLocation( '114165', '114165002', 'New Service Location 1a', 1, 'AZ', '1-123456a' );
            coredata.theSA.service_location__c = newSLid1;
            update coredata.theSA;
            ID AplanId = createActionPlan(coredata.theSA.Id);
            list<string> GoalSelStrs = createGoalsObjActions(APLanId);
            string goalId,ObjId;
            for(string s:GoalSelStrs){
                if(s!=Null && S!=''){
                    if(s.contains('a1A')&& GoalId == Null){
                        GoalId=s;
                    }
                    else if(s.contains('a1B')){
                        ObjId=s;
                    }
                }
            }
            String deselected = goalId + ',' + objId;
            Progress_Note__c pt = new Progress_Note__c(Number_of_Required_Signatures__c=2, start_time__c = system.now().addMinutes(-72),end_time__c=system.now().addMinutes(-70),Service_Assignment__c =coredata.theSA.ID,Person_Being_Served__c=coredata.contactID,action_plan__c=AplanId);
            insert pt;
            Progress_Note__c p = new Progress_Note__c(start_time__c = system.now().addhours(-1),end_time__c=system.now());
            ApexPages.StandardController sc = new ApexPages.StandardController(p);
            PageReference pageRef = Page.Notes_Progressnote_AZ_OPT;
            Test.setCurrentPageReference(pageRef);
            ApexPages.currentPage().getParameters().put('state', 'AZ');
            ApexPages.currentPage().getParameters().put('person', coredata.contactID);
            ApexPages.currentPage().getParameters().put('ServAssignId', coredata.theSA.ID);
            ApexPages.currentPage().getParameters().put('admission', coredata.theAdm.id);
            ApexPages.currentPage().getParameters().put('plan', AplanId);
            ApexPages.currentPage().getParameters().put('Id', pt.id);
            ApexPages.currentPage().getParameters().put('Mode', 'Edit');
            Notes_Progressnote_AZ_OPT objNpncTest12 = new Notes_Progressnote_AZ_OPT(sc);
            objNpncTest12.reformedittree(GoalSelStrs);
            objNpncTest12.retrieveAllGoals();
        }
        Test.stopTest();

    }
    
    static testmethod void testAZ2() {
        User testUser = TMN_Generic_Core_TestData.createUser('ESD General','tuserAZ', 'testuserAZ@tmn.com' + System.currentTimeMillis(), 'TestAZ', 'TestAZ', 'Redwood');
        System.runas(new User(Id = UserInfo.getUserId())){
            permsetAssign(new list<String>{'ESD_Notes_Common','ESD_Notes_Clinical_Data_User_Arizona'}, testUser.id);
        }
        Test.startTest();
        system.runas( testUser ) {
            TMN_Generic_Core_TestData coredata = new TMN_Generic_Core_TestData();
            coredata.loadData( 'AZ');
            ID newSLid1 = createServiceLocation( '123456', '123456001', 'New Service Location 1', 1, 'AZ', '1-123456' );
            ID newSLid1a = createServiceLocation( '114165', '114165002', 'New Service Location 1a', 1, 'AZ', '1-123456a' );
            coredata.theSA.service_location__c = newSLid1;
            update coredata.theSA;
            
            ID AplanId = createActionPlan(coredata.theSA.Id);
            list<string> GoalSelStrs = createGoalsObjActions(APLanId);
            string goalId,ObjId;
            for(string s:GoalSelStrs){
                if(s!=Null && S!=''){
                    if(s.contains('a1A')&& GoalId == Null){
                        GoalId=s;
                    }
                    else if(s.contains('a1B')){
                        ObjId=s;
                    }
                }
            }
            Progress_Note__c pt = new Progress_Note__c(Number_of_Required_Signatures__c=2, start_time__c = system.now().addMinutes(-72),end_time__c=system.now().addMinutes(-70),Service_Assignment__c =coredata.theSA.ID,Person_Being_Served__c=coredata.contactID,action_plan__c=AplanId);
            insert pt;
            Progress_Note__c p = new Progress_Note__c(start_time__c = system.now().addhours(-1),end_time__c=system.now());
            ApexPages.StandardController sc = new ApexPages.StandardController(p);
            PageReference pageRef = Page.Notes_Progressnote_AZ_OPT;
            Test.setCurrentPageReference(pageRef);
            ApexPages.currentPage().getParameters().put('state', 'AZ');
            ApexPages.currentPage().getParameters().put('person', coredata.contactID);
            ApexPages.currentPage().getParameters().put('ServAssignId', coredata.theSA.ID);
            ApexPages.currentPage().getParameters().put('admission', coredata.theAdm.id);
            ApexPages.currentPage().getParameters().put('plan', AplanId);
            ApexPages.currentPage().getParameters().put('Id', pt.id);
            ApexPages.currentPage().getParameters().put('Mode', 'InlineEdit'); 
            Notes_Progressnote_AZ_OPT objNpncTest12 = new Notes_Progressnote_AZ_OPT(sc);
            //objNpncTest12.RenderSelectedIds();
            //pagereference Render = objNpncTest12.RenderSelectedIds();
            //system.assertEquals(string.valueof(Render).contains('Notes_ProgressNote_AZ_OPT'), true);
        }
        Test.stopTest();
    }
    
   static testmethod void testAZ4() {
        User testUser = TMN_Generic_Core_TestData.createUser('ESD General','tuserAZ', 'testuserAZ@tmn.com' + System.currentTimeMillis(), 'TestAZ', 'TestAZ', 'Redwood');
        System.runas(new User(Id = UserInfo.getUserId())){
            permsetAssign(new list<String>{'ESD_Notes_Common','ESD_Notes_Clinical_Data_User_Arizona'}, testUser.id);
        }
       Test.startTest();
        system.runas( testUser ) {
            TMN_Generic_Core_TestData coredata = new TMN_Generic_Core_TestData();
            coredata.loadData( 'AZ');
            ID newSLid1 = createServiceLocation( '123456', '123456001', 'New Service Location 1', 1, 'AZ', '1-123456' );
            ID newSLid1a = createServiceLocation( '114165', '114165002', 'New Service Location 1a', 1, 'AZ', '1-123456a' );
            coredata.theSA.service_location__c = newSLid1;
            update coredata.theSA;
            
            ID AplanId = createActionPlan(coredata.theSA.Id);
            list<string> GoalSelStrs = createGoalsObjActions(APLanId);
            
            string goalId,ObjId;
            for(string s:GoalSelStrs){
                if(s!=Null && S!=''){
                    if(s.contains('a1A')&& GoalId == Null){
                        GoalId=s;
                    }
                    else if(s.contains('a1B')){
                        ObjId=s;
                    }
                }
            }
            String deselected = goalId + ',' + objId;
            Progress_Note__c pt = new Progress_Note__c(Number_of_Required_Signatures__c=2, start_time__c = system.now().addMinutes(-72),end_time__c=system.now().addMinutes(-70), Service_Assignment__c =coredata.theSA.ID,Person_Being_Served__c=coredata.contactID,action_plan__c=AplanId);
            insert pt;
            Progress_Note__c p = new Progress_Note__c(start_time__c = system.now().addhours(-1),end_time__c=system.now(),Sleep_Check_Conducted__c= true,Purpose_Service_is_Billable__c = true);
            ApexPages.StandardController sc = new ApexPages.StandardController(p);
            PageReference pageRef = Page.Notes_Progressnote_AZ_OPT;
            Test.setCurrentPageReference(pageRef);
            ApexPages.currentPage().getParameters().put('state', 'AZ');
            ApexPages.currentPage().getParameters().put('person', coredata.contactID);
            ApexPages.currentPage().getParameters().put('ServAssignId', coredata.theSA.ID);
            ApexPages.currentPage().getParameters().put('admission', coredata.theAdm.id);
            ApexPages.currentPage().getParameters().put('plan', AplanId);
            ApexPages.currentPage().getParameters().put('Id', pt.id);
            ApexPages.currentPage().getParameters().put('DeselectedKey', deselected); 
            ApexPages.currentPage().getParameters().put('Mode', 'InlineEdit'); 
            ProgressNote_ActionPlanChildren_mjo__c objectJunction = createJuncObject(goalId,objId,Pt.Id);
            Notes_Progressnote_AZ_OPT objNpncTest12 = new Notes_Progressnote_AZ_OPT(sc);
            try{
                objNpncTest12.saveProgressNote();
            }
            catch(exception e){
                
            }
        }
       Test.stopTest();
    }
    static ID createActionPlan(id servAssgId) {
        Action_Plan__c Aplan = new Action_Plan__c(Date_Service_Started__c = date.today().adddays(-7),Effective_Date__c = date.today().adddays(-7),status__c = 'Active Final',Service_Assignment__c = servAssgId,target_Date__c =date.today().adddays(17));
        Insert APLAn;
        return APLAn.Id;
    }
    
    static ProgressNote_ActionPlanChildren_mjo__c createJuncObject(string goalId,string ObjID,Id ProgNoteId) {
        ProgressNote_ActionPlanChildren_mjo__c jobj = new ProgressNote_ActionPlanChildren_mjo__c(Progress_Note__c =ProgNoteId,Goal__c = goalid, Objective__c = ObjId);
        Insert jobj;
        return jobj;
    }
    
    static List<String> createGoalsObjActions(id Aplanid) {
        list<string> GoalSelStrs = New List<string>();
        list<Action_Plan_Goal__c> GoalsList = New List<Action_Plan_Goal__c>();
        Action_Plan_Goal__c goal1 = new Action_Plan_Goal__c(Action_Plan__c = AplanId,Description__c= 'test Goal1');
        GoalsList.add(goal1); 
        Action_Plan_Goal__c goal2 = new Action_Plan_Goal__c(Action_Plan__c = AplanId,Description__c= 'test Goal2');
        GoalsList.add(goal2); 
        insert GoalsList;
        GoalSelStrs.add(GoalsList[0].id);
        GoalSelStrs.add(GoalsList[1].id);
        Action_Plan_Objective__c obj1 = new Action_Plan_Objective__c(description__c = 'test obj1',Action_Plan_Goal__c = goal1.id,Effective_Date__c = date.today(),Target_End_Date__c = date.today().adddays(7),status__c = 'New');
        insert obj1;
        GoalSelStrs.add(obj1.id);
        Action_Plan_Action__c Act1 = New Action_Plan_Action__c(Action_Plan_Objective__c = obj1.Id,Description__c = 'test Action1',start_date__c = date.today(),end_date__c = date.today().adddays(3),status__c = 'New');
        insert act1;
        GoalSelStrs.add(act1.id);
        return GoalSelStrs;
    }
        
    static ID createServiceLocation( string alias, string pgmCode, string pgmVal, integer facility, string slState, string uid ) {
        Service_location__c newSL = new Service_location__c( alias__c = alias, programid__c = pgmCode, program__c = pgmVal, facilityid__c = facility, state__c = slState, uniqueid__c = uid);
        insert newSL;
        return newSL.Id;
       }
       
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