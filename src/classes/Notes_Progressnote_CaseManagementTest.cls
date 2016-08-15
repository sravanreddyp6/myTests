@isTest
public with sharing class Notes_Progressnote_CaseManagementTest {
    @testSetup static void testData() {
        User testUser = TMN_Generic_Core_TestData.createUser('ESD General','tUser', 'tUser@tmn.com' + System.currentTimeMillis(), 'CaseManagement', 'Test', 'Redwood');
        System.runas(new User(Id = UserInfo.getUserId())){
            permsetAssign(new list<String>{'ESD_Notes_Common','iServe_Case_Management','ESD_Referrals_Common','ESD_Referrals_Intaker','ESD_Referrals_Intaker_Light'}, testUser.id);
        }
    }
    static testMethod void simpleTests() {
        User u = [Select id from User where FirstName = 'CaseManagement' Limit 1];
        system.runas( u ) {
            TMN_Generic_Core_TestData coredata = new TMN_Generic_Core_TestData();
            coredata.loadData( 'OR');
            ID newSLid1 = createServiceLocation( '123456', '123456001', 'New Service Location 1', 1, 'OR', '1-123456' );
            coredata.theSA.service_location__c = newSLid1;
            update coredata.theSA;
            
            Progress_Note__c p = new Progress_Note__c(start_time__c = system.now().addhours(-1),end_time__c=system.now());
            ApexPages.StandardController sc = new ApexPages.StandardController(p);
            PageReference pageRef = Page.Notes_Progressnote_CaseManagement;
            Test.setCurrentPageReference(pageRef);
            ApexPages.currentPage().getParameters().put('state', 'OR');
            ApexPages.currentPage().getParameters().put('person', coredata.contactID);
            ApexPages.currentPage().getParameters().put('ServAssignId', coredata.theSA.ID);
            ApexPages.currentPage().getParameters().put('admission', coredata.theAdm.id);
            ApexPages.currentPage().getParameters().put('Id', P.id);
            ApexPages.currentPage().getParameters().put('Mode', 'New'); 
            Progress_Note__c pt = new Progress_Note__c(approval_user__c = u.id, Number_of_Required_Signatures__c=2, start_time__c = system.now().addMinutes(-72),end_time__c=system.now().addMinutes(-70),Service_Assignment__c =coredata.theSA.ID,Person_Being_Served__c=coredata.contactID);
            insert pt;
            Notes_ProgressNote_CaseManagementExt objNpncTest = new Notes_ProgressNote_CaseManagementExt(sc);
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
                system.assertEquals(e.getmessage().contains('E-Signature is required before finalizing the note'), true);
            }
            pagereference editInline = objNpncTest.editInline();
            system.assertEquals(string.valueof(editInline).contains('Notes_Progressnote_CaseManagemen'), true);
            pagereference cancel = objNpncTest.cancelEditNote();
            system.assertEquals(string.valueof(cancel).contains(ApexPages.currentPage().getParameters().get('ServAssignId')), true);
            
            //2
            Progress_Note__c pt3 = new Progress_Note__c(Number_of_Required_Signatures__c=2,start_time__c = system.now().addMinutes(-72),end_time__c=system.now().addMinutes(-70),Service_Assignment__c =coredata.theSA.ID,Person_Being_Served__c=coredata.contactID);
            insert pt3;
            Progress_Note__c p3 = new Progress_Note__c(start_time__c = system.now().addhours(-1),end_time__c=system.now());
            ApexPages.StandardController sc3 = new ApexPages.StandardController(p3);
            PageReference pageRef3 = Page.Notes_Progressnote_CaseManagement;
            Test.setCurrentPageReference(pageRef3);
            ApexPages.currentPage().getParameters().put('state', 'OR');
            ApexPages.currentPage().getParameters().put('person', coredata.contactID);
            ApexPages.currentPage().getParameters().put('ServAssignId', coredata.theSA.ID);
            ApexPages.currentPage().getParameters().put('admission', coredata.theAdm.id);
            ApexPages.currentPage().getParameters().put('Id', pt3.id);
            ApexPages.currentPage().getParameters().put('Mode', 'Edit');
            Notes_ProgressNote_CaseManagementExt objNpncTest3 = new Notes_ProgressNote_CaseManagementExt(sc3);
            objNpncTest3.RenderSelectedIds();
            List<recordType> testRecTypeList = objNpncTest3.getmyRTS();
            String SelKys = objNpncTest3.selectedKeys;
            Progress_note__c testPn = objNpncTest3.getthePN();
            try{objNpncTest3.myfinal();}
            catch( exception e){}
            try{objNpncTest3.disregardNote();}
            catch( exception e){}
            
            //3
            Progress_Note__c pt4 = new Progress_Note__c(Number_of_Required_Signatures__c=2, start_time__c = system.now().addMinutes(-72),end_time__c=system.now().addMinutes(-70), Service_Assignment__c =coredata.theSA.ID,Person_Being_Served__c=coredata.contactID,Date_of_Service__c=date.today().adddays(1));
            insert pt4;
            Progress_Note__c p4 = new Progress_Note__c(start_time__c = system.now().addhours(-1),locked__c = true,end_time__c=system.now(),Sleep_Check_Conducted__c= true,Purpose_Service_is_Billable__c = true);
            ApexPages.StandardController sc4 = new ApexPages.StandardController(p4);
            PageReference pageRef4 = Page.Notes_Progressnote_CaseManagement;
            Test.setCurrentPageReference(pageRef4);
            ApexPages.currentPage().getParameters().put('state', 'OR');
            ApexPages.currentPage().getParameters().put('person', coredata.contactID);
            ApexPages.currentPage().getParameters().put('ServAssignId', coredata.theSA.ID);
            ApexPages.currentPage().getParameters().put('admission', coredata.theAdm.id);
            ApexPages.currentPage().getParameters().put('Id', pt4.id);
            ApexPages.currentPage().getParameters().put('Mode', 'InlineEdit'); 
            Notes_ProgressNote_CaseManagementExt objNpncTest4 = new Notes_ProgressNote_CaseManagementExt(sc4);
            try{objNpncTest4.saveProgressNote();}
            catch(exception e){}
            try{objNpncTest4.disregardnote();}
            catch(exception e){}
            
            //4
            Progress_Note__c pt12 = new Progress_Note__c(Number_of_Required_Signatures__c=2,start_time__c = system.now().addMinutes(-72),end_time__c=system.now().addMinutes(-70),Service_Assignment__c =coredata.theSA.ID,Person_Being_Served__c=coredata.contactID);
            insert pt12;
            Progress_Note__c p12 = new Progress_Note__c(start_time__c = system.now().addhours(-1),end_time__c=system.now());
            ApexPages.StandardController sc5 = new ApexPages.StandardController(p12);
            PageReference pageRef5 = Page.Notes_ProgressNote_CaseManagement;
            Test.setCurrentPageReference(pageRef5);
            ApexPages.currentPage().getParameters().put('state', 'OR');
            ApexPages.currentPage().getParameters().put('person', coredata.contactID);
            ApexPages.currentPage().getParameters().put('ServAssignId', coredata.theSA.ID);
            ApexPages.currentPage().getParameters().put('admission', coredata.theAdm.id);
            ApexPages.currentPage().getParameters().put('Id', pt12.id);
            ApexPages.currentPage().getParameters().put('Mode', 'Edit');
            Notes_ProgressNote_CaseManagementExt objNpncTest125 = new Notes_ProgressNote_CaseManagementExt(sc5);
            
            //5
            Progress_Note__c pt15 = new Progress_Note__c(Number_of_Required_Signatures__c=2,Approval_user__c= u.id,start_time__c = system.now().addMinutes(-72),end_time__c=system.now().addMinutes(-70),Service_Assignment__c =coredata.theSA.ID,Person_Being_Served__c=coredata.contactID);
            insert pt15;
            Progress_Note__c p15 = new Progress_Note__c(start_time__c = system.now().addhours(-1),end_time__c=system.now());
            ApexPages.StandardController sc6 = new ApexPages.StandardController(p15);
            PageReference pageRef6 = Page.Notes_ProgressNote_CaseManagement;
            Test.setCurrentPageReference(pageRef6);
            ApexPages.currentPage().getParameters().put('state', 'OR');
            ApexPages.currentPage().getParameters().put('person', coredata.contactID);
            ApexPages.currentPage().getParameters().put('ServAssignId', coredata.theSA.ID);
            ApexPages.currentPage().getParameters().put('admission', coredata.theAdm.id);
            ApexPages.currentPage().getParameters().put('Id', pt15.id);
            ApexPages.currentPage().getParameters().put('Mode', 'Edit');
            Notes_ProgressNote_CaseManagementExt objNpncTest1256 = new Notes_ProgressNote_CaseManagementExt(sc6);
            objNpncTest1256.submitforapp();
            objNpncTest1256.getApprovalHistory();
            string s = objNpncTest1256.personselectedIds;
            string t = objNpncTest1256.srvcLocationName;
            string u1 = objNpncTest1256.HomePageData;
            string v = objNpncTest1256.relatedpbstring;
            string W = objNpncTest1256.searchresultPBS;
            string X = objNpncTest1256.searchresultSA;
            id i = objNpncTest1256.ProcessId;
            boolean b1 = objNpncTest1256.updatePBs;
            boolean b2 = objNpncTest1256.canDisregard;
            boolean b3 = objNpncTest1256.showPBS;
            pt15.status__c = 'Final';
            pt15.approval_status__c = 'Pending';
            update pt15;
            list<progress_note__c> pnt = New List<progress_note__c>();
            pnt.add(pt15);
            objNpncTest1256.validateFinalizeEsign(pnt,'Yes');
            objNpncTest1256.validateesign();
            
            //6
            Progress_Note__c pt1512 = new Progress_Note__c(Number_of_Required_Signatures__c=2,start_time__c = system.now().addMinutes(-72),end_time__c=system.now().addMinutes(-70),Service_Assignment__c =coredata.theSA.ID,Person_Being_Served__c=coredata.contactID);
            insert pt1512;
            Progress_Note__c p2 = new Progress_Note__c(Service_Assignment__c =coredata.theSA.ID,start_time__c =system.now().addhours(1),end_time__c = system.now());
            ApexPages.StandardController sc2 = new ApexPages.StandardController(p2);
            PageReference pageRef2 = Page.Notes_ProgressNote_CaseManagement;
            Test.setCurrentPageReference(pageRef2);
            ApexPages.currentPage().getParameters().put('state', 'OR');
            ApexPages.currentPage().getParameters().put('person', coredata.contactID);
            ApexPages.currentPage().getParameters().put('ServAssignId', coredata.theSA.ID);
            ApexPages.currentPage().getParameters().put('admission', coredata.theAdm.id);
            ApexPages.currentPage().getParameters().put('Mode', 'Inlineedit'); 
            ApexPages.currentPage().getParameters().put('Id', pt1512.id);
            Notes_ProgressNote_CaseManagementExt objNpncTest22 = new Notes_ProgressNote_CaseManagementExt(sc2);
            pagereference pr2 = objnpnctest22.saveprogressnote();
            Notes_ProgressNote_CaseManagementExt objNpncTest231 = new Notes_ProgressNote_CaseManagementExt(sc2);
            objNpncTest231.pn.start_time__c = Null;
            pagereference pr31 = objNpncTest231.saveprogressnote();
            Notes_ProgressNote_CaseManagementExt objNpncTest232 = new Notes_ProgressNote_CaseManagementExt(sc2);
            objNpncTest232.pn.Date_of_Service__c = system.today().adddays(2);
            pagereference pr32 = objNpncTest232.saveprogressnote();
            Notes_ProgressNote_CaseManagementExt objNpncTest23 = new Notes_ProgressNote_CaseManagementExt(sc2);
            objNpncTest23.pn.Narrative__c = Null;
            pagereference pr3 = objNpncTest23.saveprogressnote();
            Notes_ProgressNote_CaseManagementExt objNpncTest23a = new Notes_ProgressNote_CaseManagementExt(sc2);
            objNpncTest23a.pn.start_time__c = system.now().addHours(1);
            pagereference pr32a = objNpncTest23a.saveprogressnote();
            Notes_ProgressNote_CaseManagementExt objNpncTest232d = new Notes_ProgressNote_CaseManagementExt(sc2);
            objNpncTest232d.pn.Purpose_Service_is_Billable__c = True;
            pagereference pr32d = objNpncTest232d.saveprogressnote();
            Notes_ProgressNote_CaseManagementExt objNpncTest233ab = new Notes_ProgressNote_CaseManagementExt(sc2);
            objNpncTest233ab.pn.Approval_user__c = u.id;
            objNpncTest233ab.submitforApp();
        }
        Test.stopTest();
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