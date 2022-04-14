//SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./Utils.sol";
import "./SVG.sol";

library spectrum {
    function gradient(
        string memory _from,
        string memory _stop1,
        string memory _stop2,
        string memory _stop3,
        string memory _stop4
    ) internal pure returns (string memory) {
        return
            string.concat(
                "from ",
                _from,
                ", ",
                _stop1,
                " 0%, ",
                _stop2,
                " 25%, ",
                _stop3,
                " 50%, ",
                _stop4,
                " 100%"
            );
    }

    function styles(
        string memory _name,
        string memory _gradient,
        string memory _duration
    ) internal pure returns (string memory) {
        return
            string.concat(
                "<style>",
                ".",
                _name,
                " { animation: spin ",
                _duration,
                "ms infinite linear;",
                "background-image: conic-gradient(",
                _gradient,
                ");}",
                "</style>"
            );
    }

    function globalStyles() internal pure returns (string memory) {
        return
            string.concat(
                "<style>",
                "   div { position: absolute; top: 0; left: 0; width: 500px; height: 500px; border-radius: 50%; mix-blend-mode: multiple; }",
                "   @keyframes spin { from { transform: rotate(0deg) } to { transform: rotate(360deg) } }",
                "</style>"
            );
    }
}
