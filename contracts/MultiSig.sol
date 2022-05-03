// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Multisig {
    address[] public approvers;
    uint256 public threshold;

    struct Transfer {
        uint256 id;
        uint256 amount;
        address payable to;
        uint256 approvals;
        bool sent;
    }

    mapping(uint256 => Transfer) transfers;
    mapping(address => mapping(uint256 => bool)) approvals;

    uint256 nextId;

    constructor(address[] memory _approvers, uint256 _threshold) payable {
        approvers = _approvers;
        threshold = _threshold;
    }

    modifier onlyApprover() {
        bool allowed = false;

        for (uint256 i = 0; i < approvers.length; i++) {
            if (approvers[i] == msg.sender) {
                allowed = true;
            }
        }
        require(allowed == true, "Not the owner own the safe");
        _;
    }

    function createTransaction(address payable to, uint256 amount)
        external
        onlyApprover
        returns (uint256)
    {
        transfers[nextId] = Transfer(nextId, amount, to, 0, false);
        nextId++;
        return nextId - 1;
    }

    function sendTransfer(uint256 id) external onlyApprover {
        require(transfers[id].sent == false, "Transfer already sent");
        require(
            transfers[id].approvals >= threshold,
            "Transaction require approvals"
        );

        transfers[id].sent = true;
        uint256 amount = transfers[id].amount;
        address payable to = transfers[id].to;

        to.transfer(amount);
        return;
    }

    function addApprover(uint256 id) external onlyApprover {
        if (approvals[msg.sender][id] == false) {
            approvals[msg.sender][id] = true;
            transfers[id].approvals++;
        }
    }
}
