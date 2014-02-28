public with sharing class PBSExportForm {
    public ApexPages.StandardController PBSController {get;set;}
    public PBSExportForm(ApexPages.StandardController controller) {
        PBSController = controller;
    }
    
    public void exportPerson(){
        DataCreate util = new DataCreate();
        
        xmlout = '<objects>\n' + util.Export(PBSController.getrecord()) + '</objects>\n';
    }
    
    public string xmlOut { get ; set;}

}