I have a synology and I wanted to use wireguard on it without messing around with kernel modules.
So I made myself a docker image with [boringtun](https://github.com/cloudflare/boringtun) and the various wireguard tools.

I build the image using `docker build --tag registry.example.org/zoredache/boringtun .` and push to my local registry.
If you have or want to use a local registry just take the image with whatever name you like.

I manually created a local wireguard configuration file wg0.conf.
I created a synology account 'wireguard' and put the in configs in `/var/services/homes/wireguard/wg0.conf`.

Then I start a container with a compose file like this.

    version: "2"
    services:
      boringtun:
        # privileged: true
        image: registry.example.org/zoredache/boringtun
        devices:
        - "/dev/net/tun:/dev/net/tun"
        cap_add:
        - NET_ADMIN
        network_mode: host
        volumes:
        - "/var/services/homes/wireguard/wg0.conf:/etc/wireguard/wg0.conf"
