public class ageCalculationController {
	public string nYears{get;set;}
	public string nMonths{get;set;} 
	public string nDays{get;set;}
	
	public string getAge(){
		return Utility.getAge(nYears,nMonths,nDays);
	}
}