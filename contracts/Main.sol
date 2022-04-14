//SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "erc721a/contracts/ERC721A.sol";
import "./SVG.sol";
import "./Utils.sol";

contract Main is ERC721A {
    constructor() ERC721A("MainTest", "TSTSTS") {}

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

    function getSVG() external pure returns (string memory) {
        return createSVG();
    }

    function mint(uint256 quantity) external payable {
        // _safeMint's second argument now takes in a quantity, not a tokenId.
        _safeMint(msg.sender, quantity);
    }
}
