public with sharing class PDMController {

 Public Integer size{get;set;}
  Public Integer noOfRecords{get; set;}
   public ApexPages.StandardSetController setCon {
        get{
            if(setCon == null){
                size = 1;
                String queryString = 'Select Work_State__c, Office_Phone_Number__c,Cell_Number__c, Operating_Group__c, Name, Manager_Name__c, Last_Name__c, Job_Title__c From TMN_User__c order by Office_Phone_Number__c';
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                setCon.setPageSize(size);
                noOfRecords = setCon.getResultSize();
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
 String queryString = 'Select Work_State__c, Office_Phone_Number__c,Cell_Number__c, Operating_Group__c, Name, Manager_Name__c, Last_Name__c, Job_Title__c From TMN_User__c where Name like \'%' + searchEmployee +'%\'  order by Office_Phone_Number__c';
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                setCon.setPageSize(size);
 noOfRecords = setCon.getResultSize();

}

public void searchByLocation () {
	String location = Apexpages.currentPage().getParameters().get('selectedLocation');
    searchLocation = location;
 String queryString = 'Select Work_State__c, Office_Phone_Number__c,Cell_Number__c, Operating_Group__c, Name, Manager_Name__c,  Last_Name__c, Job_Title__c From TMN_User__c where Work_State__c like \'%' + location +'%\'  order by Office_Phone_Number__c';
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                setCon.setPageSize(size);
 noOfRecords = setCon.getResultSize();

}

public void save() {
update setCon.getRecords();
}
public String searchEmployee {set;get;}
public String searchLocation {set;get;}
     
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