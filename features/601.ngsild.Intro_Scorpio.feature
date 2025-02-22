Feature: test tutorial 601 Introduction to Linked Data (Scorpio)

#
#   Parameters to be considered (aka INTERESTING_FEATURES_STRINGS)
#
    url: https://fiware-tutorials.readthedocs.io/en/latest/linked-data.html
    git-clone: https://github.com/FIWARE/tutorials.Linked-Data.git
    git-directory: /tmp/tutorials.Linked-Data-Intro

    shell-commands: git checkout NGSI-v2 ; ./services create; ./services scorpio
    clean-shell-commands: ./services stop


    Background:
        Given I set the tutorial 601

#
#   Request 0
#       Note: The expected body in the Tutorial has older values with respect to the current Scorpio version.
#             Besides, the expected answer is structured while the current answer is not.
#
    Scenario: [1] Checking the Scorpio service health
        When  I prepare a GET HTTP request to "http://localhost:1026/ngsi-ld/v1/info/sourceIdentity"
        And   I perform the query request
        Then  I receive a HTTP "200" response code from Scorpio with the body equal to "response601-01.json"

#
#   Request 2, 3: Creating an Entity
#
    Scenario Outline: [2, 3] Creating an Entity
      When I prepare a POST HTTP request for "creating an entity" to "http://localhost:1026/ngsi-ld/v1/entities"
      And  I set header Content-Type to application/ld+json
      And  I set the body request as described in <file>
      And  I perform the request
      Then I receive a HTTP response with the following Orion-LD data
        | Status-Code | Location   |
        | 201         | <location> |

      Examples:
        | file               | location                                           |
        | request601-02.json | /ngsi-ld/v1/entities/urn:ngsi-ld:Building:store001 |
        | request601-03.json | /ngsi-ld/v1/entities/urn:ngsi-ld:Building:store002 |


#
#   Request 4
#
    Scenario: [4] OBTAIN ENTITY DATA BY FQN TYPE
      When I prepare a GET HTTP request for "obtaining an entity data" to "http://localhost:1026/ngsi-ld/v1/entities"
      And  I set header Accept to application/ld+json
      And  the params equal to "type=https://smartdatamodels.org/dataModel.Building/Building"
      And  I perform the request
      Then I receive a HTTP "200" response code from Scorpio with the body equal to "response601-04-array.json"


#
#   Request 5
#
    Scenario: [5] OBTAIN ENTITY DATA BY ID
      When  I prepare a GET HTTP request for "obtaining entity data by Id" to "http://localhost:1026/ngsi-ld/v1/entities/urn:ngsi-ld:Building:store001"
      And   I set header Accept to application/ld+json
      And   I perform the request
      Then  I receive a HTTP "200" response code from Scorpio with the body equal to "response601-05-array.json"


#
#   Request 6
#     Note: the body response is quite different from what expected. In particular:
#           - the attribute "@context" is at the beginning of the entity and not at the end as expected
#           - the attribute "category" is of a wrong type and misplaced.
#           - in the file "response601_06" the first entity is as provided by Scorpio while the second entity
#             is left as expected in the tutorial to let understand the differences to make easier the correct the tutorial.
#     Note: the request itself in the tutorial is wrong as the url appears twice.
#
    Scenario: [6] OBTAIN ENTITY DATA BY TYPE
      When  I send GET HTTP request to Scorpio at "http://localhost:1026/ngsi-ld/v1/entities"
      And   With header 'Link$<https://smart-data-models.github.io/dataModel.Building/context.jsonld>; rel="http://www.w3.org/ns/json-ld#context"; type="application/json"'
      And   I set header Accept to application/ld+json
      And   With parameters "type$Building$options$keyValues"
      Then  I receive from Scorpio "200" response code with the body equal to "response601-06.json"


#
#   Request 7
#     Note: the body response is quite different from what expected. In particular:
#           - the attribute "@context" is at the beginning of the entity and not at the end as expected
#           - the attribute "category" is of a wrong type and misplaced.
#           The file "response601_07" is updated as provided by Scorpio to let understand how to correct the tutorial.
#
    Scenario: [7] FILTER CONTEXT DATA BY COMPARING THE VALUES OF AN ATTRIBUTE
      When  I send GET HTTP request to Scorpio at "http://localhost:1026/ngsi-ld/v1/entities"
      And   With header 'Link$<https://smart-data-models.github.io/dataModel.Building/context.jsonld>; rel="http://www.w3.org/ns/json-ld#context"; type="application/json"'
      And   I set header Accept to application/ld+json
      And   With parameters "type$Building$q$name=="Checkpoint Markt"$options$keyValues"
      Then  I receive from Scorpio "200" response code with the body equal to "response601-07.json"


#
#   Request 8
#     Note: the body response is quite different from what expected. In particular:
#           - the attribute "@context" is at the beginning of the entity and not at the end as expected
#           - the attribute "category" is of a wrong type and misplaced.
#           The file "response601_08" is left unchanged.
#
    Scenario: [8] FILTER CONTEXT DATA BY COMPARING THE VALUES OF AN ATTRIBUTE IN AN ARRAY
      When  I send GET HTTP request to Scorpio at "http://localhost:1026/ngsi-ld/v1/entities"
      And   With header 'Link$<https://smart-data-models.github.io/dataModel.Building/context.jsonld>; rel="http://www.w3.org/ns/json-ld#context"; type="application/json"'
      And   With parameters "type$Building$q$category=="commercial","office"$options$keyValues"
      Then  I receive from Scorpio "200" response code with the body equal to "response601-08.json"


#
#   Request 9
#     Note: the body response is quite different from what expected. In particular:
#           - the attribute "@context" is at the beginning of the entity and not at the end as expected
#           - the attribute "category" is of a wrong type and misplaced.
#           The file "response601_09" is left unchanged.
#
    Scenario: [9] FILTER CONTEXT DATA BY COMPARING THE VALUES OF A SUB-ATTRIBUTE
      When  I send GET HTTP request to Scorpio at "http://localhost:1026/ngsi-ld/v1/entities"
      And   With header 'Link$<https://smart-data-models.github.io/dataModel.Building/context.jsonld>; rel="http://www.w3.org/ns/json-ld#context"; type="application/json"'
      And   I set header Accept to application/ld+json
      And   With parameters "type$Building$q$address[addressLocality]=="Kreuzberg"$options$keyValues"
      Then  I receive from Scorpio "200" response code with the body equal to "response601-09.json"


#
#   Request 10
#     Note: the body response is quite different from what expected. In particular:
#           - the attribute "@context" is at the beginning of the entity and not at the end as expected
#           - the attribute "category" is of a wrong type and misplaced.
#           The file "response601_10" is left unchanged.
#
    Scenario: [10] FILTER CONTEXT DATA BY QUERYING METADATA
      When  I send GET HTTP request to Scorpio at "http://localhost:1026/ngsi-ld/v1/entities"
      And   With header 'Link$<https://smart-data-models.github.io/dataModel.Building/context.jsonld>; rel="http://www.w3.org/ns/json-ld#context"; type="application/json"'
      And   With parameters "type$Building$q$address.verified==true$options$keyValues"
      Then  I receive from Scorpio "200" response code with the body equal to "response601-10.json"


#
#   Request 11
#     Note: the body response is quite different from what expected. In particular:
#           - the attribute "@context" is at the beginning of the entity and not at the end as expected
#           - the attribute "category" is of a wrong type and misplaced.
#           The file "response601_11" is left unchanged.
#
    Scenario: [11] FILTER CONTEXT DATA BY COMPARING THE VALUES OF A GEO:JSON ATTRIBUTE
      When  I send GET HTTP request to Scorpio at "http://localhost:1026/ngsi-ld/v1/entities"
      And   With header 'Link$<https://smart-data-models.github.io/dataModel.Building/context.jsonld>; rel="http://www.w3.org/ns/json-ld#context"; type="application/json"'
      And   With parameters "type$Building$geometry$Point$coordinates$[13.3777,52.5162]$georel$near;maxDistance==2000$options$keyValues"
      Then  I receive from Scorpio "200" response code with the body equal to "response601-11.json"
