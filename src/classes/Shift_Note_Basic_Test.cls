@isTest
public class Shift_Note_Basic_Test{
    private static Progress_Note__c pn;
 private static Action_plan__c ap;
    private static Action_plan_Goal__c apg;
    private static Action_plan_Objective__c apo;
    private static Action_plan_Action__c apa;
    
static testMethod void myUnitTest() {
    
    createData();

  ApexPages.StandardController sc = new ApexPages.StandardController(pn);  
    
    Shift_Note_Basic contrl = new Shift_Note_Basic(sc);
  PageReference pageRef = Page.shiftnote_basic_form;
    Test.setCurrentPage(pageRef);
    
    contrl.myEdit();
    contrl.mySave();
    contrl.myFinal();

    pn.Signature_on_File__c = 'Y';
    update pn;
    contrl.myFinal();
    pn.Number_of_Required_Signatures__c = 0;
    pn.Locked__c = false;
    update pn;
    contrl.myFinal();
    contrl.GETallgoals();
    contrl.getchildrenScope();
    contrl.getGoals();
    
    
}
    
     private static Action_Plan__c createData(){
    String RecTypeId= [select Id from RecordType where (DeveloperName='Person_Being_Served') and (SobjectType='Account') Limit 1].Id;
        
        Account Accnt = new Account(
            RecordTypeID=RecTypeId,
            FirstName= 'Test FName',
            LastName='Test LName',
            PersonMailingStreet='test@yahoo.com',
            PersonMailingPostalCode='12345',
            PersonMailingCity='SFO',
            PersonMailingStateCode='NC',
            PersonEmail='test@yahoo.com',
            PersonHomePhone='1234567',
            PersonMobilePhone='12345678'
        );
        insert Accnt; 
        
        Id aContactId = [select PersonContactId from account where id =:accnt.id].PersonContactId;
        Id aAccountId = Accnt.Id;        
    Admission__c Adm = new Admission__c(
            Name = 'TEST ADM',
            Person_Being_Served__c = aContactId,
            Effective_Date__c = date.today(),
            Network_Offering__c = 'ARY'
        );
        insert Adm;     
        
        Service_Assignment__c SA = new Service_Assignment__c(
            admission__c = adm.id,
          Person_Being_Served__c = aContactId
        );        
        insert SA;
        
      ap = new Action_Plan__c(
          Service_Assignment__c = sa.id,
          Target_Date__c = system.today()+365,
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
          Target_End_Date__c = system.today()+365,
          Effective_Date__c = system.today()-365,
            sort_order__c = 'o'
        );
        insert apo;
        
        apa = new Action_Plan_Action__c ();
        apa.Action_Plan_Objective__c = apo.id;
        apa.Description__c = 'action';
        apa.sort_order__c = 'a';
        insert apa;
        
        pn = new progress_Note__c(
         action_plan__c = ap.id,
         Start_Time__c = system.now()-1,
         End_Time__c = system.now(),
            Person_Being_Served__c = aContactId,
            Admission__c = adm.id,
            Service_Assignment__c = sa.id,
            No_Approval_Needed__c = true
         );
         insert pn;
        ProgressNote_ActionPlanChildren_mjo__c jo = new ProgressNote_ActionPlanChildren_mjo__c(
        	goal__c = apg.id,
            progress_note__c = pn.id
        
        );
        insert jo;
        return ap;
        
    }
}