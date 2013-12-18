@isTest
private class TestCreateNewProspect {

static testMethod void testProspect() {
    
    Prospects__c[] theProspect = New Prospects__c[] {
    
        new Prospects__c(State__c = 'WI', Zip__c = '00000', Im_intersted_in_supporting__c='Adults with intellectual/developmental disabilities'),        
        new Prospects__c(State__c = 'WI', Zip__c = '00000', Im_intersted_in_supporting__c='Children and Adolescents'),       
        new Prospects__c(State__c = 'WI', Zip__c = '00000', Im_intersted_in_supporting__c='Undecided'),  
        new Prospects__c(State__c = 'WI', Zip__c = '02344', Im_intersted_in_supporting__c='Adults with intellectual/developmental disabilities'),      
        new Prospects__c(State__c = 'WI', Zip__c = '02344', Im_intersted_in_supporting__c='Children and Adolescents'),     
        new Prospects__c(State__c = 'WI', Zip__c = '02344', Im_intersted_in_supporting__c='Undecided'),
        new Prospects__c(State__c = 'WI', Zip__c = '00001', Im_intersted_in_supporting__c='Adults with intellectual/developmental disabilities'),        
        new Prospects__c(State__c = 'WI', Zip__c = '00001', Im_intersted_in_supporting__c='Children and Adolescents'),      
        new Prospects__c(State__c = 'WI', Zip__c = '00001', Im_intersted_in_supporting__c='Undecided'),        
        new Prospects__c(State__c = 'WI', Zip__c = '00000', Im_intersted_in_supporting__c='Adults with intellectual/developmental disabilities'),        
        new Prospects__c(State__c = 'WI', Zip__c = '00000', Im_intersted_in_supporting__c='Children and Adolescents'),        
        new Prospects__c(State__c = 'WI', Zip__c = '00000', Im_intersted_in_supporting__c='Undecided'),        
        new Prospects__c(State__c = 'WI', Zip__c = '02344', Im_intersted_in_supporting__c='Adults with intellectual/developmental disabilities'),     
        new Prospects__c(State__c = 'MA', Zip__c = '30003', Im_intersted_in_supporting__c='Adults with intellectual/developmental disabilities'),        
        new Prospects__c(State__c = 'AZ', Zip__c = '55330', Im_intersted_in_supporting__c='Adults with intellectual/developmental disabilities'),    
    
        new Prospects__c(State__c = 'WI', Zip__c = '55330', Im_intersted_in_supporting__c = 'Children and Adolescents'),        
        new Prospects__c(State__c = 'WI', Zip__c = '55330', Im_intersted_in_supporting__c = 'Adults with intellectual/developmental disabilities'),
        new Prospects__c(State__c = 'WI', Zip__c = '55330', Im_intersted_in_supporting__c = 'Undecided'),

        new Prospects__c(State__c = 'AL', Zip__c = '55555', Im_intersted_in_supporting__c = 'Children and Adolescents'),        
        new Prospects__c(State__c = 'AL', Zip__c = '55555', Im_intersted_in_supporting__c = 'Adults with intellectual/developmental disabilities'),
        new Prospects__c(State__c = 'AL', Zip__c = '55555', Im_intersted_in_supporting__c = 'Undecided'),

        new Prospects__c(State__c = 'MA', Zip__c = '02116', Im_intersted_in_supporting__c = 'Adults with intellectual/developmental disabilities'),        
        new Prospects__c(State__c = 'MA', Zip__c = '02135', Im_intersted_in_supporting__c = 'Children and Adolescents'),        
        new Prospects__c(State__c = 'MA', Zip__c = '95351', Im_intersted_in_supporting__c = 'Undecided'),
        
        new Prospects__c(State__c = 'MA', Zip__c = '00000', Im_intersted_in_supporting__c = 'Adults with intellectual/developmental disabilities'),        
        new Prospects__c(State__c = 'MA', Zip__c = '00000', Im_intersted_in_supporting__c = 'Children and Adolescents'),        
        new Prospects__c(State__c = 'MA', Zip__c = '00000', Im_intersted_in_supporting__c = 'Adults'),
               
        new Prospects__c(State__c = 'IL', Zip__c = '60420', Im_intersted_in_supporting__c = 'Adults with intellectual/developmental disabilities'),        
        new Prospects__c(State__c = 'IL', Zip__c = '60420', Im_intersted_in_supporting__c = 'Children and Adolescents'),        
        new Prospects__c(State__c = 'IL', Zip__c = '60420', Im_intersted_in_supporting__c = 'Undecided'),

        new Prospects__c(State__c = 'IL', Zip__c = '00000', Im_intersted_in_supporting__c = 'Adults with intellectual/developmental disabilities'),        
        new Prospects__c(State__c = 'IL', Zip__c = '00000', Im_intersted_in_supporting__c = 'Children and Adolescents'),        
        new Prospects__c(State__c = 'IL', Zip__c = '00000', Im_intersted_in_supporting__c = 'Undecided')
        
    };
    Insert theProspect;
    }

}