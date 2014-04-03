public with sharing class tmn_manage_groups {
    public List<ID> SelectGroups { get; set; }
    public List<ID> SelectGroupsToDelete { get; set; }

    public string myid = ApexPages.currentPage().getParameters().get('id') ;
    public tmn_manage_groups(ApexPages.StandardController controller) {
        SelectGroups = new List<ID>();
        SelectGroupsToDelete = new List<ID>();    
    }
   
    public PageReference DeleteFromGroups() {
        List<GroupMember> deleteme = new List<GroupMember>();
        
        for(ID local: SelectGroupsToDelete ){
            GroupMember record = new GroupMember();
            record.id =local;
            deleteme.add(record);        
        }
        delete deleteme ;
        return null;
    }

    public PageReference AddtoGroups() {
        List<GroupMember> addme = new List<GroupMember>();
        for(String local : SelectGroups){
            GroupMember gm = new GroupMember( );
            gm.groupid = local;
            gm.userorgroupid =  myid;
            addme.add(gm)   ;     
        
        }
        insert addme;
        return null;
    }  

    public List<SelectOption> AvailableGroups {get{  
        List<SelectOption> options = new List<SelectOption>();
        List<id> temp = new list<id>();

        for(GroupMember local: [Select ID, groupid, userorgroupid, Group.Name From GroupMember Where userorgroupid = :myid ]){
            temp.add(local.groupid);            
        }    

        for(Group local: [Select ID, Name From Group Where Name Like '%' AND id NOT IN :temp Order By Name]){
            options.add(new SelectOption(local.id, local.name));            
        }


        return options;       
    
    } set;}

   
    public List<SelectOption> CurrentGroups{get{  
        List<SelectOption> options = new List<SelectOption>();

        for(GroupMember local: [Select ID, Group.Name, groupid From GroupMember Where userorgroupid = :myid Order By Group.Name]){
            options.add(new SelectOption(local.Id, local.Group.Name ));            
        }


        return options;       
    
    } set;}      


}