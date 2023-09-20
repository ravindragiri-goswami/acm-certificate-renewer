using System.Net;

namespace ACM.Certificate.Renewer.Lambda.DTOs
{
    public class RenewCertificateResponseDTO
    {
        public string CertificateArn { get; set; }
        public HttpStatusCode HttpStatusCode { get; set; }
        public string StatusText { get; set; }

        public override string ToString()
        {
            return $"CertificateArn: '{CertificateArn}', HttpStatusCode: '{HttpStatusCode}'";
        }
    }
}
