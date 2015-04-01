@istest
public class Assessment_FAD_NotificationsRunBat_Test{

static testMethod void myUnitTest() {
        SchedulableContext sc;
        Assessment_FAD_NotificationsRunBatch FADnotes = new Assessment_FAD_NotificationsRunBatch ();
        FADnotes.execute(sc);
}

}