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

import "erc721a/contracts/ERC721A.sol";
import "./Utils.sol";
import "./SpectrumLib.sol";
import "./SpectrumGeneratorInterface.sol";

contract Main is ERC721A {
    uint256 public constant MAX_SPECTRUMS = 1111;
    uint256 public constant MAX_PER_ADDRESS = 1111;
    uint256 public constant MAX_PER_ADDRESS_WL = 5;
    uint256 public constant PRICE = 0.025 ether;
    uint256 public tokenCounter;

    SpectrumGeneratorInterface public spectrumGenerator;

    mapping(uint256 => uint256) private seeds;
    mapping(address => uint256) private mintedAddress;

    // IMetavatarGenerator public generator;

    constructor(SpectrumGeneratorInterface _spectrumGenerator)
        ERC721A("Main", "TSTSTS")
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

    /**
     * TODO: make sure it's nonReentrant
     */
    function mint(uint256 _q) external payable {
        // require(_q > 0, "You should mint one");
        // require(tokenCounter <= MAX_SPECTRUMS, "All metavatars minted");
        // require(
        //     tokenCounter + _q <= MAX_SPECTRUMS,
        //     "Minting exceeds max supply"
        // );
        // require(
        //     mintedAddress[msg.sender] + _q <= MAX_PER_ADDRESS,
        //     "Max 30 per wallet"
        // );
        // require(_q <= MAX_PER_ADDRESS, "Max 30 per wallet");
        // require(PRICE * _q <= msg.value, "Min 0.25eth per Spectrum");
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
}
