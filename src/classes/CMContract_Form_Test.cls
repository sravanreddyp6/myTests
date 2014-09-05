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
        Id cmId = contractRecordTypeInfo.get('CareMeridian Contracts').getRecordTypeId();
                
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
        
        system.AssertEquals(mycontract.isNeuro, true);
        system.AssertEquals(0,mycontract.locations.size());
        
        mycontract.myEdit();
        mycontract.myAddRL();
        mycontract.addtinnpi();
        System.AssertEquals(mycontract.editMode, true);
        
        mycontract.cancel();
        mycontract.myEdit();
            
          mycontract.showAddLocation();
          mycontract.searchRes();
          
          mycontract.nameFilter='*';
          mycontract.searchRes();
          
          mycontract.nameFilter='None';
          mycontract.searchRes();
          
          mycontract.cityFilter = '*';
          mycontract.searchRes();
          
          mycontract.cityFilter = 'None';
          mycontract.searchRes();
          
          mycontract.stateFilter = '*';
          mycontract.searchRes();
          
          mycontract.stateFilter = 'fl';
          mycontract.searchRes();
               
          mycontract.nameFilter = '';
          mycontract.cityFilter='*';
          mycontract.searchRes();
          
          mycontract.cityFilter = 'None';
          mycontract.searchRes();
          
          mycontract.cityFilter ='None';
          mycontract.stateFilter = 'fl';
          mycontract.searchRes();
          
          mycontract.stateFilter = '*';
          mycontract.searchRes();
          
          mycontract.cityFilter = 'Test City';
          mycontract.stateFilter = '*';
          mycontract.nameFilter = 'None';
          mycontract.searchRes();
          
          mycontract.tin ='test';
          mycontract.npi = '12345';
          mycontract.addtinnpi();
          
          system.AssertEquals(mycontract.tmpResults.size(),[SELECT Count() FROM service_location__c WHERE state__c like '%']);
               
        string tmp = String.ValueOf(system.currentTimeMillis());
        Service_Location__c svl = new Service_Location__c(Street__c = '10 Main St.', 
          State__c = 'CA', 
          Setting__c = 'Residential',
          Service_Value__c = 'IDD', 
          Program__c = 'Redwood Res',
          UniqueID__c = '10031' + tmp.Substring(tmp.length()-6, tmp.length()-1), 
          ProgramID__c = '10005', 
          Phone__c = '213-555-5555',
          FacilityID__c = 20,
          City__c = 'Bakersfield', Alias__c ='10001'+tmp.Substring(tmp.length()-6,tmp.length()-1));
          
          insert svl;      
          
          Contract_ServiceLocation_JO__c junction = new Contract_ServiceLocation_JO__c ();
          junction.Contract__c = c.id;
          junction.Service_Location__c = svl.id;
          
          insert junction;
          
       /*  List <cSearchedServiceLocationResults> sss = new List <cSearchedServiceLocationResults>();
         for(cSearchedServiceLocationResult n: sss){
           n.Service_Location_c = svl;
           n.selected = True;
         }
           mycontract.searchedServiceLocationResultsList.add(sss);*/
           
          mycontract.paramSvcLocId = svl.id;
          mycontract.resetSearchItems();
          mycontract.searchRes();
          mycontract.getOffsetSize();
          mycontract.Last();
          mycontract.getDisableNext();
          mycontract.getDisablePrevious();
          mycontract.First();
          mycontract.getDisableNext();
          mycontract.getDisablePrevious();
          mycontract.Next();
          mycontract.Previous();
          mycontract.SearchClicked();
          mycontract.processSelected();
          mycontract.showAddLocations(); 
          mycontract.save();      
          mycontract.hideAddListLocs();
          system.assertEquals(0,mycontract.Attachments.size());
          mycontract.myEdit();
          mycontract.SearchRes();
          mycontract.selectAllLocations();
          mycontract.unSelectAllLocations();
          mycontract.selectAllLocations();
          myContract.Cancel();
          mycontract.selectAllLocations();
          myContract.RemoveItem2();
          mycontract.hideAddLocations();
          mycontract.save();
          mycontract.RemoveItem();
         
                         
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
        
        CareMeridian_Contract__c third = new CareMeridian_Contract__c();
        third.Name='Test';
        third.Status__c = 'Active';
        third.RecordTypeId = cmId;
        third.Filing_Deadline__c = '30 Days';
        third.Payment_Deadline__c = '30 Days';
        third.Resubmission_Deadline__c = '30 Days';
        insert third;
        System.Debug('INSERTED: ' + third.Id);   
        
        ApexPages.StandardController sc3 = new ApexPages.StandardController(third);
        
        pageRef = Page.CMContract_Form;
        Test.setCurrentPageReference(pageRef);
        ApexPages.currentPage().getParameters().put('id', third.id);
        CMContract_Form mycontract3 = new CMContract_Form(sc3);    
        
        System.AssertEquals(mycontract3.isNeuro, False);
        mycontract3.myEdit();
        mycontract3.save();
        
    }
    
}