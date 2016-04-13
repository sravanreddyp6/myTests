const users = require("../users.js").accounts;

const referralCreationMap = {
  "Redwood": {  // can't find OH or WV user in the users.json file
    "AZ": "RW_AZ_Referral_Intaker",
    "CA": "RW_CA_Referral_Intaker",
    "CA_FSS": "RW_CAFSS",
    "IA": "RW_IA_Referral",
    "IL": "RW_IL_Referral_Cans",
    "IN": "RW_IN_Referral_Intaker",
    "MN": "RW_MN_Referral",
    "NV": "RW_NVREF",
    "ND": "RW_NDREF",
    "OR": "RW_ORREF",
    "WI": "RW_WI_REF"
  },
  "Cambridge": {
    "GA": "HS_GA_Referral_Intaker",
    "MA": "HS_MA_2_Referral_Intaker",
    "MD": "HS_MD_2_Referral_Intaker",
    "NJ": "HS_NJ_Referral_Intaker",
    "OH": "HS_OH_Ary2_Referral_Intaker"
  },
  "Care Meridian": "CM_Marketer",
  "NeuroRestorative": "NR_Referrals_Ops",
  "Adult Day Health": "ADH_MD_Referral"
};

const referralConversionMap = {
  "Redwood": {
    "AZ": "RW_AZ_handler",
    "CA": "RW_CA_L3",
    "CA_FSS": "RW_CAFSS",
    "IA": "RW_IA_L3",
    "IL": "RW_IL_Referral_Cans",  // can't find a user for this yet
    "IN": "RW_IN_L3",
    "MN": "RW_MN_L3",
    "NV": "RW_NVREF",  // can't find a user for this yet
    "ND": "RW_NDREF",  // can't find a user for this yet
    "OR": "RW_OR_L3",  
    "WI": "RW_WI_L3"
  },
  "Cambridge": {
    "GA": "HS_GA_Referral_Cans",
    "MA": "HS_MA",
    "MD": "HS_MD_Referral_Intaker",  // can't find a better user for this
    "NJ": "HS_NJ_Referral_Intaker",  // can't find a better user for this
    "OH": "HS_OH"
  },
  "Care Meridian": "CM_DON",
  "NeuroRestorative": "NR_funding",
  "Adult Day Health": "ADH_MA_L3"
};

module.exports = {
  getUserForReferralCreation: function (operatingGroup, flavor) {
    var user;
    if (operatingGroup === "Care Meridian" || operatingGroup == "NeuroRestorative" || operatingGroup == "Adult Day Health") {
      user = users[referralCreationMap[operatingGroup]];
    } else {
      user = users[referralCreationMap[operatingGroup][flavor]];
    }
    if (user) {
      return user;
    }
    throw new Error("Cannot get user for referral creation with operating group " + operatingGroup + " and flavor " + flavor);
  },
  getUserForReferralConversion: function (operatingGroup, flavor) {
    var user;
    if (operatingGroup === "Care Meridian" || operatingGroup == "NeuroRestorative" || operatingGroup == "Adult Day Health") {
      user = users[referralConversionMap[operatingGroup]];
    } else {
      user = users[referralConversionMap[operatingGroup][flavor]];
    }
    if (user) {
      return user;
    }
    throw new Error("Cannot get user for referral conversion with operating group " + operatingGroup + " and flavor " + flavor);
  }
};