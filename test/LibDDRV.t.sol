// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "src/LibDDRV.sol";

contract TestDDRV is Test {
    Forest forest;
    uint256[] seeds;
    uint256 SEED_COUNT = 1000;

    function setUp() public {
        seeds.push(keccak256(abi.encode(0)));
        for (uint i = 1; i < SEED_COUNT; i++) {
            seeds.push(keccak256(abi.encode(seeds[i-1] + i)));
        }
        forest = Forest();
    }

    function testForestStructureBasic() public {
        uint256 countHeads = 0;
        uint256 countTails = 0;
        uint256[] memory weights = new uint256[](2);
        weights[0] = 50;
        weights[1] = 50;

        LibDDRV.preprocess(weights, forest);

        // total weight should be the sum 
        assertEq(forest.weight, 100);

        // level 0 (i.e. the leaves) should not be initialized
        assertEq(forest.levels[0].weight, 0);
        assertEq(forest.levels[0].roots, 0);

        // two elements should be in the only range on level 1
        assertEq(forest.levels[1].weight, 100);

        // emit
        emit log_named_uint("lvl1 roots", forest.levels[1].roots);
    }

    function testCoinFlip() public {
        uint256 countHeads = 0;
        uint256 countTails = 0;
        uint256[] memory weights = new uint256[](2);
        weights[0] = 50;
        weights[1] = 50;

        LibDDRV.preprocess(weights, forest);

        // flip 1000 coins
        for (uint i = 0; i < SEED_COUNT; i++) { 
            uint256 seed = seeds[i];
            uint256 element = LibDDRV.generate(forest, seed);

            if (element == 0) {
                countTails++;
            } else if (element == 1) {
                countHeads++;
            } else {
                revert("unexpected element index returned from generate");
            }
        }

        // assert these after
        emit log_named_uint("heads count:", countHeads);
        emit log_named_uint("tails count:", countTails);
    }
}
