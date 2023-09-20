using ACM.Certificate.Renewer.Lambda.Wrappers;
using Amazon.Lambda.Annotations;
using Microsoft.Extensions.DependencyInjection;

namespace ACM.Certificate.Renewer.Lambda
{
    [LambdaStartup]
    public class Startup
    {
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddScoped<IAmazonCertificateManagerClientWrapper, AmazonCertificateManagerClientWrapper>();
        }
    }
}
