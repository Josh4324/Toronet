// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title A WasteToCoin Contract
 * @author Joshua Adesanya
 * @notice This contract is for managing and rewarding recycling waste.
 */

// Environmental Actions
// Waste Submission
// Tree Planting

contract ECO4Reward is Ownable {
    // Errors
    error ECO__NotOwner();
    error ECO__NotAdmin();
    error ECO__InsufficientPoint();

    // State Variables
    address private ownerECO;
    uint256 private actionCount;
    uint256 private wasteCount;
    uint256 private treeCount;
    uint256 private userCount;
    uint256 private all_trees;
    uint256 private all_waste;
    uint256 private all_actions;
    uint256 private paid_out;
    uint256 private amount_donated;
    Users[] private all_users;

    struct Actions {
        uint256 id;
        string action_type;
        string description;
        string proof;
        bool status;
        address creator;
    }

    struct Waste {
        uint256 id;
        uint256 weight; // kg;
        bool status;
        address creator;
    }

    struct Trees {
        uint256 id;
        uint256 no_of_trees;
        bool status;
        address creator;
    }

    struct Users {
        uint256 id;
        uint256 trees;
        uint256 waste;
        uint256 actions;
        uint256 overall_score;
        uint256 score;
        address user;
    }

    // Events

    // Mappings
    mapping(address => bool) private adminToBool;
    mapping(address => bool) private usersList;
    mapping(address => Users) private usersData;
    mapping(uint256 => Actions) private idToActions;
    mapping(uint256 => Waste) private idToWaste;
    mapping(uint256 => Trees) private idToTrees;

    // Modifiers
    modifier onlyAdmin() {
        if (adminToBool[msg.sender] != true) revert ECO__NotAdmin();
        _;
    }

    modifier onlyOwnerECO() {
        if (ownerECO != msg.sender) revert ECO__NotOwner();
        _;
    }

    // Constructor

    constructor() Ownable(msg.sender) {
        ownerECO = msg.sender;
        adminToBool[msg.sender] = true;
    }

    // External Functions

    /*
     * @notice Add an admin
     *  
     *  
     */
    function addAdmin(address user) external onlyOwnerECO {
        adminToBool[user] = true;
    }

    /*
     * @notice Register Environmental Action
     *  
     *  
     */
    function registerAction(string calldata action_type, string calldata desc, string calldata proof) external {
        idToActions[actionCount] = Actions(actionCount, action_type, desc, proof, false, msg.sender);
        actionCount++;
    }

    /*
     * @notice Evaluate Environmental Action
     *  
     *  
     */
    function confirmAction(uint256 id, uint256 score) external onlyAdmin {
        idToActions[id].status = true;
        if (usersList[idToActions[id].creator] != true) {
            usersList[idToActions[id].creator] = true;
            Users memory newUser = Users(userCount, 0, 0, 0, 0, 0, idToActions[id].creator);
            usersData[idToActions[id].creator] = newUser;
            all_users.push(newUser);
            userCount++;
        }

        usersData[idToActions[id].creator].overall_score = usersData[idToActions[id].creator].overall_score + score;
        usersData[idToActions[id].creator].score = usersData[idToActions[id].creator].score + score;
        usersData[idToActions[id].creator].actions = usersData[idToActions[id].creator].actions + 1;

        all_actions = all_actions + 1;

        all_users[usersData[idToActions[id].creator].id].overall_score =
            all_users[usersData[idToActions[id].creator].id].overall_score + score;

        all_users[usersData[idToActions[id].creator].id].score =
            all_users[usersData[idToActions[id].creator].id].score + score;

        all_users[usersData[idToActions[id].creator].id].actions =
            all_users[usersData[idToActions[id].creator].id].actions + 1;
    }

    /*
     * @notice Register Waste Action
     *  
     *  
     */
    function registerWaste(uint256 weight) external {
        idToWaste[wasteCount] = Waste(wasteCount, weight, false, msg.sender);
        wasteCount++;
    }

    /*
     * @notice Evaluate Waste Action
     *  
     *  
     */
    function confirmWaste(uint256 id, uint256 score) external onlyAdmin {
        idToWaste[id].status = true;

        if (usersList[idToWaste[id].creator] != true) {
            usersList[idToWaste[id].creator] = true;
            Users memory newUser = Users(userCount, 0, 0, 0, 0, 0, idToWaste[id].creator);
            usersData[idToWaste[id].creator] = newUser;
            all_users.push(newUser);
            userCount++;
        }

        usersData[idToWaste[id].creator].overall_score = usersData[idToWaste[id].creator].overall_score + score;
        usersData[idToWaste[id].creator].score = usersData[idToWaste[id].creator].score + score;
        usersData[idToWaste[id].creator].waste = usersData[idToWaste[id].creator].waste + idToWaste[id].weight;
        all_waste = all_waste + idToWaste[id].weight;

        all_users[usersData[idToWaste[id].creator].id].overall_score =
            all_users[usersData[idToWaste[id].creator].id].overall_score + score;

        all_users[usersData[idToWaste[id].creator].id].score =
            all_users[usersData[idToWaste[id].creator].id].score + score;

        all_users[usersData[idToWaste[id].creator].id].waste =
            all_users[usersData[idToWaste[id].creator].id].waste + idToWaste[id].weight;
    }

    /*
     * @notice Register Waste Action
     *  
     *  
     */
    function registerTrees(uint256 no_of_tress) external {
        idToTrees[treeCount] = Trees(treeCount, no_of_tress, false, msg.sender);
        treeCount++;
    }

    /*
     * @notice Evaluate Waste Action
     *  
     *  
     */
    function confirmTress(uint256 id, uint256 score) external onlyAdmin {
        idToTrees[id].status = true;

        if (usersList[idToTrees[id].creator] != true) {
            usersList[idToTrees[id].creator] = true;
            Users memory newUser = Users(userCount, 0, 0, 0, 0, 0, idToTrees[id].creator);
            usersData[idToTrees[id].creator] = newUser;
            all_users.push(newUser);
            userCount++;
        }

        usersData[idToTrees[id].creator].overall_score = usersData[idToTrees[id].creator].overall_score + score;
        usersData[idToTrees[id].creator].score = usersData[idToTrees[id].creator].score + score;
        usersData[idToTrees[id].creator].trees = usersData[idToTrees[id].creator].trees + idToTrees[id].no_of_trees;
        all_trees = all_trees + idToTrees[id].no_of_trees;

        all_users[usersData[idToTrees[id].creator].id].overall_score =
            all_users[usersData[idToWaste[id].creator].id].overall_score + score;

        all_users[usersData[idToTrees[id].creator].id].score =
            all_users[usersData[idToTrees[id].creator].id].score + score;

        all_users[usersData[idToTrees[id].creator].id].trees =
            all_users[usersData[idToTrees[id].creator].id].trees + idToTrees[id].no_of_trees;
    }

    /*
     * @notice Swap Points for Payment
     *  
     *  
     */
    function getPaid(uint256 points) external {
        if (points > usersData[msg.sender].score) {
            revert ECO__InsufficientPoint();
        }

        // 1 points = 0.1 toro
        uint256 amount = points * 0.1 ether;

        usersData[msg.sender].score = usersData[msg.sender].score - points;
        all_users[usersData[msg.sender].id].score = all_users[usersData[msg.sender].id].score - points;
        paid_out = paid_out + amount;

        (bool success,) = (msg.sender).call{value: amount}("");
        require(success, "Failed to send funds");
    }

    /*
     * @notice Donate or Add funds 4 ECOPROJECT
     *  
     *  
     */
    function donateOrFund() external payable {
        amount_donated = amount_donated + msg.value;
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

    // Public Functions

    /*
     * @notice Get User Info
     *  
     *  
     */
    function getUserData(address user) public view returns (Users memory) {
        return usersData[user];
    }

    /*
     * @notice Get Contract Info
     *  
     *  
     */
    function getContractData() public view returns (uint256, uint256, uint256, uint256, uint256) {
        return (all_actions, all_waste, all_trees, userCount, paid_out);
    }

    function getUserList() public view returns (Users[] memory) {
        return all_users;
    }
}
