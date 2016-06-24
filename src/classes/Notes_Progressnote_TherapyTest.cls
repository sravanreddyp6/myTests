@isTest
public with sharing class Notes_Progressnote_TherapyTest {
    @testSetup static void testData() {
        User testUser = TMN_Generic_Core_TestData.createUser('ESD General','tUser', 'tUser@tmn.com' + System.currentTimeMillis(), 'Therapy', 'Test', 'NeuroRestorative');
        System.runas(new User(Id = UserInfo.getUserId())){
            permsetAssign(new list<String>{'ESD_Notes_Common','ESD_Notes_Case_Handler_NR_Carbondale','ESD_Notes_Intaker','  ESD_Referrals_Common','ESD_Referrals_Intaker'}, testUser.id);
        }
    }
    static testMethod void simpleTests() {
        User u = [Select id from User where FirstName = 'Therapy' Limit 1];
        
        system.runas( u ) {
            TMN_Generic_Core_TestData coredata = new TMN_Generic_Core_TestData();
            coredata.loadData( 'IL');
            ID newSLid1 = createServiceLocation( '123456', '123456001', 'New Service Location 1', 1, 'IL', '1-123456' );
            ID newSLid1a = createServiceLocation( '114165', '114165002', 'New Service Location 1a', 1, 'IL', '1-123456a' );
            coredata.theSA.service_location__c = newSLid1;
            update coredata.theSA;
            
            Progress_Note__c p = new Progress_Note__c(start_time__c = system.now().addhours(-1),end_time__c=system.now());
            ApexPages.StandardController sc = new ApexPages.StandardController(p);
            PageReference pageRef = Page.Notes_Progressnote_Therapy;
            Test.setCurrentPageReference(pageRef);
            ApexPages.currentPage().getParameters().put('state', 'IL');
            ApexPages.currentPage().getParameters().put('person', coredata.contactID);
            ApexPages.currentPage().getParameters().put('ServAssignId', coredata.theSA.ID);
            ApexPages.currentPage().getParameters().put('admission', coredata.theAdm.id);
            ApexPages.currentPage().getParameters().put('Id', P.id);
            ApexPages.currentPage().getParameters().put('Mode', 'New'); 
            Progress_Note__c pt = new Progress_Note__c(approval_user__c = u.id, Number_of_Required_Signatures__c=2, start_time__c = system.now().addMinutes(-72),end_time__c=system.now().addMinutes(-70),Service_Assignment__c =coredata.theSA.ID,Person_Being_Served__c=coredata.contactID);
            insert pt;
            Notes_ProgressNote_Therapyext objNpncTest = new Notes_ProgressNote_Therapyext(sc);
            list<progress_note__c> pnote = New list<progress_note__c>();
            pnote.add(pt);
            objNpncTest.loaddata(pt);
            pagereference pr = objnpnctest.saveprogressnote();
            objNpncTest.showPopupComp();
            objNpncTest.closepopup();
            objNpncTest.closepopupcomp();
            objNpncTest.popTherapist();
            objNpncTest.popDiscipline();
            objNpncTest.lookForOverLappingNotes(pt);
            Notes_ProgressNote_Therapyext.getPBS('{"q":"test","loc":"' + newSLid1 + '","curSA":"' + coredata.theSA.ID + '"}');
            List<Attachment> att = objnpnctest.Attachments;
            system.assertEquals(att.size()<1, true);
            Test.startTest();
            try{
                objnpnctest.showpopup();
            }
            catch(exception e){
                system.assertEquals(e.getmessage().contains('A Progress Note cannot be finalized'), true);
            }
            pagereference editInline = objNpncTest.editInline();
            system.assertEquals(string.valueof(editInline).contains('Notes_Progressnote_Therapy'), true);
            pagereference cancel = objNpncTest.cancelEditNote();
            system.assertEquals(string.valueof(cancel).contains(ApexPages.currentPage().getParameters().get('ServAssignId')), true);
            //2
            
            //3
            Progress_Note__c pt3 = new Progress_Note__c(Number_of_Required_Signatures__c=2,Type__c ='Group',Related_note_IDs__c= pt.id+',',start_time__c = system.now().addMinutes(-72),end_time__c=system.now().addMinutes(-70),Service_Assignment__c =coredata.theSA.ID,Person_Being_Served__c=coredata.contactID);
            insert pt3;//Related_Person_Being_Served__c= coredata.theSA.ID + ','
            Progress_Note__c p3 = new Progress_Note__c(start_time__c = system.now().addhours(-1),end_time__c=system.now());
            ApexPages.StandardController sc3 = new ApexPages.StandardController(p3);
            PageReference pageRef3 = Page.Notes_Progressnote_Therapy;
            Test.setCurrentPageReference(pageRef3);
            ApexPages.currentPage().getParameters().put('state', 'IL');
            ApexPages.currentPage().getParameters().put('person', coredata.contactID);
            ApexPages.currentPage().getParameters().put('ServAssignId', coredata.theSA.ID);
            ApexPages.currentPage().getParameters().put('admission', coredata.theAdm.id);
            ApexPages.currentPage().getParameters().put('Id', pt3.id);
            ApexPages.currentPage().getParameters().put('Mode', 'Edit');
            ApexPages.currentPage().getParameters().put('UpdateAll', 'Yes');
            Notes_ProgressNote_Therapyext objNpncTest3 = new Notes_ProgressNote_Therapyext(sc3);
            objNpncTest3.RenderSelectedIds();
            objNpncTest3.getPBSforselect();
            objNpncTest3.submitforapp();
            try{
            objNpncTest3.myFinal();}
            catch(exception e){
            }
            id testId = objNpncTest3.Thrapyid;
            List<recordType> testRecTypeList = objNpncTest3.getmyRTS();
            String SelKys = objNpncTest3.selectedKeys;
            Progress_note__c testPn = objNpncTest3.getthePN();
            try{
                objNpncTest3.myfinal();
            }
            catch( exception e){}
            try{
                objNpncTest3.disregardNote();
            }
            catch( exception e){}
            objNpncTest3.saveprogressnote();
            //4
            Progress_Note__c pt4 = new Progress_Note__c(Number_of_Required_Signatures__c=2, start_time__c = system.now().addMinutes(-72),end_time__c=system.now().addMinutes(-70), Service_Assignment__c =coredata.theSA.ID,Person_Being_Served__c=coredata.contactID,Date_of_Service__c=date.today().adddays(1));
            insert pt4;
            Progress_Note__c p4 = new Progress_Note__c(start_time__c = system.now().addhours(-1),locked__c = true,end_time__c=system.now(),Sleep_Check_Conducted__c= true,Purpose_Service_is_Billable__c = true);
            ApexPages.StandardController sc4 = new ApexPages.StandardController(p4);
            PageReference pageRef4 = Page.Notes_Progressnote_Therapy;
            Test.setCurrentPageReference(pageRef4);
            ApexPages.currentPage().getParameters().put('state', 'IL');
            ApexPages.currentPage().getParameters().put('person', coredata.contactID);
            ApexPages.currentPage().getParameters().put('ServAssignId', coredata.theSA.ID);
            ApexPages.currentPage().getParameters().put('admission', coredata.theAdm.id);
            ApexPages.currentPage().getParameters().put('Id', pt4.id);
            ApexPages.currentPage().getParameters().put('Mode', 'InlineEdit'); 
            Notes_ProgressNote_Therapyext objNpncTest4 = new Notes_ProgressNote_Therapyext(sc4);
            try{
                objNpncTest4.saveProgressNote();
            }
            catch(exception e){}
            try{
                objNpncTest4.disregardnote();
            }
            catch(exception e){}
            
            Progress_Note__c pt12 = new Progress_Note__c(Number_of_Required_Signatures__c=2,Type__c ='Group',Related_note_IDs__c= pt.id+',',Related_Person_Being_Served__c= coredata.theSA.ID + ',',start_time__c = system.now().addMinutes(-72),end_time__c=system.now().addMinutes(-70),Service_Assignment__c =coredata.theSA.ID,Person_Being_Served__c=coredata.contactID);
            insert pt12;//Related_Person_Being_Served__c= coredata.theSA.ID + ','
            Progress_Note__c p12 = new Progress_Note__c(start_time__c = system.now().addhours(-1),end_time__c=system.now());
            ApexPages.StandardController sc5 = new ApexPages.StandardController(p12);
            PageReference pageRef5 = Page.Notes_Progressnote_Therapy;
            Test.setCurrentPageReference(pageRef5);
            ApexPages.currentPage().getParameters().put('state', 'IL');
            ApexPages.currentPage().getParameters().put('person', coredata.contactID);
            ApexPages.currentPage().getParameters().put('ServAssignId', coredata.theSA.ID);
            ApexPages.currentPage().getParameters().put('admission', coredata.theAdm.id);
            ApexPages.currentPage().getParameters().put('Id', pt12.id);
            ApexPages.currentPage().getParameters().put('Mode', 'Edit');
            ApexPages.currentPage().getParameters().put('UpdateAll', 'Yes');
            Notes_ProgressNote_Therapyext objNpncTest125 = new Notes_ProgressNote_Therapyext(sc5);
            try{
                objNpncTest125.submitforapp();
            }
            catch( exception e){}
            Progress_Note__c pt15 = new Progress_Note__c(Number_of_Required_Signatures__c=2,Type__c ='Group', Related_note_IDs__c= pt.id+',',Related_Person_Being_Served__c= coredata.theSA.ID + ',',start_time__c = system.now().addMinutes(-72),end_time__c=system.now().addMinutes(-70),Service_Assignment__c =coredata.theSA.ID,Person_Being_Served__c=coredata.contactID);
            insert pt15;//Related_Person_Being_Served__c= coredata.theSA.ID + ','
            Progress_Note__c p15 = new Progress_Note__c(start_time__c = system.now().addhours(-1),end_time__c=system.now());
            ApexPages.StandardController sc6 = new ApexPages.StandardController(p12);
            PageReference pageRef6 = Page.Notes_Progressnote_Therapy;
            Test.setCurrentPageReference(pageRef6);
            ApexPages.currentPage().getParameters().put('state', 'IL');
            ApexPages.currentPage().getParameters().put('person', coredata.contactID);
            ApexPages.currentPage().getParameters().put('ServAssignId', coredata.theSA.ID);
            ApexPages.currentPage().getParameters().put('admission', coredata.theAdm.id);
            ApexPages.currentPage().getParameters().put('Id', pt15.id);
            ApexPages.currentPage().getParameters().put('Mode', 'Edit');
            ApexPages.currentPage().getParameters().put('UpdateAll', 'No');
            Notes_ProgressNote_Therapyext objNpncTest1256 = new Notes_ProgressNote_Therapyext(sc6);
            objNpncTest1256.submitforapp();
            objNpncTest1256.userupdatedpbs();
            objNpncTest1256.getApprovalHistory();
            objNpncTest1256.validateEachnote(pt15,coredata.theSA);
            
            
            
        }
        Test.stopTest();
    } 
    static testMethod void simpleTests2() {
    User u = [Select id from User where FirstName = 'Therapy' Limit 1];
        
        system.runas( u ) {
            TMN_Generic_Core_TestData coredata = new TMN_Generic_Core_TestData();
            coredata.loadData( 'IL');
            ID newSLid1 = createServiceLocation( '123456', '123456001', 'New Service Location 1', 1, 'IL', '1-123456' );
            ID newSLid1a = createServiceLocation( '114165', '114165002', 'New Service Location 1a', 1, 'IL', '1-123456a' );
            coredata.theSA.service_location__c = newSLid1;
            update coredata.theSA;
        Progress_Note__c pt1512 = new Progress_Note__c(Number_of_Required_Signatures__c=2,Type__c ='Group',Related_Person_Being_Served__c= coredata.theSA.ID + ',',start_time__c = system.now().addMinutes(-72),end_time__c=system.now().addMinutes(-70),Service_Assignment__c =coredata.theSA.ID,Person_Being_Served__c=coredata.contactID);
            insert pt1512;
            Progress_Note__c p2 = new Progress_Note__c(Service_Assignment__c =coredata.theSA.ID,start_time__c =system.now().addhours(1),end_time__c = system.now());
            ApexPages.StandardController sc2 = new ApexPages.StandardController(p2);
            PageReference pageRef2 = Page.Notes_Progressnote_Therapy;
            Test.setCurrentPageReference(pageRef2);
            ApexPages.currentPage().getParameters().put('state', 'IL');
            ApexPages.currentPage().getParameters().put('person', coredata.contactID);
            ApexPages.currentPage().getParameters().put('ServAssignId', coredata.theSA.ID);
            ApexPages.currentPage().getParameters().put('admission', coredata.theAdm.id);
            ApexPages.currentPage().getParameters().put('Mode', 'Inlineedit'); 
            ApexPages.currentPage().getParameters().put('Id', pt1512.id);
            Notes_ProgressNote_Therapyext objNpncTest22 = new Notes_ProgressNote_Therapyext(sc2);
            pagereference pr2 = objnpnctest22.saveprogressnote();
            
            Notes_ProgressNote_Therapyext objNpncTest23 = new Notes_ProgressNote_Therapyext(sc2);
            objNpncTest23.pn.start_time__c = system.now();
            objNpncTest23.pn.end_time__c = system.now();
            pagereference pr3 = objNpncTest23.saveprogressnote();
            
            Notes_ProgressNote_Therapyext objNpncTest231 = new Notes_ProgressNote_Therapyext(sc2);
            objNpncTest231.pn.start_time__c = Null;
            objNpncTest231.pn.end_time__c = system.now();
            pagereference pr31 = objNpncTest231.saveprogressnote();
            
            Test.startTest();
            Notes_ProgressNote_Therapyext objNpncTest232 = new Notes_ProgressNote_Therapyext(sc2);
            objNpncTest232.pn.Date_of_Service__c = system.today().adddays(2);
            pagereference pr32 = objNpncTest232.saveprogressnote();
            
            Notes_ProgressNote_Therapyext objNpncTest23a = new Notes_ProgressNote_Therapyext(sc2);
            objNpncTest23a.pn.start_time__c = system.now().addHours(1);
            objNpncTest23a.pn.end_time__c = system.now().addHours(2);
            pagereference pr32a = objNpncTest23a.saveprogressnote();
            
            Notes_ProgressNote_Therapyext objNpncTest232b = new Notes_ProgressNote_Therapyext(sc2);
            objNpncTest232b.pn.start_time__c = system.now().addHours(1);
            pagereference pr32b = objNpncTest232b.saveprogressnote();
            
            Notes_ProgressNote_Therapyext objNpncTest232c = new Notes_ProgressNote_Therapyext(sc2);
            objNpncTest232c.pn.start_time__c = system.now().addHours(-5);
            objNpncTest232c.pn.end_time__c = system.now().addHours(-2);
            pagereference pr32c = objNpncTest232c.saveprogressnote();
            
            Notes_ProgressNote_Therapyext objNpncTest232d = new Notes_ProgressNote_Therapyext(sc2);
            //objNpncTest232c.pn.id = Null;
            objNpncTest232d.pn.Purpose_Service_is_Billable__c = True;
            pagereference pr32d = objNpncTest232d.saveprogressnote();
            
            
            Notes_ProgressNote_Therapyext objNpncTest232e = new Notes_ProgressNote_Therapyext(sc2);
            pagereference pr32e = objNpncTest232e.RenderSelectedIds();
            Test.stopTest();
    }
    
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