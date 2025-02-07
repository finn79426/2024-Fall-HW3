// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LenderPool} from "src/week3_lender/LenderPool.sol";
import {ReceiverPool} from "src/week3_lender/ReceiverPool.sol";
import {AmazingToken} from "src/week3_lender/AmazingToken.sol";

import {Test, console} from "forge-std/Test.sol";
import {stdError} from "forge-std/Test.sol";

contract LenderBaseTest is Test {
    address public someUser = address(0x123);
    address public attacker = address(0x456);
    uint256 TOKENS_IN_POOL = 1000000 ether;
    uint256 INITIAL_ATTACKER_TOKEN_BALANCE = 100 ether;

    AmazingToken token;
    LenderPool pool;
    ReceiverPool receiverContract;

    function setUp() public virtual {
        // setup contracts
        token = new AmazingToken();
        pool = new LenderPool(address(token));

        // setup tokens
        token.approve(address(pool), TOKENS_IN_POOL);
        pool.depositTokens(TOKENS_IN_POOL);

        token.transfer(attacker, INITIAL_ATTACKER_TOKEN_BALANCE);

        assertEq(token.balanceOf(address(pool)), TOKENS_IN_POOL);
        assertEq(token.balanceOf(attacker), INITIAL_ATTACKER_TOKEN_BALANCE);

        vm.startPrank(someUser);
        receiverContract = new ReceiverPool(address(pool));
        receiverContract.executeFlashLoan(10);
        vm.stopPrank();
    }

    modifier checkChallengeSolved() {
        _;
        vm.expectRevert(stdError.assertionError);
        vm.prank(someUser);
        receiverContract.executeFlashLoan(10);
    }
}
