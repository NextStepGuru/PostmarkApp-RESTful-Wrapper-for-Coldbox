<cfcomponent hint="Postmark App" output="false" cache="true" accessors="true">

	<!--- API Setup --->
	<cfproperty name="APIKey" default="" type="string" hint="the Postmark App credentials" required="true">
	<!--- Addressing --->
	<cfproperty name="From" default="" type="string" hint="the from email address" required="true">
	<cfproperty name="To" default="" type="string" hint="the to email addresses" required="true">
	<cfproperty name="CC" default="" type="string" hint="a list of cc email addresses" required="true">
	<cfproperty name="BCC" default="" type="string" hint="a list of bcc from email addresses" required="true">
	<cfproperty name="ReplyTo" default="" type="string" hint="the Reply To Email Address" required="true">
	<!--- Message Setup --->
	<cfproperty name="Subject" default="" type="string" hint="the email subject line" required="true">
	<cfproperty name="HTMLBody" default="" type="string" hint="HTML Message Body" required="true">
	<cfproperty name="TestBody" default="" type="string" hint="Plain Text Message Body" required="true">

	<cffunction name="init" access="public" returnType="postmarkapp" output="false" hint="Constructor">
		<cfscript>
			// The lines below are only required if you use ColdBox
			setPluginName("Postmark App");
			setPluginVersion("1.0.1");
			setPluginDescription("A REST wrapper to the Postmark App service");
			setPluginAuthor("Jeremy R DeYoung");
			setPluginAuthorURL("http://www.lunarfly.com/lft/plugins/postmarkapp");
			return this;
		</cfscript>
	</cffunction>

    <cffunction name="send" output="false" access="public" returntype="any">
		<cfscript>
			var jsonStruct = StructNew();
			if(structKeyExists(instance,"to")){
				jsonStruct.to = getTo();
			}
			else
			{
				$throw(message="TO is a Required Field",type="postmarkapp.requiredField");
			}
			if(structKeyExists(instance,"from")){
				jsonStruct.from = getFrom();
			}
			else
			{
				$throw(message="From is a Required Field",type="postmarkapp.requiredField");
			}
			if(structKeyExists(instance,"cc")){
				jsonStruct.cc = getCC();
			}
			if(structKeyExists(instance,"bcc")){
				jsonStruct.bcc = getBCC();
			}
			if(structKeyExists(instance,"subject")){
				jsonStruct.subject = getSubject();
			}
			else
			{
				$throw(message="Subject is a Required Field",type="postmarkapp.requiredField");
			}
			if(structKeyExists(instance,"HtmlBody")){
				jsonStruct.HtmlBody = getHTMLBody();
			}
			if(structKeyExists(instance,"TextBody")){
				jsonStruct.TextBody = getTextBody();
			}

			resultStruct = sendAndReceive(httpMethod="post",httpURL='https://api.postmarkapp.com/email',sendJSON=jsonStruct);

			return resultStruct;
		</cfscript>
    </cffunction>

    <cffunction name="getDeliveryStats" output="false" access="public" returntype="any">
		<cfscript>

			resultStruct = sendAndReceive(httpMethod="get",httpURL='https://api.postmarkapp.com/deliverystats');

			return resultStruct;
		</cfscript>
    </cffunction>

    <cffunction name="getBounces" output="false" access="public" returntype="any">
		<cfscript>
			var requiredFields = "";
			var optionalFields = "bounceType,inactive,emailFilter,offset,tag,count";

			var qryString = structNew();

			if(StructKeyExists(arguments,"bounceType"))
			{
				qryString.type = arguments.bounceType;
			}
			if(StructKeyExists(arguments,"inactive"))
			{
				qryString.inactive = arguments.inactive;
			}
			if(StructKeyExists(arguments,"emailFilter"))
			{
				qryString.emailFilter = arguments.emailFilter;
			}
			if(StructKeyExists(arguments,"offset"))
			{
				qryString.offset = arguments.offset;
			}
			if(StructKeyExists(arguments,"count"))
			{
				qryString.count = arguments.count;
			}

			resultStruct = sendAndReceive(httpMethod="get",httpURL='https://api.postmarkapp.com/bounces',httpQueryString=qryString);

			return resultStruct;
		</cfscript>
    </cffunction>

	<!--- Private Functions --->
    <cffunction name="sendAndReceive" output="false" access="private" returntype="any">
		<cfscript>
			var httpService = new http();
			var argumentsList = StructKeyList(arguments);
			var queryString = "";

			if(structKeyExists(arguments,'sendJSON'))
			{
				httpService.addParam(type="body",value=SerializeJSON(arguments.json).toString());
			}
			httpService.addParam(type="header",name="X-Postmark-Server-Token",value=this.getAPIKey());
			httpService.addParam(type="header",name="Accept",value="application/json");
			httpService.addParam(type="header",name="Content-Type",value="application/json");

			httpService.setMethod(arguments.httpMethod);
		    httpService.setCharset("utf-8");
			if(structKeyExists(arguments,"httpQueryString"))
			{
				var queryList = StructKeyList(arguments.httpQueryString);
				for(var i=1;i <= ListLen(queryList);i++)
				{
					queryString = queryString & "#lcase(listGetAt(queryList,i))#=" & arguments.httpQueryString[listGetAt(queryList,i)] & "&";
				}
			    httpService.setUrl(arguments.httpURL & "?" & queryString);
			}
			else
			{
			    httpService.setUrl(arguments.httpURL);
			}
			var result = httpService.send().getPrefix();

			var resultStruct      = structNew();
			resultStruct.code     = ListFirst(result.statuscode," ");
			resultStruct.status   = RemoveChars(result.statuscode,1,4);
			if(IsJSON(result.fileContent))
			{
				resultStruct.response = DeserializeJSON(result.fileContent);
			}
			else
			{
				resultStruct.response = toString(result.fileContent);
			}

			return resultStruct;
		</cfscript>
    </cffunction>

</cfcomponent>
