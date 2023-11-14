
randomize()
var map = ds_map_create()
map[?"value"] = "YoYoGames"
map[?"points"] = random(999999)
var json = json_encode(map)
ds_map_destroy(map)

FirebaseFirestore("Collection/Document").Delete(json)
