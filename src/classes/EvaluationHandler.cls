public with sharing class EvaluationHandler {
    private boolean m_isExecuting = false;

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
                '1' => new String[] {'isolation_type__c'}
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
                    'ventilator_mode__c', 'ventilator_rate__c', 'fio2__c',
                    'peep__c', 'tv__c', 'ps__c', 'cpap__c', 'bipap__c',
                    'bipap_rate__c', 'patient_to_bring_bipap__c',
                    'weaning_trial__c', 'ventilator_results__c'
                 }
            },
            'o2__c' => new Map<String, String[]>{
                '1' => new String[] {
                    'liters_min__c', 'nasal_cannula__c', 'mask__c', 't_piece__c',
                    'mist_cooled__c', 'mist_heated__c'
                }
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
                    'sputum_quantity__c', 'sputum_appearance__c'
                }
            },
            'elimination_bladder_no_continent_details__c' => new Map<String, String[]>{
                'ICP' => new String[] {'if_icp_q__c'}
            },
            'elimination_bladder_continent__c' => new Map<String, String[]>{
                '0' => new String[] {'elimination_bladder_no_continent_details__c'}
            },
            'elimination_bowel_no_continent_appliance__c' => new Map<String, String[]>{
                'Other' => new String[] {'elimination_bowel_no_appliance_other__c'}
            },
            'elimination_bowel_continent__c' => new Map<String, String[]>{
                '0' => new String[] {'elimination_bowel_no_continent_appliance__c'}
            },
            'bowel_program__c' => new Map<String, String[]>{
                '1' => new String[] {'elimination_bowel_program_type__c'}
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
                    'cast_location__c', 'cast_type__c', 'patient_to_bring_cast__c',
                    'cast_ordered__c', 'cast_schedule__c'
                }
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