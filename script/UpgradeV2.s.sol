// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {TokenFaucetProxyAdmin} from "../src/transparent/TokenFaucetProxyAdmin.sol";
// ✅ v5 正确导入路径
import {ITransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {LogicV2} from "../src/transparent/LogicV2.sol";

contract UpgradeV2 is Script {
    address constant ADMIN_ADDR = 0xa513E6E4b8f2a923D98304ec87F64353C4D5C853;
    address constant PROXY_ADDR = 0x2279B7A0a67DB372996a5FaB50D91eAA73d2eBe6;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        LogicV2 implV2 = new LogicV2();
        console.log("New ImplV2:", address(implV2));

        TokenFaucetProxyAdmin admin = TokenFaucetProxyAdmin(ADMIN_ADDR);
        // 地址强转接口，删掉payable
        ITransparentUpgradeableProxy proxy = ITransparentUpgradeableProxy(PROXY_ADDR);
        // 空data=仅升级，不执行初始化
        admin.upgradeAndCall(proxy, address(implV2), "");

        console.log("Upgrade complete!");
        vm.stopBroadcast();
    }
}