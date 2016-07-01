@isTest
public with sharing class NgTemp {



private void toInsertIsValidAndErrMsg(){
	list<Eval__c> evals = new list<Eval__c>();
	set<AggregateResult> evalsSections = new set<AggregateResult>( [select eval_type__c, eval_type__r.name, category__c, sub_category__c, cat_seq_text__c, subcat_seq_text__c
									       from eval__c 
										where eval_type__r.name = 'Involved Party' and visible__c = true  
				                        group by eval_type__c, eval_type__r.name, cat_seq_text__c, subcat_seq_text__c, category__c, sub_category__c]);
				                        
	list<AggregateResult> sectionsToRemove = [select eval_type__c, eval_type__r.name, category__c, sub_category__c, cat_seq_text__c, subcat_seq_text__c
									       from eval__c 
										where eval_type__r.name = 'Involved Party' and visible__c = true and htmlid__c = 'IsValid' 
				                        group by eval_type__c, eval_type__r.name, cat_seq_text__c, subcat_seq_text__c, category__c, sub_category__c];
				                        
	evalsSections.removeAll(sectionsToRemove);		                        
				                        
		for (AggregateResult section : evalsSections) {
		            evals.add(new Eval__c(Eval_Type__c=(string)section.get('Eval_Type__c'), 
		                                    Required__c = false, 
		                                    Category__c= (string) section.get('Category__c'),
		                                    Category_Sequence__c= Math.mod(Integer.valueOf(section.get('Cat_Seq_Text__c')), 1000),
		                                    Cat_Seq_Text__c=(string)section.get('Cat_Seq_Text__c'),
		                                    Sub_Category__c=(string)section.get('Sub_Category__c'),
		                                    Sub_Category_Sequence__c=Math.mod(Integer.valueOf(section.get('SubCat_Seq_Text__c')), 1000),
		                                    SubCat_Seq_Text__c=(string)section.get('SubCat_Seq_Text__c'),
		                                    //sub_sub_category__c = (string)section.get('sub_sub_category__c'),
		                                    //Sub_Sub_Category_Sequence__c= Math.mod(Integer.valueOf(section.get('SubSubCat_Seq_Text__c')), 1000),
		                                    //SubSubCat_Seq_Text__c=(string)section.get('SubSubCat_Seq_Text__c'),
		                                    Field_Name__c='IsValid',
		                                    htmlid__c='IsValid',
		                                    Visible__c = true, 
		                                    Field_Type__c='Hidden',
		                                    Field_Sub_Type__c='Boolean',                          
		                                    Field_Sequence__c=Decimal.valueOf('0.0')) );
		       
		           evals.add(new Eval__c(Eval_Type__c=(string)section.get('Eval_Type__c'),
		                                    Required__c = false, 
		                                    Category__c= (string) section.get('Category__c'),
		                                    Category_Sequence__c= Math.mod(Integer.valueOf(section.get('Cat_Seq_Text__c')), 1000),
		                                    Cat_Seq_Text__c=(string)section.get('Cat_Seq_Text__c'),
		                                    Sub_Category__c=(string)section.get('Sub_Category__c'),
		                                    Sub_Category_Sequence__c=Math.mod(Integer.valueOf(section.get('SubCat_Seq_Text__c')), 1000),
		                                    SubCat_Seq_Text__c=(string)section.get('SubCat_Seq_Text__c'),
		                                    //sub_sub_category__c = (string)section.get('sub_sub_category__c'),
		                                    //Sub_Sub_Category_Sequence__c= Math.mod(Integer.valueOf(section.get('SubSubCat_Seq_Text__c')), 1000),
		                                    //SubSubCat_Seq_Text__c=(string)section.get('SubSubCat_Seq_Text__c'),
		                                    Field_Name__c='ErrorMsg',
		                                    htmlid__c='ErrorMsg', 
		                                    Visible__c = true,
		                                    Field_Type__c='Hidden',
		                                    Field_Sub_Type__c='String',                                   
		                                    Field_Sequence__c=Decimal.valueOf('0.1')) );
		}
		upsert evals;
	
}


}