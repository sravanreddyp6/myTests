@istest
public with sharing class CMShiftAssessmentNotificationBatchTest {
	static testmethod void simpleTest() {
		SchedulableContext sc;
        CMShiftAssessmentNotificationRunBatch cmn = new CMShiftAssessmentNotificationRunBatch();
        cmn.execute(sc);
        
	}

}