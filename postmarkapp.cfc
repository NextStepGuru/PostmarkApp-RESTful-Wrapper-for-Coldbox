<cfcomponent hint="Postmark App" output="false" extends="coldbox.system.Plugin" cache="true">

	<cffunction name="init" access="public" returnType="postmarkapp" output="false" hint="Constructor">
		<cfargument name="controller" type="any"/>
		<cfscript>
			// Setup Plugin
			super.init(arguments.controller);
			setPluginName("Postmark App");
			setPluginVersion("1.0");
			setPluginDescription("A REST wrapper to the Postmark App service");
			setPluginAuthor("Jeremy R DeYoung");
			setPluginAuthorURL("http://www.lunarfly.com");

			// Check settings
			if( not settingExists("postmark_api_key") ){
				$throw(message="postmark_api_key setting not defined, please define it.",type="postmarkapp.invalidSettings");
			}

			// Setup API Key
			setAPIKey(getSetting("postmark_api_key"));

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

			var httpService = new http();

			httpService.addParam(type="header",name="X-Postmark-Server-Token",value=getAPIKey());
			httpService.addParam(type="header",name="Accept",value="application/json");
			httpService.addParam(type="header",name="Content-Type",value="application/json");
			httpService.setMethod("post");
		    httpService.setCharset("utf-8");
		    httpService.setUrl("https://api.postmarkapp.com/email");

			httpService.addParam(type="body",value=SerializeJSON(jsonStruct).toString());
			var result = httpService.send().getPrefix();
			var resultStruct = structNew();
			resultStruct.code = ListFirst(result.statuscode," ");
			resultStruct.response = RemoveChars(result.statuscode,1,4);

			return resultStruct;
		</cfscript>
    </cffunction>


	<!--- API Key --->
    <cffunction name="setAPIKey" output="false" access="public" returntype="void" hint="Set the Postmark App credentials">
    	<cfargument name="postmark_api_key" type="string" required="true" default="" hint="The postmark app api key"/>
		<cfscript>
			instance.postmark_api_key = arguments.postmark_api_key;
		</cfscript>
    </cffunction>

    <cffunction name="getAPIKey" output="false" access="public" returntype="string" hint="Set the Postmark App credentials">

		<cfreturn instance.postmark_api_key />
    </cffunction>

	<!--- From --->
    <cffunction name="setFrom" output="false" access="public" returntype="void">
    	<cfargument name="from" type="string" required="false" default="true" />
    	<cfscript>
			instance.from = arguments.from;
		</cfscript>
    </cffunction>

    <cffunction name="getFrom" output="false" access="public" returntype="string">

		<cfreturn instance.from />
    </cffunction>

	<!--- To --->
    <cffunction name="setTo" output="false" access="public" returntype="void">
    	<cfargument name="to" type="string" required="false" default="true" />
    	<cfscript>
			instance.to = arguments.to;
		</cfscript>
    </cffunction>

    <cffunction name="getTo" output="false" access="public" returntype="string">

		<cfreturn instance.to />
    </cffunction>

	<!--- CC --->
    <cffunction name="setCc" output="false" access="public" returntype="void">
    	<cfargument name="cc" type="string" required="false" default="true" />
    	<cfscript>
			instance.cc = arguments.cc;
		</cfscript>
    </cffunction>

    <cffunction name="getCc" output="false" access="public" returntype="string">

		<cfreturn instance.cc />
    </cffunction>

	<!--- BCC --->
    <cffunction name="setBcc" output="false" access="public" returntype="void">
    	<cfargument name="bcc" type="string" required="false" default="true" />
    	<cfscript>
			instance.bcc = arguments.bcc;
		</cfscript>
    </cffunction>

    <cffunction name="getBcc" output="false" access="public" returntype="string">

		<cfreturn instance.bcc />
    </cffunction>

	<!--- Subject --->
    <cffunction name="setSubject" output="false" access="public" returntype="void">
    	<cfargument name="subject" type="string" required="false" default="true" />
    	<cfscript>
			instance.subject = arguments.subject;
		</cfscript>
    </cffunction>

    <cffunction name="getSubject" output="false" access="public" returntype="string">

		<cfreturn instance.subject />
    </cffunction>

	<!--- HTML Body --->
    <cffunction name="setHTMLBody" output="false" access="public" returntype="void">
    	<cfargument name="htmlbody" type="string" required="false" default="true" />
    	<cfscript>
			instance.htmlbody = arguments.htmlbody;
		</cfscript>
    </cffunction>

    <cffunction name="getHTMLBody" output="false" access="public" returntype="string">

		<cfreturn instance.htmlbody />
    </cffunction>

	<!--- Text Body --->
    <cffunction name="setTextBody" output="false" access="public" returntype="void">
    	<cfargument name="textbody" type="string" required="false" default="true" />
    	<cfscript>
			instance.textbody = arguments.textbody;
		</cfscript>
    </cffunction>

    <cffunction name="getTextBody" output="false" access="public" returntype="string">

		<cfreturn instance.textbody />
    </cffunction>

	<!--- Reply To --->
    <cffunction name="setReplyTo" output="false" access="public" returntype="void">
    	<cfargument name="replyto" type="string" required="false" default="true" />
    	<cfscript>
			instance.replyto = arguments.replyto;
		</cfscript>
    </cffunction>

    <cffunction name="getReplyTo" output="false" access="public" returntype="string">

		<cfreturn instance.replyto />
    </cffunction>

</cfcomponent>