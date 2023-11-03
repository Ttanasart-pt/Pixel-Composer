/// @description 
var ev_id = async_load[? "id"];
var ev_type = async_load[? "event_type"];

if(string(ev_id) == string(STEAM_UGC_ITEM_ID) && ev_type == "ugc_create_item") {
	STEAM_UGC_PUBLISH_ID = async_load[? "published_file_id"];
	STEAM_UGC_UPDATE_HANDLE = steam_ugc_start_item_update(STEAM_APP_ID, STEAM_UGC_PUBLISH_ID);
	
	steam_ugc_set_item_title(STEAM_UGC_UPDATE_HANDLE, STEAM_UGC_ITEM_FILE.name);
	steam_ugc_set_item_description(STEAM_UGC_UPDATE_HANDLE, STEAM_UGC_ITEM_FILE.meta.description);
	steam_ugc_set_item_visibility(STEAM_UGC_UPDATE_HANDLE, ugc_visibility_public);
	
	var tgs = array_clone(STEAM_UGC_ITEM_FILE.meta.tags);
	switch(STEAM_UGC_TYPE) {
		case STEAM_UGC_FILE_TYPE.collection :	array_insert_unique(tgs, 0, "Collection");	break;
		case STEAM_UGC_FILE_TYPE.project :		array_insert_unique(tgs, 0, "Project");		break;
		case STEAM_UGC_FILE_TYPE.node_preset :	array_insert_unique(tgs, 0, "Node preset");	break;
	}
	
	steam_ugc_set_item_tags(STEAM_UGC_UPDATE_HANDLE, tgs);
	steam_ugc_set_item_preview(STEAM_UGC_UPDATE_HANDLE, TEMPDIR + "steamUGCthumbnail.png");
	steam_ugc_set_item_content(STEAM_UGC_UPDATE_HANDLE, "steamUGC");
	
	STEAM_UGC_SUBMIT_ID = steam_ugc_submit_item_update(STEAM_UGC_UPDATE_HANDLE, "Initial upload");
	exit;
}

if(string(ev_id) == string(STEAM_UGC_SUBMIT_ID)) {
	STEAM_UGC_ITEM_UPLOADING = false;
	
	var type = "";
	switch(STEAM_UGC_TYPE) {
		case STEAM_UGC_FILE_TYPE.collection :	type = "Collection";	break;
		case STEAM_UGC_FILE_TYPE.project :		type = "Project";		break;
		case STEAM_UGC_FILE_TYPE.node_preset :	type = "Node preset";	break;
	}
	
	if(async_load[? "result"] == ugc_result_success) {
		if(STEAM_UGC_UPDATE) {
			log_message("WORKSHOP", type + " updated", THEME.workshop_update);
			PANEL_MENU.setNotiIcon(THEME.workshop_update);
		} else {
			log_message("WORKSHOP", type + " uploaded", THEME.workshop_upload);
			PANEL_MENU.setNotiIcon(THEME.workshop_upload);
		}
		
		STEAM_SUB_ID = steam_ugc_subscribe_item(STEAM_UGC_PUBLISH_ID);
		exit;
	} 
	
	switch(async_load[? "result"]) { #region error
		case   2: log_warning("WORKSHOP", "Generic failure.");    break;
		case   3: log_warning("WORKSHOP", "Your Steam client doesn't have a connection to the back-end.");    break;
		case   5: log_warning("WORKSHOP", "Password/ticket is invalid."); break;
		case   6: log_warning("WORKSHOP", "The user is logged in elsewhere.");    break;
		case   7: log_warning("WORKSHOP", "Protocol version is incorrect.");  break;
		case   8: log_warning("WORKSHOP", "A parameter is incorrect.");   break;
		case   9: log_warning("WORKSHOP", "File was not found."); break;
		case  10: log_warning("WORKSHOP", "Called method is busy - action not taken.");  break;
		case  11: log_warning("WORKSHOP", "Called object was in an invalid state."); break;
		case  12: log_warning("WORKSHOP", "The name was invalid.");  break;
		case  13: log_warning("WORKSHOP", "The email was invalid."); break;
		case  14: log_warning("WORKSHOP", "The name is not unique.");    break;
		case  15: log_warning("WORKSHOP", "Access is denied.");  break;
		case  16: log_warning("WORKSHOP", "Operation timed out.");   break;
		case  17: log_warning("WORKSHOP", "The user is VAC2 banned.");   break;
		case  18: log_warning("WORKSHOP", "Account not found."); break;
		case  19: log_warning("WORKSHOP", "The Steam ID was invalid.");  break;
		case  20: log_warning("WORKSHOP", "The requested service is currently unavailable.");    break;
		case  21: log_warning("WORKSHOP", "The user is not logged on."); break;
		case  22: log_warning("WORKSHOP", "Request is pending, it may be in process or waiting on third party.");    break;
		case  23: log_warning("WORKSHOP", "Encryption or Decryption failed.");   break;
		case  24: log_warning("WORKSHOP", "Insufficient privilege.");    break;
		case  25: log_warning("WORKSHOP", "Too much of a good thing.");  break;
		case  26: log_warning("WORKSHOP", "Access has been revoked (used for revoked guest passes.)");   break;
		case  27: log_warning("WORKSHOP", "License/Guest pass the user is trying to access is expired.");    break;
		case  28: log_warning("WORKSHOP", "Guest pass has already been redeemed by account, cannot be used again."); break;
		case  29: log_warning("WORKSHOP", "The request is a duplicate and the action has already occurred in the past, ignored this time."); break;
		case  30: log_warning("WORKSHOP", "All the games in this guest pass redemption request are already owned by the user."); break;
		case  31: log_warning("WORKSHOP", "IP address not found.");  break;
		case  32: log_warning("WORKSHOP", "Failed to write change to the data store.");  break;
		case  33: log_warning("WORKSHOP", "Failed to acquire access lock for this operation.");  break;
		case  34: log_warning("WORKSHOP", "The logon session has been replaced.");   break;
		case  35: log_warning("WORKSHOP", "Failed to connect."); break;
		case  36: log_warning("WORKSHOP", "The authentication handshake has failed.");   break;
		case  37: log_warning("WORKSHOP", "There has been a generic IO failure.");   break;
		case  38: log_warning("WORKSHOP", "The remote server has disconnected.");    break;
		case  39: log_warning("WORKSHOP", "Failed to find the shopping cart requested.");    break;
		case  40: log_warning("WORKSHOP", "A user blocked the action."); break;
		case  41: log_warning("WORKSHOP", "The target is ignoring sender."); break;
		case  42: log_warning("WORKSHOP", "Nothing matching the request found.");    break;
		case  43: log_warning("WORKSHOP", "The account is disabled.");   break;
		case  44: log_warning("WORKSHOP", "This service is not accepting content changes right now.");   break;
		case  45: log_warning("WORKSHOP", "Account doesn't have value, so this feature isn't available.");   break;
		case  46: log_warning("WORKSHOP", "Allowed to take this action, but only because requester is admin.");  break;
		case  47: log_warning("WORKSHOP", "A Version mismatch in content transmitted within the Steam protocol.");   break;
		case  48: log_warning("WORKSHOP", "The current CM can't service the user making a request, user should try another.");   break;
		case  49: log_warning("WORKSHOP", "You are already logged in elsewhere, this cached credential login has failed.");  break;
		case  50: log_warning("WORKSHOP", "The user is logged in elsewhere. (Use k_EResultLoggedInElsewhere instead!)"); break;
		case  51: log_warning("WORKSHOP", "Long running operation has suspended/paused. (eg. content download.)");   break;
		case  52: log_warning("WORKSHOP", "Operation has been canceled, typically by user. (eg. a content download.)");  break;
		case  53: log_warning("WORKSHOP", "Operation canceled because data is ill formed or unrecoverable.");    break;
		case  54: log_warning("WORKSHOP", "Operation canceled - not enough disk space.");    break;
		case  55: log_warning("WORKSHOP", "The remote or IPC call has failed."); break;
		case  56: log_warning("WORKSHOP", "Password could not be verified as it's unset server side.");  break;
		case  57: log_warning("WORKSHOP", "External account (PSN, Facebook...) is not linked to a Steam account.");  break;
		case  58: log_warning("WORKSHOP", "PSN ticket was invalid.");    break;
		case  59: log_warning("WORKSHOP", "External account (PSN, Facebook...) is already linked to some other account, must explicitly request to replace/delete the link first."); break;
		case  60: log_warning("WORKSHOP", "The sync cannot resume due to a conflict between the local and remote files.");   break;
		case  61: log_warning("WORKSHOP", "The requested new password is not allowed."); break;
		case  62: log_warning("WORKSHOP", "New value is the same as the old one. This is used for secret question and answer."); break;
		case  63: log_warning("WORKSHOP", "Account login denied due to 2nd factor authentication failure."); break;
		case  64: log_warning("WORKSHOP", "The requested new password is not legal.");   break;
		case  65: log_warning("WORKSHOP", "Account login denied due to auth code invalid."); break;
		case  66: log_warning("WORKSHOP", "Account login denied due to 2nd factor auth failure - and no mail has been sent.");   break;
		case  67: log_warning("WORKSHOP", "The users hardware does not support Intel's Identity Protection Technology (IPT).");  break;
		case  68: log_warning("WORKSHOP", "Intel's Identity Protection Technology (IPT) has failed to initialize."); break;
		case  69: log_warning("WORKSHOP", "Operation failed due to parental control restrictions for current user.");    break;
		case  70: log_warning("WORKSHOP", "Facebook query returned an error.");  break;
		case  71: log_warning("WORKSHOP", "Account login denied due to an expired auth code.");  break;
		case  72: log_warning("WORKSHOP", "The login failed due to an IP restriction."); break;
		case  73: log_warning("WORKSHOP", "The current users account is currently locked for use. This is likely due to a hijacking and pending ownership verification.");   break;
		case  74: log_warning("WORKSHOP", "The logon failed because the accounts email is not verified.");   break;
		case  75: log_warning("WORKSHOP", "There is no URL matching the provided values.");  break;
		case  76: log_warning("WORKSHOP", "Bad Response due to a Parse failure, missing field, etc.");   break;
		case  77: log_warning("WORKSHOP", "The user cannot complete the action until they re-enter their password.");    break;
		case  78: log_warning("WORKSHOP", "The value entered is outside the acceptable range."); break;
		case  79: log_warning("WORKSHOP", "Something happened that we didn't expect to ever happen.");   break;
		case  80: log_warning("WORKSHOP", "The requested service has been configured to be unavailable.");   break;
		case  81: log_warning("WORKSHOP", "The files submitted to the CEG server are not valid.");   break;
		case  82: log_warning("WORKSHOP", "The device being used is not allowed to perform this action.");   break;
		case  83: log_warning("WORKSHOP", "The action could not be complete because it is region restricted.");  break;
		case  84: log_warning("WORKSHOP", "Temporary rate limit exceeded, try again later, different from k_EResultLimitExceeded which may be permanent.");  break;
		case  85: log_warning("WORKSHOP", "Need two-factor code to login."); break;
		case  86: log_warning("WORKSHOP", "The thing we're trying to access has been deleted."); break;
		case  87: log_warning("WORKSHOP", "Login attempt failed, try to throttle response to possible attacker.");   break;
		case  88: log_warning("WORKSHOP", "Two factor authentication (Steam Guard) code is incorrect."); break;
		case  89: log_warning("WORKSHOP", "The activation code for two-factor authentication (Steam Guard) didn't match.");  break;
		case  90: log_warning("WORKSHOP", "The current account has been associated with multiple partners.");    break;
		case  91: log_warning("WORKSHOP", "The data has not been modified.");    break;
		case  92: log_warning("WORKSHOP", "The account does not have a mobile device associated with it.");  break;
		case  93: log_warning("WORKSHOP", "The time presented is out of range or tolerance.");   break;
		case  94: log_warning("WORKSHOP", "SMS code failure - no match, none pending, etc.");    break;
		case  95: log_warning("WORKSHOP", "Too many accounts access this resource.");    break;
		case  96: log_warning("WORKSHOP", "Too many changes to this account.");  break;
		case  97: log_warning("WORKSHOP", "Too many changes to this phone.");    break;
		case  98: log_warning("WORKSHOP", "Cannot refund to payment method, must use wallet.");  break;
		case  99: log_warning("WORKSHOP", "Cannot send an email.");  break;
		case 100: log_warning("WORKSHOP", "Can't perform operation until payment has settled.");    break;
		case 101: log_warning("WORKSHOP", "The user needs to provide a valid captcha.");    break;
		case 102: log_warning("WORKSHOP", "A game server login token owned by this token's owner has been banned.");    break;
		case 103: log_warning("WORKSHOP", "Game server owner is denied for some other reason such as account locked, community ban, vac ban, missing phone, etc."); break;
		case 104: log_warning("WORKSHOP", "The type of thing we were requested to act on is invalid."); break;
		case 105: log_warning("WORKSHOP", "The IP address has been banned from taking this action.");   break;
		case 106: log_warning("WORKSHOP", "This Game Server Login Token (GSLT) has expired from disuse; it can be reset for use."); break;
		case 107: log_warning("WORKSHOP", "user doesn't have enough wallet funds to complete the action");  break;
		case 108: log_warning("WORKSHOP", "There are too many of this thing pending already");  break;
	} #endregion
}