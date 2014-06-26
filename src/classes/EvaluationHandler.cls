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
            
            'Diabetic__c' => new Map<String, String[]>{
                'Yes' => new String[] {'If_yes_Glucose_meter_Reading__c'}
            },
            
            'Pneumococcal__c' => new Map<String, String[]>{
                '1' => new String[] {'Pneumococcal_Text__c', 'Pneumococcal_Where_and_when__c'}
            },
            
             'Influenza__c' => new Map<String, String[]>{
                '1' => new String[] {'Influenza_Text__c', 'Influenza_where_and_when__c'}
            },
            
             'TDAP__c' => new Map<String, String[]>{
                '1' => new String[] {'TDAP_Text__c', 'TDAP_Where_and_When__c'}
            },
            
            'power_of_attorney__c' => new Map<String, String[]>{
                '1' => new String[] {'poa_name__c', 'poa_type__c'}
            },
            
            'isolation__c' => new Map<String, String[]>{
                '1' => new String[] {'DiagnosisIsolation_Type__c', 'Isolation_Type__c','Isolation_Reason_and_Site__c'}
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
                    'cuffed__c', 'pmv__c','Trach_Plugged__c'
                }
            },
            'Trach_Type__c' => new Map <String, String[]>{
            	'Other' => new String[]{'Trach_Type_Other__c'}
            },
            
            'trach_size__c' => new Map<String,String[]>{
            	'Other'=> new String []{'Trach_Size_Other__c'}
            },
            
            'Trach_Plugged__c' => new Map<String,String[]>{
            	'1'=> new String []{'Trach_Plugged_Initiated__c','Trach_Plugged_Duration__c'}
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
  
            'Smoking_History__c' => new Map<String, String[]>{
                'No' => new String[] {'Packs_Day_Years__c'}
            },
            
            'Heart_Sounds__c' => new Map<String, String[]>{
                'Irregular' => new String[] {'Heart_Sound_Describe__c'}
            },
            
            'Peripheral_Pulses_Present__c' => new Map<String, String[]>{
                'No' => new String[] {'Peripheral_Pulses_Describe__c'}
            },
            
            'Pulse_Ox_Details__c' => new Map<String, String[]>{
                'Intermittent' => new String[] {'Pulse_Ox_Schedule__c'}
            },
            
            'Autonomic_Dysreflexia__c' => new Map<String, String[]>{
                'Yes' => new String[] {'Educated_Regarding_AD__c'}
            },
            
            'elimination_bladder_no_continent_details__c' => new Map<String, String[]>{
                'ICP' => new String[] {'if_icp_q__c','ICP_Describe__c'}
            },
            
            'elimination_bladder_continent__c' => new Map<String, String[]>{
                '1' => new String[] {'elimination_bladder_no_continent_details__c','Incontinent_Age_Appropriate__c'}
            },
            
            'elimination_bowel_continent__c' => new Map<String, String[]>{
                '1' => new String[] {'elimination_bowel_no_continent_appliance__c'}
            },
            
            'Elimination_Bowel_No_Continent_Appliance__c' => new Map<String, String[]>{
                'Other' => new String[] {'Elimination_Bowel_No_Appliance_Other__c','Incontinent_Bowel_Age_Appropriate__c'}
            },
            
            'Incontinent_Bowel_Age_Appropriate__c' => new Map<String, String[]>{
                'Yes' => new String[] {'Incontinent_Bowel_Child_Training__c','Incontinent_Bowel_ChildTraining_Describe__c'}
            },
            
            'Incontinent_Age_Appropriate__c' => new Map<String, String[]>{
                'Yes' => new String[] {'InContinent_Child_toilet_training__c','Incontinent_toilet_training_describe__c'}
            },
            
            'Incontinent_Bowel_Child_Training__c' => new Map<String, String[]>{
                'Yes' => new String[] {'Incontinent_Bowel_ChildTraining_Describe__c'}
            },
            
            'InContinent_Child_toilet_training__c' => new Map<String, String[]>{
                'Yes' => new String[] {'Incontinent_toilet_training_describe__c'}
            },
            
            'Incontinent_Neurogenic_Bowel__c' => new Map<String, String[]>{
                'Yes' => new String[] {'Incontinent_Neuro_Bowel_Describe__c'}
            },
            
            'bowel_program__c' => new Map<String, String[]>{
                '1' => new String[] {'elimination_bowel_program_type__c'}
            },
            
            'Urine_Color__c' => new Map<String, String[]>{
                'Other' => new String[] {'Urine_Color_Other__c'}
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
            
            'History_of_Constipation__c' => new Map<String, String[]>{
                'Yes' => new String[] {'Type_of_Constipation__c'}
            },
            
            'History_of_Laxative_Use__c' => new Map<String, String[]>{
                'Yes' => new String[] {'Enema_or_Suppository_use_Describe__c'}
            },
            
            'History_of_Enema_or_Suppository_Use__c' => new Map<String, String[]>{
                'Yes' => new String[] {'Laxative_Use_Describe__c'}
            },
            
            'Use_of_Dietary_Supplements__c' => new Map<String, String[]>{
                'Yes' => new String[] {'Dietary_supplement_describe__c'}
            },
            
            'History_of_Diarrhea__c' => new Map<String, String[]>{
                'Yes' => new String[] {'Causative_factors_Diarrhea__c'}
            },
            
            
            'Jaw_Wires__c' => new Map<String, String[]>{
                'Yes' => new String[] {'Wire_Cutters_at_Bedside__c'}
            },
            
            'PEDS_History_of_Tonsils__c' => new Map<String, String[]>{
                'Yes' => new String[] {'PEDS_Tonsil_History_Describe__c'}
            },
            
            'PEDS_Pacifier__c' => new Map<String, String[]>{
                'Yes' => new String[] {'PEDS_Pacifier_Type_Usage__c'}
            },
            
            'RUQ__c' => new Map<String, String[]>{
                'Abnormal' => new String[] {'RUQ_Describe__c'}
            },
            
            'LUQ__c' => new Map<String, String[]>{
                'Abnormal' => new String[] {'LUQ_Describe__c'}
            },
            
            'RLQ__c' => new Map<String, String[]>{
                'Abnormal' => new String[] {'RLQ_Describe__c'}
            },
            
            'LLQ__c' => new Map<String, String[]>{
                'Abnormal' => new String[] {'LLQ_Describe__c'}
            },
            
            'History_of_Pressure_Ulcers_Flap_Surge__c' => new Map<String, String[]>{
                'Yes' => new String[] {'Pressure_Ulcer_Flap_Surgery_describe__c'}
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
            
            'Rehab_Equipment_Other__c' => new Map<String, String[]>{
                '1' => new String[] {'Rehab_Equipment_Other_Details__c'}
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
            
            'VP_Shunt__c' => new Map<String, String[]>{
                'Yes' => new String[] {'VP_Shunt_Describe__c'}
            },
            
            'Depression_History__c' => new Map<string, String[]>{
            	'Yes' => new String[]{'Depression_desire_to_hurt_themsleves__c','Depression_Patient_received_Treatment__c'}
            },
            
            'Desire_to_hurt_themselves__c' => new Map<String, String[]>{
                'Yes' => new String[] {'Plan_to_Harm_themselves__c'}
            },
            
           'One_to_One_Sitter__c' => new Map<String, String[]>{
                '1' => new String[] {'one_to_One_Sitter_of_Hours_per_day__c'}
            },
            
            'Mitt__c' => new Map<string, String[]>{
            	'1' => new String[]{'Mitt_Device_can_be_removed__c','Mitt_Device_restrict_freedom__c'}
            },
            
            'Mitt_Device_can_be_removed__c' => new Map<string, String[]>{
            	'No' => new String[]{'Mitt_Device_restrict_freedom__c'}
            },
            
             
            'UE__c' => new Map<string, String[]>{
            	'1' => new String[]{'UE_Device_can_be_removed__c','UE_Device_restrict_freedom__c'}
            },
            
            'UE_Device_can_be_removed__c' => new Map<string, String[]>{
            	'No' => new String[]{'UE_Device_restrict_freedom__c'}
            },
             
            'LE__c' => new Map<string, String[]>{
            	'1' => new String[]{'LE_Device_can_be_removed__c','LE_Device_restrict_freedom__c'}
            },
            
            'LE_Device_can_be_removed__c' => new Map<string, String[]>{
            	'No' => new String[]{'LE_Device_restrict_freedom__c'}
            },
            
            'Chest_Restraint__c' => new Map<string, String[]>{
            	'1' => new String[]{'Chest_restraint_can_be_removed__c','Chest_Restraint_restrict_Freedom__c'}
            },
            
            'Chest_restraint_can_be_removed__c' => new Map<string, String[]>{
            	'No' => new String[]{'Chest_Restraint_restrict_Freedom__c'}
            },
            
            'Seat_Belt__c' => new Map<string, String[]>{
            	'1' => new String[]{'Seat_Belt_can_be_removed__c','Seat_Belt_restrict_Freedom__c'}
            },
            
            'Seat_Belt_can_be_removed__c' => new Map<string, String[]>{
            	'No' => new String[]{'Seat_Belt_restrict_Freedom__c'}
            },
            
             'Lap_Tray__c' => new Map<string, String[]>{
            	'1' => new String[]{'Lap_Tray_Can_be_removed__c','Lap_Tray_restrict_freedom__c'}
            },
            
            'Lap_Tray_Can_be_removed__c' => new Map<string, String[]>{
            	'No' => new String[]{'Lap_Tray_restrict_freedom__c'}
            },
             
             
             'Trunk_Supports__c' => new Map<string, String[]>{
            	'1' => new String[]{'Trunk_supports_can_be_removed__c','Trunk_supports_restrict_freedom__c'}
            },
            
            'Trunk_supports_can_be_removed__c' => new Map<string, String[]>{
            	'No' => new String[]{'Trunk_supports_restrict_freedom__c'}
            },
            
            'Enclosure_Bed__c' => new Map<string, String[]>{
            	'1' => new String[]{'Enclosure_Bed_can_be_removed__c','Enclosure_bed_restrict_freedom__c'}
            },
            
            'Enclosure_Bed_can_be_removed__c' => new Map<string, String[]>{
            	'No' => new String[]{'Enclosure_bed_restrict_freedom__c'}
            },
            
            'Side_Rails_Half_full__c' => new Map<string, String[]>{
            	'1' => new String[]{'Side_Rails_can_be_removed__c','Side_rails_can_restrict_freedom__c'}
            },
            
            'Side_Rails_can_be_removed__c' => new Map<string, String[]>{
            	'No' => new String[]{'Side_rails_can_restrict_freedom__c'}
            },
  
            
            'Signed_Consent_for_Restraints__c' => new Map<string, String[]>{
            	'1' => new String[]{'Consent_for_Restraints_Describe__c'}
            },
            
            'Ear_Infections__c' => new Map<string, String[]>{
            	'1' => new String[]{'Ear_infection_Describe__c'}
            },
            
            'Activity__c' => new Map<string, String[]>{
            	'1' => new String[]{'Activity_Describe__c'}
            },
            
            'Position__c' => new Map<string, String[]>{
            	'1' => new String[]{'Position_Describe__c'}
            },
            
            'Time_of_Day__c' => new Map<string, String[]>{
            	'1' => new String[]{'Time_of_Day_Describe__c'}
            },
            
            'Neuro_Pain_Activity__c' => new Map<string, String[]>{
            	'1' => new String[]{'Neuro_pain_Activity_Describe__c'}
            },
            
            'Neuro_Pain_Position__c' => new Map<string, String[]>{
            	'1' => new String[]{'Neuro_Pain_Position_Describe__c'}
            },
            
            'Neuro_Pain_Time_of_Day__c' => new Map<string, String[]>{
            	'1' => new String[]{'Neuro_pain_time_of_day_Describe__c'}
            },
            
            'Pain_Present__c' => new Map<string, String[]>{
            	'Yes' => new String[] {'Neuro_Pain_Activity__c', 'Neuro_Pain_Position__c', 'Neuro_Pain_Time_of_Day__c','Neuro_Pain_None__c','Neuro_Pain_Position_Describe__c','Neuro_pain_time_of_day_Describe__c','Neuro_pain_Activity_Describe__c','Neuro_Pain_Severity__c','Neuro_Pain_Level__c','Neuro_Other_Body_Map_Comments__c'}
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
            
		    'Physical_emotional_or_Financial_harm__c' => new Map<string, String[]>{
		    	'Yes' => new String[] {'Harm_Describe__c', 'Harm_Reported_to__c','Harm_Date_and_Time_Reported__c'}
		    },
		    
		    'Representative_present_at_Admission__c' => new Map<string, string[]>{
            	'Yes' => new String[]{'Name_of_Representative_present__c'}
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