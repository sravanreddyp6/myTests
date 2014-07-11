public with sharing class AssessmentSetup {

    // Method to find and insert domains and Assessment_Response__c
    // placeholder rows for this assessment
    
    public static void insertDomains(Assessment__c[] assessments) {
      
      // List to hold the assessments passed by the trigger
      // to this method.  
      
      List<Assessment__c> theseAssessments = new List<Assessment__c>();
      theseAssessments = assessments;
      Map<ID, Assessment__c> assessmentMap = new Map<ID, Assessment__c>();
      for (Assessment__c assessment: [SELECT ID, Admission__r.State__c FROM Assessment__c WHERE ID IN :assessments]) {
        assessmentMap.put(assessment.ID, assessment);
      }
      
      // List to hold the ID and Type of ALL domains, plus
      // child question data
      
      List<Assessment_Domain__c> allDomainsIdType = new List<Assessment_Domain__c>();
      
      // Get all domains for all assessments in our database...
      
      allDomainsIdType = 
        [Select ID,  Name, Description__c, Assessment_Type__c, Assessment_Type2__c,
                (Select Name, ID, Question_Description__c, Question_Title__c, Question_Number__c, Excluded_States__c
                  From Question__r 
                  Order By Question_Number__c) 
              From Assessment_Domain__c];

       //Now create a map for all the domains that we can do look-ups on.
      Map<Id, Assessment_Domain__c>  domainMap = new Map<Id, Assessment_Domain__c>();
      for (Assessment_Domain__c adc : allDomainsIdType){
         domainMap.put(adc.ID, adc);
         System.Debug('domainMap Question__r value: ' + domainMap.get(adc.ID).Question__r);
      }
      
   
      // Create a list of all questions...     
            List<Assessment_Question__c> allQuestions = new List<Assessment_Question__c>();
            allQuestions = 
              [SELECT Name, ID, Question_Description__c, Question_Title__c, 
                Question_Number__c, Excluded_States__c FROM Assessment_Question__c];
       
      // Create map of questions from the list immediately above...
      Map<Id, Assessment_Question__c> questionMap = new Map<Id, Assessment_Question__c>();
      for (Assessment_Question__c aq : allQuestions){
        questionMap.put(aq.ID, aq);
      }  
      
      List<Assessment_Response__c> currentAr;
      // Now do our matching loop, but use the map instead
      // and insert our Assessment_Domain_Result__c values!
      
      List<Assessment_Response__c> dummyAr = new List<Assessment_Response__c>();
      Assessment_Response__c tempAr;
      Assessment_Domain_Result__c dummyAdr;
      String tempQuery;
      Schema.FieldSetMember[] customQuestions = SObjectType.Assessment_Response__c.FieldSets.Custom_Questions.getFields();

      for (Assessment__c a: theseAssessments){
        if (a.Previous__c==null) {
            for( ID assmtDomainLoopID : domainMap.keySet() ){
				// START: RBO-289
            	if(a.Type__c=='ISSA') {
                	// Might be possible to refactor there is less redundancy between this if block and the else if below.  J. Gilliam
                	// copied the block as a quick solution for RBO-289, July '14. 
                	if(domainMap.get(assmtDomainLoopId).Assessment_Type2__c=='ISSA') {
	                    dummyAdr = new Assessment_Domain_Result__c();
	                    dummyAdr.Assessment__c = a.Id; 
	                    dummyAdr.Assessment_Domain__c = domainMap.get(assmtDomainLoopId).Id;
	                    insert dummyAdr;              	    				
					
	                    for(Assessment_Question__c q : domainMap.get(assmtDomainLoopID).Question__r){
	                      // Check if this assessment admission's state is in the
	                      // excluded list for this question
	                      if (q.Excluded_States__c==null || assessmentMap.get(a.ID).Admission__r.State__c==null || q.Excluded_States__c.indexOf(assessmentMap.get(a.ID).Admission__r.State__c)==-1) {
	                        dummyAr.add(new Assessment_Response__c(
	                          Assessment__c = a.Id,
	                          Question__c = q.ID,
	                          Assessment_Domain_Result__c = dummyAdr.Id,
	                          Rating__c = NULL,
	                          Color__c = NULL)
	                        );
	                      }
	                    }
                	}
            	}
            	// END: RBO-289       
                else if (a.Assessment_Type__c == domainMap.get(assmtDomainLoopId).Assessment_Type__c){
                    dummyAdr = new Assessment_Domain_Result__c();
                    dummyAdr.Assessment__c = a.Id; 
                    dummyAdr.Assessment_Domain__c = domainMap.get(assmtDomainLoopId).Id;
                    insert dummyAdr;
                    
                    // Try question inserts in this loop 11/2/12 11:20 AM     
                    
                    
                    
                    for(Assessment_Question__c q : domainMap.get(assmtDomainLoopID).Question__r){
                      // Check if this assessment admission's state is in the
                      // excluded list for this question
                      if (q.Excluded_States__c==null || assessmentMap.get(a.ID).Admission__r.State__c==null || q.Excluded_States__c.indexOf(assessmentMap.get(a.ID).Admission__r.State__c)==-1) {
                        dummyAr.add(new Assessment_Response__c(
                          Assessment__c = a.Id,
                          Question__c = q.ID,
                          Assessment_Domain_Result__c = dummyAdr.Id,
                          Rating__c = NULL,
                          Color__c = NULL)
                        );
                      }
                    }
                }
            }
        } else {
            // Clone stuff now
            tempQuery = 'SELECT ID, Assessment_Domain_Result__r.Assessment_Domain__c,' +
               'Question__c, Rating__c, Color__c, Response__c';
            for(Schema.FieldSetMember f : customQuestions) {
                tempQuery += ', ' + f.getFieldPath();
            }
            tempQuery += ' FROM Assessment_Response__c WHERE Assessment__c=\'' + a.Previous__c + '\'';
            currentAr = Database.query(tempQuery);
            
            System.debug('Before trigger, currentAr: ' + currentAr);
            // Clone responses
            for (Assessment_Response__c ar: currentAr) {
                dummyAdr = new Assessment_Domain_Result__c(
                    Assessment__c = a.ID,
                    Assessment_Domain__c = ar.Assessment_Domain_Result__r.Assessment_Domain__c
                );
                insert dummyAdr;
                tempAr = new Assessment_Response__c(
                    Assessment__c = a.ID,
                    Question__c = ar.Question__c,
                    Assessment_Domain_Result__c = dummyAdr.ID,
                    Rating__c = ar.Rating__c,
                    Color__c = ar.Color__c,
                    Response__c = ar.Response__c
                );
                for(Schema.FieldSetMember f : customQuestions) {
                    tempAr.put(f.getFieldPath(), ar.get(f.getFieldPath()));
                }
                dummyAr.add(tempAr);
            }
        }
        insert dummyAr;
      }       
    }
    
    public static void cloneHardcodedAnswers(Assessment__c[] assessments) {
        // Get the answers for those questions on the old Assessment
        Schema.FieldSetMember[] hardcodedQuestions = SObjectType.Assessment__c.FieldSets.Hardcoded_Questions.getFields();
        String query;
        for (Assessment__c a: assessments) {
            if (a.Previous__c!=null) {
                query = 'SELECT ';
                for(Schema.FieldSetMember f : hardcodedQuestions) {
                    query += f.getFieldPath() + ', ';
                }
                query += 'Id, Name FROM Assessment__c WHERE ID=\'' + a.Previous__c + '\' LIMIT 1';
                Assessment__c oldAssessment = Database.query(query);
        
                for(Schema.FieldSetMember f : hardcodedQuestions) {
                    a.put(f.getFieldPath(), oldAssessment.get(f.getFieldPath()));
                }
            }
        }
    }
    
    public static void nameAssessment(Assessment__c[] assessments){     
        
        // Get the Ids for the assessment(s) being created and put them in a set.
        Set<Id> assmtId = new Set<Id>();
        Map<Id,Assessment__c> assmtMap = new Map<Id,Assessment__c>();
        
        for (Assessment__c assmt : assessments){
            assmtId.add(assmt.Id);
            assmtMap.put(assmt.Id,assmt);
        }
        
        // Re-select the assessments that were already inserted prior to trigger fire
        // into a list that is NOT read-only (unlike the Trigger.new list passed by)
        // the trigger) so we can update the Assessment_Custom_Name__c value later.  
        List<Assessment__c> assmtsSelectedToUpdate = [SELECT Id, Name, Assessment_Type__c, Interval__c 
                                                        FROM Assessment__c WHERE Id IN 
                                                        :assmtId];  

        // Create a list of all Assessment_Type__c.Name values...     
            List<Assessment_Type__c> allAssmtTypes = new List<Assessment_Type__c>();
            allAssmtTypes = 
              [SELECT Name, ID FROM Assessment_Type__c];
              
        // Create map of assessment types from the list immediately above...
            Map<Id, Assessment_Type__c> assmtTypeMap = new Map<Id, Assessment_Type__c>();
              for (Assessment_Type__c at : allAssmtTypes){
                assmtTypeMap.put(at.ID, at);
              }                
        
        // Loop through the assessment IDs we got from the trigger.
        for (Id assmtIdsToLoopThrough : assmtID){
        
            Assessment__c thisAssmt = assmtMap.get(assmtIdsToLoopThrough);
            system.debug('ty why - ' + thisAssmt.Assessment_Type_Name__c);
         //   if(thisAssmt.Assessment_Type_Name__c == 'CANS'){
                
                String typeOfThisAssmt;
                Integer numberOfAdmissionForAssmtWeAreCreating;
                
                // Get all admissions for this person being served and order by date
                List<Contact> thisPersonsContactID = [SELECT Id FROM Contact
                    WHERE AccountId = :thisAssmt.AccountId__c];
                List<Admission__c> thisPersonsAdmissions = [SELECT Id, Effective_Date__c FROM Admission__c
                    WHERE Person_Being_Served__c = :thisPersonsContactID.get(0).Id ORDER BY Effective_Date__c];
                Integer countOfAdmissions = thisPersonsAdmissions.size();
                Map<Integer,Admission__c> mapOfThisPersonsAdmissions = new Map<Integer,Admission__c>();
                Integer episodeMapCounter = 1;
                
                for (Admission__c e : thisPersonsAdmissions){
                    mapOfThisPersonsAdmissions.put(episodeMapCounter, e);
                    episodeMapCounter++;
                }
                
                for ( Integer numberOfAdmission : mapOfThisPersonsAdmissions.keySet() ){
                    if ( thisAssmt.Admission__c == mapOfThisPersonsAdmissions.get(numberOfAdmission).Id){
                        numberOfAdmissionForAssmtWeAreCreating = numberOfAdmission;
                    }
                }
                
                
                // Loop through all Assessment_Type__c IDs, and figure out what
                // type of assessment this one is.
                for( ID assmtTypesToLoopThrough : assmtTypeMap.keySet() ){
                    if ( assmtTypesToLoopThrough == thisAssmt.Assessment_Type__c ){
                        typeOfThisAssmt = assmtTypeMap.get(assmtTypesToLoopThrough).Name;
                    }
                }
                
                // Get the assessments of this type already completed for the user.
                List<Assessment__c> assmtPreExisting = [SELECT Id, Name, Interval__c FROM Assessment__c 
                    WHERE AccountPerson__c = :thisAssmt.AccountPerson__c
                    AND Admission__c = :thisAssmt.Admission__c];
                    
                List<Account> thisPerson = [SELECT FirstName, LastName FROM Account WHERE Id = :thisAssmt.AccountId__c LIMIT 1];
                String thisPersonFirstName = thisPerson.get(0).FirstName;
                String thisPersonLastName = thisPerson.get(0).LastName;
                
                Integer countOfAssmts = assmtPreExisting.size();
                //System.Debug('How many assessments has this person had?' + countOfAssmts);
                
                // Loop through the writabe list of assessments and update the Assessment_Custom_Name__c
                // value.    
                for (Assessment__c tryChangeCustomName : assmtsSelectedToUpdate){
                    if (tryChangeCustomName.Id == assmtIdsToLoopThrough)
                        if (tryChangeCustomName.Interval__c == 'Intake' || tryChangeCustomName.Interval__c == 'Discharge'){
                            tryChangeCustomName.Name = typeOfThisAssmt + '_' + thisPersonFirstName + thisPersonLastName + '_Assmt' + countOfAssmts + '_' + thisAssmt.Interval__c;
                        }
                        else{
                            tryChangeCustomName.Name = typeOfThisAssmt + '_' + thisPersonFirstName + thisPersonLastName + '_Assmt' + countOfAssmts + '_' + thisAssmt.Interval__c + thisAssmt.Quarter__c;
                        }
                    update tryChangeCustomName;
                }
         //   }
        }
        
    }
    
    public static void checkIntervals(Assessment__c[] assessments){ 
        
        for ( Assessment__c a : assessments ){
        
            List<Assessment__c> allAssmtsOfTypeForAdmission = [SELECT Id, Interval__c, Quarter__c FROM Assessment__c WHERE AccountPerson__c = :a.AccountPerson__c AND Admission__c = :a.Admission__c AND Assessment_Type__c = :a.Assessment_Type__c ORDER BY Quarter__c];
            System.Debug('List allAssmtsOfTypeForAdmission: ' + allAssmtsOfTypeForAdmission);
            
            // START: Confirm Intake is first assessment of type        
            if( a.Interval__c == 'Intake' ){
                if ( allAssmtsOfTypeForAdmission.size() > 0 ){
                    // Prevent insert and throw error
                    a.addError('Intake can only be selected as the interval for the first assessment of a given type under an admission. Another assessment of this type was found for the person being served. Please select a different inteveral or contact a system administrator for assistance.');
                }
            }
            // END: Confirm Intake is first assessment of type
            
            // START: Confirm that no assessment can be entered after the discharge.        
            for ( Assessment__c aprev : allAssmtsOfTypeForAdmission){
                if (aprev.Interval__c == 'Discharge'){
                    a.addError('A discharge assessment of this assessment type already exists for this admission.  Additional assessments of a given type cannot be created after an assessment with interval \'Discharged\' has been created for that type.  If you require assistance, please contact your system administrator.');
                }
            }
            // END: Confirm that no assessment can be entered after the discharge
            
            // START: Prevent Quarterly and Discharge if Intake not present.
            if( a.Interval__c == 'Quarterly' || a.Interval__c == 'Discharge' ){
                Boolean hasIntake = false;
                
                for ( Assessment__c aprev : allAssmtsOfTypeForAdmission){
                    if (aprev.Interval__c == 'Intake'){
                        hasIntake = true;
                    }
                }
                
                if ( hasIntake == false ){
                    a.addError('An assessment with Interval \'Intake\' must be entered for a given assessment type before assessments of that type with other Interval values can be created. Please enter the \'Intake\' assessment first, or contact your system administrator if you require assistance.');  
                }
            }
            // END: Prevent Quarterly and Discharge if Intake not present.
            
            // START: Quarterly numbering, prevent skipping and duplication
            if( a.Interval__c == 'Quarterly'){
                
                Boolean qrtrNumAllowed = false;
                System.Debug('Value of qrtrNumAllowed at Line 219: ' + qrtrNumAllowed);
                // NOTE: Our object setup prevents decimal values, but
                // our number from the object is not Integer type.  So, we
                // can use this Double and expect integers.
                Double lastAndHighestQrtrNum = 0;
                
                for ( Assessment__c aprev : allAssmtsOfTypeForAdmission){

                    
                    if(aprev.Interval__c == 'Quarterly'){
                        // First, we check to see if there's a NULL value
                        // for the Quarter__c field.  If other validation
                        // has held up, there should not be.
                        if( aprev.Quarter__c == NULL ){
                            a.addError('A quarterly assessment for this admission seems to lack a quarter number value.  This scenario should not be possible.  Please contact your system administrator and reference this error code: \'Apex Class: AssessmentSetup.cls, Line 227\'');
                        }
                        
                        if ( aprev.Quarter__c <= 0 ){
                            a.addError('A quarterly assessment for this admission seems to have a quarter number value that equals zero or is negative.  This scenario should not be possible.  Please contact your system administrator and reference this error code: \'Apex Class: AssessmentSetup.cls, Line 230\'');
                        }
                        
                        // The previous assessments in aprev are ordered by 
                        // the Quarter__c value entered by users.  If when looping 
                        // through aprev we encounter nothing but the first value,
                        // which should be "Quarterly 1" if we prevent 0 and negative
                        // values, then the Boolean qtrNumAllowed gets set to true
                        // here and shouldn't change.
                        if (aprev.Quarter__c == 1){
                                qrtrNumAllowed = true;
                        }
                        System.Debug('Value of qrtrNumAllowed at Line 248: ' + qrtrNumAllowed);
                        // Now, in this loop, we set qrtrNumAllowed to false
                        // if we find any of the following: 
                        // - A previous assessment with a Quarter__c number 
                        //      that is greater than or equal to our assessment
                        //      being created.
                        if ( aprev.Quarter__c >= a.Quarter__c ){
                            qrtrNumAllowed = false;
                        }
                        System.Debug('Value of qrtrNumAllowed at Line 257: ' + qrtrNumAllowed);                 
                        // With each iteration through the loop of past assessments,
                        // this number is, in theory, incrementing by one if all
                        // other validation holds, until we get to the last
                        // iteration in which the highest pre-existing Quarter__c
                        // number is added and persists beyond this loops
                        // lifetime.
                        if( aprev.Quarter__c > 0 ){
                            lastAndHighestQrtrNum = aprev.Quarter__c;
                        }
                    
                    }
                
                }
                
                if(lastAndHighestQrtrNum==0){
                    qrtrNumAllowed=true;
                }
                
                // If the assessment we're trying to enter is more than
                // 1 higher than the highest pre-existing Quarter__c
                // entry, set qtrNumAllowed to false.
                Integer lastAndHighestQrtrNumInt = lastAndHighestQrtrNum.intValue(); 
                
                System.Debug('a.Quarter__c before comparison to lastAndHighestQrtrNum + 1: ' + a.Quarter__c);
                System.Debug('lastAndHighestQrtrNumInt before comparison to a.Quarter__c: ' + lastAndHighestQrtrNumInt);
                System.Debug('lastAndHighestQrtrNumInt + 1: ' + (lastAndHighestQrtrNumInt + 1) );
                if ( a.Quarter__c > (lastAndHighestQrtrNumInt + 1) ){
                    qrtrNumAllowed = false;
                }
                        System.Debug('Value of qrtrNumAllowed at Line 283: ' + qrtrNumAllowed);             
                // If qtrNumAllowed equals false after all that, prevent insert.
                if(qrtrNumAllowed == false){
                    a.addError('The quarter you have indicated, ' + a.Quarter__c + ', does not seem to be the next expected quarterly assessment for this admission.  Please check the numbering of the quarterly assessments under this admission and try again.  If one or more quarterly assessments have been missed, you may need to enter and save a blank assessment for the previous quarter(s) to proceed.  If you need assistance, please contact your system administrator.');
                }   
            
            }
            // END: Quarterly numbering, prevent skipping and duplication
        }
        

    }

}