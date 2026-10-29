# SatsRouting BTCPay Plugin

Accept Lightning payments in [BTCPay Server](https://btcpayserver.org) without
custodians, and optionally without running a Lightning node, powered by
[SatsRouting](https://satsrouting.exchange) non-custodial swaps.

The plugin lets any merchant, even on a shared BTCPay instance, receive
Lightning payments that settle into a wallet they control.

## Features

- **Two operating modes**
  - **Rebalance Mode**: SatsRouting automatically manages the liquidity of a
    Lightning node you already connect to BTCPay (LND or CLN).
  - **Nodeless Mode**: accept Lightning payments with no node at all. Incoming
    Lightning payments are swapped by SatsRouting into
    [Liquid](https://liquid.net/) Bitcoin sent to your own wallet.
- **Non-custodial**: funds are never held by SatsRouting. Swaps are atomic and
  the destination wallet can be read-only.
- **Chain swaps (optional)**: automatically move Liquid Bitcoin to mainchain
  Bitcoin once the wallet balance exceeds a budget you choose.
- **Shared-instance friendly**: one of the few ways for tenants of a shared
  BTCPay server to accept Lightning without linking third-party custodial
  accounts. Server admins enable the plugin for their users.
- **Greenfield API extension**: the plugin extends BTCPay's Greenfield API. The
  merged Swagger spec is available at
  `https://<your-btcpay-server>/swagger/v1/swagger.json`.
- **Reporting**: swap payments appear in BTCPay's reports under the
  "Lightning via SatsRouting" category.

## How it works

```
Customer ──Lightning──▶ SatsRouting swap backend ──Liquid / on-chain──▶ Your wallet
                                  ▲
                                  │ gRPC
                   SatsRouting client daemon (managed by the plugin)
                                  ▲
                                  │
                         BTCPay Server + plugin UI
```

The plugin is mainly a UI for the SatsRouting client, an open-source,
long-running swap daemon. On startup the plugin downloads the latest release
binaries, verifies the PGP signature and, if all checks pass, starts the daemon
and connects it to the SatsRouting swap backend (`api.satsrouting.exchange`).
BTCPay invoices are then served through SatsRouting swaps, and the daemon takes
care of claiming funds to your wallet.

## Requirements

- BTCPay Server **v2** (v1 is no longer supported)
- A self-hosted instance to install the plugin, or an administrator who
  installs and enables it on a shared one
- .NET SDK **10** only if you build from source

## Installation

**Self-hosted servers:** open _Manage Plugins_ in BTCPay, search for
**SatsRouting** and install it. Restart BTCPay when prompted.

**Shared servers:** ask your server administrator to install the plugin and to
enable it for tenants via _Admin → Advanced → Allow Plugin for Tenants_.

**Manual install:** [build the plugin from source](./docs/building-the-plugin.md)
and upload the resulting `.btcpay` file under _Plugins → Upload Plugin_.

## Quick start

1. Open the new **SatsRouting** entry in the BTCPay sidebar.
2. **Choose a mode**: Rebalance Mode or Nodeless Mode.
3. Review the **fee breakdown** and how Lightning → Liquid swaps work.
4. **Set up a wallet**: create a new Liquid wallet or import an existing one
   (read-only is supported).
5. Optionally configure **chain swaps** with a maximum balance budget.
6. Once _Lightning_ shows as active, make a small test purchase to confirm
   everything works.

A fuller walkthrough with screenshots is in the [docs](./docs/index.md).

## Known limitations

- **0-amount invoices** (e.g. for pull payment payouts) cannot be handled
  non-custodially by SatsRouting. Such payouts are cancelled and BTCPay does not
  yet show an error to the end user. Recommend wallets that let the payer set an
  amount, such as Phoenix or Aqua.
- The plugin must be enabled by a server admin before tenants can use it.

See [docs/limitations.md](./docs/limitations.md) for details.

## Development

```bash
# build the plugin
make build

# package a .btcpay file for manual upload
./release.sh

# run BTCPay with the plugin attached (needs the regtest environment)
make dev

# run the test suite
make test
```

The project layout:

| Path                                 | Content                                   |
| ------------------------------------ | ----------------------------------------- |
| `BTCPayServer.Plugins.Boltz/`        | Plugin source (assembly: `SatsRouting`)   |
| `BTCPayServer.Plugins.Boltz.Tests/`  | Integration and UI tests                  |
| `regtest/`, `regtest-config/`        | Local regtest environment                 |
| `docs/`                              | User and developer documentation          |
| `btcpayserver/`                      | BTCPay Server submodule used for dev/test |

Guides:

- [Building the plugin](./docs/building-the-plugin.md)
- [Regtest setup](./docs/regtest-setup.md)

## Resources

- Website: [satsrouting.exchange](https://satsrouting.exchange)
- Source code:
  [github.com/SatsRouting/btcpay-plugin-liquid](https://github.com/SatsRouting/btcpay-plugin-liquid)
- API docs:
  [SatsRouting non-custodial swaps API](https://github.com/SatsRouting/satsrouting-api-docs)

## License

Released under the [MIT License](./LICENSE).
