Seriously
=========

Seriesosly is a real-time analytics engine. It allows you to collect multi-dimension measurement data and efficiently and flexibly render reports and graphs of those metrics. The system is "real-time" in that when you store metrics, they are instantly visible in any query used to draw a chart or graph. There is no batch processing. 

Seriesosly is built on top of MongoDB and is implemented in Ruby and Sinatra. 

Seriesosly provides the following features: 

 * Store arbitrary metric & dimension data
 * Query metric & dimesion data 
 ** Report aggregate metric values (e.g. total visitors) 
 ** Report historical metric values (e.g. visitors per day) 
 ** Report based on combinations of dimensions (e.g. visitors by URL, visitors by Browser by Country,..) 


Events
------


An event is a JSON object that looks like this: 

	{
		timestamp: ISODate("2011-04-04T05:10:13.374Z"),
		tags: [ 
			{source: 'machine1'}, 
			{event: 'http request'} 
		], 
		measurements: [ 
			{ 
				metric: 'bytes_in',
				value: 1234,
				tags: [ 
					{mime_type: 'text/html'},
					{url: 'http://www.amazon.com/home'}
				]
			},
			{ 
				metric: 'bytes_out',
				value: 4321,
				tags: [
					{mime_type: 'image/png'}
				]
			}
		]
	} 

An event allows the caller to group together a set of measurements into a single RPC. An event has a timestamp, which is applied to all of the measurements contained within the request. An event also has a set of tags which are shared by all of the measurements in the event. 

Each individual measurement has a name which identifies the counter sampled by this measurement, a value, which is the actual value of that counter at the timestamp, and a list of tags that are unique to that measurement. 

Reports
------- 

A client issues queries to the system to request reports. 

A Query is a JSON document that looks like this: 

	{ 
		metrics: [ 'bytes_in', 'bytes_out' ],
		from: ISODate("2011-04-04T05:10:13.374Z"),
		to: ISODate("2011-04-05T05:10:13.374Z")
		rollup: 'hour',
		filter: [ 
			{ source: 'machine1' }
		],
		group_by: [ 
			'url'
		]
	}

The query above says: "Give me hourly bytes_in and bytes_out from April 4 to April 5 broken down by url". 

A response would look like this: 

	{ 
		bytes_in: [ 
			url10: {
				sum: 123123,
				count: 234,
				sum_of_squares: 1231343234,
				begin_timestamp: ISODate("2011-04-04T05:10:13.374Z")
				values: [
					{ begin_timestamp: ISODate("2011-04-04T05:10:13.374Z"), 
					  sum: 12,
						count: 3,
						sum_of_squares: 4223 },
					{ begin_timestamp: ISODate("2011-04-04T05:10:13.374Z"), 
					  sum: 12,
						count: 3,
						sum_of_squares: 4223 }
				]
			}, 
			url11: { 
				sum: 123123,
				count: 234,
				sum_of_squares: 1231343234,
				begin_timestamp: ISODate("2011-04-04T05:10:13.374Z")
				values: [
					{ begin_timestamp: ISODate("2011-04-04T05:10:13.374Z"), 
					  sum: 12,
						count: 3,
						sum_of_squares: 4223
					}
				]
			}
			// Pagination markers. Tells the client that this section of the 
			// document has previous or next entries. The client can bass the 
			// contents of these markers back to the server on subsequent requests
			// to get paginated results
			has_next: { 
				begin: 'url12',
				cookie: '4124234251'
			}
			has_prev: { 
				end: 'url9'
				cookie: '543452342'
			}
		]
	}


Storage Policy
--------------

The Storage Policy allows an administrator to control the behavior of the database. Multiple Storage Policy's can be created on a single system, each defining different policies. The Storage Policy allows the administrator to control how data is distributed across the cluster, and how long that data should be retained by the system. 

A Storage Policy is a JSON document that looks like this: 

{ 
	shard_by: 'event.tags.source',
	aggregations: [
		total : { 
			retention: '$all'
		}
		hourly : { 
			retention: 4096 	// keep 1gb of hourly data
		}
		daily: { 
			retention: 2048 	// keep 2gb of daily data
		}
	]
} 

This document says that we should shard by the 'event.tags.source' attribute. This selects how data will be distributed within mongodb. 

If you shard by time, then all new records will be written to a single shard. This means that you can easily throw out old data by dropping nodes from the sharded cluster. But it has the limitation that a single shard must be able to handle your write rate. 

If you shard by metric, then metrics will be evenly distributed across shards. This may cause problems if you have a very small number of metrics (e.g. if therer's just one metric, it can't be split up into different shards). This may also cause problems if your load is unevenly distributed across metrics (e.g. metric 1 is reported 1M times per second and metric2 is only reported 1 time per second). 

If you shard by a tag like "source", then data will be split across shards evenly based on who sent the data. This will make aggregate queries relatively unscalable since they will typically need to do a broadcast. However, if you don't have many clients issueing queries, this can be a very efficient way to sustain high right volumes as it most closely machines write capacity to client demand. 

There are other sharding configurations possible based on use of custom tags. 

You can't change the sharding configuration once you have set up the system. 

The aggregates section allows you to control which time periods the system will store. There are 4 built-in aggregation periods

	* Total - This is a single aggregate over all of time. 
	* Hourly - Data aggregated over a 1 hour period 
	* Daily - Data aggregated over a 24 hour period 
	* Monthly - Data aggregated over a 1 month period

If a clause for one or more aggregate is left out of the configuration, it will not be tracked. 

For each aggregate included, you can specify the retention configuration for data. At the moment, rention is defined as the maximum data size to store for a partiular aggregate. The administrator can choose the special retention period "all" which instructs the system to use uncapped collections. 

The administrator can also set the retention period to a number indicating the number of MB of data to store for that period. Internally, this value is used to allocate a capped collection used to store the data.


