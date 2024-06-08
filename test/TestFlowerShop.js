
const FlowerShop = artifacts.require("FlowerShop");

contract("FlowerShop", function(accounts) {
    let flowerShopInstance;

    beforeEach(async function() {
        flowerShopInstance = await FlowerShop.new();
    });

    it("should register a new user", async function() {
        await flowerShopInstance.registerUser({from: accounts[0]});
        let user = await flowerShopInstance.users(accounts[0]);
        assert(user.registered, "User should be registered");
    });

    it("should add a flower", async function() {
        await flowerShopInstance.addFlower("Rose", 100, 10);
        let flower = await flowerShopInstance.flowers(0);
        assert.equal(flower.name, "Rose", "Flower name should be Rose");
    });

    it("should add a flower to cart", async function() {
        await flowerShopInstance.registerUser({from: accounts[0]});
        await flowerShopInstance.addFlower("Rose", 100, 10);
        await flowerShopInstance.addToCart(0, 2, {from: accounts[0]});
        let quantity = await flowerShopInstance.getCartQuantity(accounts[0], 0);
        assert.equal(quantity, 2, "Quantity should be 2");
    });

    it("should place an order", async function() {
        await flowerShopInstance.registerUser({from: accounts[0]});
        await flowerShopInstance.addFlower("Rose", 100, 10);
        await flowerShopInstance.addToCart(0, 2, {from: accounts[0]});
        await flowerShopInstance.addToBalance(1000, {from: accounts[0]});
        let user = await flowerShopInstance.users(accounts[0])
        let initialBalance = user.balance;
        await flowerShopInstance.placeOrder({from: accounts[0]});
        // let finalBalance = user.balance;
        // assert(finalBalance < initialBalance, "Balance should be decreased after placing order");
    });

    it("should get quantity of flower in cart", async function() {
        await flowerShopInstance.registerUser({from: accounts[0]});
        await flowerShopInstance.addFlower("Rose", 100, 10);
        await flowerShopInstance.addToCart(0, 2, {from: accounts[0]});
        let quantity = await flowerShopInstance.getCartQuantity(accounts[0], 0);
        console.log(`Quantity: ${quantity}`)
        assert.equal(quantity, 2, "Quantity should be 2");
    });

    it("should add funds to user's balance", async function() {
        await flowerShopInstance.addToBalance(1000, {from: accounts[0]});
        let user=await flowerShopInstance.users(accounts[0])
        let balance = user.balance;
       // console.log(`balance: ${user}`)
        assert.equal(balance, 1000, "Balance should be increased to 1000");
    });
});
