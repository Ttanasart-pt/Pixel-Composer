#!/bin/bash
set echo off

# Useful for printing all variables
# ( set -o posix ; set ) | less

# ############################################## WARNING ##############################################
#      THIS FILE IS SHOULD NOT BE CHANGED AND THE OPTIONS SHOULD BE CONTROLLED THROUGH THE IDE.
# #####################################################################################################

function error_incorrect_STEAMWORKS_path () {
    echo ""
    echo "######################################################## ERROR ########################################################"
    echo "The specified steamworks SDK path doesn't exist please edit the file 'post_build_step.sh' in your project's root folder"
    echo "#######################################################################################################################"
    echo ""
    exit 1
}

function macOS_copy_dependencies () {

    echo "Copying macOS (64 bit) dependencies"
    if [[ "$YYTARGET_runtime" == "VM" ]]; then
        cp "${STEAM_SDK_PATH}redistributable_bin/osx/libsteam_api.dylib" "libsteam_api.dylib"
        # debug check for VM
        if [[ "$YYEXTOPT_Steamworks_Debug" == "Enabled" ]] || [[ "$YYtargetFile" == "" ]] || [[ "$YYtargetFile" == " " ]]; then
            echo "Running VM macOS Steamworks project on macOS via IDE, enabling Debug..."
            echo [SteamworksUtils]>>options.ini
			echo RunningFromIDE=True>>options.ini
        fi
    else
        cp "${STEAM_SDK_PATH}redistributable_bin/osx/libsteam_api.dylib" "${YYprojectName}/${YYprojectName}/Supporting Files/libsteam_api.dylib"
        # debug check for YYC
        if [[ "$YYEXTOPT_Steamworks_Debug" == "Enabled" ]] || [[ "$YYtargetFile" == "" ]] || [[ "$YYtargetFile" == " " ]]; then
            echo "Running YYC macOS Steamworks project on macOS via IDE, enabling Debug..."
            echo [SteamworksUtils]>>"${YYprojectName}/${YYprojectName}/Supporting Files/options.ini"
			echo RunningFromIDE=True>>"${YYprojectName}/${YYprojectName}/Supporting Files/options.ini"
        fi
    fi
}

function Linux_copy_dependencies () {

    echo "Copying Linux (64 bit) dependencies"
    unzip ${YYprojectName}.zip -d ./_temp

    if [[ ! -f "_temp/assets/libsteam_api.so" ]]; then
        cp "${STEAM_SDK_PATH}redistributable_bin/linux64/libsteam_api.so" "_temp/assets/libsteam_api.so"
    fi
	
    if [[ "$YYEXTOPT_Steamworks_Debug" == "Enabled" ]] || [[ "$YYtargetFile" != "" ]]; then
		echo "Running Linux Steamworks project on Linux via IDE, enabling Debug..."
		echo [SteamworksUtils]>>"_temp/assets/options.ini"
		echo RunningFromIDE=True>>"_temp/assets/options.ini"
    fi
	
	cd _temp; zip -FS -r ../${YYprojectName}.zip *
    cd ..
    rm -r _temp
}

# Read extension options or use default (development) value
if [[ "${YYEXTOPT_Steamworks_SteamSDK}" == "" ]]; then
    STEAM_SDK_PATH=$(dirname $(dirname $(dirname $(dirname "$0"))))/steamworks_sdk
else
    STEAM_SDK_PATH=${YYEXTOPT_Steamworks_SteamSDK}
fi

# Ensure the provided path ends with a slash
if [[ "$STEAM_SDK_PATH" !=  */ ]]; then
    STEAM_SDK_PATH=${STEAM_SDK_PATH}/
fi

# Ensure the path exists
if [[ ! -d "$STEAM_SDK_PATH" ]]; then
    error_incorrect_STEAMWORKS_path
fi

# Ensure we are on the output path
pushd "$YYoutputFolder" 1>/dev/null

# Call setup method depending on the platform
# NOTE: the setup method can be (:MacOS_copy_dependencies or :Linux_copy_dependencies)
{ # try
    ${YYPLATFORM_name}_copy_dependencies 2>/dev/null
} || { # catch
    echo ""
    echo "#################################### INFORMATION ####################################"
    echo "Steam Extension is not available in this target: $YYPLATFORM_name (no setup required)"
    echo "#####################################################################################"
    echo ""
}

popd 1>/dev/null

# exit
exit 0
