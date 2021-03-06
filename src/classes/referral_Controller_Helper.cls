public with sharing class referral_Controller_Helper{

    public referral_Controller_Helper(ApexPages.standardController ctl){}
    
    @RemoteAction
    public static Related_Party__c loadRelatedParty(string relPartyId) {
            Related_Party__c party = 
                [select Id,Name, Type__c, Phone__c, Email__c, Address__c, Phone_1_Type__c, Phone_2__c, Phone_2_Type__c, comments__c, Status__c, Person_Being_Referred__c
                 from Related_Party__c where id = :relPartyId];
            return party;
     }
     
    
    @RemoteAction
    public static Related_Party__c saveRelatedParty(string partyID, string Name, string PartyType, string Phone1, string Email, 
                                              string Address, string Phone2, string Phone1Type, string Phone2Type, string comments,
                                              string PBRId, string pStatus) {
      Related_Party__c party;                                        
      if (String.isEmpty(partyID)) {
         party = new Related_Party__c(Name=Name, Type__c=PartyType, Phone__c = Phone1, Email__c = Email, Address__c = Address, Status__c = pStatus,
                                                    Phone_2__c = Phone2, Phone_1_Type__c = Phone1Type, Phone_2_Type__c = Phone2Type, Comments__c=Comments,
                                                    Person_Being_Referred__c = PBRId);
      } else {
         party = new Related_Party__c(Name=Name, Type__c=PartyType, Phone__c = Phone1, Email__c = Email, Address__c = Address, Status__c = pStatus,
                                                    Phone_2__c = Phone2, Phone_1_Type__c = Phone1Type, Phone_2_Type__c = Phone2Type, Comments__c=Comments,
                                                    Person_Being_Referred__c = PBRId, ID = partyID);
      }
      upsert party;                                  
      return party;
   }
    @RemoteAction
    public static Related_Party__c saveRelatedPartyFromPbsID(string partyID, string Name, string PartyType, string Phone1, string Email, 
                                              string Address, string Phone2, string Phone1Type, string Phone2Type, string comments,
                                              string PbsId, string pStatus) {
      Related_Party__c party;                                        
      if (String.isEmpty(partyID)) {
         party = new Related_Party__c(Name=Name, Type__c=PartyType, Phone__c = Phone1, Email__c = Email, Address__c = Address, Status__c = pStatus,
                                                    Phone_2__c = Phone2, Phone_1_Type__c = Phone1Type, Phone_2_Type__c = Phone2Type, Comments__c=Comments,
                                                    Person_Being_Served__c = PbsId);
      } else {
         party = new Related_Party__c(Name=Name, Type__c=PartyType, Phone__c = Phone1, Email__c = Email, Address__c = Address, Status__c = pStatus,
                                                    Phone_2__c = Phone2, Phone_1_Type__c = Phone1Type, Phone_2_Type__c = Phone2Type, Comments__c=Comments,
                                                    Person_Being_Served__c = PbsId, ID = partyID);
      }
      upsert party;                                  
      return party;
   }    
    @RemoteAction
    public static Referral_Location__c loadReferralLocation(string locationId) {
        Referral_Location__c loc = [select Id, Name, Referral__c, service_location__c, service_location__r.Name, service_location__r.city__c, service_location__r.state__c, service_location__r.zip__c, location__c, street_1__c, street_2__c, city__c, zip_code__c, state__c, user_assigned__c,
                                    user_assigned__r.Name, Status__c, service_location_city__c,service_location_state__c,service_location_street__c,service_location_zip__c, Service_Location_program__c, Rank__c
                                    from Referral_Location__c where id= :locationId];
        return loc;
    }
    
    @RemoteAction
    public static Referral_Location__c saveReferralLocation(string locID, string locUser, string locServiceLocation, string locStatus, string locRank, string referralId) {
      Referral_Location__c loc;     
      if ( String.isEmpty(locUser)) {
        locUser  = null;
      }
      if ( String.isEmpty(locRank)) {
        locRank  = null;
      }                                   
      if (String.isEmpty(locID)) {
         loc = new Referral_Location__c(User_Assigned__c = locUser, Service_Location__c= locServiceLocation, Status__c=locStatus, Referral__c=referralId, Rank__c = locRank);
      } else {
         loc = new Referral_Location__c(User_Assigned__c = locUser, Service_Location__c= locServiceLocation, Status__c=locStatus, Referral__c=referralId, Rank__c = locRank, ID=locID);
      }
      System.debug('%%%%%%%%% string locServicelocation'+locServiceLocation);
      System.debug('%%%%%%%%% saveReferralLocation'+loc);
      upsert loc;                                  
      return loc;
   }
    
    @RemoteAction
    public static Agency_Involved_With_Individual__c loadAgencyInvolved(string agencyId) {
        Agency_Involved_With_Individual__c agency = [select Id, Name, Address__c, Email__c, Phone__c, Reason_for_Involvement__c, Referral__c
                                    from Agency_Involved_With_Individual__c where id= :agencyId];
        return agency;
    }
    
    @RemoteAction
    public static Agency_Involved_With_Individual__c saveAgencyRemote(string agencyID, string agencyName, string agencyPhone, string agencyAddress, 
                                                                        string agencyEmail, string agencyReason, string referralId) {
      Agency_Involved_With_Individual__c agency;                                        
      if (String.isEmpty(agencyID)) {
         agency = new Agency_Involved_With_Individual__c(Name=agencyName, Phone__c=agencyPhone, Address__c = agencyAddress, 
                                                         Email__c = agencyEmail, Reason_for_Involvement__c = agencyReason, Referral__c=referralId);
      } else {
         agency = new Agency_Involved_With_Individual__c(Name=agencyName, Phone__c=agencyPhone, Address__c = agencyAddress, 
                                                         Email__c = agencyEmail, Reason_for_Involvement__c = agencyReason, Referral__c=referralId, ID=agencyID);
      }
      upsert agency;                                  
      return agency;
   }
    
     @RemoteAction
    public static Funding_Source__c loadFundingSource(string fundingId) {
        Funding_Source__c source = [select id, Funding_Source__c, Funding_Source_ID__c, Status__c, Service_Being_Funded__c, Comment__c, Payor__c, Referral__c
                                    from Funding_Source__c where id= :fundingId];
        return source;
    }
    
    @RemoteAction
    public static Funding_Source__c saveFundingRemote(string fundingID, string fundingSource, string fundingSourceId, string fundingStatus, 
                                                      string fundingService, string fundingComment, string referralId) {
      Funding_Source__c funding;                                        
      if (String.isEmpty(fundingID)) {
          Referral__c ref = [select id, recordtypeid from referral__c where id=:referralId];
         funding = new Funding_Source__c(Funding_Source__c=fundingSource, Funding_Source_ID__c = fundingSourceId, Status__c=fundingStatus, 
                                         Service_Being_Funded__c=fundingService, Comment__c=fundingComment, Referral__c=referralId,
                                        RecordTypeId=Utility.getFundingSourceRecordTypeFromReferral(ref));
      } else {
         funding = [select ID, RecordTypeId, Funding_Source__c, Funding_Source_ID__c, Status__c, Service_Being_Funded__c, Comment__c, Referral__c
                          from Funding_Source__c where id=:fundingID];
         funding.Funding_Source__c = fundingSource;
         funding.Funding_Source_ID__c = fundingSourceId;
         funding.Status__c = fundingStatus;
         funding.Service_Being_Funded__c = fundingService;
         funding.Comment__c = fundingComment;
      }
      upsert funding;                                  
      return funding;
   }
    
    @RemoteAction
    public static Task loadTask(string taskId) {
        Task t = [select Id, Subject, Priority, Status, WhatId, OwnerId, Owner.Name,
                                ActivityDate, Comments__c, Description
                         from Task
                         where Id = :taskId];
        return t;
    }
    
    @RemoteAction
    public static Task saveTask(string taskId, string taskSubject, string taskPriority, string taskStatus, 
                                string taskOwner, string taskDate, string taskComments, string referralId) {
      Task t;                                        
      if (String.isEmpty(taskId)) {
         t = new Task(WhatId=referralId, OwnerId=TaskOwner, Status=taskStatus, Subject=taskSubject, 
                      Priority=taskPriority, Description=taskComments,
                      RecordTypeId=Utility.getRecordTypeForTask('Referral Tasks'));
      } else {
         t = new Task(WhatId=referralId, OwnerId=TaskOwner, Status=taskStatus, Subject=taskSubject, 
                      Priority=taskPriority, Description=taskComments,
                      RecordTypeId=Utility.getRecordTypeForTask('Referral Tasks'),
                      ID=taskId);
      }
      t.ActivityDate = (!String.isEmpty(taskDate))?Date.parse(taskDate):(Date) null;
                                    
      upsert t;                                  
      return t;
   }
   
   @RemoteAction
    public static Diagnosis__c loadDiagnosis(string diagnosisId) {
            Diagnosis__c diagnosis = 
                [select Id, Name, Type__c, Status__c, PBR__c, Effective_Date__c, ICD__c, ICD__r.Name
                 from Diagnosis__c where id = :diagnosisId];
            return diagnosis;
     }
     
    
    @RemoteAction
    public static Diagnosis__c saveDiagnosis(string diagnosisId, string status, string effectiveTime, string ICD, string PBRId) {
      Diagnosis__c diagnosis;   
      if (String.isEmpty(diagnosisId)) {
         diagnosis = new Diagnosis__c(Status__c = status, ICD__c = ICD, PBR__c = PBRId );
      } else {
         diagnosis = new Diagnosis__c(ID = diagnosisId, Status__c = status, ICD__c = ICD, PBR__c = PBRId);
      }
      diagnosis.Effective_Date__c = (!String.isEmpty(effectiveTime)) ? Datetime.parse(effectiveTime) : (Datetime) null;
     // List<Person_Being_Referred__c> pbr = [SELECT Id, hasDiagRef__c FROM Person_Being_Referred__c WHERE Id =:PBRId LIMIT 1];
     // Referral__c ref = [SELECT Id,Person_Being_Referred__c,Referral_Status__c FROM Referral__c WHERE Person_Being_Referred__c = :PBRId];
      upsert diagnosis;
       /* if(pbr.size() > 0){
            pbr[0].hasDiagRef__c = true; 
            update pbr[0];
        } */
      return diagnosis;
   }
   
    @RemoteAction
    public static Diagnosis__c saveDiagnosisFromPbsID(string diagnosisId, string status, string effectiveTime, string ICD, string PBSId) {
      Diagnosis__c diagnosis;                                        
      if (String.isEmpty(diagnosisId)) {
        diagnosis = new Diagnosis__c(Status__c = status, ICD__c = ICD, PBS__c = PBSId );
      } else {
         diagnosis = new Diagnosis__c(ID = diagnosisId, Status__c = status,ICD__c = ICD, PBS__c = PBSId);
      }
      diagnosis.Effective_Date__c = (!String.isEmpty(effectiveTime)) ? Datetime.parse(effectiveTime) : (Datetime) null;
      upsert diagnosis;                                  
      return diagnosis;
   }
}