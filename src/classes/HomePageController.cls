public with sharing class HomePageController {
    public final String OperatingGroup = [select operating_group__c from user where id=:UserInfo.getUserId() limit 1].operating_group__c;

    public String GroupChatterLabel{
        get{
            Home_Page_Settings__c hps = Home_Page_Settings__c.getInstance();
            if(OperatingGroup == 'Redwood'){
                GroupChatterLabel = hps.Redwood_Chatter_Group_Label__c;
            }
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
            if(OperatingGroup == 'Redwood'){
                GroupChatterId = hps.Redwood_Chatter_Id__c;
            }
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

  public Map<String, String> personsBeingServedViews {
  	get {
  		if (personsBeingServedViews != null) {
  			return personsBeingServedViews;
  		}
  		personsBeingServedViews = new Map<String, String>();
  		ApexPages.StandardSetController con = new ApexPages.StandardSetController(Database.getQueryLocator(
  		    'SELECT ID FROM Account'
  		));
  		SelectOption[] options = con.getListViewOptions();
  		for (SelectOption option : options) {
  			if (option.getLabel().toLowerCase().indexOf('all persons being served')!=-1) {
  				personsBeingServedViews.put('all', option.getValue());
  			} else if (option.getLabel().toLowerCase().indexOf('recently viewed')!=-1) {
  				personsBeingServedViews.put('recent', option.getValue());
  			} else if (option.getLabel().toLowerCase().indexOf('new this week')!=-1) {
                personsBeingServedViews.put('new', option.getValue());
  			} else if (option.getLabel().toLowerCase().indexOf('my persons being served')!=-1) {
                personsBeingServedViews.put('my', option.getValue());
  			}
  		}
  		System.debug('Views: ' + personsBeingServedViews);
  		return personsBeingServedViews;
  	}
  	set;
  }

  public List<Referral_Reports__c> refReports {
    get {
      return (refReports != null) ? refReports :
        Referral_Reports__c.getall().values();
    }
    private set;
  }
  
  public List<Report> reports {
    get {
      return (reports != null) ? reports :
        [SELECT Name, Id, description, DeveloperName, SystemModstamp FROM report Where description Like '%#notes%' ORDER BY name];
  	}
  }
  public List<Task> myTasks {
    get { return populateTasks(); }
    private set;
  }
  public List<Approval> Approvals {
  	get { return populateApprovals(); }
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
    private List<Approval> populateApprovals() {
    List<Approval> approvals = [select ApproveComment,CreatedDate,OwnerId,ParentId,RequestComment,Status from Approval where OwnerId=:UserInfo.getUserId()];
    return approvals;
     }
}