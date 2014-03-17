@isTest
private class CMContract_Form_Test {

    static testMethod void myUnitTest() {

		// start with blank contract
    	ApexPages.StandardController scnew = new ApexPages.StandardController(new CareMeridian_Contract__c() );
        CMContract_Form mycontractnew = new CMContract_Form(scnew);

		// now insert one                
		Schema.DescribeSobjectResult conSchema = Schema.SobjectType.CareMeridian_Contract__c;
		Map<String,Schema.RecordTypeInfo> contractRecordTypeInfo = conSchema.getRecordTypeInfosByName();
		Id rtId = contractRecordTypeInfo.get('NeuroRestorative Contracts').getRecordTypeId();
		
        CareMeridian_Contract__c c = new CareMeridian_Contract__c ();
        c.name = 'test';
        c.Status__c = 'Active';
        c.RecordTypeId = rtID;
        c.Filing_Deadline__c = '30 Days';
        c.Payment_Deadline__c = '30 Days';
        c.Resubmission_Deadline__c = '30 Days';
        insert c;
        
        System.Debug('INSERTED: ' + c.Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(c);
        PageReference pageRef = Page.CMContract_Form;
        Test.setCurrentPageReference(pageRef);
        ApexPages.CurrentPage().getParameters().put('id',c.id);
        CMContract_Form mycontract = new CMContract_Form(sc);
        
        mycontract.myEdit();
        System.AssertEquals( mycontract.editMode, true);
        mycontract.myAddRL();
        mycontract.save();
        mycontract.addtinnpi();
        
        map<string, CMContract_Form.clsRateLevel> mrl = mycontract.getmapratelevel();
        for ( String rlkey : mrl.keyset() ) {
        	mycontract.removeid = rlkey;
        	mycontract.removeCRL();
        }
               
        CareMeridian_Contract__c c2 = new CareMeridian_Contract__c ();
        c2.name = 'test - revised';
        c2.Status__c = 'Active';
        
        ApexPages.StandardController sc2 = new ApexPages.StandardController(c2);
        
        pageRef = Page.CMContract_Form;
        Test.setCurrentPageReference(pageRef);
        ApexPages.currentPage().getParameters().put('oldid', c.id);
        CMContract_Form mycontract2 = new CMContract_Form(sc2);
     	
        List<SelectOption> listopts = mycontract2.getchangeTypes();
        System.assert( listopts.size() > 0);

		System.Debug( 'OLD ID=' + mycontract2.oldID);
		mycontract2.mycontract.name += '- revised';
		mycontract2.selectedTypes = new List<string>{'Location','Rate'};
        mycontract2.save();
        
        CareMeridian_Contract__c old = mycontract2.getOldContract();
        System.assertEquals(old.Id, c.Id);
        
        CareMeridian_Contract__c my = mycontract2.getmyContract();
        System.assertEquals(mycontract2.mycontract.Id, c2.Id);
        
        System.assertEquals(mycontract2.mycontract.Type_of_Change__c, 'Location;Rate');
        
        
    }
    
}