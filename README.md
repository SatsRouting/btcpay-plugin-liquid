# SatsRouting BTCPay Plugin

This plugin allows any merchant (even on a shared BTCPay instance) to accept Lightning payments.

It features two modi:
- Rebalance Mode: automatically manage liquidity of a connected Lightning node
- Nodeless Mode: accept Lightning payments without running a node, using Liquid swaps

The plugin uses the SatsRouting swap backend (`api.satsrouting.exchange`) and is built on top of the open-source [Boltz Client](https://github.com/BoltzExchange/boltz-client) swap daemon.

## BTCPay Compatibility

This plugin is compatible with BTCPay Server v2. Install it via the official BTCPay plugin system, or [build it from source](./docs/building-the-plugin.md) and import the resulting `.btcpay` file via the Plugin UI.

## Resources

* Website: [satsrouting.exchange](https://satsrouting.exchange)
* Source code: [github.com/SatsRouting/btcpay-plugin-liquid](https://github.com/SatsRouting/btcpay-plugin-liquid)
* API docs: [SatsRouting non-custodial swaps API](https://github.com/SatsRouting/satsrouting-api-docs)
