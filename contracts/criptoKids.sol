// SPDX-License-Identifier: unlicensed
pragma solidity ^0.8.7;

contract CryptoKids{
    // owner parent : wallet address
    address owner;
    event LogKidFundingReceived(address addr, uint amount, uint contractBalance);

   constructor (){
       owner = msg.sender;
   } 
    
    // define kid
    struct Kid {
        address payable walletAddress;
        string firstName;
        string lastName;
        uint releaseTime;
        uint amount;
        bool canWithdraw;
    }
    Kid[] public kids;

modifier onlyOwner(){
    require(msg.sender == owner, "Only the owner can add kids");
    _;
}

    // add kids to contract
    
function addKid(
        address payable walletAddress, string memory firstName,  string memory lastName, uint releaseTime, uint amount, bool canWithdraw) public onlyOwner {
        kids.push(Kid(
            walletAddress, 
            firstName, 
            lastName, 
            releaseTime, 
            amount, 
            canWithdraw
        ));
}

 // view, pure don't let funcs to change blockchain because run locally and don't cost gas
 // pure is more strict because does not allow to read state variables
 function balanceOf() public view returns(uint){
     return address(this).balance;
 }

    // deposit founds to contract to kid's accounts
    function deposit (address walletAddress) payable public {
        addToKidsBalance(walletAddress);
    }
    function addToKidsBalance(address walletAddress) private onlyOwner {
            for(uint i = 0; i < kids.length; i++) {
                if(kids[i].walletAddress == walletAddress) {
                  
                    kids[i].amount += msg.value; 
                    emit LogKidFundingReceived(walletAddress,msg.value, balanceOf());
            }
        }

    }

function getIndex(address walletAddress) view private returns(uint){
    for(uint i = 0; i<kids.length; i++){
        if(kids[i].walletAddress == walletAddress){
            return i;
        }
    }
    return 9999;
}

    // kid checks if can withdraw
function availableToWithdraw(address walletAddress) public returns(bool){
    uint i = getIndex(walletAddress);
    require(block.timestamp>kids[i].releaseTime, "You cannot withdraw now");
    if(block.timestamp>kids[i].releaseTime){
        kids[i].canWithdraw = true;
        return true;
    } else {
        return false;
    }
}

    // withraw money
function withdraw(address payable walletAddress) payable public {
    uint i = getIndex(walletAddress);
    require(msg.sender == kids[i].walletAddress, "You can't withraw someone else money");
    require(kids[i].canWithdraw == true, "You are not able to withdraw at this time");
    kids[i].walletAddress.transfer(kids[i].amount);
}
}