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
        for(string gid: contrl.planStuff.keySet()){
            contrl.goalID = gid;
        
        }
        
        
        
        for(ActionPlan_form.clsGoal g: contrl.planStuff.values()){    
            g.theGoal.Description__c = 'goal';             
            for(ActionPlan_form.clsObj o: g.GoalObjs.values()){
                o.theObj.Description__c = 'obj';
                o.theObj.Status__c ='N/A';
                for(ActionPlan_form.clsAction a: o.objActs.values()){
                   a.theAction.Description__c = 'act'; 
                }            
            }        
        }
    
    
   
    
    /*
    contrl.isparentNew = false;    
    contrl.objID = 'o' + apo.id;
    contrl.addObj();
    contrl.addAct();
    */
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
    Clinical_Catalog__c cat = new Clinical_Catalog__c(); 
    cat = createCatalog();
    contrl.curCtlg = cat.id;
    contrl.refreshHere();
    contrl.catalog_selections = '';
    for(tmn_tree.node goal : contrl.allGoals.root.nodes){
        contrl.catalog_selections += goal.key;
        contrl.catalog_selections += ',';
        
        for(tmn_tree.node obj: goal.nodes){
            contrl.catalog_selections += obj.key;
            contrl.catalog_selections += ',';
            
            for(tmn_tree.node act : obj.nodes){
                contrl.catalog_selections += act.key;
                contrl.catalog_selections += ',';
            
            }
        }
    }    
    contrl.addItemsFromTree();

    
    contrl.deleteGid = contrl.goalID;
    contrl.deleteGoal();
    //contrl.deleteObj();
    //contrl.deleteAct();
    
    
    
    contrl.myCancel();
    
    
    
}
/*
static testMethod void myCancel() {    
    createData();

    ApexPages.StandardController sc = new ApexPages.StandardController(ap);  
    
    ActionPlan_Form contrl = new ActionPlan_Form(sc);
    PageReference pageRef = Page.ActionPlanForm;
    Test.setCurrentPage(pageRef);    
    contrl.myCancel();    
}
*/
    
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
    
    private static Clinical_Catalog__c createCatalog(){
        Clinical_Catalog_Element__c goal = new Clinical_Catalog_Element__c();
        Clinical_Catalog_Element__c obj = new Clinical_Catalog_Element__c();
        Clinical_Catalog_Element__c act = new Clinical_Catalog_Element__c();
        Clinical_Catalog_Tree_Node__c g_node = new Clinical_Catalog_Tree_Node__c();
        Clinical_Catalog_Tree_Node__c o_node = new Clinical_Catalog_Tree_Node__c();
        Clinical_Catalog_Tree_Node__c a_node = new Clinical_Catalog_Tree_Node__c();
        Clinical_Catalog__c cata = new Clinical_Catalog__c();
        
        goal.Description__c = 'catalog-goal';
        goal.type__c = 'Goal';
        goal.status__c = 'Active';
        
        obj.Description__c = 'catalog-obj';
        obj.type__c = 'Objective';
        obj.status__c = 'Active';
        act.Description__c = 'catalog-act';
        act.type__c = 'Action';
        act.status__c = 'Active';
        
        
        insert goal;
        insert obj;
        insert act;            
        insert cata;
//        need to get the aut generated name so we need to reselect them from the database
        goal = [select id, name from Clinical_Catalog_Element__c where id = :goal.id];
        obj = [select id, name from Clinical_Catalog_Element__c where id = :obj.id];
        act = [select id, name from Clinical_Catalog_Element__c where id = :act.id];
        system.debug('here - '+ goal);
        
        g_node.Catalog__c = cata.id;
        g_node.Catalog_Element__c = goal.id;
        g_node.ID_Goal__c = integer.valueof(goal.name);
        g_node.ID_Objective__c = 0;
        g_node.ID_Action__c = 0;
        g_node.status__c = 'Active';
        insert g_node;

        o_node.Catalog__c = cata.id;
        o_node.Catalog_Element__c = obj.id;
        o_node.ID_Goal__c = integer.valueof(goal.name);
        o_node.ID_Objective__c = integer.valueof(obj.name);
        o_node.ID_Action__c =0;
        o_node.status__c = 'Active';
        insert o_node;

        a_node.Catalog__c = cata.id;
        a_node.Catalog_Element__c = act.id;
        a_node.ID_Goal__c = integer.valueof(goal.name);
        a_node.ID_Objective__c = integer.valueof(obj.name);
        a_node.ID_Action__c = integer.valueof(act.name);
        a_node.status__c = 'Active';
        insert a_node;                
        
        return cata;
    
    }
    
}