using ACM.Certificate.Renewer.Lambda.DTOs;
using ACM.Certificate.Renewer.Lambda.Wrappers;
using Amazon.CertificateManager;
using Amazon.CertificateManager.Model;
using Amazon.Lambda.Annotations;
using Amazon.Lambda.Core;
using Amazon.Runtime;
using Newtonsoft.Json;
using System.Net;

// Assembly attribute to enable the Lambda function's JSON input to be converted into a .NET class.
[assembly: LambdaSerializer(typeof(Amazon.Lambda.Serialization.SystemTextJson.DefaultLambdaJsonSerializer))]

namespace ACM.Certificate.Renewer.Lambda;

public class Function
{
    private readonly IAmazonCertificateManagerClientWrapper _client;
    public Function(IAmazonCertificateManagerClientWrapper client)
    {
        this._client = client;
    }

    /// <summary>
    /// A simple function that takes a string and does a ToUpper
    /// </summary>
    /// <param name="region"></param>
    /// <param name="context"></param>
    /// <returns></returns>
    [LambdaFunction]
    public async Task<List<RenewCertificateResponseDTO>> FunctionHandler(ILambdaContext context)
    {
        context.Logger.LogInformation($"Begin call FunctionHandler.");

        List<RenewCertificateResponseDTO> renewCertificateResponses = new();

        try
        {
            renewCertificateResponses = await RenewCertificatesAsync(context);
        }
        catch (Exception e)
        {
            context.Logger.LogError($"An error occured while processing your request. {e}");
            throw;
        }

        context.Logger.LogInformation($"End call FunctionHandler.");

        return renewCertificateResponses;
    }

    #region Renewal

    public async Task<List<RenewCertificateResponseDTO>> RenewCertificatesAsync(ILambdaContext context)
    {
        List<RenewCertificateResponseDTO> renewCertificateResponses = new();

        var listCertificatesResponse = await ListCertificatesResponseAsync(context);
        context.Logger.LogInformation($"Total {listCertificatesResponse.CertificateSummaryList.Count} certificates found.");

        if (listCertificatesResponse.CertificateSummaryList.Count > 0)
        {
            var certificatesCloseToExpire = FilterCertificateEligibileForRenew(listCertificatesResponse);
            context.Logger.LogInformation($"Total {listCertificatesResponse.CertificateSummaryList.Count} certificates close to expire found.");

            if (certificatesCloseToExpire?.Count > 0)
            {
                foreach (var certificate in certificatesCloseToExpire)
                {
                    context.Logger.LogInformation($"Certificate Domain: {certificate.DomainName}");
                    context.Logger.LogInformation($"Certificate ARN: {certificate.CertificateArn}\n");

                    var renewCertificateResponse = await RenewCertificateAsync(context, certificate.CertificateArn);
                    context.Logger.LogInformation($"Renew Certificate Response: {JsonConvert.SerializeObject(renewCertificateResponse)}\n");

                    renewCertificateResponses.Add(renewCertificateResponse);
                }
            }
        }

        return renewCertificateResponses;
    }

    private static List<CertificateSummary> FilterCertificateEligibileForRenew(ListCertificatesResponse listCertificatesResponse)
    {
        var certificatesCloseToExpire = (from certificate in listCertificatesResponse.CertificateSummaryList
                                         where (certificate.RenewalEligibility == RenewalEligibility.ELIGIBLE)
                                         select certificate).ToList();

        return certificatesCloseToExpire;
    }

    public async Task<RenewCertificateResponseDTO> RenewCertificateAsync(ILambdaContext context, string certificateArn)
    {
        RenewCertificateResponseDTO renewCertificateResponseDTO = default;

        context.Logger.LogInformation("RenewCertificateAsync Method Begins");

        var renewCertificateRequest = new RenewCertificateRequest() { CertificateArn = certificateArn };
        try
        {
            var renewCertificateResponse = await _client.RenewCertificateAsync(renewCertificateRequest);

            string renewStatus = (renewCertificateResponse.HttpStatusCode == HttpStatusCode.OK) ? "successful" : "failed";
            context.Logger.LogInformation($"Renew Certificate is {renewStatus} for certificate: {certificateArn}");
            renewCertificateResponseDTO = new RenewCertificateResponseDTO()
            {
                CertificateArn = certificateArn,
                HttpStatusCode = renewCertificateResponse.HttpStatusCode
            };
        }
        catch (InvalidArnException ex)
        {
            context.Logger.LogError($"The requested Amazon Resource Name (ARN) does not refer to an existing resource. For certificate: {certificateArn}. {ex}");
        }
        catch (ResourceNotFoundException ex)
        {
            context.Logger.LogError($"The specified certificate cannot be found in the caller's account or the caller's account cannot be found.. For certificate: {certificateArn}. {ex}");
        }
        catch (AmazonServiceException ex)
        {
            if (ex.ErrorCode == "ValidationException")
            {
                context.Logger.LogError($"An AmazonServiceException occured while renewing certificate: {certificateArn}. {ex}");
                renewCertificateResponseDTO = new RenewCertificateResponseDTO()
                {
                    CertificateArn = certificateArn,
                    HttpStatusCode = HttpStatusCode.UnprocessableEntity,
                    StatusText = ex.Message
                };
            }
            else
            {
                context.Logger.LogInformation($"An AmazonServiceException occured while renewing certificate: {certificateArn}. {ex}");
            }
        }
        catch (Exception ex)
        {
            context.Logger.LogError($"An Exception occured while renewing certificate: {certificateArn}. {ex}");
        }

        context.Logger.LogInformation("RenewCertificateAsync Method Ends");

        return renewCertificateResponseDTO;
    }

    #endregion Renewal

    #region Retriever

    /// <summary>
    /// Retrieves a list of the certificates defined in this Region.
    /// </summary>
    /// <param name="client">The ACM client object passed to the
    /// ListCertificateResAsync method call.</param>
    /// <param name="request"></param>
    /// <returns>The ListCertificatesResponse.</returns>
    public async Task<ListCertificatesResponse> ListCertificatesResponseAsync(ILambdaContext context)
    {
        ListCertificatesResponse response = default;
        try
        {
            response = await _client.ListCertificatesAsync();
        }
        catch (Exception ex)
        {
            context.Logger.LogError("Error occurred: " + ex);
        }

        return response;
    }

    #endregion Retriever

}
