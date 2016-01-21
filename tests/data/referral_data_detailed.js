// There are a few fields in the Excel sheet that applies to Hastings North Carolina (e.g. Other
// Id, Other Id Description), but apparently those businesses went out of business, so we don't
// have a user in users.json to test them with. I'm going to leave those fields out.
module.exports = function (operatingGroup, flavor) {
  return [
    {
      "selector_type": "label",
      "selector": "Middle Name",
      "value": "MN",
      "element_type": "text"
    },
    {
      "selector_type": "label",
      "selector": "Race",
      "value": "Caucasian",
      "element_type": "select_option"
    },
    {
      "selector_type": "label",
      "selector": "Ethnicity",
      "value": "European",
      "element_type": "select_option"
    },
    {
      "selector_type": "label",
      "selector": "Marital Status",
      "value": "Single",
      "element_type": "select_option"
    },
    {
      "selector_type": "label",
      "selector": "Primary Language",
      "value": "English",
      "element_type": "select_option"
    },
    {
      "selector_type": "selector",
      "selector": "[id$=nonverb]",
      "value": true,
      "element_type": "checkbox"
    },
    {
      "selector_type": "selector",
      "selector": "[id$=signLan]",
      "value": true,
      "element_type": "checkbox"
    },
    {
      "selector_type": "label",
      "selector": "Highest Level of Education",
      "value": "4+ Years College",
      "element_type": "select_option"
    },
    {
      "selector_type": "label",
      "selector": "Billing ID",
      "value": "Sample ID",
      "element_type": "text"
    },
    {
      "selector_type": "label",
      "selector": "Mailing Street 1",
      "value": "Sample Mailing Street 1",
      "element_type": "text"
    },
    {
      "selector_type": "label",
      "selector": "Mailing Street 2",
      "value": "Sample Mailing Street 2",
      "element_type": "text"
    },
    {
      "selector_type": "label",
      "selector": "Mailing Zip/Postal Code",
      "value": "00000",
      "element_type": "text"
    },
    {
      "selector_type": "label",
      "selector": "Mailing County",
      "value": "Sample Mailing County",
      "element_type": "text"
    },
    {
      "selector_type": "label",
      "selector": "Phone",
      "value": "0000000000",
      "element_type": "text"
    },
    {
      "selector_type": "label",
      "selector": "Email",
      "value": "test_email@thementornetwork.com",
      "element_type": "text"
    },
    {
      "selector_type": "label",
      "selector": "Current Medications",
      "value": "Sample Medications",
      "element_type": "text"
    },
    {
      "selector_type": "label",
      "selector": "Guardianship Type",
      "value": "Partial Guardianship/Conservatorship",
      "element_type": "select_option"
    },
    {
      "selector_type": "label",
      "selector": "Partial Guardianship/Conservatorship Type",
      "value": ["Financial", "Medical"],
      "element_type": "multi_select_option"
    },
  ];
}