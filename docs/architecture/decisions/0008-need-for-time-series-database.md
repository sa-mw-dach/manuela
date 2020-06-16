# 8. Need for time series database

Date: 2020-06-16

## Status

Proposed

## Context

We expect sensor data that is collected to be (temporarily) stored in Kafka as distributed event log, from where it can easily be replicated into other enviroments such as the central DC. 

Data processing at the edge however requires more than just the ability to process discrete events, for example:

* to calculate sliding averages over time windows
* TODO: what other requirements do we see/expect 

These kinds of requirements are typically addressed in time series databases. Introducing this additional component to the architecture however has some implications:

Pro:
* better developer efficiency / higher level query constructs available

Con:
* additional component which needs to be deployed, managed, has runtime footprint, etc...
* managing two sets of the same data is inherently painful:
  * need concept to feed sensor data consistently into two sinks (Kafka and Time Series DB) or an understanding that consistency will not be guaranteed
  * need decision which of the two sets of data is the "master" in case of discrepancy, how to recreate one based on the other, .... (e.g. after restore)
  * need to agree on data retention policy (i.e. will data no longer be avialable in Kafka still be present in Time Series DB?)


## Decision

We want to introduce a time series database.

## Consequences

* need to select concrete implementation for time series DB from available options
* need operational concept for Time Series DB (especially: backup/restore / recreate consistency)
* need concepts to address the issues listed under Con: above
