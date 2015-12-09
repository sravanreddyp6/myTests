public without sharing class DSP_shiftnote_summary_rpt {
    public date StartDate {get; set;}
    public date EndDate {get; set;}
    public string HCMCfilter {get; set;}
    public List<id> selectedPBS {get; set;}
    public list<SelectOption> PBSList = new list<SelectOption>();
    public list<SelectOption> getPBSList(){ return PBSList ;}
    public boolean hasRunOnce {get; set;}
    //    public string pdfRunDateTimeString { get; set; }
    public string opGroup { get; private set; }
    public list<String> currentPBSList {get; set;}
    public transient list<map<String, Object>> notes;
    public list<map<String, Object>> getnotes(){
        return notes ;
    }
    
    public transient Map<string, List<map<String, Object>>> Note_Goals;
    public Map<string, List<map<String, Object>>> getNote_Goals(){
        return Note_Goals;
    }
    
    public transient Map<string, List<map<String, Object>>> Note_Objs;
    public Map<string, List<map<String, Object>>> getNote_Objs(){
        return Note_Objs;
    }
    
    public DSP_shiftnote_summary_rpt() {    
        opGroup = [ select operating_group__c from user where id = :UserInfo.getUserId()].operating_group__c;
        hasRunOnce =false;
        
        selectedPBS = Apexpages.currentPage().getParameters().containsKey('selectedPBS') ? String.valueOf(Apexpages.currentPage().getParameters().get('selectedPBS')).split(',') : new List<id>();
        currentPBSList = (list<String>) JSON.DeSerialize(Apexpages.currentPage().getParameters().get('currentPBSList'), list<String>.class);
        for (Contact c : [select id, name from contact where id in : currentPBSList order by name]){
            PBSList.add(new SelectOption(c.id, c.name));
        }
        
    }
    
    public pagereference runReport(){
        boolean inputErr = false;
        ApexPages.getMessages().clear();
        
        if(startDate == null || endDate == null   ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                                                       'Please choose valid start and end dates'));
            inputErr = true;
        } else if ( startDate > endDate ) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                                                       'Please choose valid start and end dates'));
            inputErr = true;
        }
        if(selectedPBS.Size()==0    ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                                                       'Please select at least one Person Being Served'));
            inputErr = true;
        }
        
        if ( inputErr ) {
            return null;
        }
        
        hasRunOnce = true;
        TimeZone zone = UserInfo.getTimeZone();
        datetime startDateTime = StartDate;
        if(startDateTime !=null){startDateTime = startDateTime.addSeconds((zone.getOffset(startDateTime)/1000)*-1);}
        
        datetime endDateTime = endDate;
        if(endDateTime !=null){
            endDateTime = endDateTime.addSeconds((zone.getOffset(endDateTime)/1000)*-1);
            endDateTime = endDateTime.addDays(1);
            endDateTime = endDateTime.addseconds(-1);
        }
        
        // EC-196 - CM flag is always false for filtering out Healthcare/Medical note
        if ( opGroup == 'Care Meridian')
            HCMCfilter = 'false';
        
        map<string, boolean> isHCfilter = new map<string, boolean>();
        isHCfilter.put('true', true);
        isHCfilter.put('false',false);
        isHCfilter.remove(HCMCfilter);
        
        // RBO-265 - filter out Disregarded notes
        Set<ID> noteIDs = new Set<id>();
        this.notes = new list<map<String, Object>>();
        this.Note_Goals = new Map<string, List<map<String, Object>>>();
        this.Note_Objs = new Map<string, List<map<String, Object>>>();
        
        for(Progress_Note__c pn: [Select Name, ID, Start_Time__c, Person_Being_Served__r.name, End_Time__c, CreatedBy.Name, Healthcare_Medical_Note__c, Narrative__c 
                                  From Progress_Note__c where 
                                  ((Start_time__c > :startDateTime OR End_time__c > :startDateTime )  AND 
                                   (Start_time__c < :endDateTime OR End_time__c < :endDateTime) ) 
                                  AND Person_Being_Served__c In :selectedPBS 
                                  AND Healthcare_Medical_Note__c in :isHCfilter.Values() 
                                  AND RecordType.DeveloperName = 'Shift_Note'
                                  AND Disregard_note__c = false
                                  ORDER BY start_time__c ]){	// new ordering per RPII-35
                                      notes.add(new map<string, object>{'Name' => pn.name,
                                          'ID' => pn.ID,
                                          'Start_Time__c' => pn.Start_Time__c.format(),
                                          'Person_Being_Served__r.name' => pn.Person_Being_Served__r.name,
                                          'End_Time__c' => pn.End_Time__c.format(),
                                          'CreatedBy.Name' => pn.CreatedBy.Name,
                                          'Healthcare_Medical_Note__c' => pn.Healthcare_Medical_Note__c, 
                                          'Narrative__c' => pn.Narrative__c });
                                      noteIDs.add(pn.id);            	                               
                                      this.Note_Goals.put(pn.id, new list<map<string, object>>());
                                  }
        
        set<id> goalIDs = new set<id>();
        for(ProgressNote_ActionPlanChildren_mjo__c item: [Select Goal__r.Description__c, Goal__c, Progress_note__c 
                                                          From ProgressNote_ActionPlanChildren_mjo__c 
                                                          Where ProgressNote_ActionPlanChildren_mjo__c.Progress_Note__c in:noteIDs AND Objective__c = null
                                                          Order By Goal__r.Sort_Order__c]){
                                                              this.Note_Goals.get(item.Progress_note__c).add(new map<string, object>{'Goal__r.Description__c' => item.Goal__r.Description__c,
                                                                  'Goal__c' => item.Goal__c,
                                                                  'Progress_note__c' => item.Progress_note__c});
                                                              goalIDs.add(item.goal__c);          
                                                              string tmp = string.valueof(item.Progress_note__c) + '-' + string.valueof(item.Goal__c);
                                                              this.Note_Objs.put(tmp, new list<map<string, object>>());
                                                          }
        
        for(ProgressNote_ActionPlanChildren_mjo__c item: [Select Progress_note__c, Objective__r.Description__c, Objective__r.Action_Plan_Goal__c
                                                          From ProgressNote_ActionPlanChildren_mjo__c 
                                                          Where ProgressNote_ActionPlanChildren_mjo__c.Progress_Note__c in:noteIDs AND Objective__r.Action_Plan_Goal__c in :goalIDs
                                                          Order By Objective__r.Sort_Order__c] ){
                                                              string tmp = string.valueof(item.Progress_note__c) + '-' +  string.valueof(item.Objective__r.Action_Plan_Goal__c);
                                                              // RBO-277 - an objective associated without its parent goal can cause an issue here.  Check for existence first.
                                                              if (this.Note_Objs.containskey(tmp) )
                                                                  this.Note_Objs.get(tmp).add(new map<string, object>{'Objective__r.Description__c' => item.Objective__r.Description__c,
                                                                      'Objective__r.Action_Plan_Goal__c' => item.Objective__r.Action_Plan_Goal__c,
                                                                      'Progress_note__c' => item.Progress_note__c});
                                                          }
        
        return null;
    }
    
    /* public PageReference runPdf() { 
Datetime pdfRunDateTime = System.now();
pdfRunDateTimeString = pdfRunDateTime.format('MM/dd/yyyy, h:mm:ss a');
PageReference toPdfPage = new PageReference('/apex/DSP_shiftnote_summary_rpt_PDF');
toPdfPage.setRedirect(false);
return toPdfPage;
} */
    
    public PageReference cancelToNewRun() {
        PageReference pageRef = new PageReference('/apex/DSP_shiftnote_summary_rpt');
        pageRef.getParameters().put('currentPBSList', json.serialize(this.currentPBSList));
        pageRef.setRedirect(true);
        return pageRef;
    }
    
}