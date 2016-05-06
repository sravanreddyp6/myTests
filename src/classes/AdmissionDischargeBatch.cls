global class AdmissionDischargeBatch implements Database.Batchable<sObject> {
    
    //Admission's id list
    List<String> admIds = new list<String> { 'a0DU000001EUfSW', 'a0DU000000kTVXv', 'a0DU000000kTVZk', 'a0DU0000013s88K', 'a0DU000001DpdGQ', 'a0DU000001Cyi5m', 'a0DU000001DCdqq', 'a0DU000001DCdN4', 'a0DU000001CxTFp', 'a0DU000001CFH0l' };
        //'a0DU000001DE8Us', 'a0DU000000S1Hf6', 'a0DU000001CxTXU', 'a0DU000001EUVuZ', 'a0DU000000Krp4G', 'a0DU000000S1o0v', 'a0DU000001AKltt', 'a0DU000001AKlng', 'a0DU000001EUDtm', 'a0DU000001DxiK2', 'a0DU000001DoXvH', 'a0DU0000018Vz4M', 'a0DU000001Ca1Sw', 'a0DU000001Ca1V5', 'a0DU000001DqbCC', 'a0DU000001DX2rf','a0DU000001DyAGf', 'a0DU000001AKgVW', 'a0DU000001DBueT', 'a0DU000000kU4kC', 'a0DU000001DBkNE', 'a0DU0000019k66z', 'a0DU000001E4f5C', 'a0DU000001DEHLG', 'a0DU000001DBw5F', 'a0DU0000013tkLr', 'a0DU000001DyQEp', 'a0DU000001DpzhT', 'a0DU000001DFGl9', 'a0DU000001DZmEM', 'a0DU00000188iOZ', 'a0DU000001DBwHL', 'a0DU000001DxjHN', 'a0DU000001AKXew', 'a0DU000001DxjqD', 'a0DU000001DBuvO', 'a0DU000001BxZgu', 'a0DU000001Dxed8', 'a0DU000001ALLvN', 'a0DU0000013tvtl', 'a0DU0000013tyni', 'a0DU000001DBkXA', 'a0DU000001AKY8j', 'a0DU0000013tH0J', 'a0DU00000188up4', 'a0DU000001DX2jg', 'a0DU000001Bv2pC', 'a0DU000001DEGtX', 'a0DU000001E57et', 'a0DU000001ALLwV', 'a0DU000001AKYFK', 'a0DU0000013u1VU', 'a0DU0000019pXpC', 'a0DU000001B6Wnd', 'a0DU000001E50c5', 'a0DU000001CvwO7', 'a0DU000001DX2cl', 'a0DU000001DyB3l', 'a0DU000001DDuws', 'a0DU000001EU4sL', 'a0DU0000013t8S2', 'a0DU000001EMeD8', 'a0DU0000019JPxa', 'a0DU000001DyrWr', 'a0DU000001BwOfr', 'a0DU000001DFOCZ', 'a0DU000001DZR5K', 'a0DU000001Cvc5D', 'a0DU000001CvbpX', 'a0DU000000kSeLt', 'a0DU000001DBi3d', 'a0DU000000kTTmt', 'a0DU000001EUIkx', 'a0DU000001B9IE9', 'a0DU000001E4xpp', 'a0DU000001DBhbr', 'a0DU000001Dyd1b', 'a0DU000001DqMmn', 'a0DU000001AKgJ1', 'a0DU000001Dqm2I', 'a0DU000001DyrRb', 'a0DU000000S53zp', 'a0DU0000019rD76', 'a0DU000001DBip7', 'a0DU00000187JVw', 'a0DU0000019GVTB', 'a0DU000001B6vlm', 'a0DU000001DxjHm', 'a0DU000001E4Y1D', 'a0DU000001B5jSh', 'a0DU000001AL7Pg', 'a0DU0000013r2M3', 'a0DU000001Ca9PC', 'a0DU000001E4c9s', 'a0DU000001DCH30', 'a0DU000000S53xy', 'a0DU000000S53yw', 'a0DU000001BxZRj', 'a0DU000001DBkuM', 'a0DU000001AKz8Q', 'a0DU000001AK2bE', 'a0DU000001DBsKv', 'a0DU000001CHQXc', 'a0DU0000018Ulzo', 'a0DU0000018Um0X', 'a0DU000001AKsCo', 'a0DU000001E5Ga1', 'a0DU000001Dr5bX', 'a0DU000001DxL9y', 'a0DU000001DX2VD', 'a0DU000001DEFww', 'a0DU000001DyrUg', 'a0DU000001DBjmz', 'a0DU000001Dy76M', 'a0DU000001CdmMs', 'a0DU000001B5jpH', 'a0DU000001DBl2D', 'a0DU000001DBwqO', 'a0DU000001DXNQ3', 'a0DU000000kT4R4', 'a0DU000000KuEgN', 'a0DU000001DxPDF', 'a0DU000001Dxehx', 'a0DU000001ETSG6', 'a0DU000001DZjNJ', 'a0DU000001DX2Pt', 'a0DU000001B6vsy', 'a0DU0000013ufZN', 'a0DU000001DX2OC', 'a0DU000001AL30t', 'a0DU000001CwMFN', 'a0DU00000187S8j', 'a0DU000001AKspD', 'a0DU000000S53oQ', 'a0DU000001Cvtlg', 'a0DU000001DBlU1', 'a0DU000001Dxs1E', 'a0DU000001Dxorz', 'a0DU000001E4cOx', 'a0DU000001Dy6o2', 'a0DU000001AI1Mt', 'a0DU000001DpSXL', 'a0DU000001DBijx', 'a0DU000001CdmwJ', 'a0DU000001Cdmnh', 'a0DU000001DF9f5', 'a0DU000001DYMTi', 'a0DU000001AK9av', 'a0DU000001AK9Ux', 'a0DU000001E57GY', 'a0DU000001EOnLM', 'a0DU000001DqTjR', 'a0DU000001DDWFW', 'a0DU000001DxL5y', 'a0DU000001DyB7M', 'a0DU000001CvuK7', 'a0DU000001CG9mQ', 'a0DU0000019JfJr', 'a0DU000001DEGCt', 'a0DU000001B5r9D', 'a0DU000001DaK4S', 'a0DU000001DxLgW', 'a0DU000001DF9mS', 'a0DU000001DDEFF', 'a0DU000001DBuXw', 'a0DU000001B5cbr', 'a0DU000001EP4cL', 'a0DU000000S37rG', 'a0DU000001DBwTm', 'a0DU0000019JPD5', 'a0DU000001Cazan', 'a0DU000001Dr5dw', 'a0DU000001DEydT', 'a0DU000001DFGw7', 'a0DU000001DwipZ', 'a0DU000001DFHGg', 'a0DU000001DxeXy', 'a0DU000001DxecC', 'a0DU000001Cdwr8', 'a0DU0000019jnDe', 'a0DU0000013t2JX', 'a0DU000001DBue9', 'a0DU000001EMeEV', 'a0DU0000013uJVM', 'a0DU0000013uJQl', 'a0DU000001EMeKn', 'a0DU000001876iW', 'a0DU000001Ca1Ve', 'a0DU000001DEGa6', 'a0DU000001DxovD', 'a0DU000001AJ5MW', 'a0DU000001E5LEg', 'a0DU000001DBlM9', 'a0DU000001E5Ihm', 'a0DU000001876xr', 'a0DU000001E58CP', 'a0DU000001DxjxF', 'a0DU000000S545Y', 'a0DU000000Kssrt', 'a0DU000001CyXPu', 'a0DU000001DBuEU', 'a0DU000001CIt1k', 'a0DU000001E57zM', 'a0DU000001DxxpP', 'a0DU000001DyVmR', 'a0DU000001DBl6U', 'a0DU000001DBlVO', 'a0DU000001EL9eC', 'a0DU000001DBwaV', 'a0DU000001ALLeR', 'a0DU000001B6oCZ', 'a0DU000001E56QL', 'a0DU000001DBhWD', 'a0DU000001E51yo', 'a0DU000001EUBKi', 'a0DU000001ETS87', 'a0DU0000013rnQ5', 'a0DU000001Bwkzl', 'a0DU000001AKgR0', 'a0DU000001AKgNI', 'a0DU000001AKgP4', 'a0DU000001AKtHf', 'a0DU000001B8uyw', 'a0DU000001B7U9n', 'a0DU000001DwjSm', 'a0DU000001B7UMa', 'a0DU000001ETSK3', 'a0DU000001DqcS1', 'a0DU000001DFOCA', 'a0DU000001EO5ZR', 'a0DU0000013tkIn', 'a0DU000001DBlXe', 'a0DU000001DaAme', 'a0DU0000013tyzh', 'a0DU000001DxjhH', 'a0DU000001B9VTV', 'a0DU000001DBiTC', 'a0DU000001B5jVu', 'a0DU000000kUBY2', 'a0DU000001E4mRO', 'a0DU000001E5DWq', 'a0DU000001DaHwA', 'a0DU0000018V4ZK', 'a0DU000001DBibf', 'a0DU000001DyNJS', 'a0DU000001DBiZj', 'a0DU000001DX2dK', 'a0DU000001Dxjup', 'a0DU000001CaRDG', 'a0DU000001CaREi', 'a0DU000001Dp4xd', 'a0DU000001DppMe', 'a0DU000001DxP6D', 'a0DU000001DxiHk', 'a0DU000001DxTPc', 'a0DU000001Do4rf', 'a0DU0000018Vgax', 'a0DU000001AKk3u', 'a0DU000001DyQIz', 'a0DU000001EU8Kq', 'a0DU000000kTTnS', 'a0DU000000kTTnc', 'a0DU000001DxLAN', 'a0DU000001DFODw', 'a0DU0000019GuqO', 'a0DU000000kTJpR', 'a0DU000000kTJnf', 'a0DU000000kTJsq', 'a0DU000001DCloT', 'a0DU000001CIPQI', 'a0DU00000188yPV', 'a0DU000000Ks3Sp', 'a0DU000001DBlhL', 'a0DU000001Dqmvd', 'a0DU000001Dqmwn', 'a0DU000001Ca0qx', 'a0DU000001EP79I', 'a0DU000001DwSj7', 'a0DU0000018Vz55', 'a0DU000001AKqYR', 'a0DU000000S53m7', 'a0DU000001DXHw8', 'a0DU000001BxOFH', 'a0DU000001DyQQz', 'a0DU000001DxjmW', 'a0DU000001Dy0PN', 'a0DU000001EUZuY', 'a0DU000001EUa7m', 'a0DU000000kQZ8O', 'a0DU000000S4gss', 'a0DU000000kU9LI', 'a0DU000001E50UQ', 'a0DU000001DyRQz', 'a0DU000001DpgYU', 'a0DU000001AKkFV', 'a0DU000001DBhi4', 'a0DU000001DppAY', 'a0DU000001DFGzu', 'a0DU000001DFJ8k', 'a0DU000001DFJGd', 'a0DU000001DBwUQ', 'a0DU000001DBwV1', 'a0DU000001B5ubr', 'a0DU000001B7pkd', 'a0DU000001ALHuq', 'a0DU000000kSalz', 'a0DU000001DBhjP', 'a0DU000001AKYFe', 'a0DU000001DoH4E', 'a0DU000001DxOrK', 'a0DU000001DyQK8', 'a0DU000001DzSdY', 'a0DU000001BxsLH', 'a0DU000001CGuC8', 'a0DU000001DBjl3', 'a0DU000001DBu3l', 'a0DU000001DBliJ', 'a0DU000001DFNsy', 'a0DU000001EUDfS', 'a0DU000001BxZnK', 'a0DU000001CarpD', 'a0DU000001DBlcA', 'a0DU000001DXMB9', 'a0DU000001Dwz5D', 'a0DU000001B9kmk', 'a0DU000001DBwbY', 'a0DU000001E57Ij', 'a0DU000001DX2W6', 'a0DU000001DEHLk', 'a0DU000001EODc8', 'a0DU000001AKkL7', 'a0DU000001AL32k', 'a0DU000001DBj5o', 'a0DU000001EORjM', 'a0DU000000kU7Xl', 'a0DU000001E4cCJ', 'a0DU000001DYVXW', 'a0DU000001DFqJL', 'a0DU000001DBiCW', 'a0DU000001Dxjnn', 'a0DU000001DpfN5', 'a0DU000000kRpIm', 'a0DU000001CHnXH', 'a0DU000001EP7aH', 'a0DU000000KrtC9', 'a0DU0000019HJME', 'a0DU000001DBsNO', 'a0DU000001DFOmJ', 'a0DU000001DFNyi', 'a0DU000000kTJq0', 'a0DU000001Dxuwe', 'a0DU000001ETrST', 'a0DU000001DYMbI', 'a0DU000001CIsmS', 'a0DU000001DxiFc', 'a0DU000001DxiG8', 'a0DU000001DwSae', 'a0DU000001DCau0', 'a0DU000001DFHF9', 'a0DU0000019pCfJ', 'a0DU000001DyrVo', 'a0DU000001CIP0e', 'a0DU000001E550w', 'a0DU000001EORw7', 'a0DU000001Dxxx9', 'a0DU000001EUE0x', 'a0DU000001E4i36', 'a0DU000001E5J1O', 'a0DU000001DXqtf', 'a0DU000001E56Gz', 'a0DU000001DaIDe', 'a0DU000001DwcVE', 'a0DU000001E5BOS', 'a0DU000001E4bt0', 'a0DU000001BwYzx', 'a0DU000001DBhpm', 'a0DU000001EUDkX', 'a0DU000001DBw7G', 'a0DU000001DBsdz', 'a0DU000001DFGyD', 'a0DU000001DEG3H', 'a0DU0000013sEPP', 'a0DU000001DBtXl', 'a0DU000001E50jR', 'a0DU000001DnyUH', 'a0DU000001DpERM', 'a0DU000001Dx6bi', 'a0DU000001DEorm', 'a0DU000001Dpp0W', 'a0DU000001DxOxw', 'a0DU000001CGMat', 'a0DU000001CG95g', 'a0DU000001BxlNO', 'a0DU000001DFGtr', 'a0DU000001DyrXp', 'a0DU000001DCwL3', 'a0DU000001DBtoY', 'a0DU000001E522W', 'a0DU000001Cc1Az', 'a0DU000001DqlLh', 'a0DU000001DBsTX', 'a0DU000001DBiOC', 'a0DU000001Doa2x', 'a0DU000001B9l7o', 'a0DU00000187gyF', 'a0DU000001DqcrW', 'a0DU0000018V5iZ', 'a0DU0000013tkOJ', 'a0DU000001DX2kK', 'a0DU000001DxS2G', 'a0DU000001DCFj8', 'a0DU000001Dx6g7', 'a0DU0000019rfm7', 'a0DU000001DDWEO', 'a0DU000001DFqKT', 'a0DU000001DF9kg', 'a0DU000001DF9qy', 'a0DU000001EUDQg', 'a0DU0000019HIuO', 'a0DU000001EP818', 'a0DU000001DBwDn', 'a0DU000001DBuoI', 'a0DU0000013u9lx', 'a0DU000000KsCg1', 'a0DU000001AHUBg', 'a0DU000001BuWdJ', 'a0DU000001CaiAL', 'a0DU0000019IJrk', 'a0DU000001Dxuv7', 'a0DU00000187bZu', 'a0DU000001Cy90u', 'a0DU000001DXX1t', 'a0DU000001CFFBW', 'a0DU000001DpMru', 'a0DU000001Dwfeb', 'a0DU000001E51wd', 'a0DU000001DaBDJ', 'a0DU000001DaB5o', 'a0DU000001DaBLk', 'a0DU000001DXhs3', 'a0DU000001DXgiX', 'a0DU000001CGS5A', 'a0DU000001Dx5zY', 'a0DU000001EP4xN', 'a0DU000001DwVoI', 'a0DU000001DBtz9', 'a0DU000001DBjHz', 'a0DU000001E5LEb', 'a0DU000001Dq0No', 'a0DU000001DxTFP', 'a0DU000001DFH6C', 'a0DU000001E5Avu', 'a0DU000000S47jy', 'a0DU000001DZkXQ', 'a0DU000001DDO6l', 'a0DU000001Dy09A', 'a0DU000001CyBnY', 'a0DU000001EU608', 'a0DU000001DF9Rs', 'a0DU000001Do84L', 'a0DU000001E4xxj', 'a0DU000001DZlE7', 'a0DU000000kSekF', 'a0DU000001E56X2', 'a0DU000001AKT06', 'a0DU000001DBwcg', 'a0DU000001DBitd', 'a0DU000001EODJ9', 'a0DU000001DBtQV', 'a0DU000001DEG5A', 'a0DU000001AIKJF', 'a0DU000001AKXNM', 'a0DU000001DYPYZ', 'a0DU000001DYPr1', 'a0DU000001DxP4g', 'a0DU000001DxP5U', 'a0DU000001DEGBM', 'a0DU000001DxedE', 'a0DU000001Dxec2', 'a0DU000001DxebO', 'a0DU000001DxL9e', 'a0DU000001EOSQu', 'a0DU000001AKgU9', 'a0DU000001CHx0O', 'a0DU000001DFGxA', 'a0DU000001DFGsU', 'a0DU000001DyVrT', 'a0DU000001E583J', 'a0DU000001DosEE', 'a0DU000001DFQqW', 'a0DU000001EVL0h', 'a0DU000001DCEkB', 'a0DU0000013u1GF', 'a0DU000001Dx5xc', 'a0DU000001DyQEa', 'a0DU000001ETrYE', 'a0DU000001DyB4A', 'a0DU000001E4fAb', 'a0DU000001DxjTe', 'a0DU000001AKt8R', 'a0DU000001Cdnng', 'a0DU000001Doru6', 'a0DU000001DX2IJ', 'a0DU000001DyrPe', 'a0DU000001DoCVt', 'a0DU000001DFH7P', 'a0DU0000019rDCg', 'a0DU000001DBuXD' }; 
        global Database.QueryLocator start(Database.BatchableContext BC) {
            return Database.getQueryLocator([SELECT Id, Status__c,state__c 
                                             FROM Admission__c 
                                             WHERE Id IN: admIds 
                                            ]);
        }
    
    global void execute(Database.BatchableContext BC, List<Admission__c> scope) {
        //System.debug('****in execute***' +scope);
        List<Admission__c> admList = new List<Admission__c>();
        for(Admission__c adm : scope){ 
            adm.Status__c = 'Discharged';
            if(adm.state__c == 'NC'){
                adm.Discharged_Date__c = date.newInstance(2015, 12, 01);
            }
            else if(adm.state__c == 'FL'){
                adm.Discharged_Date__c = date.newInstance(2016, 02, 01);
                
            } 
            adm.Admitted_From__c = 'Home of Biological Parents';
            adm.Discharged_To__c = 'Home of Biological Parents';  
            admList.add(adm);
        }
        
         if(admList.size()>0){
            //Database.update(saList, true); //In this way we will get allornone, if we give false it allows partial sucess
            List<Database.SaveResult> updateResults;
            updateResults = Database.update(admList, false);
            for(Integer i=0;i<updateResults.size();i++){
                if (updateResults.get(i).isSuccess()){
                    system.debug('****All Admissions are sucess***');
                    updateResults.get(i).getId();
                }
                else if (!updateResults.get(i).isSuccess()){
                    
                    // DML operation failed
                    Database.Error error = updateResults.get(i).getErrors().get(0);
                    String failedDML = error.getMessage();
                    admList.get(i);//failed record from the list
                    System.debug('Failed Admission IDs: ' + admList.get(i).Id);  
                    
                    Error_log__c errorlog = new Error_log__c();
                    errorlog.Name = 'Admissions Discharge log on '+System.Today().format(); 
                    errorlog.Stack_Trace__c  = failedDML + '**** Admission ID: ' + admList.get(i).Id;
                    errorlog.Class_and_Method__c = 'AdmissionDischargeBatch - execute method';
                    insert errorlog;
                                  
                }
            }
        }       
        
    }
    
    global void finish(Database.BatchableContext BC) {
        List<String> toAddresses = new List<String>{'adam.vernatter@thementornetwork.com', 'dylan.melnik@thementornetwork.com'};		
        Messaging.singleEmailMessage mail = new Messaging.singleEmailMessage();
		mail.setToAddresses(toAddresses);
		mail.setSenderDisplayName('AdmissionDischargeBatch');
		mail.setSubject('AdmissionDischargeBatch batch execution is completed.');
		mail.setUseSignature(false);
		string body = 'Batch processing is completed. In production, delete me after you see this message.';
		mail.setplainTextBody(body);
		mail.setSaveAsActivity(false);
		
		Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail}); 
    }
    
}