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
}