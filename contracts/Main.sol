//SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

// Name: Spectrum
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
    uint256 MIN_LAYERS = 5;
    uint256 MAX_LAYERS = 6;
    uint256 MIN_DURATION = 5;
    uint256 MAX_DURATION = 30;
    string TEMP_SEED = "10fsdf0adgfgfdsjgfsdjfk";

    constructor() ERC721A("Main", "TSTSTS") {}

    function createLayer(
        string memory _name,
        string memory _duration,
        string memory _rgb,
        string memory _deg,
        string memory _invertDeg
    ) internal pure returns (string memory) {
        return
            string.concat(
                svg.g(
                    string.concat(
                        svg.prop("style", "mix-blend-mode: multiply")
                    ),
                    string.concat(
                        svg.circle(
                            string.concat(
                                svg.prop("cx", "500"),
                                svg.prop("cy", "500"),
                                svg.prop("r", "500"),
                                svg.prop(
                                    "fill",
                                    string.concat("url(#", _name, ")")
                                )
                            ),
                            utils.NULL
                        ),
                        svg.animateTransform(
                            string.concat(
                                svg.prop("attributeType", "xml"),
                                svg.prop("attributeName", "transform"),
                                svg.prop("type", "rotate"),
                                svg.prop(
                                    "from",
                                    string.concat(_deg, " 500 500")
                                ),
                                svg.prop(
                                    "to",
                                    string.concat("-", _invertDeg, " 500 500")
                                ),
                                svg.prop("dur", string.concat(_duration, "s")),
                                svg.prop("additive", "sum"),
                                svg.prop("repeatCount", "indefinite")
                            )
                        )
                    )
                ),
                svg.defs(
                    utils.NULL,
                    svg.radialGradient(
                        string.concat(
                            svg.prop("id", _name),
                            svg.prop("cx", "0"),
                            svg.prop("cy", "0"),
                            svg.prop("r", "1"),
                            svg.prop("gradientUnits", "userSpaceOnUse"),
                            svg.prop(
                                "gradientTransform",
                                "translate(500.001) rotate(90) scale(1000)"
                            )
                        ),
                        string.concat(
                            svg.gradientStop(0, _rgb, utils.NULL),
                            svg.gradientStop(
                                100,
                                _rgb,
                                string.concat(svg.prop("stop-opacity", "0"))
                            )
                        )
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
            uint256[3] memory arr = [r, 0, 255];
            uint256[3] memory shuffledArr = utils.shuffle(
                arr,
                utils.uint2str(i)
            );
            uint256 deg = utils.getRandomInteger(
                string.concat("deg_", id),
                seed,
                0,
                360
            );

            string memory invertDeg = utils.uint2str(360 - deg);

            layers = string.concat(
                layers,
                createLayer(
                    string.concat("layer_", id),
                    utils.uint2str(duration),
                    string.concat(
                        "rgb(",
                        utils.uint2str(shuffledArr[0]),
                        ",",
                        utils.uint2str(shuffledArr[1]),
                        ",",
                        utils.uint2str(shuffledArr[2]),
                        ")"
                    ),
                    utils.uint2str(deg),
                    invertDeg
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
                TEMP_SEED
            );
    }

    function getSVG() public view returns (string memory) {
        return
            string.concat(
                '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1000 1000" fill="none">',
                getLayers(getSeed()),
                // getBaseLayers(getSeed()),
                // spectrum.globalStyles(),
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
