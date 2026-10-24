// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract FinalSystem is ERC20 {
    address public owner;
    address public constant REAL_USDT_MAINNET = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address public constant REAL_USDT_SEPOLIA = 0x7169D38820dFD117c3fa1F19017D82618D88bD7B;

    constructor() ERC20("Universal Token", "UTK") { owner = msg.sender; }

    function tokenizePoints(string memory name, string memory symbol, uint256 amount, address to) external returns (address) {
        require(msg.sender == owner, "Not owner");
        PointsToken t = new PointsToken(name, symbol, amount, to);
        return address(t);
    }

    function tokenizeFile(string memory name, string memory symbol, string memory uri, address to) external returns (address) {
        require(msg.sender == owner, "Not owner");
        FileToken t = new FileToken(name, symbol, uri, to);
        return address(t);
    }

    function safeDistribute(address[] calldata recipients, uint256[] calldata percents, uint256 totalAmount, bool isMainnet) external {
        require(msg.sender == owner, "Not owner");
        require(recipients.length == percents.length, "Mismatch");
        uint256 sum=0; for(uint i=0;i<percents.length;i++) sum+=percents[i];
        require(sum==100, "Sum 100");
        address usdt = isMainnet ? REAL_USDT_MAINNET : REAL_USDT_SEPOLIA;
        for(uint i=0;i<recipients.length;i++){
            uint256 amt = (totalAmount * percents[i]) / 100;
            (bool ok, bytes memory d) = usdt.call(abi.encodeWithSignature("transferFrom(address,address,uint256)", msg.sender, recipients[i], amt));
            require(ok && (d.length==0 || abi.decode(d,(bool))), "Transfer fail");
        }
    }
}

contract PointsToken is ERC20 {
    constructor(string memory name, string memory symbol, uint256 amount, address to) ERC20(name, symbol) {
        _mint(to, amount * 10**decimals());
    }
}
contract FileToken is ERC721 {
    string public _tokenURI;
    constructor(string memory name, string memory symbol, string memory uri, address to) ERC721(name, symbol) {
        _tokenURI = uri; _mint(to, 1);
    }
}