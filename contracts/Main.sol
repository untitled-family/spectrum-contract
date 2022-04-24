//SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

// Name: Spectrum Minter
// Design: biron.eth
// Buidl: himlate.eth
//_______________________________________________________________________________________________________________________________________
//_____/\\\\\\\\\\\______________________________________________________________________________________________________________________
//____/\\\/////////\\\___________________________________________________________________________________________________________________
//____\//\\\______\///____/\\\\\\\\\___________________________________/\\\______________________________________________________________
//______\////\\\__________/\\\/////\\\_____/\\\\\\\\______/\\\\\\\\__/\\\\\\\\\\\__/\\/\\\\\\\___/\\\____/\\\____/\\\\\__/\\\\\__________
//__________\////\\\______\/\\\\\\\\\\____/\\\/////\\\___/\\\//////__\////\\\////__\/\\\/////\\\_\/\\\___\/\\\__/\\\///\\\\\///\\\_______
//_______________\////\\\___\/\\\//////____/\\\\\\\\\\\___/\\\____________\/\\\______\/\\\___\///__\/\\\___\/\\\_\/\\\_\//\\\__\/\\\_____
//________/\\\______\//\\\__\/\\\_________\//\\///////___\//\\\___________\/\\\_/\\__\/\\\_________\/\\\___\/\\\_\/\\\__\/\\\__\/\\\_____
//________\///\\\\\\\\\\\/___\/\\\__________\//\\\\\\\\\\__\///\\\\\\\\____\//\\\\\___\/\\\_________\//\\\\\\\\\__\/\\\__\/\\\__\/\\\____
//___________\///////////_____\///____________\//////////_____\////////______\/////____\///___________\/////////___\///___\///___\///____
//_______________________________________________________________________________________________________________________________________
//_______________________________________________________________________________________________________________________________________
//_______________________________________________________________________________________________________________________________________

import "@openzeppelin/contracts/access/Ownable.sol";
import "erc721a/contracts/ERC721A.sol";
import "./Utils.sol";
import "./SpectrumLib.sol";
import "./SpectrumGeneratorInterface.sol";

contract KineticSpectrum is ERC721A, Ownable {
    uint256 public constant MAX_SPECTRUMS = 1111;
    uint256 public constant MAX_PER_ADDRESS = 30;
    uint256 public constant PRICE = 0.003 ether;
    uint256 public constant FRIENDS_PRICE = 0.002 ether;
    uint256 public tokenCounter = 1;

    bool public isFriendSale = false;
    bool public isPublicSale = false;

    mapping(uint256 => uint256) private seeds;
    mapping(address => uint256) private mintedAddress;
    mapping(address => bool) private founders;

    SpectrumGeneratorInterface public spectrumGenerator;

    constructor(SpectrumGeneratorInterface _spectrumGenerator)
        ERC721A("Kinetic Spectrum", "KS")
    {
        spectrumGenerator = _spectrumGenerator;
    }

    event onMintSuccess(address sender, uint256 tokenId);

    function _createSeed(uint256 _tokenId, address _address)
        internal
        view
        returns (uint256)
    {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        _tokenId,
                        _address,
                        utils.getRandomInteger("spectrum", _tokenId, 0, 42069),
                        block.difficulty,
                        block.timestamp
                    )
                )
            );
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        return spectrumGenerator.tokenURI(_tokenId, seeds[_tokenId]);
    }

    function mint(uint256 _q) external payable {
        require(founders[msg.sender], "You are not a founder");
        require(isPublicSale, "Sale has not started");
        require(_q > 0, "You should mint one");
        require(tokenCounter <= MAX_SPECTRUMS, "All metavatars minted");
        require(
            tokenCounter + _q <= MAX_SPECTRUMS,
            "Minting exceeds max supply"
        );
        require(_q <= MAX_PER_ADDRESS, "Max 30 per wallet");
        require(
            mintedAddress[msg.sender] + _q <= MAX_PER_ADDRESS,
            "Minting exceeds max 30 per wallet"
        );
        require(PRICE * _q <= msg.value, "Min 0.3eth per Spectrum");
        uint256 currentTokenId = tokenCounter;

        _safeMint(msg.sender, _q);

        for (uint8 i = 0; i < _q; i++) {
            seeds[currentTokenId] = _createSeed(currentTokenId, msg.sender);
            mintedAddress[msg.sender] += _q;

            emit onMintSuccess(msg.sender, currentTokenId);

            tokenCounter++;
            currentTokenId++;
        }
    }

    function addFounder(address _address) external payable onlyOwner {
        founders[_address] = true;
    }

    function withdraw() external payable onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function startFriendSale() public onlyOwner {
        isFriendSale = true;
    }

    function stopFriendSale() public onlyOwner {
        isFriendSale = false;
    }

    function startPublicSale() public onlyOwner {
        isPublicSale = true;
    }

    function stopPublicSale() public onlyOwner {
        isPublicSale = false;
    }
}
