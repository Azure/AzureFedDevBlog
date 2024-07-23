using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Azure.Messaging.ServiceBus;
using Azure.Identity;
using System.Configuration;

namespace ServiceBusQueueFunc
{
    public class ServiceBusQueueWriter
    {
        private readonly ILogger<ServiceBusQueueWriter> _logger;

        public ServiceBusQueueWriter(ILogger<ServiceBusQueueWriter> logger)
        {
            _logger = logger;
        }

        [Function("ServiceBusQueueWriter")]
        public async Task<IActionResult> Run([HttpTrigger(AuthorizationLevel.Function, "get", "post")] HttpRequest req)
        {
            string? fullyQualifiedNamespace = Environment.GetEnvironmentVariable("ServiceBusConnection__fullyQualifiedNamespace");
            string? queueName = Environment.GetEnvironmentVariable("ServiceBusQueueName");

            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            if (fullyQualifiedNamespace == null || queueName == null || requestBody == null)
            {
                return new BadRequestObjectResult("There was an error reading the request body or the environment variables are not set.");
            }
            try
            {
                DefaultAzureCredentialOptions options = new DefaultAzureCredentialOptions();
                options.AuthorityHost = AzureAuthorityHosts.AzureGovernment;

                await using var client = new ServiceBusClient(fullyQualifiedNamespace, new DefaultAzureCredential(options));

                var sender = client.CreateSender(queueName);
                await sender.SendMessageAsync(new ServiceBusMessage(requestBody));


                _logger.LogInformation("C# HTTP trigger function sent a message to Service Bus.");
                return new OkObjectResult("Message sent to Service Bus.");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "An error occurred in the function.");
                return new StatusCodeResult(StatusCodes.Status500InternalServerError);
            }
        }
    }
}
