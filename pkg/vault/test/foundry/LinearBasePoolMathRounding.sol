// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.24;

import { LinearBasePoolMathMock } from "../../contracts/test/LinearBasePoolMathMock.sol";
import { BasePoolMathMock } from "../../contracts/test/BasePoolMathMock.sol";
import { BasePoolMathRoundingTest } from "./BasePoolMathRoundingTest.sol";

contract LinearBasePoolMathRoundingTest is BasePoolMathRoundingTest {
    function setUp() public override {
        BasePoolMathRoundingTest.setUp();
    }

    function createMathMock() internal override returns (BasePoolMathMock) {
        return BasePoolMathMock(address(new LinearBasePoolMathMock()));
    }
}