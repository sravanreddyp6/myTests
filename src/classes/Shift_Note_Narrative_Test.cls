@isTest
public class Shift_Note_Narrative_Test{

    
static testMethod void myUnitTest() {

  TMN_Generic_Core_TestData theData = createData();
  
  PageReference pageRef = Page.shiftnote_narrative_form;
   Test.setCurrentPage(pageRef);
   pageRef.getparameters().put('saID', thedata.thesa.id);
   pageRef.getparameters().put('admID', thedata.theadm.id);
   
   Progress_note__c pn = new Progress_Note__c();
   
  	ApexPages.StandardController sc = new ApexPages.StandardController(pn);  
    
  	Shift_Note_Narrative contrl = new Shift_Note_Narrative(sc);
  
    contrl.myEdit();
    system.assert(contrl.editMode);
    system.assert(!contrl.canFinalize);
    system.assertequals(contrl.pastnotes.size(),0);
    contrl.myCancel();
    contrl.myEdit();
    pn.narrative__c = 'CHANGED THE TEXT';
    contrl.mySave();
    
    Progress_note__c newnote = [ select id, narrative__c, signature_on_file__c from progress_note__C where id = :pn.id ];
    system.assertEquals( newnote.narrative__c, pn.narrative__c);
    System.assertEquals(newnote.Signature_on_File__c,'N');
    
    PageReference nextpage = contrl.handle(pn.id, UserInfo.getUserId());
    system.assertEquals(null, nextpage);
    
    newnote = [ select id, narrative__c, signature_on_file__c from progress_note__C where id = :pn.id ];
    System.assertEquals(newnote.Signature_on_File__c,'Y');
    
}
    
     private static TMN_Generic_Core_TestData createData(){
     	
      TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();

        testdata.theadm.state__c = 'CA';
        update testdata.theadm;
        
		return testData;          
    } 

}