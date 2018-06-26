# uphold/bitcoin-gold

A Bitcoin Gold docker image.

[![uphold/bitcoin-gold][docker-pulls-image]][docker-hub-url] [![uphold/bitcoin-gold][docker-stars-image]][docker-hub-url] [![uphold/bitcoin-gold][docker-size-image]][docker-hub-url] [![uphold/bitcoin-gold][docker-layers-image]][docker-hub-url]

## Tags

- `0.15.1-rc1-alpine`, `0.15-alpine`, `alpine`, `latest` ([0.15/alpine/Dockerfile](https://github.com/uphold/docker-bitcoin-gold/blob/master/0.15/alpine/Dockerfile))
- `0.15.1-rc1`, `0.15`  ([0.15/Dockerfile](https://github.com/uphold/docker-bitcoin-gold/blob/master/0.15/Dockerfile))

## What is Bitcoin Gold?

Bitcoin Gold is a fork of the Bitcoin blockchain. At block 491407, Bitcoin Gold miners began creating blocks with a new proof-of-work algorithm, and this caused a bifurcation of the Bitcoin blockchain. The new branch is a distinct blockchain with the same transaction history as Bitcoin up until the fork, but then diverges from it. As a result of this process, a new cryptocurrency was born. Learn more about [Bitcoin Gold](https://bitcoingold.org).

## Usage

### How to use this image

This image contains the main binaries from the Bitcoin Gold project - `bgoldd`, `bgold-cli` and `bitcoin-tx`. It behaves like a binary, so you can pass any arguments to the image and they will be forwarded to the `bgoldd` binary:

```sh
❯ docker run --rm -it uphold/bitcoin-gold \
  -printtoconsole \
  -regtest=1 \
  -rpcallowip=172.17.0.0/16 \
  -rpcpassword=bar \
  -rpcuser=foo
```

By default, `bgoldd` will run as user `bitcoingold` for security reasons and with its default data dir (`~/.bitcoingold/`). If you'd like to customize where `bitcoin-gold` stores its data, you must use the `BITCOIN_GOLD_DATA` environment variable. The directory will be automatically created with the correct permissions for the `bitcoingold` user and `bitcoin-gold` automatically configured to use it.

```sh
❯ docker run --env BITCOIN_GOLD_DATA=/var/lib/bgold --rm -it uphold/bitcoin-gold \
  -printtoconsole \
  -regtest=1
```

You can also mount a directory it in a volume under `/home/bitcoingold/.bitcoingold` in case you want to access it on the host:

```sh
❯ docker run -v ${PWD}/data:/home/bitcoingold/.bitcoingold -it --rm uphold/bitcoin-gold \
  -printtoconsole \
  -regtest=1
```

You can optionally create a service using `docker-compose`:

```yml
bitcoin-gold:
  image: uphold/bitcoin-gold
  command:
    -printtoconsole
    -regtest=1
```

### Using RPC to interact with the daemon

There are two communications methods to interact with a running Bitcoin Gold daemon.

The first one is using a cookie-based local authentication. It doesn't require any special authentication information as running a process locally under the same user that was used to launch the Bitcoin Gold daemon allows it to read the cookie file previously generated by the daemon for clients. The downside of this method is that it requires local machine access.

The second option is making a remote procedure call using a username and password combination. This has the advantage of not requiring local machine access, but in order to keep your credentials safe you should use the newer `rpcauth` authentication mechanism.

#### Using cookie-based local authentication

Start by launching the Bitcoin Gold daemon:

```sh
❯ docker run --rm --name bitcoin-gold-server -it uphold/bitcoin-gold \
  -printtoconsole \
  -regtest=1
```

Then, inside the running `bitcoin-gold-server` container, locally execute the query to the daemon using `bgold-cli`:

```sh
❯ docker exec --user bitcoingold bitcoin-gold-server bgold-cli -regtest getmininginfo

{
  "blocks": 0,
  "currentblocksize": 0,
  "currentblockweight": 0,
  "currentblocktx": 0,
  "difficulty": 4.656542373906925e-10,
  "errors": "",
  "networkhashps": 0,
  "pooledtx": 0,
  "chain": "regtest"
}
```

In the background, `bgold-cli` read the information automatically from `/home/bitcoingold/.bitcoingold/regtest/.cookie`. In production, the path would not contain the regtest part.

#### Using rpcauth for remote authentication

Before setting up remote authentication, you will need to generate the `rpcauth` line that will hold the credentials for the Bitcoin Gold daemon. You can either do this yourself by constructing the line with the format `<user>:<salt>$<hash>` or use the official `rpcuser.py` script to generate this line for you, including a random password that is printed to the console.

Example:

```sh
❯ curl -sSL https://raw.githubusercontent.com/BTCGPU/BTCGPU/master/share/rpcuser/rpcuser.py | python - <username>

String to be appended to bitcoin.conf:
rpcauth=foo:7d9ba5ae63c3d4dc30583ff4fe65a67e$9e3634e81c11659e3de036d0bf88f89cd169c1039e6e09607562d54765c649cc
Your password:
qDDZdeQ5vw9XXFeVnXT4PZ--tGN2xNjjR4nrtyszZx0=
```

Note that for each run, even if the username remains the same, the output will be always different as a new salt and password are generated.

Now that you have your credentials, you need to start the Bitcoin Gold daemon with the `-rpcauth` option. Alternatively, you could append the line to a `bitcoin.conf` file and mount it on the container.

Let's opt for the Docker way:

```sh
❯ docker run --rm --name bitcoin-gold-server -it uphold/bitcoin-gold \
  -printtoconsole \
  -regtest=1 \
  -rpcallowip=172.17.0.0/16 \
  -rpcauth='foo:e1fcea9fb59df8b0388f251984fe85$26431097d48c5b6047df8dee64f387f63835c01a2a463728ad75087d0133b8e6'
```

Two important notes:

1. Some shells require escaping the rpcauth line (e.g. zsh), as shown above.
2. It is now perfectly fine to pass the rpcauth line as a command line argument. Unlike `-rpcpassword`, the content is hashed so even if the arguments would be exposed, they would not allow the attacker to get the actual password.

You can now connect via `bgold-cli` or any other [compatible client](https://github.com/uphold/bitcoin-gold). You will still have to define a username and password when connecting to the Bitcoin Gold RPC server.

To avoid any confusion about whether or not a remote call is being made, let's spin up another container to execute `bgold-cli` and connect it via the Docker network using the password generated above:

```sh
❯ docker run --link bitcoin-gold-server --rm uphold/bitcoin-gold bgold-cli -rpcconnect=bitcoin-gold-server -regtest -rpcuser=foo -rpcpassword='j1DuzF7QRUp-iSXjgewO9T_WT1Qgrtz_XWOHCMn_O-Y=' getmininginfo

{
  "blocks": 0,
  "currentblocksize": 0,
  "currentblockweight": 0,
  "currentblocktx": 0,
  "difficulty": 4.656542373906925e-10,
  "errors": "",
  "networkhashps": 0,
  "pooledtx": 0,
  "chain": "regtest"
}
```

Done!

## Images

The `uphold/bitcoin-gold` image comes in multiple flavors:

### `uphold/bitcoin-gold:latest`

Points to the latest release available of Bitcoin Gold. Occasionally pre-release versions will be included.

### `uphold/bitcoin-gold:<version>`

Based on a slim Debian image, targets a specific version branch or release of Bitcoin Gold.

### `uphold/bitcoin-gold:<version>-alpine`

Based on Alpine Linux with Berkeley DB 4.8 (cross-compatible build), targets a specific version branch or release of Bitcoin Gold.

## Supported Docker versions

This image is officially supported on Docker version 17.09.0-ce, with support for older versions provided on a best-effort basis.

## License

[License information](https://github.com/BTCGPU/BTCGPU/blob/master/COPYING) for the software contained in this image.

[License information](https://github.com/uphold/docker-bitcoin-gold/blob/master/LICENSE) for the [uphold/bitcoin-gold][docker-hub-url] docker project.

[docker-hub-url]: https://hub.docker.com/r/uphold/bitcoin-gold
[docker-layers-image]: https://img.shields.io/imagelayers/layers/uphold/bitcoin-gold/latest.svg?style=flat-square
[docker-pulls-image]: https://img.shields.io/docker/pulls/uphold/bitcoin-gold.svg?style=flat-square
[docker-size-image]: https://img.shields.io/imagelayers/image-size/uphold/bitcoin-gold/latest.svg?style=flat-square
[docker-stars-image]: https://img.shields.io/docker/stars/uphold/bitcoin-gold.svg?style=flat-square
