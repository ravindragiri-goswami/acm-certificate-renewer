using Amazon.CertificateManager;
using Amazon.CertificateManager.Model;

namespace ACM.Certificate.Renewer.Lambda.Wrappers
{
    public class AmazonCertificateManagerClientWrapper : IAmazonCertificateManagerClientWrapper
    {
        public async Task<ListCertificatesResponse> ListCertificatesAsync()
        {
            ListCertificatesResponse listCertificatesResponse = default;

            using (var _client = new AmazonCertificateManagerClient())
            {
                var request = new ListCertificatesRequest();
                listCertificatesResponse = await _client.ListCertificatesAsync(request);
            }

            return listCertificatesResponse;
        }

        public async Task<GetCertificateResponse> GetCertificateAsync(string certificateArn)
        {
            GetCertificateResponse getCertificateResponse = default;

            using (var _client = new AmazonCertificateManagerClient())
            {
                var request = new ListCertificatesRequest();
                getCertificateResponse = await _client.GetCertificateAsync(certificateArn);
            }

            return getCertificateResponse;
        }

        public async Task<RenewCertificateResponse> RenewCertificateAsync(RenewCertificateRequest renewCertificateRequest)
        {
            RenewCertificateResponse renewCertificateResponse = default;

            using (var _client = new AmazonCertificateManagerClient())
            {
                renewCertificateResponse = await _client.RenewCertificateAsync(renewCertificateRequest);
            }

            return renewCertificateResponse;
        }
    }
}
