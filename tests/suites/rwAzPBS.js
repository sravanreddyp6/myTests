var assert = require('chai').assert;
var testSuite = require("../main.js").testSuite;
var users = require("../users.js").accounts;

var suiteTimeout = 3 * 60 * 1000;
var defaultOperationTimeout = 30 * 1000;

testSuite("rwAzPBS", suiteTimeout, {
	  "should create a Redwood AZ Person Being Served successfully": function(client, done) {
	    return client
	    .logInAs(users["RW_AZ_handler"])
	    .click("a=Add New Person Being Served")
	    .getSelectOptions('Race')
      .then(function(races) {
        assert.deepEqual([
          "", "Caucasian", "African American", "American Indian/Alaskan", "Asian/Pacific Islands",
          "Hispanic", "Multi-Racial", "Middle Eastern", "Other"
        ], races);
      })
      .getSelectOptions("Ethnicity")
      .then(function(ethnicities) {
        assert.deepEqual([
          "", "Aboriginal", "African", "Arab", "Balkan", "Baltic", "British Isles", "Caribbean",
          "Czech and Slovak", "East and Southeast Asian", "Eastern European", "European", "French",
          "Indo-Chinese", "Latin, Central, South American", "Maghrebi", "North American",
          "Northern European", "Oceania", "Other European", "Pacific Islands", "Scandinavian",
          "South Asian", "Southern European", "West Asian", "Western European"
        ], ethnicities);
      })
      .getSelectOptions("Marital Status")
      .then(function(status) {
        assert.deepEqual([
          "", "Single", "Married", "Divorced", "N/A"
        ], status);
      })
      .getSelectOptions("Primary Language")
      .then(function(languages) {
        assert.deepEqual([
          "", "Afghani",
          "Albanian",
          "Arabic",
          "Armenian",
          "Austrian",
          "Bengali",
          "Bielorussian",
          "Bosnian",
          "Cajun",
          "Cambodian",
          "Cantonese",
          "Chinese",
          "Croatian",
          "Czech",
          "Danish",
          "English",
          "English creoles- Belize, Guyanese",
          "French",
          "French Creole",
          "German",
          "Greek",
          "Haitian Creole",
          "Hebrew",
          "Hindi",
          "Hmong",
          "Icelandic",
          "India, n.e.c.",
          "Indonesian",
          "Italian",
          "Jamaican Creole",
          "Japanese",
          "Khmer",
          "Korean",
          "Laotian",
          "Mandarin",
          "Miao, Hmong",
          "Mon-Khmer, Cambodian",
          "Muong",
          "Norwegian",
          "Pakistan, n.e.c.",
          "Patois",
          "Polish",
          "Portuguese",
          "Romanian",
          "Russian",
          "Serbian",
          "Shanghainese",
          "Spanish",
          "Swedish",
          "Swiss",
          "Taiwanese",
          "Turkish",
          "Ukrainian",
          "Vietnamese"
        ], languages);
      })
      .getSelectOptions('Highest Level of Education')
      .then(function(educationLevels) {
        assert.deepEqual([
          "", "1 Year Preschool", "2+ Years Preschool", "Kindergarten", "Grade 1", "Grade 2",
          "Grade 3", "Grade 4", "Grade 5", "Grade 6", "Grade 7", "Grade 8", "Grade 9", "Grade 10",
          "Grade 11", "Grade 12", "1 Year College", "2 Years College", "3 Years College",
          "4+ Years College", "Graduate School", "1 Year Vocational/Technical",
          "2 Years Vocational/Technical", "Elementary School Special Education",
          "Middle School Special Education", "High School Special Education",
          "1 Year Special Education", "2+ Years Special Education",
          "Post Secondary Transition Services", "None", "Unknown"
        ], educationLevels);
      })
      .getSelectOptions('Gender')
      .then(function(genders) {
        assert.deepEqual([
          "", "Male", "Female"
        ], genders);
      })
     .getSelectOptions('Mailing Country')
      .then(function(Country) {
        assert.deepEqual([
          "", "Andorra",
          "United Arab Emirates",
          "Afghanistan",
          "Antigua and Barbuda",
          "Anguilla",
          "Albania",
          "Armenia",
          "Angola",
          "Antarctica",
          "Argentina",
          "Austria",
          "Australia",
          "Aruba",
          "Aland Islands",
          "Azerbaijan",
          "Bosnia and Herzegovina",
          "Barbados",
          "Bangladesh",
          "Belgium",
          "Burkina Faso",
          "Bulgaria",
          "Bahrain",
          "Burundi",
          "Benin",
          "Saint Barthélemy",
          "Bermuda",
          "Brunei Darussalam",
          "Bolivia, Plurinational State of",
          "Bonaire, Sint Eustatius and Saba",
          "Brazil",
          "Bahamas",
          "Bhutan",
          "Bouvet Island",
          "Botswana",
          "Belarus",
          "Belize",
          "Canada",
          "Cocos (Keeling) Islands",
          "Congo, the Democratic Republic of the",
          "Central African Republic",
          "Congo",
          "Switzerland",
          "Cote d’Ivoire",
          "Cook Islands",
          "Chile",
          "Cameroon",
          "China",
          "Colombia",
          "Costa Rica",
          "Cuba",
          "Cape Verde",
          "Curaçao",
          "Christmas Island",
          "Cyprus",
          "Czech Republic",
          "Germany",
          "Djibouti",
          "Denmark",
          "Dominica",
          "Dominican Republic",
          "Algeria",
          "Ecuador",
          "Estonia",
          "Egypt",
          "Western Sahara",
          "Eritrea",
          "Spain",
          "Ethiopia",
          "Finland",
          "Fiji",
          "Falkland Islands (Malvinas)",
          "Faroe Islands",
          "France",
          "Gabon",
          "United Kingdom",
          "Grenada",
          "Georgia",
         "French Guiana",
          "Guernsey",
          "Ghana",
          "Gibraltar",
          "Greenland",
          "Gambia",
          "Guinea",
          "Guadeloupe",
          "Equatorial Guinea",
          "Greece",
          "South Georgia and the South Sandwich Islands",
          "Guatemala",
          "Guinea-Bissau",
          "	Guyana",
          "	Heard Island and McDonald Islands",
          "	Honduras",
          "	Croatia",
          "	Haiti",
          "	Hungary",
          "	Indonesia",
          "	Ireland",
          "	Israel",
          "	Isle of Man",
          "	India",
          "	British Indian Ocean Territory",
          "	Iraq",
          "	Iran, Islamic Republic of",
          "	Iceland",
          "	Italy",
          "	Jersey",
          "	Jamaica",
          "	Jordan",
          "	Japan",
          "	Kenya",
          "	Kyrgyzstan",
          "	Cambodia",
          "	Kiribati",
          "	Comoros",
          "	Saint Kitts and Nevis",
          "	Korea, Democratic People’s Republic of",
          "	Korea, Republic of",
          "	Kuwait",
          "	Cayman Islands",
          "	Kazakhstan",
          "	Lao People’s Democratic Republic",
          "	Lebanon",
          "	Saint Lucia",
          "	Liechtenstein",
          "	Sri Lanka",
          "	Liberia",
          "	Lesotho",
          "	Lithuania",
          "	Luxembourg",
          "	Latvia",
          "	Libyan Arab Jamahiriya",
          "	Morocco",
          "	Monaco",
          "	Moldova, Republic of",
          "	Montenegro",
          "	Saint Martin (French part)",
          "	Madagascar",
          "	Macedonia, the former Yugoslav Republic of",
          "	Mali",
          "	Myanmar",
          "	Mongolia",
          "	Macao",
          "	Martinique",
          "	Mauritania",
          "	Montserrat",
          "	Malta",
          "	Mauritius",
          "	Maldives",
          "	Malawi",
          "	Mexico",
          "	Malaysia",
          "	Mozambique",
          "	Namibia",
          "	New Caledonia",
          "	Niger",
          "	Norfolk Island",
          "	Nigeria",
          "	Nicaragua",
          "	Netherlands",
          "	Norway",
          "	Nepal",
          "	Nauru",
          "	Niue",
          "	New Zealand",
          "	Oman",
          "	Panama",
          "	Peru",
          "	French Polynesia",
          "	Papua New Guinea",
          "	Philippines",
          "	Pakistan",
          "	Poland",
          "	Saint Pierre and Miquelon",
          "	Pitcairn",
          "	Palestine",
          "	Portugal",
          "	Paraguay",
          "	Qatar",
          "	Reunion",
          "	Romania",
          "	Serbia",
          "	Russian Federation",
          "	Rwanda",
          "	Saudi Arabia",
          "	Solomon Islands",
          "	Seychelles",
          "	Sudan",
          "	Sweden",
          "	Singapore",
          "	Saint Helena, Ascension and Tristan da Cunha",
          "	Slovenia",
          "	Svalbard and Jan Mayen",
          "	Slovakia",
          "	Sierra Leone",
          "	San Marino",
          "	Senegal",
          "	Somalia",
          "	Suriname",
          "	South Sudan",
          "	Sao Tome and Principe",
          "	El Salvador",
          "	Sint Maarten (Dutch part)",
          "	Syrian Arab Republic",
          "	Swaziland",
          "	Turks and Caicos Islands",
          "	Chad",
          "	French Southern Territories",
          "	Togo",
          "	Thailand",
          "	Tajikistan",
          "	Tokelau",
          "	Timor-Leste",
          "	Turkmenistan",
          "	Tunesia",
          "	Tonga",
          "	Turkey",
          "	Trinidad and Tobago",
          "	Tuvalu",
          "	Taiwan",
          "	Tanzania, United Republic of",
          "	Ukraine",
          "	Uganda",
          "	United States",
          "	Uruguay",
          "	Uzbekistan",
          "	Holy See (Vatican City State)",
          "	Saint Vincent and the Grenadines",
          "	Venezuela, Bolivarian Republic of",
          "	Virgin Islands, British",
          "	Viet Nam",
          "	Vanuatu",
          "	Wallis and Futuna",
          "	Samoa",
          "	Yemen",
          "	Mayotte",
          "	South Africa",
          "	Zambia",
          "	Zimbabwe"
        ], Country);
      })
      .chooseSelectOption("Mailing Country", "United States")
      .getSelectOptions('Mailing State/Province')
      .then(function(states) {
        assert.deepEqual([
          "", "Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut",
          "Delaware", "District of Columbia", "Florida", "Georgia", "Guam", "Hawaii", "Idaho",
          "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland",
          "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana",
          "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York",
          "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania",
          "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah",
          "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"
        ], states);
      })
      .getSelectOptions('Legal/Guardianship Status')
      .then(function(guardianStatus) {
          assert.deepEqual(["", "Civil Commitment", "Conservator/Conservatorship", "Full Guardian", "Guardian", "Health Care Representative",
                            "Kinship", "Limited Guardianship", "Parent", "Self", "Shelter Care", "State Assumes Guardianship", "Voluntary Placement Agreement"], guardianStatus);
      })
      .fillInputText("First Name", "Force")
      .chooseSelectOption("Race", "Caucasian")
      .fillInputText("Middle Name", "Freaking")
      .chooseSelectOption("Ethnicity", "North American")
      .fillInputText("Last Name", "Awakens")
      .chooseSelectOption("Marital Status", "Single")
      .fillInputText("Date of Birth", "7/7/1988")
      .chooseSelectOption("Highest Level of Education", "Graduate School")
      .chooseSelectOption("Gender", "Male")
      
      .fillInputText("Family Members / Other / Notes", "Really hateful")
      .chooseSelectOption("Mailing State/Province", "Arizona")
      .click("input[value='Save']")
      .url()
      .then(function (url) {
        assert.include(url.value, "PersonBeingServedEditNew");
      })
	  }
});