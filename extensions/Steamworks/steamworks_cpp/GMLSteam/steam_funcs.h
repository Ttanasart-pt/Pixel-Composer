//#ifndef _STEAM_FUNCS_H_
//#define _STEAM_FUNCS_H_
//
//#include "steam_enable.h"
//#include "steamtypes.h"
//
////these could be problematic...since they are called within the api header
////...any way other than modifying the header...?
////S_API void SteamAPI_RegisterCallback( class CCallbackBase *pCallback, int iCallback );
////S_API void SteamAPI_UnregisterCallback( class CCallbackBase *pCallback );
////S_API void SteamAPI_RegisterCallResult( class CCallbackBase *pCallback, SteamAPICall_t hAPICall );
////S_API void SteamAPI_UnregisterCallResult( class CCallbackBase *pCallback, SteamAPICall_t hAPICall );
//
//extern void (*g_pSteamAPI_RegisterCallback)(class CCallbackBase* pCallback, int iCallback);
//extern void (*g_pSteamAPI_UnregisterCallback)(class CCallbackBase* pCallback);
//extern void (*g_pSteamAPI_RegisterCallResult)(class CCallbackBase* pCallback, SteamAPICall_t hAPICall);
//extern void (*g_pSteamAPI_UnregisterCallResult)(class CCallbackBase* pCallback, SteamAPICall_t hAPICall);
//extern int32(*g_pSteamAPI_GetHSteamUser)();
//extern int32(*g_pSteamAPI_GetHSteamPipe)();
//
//class ISteamClient;
//
//extern ISteamClient* (*g_pSteamClient)(void);
//
////Functions above this line may b
////NB!! steam_api.h MODIFIED to call above functions through function ptr
////#include "steam_common.h"
//#include "steam_common.h"
//
////extern bool LoadSteamLib();
////extern void UnloadSteamLib();
////
////extern bool (*g_pSteamAPI_InitSafe)(void);
////extern bool (*g_pSteamAPI_Init)(void);
////extern void (*g_pSteamAPI_RunCallbacks)(void);
////extern bool (*g_pSteamAPI_RestartAppIfNecessary)(uint32);
////extern void (*g_pSteamAPI_Shutdown)(void);
//
//
////#define SteamAPI_InitSafe()						g_pSteamAPI_InitSafe()
////#define SteamAPI_Init()							g_pSteamAPI_Init()
////#define SteamAPI_RunCallbacks()					g_pSteamAPI_RunCallbacks()
////#define SteamAPI_RestartAppIfNecessary(appId)	g_pSteamAPI_RestartAppIfNecessary(appId)
////#define SteamAPI_Shutdown()						g_pSteamAPI_Shutdown()
//
//
//extern CSteamAPIContext* g_SteamContext;
//
//#define SteamClient()			g_pSteamClient()
//
//#endif //_STEAM_FUNCS_H_