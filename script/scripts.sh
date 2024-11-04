forge script --chain holesky script/Deploy.s.sol:DeployScript \
    --rpc-url https://ethereum-holesky-rpc.publicnode.com \
    --broadcast --verify --legacy -vvvv

forge script --chain holesky script/Manage.s.sol:ManagerScript \
    --rpc-url https://ethereum-holesky-rpc.publicnode.com \
        --broadcast --verify --legacy -vvvv

forge script --chain holesky script/StartGame.s.sol:StartGameScript \
    --rpc-url https://ethereum-holesky-rpc.publicnode.com \
        --broadcast --verify --legacy -vvvv

forge script --chain holesky script/CreateToken.s.sol:CreateTokenScript \
    --rpc-url https://ethereum-holesky-rpc.publicnode.com \
        --broadcast --verify --legacy -vvvv

forge script --chain holesky script/TradeToken.s.sol:TradeScript \
    --rpc-url https://ethereum-holesky-rpc.publicnode.com \
        --broadcast --verify --legacy -vvvv

forge script --chain holesky script/ShufflePairings.s.sol:ShufflePairingScript \
    --rpc-url https://ethereum-holesky-rpc.publicnode.com \
        --broadcast --verify --legacy -vvvv

forge script --chain holesky script/Top4Snapshot.s.sol:Top4SnapshotScript \
    --rpc-url https://ethereum-holesky-rpc.publicnode.com \
        --broadcast --verify --legacy -vvvv

forge script --chain holesky script/FinalizeScript.s.sol:Top4SnapshotScript \
    --rpc-url https://ethereum-holesky-rpc.publicnode.com \
        --broadcast --verify --legacy -vvvv