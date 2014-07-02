public with sharing class CorpContract_CountReqFields {

    public CorpContract_CountReqFields(ApexPages.StandardController controller) {

    }
    public CorpContract_CountReqFields() {

    }    


    
    public static void DoCount(List<TMN_Corp_Contract__c> contracts){
        Set<string> Fields = new Set<string>();
        Fields.clear();
        
                for(Schema.FieldSetMember f :
                 SObjectType.TMN_Corp_Contract__c.FieldSets.ProcureReqFields.getFields()) {
                    Fields.Add(f.getFieldPath());
                    
            }
            
            for(TMN_Corp_Contract__c local: contracts){
                        Integer TotalFields = 0;
                        Integer TotalAnsweredFields = 0;
                        for(String f: Fields){
                                TotalFields += 1;
                                        
                                if(local.get(f) !=Null){
                                        {TotalAnsweredFields +=1 ;}
                                }
                        }
                        local.Total_Required_Feilds_Answered__c = TotalAnsweredFields;
                        local.Total_Required_Fields__c = TotalFields;
            }
            
            
        
                   
                        
    }
static testMethod void testMyController()
   {      
       TMN_Corp_Contract__c contract = new TMN_Corp_Contract__c();
       insert contract;       
   }   

}