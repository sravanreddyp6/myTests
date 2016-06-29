public with sharing class RW_Contract_RenewalForm {
    public Redwood_Contract__c OldContract = new Redwood_Contract__c ();
    public Redwood_Contract__c NewContract = new Redwood_Contract__c ();

    public Redwood_Contract__c getNewContract() {return NewContract; }
    public boolean editmode{get; set;}

    public RW_Contract_RenewalForm(ApexPages.StandardController controller) {
        editmode=false;
        
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : SObjectType.Redwood_Contract__c.FieldSets.Renewal_Fields.getFields()) {        
            query += f.getFieldPath() + ', ';

        }    
        query += 'Id FROM Redwood_Contract__c Where ID =\'';    
        query += ApexPages.currentPage().getParameters().get('id');
        query += '\'';
        OldContract = Database.query(query);
        
        for(Schema.FieldSetMember f : SObjectType.Redwood_Contract__c.FieldSets.Renewal_Fields.getFields()) {        
            NewContract.put(f.getFieldPath(), OldContract.get(f.getFieldPath()));
        }
        
        NewContract.Previous_Contract__c = OldContract.id;
        
    }
    
    public PageReference ReNewContract(){
        try{
        
        insert NewContract;
        OldContract.Renewed__c = True;
        OldContract.Next_Contract__c = NewContract.id;  
        update OldContract;       
    
        return new PageReference('/' + NewContract.id);        
        
        
        
        }
        
        catch(DMLException e){NewContract.addError(e.getMessage());}
            
        return null;

    }

}