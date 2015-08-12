@RestResource(urlMapping='/Employee/*')
global with sharing class EmpController {

  @HttpGet
  global static String getEmp() {

    /*
     * Purpose: Restfull web service that will take the Taleo number find it in TMNUsers
     * and return the "identity id" associated with a given Taleo number.
     * 
     * Example: https://cs9.salesforce.com/apex/rest/Employee?num=123456
     *
     */ 

    String taleo_num = RestContext.request.params.get('num');
    
    
    /*
     * Taleo id will be a minimum of 6 characters
     */
    if (taleo_num.length() < 6) {
        return taleo_num + ' is invalid.';
    }
    

    List <TMN_User__c> employee = [ Select identity_id__c from TMN_User__c where Pre_hire_ID__c = :taleo_num];

    if (employee.size() == 0) {
        /*
         * If the taleo id is not found in TMNUser return an error
         */
        return taleo_num + ' not found.';
    }else if (employee.size() > 1) {
        /*
         * If more than one record is associated with a taleo id that is an issue
         * and requires help from IT, so return an error
         */
        return taleo_num + ' multiple returned.';
    }else {
        return String.valueOf(employee[0].Identity_ID__c);
    }
         

     

  }//end global static String getEmp
  
}// end global with sharing class EmpController