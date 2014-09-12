/*******************************************************************************
 Name           : REF_HomePageController
 Created By     : Mark Klinski (Appirio)
 Created Date   : 5/10/13
 Description    : Controller for Referrals Home Page
*******************************************************************************/

public with sharing class REF_HomePageController {
    public String OperatingGroup {
        get{
            OperatingGroup=[select operating_group__c from tmn_user__c where salesforce_user_account__c=:UserInfo.getUserId() limit 1].operating_group__c;
            if(operatinggroup!=null && operatinggroup!='' && operatingGroup.equalsIgnoreCase('Care Meridian')){
                operatinggroup = 'CareMeridian';
            }
            return operatinggroup;
        }
        set;
    }
 
    public String GroupChatterLabel{
        get{
            Home_Page_Settings__c hps = Home_Page_Settings__c.getInstance();
            //default to Redwood
            GroupChatterLabel = hps.Redwood_Chatter_Group_Label__c;
            
            if(OperatingGroup == 'CareMeridian'){
                GroupChatterLabel = hps.CareMeridian_Chatter_Group_Label__c;
            }
            if(OperatingGroup == 'Cambridge'){
                GroupChatterLabel = hps.Cambridge_Chatter_Group_Label__c;
            }
            if(OperatingGroup == 'NeuroRestorative'){
                GroupChatterLabel = hps.Neuro_Chatter_Group_Label__c;
            }
            return GroupChatterLabel;
        }
        set;
    }
    
    public String GroupChatterId{
        get{
            Home_Page_Settings__c hps = Home_Page_Settings__c.getInstance();
            //default to Redwood
            GroupChatterId = hps.Redwood_Chatter_Id__c;
            if(OperatingGroup == 'CareMeridian'){
                GroupChatterId = hps.CareMeridian_Chatter_Group_Id__c;
            }
            if(OperatingGroup == 'Cambridge'){
                GroupChatterId = hps.Cambridge_Chatter_Group_Id__c;
            }
            if(OperatingGroup == 'NeuroRestorative'){
                GroupChatterId = hps.Neuro_Chatter_Group_Id__c;
            }
            return GroupChatterId;
        }
        set;
    }
    public string referralPrefix {
        get { 
                Schema.DescribeSObjectResult d = Referral__c.sObjectType.getDescribe();
                return d.getKeyPrefix();
        }
        private set;
    }
    
  public List<CollaborationGroupFeed> listESDNews {
    get { return populateESDNews(eSDChatterGroupId); }
    private set;
  }

  public List<CollaborationGroupFeed> listGroupChatter {
    get { return populateESDNews(GroupChatterId); }
    private set;
  }

  public List<Referral_Reports__c> refReports {
    get {
      return (refReports != null) ? refReports :
        Referral_Reports__c.getall().values();
    }
    private set;
  }
  public List<Task> myTasks {
    get { return populateTasks(); }
    private set;
  }
  public Integer listESDNewsCount { get; private set; }

  private static final Id eSDChatterGroupId = Home_Page_Settings__c.getInstance().ESD_Chatter_Feed_ID__c;
  private static final Id whatsNewChatterGroupId = Home_Page_Settings__c.getInstance().Redwood_Chatter_ID__c;

  private List<CollaborationGroupFeed> populateESDNews(Id entityId) {
    List<CollaborationGroupFeed> tempListESDNews;

    tempListESDNews = [select Id, Body, CreatedBy.Name, CreatedDate
                        from CollaborationGroupFeed
                        where parentId = :entityId
                        order by createdDate DESC, Id DESC
                        limit 5];

    listESDNewsCount = tempListESDNews.size();

    return tempListESDNews;
  }
    
    private List<Task> populateTasks() {
        List<Task> tasks = [select id, subject, status, ActivityDate, Priority from Task 
                            where OwnerId=:UserInfo.getUserId() and status != 'Completed' and RecordTypeId = :Utility.getRecordTypeForTask('Referral Tasks')
                            order by ActivityDate desc, Priority limit 25];
        return tasks;
    }
  public List<Report> refReports2 {
    get {
            List<Report> refrportlst = new List<Report>();
            system.debug('op grounp ' + OperatingGroup  );
            if(OperatingGroup != null){
                set<string> okRefRpts = getReportsToShow(OperatingGroup );
                system.debug('reports in scope - ' + okRefRpts);
                for(Report rpt:report([SELECT AccessType,Id,IsReadonly,Name,DeveloperName,Type FROM Folder WHERE Type = 'Report' AND DeveloperName = 'Referrals'].id, null)){
                    
                        if(okRefRpts.contains(rpt.DeveloperName)){
                            refrportlst.add(rpt);
                            }
                }
            }
            return refrportlst ;
    }
    private set;
  }   
  public list<VF_Reports__c> getrefVfReports(){
     return [SELECT Name,Id,Name__c,Description__c,link__c, groups__c from VF_Reports__c Where groups__c LIKE '%#Referral%'];
  } 
    public set<string> getReportsToShow(string og){
        set<string> items = new set<string>();
        
        items.add('All_Active_Referrals_Report');
        items.add('All_Referrals');
        items.add('Closed_Referral_Tracking');
        items.add('Locations_Working_Ref_by_Ref_Number');
        items.add('Referral_Conversion_Time_Report');
        items.add('Referrals_By_Location_Working_Referral');
        items.add('Referrals_Requiring_Action');
        
        if(og == 'Cambridge'){
            items.add('Active_Referrals_With_Diagnosis');
            items.add('Active_Referrals_With_Diagnosis_Axis');
            items.add('Daily_Referrals');
            items.add('Red_Flagged_Referrals');
            items.add('Weekly_Referrals');
            items.add('Avatar_GA_Referrals');
            items.add('GA_Referrals_FIT_Program');        
        }
        if(og == 'Redwood'){
            items.add('Active_Referrals_With_Diagnosis');
            items.add('Active_Referrals_With_Diagnosis_Axis');
            items.add('Daily_Referrals');
            items.add('Red_Flagged_Referrals');
            items.add('Weekly_Referrals');        
        }
        if(og == 'CareMeridian'){
        
        }
        if(og == 'NeuroRestorative'){
            items.add('Daily_Referrals');
            items.add('Weekly_Referrals');                    
        } 
        
    
    
        return items;
    
    }    
     public List<Report> report(Id ownId,String ReportText){
    String query = 'SELECT Name, Id,OwnerId, description, DeveloperName, SystemModstamp FROM report where OwnerId=:ownId';
    if(ReportText!=null && ReportText=='ESDAct'){
        query+=' and description like \'%#notes%\'' ;
    } else if (ReportText != null && ReportText=='Docs') {
        query+=' and (description like \'%Case Document%\' or description like \'%Fidelity Document%\')';
    }
    
    query+= ' order by name';
    
    List<Report> tempreport = database.query(query);
    return tempreport;
 }
}