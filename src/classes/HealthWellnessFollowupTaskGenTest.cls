@isTest
private class HealthWellnessFollowupTaskGenTest {
    
    static testMethod void myUnitTest() {
    	
    	createData();
			   
    	List<Health_Wellness_Checklist__c> query = [SELECT Id, Admission__r.Person_Being_Served__r.Name, Admission__r.Person_Being_Served__c,
			       Next_Expected_Annual_Physical_Date__c, OwnerId, Admission__c
			  FROM Health_Wellness_Checklist__c
			 WHERE Admission__r.Status__c = 'Active'
			   AND Status__c = 'Active Final'
			   AND Next_Expected_Annual_Physical_Date__c = NEXT_N_DAYS:60
			   AND Next_Expected_Annual_Physical_Date__c > TODAY
			   ];
    	
    	Test.startTest();
    	HealthWellnessFollowUpTaskGenerator hwTask = new HealthWellnessFollowUpTaskGenerator();
    	Database.executeBatch(hwTask, 200);
		Test.stopTest();
        List<Task> tasks = [ select id, whoid, whatid, activitydate, subject, ownerid from Task where subject = 'Schedule Annual Physical'];
        system.assertEquals( tasks.size(), 1);
        system.assert( tasks[0].ActivityDate == Date.Today().addDays(6) || tasks[0].ActivityDate == Date.Today().addDays(6) );
        system.assertEquals( tasks[0].ownerid, UserInfo.getUserId() );
    }
    
    public class TestException extends Exception{
    }
    
    
    private static void createData(){

		TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();

		myData.theAccount.PersonBirthdate = Date.today().addYears(-20);
		update myData.theAccount;
		myData.theAdm.status__c = 'Active';
		update myData.theAdm;

		Health_Wellness_Checklist__c checklist = new Health_Wellness_Checklist__c();
		checklist.admission__c = myData.theAdm.Id;
		checklist.Status__c = 'Active Final';
		checklist.Date_of_Physical__c = Date.Today().addDays(-360);
		checklist.Status_of_Physical__c = 'Post Annual Physical';
		checklist.Taking_Prescription_Medications__c = 'Yes';
		checklist.Dental_Visit_Within_Last_Year__c = 'Yes';
		checklist.Other_Condition_1__c = true;
		checklist.Taking_Psychotropic_Medications__c = 'Yes';
		checklist.Other_Condition_1_Specify__c = 'Specify 1';
		checklist.How_Many_Psychotropic_Medications__c = '2';
		checklist.Psychotropic_Medications_Prescribed_By__c = 'Primary Care; Psychiatrist; Other';
		checklist.Medications_Prescribed_By_Other__c = 'Prescribed By Other';

		// Add a Related Party that can be used as a health care provider to the PBS
		Account account = [SELECT Id, PersonContactId From Account WHERE Id = :myData.theAccount.Id];
		Related_Party__c rp = new Related_Party__c(
			Name = 'Medical Party',
			Person_Being_Served__c = account.PersonContactId,
			Status__c = 'Active',
			Type__c = 'Medical'
		);
		insert rp;

		checklist.Health_Care_Provider_Name__c = rp.Name;
		checklist.PBS_Accompanied_to_Physical_By__c = 'Staff';
		checklist.Height_Cm__c = 182.88;
		checklist.Weight_Kg__c = 68.04;
		checklist.Blood_Pressure_Systolic__c = 120;
		checklist.Blood_Pressure_Diastolic__c = 80;
		checklist.Asthma__c = true;
		checklist.Arthritis__c = true;
		checklist.Chronic_Obstructive_Pulmonary_Disease__c = true;
		checklist.Diabetes__c = true;
		checklist.Heart_Disease__c = true;
		checklist.Mental_Health_Condition__c = true;
		checklist.Seizure_Disorder__c = true;
		checklist.Medication_List_Reviewed__c = 'Yes';
		checklist.Date_of_Last_Dental_Visit__c = Date.today();
		checklist.Preventive_Health_Screenings_Discussed__c = 'Yes';
		checklist.PBS_Accompanied_By_Other__c = 'Other';
		checklist.PBS_Accompanied_By_Other_Role__c = 'Other Role';
		checklist.Asthma_Management_Discussed__c = 'Yes';
		checklist.Arthritis_Management_Discussed__c = 'Yes';
		checklist.COPD_Management_Discussed__c = 'Yes';
		checklist.Diabetes_Management_Discussed__c = 'Yes';
		checklist.Heart_Disease_Management_Discussed__c = 'Yes';
		checklist.Mental_Health_Condition_Discussed__c = 'Yes';
		checklist.Seizure_Disorder_Management_Discussed__c = 'Yes';
		checklist.Other_Condition_1_Management_Discussed__c = 'Yes';
		
		// add in the immunizations
		List<Evaluation_Response__c> immunizations = new List<Evaluation_Response__c>{ new Evaluation_Response__c ( person_being_served__c = myData.ContactId, vaccine_type__c = 'Influenza', date__c = checklist.date_of_physical__c.AddDays(-7)),
																		  			   new Evaluation_Response__c ( person_being_served__c = myData.ContactId, vaccine_type__c = 'Diphtheria/Tetanus/Pertussis', date__c = checklist.date_of_physical__c.AddDays(-7))};
						
		insert immunizations;
		system.debug('BEFORE:' + checklist);
		insert checklist;
		
		checklist = [
			SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, LastActivityDate, Admission__c, Status__c,
				   Additional_comments__c, 
			       Arthritis_Management_Discussed__c, Arthritis__c, Asthma_Management_Discussed__c,
			       Asthma__c, COPD_Management_Discussed__c, Chronic_Obstructive_Pulmonary_Disease__c,
			       Date_of_Last_Dental_Visit__c, Date_of_Physical__c, Dental_Visit_Within_Last_Year__c,
			       Diabetes_Management_Discussed__c, Diabetes__c, Health_Care_Provider_Name__c,
			       Heart_Disease_Management_Discussed__c, Heart_Disease__c,
			       How_Many_Psychotropic_Medications__c, Medication_List_Reviewed__c,
			       Medications_Prescribed_By_Other__c, Mental_Health_Condition_Discussed__c,
			       Mental_Health_Condition__c, Other_Condition_1_Management_Discussed__c,
			       Other_Condition_1_Specify__c, Other_Condition_1__c,
			       Other_Condition_2_Management_Discussed__c, Other_Condition_2_Specify__c,
			       Other_Condition_2__c, Other_Condition_3_Management_Discussed__c,
			       Other_Condition_3_Specify__c, Other_Condition_3__c, PBS_Accompanied_to_Physical_By__c,
			       Preventive_Health_Screenings_Discussed__c, Previous_Checklist__c,
			       Psychotropic_Medications_Prescribed_By__c, Seizure_Disorder_Management_Discussed__c,
			       Seizure_Disorder__c, Status_of_Physical__c, Taking_Prescription_Medications__c, 
			       Taking_Psychotropic_Medications__c, Was_developmental_screening_conducted__c,
			       Blood_Pressure_Diastolic__c, Blood_Pressure_Not_Collected__c,
			       Blood_Pressure_Systolic__c, Height_Cm__c, Height_Ft__c, Height_Inch__c,
			       Height_Not_Collected__c, PBS_Accompanied_By_Mentor__c, PBS_Accompanied_By_Other_Role__c,
			       PBS_Accompanied_By_Other__c, PBS_Accompanied_By_Staff__c, PBS_Accompanied_By_Staff__r.name, Weight_Kg__c, Weight_Lb__c,
			       Weight_Not_Collected__c, Weight_Oz__c, bmi__c,Next_Expected_Annual_Physical_Date__c,
			       admission__r.person_being_served__c, admission__r.person_Being_served__r.birthdate,
			       admission__r.person_being_Served__r.firstname,
			       admission__r.person_being_served__r.middle_name__c,
			       admission__r.person_being_served__r.lastname,
			       admission__r.person_being_served__r.name,
			       admission__r.person_being_served__r.gender__c
			  FROM Health_Wellness_Checklist__c
			 WHERE id=:checklist.id LIMIT 1
			];
		system.debug( 'AFTER: ' + checklist );
		// checklist should save and now we can generate the task	
		system.debug('date of physical' + checklist.date_of_physical__c + ', next one:' + checklist.Next_Expected_Annual_Physical_Date__c);
        
     
    }
}