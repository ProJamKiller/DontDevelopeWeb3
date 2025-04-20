// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@thirdweb-dev/contracts/base/ERC721Base.sol";

contract PleaseDontKillTheJam is ERC721Base {
    uint256 public constant MAX_SUPPLY = 10_000;
    uint256 public mintFee;

    mapping(uint256 => uint256) public mojoScore;
    mapping(uint256 => string)  public narrative;

    event NFTMinted(address indexed to, uint256 indexed tokenId, uint256 mojo, string narr);

    constructor(
        address _defaultAdmin,
        string memory _name,
        string memory _symbol,
        address _royaltyRecipient,
        uint128 _royaltyBps,
        uint256 _initialMintFee
    )
        ERC721Base(_defaultAdmin, _name, _symbol, _royaltyRecipient, _royaltyBps)
    {
        mintFee = _initialMintFee;
    }

    /// @notice Mint one NFT with mojo & narrative attached
    function mint(
        address to,
        string calldata tokenURI,
        uint256 mojo,
        string calldata narr
    ) external payable {
        require(msg.value == mintFee,            "Bad mint fee");
        require(totalSupply() < MAX_SUPPLY,      "Sold out");

        uint256 id = nextTokenIdToMint();
        _safeMint(to, id);
        _setTokenURI(id, tokenURI);
        mojoScore[id] = mojo;
        narrative[id] = narr;

        emit NFTMinted(to, id, mojo, narr);
    }

    /// @notice Mint multiple in one go. Fees must exactly equal count * mintFee.
    function mintBatch(
        address to,
        string[] calldata tokenURIs,
        uint256[] calldata mojos,
        string[] calldata narrs
    ) external payable {
        uint256 count = tokenURIs.length;
        require(count > 0,                        "No tokens");
        require(count == mojos.length 
             && count == narrs.length,           "Array mismatch");
        require(totalSupply() + count <= MAX_SUPPLY, "Too many");
        require(msg.value == mintFee * count,     "Bad total fee");

        for (uint256 i = 0; i < count; i++) {
            uint256 id = nextTokenIdToMint();
            _safeMint(to, id);
            _setTokenURI(id, tokenURIs[i]);
            mojoScore[id] = mojos[i];
            narrative[id] = narrs[i];
            emit NFTMinted(to, id, mojos[i], narrs[i]);
        }
    }

    /// @notice Owner can update fee
    function setMintFee(uint256 fee) external onlyOwner {
        mintFee = fee;
    }

    /// @notice Withdraw all ETH
    function withdraw() external onlyOwner {
        uint256 bal = address(this).balance;
        require(bal > 0, "Nothing to withdraw");
        payable(owner()).transfer(bal);
    }
}