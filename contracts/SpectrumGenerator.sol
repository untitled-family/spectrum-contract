//SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

// Name: Spectrum Generator
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
import "./SpectrumGeneratorInterface.sol";

contract SpectrumGenerator is SpectrumGeneratorInterface {
    uint256 private MIN_LAYERS = 1;
    uint256 private MAX_LAYERS = 3;
    uint256 private MIN_DURATION = 20000;
    uint256 private MAX_DURATION = 40000;

    mapping(uint256 => string) private _tokenURIs;

    uint256 public tokenCounter;

    constructor() {}

    function _createLayer(
        string memory _name,
        string memory _duration,
        string memory _gradient
    ) internal pure returns (string memory) {
        return
            string.concat(
                svg.foreignObject(
                    string.concat(
                        svg.prop(
                            "style",
                            "mix-blend-mode: multiply; transform: scale(1);"
                        ),
                        svg.prop("x", "0"),
                        svg.prop("y", "0"),
                        svg.prop("width", "1000"),
                        svg.prop("height", "1000")
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

    function _createBaseLayers(uint256 _seed)
        internal
        view
        returns (string memory)
    {
        uint256 r = utils.getRandomInteger("base", _seed, 0, 255);
        uint256[3] memory arr = [r, 255, 0];
        uint256[3] memory shuffledArr = utils.shuffle(arr, _seed);
        uint256 duration = utils.getRandomInteger(
            "base",
            _seed,
            MIN_DURATION,
            MAX_DURATION
        );
        uint256 oppDuration = utils.getRandomInteger(
            "base_opposite",
            _seed,
            MIN_DURATION,
            MAX_DURATION
        );
        string memory deg = utils.uint2str(
            utils.getRandomInteger("deg", _seed, 0, 360)
        );
        string memory oppDeg = utils.uint2str(
            utils.getRandomInteger("oppDeg", _seed, 0, 360)
        );
        return
            string.concat(
                _createLayer(
                    "base",
                    utils.uint2str(duration),
                    spectrum.gradient(
                        string.concat(deg, "deg"),
                        string.concat(
                            utils.uint2str(shuffledArr[0]),
                            ",",
                            utils.uint2str(shuffledArr[1]),
                            ",",
                            utils.uint2str(shuffledArr[2])
                        )
                    )
                ),
                _createLayer(
                    "base_opposite",
                    utils.uint2str(oppDuration),
                    spectrum.gradient(
                        string.concat(oppDeg, "deg"),
                        string.concat(
                            utils.uint2str(
                                utils.oppositeNumber(shuffledArr[0], 255)
                            ),
                            ",",
                            utils.uint2str(
                                utils.oppositeNumber(shuffledArr[1], 255)
                            ),
                            ",",
                            utils.uint2str(
                                utils.oppositeNumber(shuffledArr[2], 255)
                            )
                        )
                    )
                )
            );
    }

    function _createAltLayers(uint256 _seed)
        internal
        view
        returns (string memory)
    {
        uint256 iterations = utils.getRandomInteger(
            "iterations",
            _seed,
            MIN_LAYERS,
            MAX_LAYERS
        );
        string memory layers;

        for (uint8 i = 0; i < iterations; i++) {
            string memory id = utils.uint2str(i);
            uint256 duration = utils.getRandomInteger(
                id,
                _seed,
                MIN_DURATION,
                MAX_DURATION
            );
            uint256 r = utils.getRandomInteger(
                string.concat("r_", id),
                _seed,
                0,
                255
            );
            uint256[3] memory arr = [r, 0, 255];
            uint256[3] memory shuffledArr = utils.shuffle(arr, i);
            string memory deg = utils.uint2str(
                utils.getRandomInteger(string.concat("deg_", id), _seed, 0, 360)
            );

            layers = string.concat(
                layers,
                _createLayer(
                    string.concat("layer_", id),
                    utils.uint2str(duration),
                    spectrum.gradient(
                        string.concat(deg, "deg"),
                        string.concat(
                            utils.uint2str(shuffledArr[0]),
                            ",",
                            utils.uint2str(shuffledArr[1]),
                            ",",
                            utils.uint2str(shuffledArr[2])
                        )
                    )
                )
            );
        }

        return layers;
    }

    function _createSvg(uint256 _seed) internal view returns (string memory) {
        string memory stringSvg = string.concat(
            '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 1000 1000">',
            _createAltLayers(_seed),
            _createBaseLayers(_seed),
            spectrum.globalStyles(),
            "</svg>"
        );

        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(bytes(stringSvg))
                )
            );
    }

    function _prepareMetadata(uint256 tokenId, string memory image)
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

    function tokenURI(uint256 _tokenId, uint256 _seed)
        external
        view
        returns (string memory)
    {
        string memory svg64 = _createSvg(_seed);

        return _prepareMetadata(_tokenId, svg64);
    }
}
