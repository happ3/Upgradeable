// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {ProxyAdmin, ITransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {LogicV2} from "../src/transparent/LogicV2.sol";
import {Proxy} from "../src/transparent/Proxy.sol";

contract UpgradeV2 is Script {
    // 填你上一轮部署出来的地址
    address constant PROXY_ADDR = 0x0B306BF915C4d645ff596e518fAf3F9669b97016;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.addr(deployerPrivateKey);
        vm.startBroadcast(deployerPrivateKey);

        Proxy proxy = Proxy(payable(PROXY_ADDR));
        ProxyAdmin admin = ProxyAdmin(proxy.proxyAdmin());
        console.log("ProxyAdmin of Proxy:", address(admin));
        console.log("Owner of ProxyAdmin:", admin.owner());

        //1.部署新版本逻辑合约V2
        LogicV2 implV2 = new LogicV2();
        console.log("New ImplV2:", address(implV2));

        //2.调用ProxyAdmin.upgrade 升级代理指向V2
        admin.upgradeAndCall(
            ITransparentUpgradeableProxy(PROXY_ADDR),
            address(implV2),
            new bytes(0)
        );

        vm.stopBroadcast();
    }
}

