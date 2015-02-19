public with sharing class Assessment_CANS_Cluster_Defs {
	public Assessment_CANS_Cluster_Defs() {		
	}

	public static final list<integer> WellBeing = new list<integer>{
		
		55, //Anxity
		15,	//Adjustment to Trauma
		24,	//Interpersonal
		28,	//Optimism
		33,	//Resilience
		44, //School Behavior
		//last =  no comma
		46 //School Attendance

	};

	public static final list<integer> Behavior_AND_Risk = new list<integer>{
		
		69, //Runaway
		54,	//Depression
		55,	//Anxiety
		58,	//Substance Abuse
		64,	//Suicide Risk
		66, //Other Self-Harm
		63, //Anger Control
		67, //Danger to Others
		//last =  no comma
		68 //Sexual Aggression

	};	
	
	public static final list<integer> Education = new list<integer>{
		44, //School Behavior (44)
		45, //School Achievement (45)
		46, //School Attendance (46)
		33, //Problem Solving-Resilience (33)
		71, //Problem Solving-Judgment (71)
		52, //Decision Making-Attention/Concentration (52)
		53, //Decision Making-Impulsivity (53)
		95 //Educational Attainment (95)       
		
	};
	
}