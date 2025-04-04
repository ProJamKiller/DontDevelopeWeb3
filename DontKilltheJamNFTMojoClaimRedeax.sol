// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@thirdweb-dev/contracts/base/ERC721Base.sol";

contract DKTJ is ERC721Base {
    uint256 public constant MAX_SUPPLY = 10000;
    uint256 public mintFee;

    mapping(uint256 => uint256) public mojoScore;
    mapping(uint256 => string) public narrative;

    constructor(
        address _defaultAdmin,
        string memory _name,
        string memory _symbol,
        address _royaltyRecipient,
        uint128 _royaltyBps
    ) ERC721Base(_defaultAdmin, _name, _symbol, _royaltyRecipient, _royaltyBps) {}

    function mintTo(
        address to,
        string memory _tokenURI,
        uint256 _mojoScore,
        string memory _narrative
    ) external payable {
        require(msg.value >= mintFee, "Insufficient mint fee");
        require(totalSupply() < MAX_SUPPLY, "Max supply reached");
        
        uint256 tokenId = nextTokenIdToMint();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, _tokenURI);
        
        mojoScore[tokenId] = _mojoScore;
        narrative[tokenId] = _narrative;
    }

    function batchMintTo(
        address to,
        string[] memory _tokenURIs,
        uint256[] memory _mojoScores,
        string[] memory _narratives
    ) external payable {
        require(
            _tokenURIs.length == _mojoScores.length && 
            _tokenURIs.length == _narratives.length,
            "Array lengths must match"
        );
        require(
            totalSupply() + _tokenURIs.length <= MAX_SUPPLY, 
            "Batch would exceed max supply"
        );
        
        require(msg.value >= mintFee * _tokenURIs.length, "Insufficient mint fee");
        
        for (uint256 i = 0; i < _tokenURIs.length; i++) {
            uint256 tokenId = nextTokenIdToMint();
            _safeMint(to, tokenId);
            _setTokenURI(tokenId, _tokenURIs[i]);
            
            mojoScore[tokenId] = _mojoScores[i];
            narrative[tokenId] = _narratives[i];
        }
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        payable(owner()).transfer(balance);
    }

    // Optional: Allow setting mint fee
    function setMintFee(uint256 _fee) external onlyOwner {
        mintFee = _fee;
    }
}

