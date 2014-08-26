public with sharing class proj_redirect {
    public project__c cur_proj {get; set;}
    public proj_redirect(ApexPages.StandardController controller) {
        cur_proj = (Project__c)controller.getRecord();
    }
    public pageReference gotoProjPage(){
        string RTid = ApexPages.currentPage().getParameters().get('RecordType');
        string myID = cur_proj.id;
        //myID = myID.substring(0,18);
        if(RTid != null){
            RecordType RT = [select id, DeveloperName from RecordType Where ID =:RTid];
            if(RT.DeveloperName  == 'Neuro_Restorative'){
                PageReference ref = new PageReference('/apex/proj_nr_form');           
                return ref;
            } 
            else{
                system.debug('yepper');
                project__c p = new project__c();
                p.name = 'title';
                p.recordtypeid = RTid;
                insert p;
                
                Schema.DescribeSObjectResult r = Project__c.sObjectType.getDescribe();
                String keyPrefix = r.getKeyPrefix();
                PageReference ref = new PageReference('/'+p.id + '/e?retURL=/' +p.id);
                //PageReference ref = new PageReference('/'+keyPrefix +'/e?id='+p.id+'&retURL=/'+p.id);           
                return ref;                
            }       
        
        
        }

        if(myID != null){
            if(cur_proj.recordtype.DeveloperName =='Neuro_Restorative'){
                PageReference ref = new PageReference('/apex/proj_nr_form?id=' + myID);           
                return ref; 
            }
            PageReference ref = new PageReference('/apex/Project_VS_Page_Layout?id=' + myID);           
            return ref;  
        }                  
        return null;
    }
}