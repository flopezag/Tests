Feature: test tutorial 602 Linked Data: Relationships and Data Models (Orion-LD)

#
#   Parameters to be considered (aka INTERESTING_FEATURES_STRINGS)
#
    url: https://fiware-tutorials.readthedocs.io/en/latest/relationships-linked-data.html
    git-clone: https://github.com/FIWARE/tutorials.Relationships-Linked-Data.git
    git-directory: /tmp/tutorials.Relationships-Linked-Data

    shell-commands: git checkout NGSI-v2; ./services create; ./services orion
    clean-shell-commands: ./services stop

#   Overall Note: The tutorial does not say anything aut the response code expected.
#                Even the success code is not always the same! It takes 200, 201, 204 depending on the API


    Background:
        Given I set the tutorial 602


#
#   Request 1
#       Note: The expected body in the Tutorial has the following differences with respect to the current Orion-LD version:
#             1) attribute '@context' expected 'https://uri.etsi.org/ngsi-ld/v1/ngsi-ld-core-context-v1.3.jsonld'
#                current 'https://uri.etsi.org/ngsi-ld/v1/ngsi-ld-core-context.jsonld'. In this respect
#                the text itself of the tutorial shall be corrected
#             2) attribute 'name' expected first, instead it is second after attribute 'https://schema.org/address'
#
    Scenario: [1] DISPLAY ALL entities of a given type (BUILDINGS)
      When  I prepare a GET HTTP request for "obtaining an entity data" to "http://localhost:1026/ngsi-ld/v1/entities"
      And   I set header Accept to application/ld+json
      And   the params equal to "type=https://uri.fiware.org/ns/data-models#Building"
      And   the params equal to "options=keyValues"
      And   I perform the request
      Then  I receive from Orion-LD "200" response code with the body equal to "response602-01.json"


#
#   Request 2
#       Note: The expected body in the Tutorial has the following differences with respect to the current Orion-LD version:
#             1) attribute 'name' expected first, instead it is last
#
    Scenario: [2] DISPLAY ALL entities of a given type (PRODUCT)
      When  I prepare a GET HTTP request for "obtaining entities data" to "http://localhost:1026/ngsi-ld/v1/entities"
      And   I set header Link to <http://context/user-context.jsonld>; rel="http://www.w3.org/ns/json-ld#context"; type="application/ld+json"
      And   the params equal to "type=https://fiware.github.io/tutorials.Step-by-Step/schema/Product"
      And   the params equal to "options=keyValues"
      And   I perform the request
      Then  I receive from Orion-LD "200" response code with the body equal to "response602-02.json"

#
#   Request 3
#       Note: The expected body in the Tutorial has the following differences with respect to the current Orion-LD version:
#             1) attribute 'name' expected first, instead it is second after 'maxCapacity' attribute
#
    Scenario: [3] DISPLAY ALL entities of a given type (SHELF)
      When  I prepare a GET HTTP request for "obtaining entities data" to "http://localhost:1026/ngsi-ld/v1/entities"
      And   I set header Link to <http://context/user-context.jsonld>; rel="http://www.w3.org/ns/json-ld#context"; type="application/ld+json"
      And   the params equal to "type=Shelf"
      And   the params equal to "options=keyValues"
      And   I perform the request
      Then  I receive from Orion-LD "200" response code with the body equal to "response602-03.json"

#
#   Request 4
#       Note: The expected body in the Tutorial has the following differences with respect to the current Orion-LD version:
#             1) attributes order completely mixed-up. Expected: name, maxCapacity, location, Current: location, maxCapacity, name
#
    Scenario: [4] OBTAIN SHELF INFORMATION
      When  I prepare a GET HTTP request for "obtaining an entity data" to "http://localhost:1026/ngsi-ld/v1/entities/urn:ngsi-ld:Shelf:unit001"
      And   I set header Link to <http://context/user-context.jsonld>; rel="http://www.w3.org/ns/json-ld#context"; type="application/ld+json"
      And   the params equal to "options=keyValues"
      And   I perform the request
      Then  I receive from Orion-LD "200" response code with the body equal to "response602-04.json"

#
#   Request 5
#
    Scenario Outline: [5] ADDING 1-1 RELATIONSHIPS
    When  I prepare a POST HTTP request for "creating an entity" to "http://localhost:1026/ngsi-ld/v1/entities/urn:ngsi-ld:Shelf:unit001/attrs"
    And   I set header Content-Type to application/ld+json
    And   I set the body request as described in <file>
    And   I perform the request
    Then  I receive a HTTP response with the following orion-ld data
      | Status-Code | Location   |
      | 204         | <location> |

    Examples:
      | file               | location |
      | request602-05.json | Any      |


#
#   Request 6
#
    Scenario: [6] OBTAIN THE UPDATED SHELF
      When I send GET HTTP request to "http://localhost:1026/ngsi-ld/v1/entities/urn:ngsi-ld:Shelf:unit001"
      Then I receive a HTTP "200" response code from Orion-LD with the body equal to "response602-06.json"


#
#   Request 7
#       Note: The expected body in the Tutorial has the following differences with respect to the current Orion-LD version:
#             1) wrong value for attribute '@context.
#                expected: 'https://fiware.github.io/tutorials.Step-by-Step/datamodels-context.jsonld'
#                current: 'https://fiware.github.io/tutorials.Step-by-Step/tutorials-context.jsonld'
#
    Scenario: [7] FIND THE STORE IN WHICH A SPECIFIC SHELF IS LOCATED
      When  I prepare a GET HTTP request for "obtaining an entity data" to "http://localhost:1026/ngsi-ld/v1/entities/urn:ngsi-ld:Shelf:unit001"
      And   I set header Link to <http://context/user-context.jsonld>; rel="http://www.w3.org/ns/json-ld#context"; type="application/ld+json"
      And   I set header Accept to application/ld+json
      And   the params equal to "attrs=locatedIn"
      And   the params equal to "options=keyValues"
      And   I perform the request
      Then  I receive from Orion-LD "200" response code with the body equal to "response602-07.json"


#
#   Request 8
#
    Scenario: [8] FIND THE IDS OF ALL SHELF UNITS IN A STORE
      When  I send GET HTTP request to Orion-LD at "http://localhost:1026/ngsi-ld/v1/entities/"
      And   With header 'Accept$application/json$Link$<https://fiware.github.io/tutorials.Step-by-Step/tutorials-context.jsonld>; rel="http://www.w3.org/ns/json-ld#context"; type="application/ld+json"'
      And   With parameters "type$Shelf$options$keyValues$attrs$locatedIn"
      Then  I receive from Orion-LD "200" response code with the body equal to "response602-08.json"


#
#   Request 9
#
    Scenario Outline: [9] ADDING 1-MANY RELATIONSHIP
      When  I prepare a POST HTTP request for "adding new attribute" to "http://localhost:1026/ngsi-ld/v1/entities/urn:ngsi-ld:Building:store001/attrs"
      And   I set header Content-Type to application/ld+json
      And   I set the body request as described in <file>
      And   I perform the request
      Then  I receive a HTTP response with the following orion-ld data
        | Status-Code | Location   |
        | 204         | <location> |

      Examples:
        | file               | location |
        | request602-09.json | Any      |


#
#   Request 10
#
    Scenario: [10] FINDING ALL SHELF UNITS FOUND WITHIN A STORE
      When  I send GET HTTP request to Orion-LD at "http://localhost:1026/ngsi-ld/v1/entities/urn:ngsi-ld:Building:store001"
      And   With header 'Accept$application/json$Link$<https://fiware.github.io/tutorials.Step-by-Step/tutorials-context.jsonld>; rel="http://www.w3.org/ns/json-ld#context"; type="application/ld+json"'
      And   With parameters "options$keyValues$attrs$furniture"
      Then  I receive from Orion-LD "200" response code with the body equal to "response602-10.json"


#
#   Request 11
#
    Scenario Outline: [11] CREATING COMPLEX RELATIONSHIPS
      When  I prepare a POST HTTP request for "creating an entity" to "http://localhost:1026/ngsi-ld/v1/entities/"
      And   I set header Content-Type to application/ld+json
      And   I set the body request as described in <file>
      And   I perform the request
      Then  I receive a HTTP response with the following orion-ld data
        | Status-Code | Location   |
        | 201         | <location> |

      Examples:
        | file               | location |
        | request602-11.json | Any      |


#
#   Request 12
#
    Scenario: [12] FINDING ALL SHELF UNITS FOUND WITHIN A STORE
      When  I send GET HTTP request to Orion-LD at "http://localhost:1026/ngsi-ld/v1/entities/"
      And   With header 'Accept$application/json$Link$<https://fiware.github.io/tutorials.Step-by-Step/tutorials-context.jsonld>; rel="http://www.w3.org/ns/json-ld#context"; type="application/ld+json"'
      And   With parameters "type$StockOrder$q$orderedProduct=="urn:ngsi-ld:Product:001"$attrs$requestedFor$options$keyValues"
      Then  I receive from Orion-LD "200" response code with the body equal to "response602-12.json"


#
#   Request 13
#
    Scenario: [13] FIND ALL PRODUCTS SOLD IN A STORE
      When  I send GET HTTP request to Orion-LD at "http://localhost:1026/ngsi-ld/v1/entities/"
      And   With header 'Accept$application/json$Link$<https://fiware.github.io/tutorials.Step-by-Step/tutorials-context.jsonld>; rel="http://www.w3.org/ns/json-ld#context"; type="application/ld+json"'
      And   With parameters "type$StockOrder$q$requestedFor=="urn:ngsi-ld:Building:store001"$attrs$orderedProduct$options$keyValues"
      Then  I receive from Orion-LD "200" response code with the body equal to "response602-13.json"


#
#   Request 14
#       Note: The expected body in the Tutorial has the following differences with respect to the current Orion-LD version:
#             1) wrong value for attribute '@context.
#                expected: 'https://fiware.github.io/tutorials.Step-by-Step/datamodels-context.jsonld'
#                current: 'https://fiware.github.io/tutorials.Step-by-Step/tutorials-context.jsonld'
#             2) expected attributes order: type, orderDate, orderedProduct, requestedBy, requestedFor, stockCount
#                current attributes order: type, requestedFor, requestedBy, orderedProduct, stockCount, orderDate
#
    Scenario: [14] OBTAIN STOCK ORDER
      When  I prepare a GET HTTP request for "obtaining an entity data" to "http://localhost:1026/ngsi-ld/v1/entities/urn:ngsi-ld:StockOrder:001"
      And   I set header Accept to application/ld+json
      And   the params equal to "options=keyValues"
      And   I perform the request
      Then  I receive from Orion-LD "200" response code with the body equal to "response602-14.json"
