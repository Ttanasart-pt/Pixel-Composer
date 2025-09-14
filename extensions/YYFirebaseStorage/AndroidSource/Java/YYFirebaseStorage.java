package ${YYAndroidPackageName};
import ${YYAndroidPackageName}.R;
import ${YYAndroidPackageName}.FirebaseUtils;

import android.app.Activity;
import android.util.Log;

import com.google.firebase.storage.FirebaseStorage;
import com.google.firebase.storage.OnProgressListener;
import com.google.firebase.storage.StorageReference;
import com.google.firebase.storage.StorageTask;
import com.google.firebase.storage.FileDownloadTask;
import com.google.firebase.storage.UploadTask;
import com.google.firebase.storage.ListResult;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;

import org.json.JSONArray;

import android.net.Uri;
import java.io.File;
import java.lang.Exception;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

import androidx.annotation.NonNull;

public class YYFirebaseStorage extends RunnerSocial {

    private static final String LOG_TAG = "YYFirebaseStorage";
    private static final long MIN_PROGRESS_UPDATE_INTERVAL_MS = 500; // Minimum interval between progress updates

    // Error Codes
    public static final double FIREBASE_STORAGE_SUCCESS = 0.0;
    public static final double FIREBASE_STORAGE_ERROR_NOT_FOUND = -1.0;

    private HashMap<Long, StorageTask<?>> taskMap;
    private HashMap<Long, Long> lastProgressUpdateTime;

    public YYFirebaseStorage() {
        taskMap = new HashMap<>();
        lastProgressUpdateTime = new HashMap<>();
    }

    // <editor-fold desc="General API">

	public double SDKFirebaseStorage_Cancel(double ind) {
		long asyncId = (long) ind; // Convert double to long
		StorageTask<?> task = taskMap.remove(asyncId);
		if (task != null) {
			task.cancel();
			return FIREBASE_STORAGE_SUCCESS;
		} else {
			return FIREBASE_STORAGE_ERROR_NOT_FOUND;
		}
	}

    public double SDKFirebaseStorage_Download(final String localPath, final String firebasePath, final String bucket) {
		final long asyncId = getNextAsyncId();
	
		FirebaseUtils.getInstance().submitAsyncTask(() -> {
			try {
				Activity activity = RunnerActivity.CurrentActivity;
				File localFile = new File(activity.getFilesDir(), localPath);
				StorageReference storageRef = FirebaseStorage.getInstance().getReference().child(firebasePath);
	
				StorageTask<FileDownloadTask.TaskSnapshot> task = storageRef.getFile(localFile)
						.addOnSuccessListener(taskSnapshot -> {
							taskMap.remove(asyncId);
                            lastProgressUpdateTime.remove(asyncId);
							sendStorageEvent("FirebaseStorage_Download", asyncId, firebasePath, localPath, true, null);
						})
						.addOnFailureListener(e -> {
							taskMap.remove(asyncId);
                            lastProgressUpdateTime.remove(asyncId);
							Map<String, Object> data = new HashMap<>();
							data.put("error", e.getMessage());
							sendStorageEvent("FirebaseStorage_Download", asyncId, firebasePath, localPath, false, data);
						})
						.addOnProgressListener(taskSnapshot -> {
							throttleProgressUpdate(asyncId, "FirebaseStorage_Download", firebasePath, localPath,
									taskSnapshot.getBytesTransferred(), taskSnapshot.getTotalByteCount());
						});
	
				taskMap.put(asyncId, task);
			} catch (Exception e) {
				Log.e(LOG_TAG, "Error in download: " + e.getMessage());
				Map<String, Object> data = new HashMap<>();
				data.put("error", e.getMessage());
				sendStorageEvent("FirebaseStorage_Download", asyncId, firebasePath, localPath, false, data);
			}
		});
	
		return (double) asyncId;
	}

    public double SDKFirebaseStorage_Upload(final String localPath, final String firebasePath, final String bucket) {
        final long asyncId = getNextAsyncId();

        FirebaseUtils.getInstance().submitAsyncTask(() -> {
            try {
				Activity activity = RunnerActivity.CurrentActivity;
                File localFile = new File(activity.getFilesDir(), localPath);
                if (!localFile.exists()) {
                    throw new Exception("Local file does not exist: " + localPath);
                }
                Uri uriFile = Uri.fromFile(localFile);
                StorageReference storageRef = FirebaseStorage.getInstance().getReference().child(firebasePath);

                StorageTask<UploadTask.TaskSnapshot> task = storageRef.putFile(uriFile)
                        .addOnSuccessListener(taskSnapshot -> {
                            taskMap.remove(asyncId);
                            lastProgressUpdateTime.remove(asyncId);
                            sendStorageEvent("FirebaseStorage_Upload", asyncId, firebasePath, localPath, true, null);
                        })
                        .addOnFailureListener(e -> {
                            taskMap.remove(asyncId);
                            lastProgressUpdateTime.remove(asyncId);
                            Map<String, Object> data = new HashMap<>();
                            data.put("error", e.getMessage());
                            sendStorageEvent("FirebaseStorage_Upload", asyncId, firebasePath, localPath, false, data);
                        })
                        .addOnProgressListener(taskSnapshot -> {
                            throttleProgressUpdate(asyncId, "FirebaseStorage_Upload", firebasePath, localPath,
                                    taskSnapshot.getBytesTransferred(), taskSnapshot.getTotalByteCount());
                        });

                taskMap.put(asyncId, task);
            } catch (Exception e) {
                Log.e(LOG_TAG, "Error in upload: " + e.getMessage());
                Map<String, Object> data = new HashMap<>();
                data.put("error", e.getMessage());
                sendStorageEvent("FirebaseStorage_Upload", asyncId, firebasePath, localPath, false, data);
            }
        });

        return (double) asyncId;
    }

    public double SDKFirebaseStorage_Delete(final String firebasePath, final String bucket) {
        final long asyncId = getNextAsyncId();

        FirebaseUtils.getInstance().submitAsyncTask(() -> {
            StorageReference storageRef = FirebaseStorage.getInstance().getReference().child(firebasePath);
            storageRef.delete()
                    .addOnSuccessListener(aVoid -> {
                        sendStorageEvent("FirebaseStorage_Delete", asyncId, firebasePath, null, true, null);
                    })
                    .addOnFailureListener(e -> {
                        Map<String, Object> data = new HashMap<>();
                        data.put("error", e.getMessage());
                        sendStorageEvent("FirebaseStorage_Delete", asyncId, firebasePath, null, false, data);
                    });
        });

        return (long) asyncId;
    }

    public double SDKFirebaseStorage_GetURL(final String firebasePath, final String bucket) {
        final long asyncId = getNextAsyncId();

        FirebaseUtils.getInstance().submitAsyncTask(() -> {
            StorageReference storageRef = FirebaseStorage.getInstance().getReference().child(firebasePath);
            storageRef.getDownloadUrl()
                    .addOnSuccessListener(uri -> {
                        Map<String, Object> data = new HashMap<>();
                        data.put("value", uri.toString());
                        sendStorageEvent("FirebaseStorage_GetURL", asyncId, firebasePath, null, true, data);
                    })
                    .addOnFailureListener(e -> {
                        Map<String, Object> data = new HashMap<>();
                        data.put("error", e.getMessage());
                        sendStorageEvent("FirebaseStorage_GetURL", asyncId, firebasePath, null, false, data);
                    });
        });

        return (double) asyncId;
    }

    public double SDKFirebaseStorage_List(final String firebasePath, double maxResults, String pageToken, String bucket) {
        final long asyncId = getNextAsyncId();

        FirebaseUtils.getInstance().submitAsyncTask(() -> {
            StorageReference storageRef = FirebaseStorage.getInstance().getReference().child(firebasePath);
            Task<ListResult> task;
            if (pageToken == null || pageToken.isEmpty()) {
                task = storageRef.list((int) maxResults);
            } else {
                task = storageRef.list((int) maxResults, pageToken);
            }

            task.addOnCompleteListener(taskResult -> {
                if (taskResult.isSuccessful()) {
                    ListResult result = taskResult.getResult();
                    Map<String, Object> data = new HashMap<>();
                    data.put("pageToken", result.getPageToken() != null ? result.getPageToken() : "");
                    data.put("files", listOfReferencesToJSON(result.getItems()));
                    data.put("folders", listOfReferencesToJSON(result.getPrefixes()));
                    sendStorageEvent("FirebaseStorage_List", asyncId, firebasePath, null, true, data);
                } else {
                    Map<String, Object> data = new HashMap<>();
                    data.put("error", taskResult.getException().getMessage());
                    sendStorageEvent("FirebaseStorage_List", asyncId, firebasePath, null, false, data);
                }
            });
        });

        return (double) asyncId;
    }

    public double SDKFirebaseStorage_ListAll(final String firebasePath, String bucket) {
        final long asyncId = getNextAsyncId();

        FirebaseUtils.getInstance().submitAsyncTask(() -> {
            StorageReference storageRef = FirebaseStorage.getInstance().getReference().child(firebasePath);
            storageRef.listAll()
                    .addOnCompleteListener(taskResult -> {
                        if (taskResult.isSuccessful()) {
                            ListResult result = taskResult.getResult();
                            Map<String, Object> data = new HashMap<>();
                            data.put("files", listOfReferencesToJSON(result.getItems()));
                            data.put("folders", listOfReferencesToJSON(result.getPrefixes()));
                            sendStorageEvent("FirebaseStorage_ListAll", asyncId, firebasePath, null, true, data);
                        } else {
                            Map<String, Object> data = new HashMap<>();
                            data.put("error", taskResult.getException().getMessage());
                            sendStorageEvent("FirebaseStorage_ListAll", asyncId, firebasePath, null, false, data);
                        }
                    });
        });

        return (double) asyncId;
    }

    // </editor-fold>

    // <editor-fold desc="Helper Methods">

    private long getNextAsyncId() {
        return FirebaseUtils.getInstance().getNextAsyncId();
    }

    private String listOfReferencesToJSON(List<StorageReference> list) {
        try {
            JSONArray array = new JSONArray();
            for (StorageReference ref : list) {
                array.put(ref.getPath());
            }
            return array.toString();
        } catch (Exception e) {
            Log.e(LOG_TAG, "Error converting list to JSON: " + e.getMessage());
            return "[]";
        }
    }

	private void sendStorageEvent(String eventType, long asyncId, String path, String localPath, boolean success, Map<String, Object> additionalData) {
		
        // Initialize a new map with the contents of the source map
        Map<String, Object> data = new HashMap<>();
        data.put("listener", (double) asyncId); // Convert to double here
		data.put("path", path);
		if (localPath != null) {
			data.put("localPath", localPath);
		}
		data.put("success", success);
        if (additionalData != null) {
            data.putAll(additionalData);
        }
		FirebaseUtils.sendSocialAsyncEvent(eventType, data);
	}

	private void throttleProgressUpdate(long asyncId, String eventType, String path, String localPath, long bytesTransferred, long totalByteCount) {
		long currentTime = System.currentTimeMillis();
		Long lastUpdateTime = lastProgressUpdateTime.get(asyncId);
		if (lastUpdateTime == null || (currentTime - lastUpdateTime) >= MIN_PROGRESS_UPDATE_INTERVAL_MS) {
			lastProgressUpdateTime.put(asyncId, currentTime);
	
			Map<String, Object> data = new HashMap<>();
			data.put("transferred", (double) bytesTransferred);
			data.put("total", (double) totalByteCount);
	
			sendStorageEvent(eventType, asyncId, path, localPath, true, data);
		}
	}

    // </editor-fold>
}