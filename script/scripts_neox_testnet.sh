#*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*//
#*                            DEPLOY                          *//
#*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*//

forge script --chain-id 12227332 script/deploy/Deploy.s.sol:DeployScript \
    --rpc-url https://neoxt4seed1.ngd.network/ \
    --broadcast --legacy -vvvv

forge script --chain 12227332 script/deploy/UpgradeMemeXDay.s.sol:UpgradeMemeXDayScript \
    --rpc-url https://neoxt4seed1.ngd.network/ \
        --broadcast --legacy -vvvv
        
forge script --chain 12227332 script/deploy/ReplaceDexLuancher.s.sol:ReplaceDexLauncherScript \
    --rpc-url https://neoxt4seed1.ngd.network/ \
        --broadcast --legacy -vvvv

#*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*//
#*                            MANAGE                          *//
#*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*//

forge script --chain 12227332 script/manage/Manage.s.sol:ManagerScript \
    --rpc-url https://neoxt4seed1.ngd.network/ \
        --broadcast  --legacy -vvvv

forge script --chain 12227332 script/manage/StartGame.s.sol:StartGameScript \
    --rpc-url https://neoxt4seed1.ngd.network/ \
        --broadcast  --legacy -vvvv

forge script --chain 12227332 script/manage/ShufflePairings.s.sol:ShufflePairingScript \
    --rpc-url https://neoxt4seed1.ngd.network/ \
        --broadcast  --legacy -vvvv

forge script --chain 12227332 script/manage/Top4Snapshot.s.sol:Top4SnapshotScript \
    --rpc-url https://neoxt4seed1.ngd.network/ \
        --broadcast --legacy -vvvv

#*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*//
#*                            OTHERS                          *//
#*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*//

forge script --chain 12227332 script/CreateToken.s.sol:CreateTokenScript \
    --rpc-url https://neoxt4seed1.ngd.network/ \
        --broadcast  --legacy -vvvv

forge script --chain 12227332 script/TradeToken.s.sol:TradeScript \
    --rpc-url https://neoxt4seed1.ngd.network/ \
        --broadcast --legacy -vvvv





forge script --chain 12227332 script/manage/Finalize.s.sol:FinalizeScript \
    --rpc-url https://neoxt4seed1.ngd.network/ \
        --broadcast --legacy -vvvv