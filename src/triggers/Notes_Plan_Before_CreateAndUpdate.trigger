trigger Notes_Plan_Before_CreateAndUpdate on Plan__c ( before update, before insert ) {
    try{
    List<Plan__c> trigPlans = new List<Plan__c>();
    for(Plan__c thisPlan: trigger.new)
        {
            trigPlans.add(thisPlan);
        }
    
    Notes_Plan_CountChildren.buildCount(trigPlans);
    }
    catch (DmlException e) {
        // Process exception here 
    }

}