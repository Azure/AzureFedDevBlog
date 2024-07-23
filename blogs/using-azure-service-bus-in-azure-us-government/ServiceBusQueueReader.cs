using System;
using System.Threading.Tasks;
using Azure.Messaging.ServiceBus;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace ServiceBusQueueFunc
{
    public class ServiceBusQueueReader
    {
        private readonly ILogger<ServiceBusQueueReader> _logger;

        public ServiceBusQueueReader(ILogger<ServiceBusQueueReader> logger)
        {
            _logger = logger;
        }

        [Function(nameof(ServiceBusQueueReader))]
        public async Task Run(
            [ServiceBusTrigger("testq", Connection = "ServiceBusConnection")]
            ServiceBusReceivedMessage message,
            ServiceBusMessageActions messageActions)
        {
            // Log the message
            _logger.LogInformation("Message ID: {id}", message.MessageId);
            _logger.LogInformation("Message Body: {body}", message.Body);
            _logger.LogInformation("Message Content-Type: {contentType}", message.ContentType);

            // do something with the message

            // Complete the message
            await messageActions.CompleteMessageAsync(message);
        }
    }
}
