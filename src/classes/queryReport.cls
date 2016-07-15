public with sharing class queryReport {

    public String filter {get; set;}
    public List<report> getRpts(){return [SELECT Name, Id, description, DeveloperName, SystemModstamp FROM report  Where description Like :filter ORDER BY name] ;}
 
 
 static testMethod void testMyController()
   {      
        queryReport controller = new queryReport();
        controller.getrpts();
        
   }
}