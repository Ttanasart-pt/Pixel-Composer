#!/bin/bash

SCRIPT_PATH="$0"

# Auxiliar Functions

# Script initialization
# Usage: scriptInit
scriptInit() {
    LOG_LABEL="UNSET"
    LOG_LEVEL=-1
    EXTENSION_NAME=

    # Get extension data
    pathExtractBase "$SCRIPT_PATH" EXTENSION_NAME
    extensionGetVersion EXTENSION_VERSION

    if [ -z "$EXTENSION_VERSION" ]; then
        EXTENSION_VERSION="0.0.0"
    fi

    # Setup logger
    toUpper $EXTENSION_NAME LOG_LABEL
    optionGetValue "logLevel" LOG_LEVEL
    if [ -z "$LOG_LEVEL" ]; then
        LOG_LEVEL=2
    fi

    # Check if the operation succeeded
    if [ "$?" -ne 0 ]; then
        log "INIT" "Script initialization failed (v$EXTENSION_VERSION :: $LOG_LEVEL)."
    else
        log "INIT" "Script initialization succeeded (v$EXTENSION_VERSION :: $LOG_LEVEL)."
    fi
}

# Gets the extension version value
# Usage: extensionGetVersion result
extensionGetVersion() {
    # Enable indirect variable reference
    set -f
    local var="GMEXT_${EXTENSION_NAME}_version"
    local result="${!var}"
    set +f

    logInformation "Accessed extension version with value '${result}'."
    printf -v "$1" "%s" "$result"
}

# Gets an extension option value
# Usage: optionGetValue optionName result
optionGetValue() {
    # Enable indirect variable reference
    set -f
    local var="YYEXTOPT_${EXTENSION_NAME}_$1"
    local result="${!var}"
    set +f

    logInformation "Accessed extension option '${1}' with value '${result}'."
    printf -v "$2" "%s" "$result"
}

# Sets a string to uppercase
toUpper() { # str result
    local _result
    _result=$(echo "$1" | tr '[:lower:]' '[:upper:]')
    printf -v "$2" "%s" "$_result"
    logInformation "Converted string '$1' to upper case."
}


# Extracts the full folder path from a filepath
# Usage: pathExtractDirectory fullpath result
pathExtractDirectory() {
    local _result
    _result="$(dirname "$1")"
    printf -v "$2" "%s" "$_result"
    logInformation "Extracted directory path from '$1'."
}


# Extracts the parent folder from a path
# Usage: pathExtractBase fullpath result
pathExtractBase() {
    local _result
    _result="$(basename "$(dirname "$1")")"
    printf -v "$2" "%s" "$_result"
    logInformation "Extracted base name from '$1'."
}

# Resolves a relative or absolute path to an absolute path
# Usage: pathResolve basePath relativePath result
pathResolve() {
    local basePath="$1"
    local relativePath="$2"
    local resolvedPath=
    local combined_path
    local result=()

    # Ensure 'basePath' ends with a forward slash
    [[ "${basePath: -1}" != "/" ]] && basePath+="/"

    # If 'relativePath' starts with "/", set 'combined_path' to 'relativePath'
    if [[ "${relativePath:0:1}" == "/" ]]; then
        combined_path="$relativePath"
    else
        # Concatenate the paths
        combined_path="$basePath$relativePath"
    fi

    # Split the path into an array by the character "/"
    IFS="/" read -ra path_parts <<< "$combined_path"

    # Remove any entries that are "." and if an entry is "..", remove that entry and the previous one
    for part in "${path_parts[@]}"; do
        if [ "$part" == "." ] || [ -z "$part" ]; then
            continue
        elif [ "$part" == ".." ]; then
            unset result[${#result[@]}-1]
        else
            result+=("$part")
        fi
    done

    # Merge the final array using "/" as a delimiter
    resolvedPath="/"
    for i in "${!result[@]}"; do
        resolvedPath+="${result[i]}"
        if [ "$i" -lt $((${#result[@]}-1)) ]; then
            resolvedPath+="/"
        fi
    done

    # Return the merged result
    logInformation "Resolved path into '$resolvedPath'."
    printf -v "$3" "%s" "$resolvedPath"
}


# Resolves an existing relative path if required (handles errors)
# Usage: pathResolveExisting basePath relativePath result
pathResolveExisting() {
    local existingPath=""
    pathResolve "$1" "$2" existingPath

    # Check if the path is valid
    if [ ! -e "$existingPath" ]; then
        logError "Path '$existingPath' does not exist or is not accessible."
    fi
    
    eval "$3=\"$existingPath\""
}

# Copies a file or folder to the specified destination folder
# Usage: itemCopyTo srcPath destFolder
itemCopyTo() {
    local source="$1"
    local destination="$2"
    local resolved_destination=""

    # Resolve the destination folder to an absolute path
    pathResolve "$PWD" "$destination" resolved_destination

    # If 'resolved_destination' ends with a "/", ensure the path exists
    if [[ "${resolved_destination: -1}" == "/" ]]; then
        mkdir -p "$resolved_destination"
    else
        # Create all parent directories up until the destination path
        parent_directory=$(dirname "$resolved_destination")
        mkdir -p "$parent_directory"
    fi

    if [ -d "$source" ]; then
        # Source is a folder
        cp -rf "$source" "$resolved_destination"
    elif [ -f "$source" ]; then
        # Source is a file
        cp -f "$source" "$resolved_destination"
    else
        logError "Failed to copy '$source' does not exist or is not accessible."
        exit 1
    fi

    if [ $? -ne 0 ]; then
        logError "Failed to copy '$source' to '$resolved_destination'."
        exit 1
    fi

    logInformation "Copied '$source' to '$resolved_destination'."
}

# Deletes a file or folder given a path
# Usage: itemDelete folderPath
itemDelete() {
    target_path="$1"

    if [ -d "$target_path" ]; then
        # Is a folder
        rm -rf "$target_path"
    elif [ -f "$target_path" ]; then
        # Is a file
        rm -f "$target_path"
    else
        logWarning "Path '$target_path' does not exist. Skipping deletion."
        return 0
    fi

    if [ $? -ne 0 ]; then
        logError "Failed to delete '$target_path'."
        return 1
    fi

    logInformation "Deleted '$target_path'."
    return 0
}

# Generates the SHA256 hash of a file and stores it into a variable
# Usage: fileGetHash filepath result
fileGetHash() {
    local file="$1"
    local hash=""

    if [ ! -f "$file" ]; then
        logError "Failed to generate hash for '$file' does not exist or is not a file."
        exit 1
    fi

    hash=$(shasum -a 256 "$file" | awk '{print $1}')

    if [ $? -ne 0 ]; then
        logError "Failed to generate hash for '$file'."
        exit 1
    fi

    toUpper "$hash" hash

    eval "$2=\"$hash\""
    logInformation "Generated SHA256 hash of '$file'."
}

# Extracts the contents of a zip file to the specified destination folder
# Usage: fileExtract srcFile destFolder
fileExtract() {
    local source="$1"
    local destination="$2"

    # Create the destination folder if it doesn't exist
    mkdir -p "$destination"

    # Extract the zip file to the destination folder
    unzip -q "$source" -d "$destination"

    if [ $? -ne 0 ]; then
        logError "Failed to extract contents of '$source' to '$destination'."
        exit 1
    fi

    logInformation "Extracted contents of '$source' to '$destination'."
}

# Compresses the contents of a folder into a zip file
# Usage: folderCompress srcFolder destFile
folderCompress() {
    local source=$1
    local destination=$2
    
    # Make sure destination exists
    touch "$destination"

    # Get the absolute path of the destination zip
    local abs_destination=$(readlink -f "$destination")
    
    # Change directory to the folder
    cd "$source" || logError "Source folder doesn't exist ''"
    
    # Compress the contents of the folder into the destination zip
    zip -r -q "$abs_destination" *
    
    if [ $? -ne 0 ]; then
        logError "Failed to compress contents of '$source' into '$destination'."
        exit 1
    fi

    # Change back to the original directory
    cd - >/dev/null 2>&1

    logInformation "Compressed contents of '$source' into '$destination'."
}

# Adds the contents of a folder into a zip file
# Usage: zipUpdate srcFolder destFile
zipUpdate() {
    local source=$1
    local destination=$2
    
    # Make sure destination exists
    touch "$destination"

    # Get the absolute path of the destination zip
    local abs_destination=$(readlink -f "$destination")
    
    # Change directory to the folder
    cd "$source" || logError "Source folder doesn't exist ''"
    
    # Update the contents of the folder into the destination zip
    zip -ur -q "$abs_destination" *
    
    if [ $? -ne 0 ]; then
        logError "Failed to compress contents of '$source' into '$destination'."
        exit 1
    fi

    # Change back to the original directory
    cd - >/dev/null 2>&1

    logInformation "Compressed contents of '$source' into '$destination'."
}

# Extracts a specified part of a version string and stores it into a variable
# Usage: versionExtract version part result
versionExtract() {
    local version="$1"
    local part="$2"

    # Use awk to extract the specified part of the version string
    local result="$(echo "$version" | awk -F '.' "{print \$$part}")"

    # Store the result in the specified variable
    eval "$3=\"$result\""

    # Display a log message
    logInformation "Extracted part $part of version '$version' with value '$result'."
}

# Compares two version numbers (w.x.y.z) and saves result into variable
# Usage: versionCompare version1 version2 result
versionCompare() {
    local version1="$1"
    local version2="$2"

    # Use awk to split the version numbers into components
    local version1_parts=($(echo "$version1" | awk -F '.' '{print $1,$2,$3,$4}'))
    local version2_parts=($(echo "$version2" | awk -F '.' '{print $1,$2,$3,$4}'))

    # Compare the components of the version numbers
    for i in {0..3}; do
        if [ "${version1_parts[$i]}" -lt "${version2_parts[$i]}" ]; then
        result=-1
        break
        elif [ "${version1_parts[$i]}" -gt "${version2_parts[$i]}" ]; then
        result=1
        break
        else
        result=0
        fi
    done

    # Store the result in the specified variable
    eval "$3=\"$result\""

    # Display a log message
    logInformation "Compared version '$version1' with version '$version2'."
}

# Check minimum required versions for STABLE|BETA|DEV releases
# Usage: versionLockCheck version stableVersion betaVersion devVersion
versionLockCheck() {
    local version="$1"
    local stableVersion="$2"
    local betaVersion="$3"
    local devVersion="$4"
    local ltsVersion="$5"

    # Extract the major and minor version numbers from the given version
    local runnerBuild=
    local majorVersion=
    local minorVersion=
    versionExtract "$version" 1 majorVersion
    versionExtract "$version" 2 minorVersion

    if [ "$minorVersion" -eq 0 ]; then
        # LTS version
        runnerBuild=LTS
        assertVersionRequired "$version" "$ltsVersion" "The $runnerBuild runtime version needs to be at least v$ltsVersion."

    elif [ "$majorVersion" -ge 2020 ]; then
        if [ "$minorVersion" -ge 100 ]; then
            # Beta version
            runnerBuild=BETA
            assertVersionRequired "$version" "$betaVersion" "The $runnerBuild runtime version needs to be at least v$betaVersion."
        else
            # Stable version
            runnerBuild=STABLE
            assertVersionRequired "$version" "$stableVersion" "The $runnerBuild runtime version needs to be at least v$stableVersion."
        fi
    else
        # Dev version
        runnerBuild=DEV
        assertVersionRequired "$version" "$devVersion" "The $runnerBuild runtime version needs to be at least v$devVersion."
    fi

    logInformation "Version lock check passed successfully, with version '$version'."
}

# ASSERTS

# Asserts the SHA256 hash of a file, logs an error message and throws an error if they do not match
# Usage: assertFileHashEquals filepath expected message
assertFileHashEquals() {
    local filepath="$1"
    local expected="$2"
    local message="$3"

    # Generate hash
    local actualHash=
    fileGetHash "$filepath" actualHash

    # Compare the actual hash with the expected hash
    if [ "$actualHash" != "$expected" ]; then
        logError "$message"
        exit 1
    fi

    # Log a message
    logInformation "Asserted SHA256 hash of '$filepath' matches expected hash."
}

# Asserts that the given version string is greater than the expected version string, logs an error message and throws an error if not
# Usage: assertVersionRequired version expected message
assertVersionRequired() {
    local version="$1"
    local expected="$2"
    local message="$3"

    # Compare the two version strings using versionCompare
    local compareResult=
    versionCompare "$version" "$expected" compareResult

    # Check the result and log an error message and throw an error if not greater
    if [ "$compareResult" -lt 0 ]; then
        logError "$message"
        exit 1
    fi

    # Log a message
    logInformation "Asserted that version '$version' is greater than or equal to version '$expected'."
}

# Asserts that the given version string is equal to the expected version string, logs an error message and throws an error if not
# Usage: assertVersionEquals version expected message
assertVersionEquals() {
    local version="$1"
    local expected="$2"
    local message="$3"

    # Compare the two version strings using versionCompare
    local compareResult=
    versionCompare "$version" "$expected" compareResult

    # Check the result and log an error message and throw an error if not equal
    if [ "$compareResult" -ne 0 ]; then
        logError "$message"
        exit 1
    fi

    # Log a message
    logInformation "Asserted that version '$version' equals version '$expected'."
}

# Asserts that Command Line Tools are installed, logs an error message and throws an error if not
# Usage: assertXcodeToolsInstalled
assertXcodeToolsInstalled() {
    # Check for Command Line Tools by querying the location of 'xcode-select'
    xcode_select_path=$(xcode-select -p &> /dev/null)

    # Check the exit code of the previous command
    if [ $? -ne 0 ]; then
        logWarning "Xcode Command Line Tools are not installed."
        logWarning "Please run 'xcode-select --install' to install them."
        logError "Unable to find Xcode Command Line Tools."
    else
        logInformation "Xcode Command Line Tools are installed."
    fi
}


# Logging

# Logs information
# Usage: logInformation message
logInformation() {
    if [ "$LOG_LEVEL" -ge 2 ]; then
        log "INFO" "$1"
    fi
}

# Logs warning
# Usage: logWarning message
logWarning() {
    if [ "$LOG_LEVEL" -ge 1 ]; then
        log "WARN" "$1"
    fi
}

# Logs error
# Usage: logError message
logError() {
    if [ "$LOG_LEVEL" -ge 0 ]; then
        log "ERROR" "$1"
    fi
    exit 1
}

# General log function
# Usage: log tag message
log() {
    echo "[$LOG_LABEL] $1: $2"
}

