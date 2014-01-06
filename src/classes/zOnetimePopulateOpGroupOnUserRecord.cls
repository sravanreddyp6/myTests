public with sharing class zOnetimePopulateOpGroupOnUserRecord {
    public list<tmn_user__c> Myusers = new list<tmn_user__c>();
public id theid{get; set;}
    public list<tmn_user__c> getMyusers(){
        list<tmn_user__c> Myusers2 = new list<tmn_user__c>();
        Myusers2 =  [select id, Salesforce_User_Account__c from tmn_user__c where Salesforce_User_Account__c != null ];
       // update Myusers2 ;
       list<user> allusers = new list<user> ();
       for(user u :[select username, statecode from user where country = '' and statecode <> '' limit 20]){
           user tmpu = new user();
           tmpu = u;
           theid = u.id;
           tmpu.country ='United States';
           tmpu.statecode = tmpu.statecode;
           allusers .add(tmpu);
       
       }
       update allusers ;
        return Myusers2;

}
public pagereference createrShiftNote(){
getMyusers();

return null;
}
}