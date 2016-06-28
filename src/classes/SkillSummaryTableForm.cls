public class SkillSummaryTableForm {
    
    public SkillSummaryTableForm(){
        MetObjectiveCount = 0;
        NotMetObjectiveCount = 0;
    }
	public integer MetObjectiveCount {get;set;}
	public integer NotMetObjectiveCount {get;set;}
	public integer OccurrencesCount {get;set;}
	public Date EffectiveDate {get;set;}
	public Date TargetDate {get;set;}
    public string RecommendationText {get;set;}
    public string CommentText {get;set;}
    
  public boolean HasData {get { return TotalTrials > 0 || OccurrencesCount > 0;}}
  public boolean HasSkillData {get { return TotalTrials > 0 ;}}
  public integer TotalTrials {get { return (MetObjectiveCount != null ? MetObjectiveCount : 0) + (NotMetObjectiveCount != null ? NotMetObjectiveCount: 0); }}
  public decimal PercentMet { get { return HasData ? 100 * (MetObjectiveCount != null ? MetObjectiveCount : 0)/ TotalTrials : 0; }}
    public boolean isDurationOver1Month {get{
        return EffectiveDate != null &&
            TargetDate != null &&
            EffectiveDate.addMonths(1) < TargetDate;
    }}
    public string Duration { get {
        return String.format('{0} Months', new List<string>{EffectiveDate.monthsBetween(TargetDate).format()});
    }}
}