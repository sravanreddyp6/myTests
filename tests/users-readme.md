# Regression Tests Users

## Users Info

Test users are contained in the config/users.json file.  These users are based on account provisioning rules set forth in https://wiki.thementornetwork.com/display/IEADD/iServe+Account+Provisioning+Types.  

The following conventions are also used in the users.json file:
- username = operating group (2 chars) _ usertype @ tmn.com
- password = TestPassword01
- first_name = operating group (2 chars) + brief desc of user type
- last_name = state (where applicable), or user type
- alias = 8 char max combindation of operating group, state, and user type 
- email = rt@tmn.com - please do not another email address
- profile = according to provisioning wiki
- operating group = according to provisioning wiki
- role = according to provisioning wiki
- permission_sets = according to provisioning wiki
- public groups = according to provisioning wiki

*Before* running this users.json script please make sure the following two public groups exist:

Referrals - Cambridge - PA
Referrals - Cambridge - SC
 

Chart of users included in users.json is here : https://wiki.thementornetwork.com/display/IEADD/Regression+Tests+Set+Up

If you need another type of user please ADD one following the guidelines above and document in the wiki file.  Do not modify the existing set unless the provisioning specs change!









 