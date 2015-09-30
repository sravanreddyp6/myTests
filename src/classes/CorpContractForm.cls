public with sharing class CorpContractForm {
//Declorations
    ApexPages.StandardController stdCtrl;
    public Map<string, Field_Tag__c> MapTags = new Map<string, Field_Tag__c>();
    public Map<string, Field_Tag__c> getMapTags(){return MapTags;}
    public String vForm{get; set;}
    
//Constructors
    public CorpContractForm(ApexPages.StandardController controller) {
        // to get the record use the code (it wasn't need right now)(TMN_Corp_Contract__c)controller.getRecord() 
        LoadData();
        stdCtrl=controller;
    }
    public CorpContractForm() {
        LoadData();
    }    
    


//Methods

   public void LoadData(){
            Map<String, Schema.SObjectType> sobjectSchemaMap = Schema.getGlobalDescribe();
            Schema.DescribeSObjectResult objDescribe = sobjectSchemaMap.get('TMN_Corp_Contract__c').getDescribe();
            Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
            
            for(Schema.SObjectField ThisFieldDef : fieldMap.values()) 
            {
                Field_Tag__c ft = new Field_Tag__c();
                Schema.Describefieldresult FieldDescribeRes = ThisFieldDef.getDescribe();
                String name = FieldDescribeRes.getName();
                MapTags.put(name, ft ); 
            }
        for(Field_Tag__c alias : [Select Name, Field_API_Name__c, Object_API_Name__c, Header__c, Header_Text__c, Flag_1__c, Tag__c From Field_Tag__c Where Object_API_Name__c = 'TMN_Corp_Contract__c' ]){
            MapTags.put(alias.Field_API_Name__c,alias );       
        }
    }
    
    
    public PageReference save()
    {
            stdCtrl.save();
            
            if (!ApexPages.hasmessages()){
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, ' '+ Datetime.now().format('MM/dd/yyyy @ hh:mm - z')));
            }
            
            
       return null;
   }    
    
    
    
/*
------------------------------
-------
-------    Test Methods
-------
-------------------------------
*/

  static testMethod void testMyController()
   {  
		PageReference pageRef = Page.CorpContractForm;
        Test.setCurrentPageReference(pageRef);
        TMN_Corp_Contract__c tstContract = new TMN_Corp_Contract__c();
        insert tstContract;
        ApexPages.StandardController sc = new ApexPages.StandardController(tstContract);
        CorpContractForm contrl = new CorpContractForm(sc);       
        CorpContractForm contrl2 = new CorpContractForm (); //not used
  		contrl.save();
        contrl.getMapTags();
   }   
    
}