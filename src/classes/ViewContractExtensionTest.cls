@isTest
private class ViewContractExtensionTest {
    
    static testMethod void myUnitTest() {
        Profile prof = [select id, name from Profile where name ='System Administrator'];
        User testUser = new User(alias = 'testU',
                                 email='dsurfleet@appirio.com',
                                 emailencodingkey='UTF-8',
                                 lastname='lastName',firstname='firstName', languagelocalekey='en_US',
                                 localesidkey='en_US',
                                 profileid = prof.Id,  
                                 timezonesidkey='America/Los_Angeles',
                                 Contract_Approver__c=true,
                                 username='ReferralTestUser@tmn.com.test' + System.currentTimeMillis());
        insert testUser;
        IssuingAgency__c issAgencey = new IssuingAgency__c(Name = 'Testing', State__c = 'MA', FY_End__c = 'January');
        insert issAgencey;
        system.runAs(testUser){
            TMN_Contract__c myContract = new TMN_Contract__c(
                
                //Edit details to be checked
                Name = 'Name',
                Operating_Group__c = 'Cambridge',
                State__c = 'MA',
                LegalEntity__c = 'Family Advocacy Services, LLC',
                Population__c = 'IDD',
                Service_Line__c = 'ABI',
                MentorRegionOfficeProgramName__c = 'testing',
                Start_Date__c = system.Date.parse('9/30/2015'),
                Termination_Date__c = system.Date.parse('9/30/2016'),
                TermNote60__c = '30',
                Status__c = 'Received',
                Value__c = 10000,
                ValueEstStated__c = 'Estimated - Annual Value',
                Funding_Type__c = 'Grants',
                ContractingParty__c = issAgencey.Id,
                Rate_Structure__c = 'Monthly',
                Value_Type__c = 'No Ceiling',
                
                //Checklist to be checked
                AdditionalGrowth__c = 'yes',
                AdditionalPermits__c = 'no',
                ServiceChange__c = 'Decreased',
                AnnualFundingLimit__c = 'no',
                CompanyNameCorrect__c = 'yes',
                DatesCorrect__c = 'yes',
                RateChangeBudget__c = 'Higher',
                RateChangeLastContract__c = 'Higher',
                SubcontractingTerms__c = 'no',
                LN_ContractTermNoNotice__c = 'no',
                CL_Payback_ReviewClause__c = 'no',
                LN_ManageCareRiskSharing__c = 'no',
                LN_LiabilityInsuranceExceedLimits__c = 'no',
                LN_new_payor_or_a_new_service__c = 'no',
                CL_CoveredByLimit__c = 'no',
                
                //Critical Indicators to be checked
                AuditRequirementsYN__c = 'no',
                CostReportRequiredYN__c = 'no',
                ServiceDocumentationYN__c = 'no',
                FrequencyOfVisitsYN__c = 'no',
                OtherSpecialRequirementsYN__c = 'no',
                OutcomeRequirementsYN__c = 'no',
                PerformanceBasedContractYN__c = 'no',
                Personnel_CredentialRequirementsYN__c = 'no',
                ProviderRequiredTrainingYN__c = 'yes',
                ProviderRequiredTraining__c = 'yes',
                ProviderRequiredTrainingDetail__c = 'testing',
                ReportingRequirementsYN__c = 'no',
                SubjectToCostReimbursementYN__c = 'no',
                SpendingRequirementsYN__c = 'no',
                StaffingClientRequirementsYN__c = 'no',
                SupportServicesYN__c = 'no',
                
                //Approver
                Approver_1__c = testUser.id
            );
            insert myContract;
            
            PageReference pg = Page.ViewContract;
            Test.setCurrentPage(pg);
            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(myContract);
            ViewContractExtension controller = new ViewContractExtension(stdCtrl);
            controller.Submit();
            
        }
    }
}