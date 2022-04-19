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
    uint256 private MIN_LAYERS = 1;
    uint256 private MAX_LAYERS = 3;
    uint256 private MIN_DURATION = 20000;
    uint256 private MAX_DURATION = 40000;
    string TEMP_SEED =
        "h1232648234sdfdfs123456789fs289374829fghf374dkjfhuhtyysdgdst1234dsf5dsf6789sdf1`1322312fhf";

    mapping(uint256 => string) private _tokenURIs;

    uint256 public tokenCounter;

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
                        svg.prop("style", "mix-blend-mode: multiply"),
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

    function getBaseLayers(string memory seed)
        private
        view
        returns (string memory)
    {
        uint256 r = utils.getRandomInteger("base", seed, 0, 255);
        uint256[3] memory arr = [r, 255, 0];
        uint256[3] memory shuffledArr = utils.shuffle(arr, seed);
        uint256 duration = utils.getRandomInteger(
            "base",
            seed,
            MIN_DURATION,
            MAX_DURATION
        );
        uint256 oppDuration = utils.getRandomInteger(
            "base_opposite",
            seed,
            MIN_DURATION,
            MAX_DURATION
        );
        string memory deg = utils.uint2str(
            utils.getRandomInteger("deg", seed, 0, 360)
        );
        string memory oppDeg = utils.uint2str(
            utils.getRandomInteger("oppDeg", seed, 0, 360)
        );
        return
            string.concat(
                createLayer(
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
                createLayer(
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

            i++;
        }

        return layers;
    }

    function getSeed(uint256 _tokenId) internal view returns (string memory) {
        return
            string.concat(
                utils.uint2str(block.difficulty),
                utils.uint2str(block.timestamp),
                utils.uint2str(_tokenId)
            );
    }

    function getSVG(string memory _seed) internal view returns (string memory) {
        return
            string.concat(
                '<svg xmlns="http://www.w3.org/2000/svg" width="500" height="500">',
                getLayers(_seed),
                getBaseLayers(_seed),
                spectrum.globalStyles(),
                "</svg>"
            );
    }

    /*
     * TODO: Make this function `internal` instead of public
     */
    function getSvgBase64(string memory _seed)
        internal
        view
        returns (string memory)
    {
        string memory stringSvg = getSVG(_seed);

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
     * get token uri
     */
    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        string memory _tokenURI = _tokenURIs[_tokenId];

        return _tokenURI;
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI)
        internal
        virtual
    {
        require(
            _exists(tokenId),
            "ERC721URIStorage: URI set of nonexistent token"
        );
        _tokenURIs[tokenId] = _tokenURI;
    }

    function mint(uint256 _q) external payable {
        uint256 tokenId = tokenCounter;
        // require(
        //     bytes(tokenURI(tokenId)).length <= 0,
        //     "tokenURI is already set!"
        // );

        _safeMint(msg.sender, _q);

        for (uint8 i = 0; i < _q; i++) {
            tokenCounter = tokenCounter + 1;

            string memory seed = getSeed(tokenId);
            string memory img = getSvgBase64(seed);
            // setTokenURI(tokenId, );

            string memory URI = getMetadata(tokenId, img);
            setTokenURI(tokenId, URI);

            tokenId++;
        }
    }
}
