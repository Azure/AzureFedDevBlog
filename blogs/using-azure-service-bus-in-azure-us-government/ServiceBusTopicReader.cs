using System;
using System.Threading.Tasks;
using Azure.Messaging.ServiceBus;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace ServiceBusQueueFunc
{
    public class ServiceBusTopicReader
    {
        private readonly ILogger<ServiceBusTopicReader> _logger;

        public ServiceBusTopicReader(ILogger<ServiceBusTopicReader> logger)
        {
            _logger = logger;
        }

        [Function(nameof(ServiceBusTopicReader))]
        public async Task Run(
            [ServiceBusTrigger("testTopic", "testSubscription", Connection = "ServiceBusConnection")]
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
