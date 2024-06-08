// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FlowerShop {
    address public owner;
    
    struct User {
        bool registered;
        uint256 balance;
        mapping(uint256 => uint256) cart;
        uint256[] orders; 
    }
    
    struct Flower {
        string name;
        uint256 price;
        uint256 inventory;
    }
    
    mapping(address => User) public users;
    mapping(uint256 => Flower) public flowers;
    uint256 public nextOrderId;
    uint256 public nextFlowerId;
    
    event UserRegistered(address indexed user);
    event FlowerAdded(uint256 indexed id, string name, uint256 price);
    event OrderPlaced(address indexed user, uint256 indexed orderId, uint256 totalAmount);
    
    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // Function to get quantity of a specific flower in user's cart
    function getCartQuantity(address user, uint256 flowerId) external view returns (uint256) {
        return users[user].cart[flowerId];
    }

    // Function to add funds to user's balance
    function addToBalance(uint256 amount) external {
        users[msg.sender].balance += amount;
    }

    function registerUser() external {
        require(!users[msg.sender].registered, "User already registered");
        users[msg.sender].registered = true;
        emit UserRegistered(msg.sender);
    }
    
    function addFlower(string memory name, uint256 price, uint256 inventory) external onlyOwner {
        uint256 flowerId = nextFlowerId++;
        flowers[flowerId] = Flower(name, price, inventory);
        emit FlowerAdded(flowerId, name, price);
    }
    
    function addToCart(uint256 flowerId, uint256 quantity) external {
        require(users[msg.sender].registered, "User not registered");
        require(quantity > 0, "Quantity must be greater than zero");
        require(flowers[flowerId].inventory >= quantity, "Not enough inventory");
        users[msg.sender].cart[flowerId] += quantity;
        flowers[flowerId].inventory -= quantity;
    }
    
    function placeOrder() external {
        require(users[msg.sender].registered, "User not registered");

        // Check if user has items in cart
        bool cartNotEmpty = false;
        for (uint256 i = 0; i < nextFlowerId; i++) {
            if (users[msg.sender].cart[i] > 0) {
                cartNotEmpty = true;
                break;
            }
        }
        require(cartNotEmpty, "Cart is empty");

        uint256 orderId = nextOrderId++;
        users[msg.sender].orders.push(orderId);

        // Process order and calculate total amount
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < nextFlowerId; i++) {
            uint256 flowerId = i;
            uint256 quantity = users[msg.sender].cart[flowerId];
            if (quantity > 0) {
                totalAmount += flowers[flowerId].price * quantity;
                // Clear cart item after processing order
                users[msg.sender].cart[flowerId] = 0;
            }
        }

        // Deduct total amount from user's balance
        require(users[msg.sender].balance >= totalAmount, "Insufficient balance");
        users[msg.sender].balance -= totalAmount;

        emit OrderPlaced(msg.sender, orderId, totalAmount);
    }
}
