// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {console} from "forge-std/console.sol";
import {Script, console} from "forge-std/Script.sol";
import {LogicEXV2} from "../src/uups/LogicEXV2.sol";

contract UpgradeEXV2 is Script {
    // 部署后替换成你链上真实Proxy地址
    address constant PROXY = 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512;

    function run() external {
        uint deployPk = vm.envUint("PRIVATE_KEY");
        // 第一步：部署V2实现合约（任何人可部署）
        vm.startBroadcast(deployPk);
        LogicEXV2 implV2 = new LogicEXV2();
        vm.stopBroadcast();

        console.log("V2 New Impl address:", address(implV2));
        console.log("Target Proxy:", PROXY);

        // UUPS升级calldata: upgradeTo(newImpl)
        bytes memory upgradeCalldata = abi.encodeWithSignature("upgradeTo(address)", address(implV2));
        console.log("==== Upgrade Calldata(upgradeTo) ====");
        console.logBytes(upgradeCalldata);

        /*
        【生产操作】
        1. Proxy合约 → Etherscan Write
        2. owner冷钱包连接，直接调用 upgradeTo(新V2地址)
        或多签：to=Proxy，data=上面calldata
        */

        // =========本地anvil调试开启下面broadcast（生产注释掉）=========
        /*
        uint ownerPk = vm.envUint("OWNER_PRIVATE_KEY");
        vm.startBroadcast(ownerPk);
        (bool succ,) = PROXY.call(upgradeCalldata);
        require(succ,"upgrade fail");
        vm.stopBroadcast();

        // 升级后测试
        LogicEXV2 proxyInst = LogicEXV2(PROXY);
        proxyInst.updateScore(-60);
        console.log("score after -60:", proxyInst.score());
        */
    }
}