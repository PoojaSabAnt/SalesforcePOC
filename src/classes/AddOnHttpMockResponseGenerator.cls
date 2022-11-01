/**
 * Mocks the callouts from SF to external Systems.
 * Stores the requests and sends the predefined responses.
 */
@isTest
public class AddOnHttpMockResponseGenerator implements HttpCalloutMock {
  /**
   * The predefined responses
   */
  private List<HttpResponse> responses;

  /**
   * The requests which have been sent by Salesforce
   */
  private List<HttpRequest> requests;

  /**
   * Standard constructor to initialize the object
   */
  public AddOnHttpMockResponseGenerator() {
    this.responses = new List<HttpResponse>();
    this.requests = new List<HttpRequest>();
  }

  /**
   * Constructor to create a response directly for single callouts
   * @param statusCode The http-statusCode to be returned
   * @param status The status-message
   * @param body The content to be returned
   * @param headers Optional header information to be returned
   */
  public AddOnHttpMockResponseGenerator(
    Integer statusCode,
    String status,
    String body,
    Map<String, String> headers
  ) {
    this();
    if (headers == null) {
      this.addResponse(createResponse(statusCode, status, body));
    } else {
      this.addResponse(createResponse(statusCode, status, body, headers));
    }
  }

  /**
   * Adds a response to the queue
   * @param response The predefined response
   */
  public void addResponse(HttpResponse response) {
    this.responses.add(response);
  }

  /**
   * Indicates if there are some responses open which have not been requested.
   * @return Boolean True if at least one response has not been sent. Else false.
   */
  public Boolean hasOpenResponses() {
    return !this.responses.isEmpty();
  }

  /**
   * Gets all collected requests
   * @return List<HttpRequest> The ordered list of HttpRequests
   */
  public List<HttpRequest> getRequests() {
    return this.requests;
  }

  /**
   * Sends the mocked response to the calling SF-Endpoint.
   * This function sends the responses in the same order as they have been added to the queue.
   * Furthermore all requests will be added to an ordered list to be able to run further assertions.
   * This method asserts if more than the predefined callouts are made.
   * @param request The request triggered by SF to the external system.
   * @return HttpReponse The predefined response.
   */
  public HttpResponse respond(HttpRequest request) {
    this.requests.add(request);

    if (!this.responses.isEmpty()) {
      return this.responses.remove(0);
    } else {
      System.assert(false, 'More Callouts than expected');
      return null;
    }
  }

  /**
   * Creates a response for a single callouts
   * @param statusCode The http-statusCode to be returned
   * @param status The status-message
   * @param body The content to be returned
   * @param headers Header information to be returned
   * @return HttpResponse The response for the mocked callout
   */
  public static HttpResponse createResponse(
    Integer statusCode,
    String status,
    String body,
    Map<String, String> headers
  ) {
    HttpResponse response = createResponse(statusCode, status, body);
    for (String key : headers.keySet()) {
      response.setHeader(key, headers.get(key));
    }

    return response;
  }

  /**
   * Creates a response for a single callouts
   * @param statusCode The http-statusCode to be returned
   * @param status The status-message
   * @param body The content to be returned
   * @return HttpResponse The response for the mocked callout
   */
  public static HttpResponse createResponse(
    Integer statusCode,
    String status,
    String body
  ) {
    HttpResponse response = new HttpResponse();
    response.setStatusCode(statusCode);
    response.setStatus(status);
    response.setBody(body);

    return response;
  }
}