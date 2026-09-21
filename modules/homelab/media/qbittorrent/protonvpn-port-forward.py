"""Follow Proton's NAT-PMP recipe; qBittorrent needs the allocated public port."""

import json
import re
import subprocess
import sys
import urllib.parse
import urllib.request


def request_mapping(protocol):
    try:
        result = subprocess.run(
            ["natpmpc", "-a", "1", "0", protocol, "60", "-g", "10.2.0.1"],
            check=True, capture_output=True, text=True, timeout=10,
        )
    except subprocess.CalledProcessError as error:
        raise RuntimeError(f"NAT-PMP {protocol} failed: {error.stdout} {error.stderr}") from None
    match = re.search(
        rf"Mapped public port (\d+) protocol {protocol.upper()} to local port \d+ lifetime (\d+)",
        result.stdout,
    )
    if not match:
        raise ValueError(f"Unrecognized NAT-PMP {protocol} response")
    port, lifetime = map(int, match.groups())
    if not 1024 <= port <= 65535 or lifetime < 60:
        raise ValueError(f"Invalid NAT-PMP {protocol} port or lease lifetime")
    return port


def update_client(base_url, port):
    # Never use a host HTTP proxy for this local, unauthenticated API.
    opener = urllib.request.build_opener(urllib.request.ProxyHandler({}))
    data = urllib.parse.urlencode({"json": json.dumps({"listen_port": port, "upnp": False})})
    request = urllib.request.Request(
        base_url + "/api/v2/app/setPreferences",
        data=data.encode(), headers={"Referer": base_url},
    )
    with opener.open(request, timeout=5) as response:
        response.read()
    with opener.open(base_url + "/api/v2/app/preferences", timeout=5) as response:
        preferences = json.load(response)
    if preferences["listen_port"] != port or preferences["upnp"]:
        raise ValueError("qBittorrent did not apply the forwarded port")


def renew(base_url):
    udp_port = request_mapping("udp")
    tcp_port = request_mapping("tcp")
    if udp_port != tcp_port:
        raise ValueError("Proton allocated different UDP and TCP ports")
    update_client(base_url, tcp_port)
    return tcp_port


if __name__ == "__main__":
    port = renew(sys.argv[1])
    print(f"Proton forwarded TCP/UDP port {port}", flush=True)
