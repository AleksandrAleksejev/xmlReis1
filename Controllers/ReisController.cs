using Microsoft.AspNetCore.Mvc;
using System.Xml;
using System.Xml.Xsl;
using System.IO;

namespace XMLReis.Controllers
{
    public class ReisController : Controller
    {
        public IActionResult Index()
        {
            string xmlPath = Path.Combine(Directory.GetCurrentDirectory(), "App_Data", "reis.xml");
            string xslPath = Path.Combine(Directory.GetCurrentDirectory(), "App_Data", "reis.xsl");

            var xslt = new XslCompiledTransform();
            xslt.Load(xslPath);

            using var xmlReader = XmlReader.Create(xmlPath);
            using var sw = new StringWriter();
            xslt.Transform(xmlReader, null, sw);

            // возвращаем HTML, созданный XSLT
            return Content(sw.ToString(), "text/html");
        }
    }
}
