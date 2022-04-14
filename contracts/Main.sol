//SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./SVG.sol";
import "./Utils.sol";
import "./Base64.sol";

contract Main is ERC721 {
    uint256 tokenIdsCount;

    constructor() ERC721("MainTest", "TSTSTS") {}

    function createSVG() public pure returns (string memory) {
        return
            string.concat(
                '<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100">',
                svg.circle(
                    string.concat(
                        svg.prop("fill", "none"),
                        svg.prop("cx", "50"),
                        svg.prop("cy", "50"),
                        svg.prop("r", "50"),
                        svg.prop("width", utils.uint2str(160)),
                        svg.prop("height", utils.uint2str(10))
                    ),
                    utils.NULL
                ),
                svg.foreignObject(
                    string.concat(
                        svg.prop("x", "0"),
                        svg.prop("y", "0"),
                        svg.prop("width", utils.uint2str(100)),
                        svg.prop("height", utils.uint2str(100))
                    ),
                    svg.div(
                        string.concat(
                            svg.prop("class", "magenta"),
                            svg.prop("xmlns", "http://www.w3.org/1999/xhtml")
                        ),
                        utils.NULL
                    )
                ),
                "<style>",
                "   div { position: absolute; top: 0; left: 0; width: 100px; height: 100px; border-radius: 50%; mix-blend-mode: multiple; }",
                "   .magenta { animation: spin 2s infinite linear; background-image: conic-gradient(from 0deg, rgba(255,000,255,0.05) 0%, rgba(255,000,255,0.9) 25%, rgba(255,000,255,0.05) 50%, rgba(255,000,255,0.05) 100%); }",
                "   @keyframes spin { from { transform: rotate(0deg) } to { transform: rotate(360deg) } }",
                "</style>",
                "</svg>"
            );
    }

    function metadata(
        uint256 tokenId,
        string memory tokenName,
        string memory tokenDescription,
        string memory svgString
    ) internal pure returns (string memory) {
        string memory json = string(
            abi.encodePacked(
                '{"name":"',
                tokenName,
                "_",
                tokenId,
                '","description":"',
                tokenDescription,
                '","image": "data:image/svg+xml;base64,',
                Base64.encode(bytes(svgString)),
                '"}'
            )
        );
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(bytes(json))
                )
            );
    }

    function tokenURI(uint256 tokenId)
        public
        pure
        override
        returns (string memory)
    {
        return metadata(tokenId, "test", "test desc", createSVG());
    }

    function getTokenIdsCount() external view returns (uint256) {
        return tokenIdsCount;
    }

    function mint(address recipient) public returns (uint256) {
        tokenIdsCount + 1;

        _mint(recipient, tokenIdsCount);

        return tokenIdsCount;
    }
}
