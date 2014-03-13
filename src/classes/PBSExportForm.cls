public with sharing class PBSExportForm {
    public ApexPages.StandardController PBSController {get;set;}
    public PBSExportForm(ApexPages.StandardController controller) {
        PBSController = controller;
    }
    
    public void exportPerson(){
        DataExport util = new DataExport();
        
        xmlout = util.Export(PBSController.getrecord());
    }
    
    public string xmlOut { get ; set;}

}