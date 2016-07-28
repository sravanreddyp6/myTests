public class ORRisktoolPrint{
	Apexpages.StandardController controller;
	public Case_Management_Plan__c isp {get; set;}
	
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
	}
	
	
	
	
	

}