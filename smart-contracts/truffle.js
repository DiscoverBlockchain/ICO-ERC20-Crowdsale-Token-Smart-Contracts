module.exports = {
    // See <http://truffleframework.com/docs/advanced/configuration>
    // for more about customizing your Truffle configuration!
    networks: {
        development: {
            host: "127.0.0.1",
            port: 8545,
            network_id: "*" // Match any network id
        },
        ganache: {
            host: 'localhost',
            port: 7545,
            network_id: '*',
            gas: 6721975,
            test: true
        },
        cli: {
            host: 'localhost',
            port: 8545,
            network_id: '*',
            gas: 6721975,
            test: true
        },
        console: {
            host: 'localhost',
            port: 9545,
            network_id: '*',
            gas: 6721975,
            test: true
        },
        test: {
            network_id: '*',
            provider: ganache.provider(),
            gas: 6721975,
            test: true
        },
        live: {
            host: '', // Live network IP address
            port: 80,
            network_id: 1 // Ethereum public network
            // optional config values:
            // gas: Gas limit used for deploys. Default is 4712388
            // gasPrice: Gas price used for deploys. Default is 100000000000 (100 Shannon).
            // from - default address to use for any transaction Truffle makes during migrations
            // provider - web3 provider instance Truffle should use to talk to the Ethereum network.
            //          - function that returns a web3 provider instance (see below.)
            //          - if specified, host and port are ignored.
        }
    }
};
