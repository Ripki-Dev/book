Feature: DELETE /BookStore/v1/Books

  Background:
    * url baseUrl
    * def headers = read('classpath:examples/resources/request/headers.json')

  Scenario: User delete book after add collection with login
    * def fakerObj =  new faker()
    * def firstName = fakerObj.name().firstName()
    * def lastName = fakerObj.name().lastName()
    * def getInfoUser = call read('classpath:examples/reusable.feature@createUser') {setFirstName: '#(firstName)',setLastName: '#(lastName)'}
    * def getUserAuth = call read('classpath:examples/reusable.feature@getGenerateToken') {setUserName: '#(getInfoUser.variables.userName)',setPassword: '#(getInfoUser.variables.password)'}
    * def getBookIsbn = call read('classpath:examples/reusable.feature@getBooksIsbn')
    * def addBook = call read('classpath:examples/reusable.feature@addBook') {setUserId: '#(getInfoUser.getUserId)',setIsbn: '#(getBookIsbn.getIsbn)',setAuth: '#(getUserAuth.setAuth)'}
    * set headers.Authorization = 'Bearer ' + getUserAuth.setAuth
    Given headers headers
    And path '/BookStore/v1/Books'
    And param UserId = getInfoUser.getUserId
    When method delete
    Then status 204
    * print response

  Scenario: New User delete book without add collection with login
    * def fakerObj =  new faker()
    * def firstName = fakerObj.name().firstName()
    * def lastName = fakerObj.name().lastName()
    * def getInfoUser = call read('classpath:examples/reusable.feature@createUser') {setFirstName: '#(firstName)',setLastName: '#(lastName)'}
    * def getUserAuth = call read('classpath:examples/reusable.feature@getGenerateToken') {setUserName: '#(getInfoUser.variables.userName)',setPassword: '#(getInfoUser.variables.password)'}
    * set headers.Authorization = 'Bearer ' + getUserAuth.setAuth
    Given headers headers
    And path '/BookStore/v1/Books'
    And param UserId = getInfoUser.getUserId
    When method delete
    Then status 204
    * print response
    # Bug: expected failed to delete book before add in collection, actual user can book even user did not add before

  Scenario: User delete book without login
    Given headers headers
    And path '/BookStore/v1/Books'
    And param UserId = 'ed6ab472-146f-4de5-a007-1534caccf2b0'
    When method delete
    Then status 401
    * print response