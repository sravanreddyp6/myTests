public with sharing class AdmissionValidation {

    private boolean m_isExecuting = false;

    public AdmissionValidation(boolean isExecuting){
        m_isExecuting = isExecuting;
    }

    public void OnBeforeInsert(Admission__c[] newObjects){
        // EXECUTE BEFORE INSERT LOGIC
            Admission__c[] theseAdms = (Admission__c[])newObjects;
            
            string admIdsToLimitServAssignQuery;
        
       
       
        
       validateAdmissions(theseAdms);
        
    }

    public void OnAfterInsert(Admission__c[] newObjects){
        // EXECUTE AFTER INSERT LOGIC
    }

    public void OnBeforeUpdate(Admission__c[] oldObjects, Admission__c[] updatedObjects, Map<Id,Admission__c> newObjMap){
        // BEFORE UPDATE LOGIC
            Admission__c[] theseAdms = (Admission__c[])updatedObjects;
            
            string admIdsToLimitServAssignQuery;
            
                        
            validateAdmissions(theseAdms);

        

    }

    public void OnAfterUpdate(Admission__c[] oldObjects, Admission__c[] updatedObjects, Map<Id,Admission__c> newObjMap){
        // AFTER UPDATE LOGIC
    }

    public void OnBeforeDelete(Admission__c[] ObjectsToDelete, Map<Id,Admission__c> oldObjMap){
        // BEFORE DELETE LOGIC
    }

    public void OnAfterDelete(Admission__c[] deletedObjects, Map<Id,Admission__c> oldObjMap){
        // AFTER DELETE LOGIC
    }

    public void OnUndelete(Admission__c[] restoredObjects){
        // AFTER UNDELETE LOGIC
    }

    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }
    
    public static void validateAdmissions(list<Admission__c> admits ){
        
            set<id> pbsInScope = new set<id>();
            for(Admission__c a: admits){
                pbsInScope.add(a.Person_Being_Served__c);
            }
            
            // SELECT ALL ADMISSIONS FOR THE PERSONS BEING SERVED
            List<Admission__c> allAdmissionsForPersons = new List<Admission__c>();
            allAdmissionsForPersons = [SELECT Id, name, Status__c, Admission_Effective_DateTime__c, Discharged_Date_Time__c, Effective_Date__c, Discharged_Date__c, Person_Being_Served__c, State__c FROM Admission__c WHERE Person_Being_Served__c = :pbsInScope ORDER BY Admission_Effective_DateTime__c];
            System.Debug('What is in allAdmissionsForPersons: ' + allAdmissionsForPersons);
            
            
            // SELECT ALL SERVICE ASSIGNMENTS FOR THE ADMISSIONS
            List<Service_Assignment__c> allSAs = new List<Service_Assignment__c>();
            allSAs = [SELECT Id, name, Start_Date__c, SA_Start_DateTime__c,  End_Date__c, Admission__c, Status__c FROM Service_Assignment__c WHERE Admission__c IN :admits];
            System.Debug('What is in allServAssigns?: ' + allSAs);
                        
            
        // START: PREVENT NEW ADMISSION IF OTHER ADMISSIONS FOR PERSON BEING SERVED LACK DISCHARGE DATE
        // Only prohibit the user to create an admission if a current admission does not have the "Discharged Date" complete and the 
        // admission is related to a Person Being Served that has a Mailing State of either "FL" or "NC" and a Network Offering=ARY.
        // 08/2013 - rule applies for all states and network offerings
        
            Boolean newAdmAllowed = true;
        
            for(Admission__c a: admits){
                    for(Admission__c anAdm2: allAdmissionsForPersons){                        
                        //make sure that there are no other active admits
                        if(a.id != anAdm2.id && anAdm2.Status__c == 'Active' && a.Status__c =='Active'){
                            newAdmAllowed = false;
                            a.addError('This Admission can not be set to Active until there are no other Active Admissions for this PBS (' + anAdm2.Name + ')');
                        }
                        
                    }// end loop over all admits               
            }// end loop over triger admits
            
            //adm.Admission_Effective_DateTime__c.date()
        
            for(Admission__c tAdmit: admits){
                        datetime curStart = tAdmit.Admission_Effective_DateTime__c.date();
                        datetime curEnd = tAdmit.Discharged_Date__c;    
                        
                    //Start: Prevent Admission date overlapping                 
                    for(Admission__c allAdmit: allAdmissionsForPersons){
                        datetime prevStart = allAdmit.Admission_Effective_DateTime__c.date();
                        datetime prevEnd = allAdmit.Discharged_Date__c;
                        
                        if(tAdmit.id != allAdmit.id){
                            boolean hasError = false;
                            if(curEnd == null){
                                if( (curStart >= prevStart) && ( curStart < prevEnd ) )                                
                                    hasError = true;                                
                            }
                            else{
                                if( (curStart >= prevStart) && ( curStart < prevEnd ) && (curEnd > prevEnd ) && (curEnd > prevStart ) )
                                    hasError = true;
                                if( (curStart >= prevStart) && ( curStart < prevEnd ) )
                                    hasError = true;  
                                if( (curEnd > prevStart ) && (curEnd <  prevEnd) )
                                    hasError = true;
                                if( (curEnd > prevStart ) && (curEnd >  prevEnd) && (curStart < prevEnd) )
                                    hasError = true;
                                if( (curStart <= prevStart)  && (curEnd >  prevStart) )
                                    hasError = true;                                                                                                                                            
                            }
                            
                            if (hasError)
                                tAdmit.addError('This Admission is within the date range of another Admission ('+ allAdmit.Name + ').  Please correct the dates so Admissions do not overlap.');
                        }
                    }
                    //prevent start dates from being before SA start dates
                    for(Service_Assignment__c sa : allSAs){
                        if(sa.Admission__c == tAdmit.id ){
                            
                            if(sa.SA_Start_DateTime__c < tAdmit.Admission_Effective_DateTime__c)                          
                                tAdmit.addError('Admission Date cannot be after a Service Assignment Start Date (' + sa.name + ' starts on: ' + sa.SA_Start_DateTime__c.date() + ')'  );
                            
                            if(sa.End_Date__c > curEnd)
                                tAdmit.addError('Discharged Date cannot be before a Service Assignment End Date (' + sa.name + ' ends on:  ' + sa.End_Date__c + ')' );
                        
                            if(sa.Status__c == 'Active' && tAdmit.Status__c == 'Discharged')
                                tAdmit.addError('Discharged Status is prevented while there is an Active Service Assignment (' + sa.name + ')'  );
                        }

                        
                    }
            }           
            
    }
}