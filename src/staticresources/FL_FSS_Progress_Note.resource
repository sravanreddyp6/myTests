<body>
<table class="myTB">
  <tr><td align="center" style="font-size:15pt"><img src="{!URLFOR($Resource.ESD_Images,'FLESDLogo.png')}" alt="FL Logo"></td></tr>
  <tr><td align="center">{!Program__c} - {!Location_Region__c}</td></tr>
</table>
<div class="section-divider"></div>
<table class="general-table">
	<tr>
		<td width="50%">Client:&nbsp;{!Name}</td>
	</tr>
	<tr>
		<td width="40%">Medicaid #:&nbsp;{!Medicaid_ID__c}</td>
		<td width="50%"></td>
	</tr>
	<tr>
		<td width="25%">Start Time:&nbsp;{!Start_Time__c}</td>
		<td width="25%">End Time:&nbsp;{!End_Time__c}</td>
	</tr>	
</table>
<div>
	<table border="1" class="general-table">
		<th>Progress Notes</th>
		<th>Collateral Contact</th>
		<tr>
			<td>
				<table>
					<tr><td>Type of Service: {!Service_Line__c}</td></tr>
					<tr><td>Service Code: {!Auth_Service_Code__c}</td></tr>
					<tr><td>TX Setting: {!Service_Location__c}</td></tr>
					<tr><td>Type of Contact: {!Type_of_Contact__c}</td></tr>
				</table>
			</td>
			<td>
				<table>
					<tr><td>Contact: {!Collateral_Contact__c}</td></tr>
					<tr><td><!-- Empty row so that both tables have the same number of rows and align properly. --></td></tr>
					<tr><td>Funding Source: {!Funding_Source__c}</td></tr>
					<tr><td>Billing ID: {!Avatar_ID__pc}</td></tr>
				</table>
			</td>
		</tr>
	</table>
</div>

<!-- Goals Block -->
	<div class="medBold">Purpose of Contact/Goals (<i>Enter exact wording from PCP</i>):</div>
	<div class="med">{!ShortTermGoals}</div>
	<div class="section-divider"></div>
	<hr/>
<!-- End Block -->

<!-- Intervention -->
	<div class="standard-block">
		<div class="medBold">Intervention:</div>
		<div class="med">{!Interventions__c}</div>
	</div>
<!-- End Block -->

<!-- Client Response -->
	<div class="standard-block">
		<div class="medBold">Client Response:</div>
		<div class="med">{!Persons_Response_to_Interventions__c}</div>
	</div>
<!-- End Block -->

<!-- Progress Block -->
	<div class="standard-block">
		<div class="medBold">Progress:</div>
		<div class="med">{!Progress__c}</div>
	</div>
	<div class="section-divider"></div>
<!-- End Block -->

<!-- Notes for Next Visit -->
	<div class="standard-block">
		<div class="medBold">Notes for Next Visit:</div>
		<div class="med">{!Notes_For_Next_Visit__c}</div>
	</div>
	<hr/>
	<div class="section-divider"></div>
<!-- End Block -->

<!-- Therapist and Client Signatures -->
	<!-- Using tables for these signature areas so that the Underline is handled with bottom border -->
	<div>
	<table>
	<tr class="signatureRow"><td class="signatureLabel">Therapist Signature:</td><td class="underline"></td><td class="dateLabel">Date:</td><td class="underline"></td></tr>
	<tr class="signatureRow"><td class="signatureLabel">Client Signature:</td><td class="underline"></td><td class="dateLabel">Date:</td><td class="underline"></td></tr>
	</table>
	</div>
<!-- End Block -->

<!-- This block is always here -->
	<div class="bottom-block">
	<div class="large-section-divider"></div>
	<div class="sm" align="center" style="color:rgb(128,128,128)">Created By:&nbsp;{!CreatedBy.Name},&nbsp;{!CreatedBy.Title}</div>
	<div class="sm" align="center" style="color:rgb(128,128,128)">Created Date:&nbsp;{!Now}</div>
	<div class="sm" align="center" style="color:rgb(128,128,128)">Latest release of form:&nbsp;{!FormDate}</div>
	</div>
<!-- End Block -->
</body>
