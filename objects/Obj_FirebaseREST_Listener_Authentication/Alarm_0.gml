
var header_map = json_decode(header_json)
request = http_request(url,method_,header_map,body)
ds_map_destroy(header_map)


