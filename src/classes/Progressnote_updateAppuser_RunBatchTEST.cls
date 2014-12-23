@isTest
private class Progressnote_updateAppuser_RunBatchTEST {
	static testmethod void runTest(){
		SchedulableContext sc;
		Progressnote_updateApproval_userRunBatch b = new Progressnote_updateApproval_userRunBatch();
		b.execute(sc);
	}

}