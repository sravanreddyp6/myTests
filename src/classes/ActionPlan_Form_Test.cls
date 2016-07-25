@isTest
private class ActionPlan_Form_Test{
    private static Action_plan_Goal__c apg;
    private static Action_plan_Objective__c apo;
    private static Action_plan_Action__c apa;
    private static Clinical_Catalog__c cat;
	private TMN_Generic_Core_TestData mydata;    
    
static testmethod void myUnitTest() {
    
    Action_Plan__c ap = [ select id, 
							Service_Assignment__r.Service_location__r.ProgramID__c, 
            				Service_Assignment__r.Flavor__c,
            				Service_Assignment__r.Service_Location__r.Network_offering__c,
            				Service_Assignment__r.Service_Location__r.Alias_Lookup__r.Alias_Operating_Group__c,
            				Service_Assignment__r.Service_Location__r.state__c,
            				Service_assignment__c,
            				Service_Assignment__r.Service_Location__r.Service_Value__c,
            				status__c,
            				effective_date__c,
            				target_date__c,
            				service_assignment__r.admission__c
     					from Action_plan__c 
     					where Service_Assignment__r.admission__r.state__c = 'AZ' LIMIT 1];

    ApexPages.StandardController sc = new ApexPages.StandardController(ap);  
	
    ActionPlan_Form contrl = new ActionPlan_Form(sc);
    system.assertEquals( false, contrl.showISP );
    system.assertEquals( false, contrl.showAck );
    
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
    
    contrl.mySave();
}

static testmethod void testWorksheets() {
    
    Action_Plan__c ap = [ select id, 
							Service_Assignment__r.Service_location__r.ProgramID__c, 
            				Service_Assignment__r.Flavor__c,
            				Service_Assignment__r.Service_Location__r.Network_offering__c,
            				Service_Assignment__r.Service_Location__r.Alias_Lookup__r.Alias_Operating_Group__c,
            				Service_Assignment__r.Service_Location__r.state__c,
            				Service_assignment__c,
            				Service_Assignment__r.Service_Location__r.Service_Value__c,
            				status__c,
            				effective_date__c,
            				target_date__c,
            				service_assignment__r.admission__c
     					from Action_plan__c 
     					where Service_Assignment__r.admission__r.state__c = 'AZ' LIMIT 1];

    ApexPages.StandardController sc = new ApexPages.StandardController(ap);  
	
    ActionPlan_Form contrl = new ActionPlan_Form(sc);

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

    boolean canE = contrl.canEditPlan;
    boolean canF = contrl.canFinalize;
    boolean hasDraft = contrl.getHasDraft();
    boolean hasAck = contrl.getHasAcknowledged();
    contrl.createrShiftNote();
    contrl.newBehaviorWorksheet();
    contrl.newWorksheet();
    
   //
}
static testmethod void testCatalog() {
    
    Action_Plan__c ap = [ select id, 
							Service_Assignment__r.Service_location__r.ProgramID__c, 
            				Service_Assignment__r.Flavor__c,
            				Service_Assignment__r.Service_Location__r.Network_offering__c,
            				Service_Assignment__r.Service_Location__r.Alias_Lookup__r.Alias_Operating_Group__c,
            				Service_Assignment__r.Service_Location__r.state__c,
            				Service_assignment__c,
            				Service_Assignment__r.Service_Location__r.Service_Value__c,
            				status__c,
            				effective_date__c,
            				target_date__c,
            				service_assignment__r.admission__c
     					from Action_plan__c 
     					where Service_Assignment__r.admission__r.state__c = 'AZ' LIMIT 1];

    ApexPages.StandardController sc = new ApexPages.StandardController(ap);  
	
    ActionPlan_Form contrl = new ActionPlan_Form(sc);
     
    createCatalog();
    contrl.curCtlg = cat.id;
    contrl.refreshSelectedCatalog();
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
    contrl.addItemsFromCatalog();

    contrl.myCancel();
    
}

@istest 
static void testServices() {

    Action_Plan__c ap = [ select id, 
							Service_Assignment__r.Service_location__r.ProgramID__c, 
            				Service_Assignment__r.Flavor__c,
            				Service_Assignment__r.Service_Location__r.Network_offering__c,
            				Service_Assignment__r.Service_Location__r.Alias_Lookup__r.Alias_Operating_Group__c,
            				Service_Assignment__r.Service_Location__r.state__c,
            				Service_assignment__c,
            				Service_Assignment__r.Service_Location__r.Service_Value__c,
            				status__c
     					from Action_plan__c 
     					where Service_Assignment__r.admission__r.state__c = 'AZ' LIMIT 1];


	ApexPages.StandardController sc = new ApexPages.StandardController(ap);  
    ActionPlan_Form contrl = new ActionPlan_Form(sc);
    
    PageReference pageRef = Page.ActionPlanForm;
    Test.setCurrentPage(pageRef);
    
	// goal is automatically added, so remove it
	for(string gid: contrl.planStuff.keySet()){
		contrl.deleteGid = gid;
    	contrl.deleteGoal();
    }
    
    system.assertEquals( false, contrl.hasServices); 
	contrl.addService();
	
    for(ActionPlan_form.clsGoal g: contrl.planStuff.values()){
    	system.assertEquals( 'Services', g.theGoal.Description__c);
    	system.assertEquals( true, g.theGoal.isService__c);
    	    
       for(ActionPlan_form.clsObj o: g.GoalObjs.values()){
            o.theObj.Description__c = 'Services obj';
            o.theObj.Status__c ='New';
            o.theObj.type__c = 'Yes/No';
        }        
    }
    
    contrl.mySave();
	system.AssertEquals( true, contrl.hasServices) ;


}


@istest
static void testISP() {
	
	Action_Plan__c ap2 = [ select id,
							Service_Assignment__r.Service_location__r.ProgramID__c, 
            				Service_Assignment__r.Flavor__c,
            				Service_Assignment__r.Service_Location__r.Network_offering__c,
            				Service_Assignment__r.Service_Location__r.Alias_Lookup__r.Alias_Operating_Group__c,
            				Service_Assignment__r.Service_Location__r.state__c,
            				Service_assignment__c,
            				Service_Assignment__r.Service_Location__r.Service_Value__c,
            				status__c
     from Action_Plan__c where service_assignment__r.service_location__r.state__c = 'OH' LIMIT 1];
	ApexPages.StandardController sc = new ApexPages.StandardController(ap2);  
    ActionPlan_Form contrl = new ActionPlan_Form(sc);
    
    system.assertEquals( true, contrl.showISP );
    system.assertEquals( true, contrl.gethasAcknowledgedISP() );	// this will be true until there's an unacknowledged one 

	// add ISP attachment
	Attachment a = new Attachment( Name='ISP-Test', Description='ISP Test', Body=Blob.valueOf('ISP Test'), parentid = ap2.id);
	insert a;
	
	contrl = new ActionPlan_form(sc); // refresh the controller
	
	system.assertEquals( 0, contrl.getISPAcks().size());
	
	// now there's an ISP attachment that needs to be ack-ed
	system.assertEquals( false, contrl.gethasAcknowledgedISP());
	
	contrl.myacknowledgeISP();
	system.assertEquals( 1, contrl.getISPAcks().size());
	system.assertEquals( true, contrl.gethasAcknowledgedISP());
}    

@testsetup
static void createData(){
    	
    	TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
        
        Action_Plan__c ap = new Action_Plan__c(
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
            Type__c = 'Skill',
            Target_End_Date__c = myData.theSA.Start_Date__c.addDays(1),
            Effective_Date__c = myData.theSA.Start_Date__c,
            sort_order__c = 'o'
        );
        insert apo;
        
        apa = new Action_Plan_Action__c ();
        apa.Action_Plan_Objective__c = apo.id;
        apa.Description__c = 'action';
        apa.sort_order__c = 'a';
        apa.Start_Date__c = myData.theSA.Start_Date__c;
        apa.End_Date__c = myData.theSA.Start_Date__c.addDays(1);
        apa.Status__c = 'New';
        insert apa;
    }

	@testsetup    
    private static void createCatalog(){
        Clinical_Catalog_Element__c goal = new Clinical_Catalog_Element__c();
        Clinical_Catalog_Element__c obj = new Clinical_Catalog_Element__c();
        Clinical_Catalog_Element__c act = new Clinical_Catalog_Element__c();
        Clinical_Catalog_Tree_Node__c g_node = new Clinical_Catalog_Tree_Node__c();
        Clinical_Catalog_Tree_Node__c o_node = new Clinical_Catalog_Tree_Node__c();
        Clinical_Catalog_Tree_Node__c a_node = new Clinical_Catalog_Tree_Node__c();
        cat = new Clinical_Catalog__c();
        
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
        insert cat;
//        need to get the aut generated name so we need to reselect them from the database
        goal = [select id, name from Clinical_Catalog_Element__c where id = :goal.id];
        obj = [select id, name from Clinical_Catalog_Element__c where id = :obj.id];
        act = [select id, name from Clinical_Catalog_Element__c where id = :act.id];
        system.debug('here - '+ goal);
        
        g_node.Catalog__c = cat.id;
        g_node.Catalog_Element__c = goal.id;
        g_node.ID_Goal__c = integer.valueof(goal.name);
        g_node.ID_Objective__c = 0;
        g_node.ID_Action__c = 0;
        g_node.status__c = 'Active';
        insert g_node;

        o_node.Catalog__c = cat.id;
        o_node.Catalog_Element__c = obj.id;
        o_node.ID_Goal__c = integer.valueof(goal.name);
        o_node.ID_Objective__c = integer.valueof(obj.name);
        o_node.ID_Action__c =0;
        o_node.status__c = 'Active';
        insert o_node;

        a_node.Catalog__c = cat.id;
        a_node.Catalog_Element__c = act.id;
        a_node.ID_Goal__c = integer.valueof(goal.name);
        a_node.ID_Objective__c = integer.valueof(obj.name);
        a_node.ID_Action__c = integer.valueof(act.name);
        a_node.status__c = 'Active';
        insert a_node;                
        
    }
    
    
    
    // test method to test specific creation of OH IDD so the ISP flags are tripped
    @testsetup
    static void createISPData(){
    
        TMN_Generic_Core_TestData myDataISP = new TMN_Generic_Core_TestData();
        
        // create an OH IDD service location
        Alias__c alOH = new Alias__c( alias_parent__c = '987650', alias_region__c = 'region', alias_service_line__c = 'IDD', alias_operating_group__c = 'Redwood', alias_state__c = 'OH', alias_unique__c = '987654', name='987654');
        insert alOH;
        
        Service_Location__c ohIDD = new Service_Location__c( state__c = 'OH', tmn_scope__c = 'Residential', network_offering__c = 'IDD', alias_lookup__c = alOH.id, alias__c = '987654', facilityid__c = 16, programid__c = '987654001', program__c = 'OH-ServiceLocation', uniqueid__c = '16||987654001');
        insert ohIDD;
        
        myDataISP.theSA.service_location__c = ohIDD.id;
        update myDataISp.theSA;
        
        
        Action_Plan__c ap2 = new Action_Plan__c(
            Service_Assignment__c = myDataISP.theSA.id,
            Target_Date__c = myDataISP.theSA.Start_Date__c.addDays(1),
            Effective_Date__c = myDataISP.theSA.start_Date__c
        );        
        insert ap2; 

        
    }
    
}