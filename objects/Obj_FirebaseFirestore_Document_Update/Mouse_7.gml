
randomize()
var map = ds_map_create()
map[?"value"] = "Opera"
map[?"points"] = random(999999)
var json = json_encode(map)
ds_map_destroy(map)

FirebaseFirestore("Collection/Document").Update(json)

