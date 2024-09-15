// SPDX-License-Identifier: MIT

pragma solidity 0.8.27;

// Custom errors for better gas efficiency and error reporting
contract EventErrors {
    error SeatAlreadyTaken(uint256 _seat);
    error NotOwner();
    error EventDoesNotExist();
    error InsufficientPayment();
    error InvalidSeatNumber();
    error WithdrawalFailed();
    error ZeroAddress();
    error SoulboundTokenCannotBeTransferred();
}
