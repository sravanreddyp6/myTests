public with sharing class shiftnote_summary_rpt {
    private final String PBS_REC_TYPE_ID = [select Id from RecordType where (DeveloperName='Person_Being_Served') and (SobjectType='Account') Limit 1].Id;
    public date StartDate {get; set;}
    public date EndDate {get; set;}
    public datetime  startDateTime{get; set;}
    public datetime  endDateTime{get; set;}    
    public string HCMCfilter {get; set;}
    public List<id> selectedPBS {get; set;}
    public List<account> allPBS {get; set;}
    public list<SelectOption> PBSlsit = new list<SelectOption>();
    public list<SelectOption> getPBSlsit(){ return PBSlsit ;}
    public boolean hasRunOnce {get; set;}
    public boolean showAllPbs {get; set;}
    
public list<ProgressNote_ActionPlanChildren_mjo__c> note_plan_joins = new list<ProgressNote_ActionPlanChildren_mjo__c>();
public list<ProgressNote_ActionPlanChildren_mjo__c> getNote_plan_joins(){

       
    return note_plan_joins;
}
    
    public list<progress_note__c> notes = new list<progress_note__c>();
    public list<progress_note__c> getnotes(){ 
         
        
                                                
        return notes ;
    
    }
    
    
    
    public shiftnote_summary_rpt() {
        allPBS = new List<account>();
        
        for(account a : [SELECT ID, FirstName, LastName, Owner.ID, Owner.Name, PersonContactId From Account WHERE RecordTypeID=:PBS_REC_TYPE_ID Order BY LastName]){
        
            PBSlsit.add(new SelectOption(a.PersonContactId, a.LastName + ', ' + a.FirstName)); 
            allPBS.add(a);
        }
        selectedPBS = new List<id>();
        hasRunOnce =false;
        showAllPbs = false;
    }

    public pagereference runReport(){
       if(selectedPBS.Size()==0    ){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                    'ERROR: Please Select at least one Person Being Served ');
                    ApexPages.addMessage(myMsg); 
                    notes.clear();
                    return null;
          // showAllPbs =true;
         //  selectAllPbs();
       
       }        
       hasRunOnce = true;
       TimeZone zone = UserInfo.getTimeZone();
       startDateTime = StartDate;
       if(startDateTime !=null){startDateTime = startDateTime.addSeconds((zone.getOffset(startDateTime)/1000)*-1);}
       
       
       endDateTime = endDate;
       if(endDateTime !=null){
           endDateTime = endDateTime.addSeconds((zone.getOffset(endDateTime)/1000)*-1);
           endDateTime = endDateTime.addDays(1);
           endDateTime = endDateTime.addseconds(-1);
       }
       map<string, boolean> isHCfilter = new map<string, boolean>();
       isHCfilter.put('true', true);
       isHCfilter.put('false',false);
       isHCfilter.remove(HCMCfilter);
       
       // RBO-265 - filter out Disregarded notes
        notes = [Select Name, ID, Start_Time__c, Person_Being_Served__c, End_Time__c, CreatedByid, Healthcare_Medical_Note__c, Narrative__c 
            From Progress_Note__c where 
                                        (
                                            (Start_time__c > :startDateTime OR End_time__c > :startDateTime ) 
                                                AND 
                                            (Start_time__c < :endDateTime OR End_time__c < :endDateTime)
                                        ) 
                                    
                                            AND Person_Being_Served__c In :selectedPBS 
                                            AND Healthcare_Medical_Note__c in :isHCfilter.Values() 
                                            AND RecordType.DeveloperName = 'Shift_Note'
                                            AND Disregard_note__c = false	
                                        ORDER BY CreatedDate ];      
     
        return null;
    }
    public pagereference selectAllPbs(){
        selectedPBS.clear();
        for(account a : allPBS){        
            selectedPBS.add(a.PersonContactId);
        }       
        return null;
    }   
    public pagereference clearSelectedPbs(){
        selectedPBS.clear();
     
        return null;
    }      

}