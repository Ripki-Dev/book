@ignore
Feature: reusable feature

    Background:
        * url baseUrl

    @createUser
    Scenario: create new user with faker
    * def fakerObj =  new faker()
    * def randNumber = fakerObj.number().digits(3)
    * def randNumberSecond = fakerObj.number().digits(3)
    * def variables = read('classpath:examples/resources/request/variables-GenerateToken.json')
    * set variables.userName = randNumber + setFirstName
    * set variables.password = setLastName + "@" + randNumberSecond + setFirstName
    Given path '/Account/v1/User'
    And request variables
    When method post
    Then status 201
    * print response
    * def getUserId = response.userID
    * def responseType = read('classpath:examples/resources/response/response-CreateUser.json')
    And retry until response == responseType

    @getBooksIsbn
    Scenario: get all book isbn
    Given path '/BookStore/v1/Books'
    When method get
    Then status 200
    * print response
    * def arrayLength = response.books.length - 1
    * def getRan = read('classpath:examples/resources/helper/getRandomArray.js')
    * def ranInt = getRan(arrayLength)
    * def getIsbn = response.books[ranInt].isbn
    * def responseType = read('classpath:examples/resources/response/response-BookIsbn.json')
    And retry until response == responseType
    * def responseTypeList = read('classpath:examples/resources/response/response-BookIsbnList.json')
    And match each response.books == responseTypeList
    
    @getGenerateToken
    Scenario: get generate user token
    * def variables = read('classpath:examples/resources/request/variables-GenerateToken.json')
    * set variables.userName = setUserName
    * set variables.password = setPassword
    Given path '/Account/v1/GenerateToken'
    And request variables
    When method post
    Then status 200
    * print response
    * def setAuth = response.token
    * def responseType = read('classpath:examples/resources/response/response-GenerateToken.json')
    And retry until response == responseType

    @deleteBooks
    Scenario: Delete books by isbn
    * def headers = read('classpath:examples/resources/request/headers.json')
    * set headers.Authorization = 'Bearer ' + userAuth
    Given headers headers
    And path '/BookStore/v1/Books'
    And param UserId = setUserId
    When method delete
    Then status 204
    * print response

    @addBook
    Scenario: add book in collection
    * def variables = read('classpath:examples/resources/request/variables-UserBooks.json')
    * def headers = read('classpath:examples/resources/request/headers.json')
    * set variables.userId = setUserId
    * set variables.collectionOfIsbns[0].isbn = setIsbn
    * print getUserAuth.setAuth
    * set headers.Authorization = 'Bearer ' + setAuth
    Given headers headers
    And path '/BookStore/v1/Books'
    And request variables
    When method post
    Then status 201
    * def responseType = read('classpath:examples/resources/response/response-book.json')
    And retry until response == responseType
    * def responseTypeList = read('classpath:examples/resources/response/response-bookList.json')
    And match each response.books == responseTypeList
