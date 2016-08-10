public class ORRisktoolPrint{
	Apexpages.StandardController controller;
	public Case_Management_Plan__c isp {get; set;}
	public List<Evaluation_Response__c> evaluations {get; set;}
	public List<Evaluation_Response__c> contributors = new List<Evaluation_Response__c>();	
	public List<wContributor> wContributors {get; set;}
	public Map<String,Eval_Value__c> YesNovalueMap {get;set;}
	public string YesnokeyCheck {get; set;}
	public Map<string, string> commentsValueMap {get; set;}
	
	public set<string> options = new set<string>{'Yes','Possible','History','No', 'Risk Present', 'No Risk', 'Other (see comments)'};
	
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
	
	public ORRisktoolPrint(Apexpages.StandardController controller){
		this.controller = controller;
		this.isp = (Case_Management_Plan__c)controller.getRecord();
		evaluations = new List<Evaluation_Response__c>();
		evaluations = [SELECT ISP_Risks__c, ISP_Specify_Other__c, ISP_Type_of_evaluation__c, ISP_Evaluation_Date__c, ISP_Has_condition_changed_evaluation__c, ISP_Where_evaluation_is_kept__c
    							FROM Evaluation_Response__c WHERE Case_Management_Plan__c = :this.isp.Id AND Recordtype.DEVELOPERNAME = 'Evaluation'];					
 	    contributors = [SELECT ISP_Contributor_Name__c, ISP_Title_Relationship_Person__c
    							FROM Evaluation_Response__c WHERE Case_Management_Plan__c = :this.isp.Id AND Recordtype.DEVELOPERNAME = 'Contributors_Signatures' order by CreatedDate asc];
        wContributors = new List<wContributor>();
        prepareContributorList(contributors);
        
        YesNovalueMap = new Map<string, Eval_Value__c>();
        YesnokeyCheck = '';
        

 
        commentsValueMap = new Map<String, string>();
        commentsValueMap.put('Behavior', '');
        commentsValueMap.put('Mental Health', '');
        commentsValueMap.put('Financial', '');
        commentsValueMap.put('Safety', '');
        
        for(Eval_Value__c ev: [SELECT Boolean__c,Date_Time__c,Text_Under_250__c, Text_Over_250__c, Eval__r.Composite__c, Eval__r.Category__c, Eval__r.htmlid__c, Eval__r.Field_name__c FROM Eval_Value__c WHERE  What_Id__c = :this.isp.id]){
    		YesNovalueMap.put(ev.Eval__r.Composite__c+'~'+ev.Eval__r.htmlid__c, ev);
    		YesnokeyCheck += ev.Eval__r.Composite__c+'~'+ev.Eval__r.htmlid__c;
        
        	if(ev.Eval__r.Category__c != 'Health and Medical' && ev.Eval__r.Field_Name__c == 'Comments'){
        		string s = commentsValueMap.get(ev.Eval__r.Category__c);
        		s += '  '+ev.Eval__r.Composite__c.SubstringAfterLast('~')+': '+ev.Text_Over_250__c;
        		commentsValueMap.put(ev.Eval__r.Category__c, s);
        	}
        	
        }
        
	}
	
	//This is needed because in word document there are two columns to display the data.
	public void prepareContributorList(List<Evaluation_Response__c> contributors){
		integer j = 0;
		for(integer i=0; i < (contributors.size()+1)/2; i++){
			wContributor wC = new wContributor();
			if(math.mod(j, 2) == 0 && j < contributors.size()){
				wC.name1 = contributors[j].ISP_Contributor_Name__c;
				wC.relation1 = contributors[j].ISP_Title_Relationship_Person__c;
				j = j+1;
			}
			if(math.mod(j, 2) != 0 && j < contributors.size()){
				wC.name2 = contributors[j].ISP_Contributor_Name__c;
				wC.relation2 = contributors[j].ISP_Title_Relationship_Person__c;
				j= j+1;
			}
			
			wContributors.add(wC);
		}
	}
	
	
	public class wContributor{
		public string name1 {get;set;}
		public string relation1 {get; set;}
		public string name2 {get;set;}
		public string relation2 {get; set;}
		
		public wContributor(){
			
		}
	}

}