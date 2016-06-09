@isTest
public with sharing class PDMControllerTest {
	
	
	public static String searchEmployee {set;get;}
	public static String searchLocation {set;get;}
	public static String searchPerson {set;get;}
	public static String tmlUserQuery {set;get;}
	public static List<TMN_User__c> TMNUserList {set;get;}
	 

			static testmethod void TestsearchByLocation(){
			List<TMN_User__c> newTmnUser = 	tmnUsers();
			User testUser = [SELECT Id FROM User WHERE Id =:newTmnUser[0].Salesforce_User_Account__c];
				system.runas(testUser){
				PDMController controller = new PDMController();
				
				   
				controller.firstName ='Adam';
				controller.lastName ='Vernatter';
				controller.city ='North Andover';
				controller.state ='MA';
				controller.operationGroup ='Corporate';
				controller.searchTitle ='Analyst';
				controller.AlphaFilter ='A';
				controller.size= 10;
				controller.curruser = newTmnUser.get(0);
				controller.ServiceCenter = '1-888-774-4872 Option #2';
 				controller.HumanResources = '1-888-774-4872 Option #3';
 				controller.ItServiceCenter=  '1-888-774-4872 Option #1';
 				controller.fax ='588-123-1234';
				
				controller.searchEmployee = 'Vernatter';
					controller.searchLocation = ' Andover';
					searchEmployee = 'Vernatter';
					searchLocation = 'Andover';
					controller.tmlUserQuery = 'Select Work_State__c, Office_Phone__c,Mentor_Cell_Phone__c, Operating_Group__c, Name, Manager_Name__c, Last_Name__c, First_Name__c,Job_Title__c ,Email__c ,fax__c,phone_ext__c,Work_State_Code__c,Work_City__c From TMN_User__c where   (Last_Name__c LIKE \'' + searchEmployee + '%\' OR First_Name__c  LIKE \'' + searchEmployee + '%\' ) ';
					controller.searchName ='AdvanceSearch';
					controller.searchEmployee();
					controller.searchByLocation();
			 System.AssertEquals(false, controller.hasNext);		
			 System.AssertEquals(false, controller.hasPrevious);	
			controller.SortFieldSave= 'desc' ;	
					controller.previous();
					controller.next();
					controller.pageNumber =  1;
					controller.SortToggle();
					controller.search();
					controller.getTMNUserList();
					controller.MainOffice= '1-617-790-4800';
					//controller.setCon = new ApexPages.StandardSetController(Database.getQueryLocator(controller.tmlUserQuery));
					 ApexPages.StandardSetController son = controller.setCon;
					 newTmnUser[0].Mentor_Cell_Phone__c= '(408)325 1258';
					 controller.save();
					 
				}
					
				
			}

		public static List<TMN_User__c> tmnUsers() {
			
			Alias__c alias = getNewAlias('000000');
			List<TMN_User__c> tmnList = new List<TMN_User__c>();
			
			TMN_User__c m = new TMN_User__c(); 
			m.Work_State__c = 'MA';
			m.Office_Phone__c = '(234)567 7890';
			m.Mentor_Cell_Phone__c = '(222)333 4444';
			m.Last_Name__c = 'TestLast1';
			m.Work_City__c = 'BOSTON';
			m.First_Name__c = 'Shaun test';
			m.Job_Title__c = 'Director';
			m.Service_Region__c= 'BU-001';
			m.Service_Line__c= 'Corporate Overhead';
			m.Salesforce_User_Account__c   = createUser('ESD General', 'cmuser', 'cmuser1@cm.com', 'Shauntesttest', 'Teststststs', 'Care Meridian').id;
			m.Suppress_External_Update__c =false;
			m.Program_String__c = '001140 IT Business Systems';
			m.Preferred_First_Name__c = 'Adam1';
			m.Preferred_Last_Name__c  = 'Vernatter1' ;
			m.Operating_Group__c= 'Corporate';
			m.Office_Location__c  = '1600 Osgood Street';
			m.Office_Location_PickList__c= 'Yes';
			m.Manager_Email__c= 'Katetest@TMN.com';
			m.Location_Name__c= 'Boston';
			m.Job_Status__c = 'Active';
			m.Hire_Date__c= Date.Today();
			m.Email__c= 'shaun@tmntest.com';
			m.Current_Person_Type__c= 'Employee';
			m.Alias__c= alias.Alias_unique__c;
			m.Alias_Lookup__c  = alias.id;
			
			insert m;
			
			TMN_User__c u = new TMN_User__c(); 
			u.Work_State__c = 'MA';
			u.Office_Phone__c = '(234)567 7890';
			u.Mentor_Cell_Phone__c = '(222)333 4444';
			u.Last_Name__c = 'TestLast1';
			u.Work_City__c = 'BOSTON';
			u.First_Name__c = 'TestFirst1';
			u.Job_Title__c = 'Analyst';
			u.Service_Region__c= 'BU-001';
			u.Service_Line__c= 'Corporate Overhead';
			u.Salesforce_User_Account__c   = createUser('ESD General', 'cmuser', 'cmuser1@cm.com', 'cmFname4', 'CmLName4', 'Care Meridian').id;
			u.Suppress_External_Update__c =false;
			u.Program_String__c = '001140 IT Business Systems';
			u.Preferred_First_Name__c = 'Adam1';
			u.Preferred_Last_Name__c  = 'Vernatter1' ;
			u.Operating_Group__c= 'Corporate';
			u.Office_Location__c  = '1600 Osgood Street';
			u.Office_Location_PickList__c= 'Yes';
			u.Manager_Lookup__c= m.id;
			//u.Manager_Last_Name__c= 'swood';
			u.Manager_Email__c= 'shaun@tmntest.com';
			u.Location_Name__c= 'Boston';
			u.Job_Status__c = 'Active';
			u.Hire_Date__c= Date.Today();
			u.Email__c= 'adam.vernatter1@thementornetwork.com';
			u.Current_Person_Type__c= 'Employee';
			u.Alias__c= alias.Alias_unique__c;
			u.Alias_Lookup__c  = alias.id;
			
			tmnList.add(u);
		
			TMN_User__c u1 = new TMN_User__c(); 
			u1.Work_State__c = 'MA';
			u1.Office_Phone__c = '(456) 456-4564';
			u1.Mentor_Cell_Phone__c = '(617) 790-4908';
			u1.Last_Name__c = 'TestLast2';
			u1.Work_City__c = 'BOSTON';
			u1.First_Name__c = 'TestFirst2';
			u1.Job_Title__c = 'Analyst2';
			u1.Service_Region__c= 'BU-001';
			u1.Service_Line__c= 'Corporate Overhead';
			u1.Salesforce_User_Account__c   = createUser('ESD General', 'cmuser', 'cmuser2@cm.com', 'cmFname1', 'CmLName1', 'Care Meridian').id;
			u1.Suppress_External_Update__c =false;
			u1.Program_String__c = '001140 IT Business Systems';
			u1.Preferred_First_Name__c = 'Adam2';
			u1.Preferred_Last_Name__c  = 'Vernatter2' ;
			u1.Operating_Group__c= 'Corporate';
			u1.Office_Location__c  = '1600 Osgood Street';
			u1.Office_Location_PickList__c= 'Yes';
			u.Manager_Lookup__c= m.id;
			//u.Manager_Last_Name__c= 'swood';
			u1.Manager_Email__c= 'shaun@tmntest.com';
			u1.Location_Name__c= 'North Andover';
			u1.Job_Status__c = 'Active';
			u1.Hire_Date__c= Date.Today();
			u1.Email__c= 'adam.vernatter2@thementornetwork.com';
			u1.Current_Person_Type__c= 'Employee';
			u1.Alias__c= alias.Alias_unique__c;
			u1.Alias_Lookup__c  = alias.id;
			
			tmnList.add(u1);
			
			u = new TMN_User__c(); 
			u.Work_State__c = 'MA';
			u.Office_Phone__c = '(617) 790-4240';
			u.Mentor_Cell_Phone__c = '(617) 790-4889';
			u.Last_Name__c = 'TestLast3';
			u.Work_City__c = 'BOSTON';
			u.First_Name__c = 'TestFirst3';
			u.Job_Title__c = 'Analyst3';
			u.Service_Region__c= 'BU-001';
			u.Service_Line__c= 'Corporate Overhead';
			u.Salesforce_User_Account__c   = createUser('ESD General', 'cmuser', 'cmuser3@cm.com', 'cmFname2', 'CmLName2', 'Care Meridian').id;
			u.Suppress_External_Update__c =false;
			u.Program_String__c = '001140 IT Business Systems';
			u.Preferred_First_Name__c = 'Adam3';
			u.Preferred_Last_Name__c  = 'Vernatter3' ;
			u.Operating_Group__c= 'Corporate';
			u.Office_Location__c  = '1600 Osgood Street';
			u.Office_Location_PickList__c= 'Yes';
			u.Manager_Lookup__c= m.id;
			//u.Manager_Last_Name__c= 'swood';
			u.Manager_Email__c= 'shaun@tmntest.com';
			u.Location_Name__c= 'North Andover';
			u.Job_Status__c = 'Active';
			u.Hire_Date__c= Date.Today();
			u.Email__c= 'adam.vernatter3@thementornetwork.com';
			u.Current_Person_Type__c= 'Employee';
			u.Alias__c= alias.Alias_unique__c;
			u.Alias_Lookup__c  = alias.id;
			tmnList.add(u);
			u = new TMN_User__c(); 
			u.Work_State__c = 'MA';
			u.Office_Phone__c = '(617) 790-4917';
			u.Mentor_Cell_Phone__c = '(617) 790-4237';
			u.Last_Name__c = 'Vernatter';
			u.Work_City__c = 'North Andover';
			u.First_Name__c = 'TestFirst4';
			u.Job_Title__c = 'Analyst4';
			u.Service_Region__c= 'BU-001';
			u.Service_Line__c= 'Corporate Overhead';
			u.Salesforce_User_Account__c   = createUser('ESD General', 'cmuser', 'cmuser4@cm.com', 'cmFname3', 'CmLName3', 'Care Meridian').id;
			u.Suppress_External_Update__c =false;
			u.Program_String__c = '001140 IT Business Systems';
			u.Preferred_First_Name__c = 'Adam4';
			u.Preferred_Last_Name__c  = 'Vernatter4' ;
			u.Operating_Group__c= 'Corporate';
			u.Office_Location__c  = '1600 Osgood Street';
			u.Office_Location_PickList__c= 'Yes';
			//u.Manager_Lookup__c= 'a0RJ000000Ai8QeMAJ';
			//u.Manager_Last_Name__c= 'swood';
			u.Manager_Email__c= 'shaun@tmntest.com';
			u.Location_Name__c= 'North Andover';
			u.Job_Status__c = 'Active';
			u.Hire_Date__c= Date.Today();
			u.Email__c= 'adam.vernatter4@thementornetwork.com';
			u.Current_Person_Type__c= 'Employee';
			u.Alias__c= alias.Alias_unique__c;
			u.Alias_Lookup__c  = alias.id;
			tmnList.add(u);
			insert tmnList;
		return tmnList;
		}
		
public static User createUser(string profileName,string userAlias, string userName, string firstName, string lastName, string OperatingGroup){
		Map<String,Profile> profileMap = new Map<String,Profile>();
		List<Profile> proflist = [SELECT Id, Name FROM Profile];
		for(Profile p : proflist){
			profileMap.put(p.Name, P);
		}
		User testUser = new User(alias = userAlias,
				email=userName,
				emailencodingkey='UTF-8',
				lastname=lastName,firstname=firstName, languagelocalekey='en_US',
				localesidkey='en_US',
				profileid = profileMap.get(profileName).id,
				timezonesidkey='America/Los_Angeles',
				username=username + System.currentTimeMillis());

		insert testUser;
		System.debug('testUser : '+testUser.id);
		return testUser;
		}
		
public static 	Alias__c getNewAlias(String unique){
	Alias__c alias = new Alias__c();
	alias.Name = unique;
	alias.Alias_Operating_Group__c= 'Care Meridian1';
	alias.Alias_unique__c = unique;
	alias.Alias_Business_Unit__c = '001140 IT Business Systems2';
	alias.Alias_Description__c = '001140 IT Business Systems3';
	alias.Alias_Level__c = '';
	alias.Alias_Region__c = 'BU-0013';
	alias.Alias_State__c = 'Corp3';
	alias.Alias_Parent__c = 'Network - IT3';
	alias.Alias_Service_Line__c = 'Corporate Overhead3';
		insert alias;
		return alias;
}	
		
		

}