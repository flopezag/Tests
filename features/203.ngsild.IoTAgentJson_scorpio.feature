Feature: test tutorial 203.IoT Agents using JSON (Scorpio)

  This is the feature file of the FIWARE Step by Step tutorial for IoT Sensors - NGSI-LD
  url: https://ngsi-ld-tutorials.readthedocs.io/en/latest/iot-agent-json.html
  git-clone: https://github.com/FIWARE/tutorials.IoT-Agent-JSON.git
  git-directory: /tmp/tutorials.IoT-Agent-JSON
  shell-commands: git checkout NGSI-LD ; ./services ${CB_ENVIRONMENT:-scorpio}
  # clean-shell-commands -- docker kill and docker rm since the services stop not working properly and causing problems in second executions.
  clean-shell-commands: ./services stop ; sleep 2 ; docker kill fiware-iot-agent ; docker kill fiware-orion ; docker rm fiware-iot-agent ; docker rm  fiware-orion


  Background:
    Given I set the tutorial 203 LD

  # Request 1 -
  Scenario: Checking the IoTAGent Service health
    When  I send GET HTTP request to "http://localhost:4041/iot/about"
    Then  I receive a HTTP "200" response code from IoTAgent with the body "01.response.json" and exclusions "01.excludes"

  # Request 2, 3 - Provision service and provision device
  Scenario Outline: Provisioning a service Group
    When  I prepare a POST HTTP request for "<description>" to "<url>"
    And   I set header fiware-service to openiot
    And   I set header fiware-servicepath to /
    And   I set the body request as described in <file>
    And   I perform the request
    Then  I receive a HTTP response with status 201 and empty dict
    And   I wait "1" seconds
    Examples:
      | url                                | file            | description         |
      | http://localhost:4041/iot/services | 02.request.json | Provision a service |
      | http://localhost:4041/iot/devices  | 03.request.json | Provision a device  |

  # Request 4 - Set some value to sensor
  Scenario: Sending some simulated data from dummy iot device - Request 4
    When I prepare a POST HTTP request to "http://localhost:7896/iot/json?k=4jggokgpepnvsb2uv4s40d59ov&i=temperature001"
    And   I set header Content-Type to application/json
    And   I set the body request as described in 04.request.json
    And   I perform the request
    Then  I receive a HTTP "201" response code
    And   I wait "1" seconds

  # Request 5
  Scenario: Querying the temperature in the context Broker
    When  I prepare a GET HTTP request to "http://localhost:1026/ngsi-ld/v1/entities/urn:ngsi-ld:Device:temperature001"
    And   I set header NGSILD-Tenant to openiot
    And   I set header NGSILD-Path to /
    And   I set header Accept to application/ld+json
    And   the params equal to "attrs=temperature"
    And   I set header Link to <http://context/ngsi-context.jsonld>; rel="http://www.w3.org/ns/json-ld#context"; type="application/ld+json"
    And   I perform the query request
    Then  I receive a HTTP "200" response code from Scorpio with the body "05.response.json" and exclusions "05.excludes"

  Scenario: Req 6 - Create a new entity sending a measure
    When  I prepare a POST HTTP request to "http://localhost:7896/iot/json?k=4jggokgpepnvsb2uv4s40d59ov&i=motion003"
    And   I set header Content-Type to application/json
    And   I set the body text to {"c": 1}
    And   I perform the request
    Then  I receive a HTTP "201" response code
    And   I wait "1" seconds

  Scenario: Req 7 - Test the value of the new device
    When  I prepare a GET HTTP request to "http://localhost:1026/ngsi-ld/v1/entities/?type=Device"
    And   I set header NGSILD-Tenant to openiot
    And   I set header NGSILD-Path to /
    And   I set header Accept to application/ld+json
    And   I set header Link to <http://context/ngsi-context.jsonld>; rel="http://www.w3.org/ns/json-ld#context"; type="application/ld+json"
    And   I perform the query request
    And   I filter the result with jq '.[]|select(.id == "urn:ngsi-ld:Device:motion003")'
    Then  I receive a HTTP "200" response code from Scorpio with the body "07.response.json" and exclusions "07.excludes"


  Scenario: Req 8 - Provision an actuator - Water001
    When  I prepare a POST HTTP request to "http://localhost:4041/iot/devices"
    And   I set header fiware-servicepath to /
    And   I set header fiware-service to openiot
    And   I set header Content-Type to application/json
    And   I set the body request as described in 08.request.json
    And   I perform the request
    Then  I receive a HTTP "201" response code
    And   I wait "1" seconds

  Scenario: Req 9 - Run a command in Water001 actuator
    When  I prepare a PATCH HTTP request to "http://localhost:4041/ngsi-ld/v1/entities/urn:ngsi-ld:Device:water001/attrs/on"
    And   I set header fiware-servicepath to /
    And   I set header fiware-service to openiot
    And   I set header Content-Type to application/json
    And   I set the body request as described in 09.request.json
    And   I perform the request
    Then  I receive a HTTP "204" response code
    And   I wait "1" seconds

  Scenario: Req 10 -- Read the result of the command by querying the CB
    When  I prepare a GET HTTP request to "http://localhost:1026/ngsi-ld/v1/entities/urn:ngsi-ld:Device:water001"
    And   I set header Accept to application/json
    And   I set header NGSILD-Tenant to openiot
    And   I set header Link to <http://context/ngsi-context.jsonld>; rel="http://www.w3.org/ns/json-ld#context"; type="application/ld+json"
    And   I perform the query request
    Then  I receive a HTTP "200" response code from Scorpio with the body "10.response.json" and exclusions "10.excludes"

  Scenario Outline: Req 11, 12 - Provisioning filling station and tractor
    When  I prepare a POST HTTP request for "<description>" to "http://localhost:4041/iot/devices"
    And   I set header fiware-service to openiot
    And   I set header fiware-servicepath to /
    And   I set header Content-Type to application/json
    And   I set the body request as described in <file>
    And   I perform the request
    Then  I receive a HTTP response with status 201 and empty dict
    Examples:
      | file            | description                 |
      | 11.request.json | Provision a filling station |
      | 12.request.json | Provision a tractor         |


  Scenario: Req 13 - Querying devices
    Given I wait "2" seconds
    When  I prepare a GET HTTP request to "http://localhost:4041/iot/devices"
    And   I set header fiware-service to openiot
    And   I set header fiware-servicepath to /
    And   I perform the query request
    Then  I receive a HTTP "200" response code

  Scenario Outline: Req 14, 15, 16 - Activating things with actuators
    When  I prepare a PATCH HTTP request for "<description>" to "http://localhost:1026/ngsi-ld/v1/entities/urn:ngsi-ld:Device:<device>/attrs/<attr>"
    And   I set header Content-Type to application/json
    And   I set header NGSILD-Tenant to openiot
    And   I set header Link to <http://context/ngsi-context.jsonld>; rel="http://www.w3.org/ns/json-ld#context"; type="application/ld+json"
    And   I set the body request as described in <file>
    And   I perform the request
    Then  I receive a HTTP response with status 204 and empty dict
    Examples:
      | file                         | device     | attr  | description            |
      | activate.things.request.json | water001   | on    | Act. irrigation system |
      | activate.things.request.json | tractor001 | start | Act. tractor           |
      | activate.things.request.json | filling001 | add   | Act. filling system    |

  Scenario: Req 17 - Provisioning a service Group for CRUD operations
    When  I prepare a POST HTTP request to "http://localhost:4041/iot/services"
    And   I set header fiware-service to openiot
    And   I set header fiware-servicepath to /
    And   I set the body request as described in 17.request.scorpio.json
    And   I perform the request
    Then  I receive a HTTP response with status 201 and empty dict

  Scenario Outline: Req 18 and 19 - Read service group details
    When  I prepare a GET HTTP request to "http://localhost:4041/iot/<what>"
    And   I set header fiware-service to openiot
    And   I set header fiware-servicepath to /
    And   I perform the query request
    Then  I receive a HTTP "200" response code from IoTA with the body "<response_file>" and exclusions "<excludes_file>"
    Examples:
      | what                        | response_file    | excludes_file |
      | services?resource=/iot/json | 18.response.json | 18.excludes   |
      | services                    | 19.response.json | 19.excludes   |

  Scenario: Req 20 - Update a service Group
    When  I prepare a PUT HTTP request to "http://localhost:4041/iot/services?resource=/iot/json&apikey=4jggokgpepnvsb2uv4s40d59ov"
    And   I set header fiware-service to openiot
    And   I set header fiware-servicepath to /
    And   I set header Content-Type to application/json
    And   I set the body request as described in 20.request.json
    And   I perform the request
    Then  I receive a HTTP response with status 204 and empty dict

  Scenario: Req 21 - Delete a service Group
    When  I prepare a DELETE HTTP request to "http://localhost:4041/iot/services?resource=/iot/json&apikey=4jggokgpepnvsb2uv4s40d59ov"
    And   I set header fiware-service to openiot
    And   I set header fiware-servicepath to /
    And   I perform the query request
    Then  I receive a HTTP response with status 204 and empty dict

  Scenario: Req 22 - Creating a provisioned device Water002
    When  I prepare a POST HTTP request to "http://localhost:4041/iot/devices"
    And   I set header fiware-service to openiot
    And   I set header fiware-servicepath to /
    And   I set header Content-Type to application/json
    And   I set the body request as described in 22.request.json
    And   I perform the request
    Then  I receive a HTTP response with status 201 and empty dict

  Scenario: Req 23 - Querying devices
    Given I wait "2" seconds
    When  I prepare a GET HTTP request to "http://localhost:4041/iot/devices/water002"
    And   I set header fiware-service to openiot
    And   I set header fiware-servicepath to /
    And   I perform the query request
    Then  I receive a HTTP "200" response code from IoTA with the body "23.response.json" and exclusions "23.excludes"

  Scenario: Req 24 - List all provisioned devices
    Given I wait "2" seconds
    When  I prepare a GET HTTP request to "http://localhost:4041/iot/devices"
    And   I set header fiware-service to openiot
    And   I set header fiware-servicepath to /
    And   I perform the query request
    Then  I receive a HTTP "200" status code response
    And   I validate against jq '.count>=5'

Scenario: Req 25 - Update a provisioned device
    When  I prepare a PUT HTTP request to "http://localhost:4041/iot/devices/water002"
    And   I set header fiware-service to openiot
    And   I set header fiware-servicepath to /
    And   I set header Content-Type to application/json
    And   I set the body request as described in 25.request.json
    And   I perform the request
    Then  I receive a HTTP response with status 204 and empty dict

  Scenario: Req 26 - Delete a provisioned device
    When  I prepare a DELETE HTTP request to "http://localhost:4041/iot/devices/water002"
    And   I set header fiware-service to openiot
    And   I set header fiware-servicepath to /
    And   I perform the query request
    Then  I receive a HTTP response with status 204 and empty dict
