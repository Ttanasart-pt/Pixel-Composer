/// steam_glue.h
#pragma once

///
#define steam_net_version 1300

// GCC glue:
#ifdef __GNUC__
#include <stdlib.h>
// I know, and great, but that's what GMS runtime uses
#pragma GCC diagnostic ignored "-Wwrite-strings"
// (I guess because it's bad, but tell that to Valve)
#pragma GCC diagnostic ignored "-Winvalid-offsetof"
#endif

// All of the Steam API enums are unscoped
#pragma warning (disable: 26812)

// For unidentifiable reason Steam API doesn't init unless using "safe" interfaces.
// Might be a conflict with GM runtime.
#define VERSION_SAFE_STEAM_API_INTERFACES 1
#include "steam_api.h"
#include "isteamappticket.h"

// The following are solely in case it is ever needed to switch to "unsafe" API
//extern CSteamAPIContext SteamAPI;
//#define SteamUser SteamAPI.SteamUser
//#define SteamFriends SteamAPI.SteamFriends
//#define SteamNetworking SteamAPI.SteamNetworking
//#define SteamMatchmaking SteamAPI.SteamMatchmaking
//#define SteamInventory SteamAPI.SteamInventory
//#define SteamUtils SteamAPI.SteamUtils
//#define SteamController SteamAPI.SteamController
//#define SteamUGC SteamAPI.SteamUGC

extern uint32 steam_app_id;
extern CSteamID steam_local_id;
extern CSteamID steam_lobby_current;

#include <vector>
#include <map>
#include <string>
#include <stdint.h>
#include "steam_callbacks.h"
std::string b64encode(const void* data, const size_t& len);

#if (STEAMWORKS < 142)
typedef uint64 SteamInventoryUpdateHandle_t;
#endif
typedef int steam_image_id;

using std::map;
using std::vector;
using std::string;

#include "gml_glue.h"
#include "gml_glue_map.h"