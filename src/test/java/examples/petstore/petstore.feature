Feature:

  Background:
    * url 'https://petstore.swagger.io/v2'

  # https://petstore.swagger.io/v2/store/inventory GET
  Scenario: Get Request
    Given url "https://petstore.swagger.io/v2"
    And path "/store/inventory"
    When method Get

    # https://petstore.swagger.io/v2/pet/findByStatus?status=pending GET
  Scenario: Get Request for Query Parameter
    Given url "https://petstore.swagger.io/v2"
    And path 'pet/findByStatus'
    And param status = 'pending'
    When method Get

    # https://https://petstore.swagger.io/v2/pet POST
  Scenario: Post Request With Header and Status
    * def requestBody =
    """
    {
      "id" : 0,
      "category" : { "id":0, "name": "string" },
      "name" : "doggie",
      "photoUrls" : ["string"],
      "tags" : [ { "id" : 0, "name" : "string" } ],
      "status" : "available"
    }
    """

    # Given url 'https://petstore.swagger.io/v2'
    And path '/pet'
    And request requestBody
    And header content-type = 'application/json'
    When method Post
    Then status 200

    Scenario: Match Operation
      And path '/store/inventory'
      When method Get
      Then status 200
      Then match $.sold == 2

    Scenario: Get Assert
      And path '/store/inventory'
      When method Get
      Then status 200
      Then assert responseTime < 1000

    Scenario: Read File
      * def requestBody = read('example.json')
      * requestBody.name = 'doggies'
      And path '/pet'
      And request requestBody
      When method Post


    Scenario: Call Function
      * def requestBody = read('example.json')
      * requestBody.name = 'doggies'
      * def myJsFunction =

      """
      function(arg){
        return arg.length
      }
      """

      * def postedLength = call myJsFunction requestBody.name

      And path '/pet'
      And request requestBody
      When method Post
      Then status 200

      * def responseLength = call myJsFunction $.name

      Then match postedLength == responseLength

    @POST @Create
    Scenario: Posted Pet For Next Scenario

      * def requestBody = read('example.json')
      * requestBody.category.id = 01
      * requestBody.category.name = 'dog'
      * requestBody.name = 'duman'
      * requestBody.status = 'sold'

      Given path '/pet'
      And request requestBody
      And header content-type = 'application/json'
      When method POST
      Then status 200

    @GET
    Scenario: Get Posted Pet
      * def petPostScenario = read('petstore.feature@Create')
      * def result = call petPostScenario
      * def petId = result.response.id
      * def petName = result.requestBody.name

      Given path '/pet/', petId
      When method Get
      Then status 200
      Then match $.name == petName

    Scenario Outline: DataTables
      Given path 'pet/findByStatus'
      And param status = <status>
      When method GET
      Then status 200
      Then print response
      Examples:
        |status       |
        |'pending'    |
        |'sold'       |
        |'available'  |