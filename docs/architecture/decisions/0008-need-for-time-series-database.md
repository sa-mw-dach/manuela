# 8. Need for time series database

Date: 2020-06-25

## Status

Proposed

## Context

We expect sensor data that is collected to be (temporarily) stored in Kafka as distributed event log, from where it can easily be moved to other sinks and replicated into other enviroments such as the central DC. It is not really used as a durable persistence layer.

Data processing at the edge however requires more than just the ability to buffer and process discrete events. It especially requires long-term persistence and the ability to retrieve data and perform calculations over time windows, e.g. to render graphs or the ability to look up historic values.

These kinds of requirements are typically addressed in time series databases. A Timeseries database is used to store and analyze time-series data. They typically include functions and operations related to time-series data analysis such as data retention policies, continuous queries, flexible time aggregations, etc.
A primary purpose of a TSDB is to analyze change over time. Traditional DBs don't scale well for inserting and querying data points.

Characteristics of time-series data:

* Append only (inserts only)
* Inserts ordered by time
* time is primary axis


Introducing this additional component to the architecture means it needs to be deployed, managed, requires backup and restore functionality, has runtime footprint, etc.

We consider the data in the time series DB to be authoritative and the data in Kafka to be ephemeral. Discrepancies between the data in Kafka and the data in the Time Series DB may occur when the TSDB has not yet caught up ingesting the Kafka data (a transient problem) or because it has a longer retention period than the Kakfa brokers.



## Decision

We want to introduce a time series database.

## Consequences

* need to select concrete implementation for time series DB from available open source options, e.g.
  * MongoDB
  * InfluxDB
  * Cassandra
  * Graphite
  * OpenTSDB
  * TimescaleDB
* need to develop a mechanism to feed sensor data from Kafka into TSDB
* need operational concept for Time Series DB (especially: backup/restore, data retention policy, etc...)
* Application Architects need to be aware of the eventually consistent nature of data in Kafka vs. data in the TSDB (and other sinks feeding from the event log) 