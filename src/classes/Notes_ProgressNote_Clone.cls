public with sharing class Notes_ProgressNote_Clone{
    public Progress_Note__c thePN = new Progress_Note__c();
    public Progress_Note__c getthePN(){return thePN;}

    public Progress_Note__c newPN = new Progress_Note__c();
    public Progress_Note__c getnewPN(){return newPN;}
    
    public Progress_Note__c holdPN = new Progress_Note__c();
    public Progress_Note__c getholdPN(){return holdPN;}  
    
    public Notes_ProgressNote_Clone(ApexPages.StandardController controller) {
      
        this.thePN = (Progress_Note__c)controller.getRecord();
        
        this.holdPN = (Progress_Note__c)Database.query(getCreatableFieldsSOQL(thePN.id));
    }   
    public PageReference  MyClone(){
        try{       
            newPN = holdPN.clone(false, true);
            newPN.locked__c = false;
            newPN.Status__c = 'In Progress';
            for(Schema.FieldSetMember f : SObjectType.Progress_Note__c.FieldSets.NewForm.getFields()) {
                string myfield = f.getFieldPath();
                newPN.put(myfield ,thePN.get(myfield));
            }
        
            insert newPN;
                
                list<ProgressNote_ServiceAssignment_mJO__c> newSTG = new list<ProgressNote_ServiceAssignment_mJO__c>();
                for(ProgressNote_ServiceAssignment_mJO__c local : 
                    [Select Short_Term_Goal__c, Objective__c, Intervention__c 
                     From ProgressNote_ServiceAssignment_mJO__c 
                     Where Progress_note__c = :thePN.id]){
                    newSTG.add(new ProgressNote_ServiceAssignment_mJO__c(Short_Term_Goal__c = local.Short_Term_goal__c,
                                                                         Objective__c = local.Objective__c,
                                                                         Intervention__c = local.Intervention__c,
                                                                         Progress_note__c = newPN.id));
                }
    
            insert newSTG;    
            
            return new PageReference('/' + newPN.id) ;
        
        }
        
        catch(DMLException e){newPN.addError(e.getMessage());}
            
            return null;        
    }
   
   public string getCreatableFieldsSOQL(String myid){
         
        String selects = '';
         
       // if (whereClause == null || whereClause == ''){ return null; }
         
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get('Progress_Note__c').getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
         
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
         
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
             
        }
        system.debug('hereeeee--------------'+ 'SELECT ' + selects + ' FROM Progress_Note__c WHERE id= \'' + myid + '\'');
        return 'SELECT ' + selects + ' FROM Progress_Note__c WHERE id= \'' + myid + '\'' ;
         
    }    
}