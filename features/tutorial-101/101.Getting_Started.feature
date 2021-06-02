# created by Amani Boughanmi on 20.05.2021

Feature: test tutorial 101.Getting Started

 This is the feature file of the FIWARE Step by Step tutorial for NGSI-v2
 url: https://fiware-tutorials.readthedocs.io/en/latest/getting-started/index.html
 docker-compose: https://raw.githubusercontent.com/FIWARE/tutorials.Getting-Started/master/docker-compose.yml
 environment: https://raw.githubusercontent.com/FIWARE/tutorials.Getting-Started/master/.env

Background: 
    Given I set the tutorial

Scenario: GET version request
	Given I send GET HTTP request
	Then the json response is valid
