public with sharing class ORISPPrint {

    public Case_Management_plan__c isp {get; set;}
    public List<Evaluation_Response__c> desiredOutcomes {get; set;}
    public List<Evaluation_Response__c> employmentOutcomes {get; set;}
    public List<Evaluation_Response__c> otherServicesSupports {get; set;}
    public List<Evaluation_Response__c> kPlanServices {get; set;}
    public List<Evaluation_Response__c> waiverServices {get; set;}
    public List<Evaluation_Response__c> commTransServices {get; set;}
    public List<Evaluation_Response__c> additionalServices {get; set;}
    public List<Evaluation_Response__c> contributors {get; set;}
    public list<riskWrapper> highRisksList {get; set;}
    
    public String getPrintView()
    {
        return
        '<!--[if gte mso 9]>' +
            '<xml>' +
            '<w:WordDocument>' +
            '<w:View>Print</w:View>' +
            '<w:Zoom>100</w:Zoom>' +
            '<w:DoNotOptimizeForBrowser/>' +
            '</w:WordDocument>' +
            '</xml>' +
            '<![endif]>';
    }

    public ORISPPrint(ApexPages.StandardController controller) {
        this.isp = (Case_Management_Plan__c) controller.getRecord();

        desiredOutComes = [SELECT ISP_What_is_the_desired_result__c, ISP_Key_Steps_to_work_toward_outcome__c, ISP_Is_there_a_paid_Service__c,ISP_Paid_Services__c, ISP_Who_is_responsible__c, ISP_Timelines_Frequency_when__c, ISP_Where_to_Record_progress__c, ISP_Note_if_Written_Implementation__c 
                                FROM Evaluation_Response__c WHERE Case_Management_Plan__c = :this.isp.Id AND Recordtype.DEVELOPERNAME = 'Desired_Outcomes'];
    	
    	employmentOutcomes = [SELECT ISP_What_is_the_desired_result__c, ISP_Key_Steps_to_work_toward_outcome__c, ISP_Is_there_a_paid_Service__c, ISP_Paid_Services__c, ISP_Who_is_responsible__c, ISP_Timelines_Frequency_when__c, ISP_Where_to_Record_progress__c, ISP_Note_if_Written_Implementation__c
    							FROM Evaluation_Response__c WHERE Case_Management_Plan__c = :this.isp.Id AND Recordtype.DEVELOPERNAME = 'Employment_Outcomes'];
    	
    	otherServicesSupports = [SELECT ISP_Describe_Chosen_Services_Supports__c, ISP_Supports_Services_Provided_by__c
    								FROM Evaluation_Response__c WHERE Case_Management_Plan__c = :this.isp.Id AND Recordtype.DEVELOPERNAME = 'Other_Services_Supports'];
    	
    	kPlanServices = [SELECT ISP_Service_Element_Service_Code__c, ISP_Units__c, ISP_Unit_Type__c, ISP_Per_Frequency__c, Label__c, ISP_Same_as_plan_year__c, ISP_Start__c, ISP_End__c, ISP_Describe_Chosen_Services_Supports__c, ISP_Identified_needs__c, ISP_Person_Preference_Service_Delivery__c
    								FROM Evaluation_Response__c WHERE Case_Management_Plan__c = :this.isp.Id AND Recordtype.DEVELOPERNAME = 'K_Plan_Services'];
     	
    	waiverServices = [SELECT ISP_Service_Element_Service_Code__c, ISP_Units__c, ISP_Unit_Type__c, ISP_Per_Frequency__c, Label__c, ISP_Same_as_plan_year__c, ISP_Start__c, ISP_End__c, ISP_Describe_Chosen_Services_Supports__c, ISP_Identified_needs__c, ISP_Person_Preference_Service_Delivery__c
    								FROM Evaluation_Response__c WHERE Case_Management_Plan__c = :this.isp.Id AND Recordtype.DEVELOPERNAME = 'Waiver_Services'];
     	
    	commTransServices = [SELECT ISP_Transportation_Type__c, ISP_Same_as_plan_year__c, ISP_Start__c, ISP_End__c, ISP_Describe_Chosen_Services_Supports__c
    								FROM Evaluation_Response__c WHERE Case_Management_Plan__c = :this.isp.Id AND Recordtype.DEVELOPERNAME = 'Community_Transportation_Services'];
     	
    	additionalServices = [SELECT ISP_Describe_service_setting__c, ISP_Identified_needs__c, ISP_Person_Preference_Service_Delivery__c
    								FROM Evaluation_Response__c WHERE Case_Management_Plan__c = :this.isp.Id AND Recordtype.DEVELOPERNAME = 'Additional_Chosen_Services'];

		contributors = [SELECT ISP_Contributor_Name__c, ISP_Title_Relationship_Person__c, ISP_Contributor_Risk_Identification_Tool__c, ISP_Signature_Required__c, ISP_Present_at_Meeting__c, ISP_Type_of_Contributor__c, CreatedDate, ISP_Contributor_Origin_Id__c  
                         			FROM Evaluation_Response__c WHERE Case_Management_Plan__c = :this.isp.Id AND RecordType.Name = 'Contributors & Signatures' order by CreatedDate asc];
                         			
                         			
       highRisksList = new List<riskWrapper>();
       map<string,riskWrapper> riskMap = new  map<string,riskWrapper>();
       
       for(Eval_Value__c ev: [SELECT Boolean__c,Eval__c, Text_over_250__c,  Eval__r.Composite__c, Eval__r.Category__c,  Eval__r.Sub_Category__c FROM Eval_Value__c WHERE (Eval__r.Field_name__c = 'High Risk?' OR Eval__r.Field_name__c = 'How is the risk addressed?') AND What_Id__c =: this.isp.id order by Eval__r.SubCat_Seq_Text__c asc]){
       		if(!riskMap.containsKey(ev.Eval__r.Composite__c)){
       			riskMap.put(ev.Eval__r.Composite__c, new riskWrapper());
       		}
       		riskWrapper rw = riskMap.get(ev.Eval__r.Composite__c);
       		if(ev.Boolean__c){
       			rw.highRisk = true;
       			rw.risk = ev.Eval__r.Sub_Category__c;
       			riskMap.put(ev.Eval__r.Composite__c, rw);
       		}
       		if(string.isNOTBLANK(ev.Text_over_250__c)){
       			rw.risk = ev.Eval__r.Sub_Category__c;
       			rw.howAddressed = ev.Text_over_250__c;
       			riskMap.put(ev.Eval__r.Composite__c, rw);
       		}
       }
       
       highRisksList = riskMap.values();
       
       System.debug('high risk list    >>>>> '+highRisksList);
    }
    
   public class riskWrapper{
    	public string  risk    			{get;set;}
    	public Boolean highRisk			{get;set;}
    	public string  howAddressed 	{get;set;}
    	
    	
    }

}