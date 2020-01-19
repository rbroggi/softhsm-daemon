## Software HSM in segregated hardware (and possibly network) exposing PKCS#11 interface

In this small repo the idea is to have two different containers:

1. A container representing a HSM that exposes a PKCS#11 interface using tls
2. A container representing an HSM client that connects to it.

This aims show how a test environment could be setup without the need to have specific hardware for it.
This POC works thanks to:
* [SoftHSM](https://github.com/opendnssec/SoftHSMv2) - A software implementation of a Hardware Security Module;
* [pkcs11-proxy](https://github.com/SUNET/pkcs11-proxy) - A proxy for accessing the remote PKCS11 HSM interface. It works with a daemon in the server side plus a client module in the client side;

The only dependency for this repo to work is docker. For a better overview of the software used please refer to the specific Dockerfiles.

The containers could probably be smaller and for a more mature solution a multi-stage build should be considered.

## Usage

1. Clone the repo and jump into the repo directory:
```bash
git clone https://github.com/rbroggi/softhsm-daemon.git
cd softhsm-daemon
```
2. Build the daemon image:
```bash
docker build -t softhsm-daemon .
```
3. Build the client image:
```bash
docker build -t softhsm-client -f Dockerfile.client .
```
4. Run the daemon image in a container named 'hsm':
```bash
docker run -d --name hsm softhsm-daemon
```
5. Run the client image (in interactive mode ) in a container linking to the daemon container:
```bash
docker run --rm -it --link=hsm:hsm softhsm-client bash
```
6. From within the client container list the slots in the daemon container:
```bash
pkcs11-tool --module=/usr/local/lib/libpkcs11-proxy.so -L
```

In this setup the connection between the two containers is encrypted with tls. check inside the image definitions the variables:
* PKCS11_DAEMON_SOCKET
* PKCS11_PROXY_SOCKET
* PKCS11_PROXY_TLS_PSK_FILE


