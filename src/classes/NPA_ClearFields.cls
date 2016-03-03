public with sharing class NPA_ClearFields{
//contructor
public  NPA_ClearFields(){

}

public static void CheckAndClear(List<Npa_Audit__c> audits){
    Set<string> BillingFields = new Set<string>();
    Set<string> QAFields = new Set<string>();
    Set<string> HHPFields = new Set<string>();
    BillingFields.clear();
    QAFields.clear();
    HHPFields.clear();
        
        //load the fields into the sets from the field sets
        for(Schema.FieldSetMember f :
             SObjectType.Npa_Audit__c.FieldSets.ClearBillingFields.getFields()) {
                BillingFields.Add(f.getFieldPath());
                
        }

        for(Schema.FieldSetMember f :
             SObjectType.Npa_Audit__c.FieldSets.ClearQaFields.getFields()) {
                QAFields.Add(f.getFieldPath());
                
        }
        
        for(Schema.FieldSetMember f :
             SObjectType.Npa_Audit__c.FieldSets.ClearHhpFields.getFields()) {
                HHPFields.Add(f.getFieldPath());
                
        }                        
        
        //go through each audit in the list and see if the Billing, QA, or HHP audit section fields are not chcked
        //when they are not checked the system needs to clear the data 
        //lastly this should only happen if the record's status = final    
        for(Npa_Audit__c local: audits){
            if(local.Status__c == 'Final'){
            system.debug('this is a final record');
            system.debug('Billing audit = '+local.Billing_Audit__c);
           // system.debug('this is a final record');
                if(! local.Billing_Audit__c){
                    system.debug('entered false billing audit check');
                    for(String f: BillingFields){
                      //  system.debug('in the loop now' + f);
                        system.debug(f+ ' field = ' +local.get(f));                        
                        local.put(f, null);
                        system.debug(f+ ' after nulling field = ' +local.get(f));   
                       // system.debug(local.get(f));                           
                    }//end if for billing section = false
                    }
                if(local.QA_Audit__c == false){
                system.debug('entered false QA audit check');
                    for(String f: QAFields){
                        system.debug(f+ ' field = ' +local.get(f));
                        local.put(f, null);         
                        system.debug(f+ ' after nulling field = ' +local.get(f));                   
                    }//end if for QA section = false
                    }
                if(local.HHP_Audit__c == false){
                system.debug('entered false HHP audit check');
                    for(String f: HHPFields){
                        system.debug(f+ ' field = ' +local.get(f));   
                        local.put(f, null);      
                        system.debug(f+ ' after nulling field = ' +local.get(f));                     
                    }//end if for HHP section = false  
                    system.debug('Billing audit = '+local.Billing_Audit__c);                                      
                }//end if for status = final            
            }
            
            system.debug('Billing audit = '+local.Billing_Audit__c);
            
            
            }


        

}
}