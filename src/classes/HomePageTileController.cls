public with sharing class HomePageTileController {
	public boolean RefCreate{get;set;}
	public boolean RefView{get;set;}
	public boolean PBSView{get;set;}
	public boolean PBSCreate{get;set;}
	public boolean TMNCreate{get;set;}
	public boolean TMNView{get;set;}
	public boolean ContractCreate{get;set;}
	public boolean ContractView{get;set;}
	public boolean DocCreate{get;set;}
	public boolean DocView{get;set;}
	public boolean IncCreate{get;set;}
	public boolean IncView{get;set;}
	
	public boolean isCAFSS{get; set;} //flag to handle CA FSS implementation
	public String objectName{get;set;}
	public boolean tileCont{get;set;}
	
	
	
	//Constructor
	public HomePageTileController(){
		shareobj();
	}
	
	
	//Block visibility check
	public void shareobj(){

		//Referral object
		Schema.DescribeSObjectResult oSchema1 = Referral__c.sObjectType.getDescribe();
		RefCreate = oSchema1.IsCreateable();
		RefView = oSchema1.isAccessible();

		//PBS object
		Schema.DescribeSObjectResult oSchema2 = Account.sObjectType.getDescribe();
		PBSCreate = oSchema2.IsCreateable();
		PBSView = oSchema2.isAccessible();

		//TMN object
		Schema.DescribeSObjectResult oSchema3 = TMN_Contact__c.sObjectType.getDescribe();
		TMNCreate = oSchema3.IsCreateable();
		TMNView = oSchema3.isAccessible();

		//Contract object
		List<TMN_User__c> tmnUsers = [SELECT ID, Operating_Group__c, Business_Unit__c FROM TMN_User__c WHERE Salesforce_User_Account__c= :UserInfo.getUserId() LIMIT 1];
		isCAFSS = (tmnUsers[0].Business_Unit__c != null  && tmnUsers[0].Business_Unit__c.startswith('BU 008'));
		Schema.DescribeSObjectResult oSchema4;
		for(TMN_User__c tmn:tmnUsers){
			if(tmn.Operating_Group__c=='Cambridge'){
				oSchema4 = TMN_Contract__c.sObjectType.getDescribe();
			}else if(tmn.Operating_Group__c=='CareMeridian' || tmn.Operating_Group__c=='Care Meridian' || tmn.Operating_Group__c=='NeuroRestorative' ){
				oSchema4 = CareMeridian_Contract__c.sObjectType.getDescribe();
			}else if(tmn.Operating_Group__c=='Redwood'){
				oSchema4 = Redwood_Contract__c.sObjectType.getDescribe();
			}else{
				oSchema4=null;
			}
		}

		if(oSchema4!=null){
			ContractCreate = oSchema4.IsCreateable();
			ContractView = oSchema4.isAccessible();
		}else{
			ContractCreate = false;
			ContractView = false;
		}

		//Doc object
		Schema.DescribeSObjectResult oSchema5 = Document__c.sObjectType.getDescribe();
		DocCreate = oSchema5.IsCreateable();
		DocView = oSchema5.isAccessible();
		
		//Incidents Object
		Schema.DescribeSObjectResult oSchema6 = Incident__c.sObjectType.getDescribe();
		IncCreate = oSchema6.IsCreateable();
		IncView = oSchema6.isAccessible();
		
		PermissionSetAssignment[] assignments = [
		SELECT Id, PermissionSet.Name
			FROM PermissionSetAssignment
			WHERE AssigneeId = :UserInfo.getUserId()
		];
		Set<String> permissionSets = new Set<String>();
		for (PermissionSetAssignment assignment: assignments) {
			permissionSets.add(assignment.PermissionSet.Name);
		}
		if (permissionSets.contains('ESD_Notes_Catalog_and_Packet_Admin') || permissionSets.contains('Manage_Service_Locations') || permissionSets.contains('Create_Service_Locations')){
			tileCont = true;
		} else {
			tileCont = false;
		}
		
	}


	public string referralPrefix {
		get {
			Schema.DescribeSObjectResult d = Referral__c.sObjectType.getDescribe();

			return d.getKeyPrefix();
		}
		private set;
	}


	public Map<String, String> ReferralViews {
		get {
			if (ReferralViews != null) {
				return ReferralViews;
			}
			ReferralViews = new Map<String, String>();
			String query2 = 'SELECT ID FROM Referral__c  limit 100'; // 05/06/14 - set limit to prevent governor limit overrun
			ApexPages.StandardSetController con2 = new ApexPages.StandardSetController(Database.getQueryLocator(query2));
			SelectOption[] options2 = con2.getListViewOptions();
			for (SelectOption option2 : options2) {

				if (option2.getLabel().toLowerCase().indexOf('all')!=-1) {
					ReferralViews.put('all', option2.getValue().substring(0,15));
				} else if (option2.getLabel().toLowerCase().indexOf('my referrals')!=-1) {
					ReferralViews.put('my', option2.getValue().substring(0,15));
				}
			}

			return ReferralViews;
		}
		set;
	}
	public Map<String, String> DocViews {
		get {
			if (DocViews != null) {
				return DocViews;
			}
			DocViews = new Map<String, String>();
			String query1 = 'SELECT ID FROM Document__c  limit 100'; // 05/06/14 - set limit to prevent governor limit overrun
			ApexPages.StandardSetController con1 = new ApexPages.StandardSetController(Database.getQueryLocator(query1));

			SelectOption[] options1 = con1.getListViewOptions();

			for (SelectOption option1 : options1) {
				if (option1.getLabel().toLowerCase().indexOf('all')!=-1) {
					DocViews.put('all', option1.getValue().substring(0,15));
				} else if (option1.getLabel().toLowerCase().indexOf('Cambridge BP DocView')!=-1) {
					DocViews.put('cambridge', option1.getValue().substring(0,15));
				}
			}
			return DocViews;
		}
		set;
	}

	public Map<String, String> TMNViews {
		get {
			if (TMNViews != null) {
				return TMNViews;
			}
			TMNViews = new Map<String, String>();
			String query4 = 'SELECT ID FROM TMN_Contact__c  limit 100'; // 05/06/14 - set limit to prevent governor limit overrun
			ApexPages.StandardSetController con4 = new ApexPages.StandardSetController(Database.getQueryLocator(query4));

			SelectOption[] options4 = con4.getListViewOptions();

			for (SelectOption option4 : options4) {
				if (option4.getLabel().toLowerCase().indexOf('my')!=-1) {
					TMNViews.put('my', option4.getValue().substring(0,15));
				}
			}
			return TMNViews;
		}
		set;
	}

	
}