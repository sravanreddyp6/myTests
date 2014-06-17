public with sharing class EvaluationHandler {
    private boolean m_isExecuting = false;
    public List <Evaluation_Response__c> tobedelAnnos = new List<Evaluation_Response__c>();
    public List<Evaluation__c> annoEvals = new List<Evaluation__c>();

    public EvaluationHandler(boolean isExecuting){
        m_isExecuting = isExecuting;
    }

    public void OnBeforeInsert(Evaluation__c[] newObjects){
        // EXECUTE BEFORE INSERT LOGIC
        for (Evaluation__c newObject: newObjects) {
            validateFields(newObject);
            
        }
    }

    public void OnAfterInsert(Evaluation__c[] newObjects){
        // EXECUTE AFTER INSERT LOGIC
    }

    public void OnBeforeUpdate(Evaluation__c[] oldObjects, Evaluation__c[] updatedObjects, Map<Id,Evaluation__c> newObjMap){
        // BEFORE UPDATE LOGIC
        for(Evaluation__c eUpdated : updatedObjects) {
            validateFields(eUpdated);
            if(eUpdated.Is_Being_Signed__c==true) {
                eUpdated.Is_Signed__c = true;
            }
            else {
                eUpdated.Is_Signed__c = false;
            }
            eUpdated.Is_Being_Signed__c = false;
        }
        //Logic to Delete Annotations on NeuroTab when Pain Present field's value is set to 'No' or 'None'.
       	for(Evaluation__c anno : updatedObjects){
       		if(anno.Pain_Present__c != 'Yes')
       			annoEvals.add(anno);
       			
       	}
       	if(annoEvals.size()>0){
	        for(Evaluation_Response__c ers : [SELECT ID FROM Evaluation_Response__c WHERE Evaluation__c IN:annoEvals AND RecordType.Name = 'NeuroAnnotation']){
	        		tobedelAnnos.add(ers); 			
	        }
	       		if(tobedelAnnos.size()>0)
	        	delete tobedelAnnos; 
       	}
      
    }

    public void OnAfterUpdate(Evaluation__c[] oldObjects, Evaluation__c[] updatedObjects, Map<Id,Evaluation__c> newObjMap){
        // AFTER UPDATE LOGIC
    }

    public void OnBeforeDelete(Evaluation__c[] ObjectsToDelete, Map<Id,Evaluation__c> oldObjMap){
        // BEFORE DELETE LOGIC
    }

    public void OnAfterDelete(Evaluation__c[] deletedObjects, Map<Id,Evaluation__c> oldObjMap){
        // AFTER DELETE LOGIC
    }

    public void OnUndelete(Evaluation__c[] restoredObjects){
        // AFTER UNDELETE LOGIC
    }

    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }

    private void validateFields(Evaluation__c obj) {
        // This Map has the format: field_name => (field_value => other_field[])
        // meaning that: if the field_name's value is anything other than
        // field_value, the other_field[] can only be null (or false in Boolean
        // case).
        Map<String, Map<String, String[]>> validationMap = new Map<String, Map<String, String[]>>{
            'employed__c' => new Map<String, String[]>{
                '1' => new String[] {'employment_status__c'}
            },
            'advanced_directives__c' => new Map<String, String[]>{
                '1' => new String[] {'advanced_directives_attached__c'}
            },
            'code_status__c' => new Map<String, String[]>{
                'Other' => new String[] {'code_status_other__c'}
            },
            
            'power_of_attorney__c' => new Map<String, String[]>{
                '1' => new String[] {'poa_name__c', 'poa_type__c'}
            },
            'isolation__c' => new Map<String, String[]>{
                '1' => new String[] {'DiagnosisIsolation_Type__c', 'Isolation_Type__c'}
            },
            'pca__c' => new Map<String, String[]>{
                '1' => new String[] {'pca_rx__c', 'pca_rate__c'}
            },
            'mars_attached__c' => new Map<String, String[]>{
                '1' => new String[] {'recent_changes__c'}
            },
            'telemetry__c' => new Map<String, String[]>{
                '1' => new String[] {'will_be_dc_d_prior_to_transfer__c'}
            },
            'ventilator__c' => new Map<String, String[]>{
                '1' => new String[] {
                    'ventilator_mode__c','Ventilator_Type__c', 'ventilator_rate__c', 'fio2__c',
                    'peep__c', 'tv__c', 'ps__c', 'cpap__c', 'bipap__c','Ventilator_Other__c',
                    'bipap_rate__c', 'patient_to_bring_bipap__c',
                    'weaning_trial__c', 'ventilator_results__c'
                 }
            },
            
            'Ventilator_Type__c' => new Map<String, String[]>{
            	'Intermittent' => new String[]{'If_Intermittent_Schedule__c'}	
            },
             
            'o2__c' => new Map<String, String[]>{
                '1' => new String[] {
                    'liters_min__c', 'nasal_cannula__c', 'mask__c','O2_Type__c', 't_piece__c',
                    'mist_cooled__c', 'mist_heated__c', 'Mist__c'
                }
            },
            
            'Mist__c' => new Map <String, String[]>{
            	'1' => new String[] {'Mist_Type__c'}
            },
            
            'Mask__c' => new Map<String,String[]>{
            	'1' => new String[]{'Mask_Type__c'}
            },
            
            'telemetry__c' => new Map<String, String[]>{
                '1' => new String[] {'will_be_dc_d_prior_to_transfer__c'}
            },
            
            'trach__c' => new Map<String, String[]>{
                '1' => new String[] {
                    'trach_placement_date__c', 'trach_type__c', 'trach_size__c',
                    'cuffed__c', 'pmv__c'
                }
            },
            'Trach_Type__c' => new Map <String, String[]>{
            	'Other' => new String[]{'Trach_Type_Other__c'}
            },
            
            'trach_size__c' => new Map<String,String[]>{
            	'Other'=> new String []{'Trach_Size_Other__c'}
            },
            
            
            'treatments_other__c' => new Map<String, String[]>{
                '1' => new String[] {'treatments_other_comments__c'}
            },
            'treatments__c' => new Map<String, String[]>{
                '1' => new String[] {
                    'hhn__c', 'ippb__c', 'treatments_other__c'
                }
            },
            'decannulated__c' => new Map<String, String[]>{
                '1' => new String[] {'decannulated_placement_date__c'}
            },
            'suctioning__c' => new Map<String, String[]>{
                '1' => new String[] {
                    'suctioning_type__c', 'suctioning_frequency__c',
                    'sputum_quantity__c', 'sputum_appearance__c','Sputum_Color__c', 'Blood_Tinged__c','Thick__c','Thin__c',
                    'Frothy__c', 'Sticky__c', 'Creamy__c', 'Odor__c'
                }
            },
            'elimination_bladder_no_continent_details__c' => new Map<String, String[]>{
                'ICP' => new String[] {'if_icp_q__c'}
            },
            'elimination_bladder_continent__c' => new Map<String, String[]>{
                '1' => new String[] {'elimination_bladder_no_continent_details__c'}
            },
            'elimination_bowel_no_continent_appliance__c' => new Map<String, String[]>{
                'Other' => new String[] {'elimination_bowel_no_appliance_other__c'}
            },
            'elimination_bowel_continent__c' => new Map<String, String[]>{
                '1' => new String[] {'elimination_bowel_no_continent_appliance__c'}
            },
            'bowel_program__c' => new Map<String, String[]>{
                '1' => new String[] {'elimination_bowel_program_type__c'}
            },
            
            'Shunt_Permacath__c' => new Map <String, String[]>{
            	'1' => new String []{'Shunt_Permacath_Date_Placed__c', 'Shunt_Permacath_Location__c',
            						 'Shunt_Permacath_Previous_Provider__c'
            	}
            },
            
            'dialysis__c' => new Map<String, String[]>{
                '1' => new String[] {
                    'dialysis_type__c', 'dialysis_type_details__c',
                    'dialysis_onset__c', 'dialysis_days_of_the_week__c'
                }
            },
            'swallowing_problems__c' => new Map<String, String[]>{
                '1' => new String[] {
                    'dysphagia__c', 'aspiration__c', 'mbs_date__c',
                    'swallowing_problems_results__c'
                }
            },
            'rash__c' => new Map<String, String[]>{
                '1' => new String[] {'rash_description__c', 'rash_location__c'}
            },
            'burns__c' => new Map<String, String[]>{
                '1' => new String[] {'tbsa_percent__c', 'burns_area__c'}
            },
            'wound_vac__c' => new Map<String, String[]>{
                '1' => new String[] {
                    'wound_vac_frequency__c', 'wound_vac_duration__c'
                }
            },
            'specialty_bed__c' => new Map<String, String[]>{
                '1' => new String[] {'specialty_bed_type__c'}
            },
            'restraints__c' => new Map<String, String[]>{
                '1' => new String[] {'type_of_restraints__c'}
            },
            'rom_not_tested__c' => new Map<String, String[]>{
                '0' => new String[] {
                    'r_upper_rom__c', 'r_lower_rom__c', 'l_upper_rom__c',
                    'l_lower_rom__c'
                }
            },
            'tone_not_tested__c' => new Map<String, String[]>{
                '0' => new String[] {
                    'r_upper_tone__c', 'r_lower_tone__c', 'l_upper_tone__c',
                    'l_lower_tone__c'
                }
            },
            'strength_not_tested__c' => new Map<String, String[]>{
                '0' => new String[] {
                    'r_upper_strength__c', 'r_lower_strength__c',
                    'l_upper_strength__c', 'l_lower_strength__c'
                }
            },
            'sensation_not_tested__c' => new Map<String, String[]>{
                '0' => new String[] {
                    'r_upper_sensation__c', 'r_lower_sensation__c',
                    'l_upper_sensation__c', 'l_lower_sensation__c'
                }
            },
            'cast__c' => new Map<String, String[]>{
                '1' => new String[] {
                    'Ortho_Cast_Location__c', 'cast_type__c', 'patient_to_bring_cast__c',
                    'cast_ordered__c', 'cast_schedule__c'
                }
            },
            'Ortho_Cast_Location__c' => new Map <String, String[]>{
            	'Other' => new String[]{'Cast_Location__c'}
            },
            
            'traction__c' => new Map<String, String[]>{
                '1' => new String[] {
                    'traction_location__c', 'traction_type__c', 'traction_weight__c',
                    'traction_pin_care__c'
                }
            },
            'brace__c' => new Map<String, String[]>{
                '1' => new String[] {
                    'brace_location__c', 'brace_type__c', 'patient_to_bring_brace__c',
                    'brace_ordered__c', 'brace_schedule__c'
                }
            },
            'external_devices__c' => new Map<String, String[]>{
                '1' => new String[] {
                    'external_devices_location__c', 'external_devices_type__c',
                    'external_devices_pin_care__c'
                }
            },
            'rom__c' => new Map<String, String[]>{
                'Limited' => new String[] {'rom_limited_due_to__c'}
            },
            
            'therapy_ordered__c' => new Map<String, String[]>{
                '1' => new String[] {
                    'therapy_ordered_pt__c', 'therapy_ordered_ot__c',
                    'therapy_ordered_st__c', 'therapy_ordered_neuro_psy__c'
                }
            },
            
            'current_gait_mobility_other__c' => new Map<String, String[]>{
                '1' => new String[] {'current_gait_mobility_other_comments__c'}
            },
            'prior_living_situation__c' => new Map<String, String[]>{
                'Other' => new String[] {'prior_living_situation_other__c'}
            },
            'stairs__c' => new Map<String, String[]>{
                '1' => new String[] {'number_of_stairs__c', 'location_of_stairs__c'}
            },
            'discharge_to__c' => new Map<String, String[]>{
                'Other' => new String[] {'discharge_to_other__c'}
            },
            
            'Pain_Present__c' => new Map<string, String[]>{
            	'Yes' => new String[] {'Neuro_Pain_Activity__c', 'Neuro_Pain_Position__c', 'Neuro_Pain_Time_of_Day__c','Neuro_Pain_None__c','Neuro_Pain_Position_Describe__c','Neuro_pain_time_of_day_Describe__c','Neuro_pain_Activity_Describe__c','Neuro_Pain_Severity__c','Neuro_Pain_Level__c'}
            },
            
            'DC_Plan__c' => new Map<string, String[]>{
            	'Other' => new String[]{'DC_Plan_Other__c'}
            },
            
            'Alcohol_Abuse__c' => new Map<string, string[]>{
            	'1' => new String[]{'Alcohol_Abuse_Describe__c'}
            },
            'Drug_Abuse__c' => new Map<string, string[]>{
            	'1' => new String[]{'Drug_Abuse_Describe__c'}
            },
            
            'Sexual_Abuse__c' => new Map<string, string[]>{
            	'1' => new String[]{'Sexual_Abuse_Describe__c'}
            },
            
            'Domestic_Abuse__c' => new Map<string, string[]>{
            	'1' => new String[]{'Domestic_Abuse_Describe__c'}
            },
            
            'Financial_Abuse__c' => new Map<string, string[]>{
            	'1' => new String[]{'Financial_Abuse_Describe__c'}
            },
            
            'Physical_Abuse__c' => new Map<string, string[]>{
            	'1' => new String[]{'Physical_Abuse_Describe__c'}
            },
            
            'Risk_to_Self__c' => new Map<string, string[]>{
            	'1' => new String[]{'Risk_to_Self_Describe__c'}
            },
            
            'Risk_to_Others__c' => new Map<string, string[]>{
            	'1' => new String[]{'Risk_to_Others_Describe__c'}
            },
            
            'Hallucinations__c' => new Map<string, string[]>{
            	'1' => new String[]{'Hallucinations_Describe__c'}
            },
            
            'Elopement_Risk__c' => new Map<string, string[]>{
            	'1' => new String[]{'Elopement_Risk_Describe__c'}
            },
            
            'Religious_Preference__c' => new Map<string, String[]>{
            	'Yes' => new String[] {'Religious_Preference_Details__c', 'Spiritual_Care_Visits__c'}
            },
            
            'Cultural_Preferences__c' => new Map<string, string[]>{
            	'Yes' => new String[]{'Cultural_Preference_Specify__c'}
            },
            
            'Beliefs_that_could_affect_Treatment__c' => new Map<string, String[]>{
            	'Yes' => new String[] {'Other_Religious_Effect__c'}
            }
           
            
            
        };
        for (String fieldName: validationMap.keySet()) {
            String fieldStringValue;
            if (obj.get(fieldName) == null) {
                fieldStringValue = null;
            } else if ((Object)obj.get(fieldName) instanceof Boolean) {
                // Checkbox field
                fieldStringValue = (Boolean)obj.get(fieldName) ? '1' : '0';
            } else {
                fieldStringValue = String.valueOf(obj.get(fieldName));
            }
            Map<String, String[]> fieldMap = validationMap.get(fieldName);
            for (String validationValue: fieldMap.keySet()) {
                String[] fieldsToCheck = fieldMap.get(validationValue);
                if (validationValue != fieldStringValue) {
                    // Check all the other_field[] here
                    for (String fieldToCheck: fieldsToCheck) {
                        if (obj.get(fieldToCheck) == null) {
                            // Don't check type of null! It belongs to everything!
                            continue;
                        }
                        if ((Object)obj.get(fieldToCheck) instanceof Boolean) {
                            // Checkbox field are a little bit different, as
                            // they are always false by default, so we can't
                            // compare them to null or ''
                            if ((Boolean)obj.get(fieldToCheck)) {
                                //obj.get(fieldToCheck).addError('cannot be True while its controlling field has values in it.');
                                obj.put(fieldToCheck, false);
                            }
                        } else {
                            // For other fields, compare them to null or '' is
                            // enough
                            if (obj.get(fieldToCheck) != null && String.valueOf(obj.get(fieldToCheck)) != '') {
                                //obj.get(fieldToCheck).addError('cannot be set to ' + String.valueOf(obj.get(fieldToCheck)) + ' while its controlling field has values in it.');
                                obj.put(fieldToCheck, null);
                            }
                        }
                    }
                }
            }
        }
    }
    
}