// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

/**
 * @title 
 * 在 该挑战 的 Bank 合约基础之上，编写 IBank 接口及BigBank 合约，使其满足 Bank 实现 IBank， BigBank 继承自 Bank ， 同时 BigBank 有附加要求：

要求存款金额 >0.001 ether（用modifier权限控制）
BigBank 合约支持转移管理员
编写一个 Admin 合约， Admin 合约有自己的 Owner ，同时有一个取款函数 adminWithdraw(IBank bank) , 
adminWithdraw 中会调用 IBank 接口的 withdraw 方法从而把 bank 合约内的资金转移到 Admin 合约地址。

BigBank 和 Admin 合约 部署后，把 BigBank 的管理员转移给 Admin 合约地址,未重写的方法权限不用转移,模拟几个用户的存款，然后

Admin 合约的Owner地址调用 adminWithdraw(IBank bank) 把 BigBank 的资金转移到 Admin 地址。

请提交 github 仓库地址。

查看批注

 * @author 
 * @notice 
 */
interface IBank {
    function deposit() external payable;
    function withdraw() external;
    function getTopDepositors()external view  returns (address[3] memory,uint256[3] memory);
}

contract Bank is IBank {
    mapping (address => uint256) balancesOf;
    address[3] public topThree;
    address public owner;
    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    receive () external virtual payable  {
        require(msg.value > 0, "Deposit amount must be greater than zero.");
        _hardDeposit(msg.sender,msg.value);
    }


    function deposit() external virtual override payable {
        require(msg.value > 0, "Deposit amount must be greater than zero.");
        _hardDeposit(msg.sender,msg.value);
    }

    function _hardDeposit(address user,uint256 amount) internal   {
        balancesOf[user] += amount;
        _sortAndUpdateTopThree(user);
    }

    function _sortAndUpdateTopThree(address user)  internal {
       uint256 currentBalance = balancesOf[user];
      uint256 index = 3;
       address [3] memory tempBank = topThree;

       for (uint256 i = 0; i < 3; i++) {
            tempBank[i] = topThree[i];
       }

        while (index > 0 && balancesOf[tempBank[index-1]] < currentBalance) {
            if(index < 3){
                tempBank[index] =  tempBank[index-1];
            }
            index--;
         
        }
        if(index < 3 ){
            tempBank[index] = user;
        }
        topThree = tempBank;
  
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance to withdraw");
        (bool success,) = payable(msg.sender).call{value: balance}("");
        require(success,"withdraw fail");
    }

    function getTopDepositors() external view override  returns (address[3] memory,uint256[3] memory){
         uint256[3] memory res;
        for (uint256 i = 0; i < 3; i++) {
            res[i] = balancesOf[topThree[i]];
        }
        return (topThree, res);
    }

}

contract BigBank is Bank{

    address public  admin;

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin{
        require(msg.sender == admin,"not admin");
        _;
    }


    function deposit() external payable virtual override {
        require(msg.value >  0.001 ether,"value must >  0.001 ether");
        super._hardDeposit(msg.sender,msg.value);
    }

    receive() external payable virtual override {
        require(msg.value >  0.001 ether,"value must >  0.001 ether");
        super._hardDeposit(msg.sender,msg.value);
    }

    function changeAdmin(address newAdmin) external onlyAdmin{
        require(newAdmin != address(0), "New admin cannot be zero address");
        owner = newAdmin;// 踩坑最厉害的是这里  
    }

}

contract Admin{
    address public immutable admin;
    
    constructor() {
        admin = msg.sender;
    }
    
    receive() external payable {
    }
    //把钱转到当前合约
    function adminWithdraw(IBank bank) external {
        require(msg.sender == admin, "Only admin can withdraw");
        bank.withdraw();
    }
    //当前合约提现
    function withdraw() external {
        require(msg.sender == admin, "Only admin can withdraw");
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance to withdraw");
        (bool sent, ) = payable(admin).call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }

}

