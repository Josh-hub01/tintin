// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Lib {
    function insertionSort(
        uint[] memory arr
    ) public pure returns (uint[] memory) {
        for (uint i = 1; i < arr.length; i++) {
            uint key = arr[i];
            int j = int(i) - 1;

            while (j >= 0 && arr[uint(j)] > key) {
                arr[uint(j + 1)] = arr[uint(j)];
                j--;
            }

            arr[uint(j + 1)] = key;
        }

        return arr;
    }

    function bubbleSort(uint[] memory arr) public pure returns (uint[] memory) {
        for (uint i = 0; i < arr.length; i++) {
            for (uint j = i + 1; j < arr.length; j++) {
                if (arr[i] > arr[j]) {
                    uint temp = arr[i];
                    arr[i] = arr[j];
                    arr[j] = temp;
                }
            }
        }
        return arr;
    }
}
