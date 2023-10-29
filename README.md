# Karate Template

Refer to the [Getting Started Guide](https://github.com/karatelabs/karate/wiki/Get-Started:-Maven-and-Gradle#github-template) for instructions.

## Project Structure

```
<Project Path>
...examples -> parent folder
...karate-config.js -> config for karate

......api -> folder for testing script
.........deleeteBook -> test suite for DELETE /BookStore/v1/Books
.........postBook -> test suite for POST /BookStore/v1/Books

......resources -> folder for resource of testing
.........helper -> folder for helper function
.........request -> folder for request body
.........request -> folder for response body
```

## Requirements

- Java 11 or newer
- Maven

## Running tests

Running all tests:

```
mvn clean test
```

## Report tests

Location:

```
target/karate-reports/karate-summary.html
```
