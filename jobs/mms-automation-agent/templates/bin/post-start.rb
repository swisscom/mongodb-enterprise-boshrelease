require 'rubygems'
require 'json'

def cluster_healty?

  begin

    str = `mongo localhost:<%= p('mongodb.port') %>/admin -u <%= p('mongodb.health.user') %> -p '<%= p('mongodb.health.password') %>' --eval 'JSON.stringify(rs.status())' --quiet`

    # Raise Error if status code is not 0s
    if $? != 0
      raise RuntimeError.new("Error connecting to mongodb")
    end

    parsed = JSON.parse(str)

  # Rescue mongoshell error 5 times
  rescue RuntimeError => e
    sleep 5
    try += 1
    puts e
    try <= 5 ? retry : raise

  # Rescue jsonparse error forever
  rescue JSON::ParserError => e
    sleep 5
    puts e
    retry

  end


  cluster_healty = true

  parsed['members'].each { |member|
    memberHealth=member['health']
    # 0 => STARTUP, 3 => RECOVERING, 5 => STARTUP2, 9 => ROLLBACK
    if memberHealth == 0 || memberHealth == 3 || memberHealth == 5 || memberHealth == 9
      puts "unhealthy node: #{member['name']} with node status: #{memberHealth}"
      cluster_healty = false
    end

  }
  cluster_healty
end


# wait until cluster is healthy 
while true do
  if cluster_healty?
    puts 'cluster OK, proceeding'
    break 
  else
    puts 'cluster unhealty; wait and try again'
    sleep 10
  end
end
