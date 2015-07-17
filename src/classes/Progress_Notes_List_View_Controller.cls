public with sharing class Progress_Notes_List_View_Controller {
    
    private String Querystring;
    private Integer pageSize =20;
    private integer counter=0; 
    private integer prNum=0;
    public integer totalSize;
    public integer actualsize{get;set;}
    public Progress_Notes_List_View_Controller (){totalSize = [select count() from Progress_Note__c Limit 500];}
    public id selectedpnid{get;set;}
    public string notes='';
    public ApexPages.StandardSetController ProgressNoteController {
        get{
            if(ProgressNoteController == null && notes!=''){
                Querystring='SELECT id,Name,CreatedDate,Service_Assignment__c,Disregard_Note__c,Start_Time__c,End_Time__c,Progress__c,CreatedBy.Name FROM Progress_Note__c where Name LIKE \'%'+String.escapeSingleQuotes(notes)+ '%\' ORDER BY Name Limit 500';
                ProgressNoteController = new ApexPages.StandardSetController(Database.getQueryLocator(Querystring));
                ProgressNoteController.setPageSize(pageSize);
                actualsize  = ProgressNoteController.getrecords().size();
                totalSize = [select count() from Progress_Note__c Limit 500];
                prNum =1;
                if(actualsize==0){
                    prNum = 0;
                    totalSize = 0;
                    counter= 0;
                }
            }
            if(ProgressNoteController == null){
                Querystring= 'SELECT id,Name,CreatedDate,Service_Assignment__c,Disregard_Note__c,Start_Time__c,End_Time__c,Progress__c,CreatedBy.Name FROM Progress_Note__c ORDER BY CreatedDate DESC Limit 500';
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
        actualsize= pageSize;
    }
    
    public void lastPage()
    {
        ProgressNoteController.last();
        counter = totalSize - math.mod(totalSize, pageSize);
        prNum = (totalSize - math.mod(totalSize, pageSize))+1;
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
    
    public List<Progress_Note__c> getProgressNotes()
    {
        return (List<Progress_Note__c>)ProgressNoteController.getRecords();
    }
    
    public PageReference editcardnotes(){
        
        PageReference pnPage = new PageReference('/apex/Notes_Progressnote_AZ_OPT?Mode=Edit&id='+selectedpnid);
        pnPage.setRedirect(true);
        return pnPage;
    }
    
    public Pagereference searchProgressNotes(){
        notes = Apexpages.currentPage().getParameters().get('progressnotename');
        ProgressNoteController=null;
        ProgressNoteController.setPageNumber(1);
        if(actualsize>pageSize){
            pageSize = actualsize;
        }
        return null;
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
}