#pragma once

#include "pch.h"

#include "steam_glue.h"
class steam_net_callbacks_t 
{
public:
	steam_net_callbacks_t() 
	{
		//
	};
	STEAM_CALLBACK(steam_net_callbacks_t, p2p_session_request, P2PSessionRequest_t);
	//STEAM_CALLBACK(steam_net_callbacks_t, OnPersonaStateChange, PersonaStateChange_t);
	STEAM_CALLBACK(steam_net_callbacks_t, lobby_chat_update, LobbyChatUpdate_t);
	STEAM_CALLBACK(steam_net_callbacks_t, lobby_chat_message, LobbyChatMsg_t);
	STEAM_CALLBACK(steam_net_callbacks_t, lobby_join_requested, GameLobbyJoinRequested_t);
	STEAM_CALLBACK(steam_net_callbacks_t, micro_txn_auth_response, MicroTxnAuthorizationResponse_t);
	STEAM_CALLBACK(steam_net_callbacks_t, steam_inventory_result_ready, SteamInventoryResultReady_t);
	STEAM_CALLBACK(steam_net_callbacks_t, steam_inventory_full_update, SteamInventoryFullUpdate_t);
	STEAM_CALLBACK(steam_net_callbacks_t, steam_inventory_definition_update, SteamInventoryDefinitionUpdate_t);
	STEAM_CALLBACK(steam_net_callbacks_t, avatar_image_loaded, AvatarImageLoaded_t);
	STEAM_CALLBACK(steam_net_callbacks_t, steam_music_volume_has_changed, VolumeHasChanged_t);
	STEAM_CALLBACK(steam_net_callbacks_t, steam_music_playback_status_has_changed, PlaybackStatusHasChanged_t);

	void lobby_list_received(LobbyMatchList_t* e, bool failed);
	void lobby_created(LobbyCreated_t* e, bool failed);
	void lobby_joined(LobbyEnter_t* e, bool failed);

	void steam_inventory_request_prices(SteamInventoryRequestPricesResult_t* e, bool failed);
	void steam_inventory_request_eligible_promo_item_defs(SteamInventoryEligiblePromoItemDefIDs_t* e, bool failed);

	void item_deleted(DeleteItemResult_t* r, bool failed);
	void encrypted_app_ticket_response_received(EncryptedAppTicketResponse_t* pEncryptedAppTicketResponse, bool bIOFailure);
};
extern steam_net_callbacks_t steam_net_callbacks;