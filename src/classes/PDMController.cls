public with sharing class PDMController {

 Public Integer size{get;set;}
 Public Integer noOfRecords {get;set;}
 public List<PermissionSetAssignment> editAccess {get; set;}
 public TMN_User__c curruser  {get{return [ select id,Work_State__c,Work_City__c,Alias__c   from tmn_user__c where salesforce_user_account__c = :UserInfo.getUserId() LIMIT 1];} set;}
 
 public String MainOffice {get{
 	List<Service_Location__c> phone =	[select Alias__c, Phone__c, City__c, State__c, Zip__c from Service_Location__c where Alias__c =:curruser.Alias__c limit 1];
 		if(phone!=null && phone.size()>0){
 		return phone.get(0).Phone__c;
 		}return '1-617-790-4800';
 } set;}
 public String ServiceCenter {get{return '1-888-774-4872 Option #2';} set;}
 public String HumanResources {get{return '1-888-774-4872 Option #3';} set;}
 public String ItServiceCenter {get{return '1-888-774-4872 Option #1';} set;}
 public String fax {get{return '588-123-1234';} set;}
   
public String firstName {get; set;}
public String lastName {get; set;}
public String city {get; set;}
public String state {get; set;}
public String operationGroup {get; set;}
public String searchTitle {set;get;}
public String AlphaFilter {set;get;} 
    public String SortDirection {
        get { if (SortDirection == null) {  SortDirection = 'asc'; } return SortDirection;  }
        set;
    }
public String SortField {
        get { if (SortField == null) {SortField = 'Office_Phone__c'; } return SortField;  }
        set; 
    }    
public String SortFieldSave;    
public Boolean errorMsg1 {set;get;}
public Boolean errorMsg2 {set;get;}
public Boolean errorMsg3 {set;get;}
public Boolean errorMsg4 {set;get;}
public String searchingForQuery {set;get;}    
@testVisible private String tmlUserQuery;
@testVisible private List<TMN_User__c> TMNUserList {set;get;}
@testVisible private String searchName;

	public PDMController() {
		  SortFieldSave = SortField;
		TMNUserList = new List<TMN_User__c>();
	// alpha filter, use page parameter or set default to all
        if (apexpages.currentpage().getparameters().get('alpha') == null) {
            AlphaFilter = 'All';
        } else {
            AlphaFilter = apexpages.currentpage().getparameters().get('alpha');
        }
        
         firstName = apexpages.currentpage().getparameters().get('firstName');
         lastName = apexpages.currentpage().getparameters().get('lastName');
         city = apexpages.currentpage().getparameters().get('city');
         state = apexpages.currentpage().getparameters().get('state');
         operationGroup = apexpages.currentpage().getparameters().get('operationGroup');
         searchTitle = apexpages.currentpage().getparameters().get('JobTitle');
        // list generation
        BuildQuery();
        
        editAccess = [SELECT PermissionSetId
              FROM PermissionSetAssignment
              WHERE assignee.Id = :UserInfo.getUserId()
              AND PermissionSet.Name = 'Company_Directory_Editor'
              LIMIT 1];
          
	}

   public ApexPages.StandardSetController setCon {
        get{
            if(setCon == null){
                size = 50;
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(tmlUserQuery));
                setCon.setPageSize(size);
                noOfRecords = setCon.getResultSize();
                	if(noOfRecords==0 && searchName!=null && searchName.equals('AdvanceSearch')) {
                	errorMsg4 = true;errorMsg1 = false;errorMsg3 = false;errorMsg2 = false;
                	}
                
            }
            return setCon;
        }set;
    }


Public List<TMN_User__c> getTMNUserList(){
        List<TMN_User__c> Tlist = new List<TMN_User__c>();
        for(TMN_User__c t : (List<TMN_User__c>)setCon.getRecords()){
            Tlist.add(t);
        }
        return Tlist;
    }
public void searchEmployee() {
	SortField = null;
	SortDirection = null;
 String queryString = 'Select Work_State__c, Office_Phone__c,Mentor_Cell_Phone__c, Operating_Group__c, Name, Manager_Name__c, Last_Name__c, First_Name__c,Job_Title__c ,Email__c ,fax__c,phone_ext__c,Work_State_Code__c,Work_City__c From TMN_User__c where office_phone__C <> \'Call Manager\' and   (Last_Name__c LIKE \'' + searchEmployee + '%\' OR First_Name__c  LIKE \'' + searchEmployee + '%\' ) ' +getExcludeJobTitle();
    			if(searchLocation!=null && searchLocation.length() > 0) {
				queryString =  queryString + ' and Work_City__c like \'%' + searchLocation +'%\' ';
				}
    searchingForQuery = queryString;
			queryString =  queryString + ' order by ' + SortField + ' ' + SortDirection + ' limit 10000'; 
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                setCon.setPageSize(size);
 noOfRecords = setCon.getResultSize();
			if(noOfRecords==0){
				if(searchLocation!=null && searchLocation.length() > 0) {
				errorMsg2 = true;errorMsg1 = false;errorMsg3 = false;errorMsg4 = false;
				}else {
				errorMsg3 = true; errorMsg2 = false;errorMsg1 = false;errorMsg4 = false;
				}
					
				}

}

public void searchByLocation () {
	SortField = null;
	SortDirection = null;
 String queryString = 'Select Work_State__c, Office_Phone__c,Mentor_Cell_Phone__c, Operating_Group__c, Name, Manager_Name__c,  Last_Name__c,First_Name__c, Job_Title__c,Email__c ,fax__c,phone_ext__c,Work_State_Code__c,Work_City__c From TMN_User__c where office_phone__C <> \'Call Manager\' and Work_City__c like \'%' + searchLocation +'%\'  ' +getExcludeJobTitle();
searchingForQuery = queryString;
    queryString =  queryString +  ' order by ' + SortField + ' ' + SortDirection + ' limit 10000';
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                setCon.setPageSize(size);
 noOfRecords = setCon.getResultSize();
	if(noOfRecords==0){
	errorMsg1 = true;errorMsg2 = false;errorMsg3 = false;errorMsg4 = false;
	}
}

	   public void BuildQuery() {
        setCon = null;
        String locationSelected = curruser.Work_City__c;
        		if(searchLocation !=null && searchLocation.length()>0){
        		locationSelected = searchLocation ;
        		}else{
        		searchLocation = locationSelected;
        		}
        
        if (AlphaFilter == null || AlphaFilter.trim().length() == 0) {
            AlphaFilter = 'All';
        }
        
        tmlUserQuery = 'Select Work_State__c,Office_Phone__c,Mentor_Cell_Phone__c, Operating_Group__c, Name, Manager_Name__c, fax__c,';
     tmlUserQuery = tmlUserQuery +  + 'Last_Name__c, First_Name__c,Job_Title__c,Email__c,phone_ext__c,Work_State_Code__c,Work_City__c From TMN_User__c  where Work_City__c = \'' + locationSelected +'\' ' +getExcludeJobTitle(); 
           if (AlphaFilter != 'All') {
            tmlUserQuery =  tmlUserQuery +' and (Last_Name__c LIKE \'' + AlphaFilter + '%\' OR First_Name__c  LIKE \'' + AlphaFilter + '%\' )' ;
        	}
        tmlUserQuery += ' order by ' + SortField + ' ' + SortDirection + ' limit 10000';
					if (AlphaFilter != 'All') {
                 		searchName = null;
                 } 

           if(searchName!=null && searchName.equals('AdvanceSearch')){
        	locationSelected = null;
        String QueryWhere = '';
  tmlUserQuery = 'Select Work_State__c, Office_Phone__c,Mentor_Cell_Phone__c, Operating_Group__c, Name, Manager_Name__c, First_Name__c, Last_Name__c, Job_Title__c,Email__c ,fax__c,phone_ext__c,Work_State_Code__c,Work_City__c From TMN_User__c ';
				if(City!=null && City.length() > 0) {
				QueryWhere =  BuildWhere( QueryWhere , 'Work_City__c like \'' + City +'%\' ');
				}
				if(state!=null && state.length() > 0) {
				QueryWhere =  BuildWhere( QueryWhere , 'Work_State_Code__c =\'' + state +'\' ');
				}
				if(firstName!=null && firstName.length() > 0) {
				QueryWhere =  BuildWhere( QueryWhere , 'First_Name__c like \'%' + firstName +'%\' ');
				}
				if(lastName!=null && lastName.length() > 0) {
				QueryWhere =  BuildWhere( QueryWhere , 'Last_Name__c like \'%' + lastName +'%\' ');
				}
				if(operationGroup!=null && operationGroup.length() > 0) {
					if(operationGroup.startsWithIgnoreCase('Has')) operationGroup = 'Cambridge';
					QueryWhere =  BuildWhere( QueryWhere , 'Operating_Group__c like \'' + operationGroup +'%\' ');
				}
				if(searchTitle!=null && searchTitle.length() > 0) {
				QueryWhere =  BuildWhere( QueryWhere , 'Job_Title__c like \'%' + searchTitle +'%\' ');
				}
            searchingForQuery =  tmlUserQuery + QueryWhere ;
			tmlUserQuery =  tmlUserQuery + QueryWhere +  ' order by ' + SortField + ' ' + SortDirection + ' limit 10000';
        }
           if(searchingForQuery!=null) {
       	      if (AlphaFilter != 'All') {
            tmlUserQuery =  searchingForQuery +' and (Last_Name__c LIKE \'' + AlphaFilter + '%\' OR First_Name__c  LIKE \'' + AlphaFilter + '%\' )' ;
              }else{
                  tmlUserQuery =  searchingForQuery;
              }
               tmlUserQuery = tmlUserQuery + ' order by ' + SortField + ' ' + SortDirection + ' limit 10000';
           }
    }
	
	 public void SortToggle() {
        SortDirection = SortDirection.equals('asc') ? 'desc NULLS LAST' : 'asc';
        // reset alpha filter and sort sequence when sorted field is changed
        if (SortFieldSave != SortField) {
            SortDirection = 'asc';
            AlphaFilter = 'All';
            SortFieldSave = SortField;
        }
         searchName = null;
        // run the query again
        BuildQuery();
    }
    
	
   public String BuildWhere(String QW, String Cond) {
        if (QW == '') {
            return ' WHERE office_phone__C <> \'Call Manager\''+getExcludeJobTitle()+ 'and ' + Cond;
        } else {
            return QW + ' AND ' + Cond;
        }
    }
public void search () {
	SortField = null;
	SortDirection = null;
	AlphaFilter = null;
	searchName ='AdvanceSearch';
	BuildQuery();
}

public void save() {
update setCon.getRecords();
}


public static String getExcludeJobTitle (){
		String jobTitle ='  AND Job_Status__c<>\'Inactive\' AND (NOT Job_Title__c  like \'%Call Manager%\')  AND Job_Title__c NOT IN (\'Certified Nurses Assistant\',\'Community Outreach Worker\',\'Cook\',\'Co-op\',\'Data Entry Coordinator\',\'Day Program Assistant\',\'Direct Support Professional\',\'Driver\',\'Family Member Caregiver\',\'Family Provider\',\'Housekeeper\',\'Job Coach\',\'Lead Maintenance Worker\',\'Life Skills Trainer\',\'Maintenance Specialist\',\'Maintenance Worker\',\'Personal Care Assistant\',\'Personal Service Attendant\',\'Rehabilitation Specialist\',\'Team Lead\',\'Vocational Program Participant\') ';
		return jobTitle;
}


public String searchEmployee {set;get;}
public String searchLocation {set;get;}
public String searchPerson {set;get;}

     
    public Boolean hasNext {
        get {
            return setCon.getHasNext();
        }
        set;
    }
    public Boolean hasPrevious {
        get {
            return setCon.getHasPrevious();
        }
        set;
    }
  
    public Integer pageNumber {
        get {
            return setCon.getPageNumber();
        }
        set;
    }
  
   
    public void previous() {
        setCon.previous();
    }
  
    public void next() {
        setCon.next();
    }
}