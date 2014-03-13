/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class DataExportTest {
	static private Contact person;
	static private id personId;
	static private Service_Assignment__c sa;
	static private Action_Plan__c testplan;
	static Action_Plan_Goal__c testGoal;
	static Action_Plan_Objective__c testObjective;
	static Action_Summary__c summary;
	static Action_Summary__c summary2;
	
    static testMethod void myUnitTest() {
        
		createObjects();
		
		DataExport util = new DataExport();
		
		string out = util.Export((SObject)person);
		
		Dom.Document doc = new Dom.Document();
		doc.Load(out);
		
		system.debug('xml:' + out);
		Dom.XmlNode root = doc.GetRootElement();
		System.assert( root.getName() == 'objects');
		integer oo = 0;
		integer matches = 0;
		string personpseudonym;
		string admissionpseudonym;
		string sapseudonym;
		string appseudonym;
		string apgpseudonym;
		string apopseudonym;
		string aspseudonym;
		for(Dom.XmlNode objnode: root.getChildElements()){
			system.assert(objnode.getName() == 'object' || objnode.getName() == 'pseudonym' );
			if (objnode.getattribute('classname', '') == 'Contact'
				&& objnode.getName() == 'object'){
				personpseudonym = objnode.getattribute('pseudonym', '');
			}
			if (objnode.getattribute('classname', '') == 'Admission__c'
				&& objnode.getName() == 'object'){
				admissionpseudonym = objnode.getattribute('pseudonym', '');
			}
			if (objnode.getattribute('classname', '') == 'Service_Assignment__c'
				&& objnode.getName() == 'object'){
				sapseudonym = objnode.getattribute('pseudonym', '');
			}
			if (objnode.getattribute('classname', '') == 'Action_Plan__c'
				&& objnode.getName() == 'object'){
				appseudonym = objnode.getattribute('pseudonym', '');
			}
			if (objnode.getattribute('classname', '') == 'Action_Plan_Goal__c'
				&& objnode.getName() == 'object'){
				apgpseudonym = objnode.getattribute('pseudonym', '');
			}
			if (objnode.getattribute('classname', '') == 'Action_Plan_Objective__c'
				&& objnode.getName() == 'object'){
				apopseudonym = objnode.getattribute('pseudonym', '');
			}
			if (objnode.getattribute('classname', '') == 'Action_Summary__c'
				&& objnode.getName() == 'object'){
				aspseudonym = objnode.getattribute('pseudonym', '');
			}
			integer ff = 0;
			for(Dom.XmlNode fieldnode: objnode.getChildElements()){
				system.assert(fieldnode.getName() == 'field');
				if (objnode.getattribute('classname', '') == 'Contact'
					&& fieldnode.getAttribute('name', '') == 'Lastname'){
					System.assertequals('Contact', fieldnode.gettext());
					matches++;
				}
				if (objnode.getattribute('classname', '') == 'Contact'
					&& fieldnode.getAttribute('name', '') == 'firstname'){
					System.assertequals('Test', fieldnode.gettext());
					matches++;
				}
				if (objnode.getattribute('classname', '') == 'Admission__c'
					&& fieldnode.getAttribute('name', '') == 'person_being_served__c'){
					System.assertequals(personpseudonym, fieldnode.gettext());
					matches++;
				}
				if (objnode.getattribute('classname', '') == 'Service_Assignment__c'
					&& fieldnode.getAttribute('name', '') == 'start_date__c'){
					System.assertequals('10/10/2013', fieldnode.gettext());
					matches++;
				}
				if (objnode.getattribute('classname', '') == 'Service_Assignment__c'
					&& fieldnode.getAttribute('name', '') == 'admission__c'){
					System.assertequals(admissionpseudonym, fieldnode.gettext());
					matches++;
				}
				if (objnode.getattribute('classname', '') == 'Action_Plan__c'
					&& fieldnode.getAttribute('name', '') == 'effective_date__c'){
					System.assertequals(date.today().format(), fieldnode.gettext());
					matches++;
				}
//				if (objnode.getattribute('classname', '') == 'Action_Plan__c'
//					&& fieldnode.getAttribute('name', '') == 'Service_Assignment__c'){
//					System.assertequals(sapseudonym, fieldnode.gettext());
//					matches++;
//				}
				if (objnode.getattribute('classname', '') == 'Action_Plan__c'
					&& fieldnode.getAttribute('name', '') == 'target_date__c'){
					System.assertequals(DataConvert.toString(date.today().addmonths(3)), fieldnode.gettext());
					matches++;
				}
				if (objnode.getattribute('classname', '') == 'Action_Plan__c'
					&& fieldnode.getAttribute('name', '') == 'Status__c'){
					System.assertequals('Active Final', fieldnode.gettext());
					matches++;
				}
				if (objnode.getattribute('classname', '') == 'Action_Plan_Goal__c'
					&& fieldnode.getAttribute('name', '') == 'action_plan__c'){
					System.assertequals(appseudonym, fieldnode.gettext());
					matches++;
				}
				if (objnode.getattribute('classname', '') == 'Action_Plan_Goal__c'
					&& fieldnode.getAttribute('name', '') == 'description__c'){
					System.assertequals('Just a testobject', fieldnode.gettext());
					matches++;
				}
				if (objnode.getattribute('classname', '') == 'Action_Plan_Objective__c'
					&& fieldnode.getAttribute('name', '') == 'Action_Plan_Goal__c'){
					System.assertequals(apgpseudonym, fieldnode.gettext());
					matches++;
				}
				if (objnode.getattribute('classname', '') == 'Action_Plan_Objective__c'
					&& fieldnode.getAttribute('name', '') == 'description__c'){
					System.assertequals('Just a testobject', fieldnode.gettext());
					matches++;
				}
				if (objnode.getattribute('classname', '') == 'Action_Plan_Objective__c'
					&& fieldnode.getAttribute('name', '') == 'Status__c'){
					System.assertequals('In Progress', fieldnode.gettext());
					matches++;
				}
				if (objnode.getattribute('classname', '') == 'Action_Plan_Objective__c'
					&& fieldnode.getAttribute('name', '') == 'Type__c'){
					System.assertequals('Skill', fieldnode.gettext());
					matches++;
				}
				if (objnode.getattribute('classname', '') == 'Action_Plan_Objective__c'
					&& fieldnode.getAttribute('name', '') == 'Effective_date__c'){
					System.assertequals(date.Today().format(), fieldnode.gettext());
					matches++;
				}
				if (objnode.getattribute('classname', '') == 'Action_Plan_Objective__c'
					&& fieldnode.getAttribute('name', '') == 'Target_end_date__c'){
					System.assertequals(date.today().addmonths(1).format(), fieldnode.gettext());
					matches++;
				}
// action_summary__c is not master detail to service_assignmment so order does not have to be predictable
//				if (objnode.getattribute('classname', '') == 'Action_Summary__c'
//					&& fieldnode.getAttribute('name', '') == 'Service_Assignment__c'
//					&& objnode.getattribute('pseudonym', '') == summary.id){
//					System.assertequals(sapseudonym, fieldnode.gettext());
//					matches++;
//				}
				if (objnode.getattribute('classname', '') == 'Action_Summary__c'
					&& fieldnode.getAttribute('name', '') == 'Start_Date__c'
					&& objnode.getattribute('pseudonym', '') == summary.id){
					System.assertequals(Date.today().toStartOfMonth().format(), fieldnode.gettext());
					matches++;
				}
				if (objnode.getattribute('classname', '') == 'Action_Summary__c'
					&& fieldnode.getAttribute('name', '') == 'End_Date__c'
					&& objnode.getattribute('pseudonym', '') == summary.id){
					System.assertequals(Date.today().toStartOfMonth().addmonths(1).format(), fieldnode.gettext());
					matches++;
				}
// action_summary__c is not master detail to service_assignmment so order does not have to be predictable
//				if (objnode.getattribute('classname', '') == 'Action_Summary__c'
//					&& fieldnode.getAttribute('name', '') == 'Service_Assignment__c'
//					&& objnode.getattribute('pseudonym', '') == summary2.id){
//					System.assertequals(sapseudonym, fieldnode.gettext());
//					matches++;
//				}
				if (objnode.getattribute('classname', '') == 'Action_Summary__c'
					&& fieldnode.getAttribute('name', '') == 'Start_Date__c'
					&& objnode.getattribute('pseudonym', '') == summary2.id){
					System.assertequals(Date.today().toStartOfMonth().format(), fieldnode.gettext());
					matches++;
				}
				if (objnode.getattribute('classname', '') == 'Action_Summary__c'
					&& fieldnode.getAttribute('name', '') == 'End_Date__c'
					&& objnode.getattribute('pseudonym', '') == summary2.id){
					System.assertequals((Date.today().toStartOfMonth().addmonths(1)-1).format(), fieldnode.gettext());
					matches++;
				}
				ff++;
			}
			oo++;
		}
		system.assertequals(12,oo,'wrong number of objects/pseudonyms');
		system.assertequals(20,matches, 'did not hit all the fields');
    }
    
    private static Action_Plan__c createObjects(){
        person = new Contact();
        person.LastName = 'Contact';
        person.FirstName = 'Test';
        insert person;
        personId = person.Id;
        Admission__c adm = new Admission__c();
        adm.person_being_served__c = person.id;
        insert adm;
        sa = new Service_Assignment__c();  
        sa.Person_Being_Served__c = person.id;
        sa.admission__c = adm.id;
        sa.Start_Date__c = Date.parse('10/10/2013');
        insert sa;  
       
        testplan = new Action_Plan__c();
        testplan.Service_Assignment__c = sa.id;
        testplan.effective_date__c = date.today();
        testplan.target_date__c = testplan.effective_date__c.addmonths(3);
        testplan.Status__c = 'Active Final';
        insert testPlan;
       
        testGoal = new Action_Plan_Goal__c();
        testGoal.Action_Plan__c = testPlan.Id;
        testGoal.Description__c = 'Just a testobject';
        insert testGoal;
       
        testObjective = new Action_Plan_Objective__c();
        testObjective.Action_Plan_Goal__c = testGoal.Id;
        testObjective.Description__c = 'Just a testobject';
        testObjective.Status__c = 'In Progress';
        testObjective.Type__c = 'Skill';
        testObjective.Effective_date__c = date.Today();
        testObjective.Target_end_date__c = date.today().addmonths(1);       
        insert testObjective;

        summary = new Action_Summary__c();
        summary.Start_Date__c = Date.today().toStartOfMonth();
        summary.End_Date__c = summary.Start_Date__c.addmonths(1);
        summary.Service_Assignment__c = sa.id;
        insert summary;

        summary2 = new Action_Summary__c();
        summary2.Start_Date__c = Date.today().toStartOfMonth();
        summary2.End_Date__c = summary.Start_Date__c.addmonths(1)-1;
        summary2.Service_Assignment__c = sa.id;
        insert summary2;

        Objective_Summary_Comment__c sumComment = new Objective_Summary_Comment__c();
        SumComment.action_plan_objective__c = testObjective.id;
        sumComment.Action_Summary__c = summary2.id;
        insert sumComment;

        Action_Skill_Result__c testresult = new Action_Skill_Result__c();
        testresult.Action_plan_objective__c = testObjective.id;
        testresult.Attempts__c = 5;
        testResult.Day__c = date.today();
        testResult.Status__c = 'V';
        testResult.Met_Objective__c = 'Y';
        insert testresult;
        
        Action_Skill_Result__c testresult2 = new Action_Skill_Result__c();
        testresult2.Action_plan_objective__c = testObjective.id;
        testresult2.Attempts__c = 1;
        testResult2.Day__c = date.today()+1;
        testResult2.Status__c = 'PP';
        testResult2.Met_Objective__c = 'N';
        insert testresult2;
        
        return testplan;
    }

    
}