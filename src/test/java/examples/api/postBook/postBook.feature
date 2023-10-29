Feature: POST /BookStore/v1/Books

  Background:
    * url baseUrl
    * def variables = read('classpath:examples/resources/request/variables-UserBooks.json')
    * def headers = read('classpath:examples/resources/request/headers.json')
    * def getErrMsg = read('classpath:examples/resources/helper/getErrMsg.json')
    * def sleep = function(millis){ java.lang.Thread.sleep(millis) }
    * sleep(1000)

  Scenario: New User read book with login
    * def fakerObj =  new faker()
    * def firstName = fakerObj.name().firstName()
    * def lastName = fakerObj.name().lastName()
    * def getInfoUser = call read('classpath:examples/reusable.feature@createUser') {setFirstName: '#(firstName)',setLastName: '#(lastName)'}
    * def getUserAuth = call read('classpath:examples/reusable.feature@getGenerateToken') {setUserName: '#(getInfoUser.variables.userName)',setPassword: '#(getInfoUser.variables.password)'}
    * def getBookIsbn = call read('classpath:examples/reusable.feature@getBooksIsbn')
    * set variables.userId = getInfoUser.getUserId
    * set variables.collectionOfIsbns[0].isbn = getBookIsbn.getIsbn
    * print getUserAuth.setAuth
    * set headers.Authorization = 'Bearer ' + getUserAuth.setAuth
    Given headers headers
    And path '/BookStore/v1/Books'
    And request variables
    When method post
    Then status 201
    * print responseTime
    * print response
    * def responseType = read('classpath:examples/resources/response/response-book.json')
    And match response == responseType
    * def responseTypeList = read('classpath:examples/resources/response/response-bookList.json')
    And match each response.books == responseTypeList
    * if (responseTime > 1000) karate.fail('Response Time more than 1000ms, actual: ' + responseTime)

  Scenario: User read book without login
    * set variables.userId = "543ed817-d5e3-46d6-9155-873fca765a94"
    * set variables.collectionOfIsbns[0].isbn = "9781449325862"
    Given headers headers
    And path '/BookStore/v1/Books'
    And request variables
    When method post
    Then status 401
    * print response
    And match response.code == getErrMsg.errCode_1200
    And match response.message == getErrMsg.err_usr_auth

 Scenario: User read book with another user token
    * def getUserAuth = call read('classpath:examples/reusable.feature@getGenerateToken') {setUserName: 'Remona',setPassword: 'Thompson@123Remona'}
    * set variables.userId = "ed6ab472-146f-4de5-a007-1534caccf2b0"
    * set variables.collectionOfIsbns[0].isbn = "9781449325862"
    * set headers.Authorization = 'Bearer ' + getUserAuth.setAuth
    Given headers headers
    And path '/BookStore/v1/Books'
    And request variables
    When method post
    Then status 401
    * print response
    # Bug: expected failed to read book by another user token & response 401, actual user can read book by another user token & response 200

  Scenario: Existing User already have book with login
    * def getUserAuth = call read('classpath:examples/reusable.feature@getGenerateToken') {setUserName: 'Lionel',setPassword: 'Schuster@123Lionel'}
    * set variables.userId = "543ed817-d5e3-46d6-9155-873fca765a94"
    * set variables.collectionOfIsbns[0].isbn = "9781449325862"
    * print getUserAuth.setAuth
    * set headers.Authorization = 'Bearer ' + getUserAuth.setAuth
    Given headers headers
    And path '/BookStore/v1/Books'
    And request variables
    When method post
    Then status 400
    * print response
    And match response.code == getErrMsg.errCode_1210
    And match response.message == getErrMsg.err_usr_have_isbn

  Scenario: Existing User read book with login
    * def getUserAuth = call read('classpath:examples/reusable.feature@getGenerateToken') {setUserName: 'Remona',setPassword: 'Thompson@123Remona'}
    * def getBookIsbn = call read('classpath:examples/reusable.feature@getBooksIsbn')
    * set variables.userId = "ed6ab472-146f-4de5-a007-1534caccf2b0"
    * set headers.Authorization = 'Bearer ' + getUserAuth.setAuth
    * set variables.collectionOfIsbns[0].isbn = getBookIsbn.getIsbn
    Given headers headers
    And path '/BookStore/v1/Books'
    And request variables
    When method post
    Then status 201
    * print response
    * def responseType = read('classpath:examples/resources/response/response-book.json')
    And match response == responseType
    * def responseTypeList = read('classpath:examples/resources/response/response-bookList.json')
    And match each response.books == responseTypeList
    * def deleteUserBooks = call read('classpath:examples/reusable.feature@deleteBooks') {userAuth: '#(getUserAuth.setAuth)', setUserId: 'ed6ab472-146f-4de5-a007-1534caccf2b0'}  

  Scenario Outline: User with login when <case>
    * def getUserAuth = call read('classpath:examples/reusable.feature@getGenerateToken') {setUserName: 'Lionel',setPassword: 'Schuster@123Lionel'}
    * set variables.userId = <setUserId>
    * set variables.collectionOfIsbns[0].isbn = "9781449325862"
    * print getUserAuth.setAuth
    * set headers.Authorization = 'Bearer ' + getUserAuth.setAuth
    Given headers headers
    And path '/BookStore/v1/Books'
    And request variables
    When method post
    Then status 401
    * print response
    And match response.code == getErrMsg.errCode_1207
    And match response.message == getErrMsg.err_usr_id
    Examples:
    | setUserId                             | case           |
    | ''                                    | userId Blank   |
    | null                                  | userId null    |
    | 'xxxxxxx-146f-4de5-a007-1534caccf2b0' | userId invalid |

  Scenario Outline: User with login when <case>
    * def getUserAuth = call read('classpath:examples/reusable.feature@getGenerateToken') {setUserName: 'Remona',setPassword: 'Thompson@123Remona'}
    * set variables.userId = "ed6ab472-146f-4de5-a007-1534caccf2b0"
    * set headers.Authorization = 'Bearer ' + getUserAuth.setAuth
    * set variables.collectionOfIsbns[0].isbn = <isbn>
    Given headers headers
    And path '/BookStore/v1/Books'
    And request variables
    When method post
    Then assert (responseStatus == 400) || (responseStatus == 401)
    * print response
    * assert (response.code == getErrMsg.errCode_1205) || (response.code == getErrMsg.errCode_1200)
    * assert (response.message == getErrMsg.err_isbn_not_avail) || (response.message == getErrMsg.err_usr_auth)
    # Minor Bug from BE: response did not consistent 
    Examples:
    | isbn      | case |
    | ''        | isbn Blank |
    | null      | isbn null |
    | '1928381' | isbn invalid |