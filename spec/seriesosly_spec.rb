require File.expand_path( File.dirname(__FILE__) + '/spec_helper' )

describe "Seriesosly" do 
	describe "Events" do 
		it "should record new events" 
		it "should require an event to have a timestamp" 
		it "should require an event to have at least one measurement" 
		describe "Measurements" do 
			it "should require a metric name" 
			it "should require a metric value" 
			it "should allow a list of measurement specific tags" 
		end 
		it "should allow a list of global tags" 
	end 

	describe "Queries" do 
		it "should respond to queries" 
		it "should return data from the time range specified" 
		it "should return data at the rollup specified" 
		it "should return an array of values for the metric if it's long enough"
		it "should return total values for the metric" 
		it "should break results down by dimensions in query" 
		it "should paginate results" 
	end 

	describe "Policy" do 
		it "should initialize cluster from storage policy" 
		it "should create a new database" 
		it "should shard the database" 
		it "should set the shard key for the database" 
		it "should create collections for data" 
		it "should cap collections based on retention policy" 
		it "should not try to change an existing database" 
	end 
end 

