@isTest
public class ServiceLocationNewTest {
    //General test data creation
    @testSetup static void setTestData(){
        Alias__c a = new Alias__c();
        a.Name = '12345';
        a.Alias_Operating_group__c = 'test';
        a.Alias_unique__c = '12345';
        a.Alias_State__c = 'MA';
        a.Alias_Parent__c = 'test';
        a.Alias_Region__c = 'test';
        a.Alias_Service_Line__c = 'test';
        
        insert a;
        
        Alias__c b = new Alias__c();
        b.Name = '99999';
        b.Alias_Operating_group__c = 'test';
        b.Alias_unique__c = '99999';
        b.Alias_State__c = 'MA';
        b.Alias_Parent__c = 'test';
        b.Alias_Region__c = 'test';
        b.Alias_Service_Line__c = 'test';
        
        insert b;
        
        Service_location__c s = new Service_Location__c();
        s.Alias_lookup__c = b.iD;
        s.Alias__c = '99999';
        s.Name = '99999';
        s.ProgramId__c = 'test';
        s.FacilityId__c = 999;
        s.Program__c = 'test Program';
        s.Service_value__c = 'test';
        s.source_System__c = 'AVATAR';
        s.UniqueID__c = '999||test Program';
        s.Physical_location__c = 'test';
        s.City__c = 'test';
        
        insert s;   
    
    }
    
    //For Create new Locations
    static testmethod void createnewSL(){
        
        PageReference pg = Page.ServiceLocationNew;
        Test.setcurrentpage(pg);
        Service_Location__c location = new Service_Location__c();
        Apexpages.StandardController sc = new Apexpages.StandardController(location);
        ServiceLocationNew controller = new ServiceLocationNew(sc);
        //controller.location = location;
        location.Alias_lookup__c = null;
        controller.setlocationFields();
        
        
        location.Alias_lookup__c = [SELECT Id FROM Alias__c WHERE Name='12345'].id; 
        controller.setlocationFields();
        location.State__c = null;
        location.Status__c = null;
        controller.save(); //so that error validations are covered
        
        
        Test.StartTest(); //Actual testing starts here
            location.Alias_lookup__c = [SELECT Id FROM Alias__c WHERE Name='12345'].id;
            controller.setlocationFields();
            
            location.Service_Type__c = 'test';
            location.Physical_location__c = 'test';
            location.TMN_Scope__c = 'test';
            location.Network_offering__c = 'test';
            location.Service_type__c = 'test';
            location.Population_Served__c = 'test';
            location.Street__c = 'test';
            location.City__c = 'test';
            location.Zip__c = '1220';
            location.Status__c = 'Active';
            //location.FacilityId__c = '1';
            
            controller.save();
        Test.StopTest();
    
        Service_Location__c sl = [SELECT Id, Name, FacilityId__c, UniqueId__c, ProgramId__c FROM Service_Location__c WHERE Id=: location.Id LIMIT 1]; //Querying the created Service Location
            system.assert(sl.UniqueId__c == '26||12345001'); // This validates almost entire save method 
            
        controller.cancel(); //Cover few more lines
        
        //Create a New Service Location 
        Test.setcurrentpage(pg);
        Service_Location__c location2 = new Service_Location__c();
        Apexpages.StandardController sc2 = new Apexpages.StandardController(location2);
        ServiceLocationNew controller2 = new ServiceLocationNew(sc2);
        location2.Alias_lookup__c = [SELECT Id FROM Alias__c WHERE Name='12345'].id;    
        controller2.setlocationFields();
        system.assert(location2.ProgramId__c == '12345002'); //Validating the Auto-population of Program Code
        
        location2.ProgramId__c = '12345001'; // Force fully creating a dupe SL to check the validation
        location2.Service_Type__c = 'test';
        location2.Physical_location__c = 'test';
        location2.TMN_Scope__c = 'test';
        location2.Network_offering__c = 'test';
        location2.Service_type__c = 'test';
        location2.Population_Served__c = 'test';
        location2.Street__c = 'test';
        location2.City__c = 'test';
        location2.Zip__c = '1220';
        location2.Status__c = 'Active';
        controller2.save();
        
        boolean error = false;
        for(Apexpages.Message m: Apexpages.getMessages()){
            if(m.getSummary().contains('Another Service Location exists')){
                error = true;
                break;
            }
        }
        
        system.assert(error);//Validating the error message
        
    }
    
    // For manage Service locations
    static testmethod void manageLocations(){
        Service_Location__c sl = new Service_location__c();
        Apexpages.StandardController sc = new Apexpages.StandardController(sl);
        manageservicelocationsController controller = new manageservicelocationsController(sc);
        PageReference pg = Page.manageServiceLocations;
        test.SetCurrentPage(pg);
        
        sl.Alias_lookup__c = null;
        controller.run();
        system.assert(controller.locations.Size() == 0);
        
        sl.Alias_lookup__c = [SELECT Id FROM Alias__c WHERE Name ='12345'].Id;
        controller.run();
        system.Assert(controller.locations.Size() == 0); // No locations Associated to this Alias
        
        sl.Alias_lookup__c = [SELECT Id FROM Alias__c WHERE Name ='99999'].Id;
        controller.run();
        system.Assert(controller.locations.Size() > 0); //locations Associated to this Alias in test setup
        
        Boolean dispCreate = controller.showCreate; //Not asserting this as we might run test classes as different users.
        system.assertNotEquals(null,controller.createNew()); //validates that the pagereference is taking to another page.
        
    }
    
    //For Service location edit 
    static testmethod void editLocations(){
        Service_Location__c location = [SELECT id, name, Alias__c, Alias_lookup__c,City__c,iServe_Program__c, Location_Nickname__c, Network_Offering__c,Phone__c,
                 Program__c, Physical_location__c, ProgramID__c, Service_Type__c, Service_Value__c, Source_System__c, Status__c, TMN_Scope__c, UniqueID__c FROM Service_Location__c WHERE Name='99999'];
        
        Apexpages.StandardController sc = new Apexpages.StandardController(location);
        ServiceLocationEdit  controller = new ServiceLocationEdit(sc);
        PageReference pg = Page.ServiceLocationEdit;
        test.SetCurrentPage(pg);
        
        location.Service_Type__c = 'test';
        location.Physical_location__c = 'test';
        location.TMN_Scope__c = 'test';
        location.Network_offering__c = 'test';
        location.Service_type__c = 'test';
        location.Population_Served__c = 'test';
        location.Street__c = 'test';
        location.City__c = 'test';
        location.Zip__c = '1220';
        location.Status__c = 'Active';
        
    
        controller.Save();
        
        //get the latest copy
        location = [SELECT id, name, Alias__c, Alias_lookup__c,City__c,iServe_Program__c, Location_Nickname__c, Network_Offering__c,Phone__c,
                 Program__c, Physical_location__c, ProgramID__c, Service_Type__c, Service_Value__c, Source_System__c, Status__c, TMN_Scope__c, UniqueID__c FROM Service_Location__c WHERE Name='99999'];
        
        system.assert(location.Location_Nickname__c == location.city__c+' '+location.Physical_Location__c);
        system.assert(location.Service_Value__c == 'test'); //Shopuld not be changed since this is Avatar location and the value is not null intitially
        
    }

}