//SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "erc721a/contracts/ERC721A.sol";
import "./SVG.sol";
import "./Utils.sol";
import "./Base64.sol";

contract Main is ERC721A {
    constructor() ERC721A("Main", "TSTSTS") {}

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

    function getSVG64() internal pure returns (string memory) {
        string memory stringSvg = createSVG();
        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(bytes(stringSvg))
                )
            );
    }

    function uint2str(uint256 _i)
        internal
        pure
        returns (string memory _uintAsString)
    {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function tokenURI(uint256 tokenId)
        public
        pure
        override
        returns (string memory)
    {
        string memory svg64 = getSVG64();

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                uint2str(tokenId),
                                '", "description":"testest desc", "attributes":"", "image":"',
                                svg64,
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    function mint(uint256 quantity) external payable {
        _safeMint(msg.sender, quantity);
    }
}
