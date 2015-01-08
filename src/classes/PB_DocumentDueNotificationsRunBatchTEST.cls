@isTest
private class PB_DocumentDueNotificationsRunBatchTEST {

    static testMethod void myUnitTest() {
        
        SchedulableContext sc;
        PB_DocumentDueNotificationsRunBatch assocDocNotifier = new PB_DocumentDueNotificationsRunBatch();
        
        assocDocNotifier.execute(sc);

    }
}