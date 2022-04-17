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
    uint256 MIN_LAYERS = 2;
    uint256 MAX_LAYERS = 10;
    uint256 MIN_DURATION = 15000;
    uint256 MAX_DURATION = 30000;

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
                            svg.prop("xmlns", "http://www.w3.org/1999/xhtml"),
                            svg.prop(
                                "style",
                                spectrum.styles(_gradient, _duration)
                            )
                        ),
                        utils.NULL
                    )
                )
            );
    }

    function getLayers(string memory seed)
        private
        view
        returns (string memory)
    {
        uint256 i;
        uint256 iterations = utils.getRandomInteger(
            "iterations",
            seed,
            MIN_LAYERS,
            MAX_LAYERS
        );
        string memory layers;

        while (i < iterations) {
            string memory id = utils.uint2str(i);
            uint256 duration = utils.getRandomInteger(
                id,
                seed,
                MIN_DURATION,
                MAX_DURATION
            );
            uint256 r = utils.getRandomInteger(
                string.concat("r_", id),
                seed,
                0,
                255
            );
            uint256 g = utils.getRandomInteger(
                string.concat("g_", id),
                seed,
                0,
                255
            );
            uint256 b = utils.getRandomInteger(
                string.concat("b_", id),
                seed,
                0,
                255
            );
            string memory deg = utils.uint2str(
                utils.getRandomInteger(string.concat("deg_", id), seed, 0, 360)
            );

            layers = string.concat(
                layers,
                createLayer(
                    string.concat("layer_", id),
                    utils.uint2str(duration),
                    spectrum.gradient(
                        string.concat(deg, "deg"),
                        utils.rgba(r, g, b, 5),
                        utils.rgba(r, g, b, 90),
                        utils.rgba(r, g, b, 5),
                        utils.rgba(r, g, b, 5)
                    )
                )
            );

            i++;
        }

        return layers;
    }

    function getSeed() internal view returns (string memory) {
        return
            string.concat(
                utils.uint2str(block.difficulty),
                utils.uint2str(block.timestamp),
                "0xC784Fd3553517E4E930bfA53E0a5e1F053311bC3"
            );
    }

    function getSVG() public view returns (string memory) {
        return
            string.concat(
                '<svg xmlns="http://www.w3.org/2000/svg" width="500" height="500">',
                getLayers(getSeed()),
                spectrum.globalStyles(),
                "</svg>"
            );
    }

    /*
     * TODO: Make this function `internal` instead of public
     */
    function svgToBase64() public view returns (string memory) {
        string memory stringSvg = getSVG();

        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(bytes(stringSvg))
                )
            );
    }

    function getMetadata(uint256 tokenId, string memory image)
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

    /*
     * TODO: This should have tokenId as argument
     */
    function _tokenURI() public view returns (string memory) {
        string memory base64svg = svgToBase64();

        return getMetadata(0, base64svg);
    }

    /*
     * TODO: This should create seed - store seed in tokenURIs[]
     */
    function mint(uint256 quantity) external payable {
        _safeMint(msg.sender, quantity);
    }
}
