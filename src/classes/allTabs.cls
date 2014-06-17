public with sharing class allTabs {
    public List<Schema.SObjectType> gd {get; set;}
    public List<SelectOption> options {get; set;}

    public allTabs(){
        gd = new list<Schema.SObjectType>();
        List<Schema.SObjectType> gd = Schema.getGlobalDescribe().Values();
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('test','test'));
        for(Schema.SObjectType f : gd)
        {
           options.add(new SelectOption(f.getDescribe().getLabel(),f.getDescribe().getLabel()));
        }            
         
    }

  public String val {get;set;}
 
  public list<objectInfo> getName()
  {
    List<Schema.SObjectType> gd = Schema.getGlobalDescribe().Values();     
    list<objectInfo> options = new list<objectInfo>();
    for(Schema.SObjectType f : gd)
    {
        if(f.getDescribe().getKeyPrefix() != null){
           objectInfo tmp = new objectInfo(); 
           tmp.label = f.getDescribe().getLabel();
           tmp.prefix = f.getDescribe().getKeyPrefix();
           tmp.name = f.getDescribe().getName();
           tmp.isCustom = f.getDescribe().isCustom();
           tmp.cObjs = f.getDescribe().getChildRelationships();
           
           options.add(tmp);
       }
    }     

    return options;
   }

    public class objectInfo{
        public string Label {get; set;}
        public string prefix {get; set;}
        public string children {get; set;}
        public string name {get; set;}
        public boolean isCustom {get; set;}
        public list<Schema.ChildRelationship> cObjs {get; set;}
        public objectInfo(){
            cObjs = new list<Schema.ChildRelationship>();
        
        }
    
    }

}