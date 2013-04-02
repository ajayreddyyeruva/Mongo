rs.initiate({"_id" : "<%= replSet %>","members" : [{"_id" : 0,"host" : "<%= public_ip %>:<%= port %>","priority" : 50}]})
