public with sharing class Notes_Person_Tab {
    public ID currentLogedUserId = UserInfo.getUserId();
  //  public Set<ID> acctsCurrentUserIsMemberOf = new Set<ID>();
  //  public Set<ID> getacctsCurrentUserIsMemberOf(){return acctsCurrentUserIsMemberOf ;}

    public Notes_Person_Tab(){
        LoadData();
    }

    public void LoadData(){
       /* should be added at a time when account teams become used!
        for(AccountTeamMember local :[Select accountId from accountTeamMember where userId=:currentLogedUserId]){
            acctsCurrentUserIsMemberOf.add(local.accountID);
        }  
        
        */      
    }
    
    public List<Plan_ServiceAssignment_MJO__c> getMyPlans(){
        Map<string, Plan_ServiceAssignment_MJO__c> distinctPlans = new Map<string, Plan_ServiceAssignment_MJO__c>();
        
        //where clause should be added at a time when account teams become used!
        /*
        Where Service_Assignment__r.Person_Being_Served__r.OwnerId =:currentLogedUserId 
                        OR 
                    Service_Assignment__r.Person_Being_Served__r.AccountId IN :acctsCurrentUserIsMemberOf
        
        
        */
        for(Plan_ServiceAssignment_MJO__c local :
            [Select id, Service_Assignment__c, Service_Assignment__r.Person_Being_Served__c,  Short_term_Goal__r.Plan__r.OwnerID,
             Service_Assignment__r.Admission__r.State__c, Service_Assignment__r.Admission__c,
             Short_term_Goal__r.Plan__c, Guardian1_Name__c , Guardian_Phone_Number__c, Short_term_Goal__r.Plan__r.Plan_Expiration_Date__c 
                From Plan_ServiceAssignment_MJO__c 
                    Where Short_Term_Goal__r.Plan__r.Status__c = 'Active' AND Service_Assignment__r.Status__c = 'Active'])
        {                
            string tmp = string.Valueof(local.Service_Assignment__c) + string.Valueof(local.Short_term_Goal__r.Plan__c) ;
            distinctPlans.put(tmp, local);
        }
        return distinctPlans.Values();
    
    }
    
    public List<Service_Assignment__c> getMyAssessmentOnlyServiceAssignments(){
        /*
        
        (Person_Being_Served__r.OwnerID =:currentLogedUserID
                            OR
                        Person_Being_Served__r.AccountId IN :acctsCurrentUserIsMemberOf)
                            AND
        
        */    
        List<Service_Assignment__c> localServiceAssignments = new List<Service_Assignment__c>();
            
            for(Service_Assignment__c local :
                [Select id, Admission__c, Person_Being_Served__r.OwnerID,
                 Person_Being_Served__c, Person_Being_Served__r.Guardian_Phone_Number__c, Person_Being_Served__r.Guardian1_Name__c,
                  Admission__r.State__c, Name 
                    From Service_Assignment__c
                        Where RecordType.Name = 'Assessment Only' AND Status__c = 'Active'])
            {
               localServiceAssignments.add(local); 
            }
        
        
        return localServiceAssignments;
    
    }
}