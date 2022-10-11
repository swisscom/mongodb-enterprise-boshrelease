require 'rubygems'
require 'json'

skipFile="/var/vcap/store/mongodb-skip-post-start"
startTime = Time.now
timeOut = 3600
timeOutTime = startTime + timeOut

try = 0

def get_rs_state
  begin

    str = `mongo localhost:<%= p('mongodb.port') %>/admin -u <%= p('mongodb.health.user') %> -p '<%= p('mongodb.health.password') %>' --eval 'JSON.stringify(rs.status())' --quiet`

    # Raise Error if status code is not 0s
    if $? != 0
      raise RuntimeError.new("Error connecting to mongodb")
    end

    parsed = JSON.parse(str)

  # Rescue mongoshell error 12 times per run
  rescue RuntimeError => e
    sleep 10
    try += 1
    puts e
    try <= 12 ? retry : raise

  # Rescue jsonparse error 12 times per run
  rescue JSON::ParserError => e
    sleep 5
    try += 1
    puts e
    try <= 12 ? retry : raise
  end

end


def cluster_healty?

  cluster_healty = true
  rs_state = get_rs_state()

  rs_state['members'].each { |member|
    memberHealth=member['state']
    # 0 => STARTUP, 3 => RECOVERING, 5 => STARTUP2, 9 => ROLLBACK
    if memberHealth == 0 || memberHealth == 3 || memberHealth == 5 || memberHealth == 9
      puts "unhealthy node: #{member['name']} with node status: #{memberHealth}"
      cluster_healty = false
    end
  }
  cluster_healty
end

# wait until cluster is healthy until timeout is reached or skipfile exists
# if cluster is healthy and skipfile exsists it will be healthy and ignore skipfile
while Time.now < timeOutTime  do
  if File.file?(skipFile)
    puts "#{skipFile} found, therefore skipping"
    break
  elsif cluster_healty?
    puts "cluster OK, proceeding"
    break
  else
    puts "cluster unhealty; wait and try again"
    sleep 10
  end
end