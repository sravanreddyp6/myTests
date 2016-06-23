@isTest
public with sharing class TestUtils {
	public static Service_Location__c createServiceLocation() {
		Service_location__c serviceLocation = new Service_location__c(
			Name = '123',
			UniqueID__c = String.valueOf(Math.abs(Math.random())),
			FacilityID__c = 123,
			Alias__c = '123',
			ProgramID__c = '123',
			Program__c = '123',
			Service_Value__c = 'CA-MNTR-SL-Rancho-IDD'
		);
		insert serviceLocation;
		return serviceLocation;
	}

	/**
	 * Create TMN User record for the current user with some defaults
	 */
	public static TMN_User__c createTmnUser() {
		return createTmnUser(UserInfo.getUserId(), 'Redwood');
	}

	/**
	 * Create TMN User record for a specified user with custom details
	 */
	public static TMN_User__c createTmnUser(Id userId, String operatingGroup) {
		Tmn_User__c tmnUser = new Tmn_User__c(
			Operating_Group__c = operatingGroup,
			Business_unit__c = 'Test',
			Salesforce_User_Account__c = userId
		);
		insert tmnUser;
		return tmnUser;
	}

	public class EvalBuilder {
		private String category;
		private String subCategory;
		private String htmlId;
		private String fieldName;
		private String fieldType;
		private String fieldSubType;
		private String involvedPartyType;
		private String visibilityRules;

		private Integer categorySequence;
		private Integer subCategorySequence;
		private Integer fieldSequence;

		private Boolean required;

		private Id evalTypeId;

		private Eval_Type__c[] evalTypes;

		public EvalBuilder() {
			evalTypes = [
				SELECT Id, Name
				  FROM Eval_Type__c
			];
			// Provide some sensible defaults here
			fieldSequence = 1;
			categorySequence = 1;
			subCategorySequence = 1;

			fieldType = 'String';
			fieldSubType = '';
			involvedPartyType = '';

			required = false;
		}

		public EvalBuilder setHtmlId(String htmlId) {
			this.htmlId = htmlId;
			if (this.fieldName == null) {
				this.fieldName = this.htmlId;
			}
			return this;
		}

		public EvalBuilder setRequired(Boolean required) {
			this.required = required;
			return this;
		}

		public EvalBuilder setVisibilityRules(String visibilityRules) {
			this.visibilityRules = visibilityRules;
			return this;
		}

		public EvalBuilder setCategory(String category) {
			this.category = category;
			this.categorySequence += 1;
			return this;
		}

		public EvalBuilder setSubCategory(String subCategory) {
			this.subCategory = subCategory;
			this.subCategorySequence += 1;
			return this;
		}

		public EvalBuilder setEvalTypeId(Id evalTypeId) {
			this.evalTypeId = evalTypeId;
			this.categorySequence = 0;
			this.subCategorySequence = 0;
			return this;
		}

		public EvalBuilder setEvalType(String evalType) {
			return this.setEvalTypeId(findEvalType(evalType).Id);
		}

		private Eval_Type__c findEvalType(String evalType) {
			for (Eval_Type__c type: evalTypes) {
				if (type.Name == evalType) {
					return type;
				}
			}
			throw new Utility.CustomException('Eval Type ' + evalType + 'could not be found');
		}

		public EvalBuilder setFieldName(String fieldName) {
			this.fieldName = fieldName;
			return this;
		}

		public EvalBuilder setFieldType(String fieldType) {
			this.fieldType = fieldType;
			return this;
		}

		public EvalBuilder setFieldSubType(String fieldSubType) {
			this.fieldSubType = fieldSubType;
			return this;
		}

		public EvalBuilder setInvolvedPartyType(String involvedPartyType) {
			this.involvedPartyType = involvedPartyType;
			return this;
		}

		public Eval__c getInstance() {
			return new Eval__c(
				Category__c = category,
				Sub_Category__c = subCategory,
				htmlId__c = htmlId,
				Field_Name__c = fieldName,
				Field_Type__c = fieldType,
				Field_Sub_Type__c = fieldSubType,
				Eval_Type__c = evalTypeId,
				Involved_Party_Type__c = involvedPartyType,
				Category_Sequence__c = categorySequence,
				Sub_Category_Sequence__c = subCategorySequence,
				Visibility_Rules__c = visibilityRules,
				Required__c = required
			);
		}

		// IsValid and ErrorMsg are 2 Eval__c that appear in everything, so we have this method to
		// create them quickly
		public Eval__c[] getCommonInstances() {
			return new Eval__c[] {
				this
					.setHtmlId('IsValid')
					.setFieldName('IsValid')
					.setFieldType('Hidden')
					.setFieldSubType('Boolean')
					.getInstance(),
				this
					.setHtmlId('ErrorMsg')
					.setFieldName('ErrorMsg')
					.setFieldType('Hidden')
					.setFieldSubType('String')
					.getInstance()
			};
		}
	}

	public class EvalDropdownBuilder {
		private Eval__c[] evals;
		private String evalType;
		private String category;
		private String subCategory;
		private String htmlId;
		private String optionName;
		private String optionValue;
		private Double sequence;

		public EvalDropdownBuilder() {
			evals = [
				SELECT Id, Eval_Type__r.Name, Category__c, Sub_Category__c, HtmlId__c,
				       Length__c, Field_Type__c, Field_Sub_Type__c
				  FROM Eval__c
			];
			this.sequence = 1;
		}

		public EvalDropdownBuilder setCategory(String category) {
			this.category = category;
			return this;
		}

		public EvalDropdownBuilder setSubCategory(String subCategory) {
			this.subCategory = subCategory;
			return this;
		}

		public EvalDropdownBuilder setEvalType(String evalType) {
			this.evalType = evalType;
			return this;
		}

		public EvalDropdownBuilder setHtmlId(String htmlId) {
			this.htmlId = htmlId;
			return this;
		}

		public EvalDropdownBuilder setSequence(Double sequence) {
			this.sequence = sequence;
			return this;
		}

		public EvalDropdownBuilder incrementSequence() {
			this.sequence += 1;
			return this;
		}

		public EvalDropdownBuilder setOptionName(String optionName) {
			this.optionName = optionName;
			return this;
		}

		public EvalDropdownBuilder setOptionValue(String optionValue) {
			this.optionValue = optionValue;
			return this;
		}

		public Eval_Drop_Down__c getInstance() {
			Eval__c eval = findEval(evalType, category, subCategory, htmlId);
			return new Eval_Drop_Down__c(
				WhatId__c = eval.Id,
				Option_Name__c = optionName,
				Option_Value__c = optionValue,
				What_Id_Object__c = 'Eval__c',
				Sequence__c = sequence
			);
		}

		private Eval__c findEval(String evalType, String category, String subCategory, String htmlId) {
			for (Eval__c eval: this.evals) {
				if (eval.Eval_Type__r.Name == evalType &&
						eval.Category__c == category &&
						eval.Sub_Category__c == subCategory &&
						eval.HtmlId__c == htmlId) {
					return eval;
				}
			}
			throw new Utility.CustomException('Could not find eval');
		}
	}

	public class EvalValueBuilder {
		private Eval__c[] evals;
		private String evalType;
		private String category;
		private String subCategory;
		private String htmlId;
		private String whatIdObject;
		private Id whatId;
		private String evalSectionId;
		private String stringValue;
		private Boolean booleanValue;

		public EvalValueBuilder() {
			evals = [
				SELECT Id, Eval_Type__r.Name, Category__c, Sub_Category__c, HtmlId__c,
				       Length__c, Field_Type__c, Field_Sub_Type__c
				  FROM Eval__c
			];
			this.booleanValue = false;
			this.evalSectionId = UserInfo.getUserId() + '-' + String.valueOf(DateTime.now().getTime());
		}

		public EvalValueBuilder setCategory(String category) {
			this.category = category;
			this.evalSectionId = UserInfo.getUserId() + '-' + String.valueOf(DateTime.now().getTime());
			return this;
		}

		public EvalValueBuilder setSubCategory(String subCategory) {
			this.subCategory = subCategory;
			this.evalSectionId = UserInfo.getUserId() + '-' + String.valueOf(DateTime.now().getTime());
			return this;
		}

		public EvalValueBuilder setEvalType(String evalType) {
			this.evalType = evalType;
			this.evalSectionId = UserInfo.getUserId() + '-' + String.valueOf(DateTime.now().getTime());
			return this;
		}

		public EvalValueBuilder setWhatIdObject(String whatIdObject) {
			this.whatIdObject = whatIdObject;
			return this;
		}

		public EvalValueBuilder setWhatId(Id whatId) {
			this.whatId = whatId;
			return this;
		}

		public EvalValueBuilder setEvalSectionId(String evalSectionId) {
			this.evalSectionId = evalSectionId;
			return this;
		}

		public EvalValueBuilder setHtmlId(String htmlId) {
			this.htmlId = htmlId;
			return this;
		}

		public EvalValueBuilder setValue(String value) {
			this.stringValue = value;
			return this;
		}

		public EvalValueBuilder setValue(Boolean booleanValue) {
			this.booleanValue = booleanValue;
			return this;
		}

		public Eval_Value__c getInstance() {
			Eval__c eval = findEval(evalType, category, subCategory, htmlId);
			Eval_Value__c value = new Eval_Value__c(
				Eval__r = eval,
				Eval__c = eval.Id,
				Eval_Section_Id__c = evalSectionId,
				What_Id__c = whatId,
				What_Id_Object__c = whatIdObject
			);
			if (eval.Field_Type__c == 'String' && eval.Length__c < 250) {
				value.Text_Under_250__c = stringValue;
			} else if (eval.Field_Type__c == 'String' && eval.Length__c >= 250) {
				value.Text_Over_250__c = stringValue;
			} else if (eval.Field_Type__c == 'Boolean') {
				value.Boolean__c = booleanValue;
			} else if (eval.Field_Type__c == 'Hidden' && eval.Field_Sub_Type__c == 'Boolean') {
				value.Boolean__c = booleanValue;
			} else if (eval.Field_Type__c == 'Multiselect' && eval.Field_Sub_Type__c == 'Checkbox') {
				value.Text_Under_250__c = stringValue;
			} else if (eval.Field_Type__c == 'Dropdown') {
				value.Text_Under_250__c = stringValue;
			}
			return value;
		}

		public String getInstanceJson() {
			Eval_Value__c evalValue = this.getInstance();
			String value;
			if (evalValue.Eval__r.Field_Type__c == 'String' && evalValue.Eval__r.Length__c < 250) {
				value = evalValue.Text_Under_250__c;
			} else if (evalValue.Eval__r.Field_Type__c == 'String' && evalValue.Eval__r.Length__c >= 250) {
				value = evalValue.Text_Over_250__c;
			} else if (evalValue.Eval__r.Field_Type__c == 'Boolean') {
				value = String.valueOf(evalValue.Boolean__c);
			} else if (evalValue.Eval__r.Field_Type__c == 'Hidden' && evalValue.Eval__r.Field_Sub_Type__c == 'Boolean') {
				value = String.valueOf(evalValue.Boolean__c);
			} else if (evalValue.Eval__r.Field_Type__c == 'Multiselect' && evalValue.Eval__r.Field_Sub_Type__c == 'Checkbox') {
				value = evalValue.Text_Under_250__c;
			} else if (evalValue.Eval__r.Field_Type__c == 'Dropdown') {
				value = evalValue.Text_Under_250__c;
			}

			return '{"name": "' + evalValue.Eval__c + '_esi", "value": "' + evalValue.Eval_Section_Id__c + '"}, {"name": "' + evalValue.Eval__c + '", "value": "' + value + '"}';
		}

		private Eval__c findEval(String evalType, String category, String subCategory, String htmlId) {
			for (Eval__c eval: this.evals) {
				if (eval.Eval_Type__r.Name == evalType &&
						eval.Category__c == category &&
						eval.Sub_Category__c == subCategory &&
						eval.HtmlId__c == htmlId) {
					return eval;
				}
			}
			throw new Utility.CustomException('Could not find eval');
		}
	}

	public class AliasBuilder {
		private String name;
		private String state;

		public AliasBuilder() {
			this.name = TMN_Generic_Core_TestData.generateRandomString(6);
			this.state = 'MA';
		}

		public AliasBuilder setName(String name) {
			this.name = name;
			return this;
		}

		public AliasBuilder setState(String state) {
			this.state = state;
			return this;
		}

		public Alias__c getInstance() {
			return new Alias__c(
				Name = name,
				Alias_Unique__c = name,
				alias_business_unit__c = 'BU 370 REM South Central, Inc',
				alias_level__c = '',
				alias_parent__c = 'MN-AD44',
				alias_operating_group__c = 'Redwood',
				alias_state__c = state,
				alias_description__c = 'MN-REMSCS-SL-Chrysalis-MH',
				alias_region__c = 'Redwood North',
				alias_responsibility_center_code__c = '79647',
				alias_service_line__c = 'Waiver Group Homes'
			);
		}
	}

	public class ServiceLocationBuilder {
		private Alias__c alias;
		private Id aliasId;
		private String state;

		public ServiceLocationBuilder() {
			this.state = 'MA';
		}

		public ServiceLocationBuilder setAliasId(Id aliasId) {
			this.aliasId = aliasId;
			alias = [SELECT Id, Name, Alias_State__c FROM Alias__c WHERE Id=:aliasId];
			this.state = alias.Alias_State__c;
			return this;
		}

		public ServiceLocationBuilder setState(String state) {
			this.state = state;
			return this;
		}

		public Service_Location__c getInstance() {
			return new Service_Location__c(
				Alias_Lookup__c = aliasId,
				Alias__c = alias.Name,
				City__c = 'Redwood Falls',
				FacilityID__c = 13.0,
				Name = alias.Name,
				ProgramID__c = '370647000',
				Program__c = 'MN-REMSCS-SL-Chrysalis-MH',
				Service_Value__c = 'IDD - Residential Group Home',
				Setting__c = 'Inpatient/Residential',
				Source_System__c = 'AVATAR',
				State__c = state,
				Status__c = 'Active',
				Street__c = '515 E Elm Street',
				TIN__c = '41-1509578',
				ZIP__c = '56283-1119',
				TMN_Scope__c = 'Residential',
				UniqueID__c = TMN_Generic_Core_TestData.generateRandomString(6)
			);
		}
	}

	public class UserBuilder {
		private Profile profile;
		private String firstName;
		private String lastName;
		private String userAlias;
		private String email;
		private String operatingGroup;  // to overcome trigger not running during tests

		public UserBuilder() {
			profile = [ select id, name from Profile where name ='ESD General' ];
			operatingGroup = 'Redwood';
			email = 'testUser@tmn.com';
		}

		public UserBuilder setProfile(Profile profile) {
			this.profile = profile;
			return this;
		}

		public UserBuilder setUserAlias(String userAlias) {
			this.userAlias = userAlias;
			return this;
		}

		public UserBuilder setFirstName(String firstName) {
			this.firstName = firstName;
			return this;
		}

		public UserBuilder setLastName(String lastName) {
			this.lastName = lastName;
			return this;
		}

		public UserBuilder setOperatingGroup(String operatingGroup) {
			this.operatingGroup = operatingGroup;
			return this;
		}

		public UserBuilder setEmail(String email) {
			this.email = email;
			return this;
		}

		public User getInstance() {
			return new User(
				alias = userAlias,
				email = email,
				emailencodingkey = 'UTF-8',
				lastname = lastName,
				firstname = firstName,
				languagelocalekey = 'en_US',
				localesidkey = 'en_US',
				profileId = profile.Id,
				timezonesidkey = 'America/New_York',
				username = email + '.' + System.currentTimeMillis(),
				operating_group__c = operatingGroup
			);
		}
	}

	public class TmnUserBuilder {
		private Id userId;
		private User user;
		private String firstName;
		private String lastName;
		private Alias__c alias;
		private String operatingGroup;
		private String email;
		private String managerEmail;
		private Double approvalLevel;

		public TmnUserBuilder() {
			this.userId = UserInfo.getUserId();
			this.user = [ SELECT Id, FirstName, LastName, Email FROM User WHERE Id=:userId ];
			this.email = this.user.Email;
			this.operatingGroup = 'Redwood';
			this.approvalLevel = 0;
		}

		public TmnUserBuilder setUserId(Id userId) {
			this.userId = userId;
			this.user = [ SELECT Id, FirstName, LastName, Email FROM User WHERE Id=:userId ];
			this.email = this.user.Email;
			this.firstName = this.user.FirstName;
			this.lastName = this.user.LastName;
			return this;
		}

		public TmnUserBuilder setOperatingGroup(String operatingGroup) {
			this.operatingGroup = operatingGroup;
			return this;
		}

		public TmnUserBuilder setEmail(String email) {
			this.email = email;
			return this;
		}

		public TmnUserBuilder setManagerEmail(String managerEmail) {
			this.managerEmail = managerEmail;
			return this;
		}

		public TmnUserBuilder setApprovalLevel(Double approvalLevel) {
			this.approvalLevel = approvalLevel;
			return this;
		}

		public TmnUserBuilder setAlias(Alias__c alias) {
			this.alias = alias;
			return this;
		}

		public TmnUserBuilder setFirstName(String firstName) {
			this.firstName = firstName;
			return this;
		}

		public TmnUserBuilder setLastName(String lastName) {
			this.lastName = lastName;
			return this;
		}

		public Tmn_User__c getInstance() {
			return new Tmn_User__c(
				Salesforce_User_Account__c = user.Id,
				Operating_Group__c = operatingGroup,
				Email__c = email,
				Manager_Email__c = managerEmail,
				Accountable_Manager_Mentor_Email__c = managerEmail,
				Approval_Level__c = approvalLevel,
				Alias__c = alias.Name,
				Alias_Lookup__c = alias.Id,
				First_Name__c = firstName,
				Last_Name__c = lastName,
				Job_Status__c = 'Active',
				Name = firstName + ' ' + lastName
			);
		}
	}
}
