@isTest
public class GenerateRiskSectionTest {
	static List<Eval__c> newEvals = new List<Eval__c>();
  	static List<Eval__c> realEvals = new List<Eval__c>();
    
    static testMethod void simpleTests(){
    	TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
    	Case_Management_Plan__c isp = new Case_Management_Plan__c(Status__c = 'Inactive Draft', Service_Assignment__c = myData.theSA.Id);
    	insert isp;
    	createData();
    	
    	
    	GenerateRiskSection component = new GenerateRiskSection();
    	Eval_Type__c evlTyp = [Select Name, id from Eval_Type__c where Name = 'Risk Identification Tool'];
    	component.showActionButtons = false;
	    component.editable = true;
	    component.evalname = evlTyp.Name;
	    component.casemanagementID = isp.id;
	    component.cat = 'TEST';
	    component.subCat = 'TEST_TEST';
	    component.batchUpsert = true;
	    component.batchInsert = false;
	    
	    list<GenerateRiskSection.FormKeyVal> evalVals = new list<GenerateRiskSection.FormKeyVal>();
	    String evalSecId = UserInfo.getUserId() + '-' + DateTime.now().getTime();
	    for (Eval__c e : newEvals){
	      GenerateRiskSection.FormKeyVal val = new GenerateRiskSection.FormKeyVal();
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
	        val.value = '04/27/2015 18:00';
	      else if(e.Field_Type__c == 'Multiselect') {
	        val.value = 'TEST';
	        GenerateRiskSection.FormKeyVal val1 = new GenerateRiskSection.FormKeyVal();
	        val1.name= e.id;
	        val1.value = 'TEST1';
	        evalVals.add(val1);
	      }
	      else
	        val.value = 'String,ID,Dropdown,Double,Currency values.';
	
	      evalVals.add(val);
	      GenerateRiskSection.FormKeyVal valEsi = new GenerateRiskSection.FormKeyVal();
	      valEsi.name = e.id + '_esi';
	      valEsi.value = evalSecId;
	      evalVals.add(valEsi);
	    }
	

	
	    GenerateRiskSection.saveFields(isp.id, UserInfo.getUserId() + '-' + DateTime.now().formatLong(),
	        evlTyp.Name, evlTyp.Name, JSON.serialize(evalVals), false, true);
	
	    component.evalSectionId = [select Eval_Section_Id__c from eval_value__c limit 1].Eval_Section_Id__c;
	
	    evalVals.remove(0);
	    GenerateRiskSection.saveFields(isp.id, component.evalSectionId,
	        evlTyp.Name, evlTyp.Name, JSON.serialize(evalVals), false, true);
	
	    List<String> composites;
	    composites = component.getComposites();
	    System.assertNotEquals(0, composites.size());
	    for (String composite: composites) {
	      System.assertNotEquals('N/A', component.compositeToHtmlMap.get(composite));
	    }
	    
	    
    }
    
    
    private static void createData(){
    	Eval_Type__c evalType = new Eval_Type__c(Name='Risk Identification Tool', Category__c = 'Oregon Combined ISP');
    	insert evalType;
    	
    	newEvals.add(new Eval__c(Eval_Type__c = evalType.id,
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
        Field_Sequence__c = Decimal.valueOf('0.00')));

    	newEvals.add(new Eval__c(Eval_Type__c = evalType.id,
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

    	newEvals.add(new Eval__c(Eval_Type__c = evalType.id,
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

    	newEvals.add(new Eval__c(Eval_Type__c = evalType.id,
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
        Field_Sequence__c = Decimal.valueOf('2.0')));
        
        newEvals.add(new Eval__c(Eval_Type__c = evalType.id,
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

    	newEvals.add(new Eval__c(Eval_Type__c = evalType.id,
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

    	newEvals.add(new Eval__c(Eval_Type__c = evalType.id,
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

    	newEvals.add(new Eval__c(Eval_Type__c = evalType.id,
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

    	newEvals.add(new Eval__c(Eval_Type__c = evalType.id,
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

    	newEvals.add(new Eval__c(Eval_Type__c = evalType.id,
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

    	newEvals.add(new Eval__c(Eval_Type__c = evalType.id,
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

    	newEvals.add(new Eval__c(Eval_Type__c = evalType.id,
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

    	newEvals.add(new Eval__c(Eval_Type__c = evalType.id,
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
        Field_Sequence__c = Decimal.valueOf('10.0')));

    	newEvals.add(new Eval__c(Eval_Type__c = evalType.id,
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

    	newEvals.add(new Eval__c(Eval_Type__c = evalType.id,
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
        Field_Sequence__c = Decimal.valueOf('12.0')));

    	newEvals.add(new Eval__c(Eval_Type__c = evalType.id,
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
        Field_Sequence__c = Decimal.valueOf('10.0')));

    	insert newEvals;
    	
    	realEvals.add(
	      new Eval__c(
	        Eval_Type__c = evalType.id,
	        Required__c = true,
	        Category__c = 'Health and Medical',
	        Category_Sequence__c = 1,
	        Cat_Seq_Text__c = '6001',
	        Sub_Category__c = 'Seizures',
	        Sub_Category_Sequence__c = 5,
	        SubCat_Seq_Text__c = '6005',
	        sub_sub_category__c = '',
	        Sub_Sub_Category_Sequence__c = 1,
	        SubSubCat_Seq_Text__c = '1',
	        Field_Name__c = 'IsValid',
	        htmlid__c = 'IsValid',
	        Field_Type__c = 'Hidden',
	        Field_Sub_Type__c = 'Boolean',
	        Field_Sequence__c = Decimal.valueOf('1.0')
	      )
	    );
	    realEvals.add(
	      new Eval__c(
	        Eval_Type__c = evalType.id,
	        Required__c = true,
	        Category__c = 'Safety',
	        Category_Sequence__c = 1,
	        Cat_Seq_Text__c = '1',
	        Sub_Category__c = 'Water Temperature Safety',
	        Sub_Category_Sequence__c = 2,
	        SubCat_Seq_Text__c = '2',
	        sub_sub_category__c = '',
	        Sub_Sub_Category_Sequence__c = 1,
	        SubSubCat_Seq_Text__c = '1',
	        Field_Name__c = 'IsValid',
	        htmlid__c = 'IsValid',
	        Field_Type__c = 'Hidden',
	        Field_Sub_Type__c = 'Boolean',
	        Field_Sequence__c = Decimal.valueOf('1.0')
	      )
	    );
	    realEvals.add(
	      new Eval__c(
	        Eval_Type__c = evalType.id,
	        Required__c = true,
	        Category__c = 'Financial',
	        Category_Sequence__c = 1,
	        Cat_Seq_Text__c = '1',
	        Sub_Category__c = 'Potential for Financial Abuse',
	        Sub_Category_Sequence__c = 3,
	        SubCat_Seq_Text__c = '3',
	        sub_sub_category__c = '',
	        Sub_Sub_Category_Sequence__c = 1,
	        SubSubCat_Seq_Text__c = '1',
	        Field_Name__c = 'IsValid',
	        htmlid__c = 'IsValid',
	        Field_Type__c = 'Hidden',
	        Field_Sub_Type__c = 'Boolean',
	        Field_Sequence__c = Decimal.valueOf('1.0')
	      )
	    );
	    
	    realEvals.add(
	      new Eval__c(
	        Eval_Type__c = evalType.id,
	        Required__c = true,
	        Category__c = 'Mental Health',
	        Category_Sequence__c = 1,
	        Cat_Seq_Text__c = '1',
	        Sub_Category__c = 'Mental Health',
	        Sub_Category_Sequence__c = 1,
	        SubCat_Seq_Text__c = '1',
	        sub_sub_category__c = '',
	        Sub_Sub_Category_Sequence__c = 1,
	        SubSubCat_Seq_Text__c = '1',
	        Field_Name__c = 'IsValid',
	        htmlid__c = 'IsValid',
	        Field_Type__c = 'Hidden',
	        Field_Sub_Type__c = 'Boolean',
	        Field_Sequence__c = Decimal.valueOf('1.0')
	      )
	    );
	    
	    realEvals.add(
	      new Eval__c(
	        Eval_Type__c = evalType.id,
	        Required__c = true,
	        Category__c = 'Behavior',
	        Category_Sequence__c = 1,
	        Cat_Seq_Text__c = '1',
	        Sub_Category__c = 'Physical Aggression',
	        Sub_Category_Sequence__c = 1,
	        SubCat_Seq_Text__c = '1',
	        sub_sub_category__c = '',
	        Sub_Sub_Category_Sequence__c = 1,
	        SubSubCat_Seq_Text__c = '1',
	        Field_Name__c = 'IsValid',
	        htmlid__c = 'IsValid',
	        Field_Type__c = 'Hidden',
	        Field_Sub_Type__c = 'Boolean',
	        Field_Sequence__c = Decimal.valueOf('1.0')
	      )
	    );
	    
	    insert realEvals;
    
    	list < eval_drop_down__c > dropdowns = new list < eval_drop_down__c > ();
	    //create eval_drop_down__c
	    for (eval__c eval: [Select Id from Eval__c where Category__c = 'TEST' and (Field_Type__c = 'DropDown' Or Field_Type__c = 'Multiselect')] ) {
	      dropdowns.add(new eval_drop_down__c(What_Id_Object__c = 'Eval__c', whatid__c = eval.id, option_name__c = 'TEST', option_value__c = 'TEST'));
	      dropdowns.add(new eval_drop_down__c(What_Id_Object__c = 'Eval__c', whatid__c = eval.id, option_name__c = 'TEST1', option_value__c = 'TEST1'));
	    }
	    insert dropdowns;
	    
    }
}