git submodule update --init
dotnet publish BTCPayServer.Plugins.SatsRouting -o ./publish
dotnet run --project btcpayserver/BTCPayServer.PluginPacker ./publish BTCPayServer.Plugins.SatsRouting ./release
