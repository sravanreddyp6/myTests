public with sharing class SearchLogicOnPBSR {
    private static string RECORD_LIMIT = '50';
    
    public static List<ReferralSearchResults> search(String referralNumber,String lastname,String firstname,Date dob, Double age,String gender){
        system.debug('lastname:' + lastname + ';firstname:' +firstname+';dob:'+dob+';age:'+age+';gender:'+gender);
        List<ReferralSearchResults> results = new List<ReferralSearchResults>();
        if((lastname== null || lastname=='') && (firstname==null || firstname=='') && 
           (referralNumber==null || referralNumber=='')){
            throw new CustomException('Both last and first name cannot be null');
        }
        String searchString = '';
        List<Person_Being_Referred__c> pbrs = new List<Person_Being_Referred__c>();
        if ((lastname!= null && lastname!='') || (firstname!=null && firstname!='')) {
            searchString= SearchLogicOnPBSR.buildCriteria(lastname,firstname,dob, age,gender,false, true);           
            pbrs = Database.query(searchString);
        }
        
        if(referralNumber!=null && referralNumber!=''){
            Person_Being_Referred__c tmpPbr=[Select name,first_name__c,last_name__c,gender__c,date_of_birth__c,city__c,state__c,zip_code__c,street_1__c,street_2__c,age__c  
                    From person_being_referred__c 
                        Where id in 
                            (select person_being_referred__c from referral__c where name=:referralNumber)
                    limit 1];
            if(tmpPbr!=null){
                pbrs.add(tmpPbr);
            }
        }
        
        for(Person_Being_Referred__c pbr : pbrs)
        {
            Integer matchedItems = 0;
            if (lastname!=null && lastname!='' && pbr.Last_Name__c == lastName) matchedItems +=1;
            if (firstname!=null && firstname!='' && pbr.First_Name__c == firstName) matchedItems +=1;
            if (dob!=null && pbr.Date_of_Birth__c == dob) matchedItems +=1;
            if (age!=null && age!=0 && pbr.Age__c == age) matchedItems +=1;
            if (gender!=null && gender!='' && pbr.Gender__c == gender) matchedItems +=1;
            results.add(new ReferralSearchResults(pbr, matchedItems));  
        }
        
        if ((lastname!= null && lastname!='') || (firstname!=null && firstname!='')) {
            searchString= SearchLogicOnPBSR.buildCriteria(lastname,firstname,dob, age,gender,true, false);
            
            List<Contact> pbsList = Database.query(searchString);
            for(Contact pbs : pbsList)
            {
                Integer matchedItems = 0;
                if (lastname!=null && lastname!='' && pbs.LastName == lastName) matchedItems +=1;
                if (firstname!=null && firstname!='' && pbs.FirstName == firstName) matchedItems +=1;
                if (dob!=null && pbs.Birthdate == dob) matchedItems +=1;
                if (age!=null && age!=0 && pbs.Age__c == age) matchedItems +=1;
                if (gender!=null && gender!='' && pbs.Gender__c == gender) matchedItems +=1;
                            
                results.add(new ReferralSearchResults(pbs, matchedItems));  
            }
        }
        
        results.sort();
        return results;
        
    }
    public static String buildCriteria(String lastname, String firstname, Date dob, Double age,String gender,Boolean isContact, Boolean isPBR){
        
        String sobjecttype='';
        
        String namefield='';
        String lastnamefield='';
        String firstnamefield='';
        String genderfield='';
        String dobfield='';
        String cityfield='';
        String statefield='';
        String zipfield='';
        String street1field='';
        String street2field='';
        
        
        String ssnfield='';
        String agefield='';
        if(isContact){
            namefield='name';
            lastnamefield='lastname';
            firstnamefield='firstname';
            genderfield='gender__c';
            dobfield='birthdate';
            cityfield='mailingcity';
            statefield='mailingstatecode';
            zipfield='mailingpostalcode';
            street1field='mailingstreet';
            street2field='otherstreet';
            agefield='age__c';
            sobjecttype='contact';
        }
        if(isPBR){
            namefield='name';
            lastnamefield='last_name__c';
            firstnamefield='first_name__c';
            genderfield='gender__c';
            dobfield='date_of_birth__c';
            cityfield='city__c';
            statefield='state__c';
            zipfield='zip_code__c';
            street1field='street_1__c';
            street2field='street_2__c';
            agefield='age__c';
            ssnfield='ssn__c';
            sobjecttype='person_being_referred__c';
        }
        String criteria='Select '+namefield+','+firstnamefield+','+lastnamefield+','+genderfield+','+dobfield+','+cityfield+','+statefield+','+zipfield+','+street1field+','+street2field+','+agefield+' From '+ sobjecttype+' where (';
        string lNameSearch = '';
        string fNameSearch = '';
        if(lastname!=null && lastname!=''){
            if(lastname.contains('*')){
                lNameSearch+=' ('+lastnamefield +' like \''+lastname.replace('*','%')+'\')';
            }else{
                //if(dob!=null || (age!=null && age!=0)){
                    lNameSearch+=' ('+lastnamefield +' like \''+lastname+'%\''+ ' or last_name_soundex_key__c =\''+SoundEx.ToSoundEx(lastname)+'\') ';
                //}
            }
            criteria += lNameSearch;
        }
        if(firstname!=null && firstname!=''){
            if(lastname!=null && lastname!=''){
                criteria+= ' and ';
            }
            if(firstname.contains('*')){
                fNameSearch+=' ('+firstnamefield+' like \''+firstname.replace('*','%')+'\')';
            }else{
                //if(dob!=null || (age!=null && age!=0)){
                    fNameSearch+=' ('+firstnamefield+' like \''+firstname+'%\''+ ' or first_name_soundex_key__c =\''+SoundEx.ToSoundEx(firstname)+'\')';
                //}
            }
            criteria += fNameSearch;
        }
        criteria += ')';
        
        if(dob!=null || (age!= null && age!=0) || gender!=null && gender!=''){
            String extraCriteria = '';
            if(dob!=null){
                extraCriteria += ' and ';
                extraCriteria+=' ('+dobfield+' = :dob ) ';
            }
            if(age!= null && age!=0){
                extraCriteria += ' and ';
                extraCriteria+=' ('+agefield+' = '+age+ ') ';
            }
            if(gender!=null && gender!=''){
                extraCriteria += ' and ';
                extraCriteria+=' ('+genderfield+' = \''+gender+ '\') ';
            }
            
            if (firstname!=null && firstname!='' && lastname!=null && lastname!='' ) {
                //if both first name and last name are filled in then search on each individually
                criteria += 'or (' + fNameSearch + extraCriteria + ') or (' + lNameSearch + extraCriteria +')';
            }
            else
            {
                //if only first name or only last name, then don't search on each individually
                criteria += extraCriteria;
            }
        }
        /*
        if(ssn!=null && ssn!=''){
            if(isAccount){
                throw new CustomException('There is no ssn field on Person Being Served Object. Set isAccount argument to false or ssn argument to null');
            }
            criteria += ' and ';
            criteria+=' ('+ssnfield+' = \''+ssn+ '\') ';
        }*/
        criteria+= ' limit ' + RECORD_LIMIT;
        return criteria;
    }
    class CustomException extends Exception{
    
    }
}