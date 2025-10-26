using System;
using System.IO;
using System.Xml;
using System.Xml.Xsl;

namespace xmlReis1
{
    public partial class Reis : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string xmlPath = Server.MapPath("~/App_Data/reis.xml");
            string xslPath = Server.MapPath("~/App_Data/reis.xsl");

            var xslt = new XslCompiledTransform();
            xslt.Load(xslPath);

            using (var sw = new StringWriter())
            using (var xmlReader = XmlReader.Create(xmlPath))
            {
                xslt.Transform(xmlReader, null, sw);
                ltlOutput.Text = sw.ToString();
            }
        }
    }
}
