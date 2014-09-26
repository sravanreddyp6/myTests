public with sharing class NpaTrigger_Utilities {
	public NpaTrigger_Utilities() {
		
	}
	public static void setDefaults(List<Npa_Audit__c> audits){
		set<string> careFields = new set< string>();
		set<string> ARY_PER_Fields = new set<string>();
		careFields.clear();
		ARY_PER_Fields.clear();
		

        	for(Schema.FieldSetMember f :
             	SObjectType.Npa_Audit__c.FieldSets.NA_Bill_Fields_CareM.getFields()) {
            	    careFields.Add(f.getFieldPath());                
        	}
        	for(Schema.FieldSetMember f :
             	SObjectType.Npa_Audit__c.FieldSets.NA_QA_Fields_ARY_Per.getFields()) {
            	    ARY_PER_Fields.Add(f.getFieldPath());                
        	}        	

		
        for(Npa_Audit__c item: audits){
        		
    		
			if(item.Operating_Group__c == 'CareMeridian' && item.Billing_Audit__c){
    			item = NpaTrigger_Utilities.setNA(careFields, item);
			}

			//QA checks
			if(item.QA_Audit__c){
				item = setNA(new set<string>{'Q8b__c'}, item);

				if(item.Program_Category__c == 'ARY - At-Risk-Youth' && item.Service_Scope__c =='Periodic ( < 24/7)'){
					item = setNA(ARY_PER_Fields, item);
                    if(item.Q13a__c == null){item.Q13a__c = '11 Not applicable for this consumer (no vocational goal)';}
                    if(item.Q14a__c == null){item.Q14a__c = '05 Not Applicable, because of scope of service';}
                    if(item.Q14b__c == null){item.Q14b__c = 'No';}
                    if(item.Q12a__c == null){item.Q12a__c = 'Neither Rep-Payee nor Assists';}

				}
				if(item.Service_Setting__c != null && item.Service_Setting__c !='Host Home'){
					item = setNA(new set<string>{'Q11a__c'},item);
				}
				if(item.Population__c != null && item.Population__c =='Adult'){
					item = setNA(new set<string>{'Q12f__c'},item);
				}				

			}
			
			//end QA checks


        	
        }
	}

	public static Npa_Audit__c setNA(set<string> allfields, Npa_Audit__c item){
		for(String f: allfields){
			if( item.get(f) == null){item.put(f,'Not Applicable');}
		}		
		return item;
	}

public static void setNullFields(List<Npa_Audit__c> audits){
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
    }//end clear fields

}