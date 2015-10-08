@isTest
private class TestCreateNewProspect {
    static testMethod void testProspect() {
        User user = [SELECT Id FROM User LIMIT 1];
        Region__c[] regions = new Region__c[] {
            new Region__c(State__c='AZ', Route_To_IDD_1__c=user.Id, Type__c='State')
        };
        insert regions;
        Zip_Codes__c[] zipCodes = new Zip_Codes__c[] {
            new Zip_Codes__c(Name='00000', Route_To_Region__c=regions[0].Id, Route_To_Region_IDD__c=regions[0].Id),
            new Zip_Codes__c(Name='00001', Route_To_Region__c=regions[0].Id)
        };
        insert zipCodes;

        Prospects__c[] theProspect = New Prospects__c[] {
            new Prospects__c(State__c = 'AZ', Zip__c = '00000', Im_intersted_in_supporting__c='Adults with intellectual/developmental disabilities', Entry_Point__c='Web')
        };
        insert theProspect;
        Prospects__c[] prospects1 = New Prospects__c[] {
            new Prospects__c(State__c = 'AZ', Zip__c = '00000', Im_intersted_in_supporting__c='Children and Adolescents', Entry_Point__c='Web')
        };
        insert prospects1;
        Prospects__c[] prospects2 = New Prospects__c[] {
            new Prospects__c(State__c = 'AZ', Zip__c = '00000', Im_intersted_in_supporting__c='Undecided', Entry_Point__c='Web')
        };
        insert prospects2;
        Prospects__c[] prospects3 = New Prospects__c[] {
            new Prospects__c(State__c = 'AZ', Zip__c = '00001', Im_intersted_in_supporting__c='Children and Adolescents', Entry_Point__c='Web')
        };
        insert prospects3;
        Prospects__c[] prospects4 = New Prospects__c[] {
            new Prospects__c(State__c = 'AZ', Zip__c = '00001', Im_intersted_in_supporting__c='Adults with intellectual/developmental disabilities', Entry_Point__c='Web')
        };
        insert prospects4;
        Prospects__c[] prospects5 = New Prospects__c[] {
            new Prospects__c(State__c = 'AZ', Zip__c = '00001', Im_intersted_in_supporting__c='AUndecided', Entry_Point__c='Web')
        };
        insert prospects5;
    }
}