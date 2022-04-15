//SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

// Title: Spectrum
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
import "./SVG.sol";
import "./Utils.sol";
import "./Base64.sol";
import "./SpectrumLib.sol";

contract Main is ERC721A {
    constructor() ERC721A("Main", "TSTSTS") {}

    function createLayer(
        string memory _name,
        string memory _duration,
        string memory _gradient
    ) internal pure returns (string memory) {
        return
            string.concat(
                svg.foreignObject(
                    string.concat(
                        svg.prop("x", "0"),
                        svg.prop("y", "0"),
                        svg.prop("width", "500"),
                        svg.prop("height", "500")
                    ),
                    svg.div(
                        string.concat(
                            svg.prop(
                                "class",
                                string.concat(_name, " spectrum")
                            ),
                            svg.prop("xmlns", "http://www.w3.org/1999/xhtml")
                        ),
                        utils.NULL
                    )
                ),
                spectrum.styles(_name, _gradient, _duration)
            );
    }

    function createSVG() public pure returns (string memory) {
        return
            string.concat(
                '<svg xmlns="http://www.w3.org/2000/svg" width="500" height="500">',
                createLayer(
                    "layer1",
                    "20000",
                    spectrum.gradient(
                        "0deg",
                        "rgba(255,000,255,0.05)",
                        "rgba(255,000,255,0.9)",
                        "rgba(255,000,255,0.05)",
                        "rgba(255,000,255,0.05)"
                    )
                ),
                createLayer(
                    "layer2",
                    "22000",
                    spectrum.gradient(
                        "120deg",
                        "rgba(255,255,0,0.05)",
                        "rgba(255,255,0,0.9)",
                        "rgba(255,255,0,0.05)",
                        "rgba(255,255,0,0.05)"
                    )
                ),
                createLayer(
                    "layer3",
                    "24000",
                    spectrum.gradient(
                        "240deg",
                        "rgba(0,255,255,0.05)",
                        "rgba(0,255,255,0.9)",
                        "rgba(0,255,255,0.05)",
                        "rgba(0,255,255,0.05)"
                    )
                ),
                spectrum.globalStyles(),
                "</svg>"
            );
    }

    function svgToBase64() internal pure returns (string memory) {
        string memory stringSvg = createSVG();

        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(bytes(stringSvg))
                )
            );
    }

    function createMetadata(uint256 tokenId, string memory image)
        internal
        pure
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                utils.uint2str(tokenId),
                                '", "description":"testest desc", "attributes":"", "image":"',
                                image,
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    function tokenURI(uint256 tokenId)
        public
        pure
        override
        returns (string memory)
    {
        string memory base64svg = svgToBase64();

        return createMetadata(tokenId, base64svg);
    }

    function mint(uint256 quantity) external payable {
        _safeMint(msg.sender, quantity);
    }
}
