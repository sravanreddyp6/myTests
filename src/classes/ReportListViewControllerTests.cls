@isTest
public with sharing class ReportListViewControllerTests {
	
	@testsetup
	static void setUpData() {
		
		User redwoodUser = TMN_Generic_Core_TestData.createUserWithRole('ESD General', 'joeSmith', 'joeSmith@tmn.com.joeSmith222', 'joe', 'smith', 'Redwood','MN');
		TMN_Generic_Core_TestData.permsetAssign(new String[]{'ESD_Notes_Common','ESD_Notes_RW_Level_3','ESD_Referrals_Common','ESD_Referrals_Intaker'}, redwoodUser.Id);
        TMN_User__c redwoodtmnUser = [SELECT ID, Name FROM TMN_User__c WHERE Salesforce_User_Account__c =: redwoodUser.id];
        system.debug( [ select permissionset.name from PermissionSetAssignment where assigneeid = :redwoodUser.id]);
        system.debug('after');
        
        GroupMember GM = new GroupMember();
        GM.GroupId = [ select id from group where name = 'Referrals - MN' LIMIT 1].Id;
        GM.UserOrGroupId = redwoodUser.Id;
        insert GM;        
        
        List<VF_Reports__c> vfreplist = new LIst<VF_Reports__c>();
        
        VF_Reports__c vfrep = new VF_Reports__c( name__c = 'Test Report Ref', name='Test Report Ref', link__c = '/testReportLink', groups__c = '#Referrals', Description__c = '#Redwood', standard_report__c = false );
        vfreplist.add( vfrep );
        vfrep =  new VF_Reports__c( name__c = 'Test Report PBS', name ='Test Report PBS', link__c = '/testReportLink', groups__c = '#PBS', Description__c = '#Redwood', standard_report__c = false );
		vfreplist.add( vfrep );
		vfrep =  new VF_Reports__c( name__c = 'Test Report Neuro', name ='Test Report Neuro', link__c = '/testReportLink', groups__c = '#PBS', Description__c = '#Neuro', standard_report__c = false );
		vfreplist.add( vfrep);
		vfrep =  new VF_Reports__c( name__c = 'TimeLogEntryReport', name ='TimeLogEntryReport', link__c = '/testReportLink', groups__c = '#PBS', Description__c = '#Redwood', standard_report__c = false );
		vfreplist.add( vfrep);
		insert vfreplist;
	}
	
	static testmethod void simpleTests() {
        User redwoodUser = [ select id, name from User where name like 'joe smith'];
        system.runas( redwooduser ) {				
			ReportListViewController controller = new ReportListViewController();
			controller.getReportList();
			System.assertNotEquals(null, controller.refrportlst.size());
			System.assertNotEquals(null, controller.VFReportlstPBS.size());
			System.assertNotEquals(null, controller.contractrportlst.size());
			System.assertNotEquals(null, controller.docrportlst.size());
			System.assert(!controller.showNeuroFeatures);
        }
		
	}
	
	
	static testmethod void testPBSList() {

        User redwoodUser = [ select id, name from User where name like 'joe smith'];
        system.runas( redwooduser ) {				
		
			PageReference pg = Page.ReportListView;
			test.setCurrentpageReference(pg);
			
			ApexPages.currentPage().getParameters().put('object', 'Person Being Served');
			
			ReportListViewController controller = new ReportListViewController();
			system.assertEquals( controller.objectName, 'Person Being Served');
			controller.getReportList();
			
			System.assert( controller.VFReportlstPBS.size() > 0);
        }
	}

	@istest
    public static void testReferralsList() {
		
        User redwoodUser = [ select id, name from User where name like 'joe smith'];
        system.runas( redwooduser ) {				
		
			PageReference pg = Page.ReportListView;
			test.setCurrentpageReference(pg);
			
			ApexPages.currentPage().getParameters().put('object', 'Referrals');
			ReportListViewController controller = new ReportListViewController();
			controller.getReportList();
			
			System.assert( controller.vfreportlst.size() > 0 );
			System.assertEquals( false, controller.showNeuroFeatures);
			
        }
		
	}
	
	

		
}