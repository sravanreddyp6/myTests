@isTest
private class MyRemoteMethodsTest {
    static Contact person;
    static Admission__c adm;
    static Service_Assignment__c ServAssign;
    
    private static TMN_Generic_Core_TestData myData;

    static testMethod void myUnitTestInstance() {
        createObjects();
        MyRemoteMethods remoteMethods = new MyRemoteMethods();
        System.assertequals(1,remoteMethods.getMyService_Locations().size());        
    }
    
    static testMethod void myUnitTestInstance2() {
        MyRemoteMethods remoteMethods = new MyRemoteMethods(new TxnQueueResponseController());
        system.AssertNotEquals(null,remoteMethods.parentCntrller);
        
    }
    
    static testMethod void myUnitTestRemote() {
        User redwoodUser = TMN_Generic_Core_TestData.createUser('ESD General', 'joeSmith', 'joeSmith@tmn.com.joeSmith', 'joe', 'smith', 'Redwood');
        TMN_User__c redwoodtmnUser = [SELECT ID, Name FROM TMN_User__c WHERE Salesforce_User_Account__c =: redwoodUser.id];
        
        system.runas(redwoodUser){
            createData();
            myData.loadData('IA');
            Im_Incident__c incident = new Im_Incident__c(Reported_By__c = UserInfo.getUserId(), Status__c='Event-Draft', Date_Documented__c= system.now());
            incident.Service_Location__c = myData.theSA.Service_Location__c;
            incident.Supervisor__c = redwoodtmnUser.id;
            insert incident;
            
            Im_InvolvedParty__c invPrty = new Im_InvolvedParty__c(Im_Incident__c = incident.id, type__c = 'Other', Name = 'Test Inv Party');
            insert invPrty;
            
            MyRemoteMethods.Im_partyData invPrtyData = MyRemoteMethods.getInvolvedParty(String.ValueOf(invPrty.id));
            
            system.AssertEquals(invPrty.id,invPrtyData.id);
            system.AssertEquals(invPrty.id,MyRemoteMethods.getInvolvedParties(String.ValueOf(incident.id))[0].id);

            system.AssertEquals(1,MyRemoteMethods.getStaffFortheProgram(JSON.serialize(new map<String, String>{'programLocation'=> myData.theSA.service_location__c,'q'=>''})).size());
            system.AssertEquals(0,MyRemoteMethods.getEventReviewerForProgram(JSON.serialize(new map<String, String>{'programLocation'=> myData.theSA.service_location__c,'q'=>''})).size());
            system.AssertEquals(1,MyRemoteMethods.getPBSFortheProgram(JSON.serialize(new map<String, String>{'programLocation'=> myData.theSA.service_location__c,'q'=>''})).size());
            
            
            system.AssertEquals(false,MyRemoteMethods.validateEvent(String.ValueOf(incident.id)).get('goodToSubmit'));
            system.AssertEquals('[]',MyRemoteMethods.GetInvolvedPartyEventTypes(JSON.serialize(new map<String, String>{'involvedParty'=> invPrty.id,'involvedPartyType'=>'Other'})));

            String evalSecId = UserInfo.getUserId() + '-' + DateTime.now().getTime();
            MyRemoteMethods.addOrModifyAnnotation(null, 'Body', 1.1, 1.1, 1.0, 1.0, 'Square', 'Annotation', evalSecId,String.valueOf(invPrty.id));
            system.assertNotEquals('', MyRemoteMethods.getAnnotations(String.valueOf(invPrty.id), evalSecId));

            system.AssertEquals(0,MyRemoteMethods.getInvPrtyEvntDetails(String.ValueOf(invPrty.id)).size());
        }
            
    }

    static List<Eval__c> newEvals = new List<Eval__c>();

    static testMethod void myUnitTestRemote2() {
        User redwoodUser = TMN_Generic_Core_TestData.createUser('ESD General', 'joeSmith', 'joeSmith@tmn.com.joeSmith', 'joe', 'smith', 'Redwood');
        TMN_User__c redwoodtmnUser = [SELECT ID, Name FROM TMN_User__c WHERE Salesforce_User_Account__c =: redwoodUser.id];
        
        system.runas(redwoodUser){
            createData();
            myData.loadData('IA');
            Im_Incident__c incident = new Im_Incident__c(Reported_By__c = UserInfo.getUserId(), Status__c='Event-Draft', Date_Documented__c= system.now());
            incident.Service_Location__c = myData.theSA.Service_Location__c;
            incident.Supervisor__c = redwoodtmnUser.id;
            insert incident;
            
            Im_InvolvedParty__c invPrty = new Im_InvolvedParty__c(Im_Incident__c = incident.id, type__c = 'Other', Name = 'Test Inv Party');
            insert invPrty;

            createEvalData();
	        list<MyRemoteMethods.FormKeyVal> evalVals = new list<MyRemoteMethods.FormKeyVal>();
	        String evalSecId = UserInfo.getUserId() + '-' + DateTime.now().getTime();
	        for (Eval__c e : newEvals){
	            MyRemoteMethods.FormKeyVal val = new MyRemoteMethods.FormKeyVal();
	            val.name= e.id;
	            if (e.Field_Type__c == 'Hidden' && e.Field_Sub_Type__c == 'Boolean')
	                val.value = 'True';
	            else if (e.Field_Type__c == 'Hidden' && e.Field_Sub_Type__c == 'String')
	                val.value = 'Error Message';
	            else if(e.Field_Type__c == 'Boolean' && e.Field_Sub_Type__c == 'Checkbox')
	                val.value = '1';
	            else if(e.Field_Type__c == 'Boolean' && e.Field_Sub_Type__c == 'Dropdown')
	                val.value = 'TEST';
	            else if(e.Field_Type__c == 'Int' )
	                val.value = '12';
	            else if(e.Field_Type__c == 'Date')
	                val.value = '11/12/2013';
	            else if(e.Field_Type__c == 'DateTime')
	                val.value = '04/27/2015 06:00 PM';
	            else if(e.Field_Type__c == 'Multiselect') {
	                val.value = 'TEST';
	                MyRemoteMethods.FormKeyVal val1 = new MyRemoteMethods.FormKeyVal();
	                val1.name= e.id;
	                val1.value = 'TEST1';
	                evalVals.add(val1);
	            }
	            else
	                val.value = 'String,ID,Dropdown,Double,Currency values.';
	
	            evalVals.add(val);
	            MyRemoteMethods.FormKeyVal valEsi = new MyRemoteMethods.FormKeyVal();
	            valEsi.name = e.id + '_esi';
	            valEsi.value = evalSecId;
	            evalVals.add(valEsi);
	        }

            MyRemoteMethods.saveFields(invPrty.id, JSON.serialize(evalVals));

            system.AssertNotEquals(0,MyRemoteMethods.getInvPrtyEvntDetails(String.ValueOf(invPrty.id)).size());
            system.AssertEquals('[]',MyRemoteMethods.GetInvolvedPartyEventTypes(JSON.serialize(new map<String, String>{'involvedParty'=> invPrty.id,'involvedPartyType'=>'Other'})));
            
            MyRemoteMethods.addOrModifyAnnotation(null, 'Body', 1.1, 1.1, 1.0, 1.0, 'Square', 'Annotation', evalSecId,String.valueOf(invPrty.id));
            system.assertEquals('', MyRemoteMethods.getAnnotations(String.valueOf(invPrty.id), evalSecId)); // thats because the annotations are retrieved only once per transaction, done above getInvPrtyEvntDetails() 

            MyRemoteMethods.deleteAnnotation([Select id from Evaluation_Response__c where ImInvolvedPartyAnnotations__c =: invPrty.id].id);
            system.AssertEquals(true,MyRemoteMethods.validateEvent(String.ValueOf(incident.id)).get('goodToSubmit'));
        }
            
    }
    
    private static void createData(){
        myData = new TMN_Generic_Core_TestData();
    }

     

    private static void createObjects(){
        person = new Contact();
        person.LastName = 'Contact';
        person.FirstName = 'Test';
        insert person;

        adm = new Admission__c();
        adm.person_being_served__c = person.id;
        adm.Admission_Effective_DateTime__c = DateTime.newInstance(2013, 1,1,0,0,0);
        insert adm;  

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

        ServAssign = new Service_Assignment__c(
            Name = 'TEST SERV ASSIGN',
            Admission__c = Adm.Id,
            Person_Being_Served__c = person.id,
            Start_Date__c = date.newInstance(2013, 1, 1),
            Status__c = 'Active',
            Program__c = 'IFCS',
            Service_Line__c = 'Intensive In Home - FCT',
            Service_Location__c = svl.id
        );
        insert ServAssign;
        
    }
	
    private static void createEvalData() {
        //create Eval_Type__c records
        Eval_Type__c[] evalTypes = new Eval_Type__c[] {
                new Eval_Type__c(Name = 'Involved Party', Category__c = 'Care Meridian')
        };
        insert evalTypes;

        newEvals.add(new Eval__c(Eval_Type__c = evalTypes[0].id,
                Required__c = false,
                Category__c = 'TEST',
                Category_Sequence__c = 1,
                Cat_Seq_Text__c = '1',
                Sub_Category__c = 'TEST_TEST',
                Sub_Category_Sequence__c = 1,
                SubCat_Seq_Text__c = '1',
                sub_sub_category__c = 'TEST_TEST_TEST',
                Sub_Sub_Category_Sequence__c = 1,
                SubSubCat_Seq_Text__c = '1',
                Field_Name__c = 'IsValid',
                htmlid__c = 'IsValid',
                Field_Type__c = 'Hidden',
                Field_Sub_Type__c = 'Boolean',
                Field_Sequence__c = Decimal.valueOf('0.00')) );

        newEvals.add(new Eval__c(Eval_Type__c = evalTypes[0].id,
                Required__c = false,
                Category__c = 'TEST',
                Category_Sequence__c = 1,
                Cat_Seq_Text__c = '1',
                Sub_Category__c = 'TEST_TEST',
                Sub_Category_Sequence__c = 1,
                SubCat_Seq_Text__c = '1',
                sub_sub_category__c = 'TEST_TEST_TEST',
                Sub_Sub_Category_Sequence__c = 1,
                SubSubCat_Seq_Text__c = '1',
                Field_Name__c='ErrorMsg',
                htmlid__c='ErrorMsg',
                Field_Type__c='Hidden',
                Field_Sub_Type__c='String',
                Field_Sequence__c=Decimal.valueOf('0.10')));

        newEvals.add(new Eval__c(Eval_Type__c = evalTypes[0].id,
                Required__c = false,
                Category__c = 'TEST',
                Category_Sequence__c = 1,
                Cat_Seq_Text__c = '1',
                Sub_Category__c = 'TEST_TEST',
                Sub_Category_Sequence__c = 1,
                SubCat_Seq_Text__c = '1',
                sub_sub_category__c = 'TEST_TEST_TEST',
                Sub_Sub_Category_Sequence__c = 1,
                SubSubCat_Seq_Text__c = '1',
                Field_Name__c = 'Boolean_Checkbox',
                htmlid__c = 'Boolean_Checkbox',
                Field_Type__c = 'Boolean',
                Field_Sub_Type__c = 'Checkbox',
                Field_Sequence__c = Decimal.valueOf('1.0')));

        newEvals.add(new Eval__c(Eval_Type__c = evalTypes[0].id,
                Required__c = true,
                Category__c = 'TEST',
                Category_Sequence__c = 1,
                Cat_Seq_Text__c = '1',
                Sub_Category__c = 'TEST_TEST',
                Sub_Category_Sequence__c = 1,
                SubCat_Seq_Text__c = '1',
                sub_sub_category__c = 'TEST_TEST_TEST',
                Sub_Sub_Category_Sequence__c = 1,
                SubSubCat_Seq_Text__c = '1',
                Field_Name__c = 'Boolean_Dropdown',
                htmlid__c = 'Boolean_Dropdown',
                Field_Type__c = 'Boolean',
                Field_Sub_Type__c = 'Dropdown',
                Field_Sequence__c = Decimal.valueOf('2.0'),
                visibility_rules__c='{&quot;1&quot;: [&quot;String_3000&quot;]}' ));

        newEvals.add(new Eval__c(Eval_Type__c = evalTypes[0].id,
                Required__c = false,
                Category__c = 'TEST',
                Category_Sequence__c = 1,
                Cat_Seq_Text__c = '1',
                Sub_Category__c = 'TEST_TEST',
                Sub_Category_Sequence__c = 1,
                SubCat_Seq_Text__c = '1',
                sub_sub_category__c = 'TEST_TEST_TEST',
                Sub_Sub_Category_Sequence__c = 1,
                SubSubCat_Seq_Text__c = '1',
                length__c = 3000,
                Field_Name__c = 'String_3000',
                htmlid__c = 'String_3000',
                Field_Type__c = 'String',
                Field_Sequence__c = Decimal.valueOf('3.0')));

        newEvals.add(new Eval__c(Eval_Type__c = evalTypes[0].id,
                Required__c = false,
                Category__c = 'TEST',
                Category_Sequence__c = 1,
                Cat_Seq_Text__c = '1',
                Sub_Category__c = 'TEST_TEST',
                Sub_Category_Sequence__c = 1,
                SubCat_Seq_Text__c = '1',
                sub_sub_category__c = 'TEST_TEST_TEST',
                Sub_Sub_Category_Sequence__c = 1,
                SubSubCat_Seq_Text__c = '1',
                Field_Name__c = 'String_300',
                htmlid__c = 'String_300',
                Field_Type__c = 'String',
                Field_Sequence__c = Decimal.valueOf('3.1')));

        newEvals.add(new Eval__c(Eval_Type__c = evalTypes[0].id,
                Required__c = false,
                Category__c = 'TEST',
                Category_Sequence__c = 1,
                Cat_Seq_Text__c = '1',
                Sub_Category__c = 'TEST_TEST',
                Sub_Category_Sequence__c = 1,
                SubCat_Seq_Text__c = '1',
                sub_sub_category__c = 'TEST_TEST_TEST',
                Sub_Sub_Category_Sequence__c = 1,
                SubSubCat_Seq_Text__c = '1',
                Field_Name__c = 'Double',
                htmlid__c = 'Double',
                Field_Type__c = 'Double',
                Field_Sequence__c = Decimal.valueOf('4.0')));

        newEvals.add(new Eval__c(Eval_Type__c = evalTypes[0].id,
                Required__c = false,
                Category__c = 'TEST',
                Category_Sequence__c = 1,
                Cat_Seq_Text__c = '1',
                Sub_Category__c = 'TEST_TEST',
                Sub_Category_Sequence__c = 1,
                SubCat_Seq_Text__c = '1',
                sub_sub_category__c = 'TEST_TEST_TEST',
                Sub_Sub_Category_Sequence__c = 1,
                SubSubCat_Seq_Text__c = '1',
                Field_Name__c = 'Int',
                htmlid__c = 'Int',
                Field_Type__c = 'Int',
                Field_Sequence__c = Decimal.valueOf('5.0')));

        newEvals.add(new Eval__c(Eval_Type__c = evalTypes[0].id,
                Required__c = false,
                Category__c = 'TEST',
                Category_Sequence__c = 1,
                Cat_Seq_Text__c = '1',
                Sub_Category__c = 'TEST_TEST',
                Sub_Category_Sequence__c = 1,
                SubCat_Seq_Text__c = '1',
                sub_sub_category__c = 'TEST_TEST_TEST',
                Sub_Sub_Category_Sequence__c = 1,
                SubSubCat_Seq_Text__c = '1',
                Field_Name__c = 'DropDown',
                htmlid__c = 'DropDown',
                Field_Type__c = 'DropDown',
                Field_Sequence__c = Decimal.valueOf('6.0')));

        newEvals.add(new Eval__c(Eval_Type__c = evalTypes[0].id,
                Required__c = false,
                Category__c = 'TEST',
                Category_Sequence__c = 1,
                Cat_Seq_Text__c = '1',
                Sub_Category__c = 'TEST_TEST',
                Sub_Category_Sequence__c = 1,
                SubCat_Seq_Text__c = '1',
                sub_sub_category__c = 'TEST_TEST_TEST',
                Sub_Sub_Category_Sequence__c = 1,
                SubSubCat_Seq_Text__c = '1',
                Field_Name__c = 'Date',
                htmlid__c = 'Date',
                Field_Type__c = 'Date',
                Field_Sequence__c = Decimal.valueOf('7.0')));

        newEvals.add(new Eval__c(Eval_Type__c = evalTypes[0].id,
                Required__c = false,
                Category__c = 'TEST',
                Category_Sequence__c = 1,
                Cat_Seq_Text__c = '1',
                Sub_Category__c = 'TEST_TEST',
                Sub_Category_Sequence__c = 1,
                SubCat_Seq_Text__c = '1',
                sub_sub_category__c = 'TEST_TEST_TEST',
                Sub_Sub_Category_Sequence__c = 1,
                SubSubCat_Seq_Text__c = '1',
                Field_Name__c = 'Datetime',
                htmlid__c = 'Datetime',
                Field_Type__c = 'Datetime',
                Field_Sequence__c = Decimal.valueOf('8.0')));

        newEvals.add(new Eval__c(Eval_Type__c = evalTypes[0].id,
                Required__c = true,
                Category__c = 'TEST',
                Category_Sequence__c = 1,
                Cat_Seq_Text__c = '1',
                Sub_Category__c = 'TEST_TEST',
                Sub_Category_Sequence__c = 1,
                SubCat_Seq_Text__c = '1',
                sub_sub_category__c = 'TEST_TEST_TEST',
                Sub_Sub_Category_Sequence__c = 1,
                SubSubCat_Seq_Text__c = '1',
                Field_Name__c = 'Multiselect_Checkbox',
                htmlid__c = 'Multiselect_Checkbox',
                Field_Type__c = 'Multiselect',
                Field_Sub_Type__c = 'Checkbox',
                Field_Sequence__c = Decimal.valueOf('9.0')));

        newEvals.add(new Eval__c(Eval_Type__c = evalTypes[0].id,
                Required__c = false,
                Category__c = 'TEST',
                Category_Sequence__c = 1,
                Cat_Seq_Text__c = '1',
                Sub_Category__c = 'TEST_TEST',
                Sub_Category_Sequence__c = 1,
                SubCat_Seq_Text__c = '1',
                sub_sub_category__c = 'TEST_TEST_TEST',
                Sub_Sub_Category_Sequence__c = 1,
                SubSubCat_Seq_Text__c = '1',
                Field_Name__c = 'Multiselect',
                htmlid__c = 'Multiselect',
                Field_Type__c = 'Multiselect',
                Field_Sequence__c = Decimal.valueOf('10.0'),
                Visible__c = true,
                Involved_Party_Type__c = 'Other')
                );

        newEvals.add(new Eval__c(Eval_Type__c = evalTypes[0].id,
                Required__c = false,
                Category__c = 'TEST',
                Category_Sequence__c = 1,
                Cat_Seq_Text__c = '1',
                Sub_Category__c = 'TEST_TEST',
                Sub_Category_Sequence__c = 1,
                SubCat_Seq_Text__c = '1',
                sub_sub_category__c = 'TEST_TEST_TEST',
                Sub_Sub_Category_Sequence__c = 1,
                SubSubCat_Seq_Text__c = '1',
                Field_Name__c = 'BodyMap',
                htmlid__c = 'BodyMap',
                Field_Type__c = 'BodyMap',
                Field_Sequence__c = Decimal.valueOf('11.0')));

        newEvals.add(new Eval__c(Eval_Type__c = evalTypes[0].id,
                Required__c = false,
                Category__c = 'TEST',
                Category_Sequence__c = 1,
                Cat_Seq_Text__c = '1',
                Sub_Category__c = 'TEST_TEST',
                Sub_Category_Sequence__c = 1,
                SubCat_Seq_Text__c = '1',
                sub_sub_category__c = 'TEST_TEST_TEST',
                Sub_Sub_Category_Sequence__c = 1,
                SubSubCat_Seq_Text__c = '1',
                Field_Name__c = 'Image',
                htmlid__c = 'Image',
                Field_Type__c = 'Image',
                field_sub_type__c= 'Image',
                Field_Sequence__c = Decimal.valueOf('12.0'),
                Visible__c = true,
                Involved_Party_Type__c = 'Other'));

        newEvals.add(new Eval__c(Eval_Type__c = evalTypes[0].id,
                Required__c = false,
                Category__c = 'TEST',
                Category_Sequence__c = 1,
                Cat_Seq_Text__c = '1',
                Sub_Category__c = 'TEST_TEST',
                Sub_Category_Sequence__c = 1,
                SubCat_Seq_Text__c = '1',
                sub_sub_category__c = 'TEST_TEST_TEST',
                Sub_Sub_Category_Sequence__c = 1,
                SubSubCat_Seq_Text__c = '1',
                Field_Name__c = 'Slider',
                htmlid__c = 'Slider',
                Field_Type__c = 'Slider',
                Field_Sequence__c = Decimal.valueOf('10.0'),
                Involved_Party_Type__c = 'Other'));

        insert newEvals;

        list < eval_drop_down__c > dropdowns = new list < eval_drop_down__c > ();
        //create eval_drop_down__c
        for (eval__c eval: [Select Id from Eval__c where Category__c = 'TEST' and (Field_Type__c = 'DropDown' Or Field_Type__c = 'Multiselect')] ) {
            dropdowns.add(new eval_drop_down__c(What_Id_Object__c = 'Eval__c', whatid__c = eval.id, option_name__c = 'TEST', option_value__c = 'TEST'));
            dropdowns.add(new eval_drop_down__c(What_Id_Object__c = 'Eval__c', whatid__c = eval.id, option_name__c = 'TEST1', option_value__c = 'TEST1'));
        }
        insert dropdowns;

    }

}