using Amazon.CertificateManager.Model;

namespace ACM.Certificate.Renewer.Lambda.Wrappers
{
    public interface IAmazonCertificateManagerClientWrapper
    {
        Task<ListCertificatesResponse> ListCertificatesAsync();
        Task<GetCertificateResponse> GetCertificateAsync(string certificateArn);
        Task<RenewCertificateResponse> RenewCertificateAsync(RenewCertificateRequest renewCertificateRequest);
    }
}
