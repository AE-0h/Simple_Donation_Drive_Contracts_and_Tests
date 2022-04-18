// SPDX-License-Identifier: MIT
pragma solidity^ 0.8.7;

import 'truffle/Assert.sol';
import'../contracts/Funding.sol';
import 'truffle/DeployedAddresses.sol';

contract FundingTest{
    uint public initialBalance = 10 ether;
    Funding funding;

    receive() external payable{}

    function beforeEach() public{
        funding = new Funding(1 days, 100000000 gwei);
    }

    function testWithdrawlByOwner()public{
        uint initBalance = address(this).balance;
        funding.donate{value: 50000000 gwei}();

        bytes memory bs = abi.encodePacked((keccak256('withdraw()')));
        (bool result,) = address(funding).call(bs);
        Assert.equal(result, false, 'Allows for withdrawl before reaching the goal');

        funding.donate{value: 50000000 gwei}();
        Assert.equal(address(this).balance, initBalance - 100000000 gwei, "Balance before withdrawl doesn't equal to sum of donations");

        bs = abi.encodePacked((keccak256('withdraw()')));
        (result,) = address(funding).call(bs);
        Assert.equal(result, true, 'Does not Allow for withdrawl after reaching the goal');
        Assert.equal(address(this).balance, initBalance, "Balance after withdrawl doesn't equal to sum of donations"); 

    }

    function testWithdrawlByNonOwner()public{
       funding = Funding(DeployedAddresses.Funding());
       funding.donate{value: 100000000 gwei}();

         bytes memory bs = abi.encodePacked((keccak256('withdraw()')));
            (bool result,) = address(funding).call(bs);
            Assert.equal(result, false, 'Does not allow withdrawl by non-owner of contract');


    }

    function testTrackingDonatorsBalance( )public{
       
        funding.donate{value: 5000000 gwei}();
        funding.donate{value: 15000000 gwei}();
        Assert.equal(funding.balances(address(this)), 20000000 gwei, 'Donator balance is different from donations');
    }


    function testSettingAnOwnerDuringCreation()public{
      
        Assert.equal(funding.owner(), address(this), 'The owner is not the same actor as deployer');
    }

    function testSettingAnOwnerOfDeployedContract()public{
        Funding newfund = Funding(DeployedAddresses.Funding());
        Assert.equal(newfund.owner(), msg.sender, 'The owner is not the same actor as deployer');
    }

    function testAcceptingDonations()public{
        
        Assert.equal(funding.raised(), 0, 'Initial raised amount is different from 0');

        funding.donate{value:10000000 gwei}();
        funding.donate{value:20000000 gwei}();
        Assert.equal(funding.raised(), 30000000 gwei, 'Raised amount is different from sum of donations');
    }

    function testDonatingAfterTimeIsUp() public{
        Funding newFund = new Funding(0, 100000000 gwei);
        bytes memory bs = abi.encodePacked((keccak256('donate()')));

        (bool result,) = address(newFund).call{value: 100000000 gwei}(bs);
        Assert.equal(result, false, 'Donation was accepted even after time is up');
    }

}