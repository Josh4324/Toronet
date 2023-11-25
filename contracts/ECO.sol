// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

//import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title A ECO4Reward Contract
 * @author Joshua Adesanya
 * @notice This contract is for managing and rewarding environmental actions.
 */

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
        bool confirmed;
        address creator;
    }

    struct Waste {
        uint256 id;
        uint256 weight; // kg;
        bool sorted;
        bool status;
        bool confirmed;
        address creator;
    }

    struct Trees {
        uint256 id;
        uint256 no_of_trees;
        string locations;
        bool status;
        bool confirmed;
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
    event actionCreated(
        uint256 id, string action_type, string description, string proof, bool status, bool confirmed, address creator
    );

    event actionUpdated(uint256 id, bool status, bool confirmed, address creator);
    event wasteCreated(uint256 id, uint256 weight, bool sorted, bool status, bool confirmed, address creator);
    event wasteUpdated(uint256 id, bool status, bool confirmed, address creator);
    event treeCreated(uint256 id, uint256 no_of_trees, string locations, bool status, bool confirmed, address creator);
    event treeUpdated(uint256 id, bool status, bool confirmed, address creator);
    event userCreated(
        uint256 id, uint256 trees, uint256 waste, uint256 actions, uint256 overall_score, uint256 score, address user
    );
    event userUpdatedActions(uint256 actions, uint256 overall_score, uint256 score, address user);
    event userUpdatedWaste(uint256 waste, uint256 overall_score, uint256 score, address user);
    event userUpdatedTree(uint256 trees, uint256 overall_score, uint256 score, address user);
    event userUpdatedScore(uint256 score, address user);

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

    constructor() {
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
        idToActions[actionCount] = Actions(actionCount, action_type, desc, proof, false, false, msg.sender);
        emit actionCreated(actionCount, action_type, desc, proof, false, false, msg.sender);
        actionCount++;
    }

    /*
     * @notice Evaluate Environmental Action
     *  
     *  
     */
    function confirmAction(uint256 id, uint256 score, bool status) external onlyAdmin {
        idToActions[id].status = status;
        idToActions[id].confirmed = true;
        if (usersList[idToActions[id].creator] != true) {
            usersList[idToActions[id].creator] = true;
            Users memory newUser = Users(userCount, 0, 0, 0, 0, 0, idToActions[id].creator);
            usersData[idToActions[id].creator] = newUser;
            all_users.push(newUser);
            emit userCreated(userCount, 0, 0, 0, 0, 0, idToActions[id].creator);
            userCount++;
        }

        if (status == true) {
            usersData[idToActions[id].creator].overall_score = usersData[idToActions[id].creator].overall_score + score;
            usersData[idToActions[id].creator].score = usersData[idToActions[id].creator].score + score;
            usersData[idToActions[id].creator].actions = usersData[idToActions[id].creator].actions + 1;

            all_actions = all_actions + 1;
            emit userUpdatedActions(
                usersData[idToActions[id].creator].actions,
                usersData[idToActions[id].creator].overall_score,
                usersData[idToActions[id].creator].score,
                idToActions[id].creator
            );

            all_users[usersData[idToActions[id].creator].id].overall_score =
                all_users[usersData[idToActions[id].creator].id].overall_score + score;

            all_users[usersData[idToActions[id].creator].id].score =
                all_users[usersData[idToActions[id].creator].id].score + score;

            all_users[usersData[idToActions[id].creator].id].actions =
                all_users[usersData[idToActions[id].creator].id].actions + 1;
        }

        emit actionUpdated(id, status, true, idToActions[id].creator);
    }

    /*
     * @notice Register Waste Action
     *  
     *  
     */
    function registerWaste(uint256 weight, bool sorted) external {
        idToWaste[wasteCount] = Waste(wasteCount, weight, sorted, false, false, msg.sender);
        emit wasteCreated(wasteCount, weight, sorted, false, false, msg.sender);
        wasteCount++;
    }

    /*
     * @notice Evaluate Waste Action
     *  
     *  
     */
    function confirmWaste(uint256 id, uint256 score, bool status) external onlyAdmin {
        idToWaste[id].status = status;
        idToWaste[id].confirmed = true;

        if (usersList[idToWaste[id].creator] != true) {
            usersList[idToWaste[id].creator] = true;
            Users memory newUser = Users(userCount, 0, 0, 0, 0, 0, idToWaste[id].creator);
            usersData[idToWaste[id].creator] = newUser;
            all_users.push(newUser);
            emit userCreated(userCount, 0, 0, 0, 0, 0, idToActions[id].creator);
            userCount++;
        }

        if (status == true) {
            usersData[idToWaste[id].creator].overall_score = usersData[idToWaste[id].creator].overall_score + score;
            usersData[idToWaste[id].creator].score = usersData[idToWaste[id].creator].score + score;
            usersData[idToWaste[id].creator].waste = usersData[idToWaste[id].creator].waste + idToWaste[id].weight;
            all_waste = all_waste + idToWaste[id].weight;

            emit userUpdatedWaste(
                usersData[idToWaste[id].creator].waste,
                usersData[idToWaste[id].creator].overall_score,
                usersData[idToWaste[id].creator].score,
                idToWaste[id].creator
            );

            all_users[usersData[idToWaste[id].creator].id].overall_score =
                all_users[usersData[idToWaste[id].creator].id].overall_score + score;

            all_users[usersData[idToWaste[id].creator].id].score =
                all_users[usersData[idToWaste[id].creator].id].score + score;

            all_users[usersData[idToWaste[id].creator].id].waste =
                all_users[usersData[idToWaste[id].creator].id].waste + idToWaste[id].weight;
        }

        emit wasteUpdated(id, status, true, idToWaste[id].creator);
    }

    /*
     * @notice Register Waste Action
     *  
     *  
     */
    function registerTrees(uint256 no_of_tress, string calldata locations) external {
        idToTrees[treeCount] = Trees(treeCount, no_of_tress, locations, false, false, msg.sender);
        emit treeCreated(treeCount, no_of_tress, locations, false, false, msg.sender);
        treeCount++;
    }

    /*
     * @notice Evaluate Waste Action
     *  
     *  
     */
    function confirmTress(uint256 id, uint256 score, bool status) external onlyAdmin {
        idToTrees[id].status = status;
        idToTrees[id].confirmed = true;

        if (usersList[idToTrees[id].creator] != true) {
            usersList[idToTrees[id].creator] = true;
            Users memory newUser = Users(userCount, 0, 0, 0, 0, 0, idToTrees[id].creator);
            usersData[idToTrees[id].creator] = newUser;
            all_users.push(newUser);
            emit userCreated(userCount, 0, 0, 0, 0, 0, idToActions[id].creator);
            userCount++;
        }

        if (status == true) {
            usersData[idToTrees[id].creator].overall_score = usersData[idToTrees[id].creator].overall_score + score;
            usersData[idToTrees[id].creator].score = usersData[idToTrees[id].creator].score + score;
            usersData[idToTrees[id].creator].trees = usersData[idToTrees[id].creator].trees + idToTrees[id].no_of_trees;
            all_trees = all_trees + idToTrees[id].no_of_trees;

            emit userUpdatedTree(
                usersData[idToTrees[id].creator].trees,
                usersData[idToTrees[id].creator].overall_score,
                usersData[idToTrees[id].creator].score,
                idToTrees[id].creator
            );

            all_users[usersData[idToTrees[id].creator].id].overall_score =
                all_users[usersData[idToWaste[id].creator].id].overall_score + score;

            all_users[usersData[idToTrees[id].creator].id].score =
                all_users[usersData[idToTrees[id].creator].id].score + score;

            all_users[usersData[idToTrees[id].creator].id].trees =
                all_users[usersData[idToTrees[id].creator].id].trees + idToTrees[id].no_of_trees;
        }

        emit treeUpdated(id, status, true, idToTrees[id].creator);
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
        emit userUpdatedScore(usersData[msg.sender].score, msg.sender);
        paid_out = paid_out + amount;

        require(
            IERC20(0xff0dFAe9c45EeB5cA5d269BE47eea69eab99bf6C).transfer(msg.sender, amount), "token transfer failed"
        );
    }

    /*
     * @notice Donate or Add funds 4 ECOPROJECT
     *  
     *  
     */
    function donateOrFund(uint256 amount) external {
        amount_donated = amount_donated + amount;

        require(
            IERC20(0xff0dFAe9c45EeB5cA5d269BE47eea69eab99bf6C).transferFrom(msg.sender, address(this), amount),
            "token transfer failed"
        );
    }

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

    /*
     * @notice Get A list of all users details
     *  
     *  
     */
    function getUserList() public view returns (Users[] memory) {
        return all_users;
    }

    /*
     * @notice Get A list of all environmental actions
     *  
     *  
     */
    function getActions() public view returns (Actions[] memory) {
        uint256 currentIndex = 0;
        uint256 itemCount = 0;

        for (uint256 i = 0; i < actionCount; i++) {
            itemCount += 1;
        }

        Actions[] memory items = new Actions[](itemCount);

        for (uint256 i = 0; i < actionCount; i++) {
            uint256 currentId = i;

            Actions storage currentItem = idToActions[currentId];
            items[currentIndex] = currentItem;

            currentIndex += 1;
        }

        uint256 length = items.length;
        Actions[] memory reversedArray = new Actions[](length);

        for (uint256 i = 0; i < length; i++) {
            reversedArray[i] = items[length - 1 - i];
        }
        return reversedArray;
    }

    /*
     * @notice Get A list of all waste recyling actions
     *  
     *  
     */
    function getWasteActions() public view returns (Waste[] memory) {
        uint256 currentIndex = 0;
        uint256 itemCount = 0;

        for (uint256 i = 0; i < wasteCount; i++) {
            itemCount += 1;
        }

        Waste[] memory items = new Waste[](itemCount);

        for (uint256 i = 0; i < wasteCount; i++) {
            uint256 currentId = i;

            Waste storage currentItem = idToWaste[currentId];
            items[currentIndex] = currentItem;

            currentIndex += 1;
        }

        uint256 length = items.length;
        Waste[] memory reversedArray = new Waste[](length);

        for (uint256 i = 0; i < length; i++) {
            reversedArray[i] = items[length - 1 - i];
        }
        return reversedArray;
    }

    /*
     * @notice Get A list of all tree planting actions
     *  
     *  
     */
    function getTreeActions() public view returns (Trees[] memory) {
        uint256 currentIndex = 0;
        uint256 itemCount = 0;

        for (uint256 i = 0; i < treeCount; i++) {
            itemCount += 1;
        }

        Trees[] memory items = new Trees[](itemCount);

        for (uint256 i = 0; i < treeCount; i++) {
            uint256 currentId = i;

            Trees storage currentItem = idToTrees[currentId];
            items[currentIndex] = currentItem;

            currentIndex += 1;
        }

        uint256 length = items.length;
        Trees[] memory reversedArray = new Trees[](length);

        for (uint256 i = 0; i < length; i++) {
            reversedArray[i] = items[length - 1 - i];
        }
        return reversedArray;
    }
}
