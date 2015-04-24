public with sharing class ESD_DetermineParentRoles {
    // J. Gilliam, 2/7/13:  As of this note, there is a single constructor for this class
    // that expects a User object Id.  Feed it any other Id, and it will fail.  Ideally,
    // we'd go back and revise this to interpret various Id types and either create the 
    // object, or throw an error if the Id supplied does not allow determination of the
    // list of parent roles.
        
    public List<Id> allParents = new List<Id>();
   
    public ESD_DetermineParentRoles(Id aUserId){
        
        Id aRole;
        
        List<User> aUserWithARole = [SELECT UserRoleId FROM User WHERE Id = :aUserId];
        for(User theOneUserFromAUserWithARole : aUserWithARole){
            aRole = theOneUserFromAUserWithARole.UserRoleId;
        }
        
        List<UserRole> allRoles = [SELECT Id, ParentRoleId FROM UserRole];
        Map<Id,Id> mapAllRoles = new Map<Id,Id>();
        
        for(UserRole uR : allRoles){
            mapAllRoles.put(uR.Id, uR.ParentRoleId);
        }
        
        Id thisParent = mapAllRoles.get(aRole);
        Id roleToCheck;
        roleToCheck = aRole;        

        Boolean hadParent = true;
        
        while(hadParent == true){
            // Check to see if role has a parent.  If yes, put it in the allParents array and then check that parent next.
            Id thisLoopParent = mapAllRoles.get(roleToCheck);
            System.Debug('What is in thisLoopParent:' + thisLoopParent);        
            if(thisLoopParent == null){
                hadParent = false;
            }
            else{
                allParents.add(thisLoopParent);
                roleToCheck = thisLoopParent;
                hadParent = true;       
            }           
        }
        
    }
    
}