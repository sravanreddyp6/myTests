/*
 *
 *  Trigger Update field Admission_Hidden_c with a number incrementing 
 *  based on the number of admissions associated with the related person (Contact_c).
 *
 */

trigger V2SA_NameUpdate_Admission on Admission__c (before insert) {
    
    set<Id> setOfContactIDs = new set<Id>();
    for(Admission__c objEpisode : trigger.new){
        setOfContactIDs.add(objEpisode.Person_Being_Served__c);
    }
    
    // list of existing Episodes with the same Contact__c Id like newly inserted Episodes
    list<Admission__c> lstOfEpisodes = [ Select Id, Person_Being_Served__c, Admission_Hidden__c From Admission__c Where Person_Being_Served__c In :setOfContactIDs  ];

    map<Id, Decimal> counterByContact = new map<Id, Decimal>();
    
    // if lstOfEpisodes is empty, set each Episode Admission_Hidden__c
    if(lstOfEpisodes.isEmpty()){
        for(Admission__c objEpisode : trigger.new){ // if list of existing Episodes related to the same Contact is empty we iterate over trigger.new
            Admission__c temp = objEpisode;
            // if maximum value is null(Admission_Hidden__c value is not set)
            if(counterByContact.get(objEpisode.Person_Being_Served__c ) == null){
                if(objEpisode.Admission_Hidden__c == null){
                    counterByContact.put(objEpisode.Person_Being_Served__c , 0);
                }
                else{
                    counterByContact.put(objEpisode.Person_Being_Served__c , objEpisode.Admission_Hidden__c - 1);
                }
            }
            else{
                if(counterByContact.get(objEpisode.Person_Being_Served__c ) < temp.Admission_Hidden__c){
                    counterByContact.put(objEpisode.Person_Being_Served__c , temp.Admission_Hidden__c - 1);
                }
            }
        }       
    }
    else{
        // find maximum of Admission_Hidden_c value
        for(Admission__c objEpisode : lstOfEpisodes){
            Admission__c temp = objEpisode;
            // if maximum value is null(Admission_Hidden__c value is not set)
            if(counterByContact.get(objEpisode.Person_Being_Served__c ) == null){
                //counterByContact.put(objEpisode.Person_Being_Served__c , objEpisode.Admission_Hidden__c);
                if(objEpisode.Admission_Hidden__c == null){
                    counterByContact.put(objEpisode.Person_Being_Served__c , 0);
                }
                else{
                    counterByContact.put(objEpisode.Person_Being_Served__c , objEpisode.Admission_Hidden__c);
                }
            }
            else{
                if(counterByContact.get(objEpisode.Person_Being_Served__c ) < temp.Admission_Hidden__c){
                    counterByContact.put(objEpisode.Person_Being_Served__c , temp.Admission_Hidden__c);
                }
            }
        }
        
        // set Admission_Hidden_c value in map
        for(Admission__c objEpisode : lstOfEpisodes){
            if(objEpisode.Admission_Hidden__c == null){
                objEpisode.Admission_Hidden__c = counterByContact.get(objEpisode.Person_Being_Served__c ) + 1;
                // update maximum value in map
                counterByContact.put(objEpisode.Person_Being_Served__c , objEpisode.Admission_Hidden__c);
            }
        }
        update lstOfEpisodes;
    }
    
    // set Admission_Hidden_c value to newly inserted Episodes
    for(Admission__c objEpisode : trigger.new){
        if(counterByContact.get(objEpisode.Person_Being_Served__c ) != null){
            objEpisode.Admission_Hidden__c = counterByContact.get(objEpisode.Person_Being_Served__c ) + 1;
            //update maximum value in map
            counterByContact.put(objEpisode.Person_Being_Served__c , objEpisode.Admission_Hidden__c);
        }
    }

}