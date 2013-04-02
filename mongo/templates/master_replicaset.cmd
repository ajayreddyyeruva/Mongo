rs.initiate({"_id" : "sdrepset<%= component %>","members" : [{"_id" : 0,"host" : "<%= public_ip %>:<%= port %>","priority" : 50}]})
