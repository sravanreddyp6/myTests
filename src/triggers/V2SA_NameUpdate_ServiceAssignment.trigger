/*
 *
 *  Trigger Update field SA_Hidden_c with a number incrementing 
 *  based on the number of Service Assignments associated with the related person (Contact_c).
 *
 */

trigger V2SA_NameUpdate_ServiceAssignment on Service_Assignment__c (before insert) {
   
    set<Id> setOfContactIDs = new set<Id>();
    for(Service_Assignment__c objSA : trigger.new){
        setOfContactIDs.add(objSA.Person_Being_Served__c);
    }
    
    // list of existing Service Assignments with the same Person_Being_Served__c Id like newly inserted Service Assignments
    list<Service_Assignment__c> lstOfSAs = [ Select Id, Person_Being_Served__c, SA_Hidden__c From Service_Assignment__c Where Person_Being_Served__c In :setOfContactIDs  ];

    map<Id, Decimal> counterByContact = new map<Id, Decimal>();
    
    // if lstOfSAs is empty, set each Episode SA_Hidden__c
    if(lstOfSAs.isEmpty()){
        for(Service_Assignment__c objSA : trigger.new){ // if list of existing Service Assignments related to the same Contact is empty we iterate over trigger.new
            Service_Assignment__c temp = objSA;
            // if maximum value is null(SA_Hidden__c value is not set)
            if(counterByContact.get(objSA.Person_Being_Served__c) == null){
                if(objSA.SA_Hidden__c == null){
                    counterByContact.put(objSA.Person_Being_Served__c, 0);
                }
                else{
                    counterByContact.put(objSA.Person_Being_Served__c, objSA.SA_Hidden__c - 1);
                }
            }
            else{
                if(counterByContact.get(objSA.Person_Being_Served__c) < temp.SA_Hidden__c){
                    counterByContact.put(objSA.Person_Being_Served__c, temp.SA_Hidden__c - 1);
                }
            }
        }       
    }
    else{
        // find maximum of SA_Hidden__c value
        for(Service_Assignment__c objSA : lstOfSAs){
            Service_Assignment__c temp = objSA;
            // if maximum value is null(SA_Hidden__c value is not set)
            if(counterByContact.get(objSA.Person_Being_Served__c) == null){
                //counterByContact.put(objSA.Person_Being_Served__c, objSA.SA_Hidden__c);
                if(objSA.SA_Hidden__c == null){
                    counterByContact.put(objSA.Person_Being_Served__c, 0);
                }
                else{
                    counterByContact.put(objSA.Person_Being_Served__c, objSA.SA_Hidden__c);
                }
            }
            else{
                if(counterByContact.get(objSA.Person_Being_Served__c) < temp.SA_Hidden__c){
                    counterByContact.put(objSA.Person_Being_Served__c, temp.SA_Hidden__c);
                }
            }
        }
        
        // set SA_Hidden__c value to Service Assignments with blank value of this Field
        for(Service_Assignment__c objSA : lstOfSAs){
            if(objSA.SA_Hidden__c == null){
                objSA.SA_Hidden__c = counterByContact.get(objSA.Person_Being_Served__c) + 1;
                // update maximum value in map
                counterByContact.put(objSA.Person_Being_Served__c, objSA.SA_Hidden__c);
            }
        }
        update lstOfSAs;
    }
    
    // set SA_Hidden__c value to newly inserted Service Assignments
    for(Service_Assignment__c objSA : trigger.new){
        if(counterByContact.get(objSA.Person_Being_Served__c) != null){
            objSA.SA_Hidden__c = counterByContact.get(objSA.Person_Being_Served__c) + 1;
            //update maximum value in map
            counterByContact.put(objSA.Person_Being_Served__c, objSA.SA_Hidden__c);
        }
    } 
    
}