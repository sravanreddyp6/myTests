trigger CreateUserAccountAdminRecord on TMN_User__c (before insert) {

    List<Account_Administration__c> UserAccts = new List<Account_Administration__c>();

    for (TMN_User__c o : Trigger.new )
    {
            UserAccts.Add ( new Account_Administration__c( First_Name__c = o.First_Name__c, Name = o.Last_Name__c ));      
   }
 
    insert UserAccts;
  
}