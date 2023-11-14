randomize()
var map = ds_map_create()
map[?"value"] = choose("Opera","YoYoGames","GameMaker","Firebase")
map[?"points"] = irandom(999)
var json = json_encode(map)
ds_map_destroy(map)

FirebaseFirestore("Collection").Set(json)
