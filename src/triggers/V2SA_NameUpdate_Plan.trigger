/*
 *
 *  Trigger Update field Plan_Hidden_c with a number incrementing 
 *  based on the number of Plans associated with the related person (Contact_c).
 *
 */

trigger V2SA_NameUpdate_Plan on Plan__c (before insert) {
    
    set<Id> setOfContactIDs = new set<Id>();
    for(Plan__c objPlan : trigger.new){
        setOfContactIDs.add(objPlan.Person_Being_Served__c);
    }
    
    // list of existing Episodes with the same Contact__c Id like newly inserted Episodes
    list<Plan__c> lstOfPlans = [ Select Id, Person_Being_Served__c, Plan_Hidden__c From Plan__c Where Person_Being_Served__c In :setOfContactIDs  ];

    map<Id, Decimal> counterByContact = new map<Id, Decimal>();
    
    // if lstOfPlans is empty, set each Episode Plan_Hidden__c
    if(lstOfPlans.isEmpty()){
        for(Plan__c objPlan : trigger.new){ // if list of existing Episodes related to the same Contact is empty we iterate over trigger.new
            Plan__c temp = objPlan;
            // if maximum value is null(Plan_Hidden__c value is not set)
            if(counterByContact.get(objPlan.Person_Being_Served__c) == null){
                if(objPlan.Plan_Hidden__c == null){
                    counterByContact.put(objPlan.Person_Being_Served__c, 0);
                }
                else{
                    counterByContact.put(objPlan.Person_Being_Served__c, objPlan.Plan_Hidden__c - 1);
                }
            }
            else{
                if(counterByContact.get(objPlan.Person_Being_Served__c) < temp.Plan_Hidden__c){
                    counterByContact.put(objPlan.Person_Being_Served__c, temp.Plan_Hidden__c - 1);
                }
            }
        }       
    }
    else{
        // find maximum of Plan_Hidden__c value
        for(Plan__c objPlan : lstOfPlans){
            Plan__c temp = objPlan;
            // if maximum value is null(Plan_Hidden__c value is not set)
            if(counterByContact.get(objPlan.Person_Being_Served__c) == null){
                //counterByContact.put(objPlan.Person_Being_Served__c, objPlan.Plan_Hidden__c);
                if(objPlan.Plan_Hidden__c == null){
                    counterByContact.put(objPlan.Person_Being_Served__c, 0);
                }
                else{
                    counterByContact.put(objPlan.Person_Being_Served__c, objPlan.Plan_Hidden__c);
                }
            }
            else{
                if(counterByContact.get(objPlan.Person_Being_Served__c) < temp.Plan_Hidden__c){
                    counterByContact.put(objPlan.Person_Being_Served__c, temp.Plan_Hidden__c);
                }
            }
        }
        
        // set Plan_Hidden__c value to Episodes with blank value of this Field
        for(Plan__c objPlan : lstOfPlans){
            if(objPlan.Plan_Hidden__c == null){
                objPlan.Plan_Hidden__c = counterByContact.get(objPlan.Person_Being_Served__c) + 1;
                // update maximum value in map
                counterByContact.put(objPlan.Person_Being_Served__c, objPlan.Plan_Hidden__c);
            }
        }
        //update lstOfPlans;
    }
    
    // set Plan_Hidden__c value to newly inserted Episodes
    for(Plan__c objPlan : trigger.new){
        if(counterByContact.get(objPlan.Person_Being_Served__c) != null){
            objPlan.Plan_Hidden__c = counterByContact.get(objPlan.Person_Being_Served__c) + 1;
            //update maximum value in map
            counterByContact.put(objPlan.Person_Being_Served__c, objPlan.Plan_Hidden__c);
        }
    }
    
}