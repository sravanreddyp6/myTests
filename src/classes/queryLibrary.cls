public with sharing class queryLibrary {
    public String filter {get; set;}
    public String docToPreview {get; set;} 
    public List<ContentVersion> getDocs(){return [SELECT Title, Id, description, TagCsv, ContentDocumentId, ContentUrl FROM ContentVersion Where Publish_To__c Includes (:filter) AND IsLatest =True  ORDER BY title] ;}
    public void Nothing(){}    


 static testMethod void testMyController()
   {      
        queryLibrary controller = new queryLibrary();
        controller.getdocs();
        controller.nothing();        
   }
   
}