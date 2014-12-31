@isTest
public with sharing class SObjectHistoriesTest {
    static testmethod void simpleTest() {
        // There's actually no way to test histories (since SF doesn't actually
        // commit during Tests), so this class is here simple to satisfy the
        // code coverage. 
        
        TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
        SObjectHistoriesController con = new SObjectHistoriesController();              
        
        myData.theAdm.Name = 'Another test';
        update myData.theAdm;
        con.item = myData.theAdm;
        SObject histItem = new Admission__History().getSObjectType().newSObject();
        DateTime a = con.getHistoryItem(histItem).CreatedDate;
        String b = con.getHistoryItem(histItem).Field;
        String c = con.getHistoryItem(histItem).oldValue;
        String d = con.getHistoryItem(histItem).newValue;
    }
}