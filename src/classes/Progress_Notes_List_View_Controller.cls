public with sharing class Progress_Notes_List_View_Controller {
    private String Querystring;
    private Integer pageSize =20;
    private integer counter=0; 
    private integer prNum=0;
    public integer totalSize;
    public integer actualsize{get;set;}
    public id selectedpnid{get;set;}
    public string pbsname{get;set;}
    public string saname{get;set;}
    public boolean displayname{get;set;}
    public boolean displaypbs{get;set;}
    public Id admissionId { get; set; }
    public Id pbsid { get; set; }
    public Id said { get; set; }
    public Progress_Notes_List_View_Controller (){
        said = Apexpages.currentPage().getParameters().get('saID');
        pbsid = Apexpages.currentPage().getParameters().get('PBSID');
        admissionId = Apexpages.currentPage().getParameters().get('admission');
    }
    public ApexPages.StandardSetController ProgressNoteController {
        get{
            displaypbs = true;
            said = Apexpages.currentPage().getParameters().get('saID');
            pbsid = Apexpages.currentPage().getParameters().get('PBSID');
            admissionId = Apexpages.currentPage().getParameters().get('admission');
            if(Apexpages.currentPage().getParameters().get('PBSID') !=null  && Apexpages.currentPage().getParameters().get('pbsname')!=null){
                pbsname = Apexpages.currentPage().getParameters().get('pbsname');
                if(pbsname!=''){
                    displayname = true;
                    displaypbs =false;
                }  
                if(ProgressNoteController == null){
                    Querystring='SELECT id,Name,CreatedDate,Service_Assignment__c,Disregard_Note__c,Start_Time__c,End_Time__c,Progress__c,status__C,CreatedBy.Name,Service_Assignment__r.person_being_served__C,Person_Being_Served__r.name FROM Progress_Note__c where service_assignment__r.person_being_served__C = :pbsid ORDER BY CreatedDate DESC Limit 500';
                    ProgressNoteController = new ApexPages.StandardSetController(Database.getQueryLocator(Querystring));
                    ProgressNoteController.setPageSize(pageSize);
                    actualsize  = ProgressNoteController.getrecords().size();
                    totalSize = [select count() from Progress_Note__c where service_assignment__r.person_being_served__C = :pbsid Limit 500];
                    prNum =1;
                    if(actualsize==0){
                        prNum = 0;
                        totalSize = 0;
                        counter= 0;
                    }
                }                
            } else if(Apexpages.currentPage().getParameters().get('saID') !=null&& Apexpages.currentPage().getParameters().get('saname') !=null){
                displayname = false;
                saname = Apexpages.currentPage().getParameters().get('saname');
                if(ProgressNoteController == null ){
                    Querystring='SELECT id,Name,CreatedDate,Service_Assignment__c,Disregard_Note__c,Start_Time__c,End_Time__c,Progress__c,status__C,CreatedBy.Name,Service_Assignment__r.name  FROM Progress_Note__c where service_assignment__c = :said ORDER BY CreatedDate DESC Limit 500';
                    ProgressNoteController = new ApexPages.StandardSetController(Database.getQueryLocator(Querystring));
                    ProgressNoteController.setPageSize(pageSize);
                    actualsize  = ProgressNoteController.getrecords().size();
                    totalSize = [select count() from Progress_Note__c where service_assignment__c = :said Limit 500];
                    prNum =1;
                    if(actualsize==0){
                        prNum = 0;
                        totalSize = 0;
                        counter= 0;
                    }
                }
            } 
            if(ProgressNoteController == null){
                Querystring= 'SELECT id,Name,CreatedDate,Service_Assignment__c,Disregard_Note__c,Start_Time__c,End_Time__c,Progress__c,status__C,CreatedBy.Name FROM Progress_Note__c ORDER BY CreatedDate DESC Limit 500';
                ProgressNoteController = new ApexPages.StandardSetController(Database.getQueryLocator(Querystring));
                ProgressNoteController.setPageSize(pageSize);
                actualsize  = ProgressNoteController.getrecords().size();
                prNum = 1;
            }
            return ProgressNoteController;
        }set;
    }
    public Progress_Notes_List_View_Controller (ApexPages.StandardSetController c) {  }
    
    public void firstPage()
    {
        ProgressNoteController.first();
        counter = 0;
        prNum = 1;
        if(totalSize<pageSize){
            actualsize=totalSize;
        }else
            actualsize= (counter/pageSize + 1)*pageSize;
    } 
    
    public void lastPage()
    {
        ProgressNoteController.last();
        counter = totalSize - math.mod(totalSize, pageSize);   
        if(counter==totalSize){
        	counter-= pageSize;
            if(counter<0){
                counter=0;
            }
        }      
        prNum = (totalSize - math.mod(totalSize, pageSize))+1;
        if(prNum>totalSize){
            prNum-=pageSize;
        }
        actualsize = totalSize ;
    }
    
    public void next()
    {
        if(ProgressNoteController.getHasNext())
        {
            ProgressNoteController.next();
            counter += pageSize;
            prNum  += pageSize;        
            actualsize += pageSize;
            if(actualsize>=totalSize){
                actualsize=totalSize;
            } 
        }
    }
    
    public void prev()
    {
        if(ProgressNoteController.getHasPrevious())
        {
            ProgressNoteController.previous();
            counter -= pageSize;
            prNum  -= pageSize;
            actualsize= (counter/pageSize + 1)*pageSize;
        }
    }
    public Integer getPageNumber() {
        if(totalSize==0){
            return counter/pageSize;
        }else{
            return counter/pageSize + 1;
        }
    }
    
    public Integer getTotalPages() {
        if (math.mod(totalSize, pageSize ) > 0) {
            return totalSize/pageSize + 1;
        } else {
            return (totalSize/pageSize );
        }
    }
    
    public Integer getTotalSize() {
        return totalSize;
    }
    
    public Integer getProgSize() {
        if (totalSize==0) {
            return prNum=0;
        } else {
            return prNum;
        }
        
    }
    
    public List<Progress_Note__c> getProgressNotes()
    {
        return (List<Progress_Note__c>)ProgressNoteController.getRecords();
    }
    
    public PageReference editcardnotes(){
        PageReference pnPage = new PageReference('/apex/ProgressNote_DetailPage?id='+selectedpnid);
        pnPage.setRedirect(true);
        return pnPage;
    }
    
    
}