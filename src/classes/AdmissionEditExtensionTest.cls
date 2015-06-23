@isTest
private class AdmissionEditExtensionTest {
    static testmethod void simpleTest() {
        
        TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
        
        PageReference ref = new PageReference('/apex/AdmissionEdit?id='+ myData.theAdm.id);
        Test.setCurrentPage(ref); 
        AdmissionEditExtension controller = new AdmissionEditExtension(new ApexPages.StandardController(myData.theAdm));
        System.assertEquals(myData.theAdm.id, controller.admission.ID);
        
        controller.admission.status__c = 'Discharged';
        controller.admission.discharged_to_subcategory__c = 'Other';
        controller.admission.discharged_to_category__c = 'Another Facility';
        controller.admission.discharged_reason_additional__c = 'Other';
        controller.useDischargeSection = true;
        controller.saveAdmission();
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        system.assert( msgList.size() > 0);
        
        controller.useDischargeSection = false;
        controller.admission.status__c = 'Active';
        controller.admEffDateTime = myData.theAdm.Admission_Effective_DateTime__c.format();
        controller.admDischargeDateTime = '';
        controller.admission.Referred_Out_Agency_Name__c = 'Test Agency';
        controller.saveAdmission();
        msgList = ApexPages.getMessages();
        for(ApexPages.Message msg :  ApexPages.getMessages()) {
            system.debug( msg.getSummary());
        }
                 
        myData.theAdm = [
            SELECT Referred_Out_Agency_Name__c FROM Admission__c
            WHERE ID=:myData.theAdm.id
        ];
        
        System.assertEquals('Test Agency', myData.theAdm.Referred_Out_Agency_Name__c);
        
        
        
        ref = new PageReference('/apex/AdmissionEdit?pbsId='+myData.contactID);
        Test.setCurrentPage(ref);
        controller = new AdmissionEditExtension(new ApexPages.StandardController(New Admission__c()));
        
    }
}