public with sharing class Assessment_BeforeInsert_BeforeUpdate {
    
     public static void setAccountPerson(List<Assessment__c> assess){
     
         for(Assessment__c item : assess){
             system.debug('hhheerrreee');
             system.debug('test'+item.AccountId__c);
             item.AccountPerson__c = item.AccountId__c; 
             //item.adderror('test');       
         
         }
     
     }
     
     public static void setCount(List<Assessment__c> assess){
     //Assessment_Count
     
     
     
     }


}