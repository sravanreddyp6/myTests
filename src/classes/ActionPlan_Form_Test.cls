@isTest
public class ActionPlan_Form_Test{
    private static Action_plan__c ap;
    private static Action_plan_Goal__c apg;
    private static Action_plan_Objective__c apo;
    private static Action_plan_Action__c apa;
    
static testMethod void myUnitTest() {
    
    createData();

    ApexPages.StandardController sc = new ApexPages.StandardController(ap);  
    
    ActionPlan_Form contrl = new ActionPlan_Form(sc);
    PageReference pageRef = Page.ActionPlanForm;
    Test.setCurrentPage(pageRef);
    

    
    contrl.addGoal();
    contrl.goalID = 'g'+ apg.id;
    contrl.isparentNew = false;
    contrl.addObj();
    contrl.objID = 'o' + apo.id;
    contrl.addAct();
    contrl.mySave();
    
    Date internaldate = system.today();
    string mydate = internaldate.month() + '/' + internaldate.day() + '/' + internaldate.year();
    contrl.worksheetWeek = mydate;  
    contrl.getuncheckedWeeks();
    contrl.getWeekResults();
    contrl.getBehaviorMonthsAvailable();
    contrl.getBehaviorWorkSheets();
    
    contrl.myFinal();
    contrl.myacknowledge();
    contrl.myClone();
   // contrl.addObj();
   // contrl.addAct();
    boolean canE = contrl.canEditPlan;
    boolean canF = contrl.canFinalize;
    boolean hasDraft = contrl.getHasDraft();
    boolean hasAck = contrl.getHasAcknowledged();
    contrl.createrShiftNote();
    contrl.newBehaviorWorksheet();
    contrl.newWorksheet();
    
   //
    contrl.myCancel();
    
    
}
static testMethod void myCancel() {    
    createData();

    ApexPages.StandardController sc = new ApexPages.StandardController(ap);  
    
    ActionPlan_Form contrl = new ActionPlan_Form(sc);
    PageReference pageRef = Page.ActionPlanForm;
    Test.setCurrentPage(pageRef);    
    contrl.myCancel();    
}
    
    private static Action_Plan__c createData(){
    
    /*
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
        */
        TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
        
        ap = new Action_Plan__c(
            Service_Assignment__c = myData.theSA.id,
            Target_Date__c = myData.theSA.Start_Date__c.addDays(1),
            Effective_Date__c = myData.theSA.start_Date__c
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
            Target_End_Date__c = myData.theSA.Start_Date__c.addDays(1),
            Effective_Date__c = myData.theSA.Start_Date__c,
            sort_order__c = 'o'
        );
        insert apo;
        
        apa = new Action_Plan_Action__c ();
        apa.Action_Plan_Objective__c = apo.id;
        apa.Description__c = 'action';
        apa.sort_order__c = 'a';
        insert apa;
        
        
        
        
        return ap;
        
    }
}