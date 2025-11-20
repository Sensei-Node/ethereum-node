# MEV-Boost

MEV-Boost is a sidecar service that allows Ethereum validators to access blocks from a competitive builder marketplace. This maximizes validator rewards through MEV (Maximal Extractable Value).

## What is MEV-Boost?

MEV-Boost connects validators to multiple block builders, enabling them to receive the most profitable blocks while maintaining decentralization. It's developed by Flashbots and is widely used by validators on Ethereum mainnet.

## Configuration

Configure MEV-Boost in `environments/.env.mev`:

```bash
# MEV-Boost relay endpoints (comma-separated)
MEV_RELAYS=https://0xac6e77dfe25ecd6110b8e780608cce0dab71fdd5ebea22a16c0205200f2f8e2e3ad3b71d3499c54ad14d6c21b41a37ae@boost-relay.flashbots.net,https://0xa1559ace749633b997cb3fdacffb890aeebdb0f5a3b6aaa7eeeaf1a38af0a8fe88b9e4b1f61f236d2e64d95733327a62@relay.ultrasound.money

# Minimum bid value (in wei) - optional
MEV_MIN_BID=0

# Check relay status on startup
MEV_CHECK=true

# Additional flags
MEV_EXTRA_FLAGS=
```

## Relay Endpoints

### Mainnet Relays

Popular MEV-Boost relays for mainnet:

- **Flashbots**: https://boost-relay.flashbots.net
- **bloXroute Max Profit**: https://bloxroute.max-profit.blxrbdn.com
- **bloXroute Ethical**: https://bloxroute.ethical.blxrbdn.com
- **Blocknative**: https://builder-relay-mainnet.blocknative.com
- **Ultrasound**: https://relay.ultrasound.money
- **Aestus**: https://mainnet.aestus.live
- **Agnostic**: https://agnostic-relay.net

### Testnet Relays

For Sepolia testnet:
- **Flashbots Sepolia**: https://boost-relay-sepolia.flashbots.net

## Usage

### Enable MEV-Boost

In your main `.env` file:

```bash
START_MEV_BOOST=true
```

### Configure Your Consensus Client

Make sure your consensus client is configured to use MEV-Boost. This is typically done in `environments/.env.consensus`:

**For Lighthouse:**
```bash
ENABLE_MEV=true
C_MEV_URL=http://mev-boost:18550
```

**For Nimbus:**
```bash
ENABLE_MEV=true
C_MEV_URL=http://mev-boost:18550
```

### Start Services

```bash
./node.sh
```

### Verify MEV-Boost is Running

Check logs:
```bash
./node.sh logs mev-boost
```

Check status:
```bash
./node.sh status
```

You should see the `mev-boost` container running on port 18550.

## Monitoring

### Check MEV-Boost Logs

```bash
docker logs mev-boost
```

Look for:
- Successful relay connections
- Incoming requests from consensus client
- Block bid information

### Verify Relay Connections

MEV-Boost will log which relays it successfully connected to on startup. Make sure at least one relay is reachable.

## Ports

- **18550** - MEV-Boost API endpoint (accessed by consensus client)

## Important Notes

### For Validators Only

MEV-Boost is only useful if you're running a **validator**. If you're only running an RPC node (execution + consensus without validator keys), you don't need MEV-Boost.

### Relay Selection

Choose relays carefully:
- Use multiple relays for redundancy
- Consider "ethical" vs "max profit" relays based on your preferences
- Keep relay list updated as the ecosystem evolves

### Network Compatibility

Make sure your relay endpoints match your network (mainnet, sepolia, etc.). Using mainnet relays on a testnet won't work.

### Registration

Some relays require validator registration. MEV-Boost handles this automatically when your validator proposes blocks.

## Troubleshooting

### MEV-Boost not connecting to relays

1. Check your relay URLs in `.env.mev`
2. Verify network connectivity: `docker exec mev-boost wget -O- <relay-url>`
3. Check if relays are operational (visit relay websites)

### Consensus client not using MEV-Boost

1. Verify `ENABLE_MEV=true` in `.env.consensus`
2. Check `C_MEV_URL=http://mev-boost:18550` is set correctly
3. Restart consensus client: `./node.sh restart`

### No MEV rewards

1. MEV is variable - not every block has MEV opportunities
2. Verify you're using competitive relays
3. Check validator is registered with relays (automatic on first proposal)

## Resources

- [MEV-Boost Documentation](https://boost.flashbots.net/)
- [Flashbots GitHub](https://github.com/flashbots/mev-boost)
- [Relay Directory](https://boost.flashbots.net/relay-directory)
- [MEV-Boost Monitoring Dashboard](https://mevboost.pics/)

## Version

The version is controlled by `MEV_VERSION` in your `.env` file:

```bash
MEV_VERSION=latest  # or specific version like v1.7
```

To update:
```bash
./node.sh pull
./node.sh restart
```
