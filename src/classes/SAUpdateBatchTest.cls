@isTest
private class SAUpdateBatchTest {
    static testMethod void testBatch() {
        TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();  

        list<Service_Location__c> sls = [select id, alias__c, city__c, program__c, service_value__c from service_location__c where programid__c = '122874001' or programid__c = '010895001'];
        if (sls.size() == 0) {
            sls.add(new Service_Location__c(
                    Alias__c = '122874',
                    City__c = 'Phoenix',
                    FacilityID__c = 14.0,
                    Name = '122874',
                    ProgramID__c = '122874001',
                    Program__c = 'AZ-MNTR-BH-Outpatient-MH',
                    Service_Value__c = 'IDD - Non-Residential Supported Living/IHSS/Ind Living',
                    Setting__c = 'Outpatient',
                    Source_System__c = 'AVATAR',
                    State__c = 'AZ',
                    Status__c = 'Active',
                    Street__c = '2700 N 3rd St, Ste 4000',
                    TIN__c = '042893910',
                    ZIP__c = '85004-1173',
                    UniqueID__c = TMN_Generic_Core_TestData.generateRandomString(10)  // This needs to be unique
                    ));
            sls.add(new Service_Location__c(
                    Alias__c = '010895',
                    City__c = 'Miami',
                    FacilityID__c = 14.0,
                    Name = '010895',
                    ProgramID__c = '010895001',
                    Program__c = 'AZ-MNTR-BH-Outpatient-MH',
                    Service_Value__c = 'IDD - Non-Residential Supported Living/IHSS/Ind Living',
                    Setting__c = 'Outpatient',
                    Source_System__c = 'AVATAR',
                    State__c = 'AZ',
                    Status__c = 'Active',
                    Street__c = '2700 N 3rd St, Ste 4000',
                    TIN__c = '042893910',
                    ZIP__c = '85004-1173',
                    UniqueID__c = TMN_Generic_Core_TestData.generateRandomString(10)  // This needs to be unique
                    ));
        }                                
        upsert sls;
        
        list<sObject> serAssigns = new list<Service_Assignment__c>(); 
        serAssigns.add(new Service_Assignment__c(
                phase_1_Start_Date__c = system.today().addDays(-7),
                Admission__c = myData.theAdm.id,
                Person_Being_served__c = myData.contactID,
                Program__c = 'Miami',
                Status__c = 'Active',
                SA_Start_DateTime__c = datetime.newInstance(2013, 1, 1, 0, 0, 0),
                Projected_Treatment_End_Date__c = date.newInstance(2014, 12, 31),
                Service_Location__c = sls[0].Id,
                Location_Region__c='S. Miami',
                Service_Line__c = 'Intensive In-Home'
                ));
        insert serAssigns;
        
        Test.StartTest();
    	String query = 'select ID, service_location__c, location_region__c, program__c, program_detail__c, service_line__c ' + 
    	                'from service_assignment__c where status__c = \'Active\' and id =\''+  serAssigns[0].id + '\' limit 1';
        ID batchprocessid = Database.executeBatch(new SAUpdateBatch(query), 1);
        Test.StopTest();

        System.assertequals('MENTOR', [select Program__c from Service_Assignment__c where id =: serAssigns[0].id].Program__c);
    }

    
}