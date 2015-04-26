# The behaviour of this example will depend on which, if any, ruby-xes gems you have installed
#
# 0. No gem installed
#    Uncomment the line to specify the load path and use local code
# 1. ruby-xes-0.1.0
#    Comment the line to specify the load path and use ruby-xes-0.1.0
#
# The key thing to note is that the only lice of this program that needs to be different
# when using ruby-xes-0.2.0 is the cline to write the XML to the file

$LOAD_PATH.unshift('../lib')

require 'csv'
require 'xes'

puts "Example using ruby-xes-#{XES::VERSION}"

# Get some test data
csv = CSV.parse(File.read('Sample-osx.csv'), :headers => true)

doc = XES::Document.new
doc.log = log = XES::Log.default
#log = XES::Log.default
# This example does illustrate the use of nested attributes
#doc.log.xes_features = "nested-attributes"

# Add Global attributes here
doc.log.trace_global = XES::Global.new('trace', [
  XES::int('CaseID', ''), XES::int('CustomerID', '')
  ]
)
doc.log.event_global = XES::Global.new('event', [
  XES::string('Activity', ''), XES::date('StartDate', ''), XES::date('EndDate', ''),
  XES::string('AgentPosition', ''), XES::string('Product', ''),
  XES::string('ServiceType', ''), XES::string('Resource', '')
  ]
)

# Add Classifiers here
doc.log.classifiers = [
  XES::Classifier.new('Activity', 'Activity'),
  XES::Classifier.new("Resource", "Resource")
  ]

id = 0
trace = XES::Trace.new
csv.each do |row|

  #puts row['Case ID']
  caseId = row['Case ID'].split
  custId = row['Customer ID'].split

  # CSV file is sorted on 'Case ID', so
  # Each time we see a new 'Case ID' then we need to start a new trace
  if not row['Case ID'].eql?(id)
    trace = XES::Trace.new
    trace.attributes << XES::int('CaseID', caseId[1])
    trace.attributes << XES::int('CustomerID', custId[1])
  end

  # Each row of the CSV file is an event, and
  # Each column of the CSV file is an event attribute
  event = XES::Event.new
  event.attributes << XES::string('Activity', row['Activity'])
  event.attributes << XES::container('times', [
    XES::date('StartDate', row['Start Date'], [ 
      XES::boolean('UTC-format', 'false') 
    ]),
    XES::date('EndDate', row['End Date'], [ 
      XES::boolean('UTC-format', 'false') 
    ])
  ])
  event.attributes << XES::string('AgentPosition', row['Agent Position'])
  event.attributes << XES::string('Product', row['Product'])
  event.attributes << XES::string('ServiceType', row['Service Type'])
  event.attributes << XES::string('Resource', row['Resource'])
  trace.events << event

  if not row['Case ID'].eql?(id)
    id = row['Case ID']
    doc.log.traces << trace
  end

end

f = open("example-#{XES::VERSION}.xes", 'w')
if XES::VERSION.eql?("0.2.0")
  f.write(doc.format)
else
  doc.format.write(f, 2)
end
f.close()
