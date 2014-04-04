@isTest
Public class Create_LogHistory_Test{

    static testMethod void myUnitTest(){ 
    
        Date dt= Date.Today();
           
            
        Create_LogHistory cl = new Create_LogHistory();
        cl.CreateLogHistory('test','test',dt,'x567record','test');
        
       
    }

}