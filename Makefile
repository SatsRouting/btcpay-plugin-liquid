VERSION := 1.0.3
RELEASE_PATH := ./release/BTCPayServer.Plugins.SatsRouting/$(VERSION)
BOLTZ_REGTEST ?= $(CURDIR)/regtest
BOLTZ_REGTEST_PATH := $(abspath $(BOLTZ_REGTEST))

gh-release:
	./release.sh
	git commit -a -m "chore: bump version to v$(VERSION)"
	git tag -s v$(VERSION) -m "v$(VERSION)"
	git push
	git push --tags
	cd $(RELEASE_PATH) && gpg --detach-sig SHA256SUMS
	gh release create v$(VERSION) --title v$(VERSION) --draft --notes-file release-notes-template.md $(RELEASE_PATH)/*

btcpay-appsettings:
	echo "{ \
	\"DEBUG_PLUGINS\": \"$(PWD)/BTCPayServer.Plugins.Boltz/bin/Debug/net10.0/BTCPayServer.Plugins.SatsRouting.dll\" \
	}" > ./btcpayserver/BTCPayServer/appsettings.dev.json

# NOTE: -p:StaticWebAssetsEnabled=false is required for the BTCPay Server host
# to build/run under the integration tests. Upstream patches this directly in
# the btcpayserver submodule; we inject it as a global MSBuild property instead
# so the submodule can stay pinned to the clean v2.4.7 tag.
build:
	dotnet build BTCPayServer.Plugins.Boltz -p:StaticWebAssetsEnabled=false

run:
	cd ./btcpayserver/BTCPayServer && \
	BTCPAY_BTCLIGHTNING="type=lnd-rest;server=https://127.0.0.1:8081/;macaroonfilepath=$(BOLTZ_REGTEST_PATH)/data/lnd1/data/chain/bitcoin/regtest/admin.macaroon;certfilepath=$(BOLTZ_REGTEST_PATH)/data/lnd1/tls.cert;allowinsecure=true" \
	dotnet run --launch-profile "Bitcoin-Boltz"

dev: btcpay-appsettings build run

test: btcpay-appsettings
	$(eval BTC_COOKIE := $(shell docker exec boltz-bitcoind cat /app/bitcoin/regtest/.cookie 2>/dev/null))
	TESTS_BTCRPCCONNECTION="server=http://127.0.0.1:18443;$(BTC_COOKIE)" \
	TESTS_BTCNBXPLORERURL="http://127.0.0.1:32838/" \
	TESTS_POSTGRES="User ID=boltz;Password=boltz;Include Error Detail=true;Host=127.0.0.1;Port=5432;Database=btcpayserver" \
	TESTS_EXPLORER_POSTGRES="User ID=boltz;Password=boltz;Include Error Detail=true;Host=127.0.0.1;Port=5432;Database=nbxplorer" \
	dotnet test ./BTCPayServer.Plugins.Boltz.Tests -p:StaticWebAssetsEnabled=false --logger "console;verbosity=normal"

