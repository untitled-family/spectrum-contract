//SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./Utils.sol";
import "./SVG.sol";

library spectrum {
    function gradient(string memory _from, string memory _rgb)
        internal
        pure
        returns (string memory)
    {
        return
            string.concat(
                "from ",
                _from,
                ", ",
                utils.rgbaString(_rgb, "05"),
                " 0%, ",
                utils.rgbaString(_rgb, "9"),
                " 25%, ",
                utils.rgbaString(_rgb, "05"),
                " 50%, ",
                utils.rgbaString(_rgb, "05"),
                " 100%"
            );
    }

    function styles(string memory _gradient, string memory _duration)
        internal
        pure
        returns (string memory)
    {
        return
            string.concat(
                "animation: spin ",
                _duration,
                "ms infinite linear;",
                "background-image: conic-gradient(",
                _gradient,
                ");"
            );
    }

    function globalStyles() internal pure returns (string memory) {
        return
            string.concat(
                "<style>",
                "   .spectrum { width: 100%; height: 100%; border-radius: 50%; }",
                "   @keyframes spin { from { transform: rotate(0deg) } to { transform: rotate(360deg) } }",
                "</style>"
            );
    }
}
