export CONNECT_STRING="mongodb://<%= p('mongodb.health.user') %>:<%= p('mongodb.health.password') %>@127.0.0.1:<%= p('mongodb.port') %>/admin?authSource=admin"