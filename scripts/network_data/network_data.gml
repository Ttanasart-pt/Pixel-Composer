globalvar NETWORK_LOG, NETWORK_LOG_DATA;
NETWORK_LOG = [];
NETWORK_LOG_DATA = {};

#macro network_create_socket Network_create_socket
#macro __network_create_socket network_create_socket

function Network_create_socket(type) {
    var c = __network_create_socket(type);
    array_push(NETWORK_LOG, new notification(NOTI_TYPE.internal, $"Created socket {c} of type {type}"));
    
    return c;
}

#macro network_create_server_raw Network_create_server_raw
#macro __network_create_server_raw network_create_server_raw

function Network_create_server_raw(type, port, max_client) {
    var s = __network_create_server_raw(type, port, max_client);
    array_push(NETWORK_LOG, new notification(NOTI_TYPE.internal, $"Created server {s} of type {type} at port {port} (mclient {max_client})"));
    
    return s;
}

#macro network_destroy Network_destroy
#macro __network_destroy network_destroy

function Network_destroy(server) {
    __network_destroy(server);
    array_push(NETWORK_LOG, new notification(NOTI_TYPE.internal, $"Destroy server {server}"));
}

#macro url_open URL_open
#macro __url_open url_open

function URL_open(url) {
    __url_open(url);
    array_push(NETWORK_LOG, new notification(NOTI_TYPE.internal, $"Open {url}"));
}