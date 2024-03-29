require 'rubygems'
require 'json'

def cluster_healty?

  str = `mongosh localhost:<%= p('mongodb.port') %>/admin -u <%= p('mongodb.health.user') %> -p '<%= p('mongodb.health.password') %>' --eval 'JSON.stringify(rs.status())' --quiet`
  puts str

  parsed = JSON.parse(str)

  if parsed['errmsg'] == 'not running with --replSet'
    puts 'not in cluster mode, proceeding'
    `/var/vcap/bosh/bin/monit stop mms-automation-agent`
    exit 0
  end

  cluster_healty = true

  parsed['members'].each { |member|
    if member['health'] == 0
      puts 'unhealthy node: ' + member['name']
      cluster_healty = false
    end

  }
  cluster_healty
end


# wait up to 10 minutes for cluster to get healty
i = 0
while i < 60 do
  if cluster_healty?
    puts 'cluster OK, proceeding'
    
    str = `mongosh localhost:<%= p('mongodb.port') %>/admin -u <%= p('mongodb.health.user') %> -p '<%= p('mongodb.health.password') %>' --eval 'JSON.stringify(db.isMaster())' --quiet`
    puts str

    parsed = JSON.parse(str)


    if parsed['ismaster'] == true
      puts 'node is writeable, doing rs.stepDown now'
      `mongosh localhost:<%= p('mongodb.port') %>/admin -u <%= p('mongodb.health.user') %> -p '<%= p('mongodb.health.password') %>' --eval 'JSON.stringify(rs.stepDown())' --quiet`
    end

    `/var/vcap/bosh/bin/monit stop mms-automation-agent`

    `mongosh localhost:<%= p('mongodb.port') %>/admin -u <%= p('mongodb.health.user') %> -p '<%= p('mongodb.health.password') %>' --eval 'JSON.stringify(db.shutdownServer())' --quiet 2>&1 >> /var/vcap/sys/log/mms-automation-agent/drain.log`
    
    exit 0
  else
    puts 'cluster unhealty; wait and try again. try: ' + i.to_s
    sleep 10
    i += 1
  end
end
puts 'Timeout: no healty cluster state could be reached.'
exit 1
