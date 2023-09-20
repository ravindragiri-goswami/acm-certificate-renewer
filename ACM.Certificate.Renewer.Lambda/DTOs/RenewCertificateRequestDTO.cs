namespace ACM.Certificate.Renewer.Lambda.DTOs
{
    public class RenewCertificateRequestDTO
    {
        public string Region { get; set; }
        public string CertificateArn { get; set; }
    }
}
