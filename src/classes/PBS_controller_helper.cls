public with sharing class PBS_controller_helper {

    public PBS_Controller_Helper(ApexPages.standardController ctl){}
    
    @RemoteAction
    public static Related_Party__c loadRelatedParty(string relPartyId) {
            Related_Party__c party = 
                [select Id,Name, Type__c, Phone__c, Email__c, Address__c, Phone_1_Type__c, Phone_2__c, Phone_2_Type__c, comments__c,Person_Being_Served__c
                 from Related_Party__c where id = :relPartyId];
            return party;
     }
    
    @RemoteAction
    public static Related_Party__c saveRelatedParty(string partyID, string Name, string PartyType, string Phone1, string Email, 
                                              string Address, string Phone2, string Phone1Type, string Phone2Type, string comments,
                                              string PBSId) {
      Related_Party__c party;                                        
      if (String.isEmpty(partyID)) {
         party = new Related_Party__c(Name=Name, Type__c=PartyType, Phone__c = Phone1, Email__c = Email, Address__c = Address,
                                                    Phone_2__c = Phone2, Phone_1_Type__c = Phone1Type, Phone_2_Type__c = Phone2Type, Comments__c=Comments,
                                                    Person_Being_Served__c = PBSId);
      } else {
         party = new Related_Party__c(Name=Name, Type__c=PartyType, Phone__c = Phone1, Email__c = Email, Address__c = Address,
                                                    Phone_2__c = Phone2, Phone_1_Type__c = Phone1Type, Phone_2_Type__c = Phone2Type, Comments__c=Comments,
                                                    Person_Being_Served__c = PBSId, ID = partyID);
      }
      upsert party;                                  
      return party;
   }
    
     // calculation of whether user is allowed to make this change
        public static Boolean isUserLevel1or2() {
                
                List<PermissionSetAssignment> userperms = [ select id, permissionset.name, assigneeid from PermissionSetAssignment where assigneeid = :UserInfo.getUserId()]; 
                for ( PermissionSetAssignment p : userperms ) {
                        
                        // user can only update if in one of these three permission sets
                        if ( p.PermissionSet.Name.Contains('Level_1') || p.PermissionSet.Name.Contains('Level_2') ) {
                                System.Debug('User is level1 or level2.');
                                return true;    
                        }
                }
                return false;
        }
    
}