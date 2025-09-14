
// Global namespace for Firebase Storage
// Merge the new methods and properties into the existing FirebaseStorageExt object
window.FirebaseStorageExt = Object.assign(window.FirebaseStorageExt || {}, {

    // Map to store tasks by listener ID for cancellation
    taskMap: {},
	lastProgressUpdateTime: {},
	min_progress_update_interval_ms: 500,

	/**
     * Helper function to check if storage is initialized.
     * Logs an error if `module` is not ready.
     * @return {boolean} `true` if `module` is ready, `false` otherwise.
     */
    isStorageInitialized: function() {
        const context = window.FirebaseStorageExt;
        if (!context.module) {
            console.warn("Firebase Storage is not initialized. Please wait for initialization to complete.");
            return false;
        }
        return true;
    },

	// Utility to convert a Blob to a Base64 string
	blobToBase64: function(blob) {
		return new Promise((resolve, reject) => {
			const reader = new FileReader();
			reader.onloadend = () => {
				const base64String = reader.result.split(',')[1]; // Remove data URL prefix
				resolve(base64String);
			};
			reader.onerror = () => {
				reject(reader.error);
			};
			reader.readAsDataURL(blob);
		});
	},

	// Utility to convert a Base64 string to a Blob
	base64ToBlob: function(base64String, contentType = '') {
		const byteCharacters = atob(base64String);
		const byteArrays = [];
		const sliceSize = 1024;

		for (let offset = 0; offset < byteCharacters.length; offset += sliceSize) {
			const slice = byteCharacters.slice(offset, offset + sliceSize);
			const byteNumbers = new Array(slice.length);
			for (let i = 0; i < slice.length; i++) {
				byteNumbers[i] = slice.charCodeAt(i);
			}
			const byteArray = new Uint8Array(byteNumbers);
			byteArrays.push(byteArray);
		}

		return new Blob(byteArrays, { type: contentType });
	},

	// Utility to estimate the size of a Base64 string in bytes
	getBase64Size: function(base64String) {
		return Math.ceil((base64String.length * 3) / 4); // Approximate size in bytes
	},

    /**
     * Generates a new listener ID.
     * @return {number} A unique listener ID.
     */
    getListenerInd: function() {
		const { getNextAsyncId } = window.FirebaseSetup;
        return getNextAsyncId();
    },

	/**
	 * Throttles progress updates to avoid sending too many events.
	 * @param {number} asyncId - The listener ID.
	 * @param {string} eventType - The type of the event.
	 * @param {string} path - The storage path.
	 * @param {string|null} localPath - The local path.
	 * @param {number} bytesTransferred - The number of bytes transferred.
	 * @param {number} totalByteCount - The total number of bytes.
	 */
	throttleProgressUpdate: function(asyncId, eventType, path, localPath, bytesTransferred, totalByteCount) {
		const { sendStorageEvent, lastProgressUpdateTime, min_progress_update_interval_ms } = window.FirebaseStorageExt;

		const currentTime = Date.now();
		const lastUpdateTime = lastProgressUpdateTime[asyncId];

		if (lastUpdateTime === undefined || (currentTime - lastUpdateTime) >= min_progress_update_interval_ms) {
			lastProgressUpdateTime[asyncId] = currentTime;

			const data = {
				transferred: bytesTransferred,
				total: totalByteCount,
			};

			sendStorageEvent(eventType, asyncId, path, localPath, true, data);
		}
	},

	/**
	 * Sends a storage event with the specified parameters.
	 * @param {string} eventType - The type of the event.
	 * @param {number} asyncId - The listener ID.
	 * @param {string} path - The storage path.
	 * @param {string|null} localPath - The local path.
	 * @param {boolean} success - Indicates if the operation was successful.
	 * @param {Object} additionalData - Additional data to include in the event.
	 */
	sendStorageEvent: function(eventType, asyncId, path, localPath, success, additionalData) {
		const { sendSocialAsyncEvent } = window.FirebaseSetup;
		
		// Initialize a new data object
		const data = {
			listener: asyncId,
			path: path,
			success: success,
		};

		if (localPath !== null && localPath !== undefined) {
			data.localPath = localPath;
		}

		if (additionalData !== null && additionalData !== undefined) {
			// Merge additionalData into data
			Object.assign(data, additionalData);
		}

		sendSocialAsyncEvent(eventType, data);
	},

});

const FIREBASE_STORAGE_SUCCESS = 0.0;
const FIREBASE_STORAGE_ERROR_NOT_FOUND = -1.0;
const FIREBASE_STORAGE_ERROR_INVALID_PARAMETERS = -2.0;
const FIREBASE_STORAGE_ERROR_NOT_INITIALIZED = -3.0;
const FIREBASE_STORAGE_ERROR_UNSUPPORTED = -4.0;

function SDKFirebaseStorage_Cancel(listener) {
    const { isStorageInitialized, taskMap, lastProgressUpdateTime } = window.FirebaseStorageExt;
    if (!isStorageInitialized()) {
        return FIREBASE_STORAGE_ERROR_NOT_INITIALIZED;
    }

    const task = taskMap[listener];
    if (task) {
        task.cancel();
        delete taskMap[listener];
        delete lastProgressUpdateTime[listener];
        return FIREBASE_STORAGE_SUCCESS;
    } else {

        return FIREBASE_STORAGE_ERROR_NOT_FOUND;
    }
}

function SDKFirebaseStorage_Upload(localStorageKey, firebasePath, bucket = '') {
    const { isStorageInitialized, module, getListenerInd, base64ToBlob, taskMap, lastProgressUpdateTime, sendStorageEvent, throttleProgressUpdate } = window.FirebaseStorageExt;

    if (!isStorageInitialized()) {
        return FIREBASE_STORAGE_ERROR_NOT_INITIALIZED;
    }

	if (typeof bucket !== 'string') {
		return FIREBASE_STORAGE_ERROR_INVALID_PARAMETERS;
	}

    const listener = getListenerInd();

    // Retrieve the Base64-encoded file data from localStorage
    const base64Data = window.localStorage.getItem(localStorageKey);
    if (!base64Data) {
		const data = { error: "File not found in localStorage." };
		sendStorageEvent('FirebaseStorage_Upload', listener, firebasePath, localStorageKey, false, data);
        return listener;
    }

    // Convert Base64 string back to Blob
    const contentType = ''; // You can store and retrieve the content type if needed
    const fileBlob = base64ToBlob(base64Data, contentType);

    // Check file size against localStorage limits (optional)
    const fileSize = fileBlob.size;
    if (fileSize > 5 * 1024 * 1024) {
		const data = { error: 'File size exceeds localStorage limits.' };
		sendStorageEvent('FirebaseStorage_Upload', listener, firebasePath, localStorageKey, false, data);
        return listener;
    }

    // Get a reference to the storage service
	bucket = bucket.length > 0 ? bucket : undefined;
    const storage = module.getStorage(undefined, bucket);
    const storageRef = module.ref(storage, firebasePath);

    // Start the upload task
    const uploadTask = module.uploadBytesResumable(storageRef, fileBlob);

    // Store the task in taskMap for cancellation
    taskMap[listener] = uploadTask;

    // Listen for state changes, errors, and completion
    uploadTask.on(
        'state_changed',
        (snapshot) => {
            // Progress updates
			throttleProgressUpdate(listener, 'FirebaseStorage_Upload', firebasePath, localStorageKey, 
				snapshot.bytesTransferred, snapshot.totalBytes);
        },
        (error) => {
            // Handle upload error
            const data = { error: error.message };
            sendStorageEvent('FirebaseStorage_Upload', listener, firebasePath, localStorageKey, false, data);
            delete taskMap[listener];
            delete lastProgressUpdateTime[listener];
        },
        () => {
            // Upload completed successfully
			sendStorageEvent('FirebaseStorage_Upload', listener, firebasePath, localStorageKey, true, null);
            delete taskMap[listener];
            delete lastProgressUpdateTime[listener];
        }
    );

    return listener;
}

function SDKFirebaseStorage_Download(localStorageKey, firebasePath, bucket = '') {
    const { isStorageInitialized, module, getListenerInd, blobToBase64, getBase64Size, sendStorageEvent } = window.FirebaseStorageExt;

    if (!isStorageInitialized()) {
        return FIREBASE_STORAGE_ERROR_NOT_INITIALIZED;
    }

	if (typeof bucket !== 'string') {
		return FIREBASE_STORAGE_ERROR_INVALID_PARAMETERS;
	}

    const listener = getListenerInd();

    // Get a reference to the storage service
	bucket = bucket.length > 0 ? bucket : undefined;
    const storage = module.getStorage(undefined, bucket);
    const storageRef = module.ref(storage, firebasePath);

    // Start the download
    module.getBytes(storageRef)
        .then((arrayBuffer) => {
            const blob = new Blob([arrayBuffer]);

            // Convert Blob to Base64 string
            return blobToBase64(blob);
        })
        .then((base64Data) => {
            // Check if the data fits into localStorage
            const dataSize = getBase64Size(base64Data);
            if (dataSize > 5 * 1024 * 1024) {
                throw new Error('Downloaded file exceeds localStorage size limits.');
            }

            // Store the Base64 string in localStorage
            window.localStorage.setItem(localStorageKey, base64Data);

            // Send success event
			sendStorageEvent('FirebaseStorage_Download', listener, firebasePath, localStorageKey, true, null);
        })
        .catch((error) => {
            // Handle error
            const data = { error: error.message };
            sendStorageEvent('FirebaseStorage_Download', listener, firebasePath, localStorageKey, false, data);
        });

    return listener;
}

function SDKFirebaseStorage_Delete(firebasePath, bucket = '') {
    const { isStorageInitialized, module, getListenerInd, sendSocialAsyncEvent } = window.FirebaseStorageExt;
    if (!isStorageInitialized()) {
        return FIREBASE_STORAGE_ERROR_NOT_INITIALIZED;
    }

	if (typeof bucket !== 'string') {
		return FIREBASE_STORAGE_ERROR_INVALID_PARAMETERS;
	}

    const listener = getListenerInd();

    // Get a reference to the storage service
	bucket = bucket.length > 0 ? bucket : undefined;
    const storage = module.getStorage(undefined, bucket);
    const storageRef = module.ref(storage, firebasePath);

    // Delete the file
    module.deleteObject(storageRef)
        .then(() => {
            // File deleted successfully
			sendStorageEvent('SDKFirebaseStorage_Delete', listener, firebasePath, null, true, null);
        })
        .catch((error) => {
            // Handle error
            const data = { error: error.message };
			sendStorageEvent('SDKFirebaseStorage_Delete', listener, firebasePath, null, false, data);
        });

    return listener;
}

function SDKFirebaseStorage_GetURL(firebasePath, bucket = '') {
    const { isStorageInitialized, module, getListenerInd, sendStorageEvent } = window.FirebaseStorageExt;
    if (!isStorageInitialized()) {
        return FIREBASE_STORAGE_ERROR_NOT_INITIALIZED;
    }

	if (typeof bucket !== 'string') {
		return FIREBASE_STORAGE_ERROR_INVALID_PARAMETERS;
	}

    const listener = getListenerInd();

    // Get a reference to the storage service
	bucket = bucket.length > 0 ? bucket : undefined;
    const storage = module.getStorage(undefined, bucket);
    const storageRef = module.ref(storage, firebasePath);

    // Get the download URL
    module.getDownloadURL(storageRef)
        .then((url) => {
			// Send success event
            const data = { value: url };
			sendStorageEvent('FirebaseStorage_GetURL', listener, firebasePath, null, true, data);
        })
        .catch((error) => {
            // Handle error
            const data = { error: error.message };
			sendStorageEvent('FirebaseStorage_GetURL', listener, firebasePath, null, false, data);
        });

    return listener;
}

function SDKFirebaseStorage_List(firebasePath, maxResults, pageToken = '', bucket = '') {
    const { isStorageInitialized, module, getListenerInd, sendStorageEvent } = window.FirebaseStorageExt;
    if (!isStorageInitialized()) {
        return FIREBASE_STORAGE_ERROR_NOT_INITIALIZED;
    }

	if (typeof pageToken !== 'string' || typeof bucket !== 'string') {
		return FIREBASE_STORAGE_ERROR_INVALID_PARAMETERS;
	}

    const listener = getListenerInd();

    // Get a reference to the storage service
	bucket = bucket.length > 0 ? bucket : undefined;
    const storage = module.getStorage(undefined, bucket);
    const storageRef = module.ref(storage, firebasePath);

    // Create list options
    const listOptions = {};
    if (maxResults) {
        listOptions.maxResults = maxResults;
    }
    if (pageToken && pageToken.length > 0) {
        listOptions.pageToken = pageToken;
    }

    // List items and prefixes
    module.list(storageRef, listOptions)
        .then((result) => {
            // Process result
            const items = result.items.map(itemRef => itemRef.fullPath);
            const prefixes = result.prefixes.map(prefixRef => prefixRef.fullPath);

            const data = { files: items, folders: prefixes };

			// Send success event
			sendStorageEvent('FirebaseStorage_List', listener, firebasePath, null, true, data);
        })
        .catch((error) => {
            // Handle error
            const data = { error: error.message };
            sendStorageEvent('FirebaseStorage_List', listener, firebasePath, null, false, data);
        });

    return listener;
}

function SDKFirebaseStorage_ListAll(firebasePath, bucket) {
    const { isStorageInitialized, module, getListenerInd, sendStorageEvent } = window.FirebaseStorageExt;
    if (!isStorageInitialized()) {
        return FIREBASE_STORAGE_ERROR_NOT_INITIALIZED;
    }

	if (typeof bucket !== 'string') {
		return FIREBASE_STORAGE_ERROR_INVALID_PARAMETERS;
	}

    const listener = getListenerInd();

    // Get a reference to the storage service
	bucket = bucket.length > 0 ? bucket : undefined;
    const storage = module.getStorage(undefined, bucket);
    const storageRef = module.ref(storage, firebasePath);

    const allItems = [];
    const allPrefixes = [];

    function listAllHelper(ref) {
        return module.listAll(ref)
            .then((res) => {
                allItems.push(...res.items.map(itemRef => itemRef.fullPath));
                allPrefixes.push(...res.prefixes.map(prefixRef => prefixRef.fullPath));

                // Recursively list prefixes
                const promises = res.prefixes.map(prefixRef => listAllHelper(prefixRef));
                return Promise.all(promises);
            })
            .catch((error) => {
                // Handle error
                const data = { error: error.message };
				sendStorageEvent('FirebaseStorage_ListAll', listener, firebasePath, null, false, data);
            });
    }

    // Start listing
    listAllHelper(storageRef)
        .then(() => {
            // Send success event
            const data = {
                files: allItems,
                folders: allPrefixes,
            };
            sendStorageEvent('FirebaseStorage_ListAll', listener, firebasePath, null, true, data);
        })
        .catch((error) => {
            // Handle error
            const data = { error: error.message };
            sendStorageEvent('FirebaseStorage_ListAll', listener, firebasePath, null, false, data);
        });

    return listener;
}

