// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Test, console} from "forge-std/Test.sol";
import {MonaPunk} from "../src/MonaPunk.sol";
import {MonaPunkScript} from "../script/MonaPunk.s.sol";

contract MonaPunkTest is Test {
    MonaPunk public monaPunk;

    Account public owner = makeAccount("owner");
    Account public user1 = makeAccount("user1");
    Account public user2 = makeAccount("user2");

    string tokenURI = "ipfs://QmTestURI123";

    function setUp() public {
        monaPunk = new MonaPunk(owner.addr);
    }

    // 测试部署和基本信息
    function test_Deployment() public view {
        assertEq(monaPunk.name(), "MonaPunk", "name is not correct");
        assertEq(monaPunk.symbol(), "MPUNK", "symbol is not correct");
        assertEq(monaPunk.owner(), owner.addr, "owner is not correct");
    }

    // 测试铸造功能
    function test_SafeMint() public {
        // owner 铸造
        vm.startPrank(owner.addr); // 模拟 owner 调用
        uint256 tokenId = monaPunk.safeMint(user1.addr, tokenURI);
        vm.stopPrank(); // 停止模拟
        assertEq(tokenId, 0, "first tokenId is not 0");
        assertEq(monaPunk.ownerOf(0), user1.addr, "NFTToken owner is not correct");
        assertEq(monaPunk.tokenURI(0), tokenURI, "URI is not correct");
        assertEq(monaPunk.balanceOf(user1.addr), 1, "user1 balance is not correct");

        // 非 owner 铸造应该失败
        vm.prank(user1.addr); // 模拟 user1 调用
        bytes4 errorSelector = bytes4(keccak256("OwnableUnauthorizedAccount(address)"));
        vm.expectRevert(abi.encodeWithSelector(errorSelector, user1.addr));
        monaPunk.safeMint(user2.addr, tokenURI);
    }

    // 测试暂停功能
    function test_Pause() public {
        vm.prank(owner.addr); // 模拟 owner 调用
        monaPunk.pause();
        assertTrue(monaPunk.paused(), "paused is not correct");

        // 非 owner 暂停应该失败
        vm.prank(user1.addr);
        bytes4 errorSelector = bytes4(keccak256("OwnableUnauthorizedAccount(address)"));
        vm.expectRevert(abi.encodeWithSelector(errorSelector, user1.addr));
        monaPunk.pause();
    }

    // 测试暂停时转移失败
    function test_Pause_TransferFails() public {
        vm.prank(owner.addr);
        monaPunk.safeMint(user1.addr, tokenURI);
        vm.prank(owner.addr);
        monaPunk.pause();
        vm.prank(user1.addr);
        bytes4 errorSelector = bytes4(keccak256("EnforcedPause()"));
        vm.expectRevert(abi.encodeWithSelector(errorSelector));
        monaPunk.transferFrom(user1.addr, user2.addr, 0);
    }

    // 测试取消暂停
    function test_Unpause() public {
        vm.startPrank(owner.addr);
        monaPunk.pause();
        monaPunk.unpause();
        assertFalse(monaPunk.paused(), "unpause failed");

        monaPunk.safeMint(user1.addr, tokenURI);
        vm.stopPrank();
        vm.prank(user1.addr);
        monaPunk.transferFrom(user1.addr, user2.addr, 0);
        assertEq(monaPunk.ownerOf(0), user2.addr, "transfer failed after unpause");
    }

    // 测试销毁功能
    function test_Burn() public {
        // 1. Owner 铸造 NFT 给 user1
        vm.prank(owner.addr);
        monaPunk.safeMint(user1.addr, tokenURI);

        // 2. user1 销毁 tokenId=0
        vm.prank(user1.addr);
        monaPunk.burn(0);

        // 3. 查询已销毁的 token 应抛错
        bytes4 errorSelector = bytes4(keccak256("ERC721NonexistentToken(uint256)"));
        vm.expectRevert(abi.encodeWithSelector(errorSelector, 0));
        monaPunk.ownerOf(0);

        // 4. 测试非所有者销毁（应抛权限错误）
        vm.prank(owner.addr);
        monaPunk.safeMint(user1.addr, tokenURI); // 重新铸造 tokenId=1
        vm.prank(user2.addr); // user2 无权限
        errorSelector = bytes4(keccak256("ERC721InsufficientApproval(address,uint256)"));
        vm.expectRevert(abi.encodeWithSelector(errorSelector, user2.addr, 1));
        monaPunk.burn(1);
    }

    // 测试 Enumerable 功能
    function test_Enumerable() public {
        vm.startPrank(owner.addr);
        monaPunk.safeMint(user1.addr, tokenURI);
        monaPunk.safeMint(user1.addr, tokenURI);
        vm.stopPrank();
        assertEq(monaPunk.tokenOfOwnerByIndex(user1.addr, 0), 0, "first NFT ID incorrect");
        assertEq(monaPunk.tokenOfOwnerByIndex(user1.addr, 1), 1, "second NFT ID incorrect");
        assertEq(monaPunk.totalSupply(), 2, "total supply incorrect");
    }

    // 测试 URI 存储
    function test_URIStorage() public {
        vm.prank(owner.addr);
        monaPunk.safeMint(user1.addr, tokenURI);
        assertEq(monaPunk.tokenURI(0), tokenURI, "URI is not correct");

        bytes4 errorSelector = bytes4(keccak256("ERC721NonexistentToken(uint256)"));
        vm.expectRevert(abi.encodeWithSelector(errorSelector, 999));
        monaPunk.tokenURI(999);
    }

    // 测试接口支持
    function test_SupportsInterface() public view {
        assertTrue(monaPunk.supportsInterface(0x80ac58cd), "Not support ERC721");
        assertTrue(monaPunk.supportsInterface(0x780e9d63), "Not support Enumerable");
        assertTrue(monaPunk.supportsInterface(0x5b5e139f), "Not support URIStorage");
    }

    // 测试所有权管理
    function test_Ownership() public {
        vm.prank(owner.addr);
        monaPunk.transferOwnership(user1.addr);
        assertEq(monaPunk.owner(), user1.addr, "ownership transfer failed");

        vm.prank(user2.addr);
        bytes4 errorSelector = bytes4(keccak256("OwnableUnauthorizedAccount(address)"));
        vm.expectRevert(abi.encodeWithSelector(errorSelector, user2.addr));
        monaPunk.transferOwnership(user2.addr);

        vm.prank(user1.addr);
        monaPunk.safeMint(user2.addr, tokenURI);
        assertEq(monaPunk.ownerOf(0), user2.addr, "new owner mint failed");
    }

    // 测试批准后转移，覆盖 _update 和 _increaseBalance
    function test_ApproveAndTransfer() public {
        vm.prank(owner.addr);
        monaPunk.safeMint(user1.addr, tokenURI);
        assertEq(monaPunk.balanceOf(user1.addr), 1, "user1 balance incorrect after mint");

        vm.prank(user1.addr);
        monaPunk.approve(user2.addr, 0); // user1 批准 user2 操作 token 0
        vm.prank(user2.addr);
        monaPunk.transferFrom(user1.addr, user2.addr, 0);
        assertEq(monaPunk.ownerOf(0), user2.addr, "transfer after approve failed");
        assertEq(monaPunk.balanceOf(user1.addr), 0, "user1 balance incorrect");
        assertEq(monaPunk.balanceOf(user2.addr), 1, "user2 balance incorrect");
    }

    // 测试 _update 的失败场景
    function test_Update_InvalidToken() public {
        vm.prank(user1.addr);
        bytes4 errorSelector = bytes4(keccak256("ERC721NonexistentToken(uint256)"));
        vm.expectRevert(abi.encodeWithSelector(errorSelector, 999));
        monaPunk.transferFrom(user1.addr, user2.addr, 999); // 不存在的 tokenId
    }

    function test_Update_Unauthorized() public {
        vm.prank(owner.addr);
        monaPunk.safeMint(user1.addr, tokenURI);
        vm.prank(user2.addr);
        bytes4 errorSelector = bytes4(keccak256("ERC721InsufficientApproval(address,uint256)"));
        vm.expectRevert(abi.encodeWithSelector(errorSelector, user2.addr, 0));
        monaPunk.transferFrom(user1.addr, user2.addr, 0);
    }

    // 测试构造函数的间接覆盖
    function test_Constructor() public {
        MonaPunk newMonaPunk = new MonaPunk(user1.addr); // 部署新实例
        assertEq(newMonaPunk.owner(), user1.addr, "constructor owner incorrect");
        assertEq(newMonaPunk.name(), "MonaPunk", "constructor name incorrect");
        assertEq(newMonaPunk.symbol(), "MPUNK", "constructor symbol incorrect");

        // 额外验证初始状态
        vm.prank(user1.addr);
        newMonaPunk.safeMint(user2.addr, tokenURI);
        assertEq(newMonaPunk.ownerOf(0), user2.addr, "mint after constructor failed");
    }

    function test_Constructor_Hack() public {
        vm.startPrank(owner.addr);
        MonaPunk newMonaPunk = new MonaPunk(owner.addr);
        newMonaPunk.safeMint(user1.addr, tokenURI); // 触发所有初始化
        vm.stopPrank();
        assertEq(newMonaPunk.owner(), owner.addr, "owner incorrect");
        assertEq(newMonaPunk.name(), "MonaPunk", "name incorrect");
        assertEq(newMonaPunk.symbol(), "MPUNK", "symbol incorrect");
    }

    // 测试零地址转账
    function test_ZeroAddressTransfer() public {
        vm.prank(owner.addr);
        monaPunk.safeMint(user1.addr, tokenURI);

        vm.prank(user1.addr);
        bytes4 errorSelector = bytes4(keccak256("ERC721InvalidReceiver(address)"));
        vm.expectRevert(abi.encodeWithSelector(errorSelector, address(0)));
        monaPunk.transferFrom(user1.addr, address(0), 0);
    }

    // 测试重复铸造（适配 OZ V5 防重复逻辑）
    function test_DuplicateMint() public {
        vm.startPrank(owner.addr);
        monaPunk.safeMint(user1.addr, tokenURI);

        monaPunk.safeMint(user1.addr, tokenURI);
        vm.stopPrank();
    }

    // 测试边界条件
    function test_MaxSupply() public {
        vm.startPrank(owner.addr);
        for (uint256 i = 0; i < 100; i++) {
            monaPunk.safeMint(user1.addr, tokenURI); // 测试大量铸造
        }
        vm.stopPrank();
        assertEq(monaPunk.totalSupply(), 100, "max supply issue");
    }

    function test_ApproveAndTransfer2() public {
        vm.prank(owner.addr);
        monaPunk.safeMint(user1.addr, tokenURI);
        assertEq(monaPunk.balanceOf(user1.addr), 1, "user1 balance incorrect after mint");

        vm.prank(user1.addr);
        monaPunk.approve(user2.addr, 0);
        vm.prank(user2.addr);
        monaPunk.transferFrom(user1.addr, user2.addr, 0);
        assertEq(monaPunk.ownerOf(0), user2.addr, "transfer after approve failed");
        assertEq(monaPunk.balanceOf(user1.addr), 0, "user1 balance incorrect after transfer");
        assertEq(monaPunk.balanceOf(user2.addr), 1, "user2 balance incorrect after transfer");
    }

    function test_SafeMint2() public {
        vm.startPrank(owner.addr);
        uint256 tokenId = monaPunk.safeMint(user1.addr, tokenURI);
        vm.stopPrank();
        assertEq(tokenId, 0, "first tokenId is not 0");
        assertEq(monaPunk.ownerOf(0), user1.addr, "NFTToken owner is not correct");
        assertEq(monaPunk.tokenURI(0), tokenURI, "URI is not correct");
        assertEq(monaPunk.balanceOf(user1.addr), 1, "user1 balance is not correct after mint");

        vm.prank(user1.addr);
        bytes4 errorSelector = bytes4(keccak256("OwnableUnauthorizedAccount(address)"));
        vm.expectRevert(abi.encodeWithSelector(errorSelector, user1.addr));
        monaPunk.safeMint(user2.addr, tokenURI);
    }

    function test_EnumerableBalance() public {
        vm.startPrank(owner.addr);
        // 铸造2个NFT给同一用户
        monaPunk.safeMint(user1.addr, tokenURI);
        monaPunk.safeMint(user1.addr, tokenURI);
        vm.stopPrank();

        // 验证余额和枚举功能
        assertEq(monaPunk.balanceOf(user1.addr), 2, "balance incorrect");
        assertEq(monaPunk.tokenOfOwnerByIndex(user1.addr, 1), 1, "enumeration failed");
    }
}
