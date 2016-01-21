"use strict";

const getCurrentDate = function () {
  const today = new Date();
  let dd = today.getDate();
  let mm = today.getMonth() + 1;  // 0-based index
  let yyyy = today.getFullYear();

  if (dd < 10) {
      dd = '0' + dd;
  }

  if (mm < 10) {
      mm = '0' + mm;
  }
  return mm + '/' + dd + '/' + yyyy;
}

module.exports = function (operatingGroup, flavor) {
  return [
    {
      "selector_type": "label",
      "selector": "Anticipated Admission DateTime",
      "value": "01/12/2016 18:00",
      "element_type": "text"
    },
    {
      "selector_type": "label",
      "selector": "Referral Date",
      "value": getCurrentDate(),
      "element_type": "text"
    },
    {
      "selector_type": "label",
      "selector": "Referral Status",
      "value": "New",
      "element_type": "select_option"
    },
    {
      "selector_type": "label",
      "selector": "Current Location",
      "value": "Home",
      "element_type": "text",
      "enabled": operatingGroup == "Care Meridian"
    },
    {
      "selector_type": "label",
      "selector": "Referral Source",
      "value": "Sample Source",
      "element_type": "text",
      "enabled": operatingGroup == "Care Meridian" || operatingGroup == "NeuroRestorative"
    },
    {
      "selector_type": "label",
      "selector": "Referral Source Type",
      "value": "Administrator",
      "element_type": "select_option",
      "enabled": operatingGroup == "NeuroRestorative"
    },
    {
      "selector_type": "label",
      "selector": "How did referrer learn about us?",
      "value": "Internet Search",
      "element_type": "select_option",
      "enabled": operatingGroup == "NeuroRestorative"
    },
    {
      "selector_type": "label",
      "selector": "Referrer Name",
      "value": "Sample Name",
      "element_type": "text",
      "enabled": operatingGroup == "NeuroRestorative"
    },
    {
      "selector_type": "label",
      "selector": "Date of Injury",
      "value": "1/13/2016",
      "element_type": "text",
      "enabled": operatingGroup == "NeuroRestorative"
    },
    {
      "selector_type": "label",
      "selector": "Cause of Injury",
      "value": "Fall",
      "element_type": "select_option",
      "enabled": operatingGroup == "NeuroRestorative"
    },
    {
      "selector_type": "label",
      "selector": "Current Location Type",
      "value": "Home",
      "element_type": "select_option",
      "enabled": operatingGroup == "NeuroRestorative"
    },
    {
      "selector_type": "label",
      "selector": "Services Requested",
      "value": ["Community", "In-Patient"],
      "element_type": "multi_select_option",
      "enabled": operatingGroup == "NeuroRestorative"
    },
    {
      "selector_type": "label",
      "selector": "Program Category",
      "value": "IDD",
      "element_type": "select_option",
      "enabled": operatingGroup == "Cambridge"
    },
    {
      "selector_type": "label",
      "selector": "Service Line",
      "value": ["Group Home"],
      "element_type": "multi_select_option",
      "enabled": operatingGroup == "Cambridge"
    },
    {
      "selector_type": "label",
      "selector": "Services Requested",
      "value": ["Host Home"],
      "element_type": "multi_select_option",
      "enabled": operatingGroup == "Cambridge"
    },
  ];
};