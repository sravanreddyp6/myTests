public with sharing class PDMController {

 Public Integer size{get;set;}
 Public Integer noOfRecords {get;set;}
 public TMN_User__c curruser  {get{return [ select id,Work_State__c,Work_City__c  from tmn_user__c where salesforce_user_account__c = :UserInfo.getUserId() LIMIT 1];} set;}
 
 public String MainOffice {get{return '999-999-9999';} set;}
 public String ServiceCenter {get{return '989-989-7888';} set;}
 public String HumanResources {get{return '999-999-9999';} set;}
 public String TestLabel {get{return '234-234-3434';} set;}
 public String fax {get{return '588-123-1234';} set;}
   
public String firstName {get; set;}
public String lastName {get; set;}
public String city {get; set;}
public String state {get; set;}
public String operationGroup {get; set;}
public String searchTitle {set;get;}
public String AlphaFilter {set;get;}
public Boolean errorMsg1 {set;get;}
public Boolean errorMsg2 {set;get;}
public Boolean errorMsg3 {set;get;}
public Boolean errorMsg4 {set;get;}
private String tmlUserQuery;
private List<TMN_User__c> TMNUserList {set;get;}
 private String searchName;

	public PDMController() {
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
	}

   public ApexPages.StandardSetController setCon {
        get{
            if(setCon == null){
                size = 10;
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
 String queryString = 'Select Work_State__c, Office_Phone__c,Mentor_Cell_Phone__c, Operating_Group__c, Name, Manager_Name__c, Last_Name__c, First_Name__c,Job_Title__c ,Email__c ,fax__c,phone_ext__c,Work_State_Code__c,Work_City__c From TMN_User__c where Name like \'%' + searchEmployee +'%\' ';
    			if(searchLocation!=null && searchLocation.length() > 0) {
				queryString =  queryString + ' and Work_City__c like \'%' + searchLocation +'%\' ';
				}
			queryString =  queryString + ' order by Office_Phone__c';
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
 String queryString = 'Select Work_State__c, Office_Phone__c,Mentor_Cell_Phone__c, Operating_Group__c, Name, Manager_Name__c,  Last_Name__c,First_Name__c, Job_Title__c,Email__c ,fax__c,phone_ext__c,Work_State_Code__c,Work_City__c From TMN_User__c where Work_City__c like \'%' + searchLocation +'%\'  order by Office_Phone__c';
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
     tmlUserQuery = tmlUserQuery +  + 'Last_Name__c, First_Name__c,Job_Title__c,Email__c,phone_ext__c,Work_State_Code__c,Work_City__c From TMN_User__c  where Work_City__c = \'' + locationSelected +'\' '; 
        
         if (AlphaFilter != 'All') {
            tmlUserQuery =  tmlUserQuery +' and (Last_Name__c LIKE \'' + AlphaFilter + '%\' OR First_Name__c  LIKE \'' + AlphaFilter + '%\' )' ;
        }
        tmlUserQuery += ' order by Office_Phone__c';
        
        if(searchName!=null && searchName.equals('AdvanceSearch')){
        String QueryWhere = '';
  tmlUserQuery = 'Select Work_State__c, Office_Phone__c,Mentor_Cell_Phone__c, Operating_Group__c, Name, Manager_Name__c, First_Name__c, Last_Name__c, Job_Title__c,Email__c ,fax__c,phone_ext__c,Work_State_Code__c,Work_City__c From TMN_User__c ';
				if(City!=null && City.length() > 0) {
				QueryWhere =  BuildWhere( QueryWhere , '  Work_City__c like \'%' + City +'%\' ');
				}
				if(state!=null && state.length() > 0) {
				QueryWhere =  BuildWhere( QueryWhere , '   Work_State_Code__c like \'%' + state +'%\' ');
				}
				if(firstName!=null && firstName.length() > 0) {
				QueryWhere =  BuildWhere( QueryWhere , '  First_Name__c like \'%' + firstName +'%\' ');
				}
				if(lastName!=null && lastName.length() > 0) {
				QueryWhere =  BuildWhere( QueryWhere , '  Last_Name__c like \'%' + lastName +'%\' ');
				}
				if(operationGroup!=null && operationGroup.length() > 0) {
				QueryWhere =  BuildWhere( QueryWhere , '  Operating_Group__c like \'%' + operationGroup +'%\' ');
				}
				if(searchTitle!=null && searchTitle.length() > 0) {
				QueryWhere =  BuildWhere( QueryWhere , '  Job_Title__c like \'%' + searchTitle +'%\' ');
				}
			tmlUserQuery =  tmlUserQuery + QueryWhere + ' order by Office_Phone__c';
			System.debug('tmlUserQuery is ' + tmlUserQuery);
        }
    }
	
   public String BuildWhere(String QW, String Cond) {
        if (QW == '') {
            return ' WHERE ' + Cond;
        } else {
            return QW + ' AND ' + Cond;
        }
    }
public void search () {
	searchName ='AdvanceSearch';
	BuildQuery();
}

public void save() {
update setCon.getRecords();
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