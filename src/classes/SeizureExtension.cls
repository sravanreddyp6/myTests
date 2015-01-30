public with sharing class SeizureExtension {
public Id pageId; 
    
    public Seizure__c seizure {
      get{
          if (seizure == null) {
                seizure = new Seizure__c();
                seizure.Service_Assignment__c = this.pageId;
                seizure.Start_DateTime__c = null;
                seizure.End_DateTime__c = null;
                seizure.Comments__c = null;
                seizure.Observed_By__c = UserInfo.getUserId();
          }
          return seizure;
      }
      set; }
    public List<Seizure__c> seizures { get; set; }
  
  
    public SeizureExtension(ApexPages.StandardController controller) {
        this.pageId = controller.getid();
        
        showAddSeizure();
        populateSeizures();
    }
    
    public SeizureExtension(PersonalRecordController controller){
        this.pageId = Id.valueOf(controller.saId);
        showAddSeizure();
        populateSeizures();
    }
    
    
    public void showAddSeizure() {
        seizure = new Seizure__c();
        seizure.Service_Assignment__c = this.pageId;
        seizure.Start_DateTime__c = null;
        seizure.End_DateTime__c = null;
        seizure.Comments__c = null;
        seizure.Observed_By__c = UserInfo.getUserId();
    }
    
    public void saveSeizure() {
        System.debug('Before upsert, seizure: ' + this.seizure);
        if (String.valueOf(this.seizure.Id) == '') {
            this.seizure.Id = null;
        }
        upsert this.seizure;
        populateSeizures();
        showAddSeizure();
    }
    
    public void populateSeizures() {
        this.seizures = [select id, Start_DateTime__c, End_DateTime__c, Observed_By__c, Comments__c, Duplicate_Entry__c from Seizure__c where Service_Assignment__c = : this.pageId 
        //And Duplicate_Entry__c = false 
        order by Start_DateTime__c desc limit 6];
    }
    
    public void showEditSeizure() {
        string seizureId = ApexPages.CurrentPage().getParameters().get('seizureId');
        this.seizure = [select id, Start_DateTime__c, End_DateTime__c, Observed_By__c, Comments__c, Duplicate_Entry__c from Seizure__c where id = : seizureId];
    }
    
    @RemoteAction
    public static boolean findDuplicateSeizure(string seizureStart, string seizureEnd, Id saId, Id seizureId) {
        DateTime st = Datetime.parse(seizureStart);
        DateTime en = Datetime.parse(seizureEnd);
        boolean dupefound = false;
        List<Seizure__c> duplicateSeizure = [SELECT Id FROM Seizure__c WHERE Service_Assignment__c = :saId 
                                              AND ( ( Start_DateTime__c <= : st And End_DateTime__c > : st )   // one start at the same time OR after but the before the end of an existing one
                                              Or ( Start_DateTime__c >= : st And End_DateTime__c <= : en ) )   // the one being entered is not marking an existing one as the duplicate
                                              AND Duplicate_Entry__c = false
                                              AND Id != : seizureId                               // exclude the one itself from consideration when editing a record.
                                              limit 1];
                        
        if(duplicateSeizure.size() > 0) {
            dupeFound = true;
        }
        return dupeFound;
   }
    
    
}