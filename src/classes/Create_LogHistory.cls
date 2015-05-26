/*********************************************************************\
@ Created By : Sravan Reddy Pinninti
@ Description: This class is used to create records in the Log History object.
@ Created Date: 03/27/2014
@ Last Modified By :
@ Last Modified Reason: 

/**********************************************************************/

Public with sharing class Create_LogHistory{
    

Public void CreateLogHistory(string action,string objName,Date subDate,string recId, string coms){
      Log_History__c lgh = new Log_History__c();
       lgh.By_User__c = Userinfo.getUserId();
       lgh.Action_Date_Time__c = datetime.now();

       if(string.isNotBlank(action)){
        lgh.Action__c = action;
        }
       

       if(string.isNotBlank(objName)){
       lgh.Object_Name__c = objName;

       }
       
       if(subDate!=null){
       lgh.Date_of_Submission__c = subDate;
       }
       
       if(string.isNotBlank(recId)){
       lgh.Record_Id__c = recId;
       }
       
       if(string.isNotBlank(coms)){
       lgh.Comments__c = coms;
       }


       insert lgh;

  

    }

}