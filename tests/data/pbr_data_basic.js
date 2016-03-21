const stateMap = require("./state_map.js");

module.exports = function (operatingGroup, flavor) {
  return [
    {
      "selector_type": "label",
      "selector": "First Name",
      "value": operatingGroup + (new Date().getTime()),
      "element_type": "text"
    },
    {
      "selector_type": "label",
      "selector": "Last Name",
      "value": flavor,
      "element_type": "text"
    },
    {
      "selector_type": "label",
      "selector": "Date of Birth",
      "value": "01/01/1970",
      "element_type": "text"
    },
    {
      "selector_type": "label",
      "selector": "Gender",
      "value": "Male",
      "element_type": "select_option"
    },
    {
      "selector_type": "label",
      "selector": "Mailing State/Province",
      "value": stateMap()[flavor],
      "element_type": "select_option"
    },
  ];
};