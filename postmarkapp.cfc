<cfcomponent hint="Postmark App" output="false" extends="coldbox.system.Plugin" cache="true" accessors="true">

	<!--- API Setup --->
	<cfproperty name="APIKey" default="" type="string" hint="the Postmark App credentials" required="false">
	<!--- Addressing --->
	<cfproperty name="From" default="" type="string" hint="the from email address" required="false">
	<cfproperty name="To" default="" type="string" hint="the to email addresses" required="false">
	<cfproperty name="CC" default="" type="string" hint="a list of cc email addresses" required="false">
	<cfproperty name="BCC" default="" type="string" hint="a list of bcc from email addresses" required="false">
	<cfproperty name="ReplyTo" default="" type="string" hint="the Reply To Email Address" required="false">
	<!--- Message Setup --->
	<cfproperty name="Subject" default="" type="string" hint="the email subject line" required="false">
	<cfproperty name="HTMLBody" default="" type="string" hint="HTML Message Body" required="false">
	<cfproperty name="TextBody" default="" type="string" hint="Plain Text Message Body" required="false">

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

			if(len(this.getTO())){
				jsonStruct.to = getTo();
			}
			else
			{
				$throw(message="TO is a Required Field",type="postmarkapp.requiredField");
			}
			if(len(this.getFrom())){
				jsonStruct.from = getFrom();
			}
			else
			{
				$throw(message="From is a Required Field",type="postmarkapp.requiredField");
			}
			if(Len(this.getCC())){
				jsonStruct.cc = getCC();
			}
			if(len(this.getBCC())){
				jsonStruct.bcc = getBCC();
			}
			if(len(this.getSubject())){
				jsonStruct.subject = getSubject();
			}
			else
			{
				$throw(message="Subject is a Required Field",type="postmarkapp.requiredField");
			}
			if(len(this.getHTMLBody())){
				jsonStruct.HtmlBody = getHTMLBody();
			}
			if(len(this.getTextBody())){
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
				httpService.addParam(type="body",value=toString(SerializeJSON(arguments.sendJSON)));
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
