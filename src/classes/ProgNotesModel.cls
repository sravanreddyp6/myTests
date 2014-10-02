public with sharing class ProgNotesModel {
	public Id pNoteID {get;set;}
	public String Date_of_Service_String {get;set;}
	public String Auth_Service_Code {get; set;}
	public String Program_Code {get; set;}
	public String Staff_Employee_ID {get; set;}
	public String Billing_ID {get; set;}
	public String Service_Assignment_Episode {get; set;}
	public String Blank {get; set;}
	public String Blank2 {get; set;}
	public Decimal Total_Time {get; set;}
	public String Location_Type_AZ_Report_Map {get; set;}
	public String BlankUnits {get; set;}
	public String Blank4 {get; set;}
	public String Blank5 {get; set;}
	public String Blank6 {get; set;}
	public String Blank7 {get; set;}
	public String Blank8 {get; set;}
	public String Blank9 {get; set;}
	public String Blank10 {get; set;}
	public String Blank11 {get; set;}
	public String Start_Time_Only {get; set;}
	public String End_Time_Only {get; set;}
	public String Blank_Cost {get; set;}
	public String Primary_Care_Provider_Name {get; set;}
	public String Primary_Care_Provider_NPI_Number {get; set;}
	public String NAME {get; set;}
	public String Service_Assignment_Program {get; set;}
	public String Service_Assignment_Service_Line {get; set;}
	public String CreatedByName {get; set;}
	public String Program_Detail {get; set;}
	public String Approval_Status_Date {get; set;}
	public Boolean Purpose_Service_is_Billable {get; set;}
	public Boolean Disregard_Note {get; set;}
	public String Notes_Sequence_Identifier {get; set;}
	public Date Date_of_Service {get; set;}
	public Id Person_Being_Served {get; set;}
	
	public Boolean isProcessed {get; set;}
	 
	public static ProgNotesModel setBlanks(ProgNotesModel pnModel
									,String Blank 
									,String Blank2 
									,String Blank4 
									,String Blank5 
									,String Blank6 
									,String Blank7 
									,String Blank8 
									,String Blank9 
									,String Blank10 
									,String Blank11){
			pnModel.Blank = Blank;
			pnModel.Blank2 = Blank2;
			pnModel.Blank4 = Blank4;
			pnModel.Blank5 = Blank5;
			pnModel.Blank6 = Blank6;
			pnModel.Blank7 = Blank7;
			pnModel.Blank8 = Blank8;
			pnModel.Blank9 = Blank9;
			pnModel.Blank10 = Blank10;
			pnModel.Blank11 = Blank11;
			return pnModel;
		} 


	public ProgNotesModel(Id pNoteID
		,String Date_of_Service_String
		,String Auth_Service_Code 
		,String Program_Code 
		,String Staff_Employee_ID 
		,String Billing_ID 
		,String Service_Assignment_Episode 
		,Decimal Total_Time 
		,String Location_Type_AZ_Report_Map 
		,String BlankUnits 
		,String Start_Time_Only 
		,String End_Time_Only 
		,String Blank_Cost 
		,String Primary_Care_Provider_Name 
		,String Primary_Care_Provider_NPI_Number 
		,String NAME 
		,String Service_Assignment_Program 
		,String Service_Assignment_Service_Line 
		,String CreatedByName 
		,String Program_Detail 
		,String Approval_Status_Date 
		,Boolean Purpose_Service_is_Billable 
		,Boolean Disregard_Note 
		,String Notes_Sequence_Identifier 
		,Date Date_of_Service 
		,Id Person_Being_Served ){
	
			this.pNoteID = pNoteID;
			this.Date_of_Service_String = Date_of_Service_String;
			this.Auth_Service_Code = Auth_Service_Code;
			this.Program_Code = Program_Code;
			this.Staff_Employee_ID = Staff_Employee_ID;
			this.Billing_ID = Billing_ID;
			this.Service_Assignment_Episode = Service_Assignment_Episode;
			this.Total_Time = Total_Time;
			this.Location_Type_AZ_Report_Map = Location_Type_AZ_Report_Map;
			this.BlankUnits = BlankUnits;
			this.Start_Time_Only = Start_Time_Only;
			this.End_Time_Only = End_Time_Only; 
			this.Blank_Cost = Blank_Cost;
			this.Primary_Care_Provider_Name = Primary_Care_Provider_Name;
			this.Primary_Care_Provider_NPI_Number = Primary_Care_Provider_NPI_Number;
			this.NAME = NAME;
			this.Service_Assignment_Program = Service_Assignment_Program;
			this.Service_Assignment_Service_Line = Service_Assignment_Service_Line;
			this.CreatedByName = CreatedByName;
			this.Program_Detail = Program_Detail;
			this.Approval_Status_Date = Approval_Status_Date;
			this.Purpose_Service_is_Billable = Purpose_Service_is_Billable;
			this.Disregard_Note = Disregard_Note;
			this.Notes_Sequence_Identifier = Notes_Sequence_Identifier;
			this.Date_of_Service = Date_of_Service;
			this.Person_Being_Served = Person_Being_Served;
			
			this.isProcessed = false;
	}
	
	public ProgNotesModel placeHolderClone(String dateOfService){
		ProgNotesModel pnModel =  new ProgNotesModel(this.pNoteID, 
			dateOfService, //this.Date_of_Service_String,
			this.Auth_Service_Code,
			this.Program_Code,
			this.Staff_Employee_ID,
			this.Billing_ID,
			this.Service_Assignment_Episode,
			null, // decimal.valueOf(''), //this.Total_Time,
			'15', //this.Location_Type_AZ_Report_Map,
			this.BlankUnits,
			'', //this.Start_Time_Only,
			'', //this.End_Time_Only, 
			this.Blank_Cost,
			this.Primary_Care_Provider_Name,
			this.Primary_Care_Provider_NPI_Number,
			'Per Diem Placeholder', //this.NAME,
			this.Service_Assignment_Program,
			this.Service_Assignment_Service_Line,
			'Integration', //this.CreatedByName,
			this.Program_Detail,
			'', //this.Approval_Status_Date,
			this.Purpose_Service_is_Billable,
			this.Disregard_Note,
			'',//this.Notes_Sequence_Identifier,
			this.Date_of_Service,
			this.Person_Being_Served);

			return ProgNotesModel.setBlanks(pnModel,
			this.Blank,
			this.Blank2,
			this.Blank4,
			this.Blank5,
			this.Blank6,
			this.Blank7,
			this.Blank8,
			this.Blank9,
			this.Blank10,
			this.Blank11);
			
	}
	
}