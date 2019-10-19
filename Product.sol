pragma solidity >=0.4.24;

contract Product {
    
    // Variable: Owner;
    address payable owner;
    
    // Variable: SkuCount;
    uint skuCount;
    
    // State: For Sale
    enum State {ForSale, Sold, Shipped}
    
    // Struct item with the following attributes: name, sku, price, state, seller, buyer.
    struct Item {
        string name;
        uint sku;
        uint price;
        State state;
        address payable seller;
        address payable buyer;
    }
    
    // Mapping: Assign 'Item' a sku
    mapping (uint => Item) items;
    
    // Event ForSale
    event ForSale(uint skuCount);
    
    // Event Sold
    event Sold(uint sku);
    
    //Event Shipped
    event Shipped(uint sku);
    
    // Modifier: Only Owner
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    // Modifier: Verify Caller
    modifier verifyCaller( address _address) {
        require(msg.sender == _address);
        _;
    }
    
    // Modifier: Paid Enough
    modifier paidEnough(uint _price) {
        require(msg.value >= _price);
        _;
    }
    
    // Modifier: For Sale
    modifier forSale(uint _sku) {
        require(items[_sku].state == State.ForSale);
        _;
    }
    // Modifier: Sold
    modifier sold(uint _sku) {
        require(items[_sku].state == State.Sold);
        _;
    }
    
    // Define a modifier that checks the price and refunds the remaining balance
    modifier checkValue(uint _sku) {
        _;
        uint _price = items[_sku].price;
        uint amountToRefund = msg.value - _price;
        items[_sku].buyer.transfer(amountToRefund);
    }
    
    // Function: Contructor to set some initials values
    constructor() public {
        owner = msg.sender;
        skuCount = 0;
    }
    
    // Function: Add Item
    function addItem(string memory _name, uint _price) onlyOwner public {
        skuCount += 1;
        emit ForSale(skuCount);
        items[skuCount] = Item({
            name: _name,
            sku: skuCount,
            price: _price,
            state: State.ForSale,
            seller: msg.sender,
            buyer: address(0)
        });
    }
    // Function: Buy Item
    function buyItem(uint _sku) forSale(_sku) paidEnough(items[_sku].price) checkValue(_sku) public payable {
        address payable buyer = msg.sender;
        
        uint price = items[_sku].price;
//      Update buyer
        items[_sku].buyer = buyer;
//      Update State
        items[_sku].state = State.Sold;
//      Transfer money to seller
        items[_sku].seller.transfer(price);
//      emit the appropriate event
        emit Sold(_sku);
        
    }
    
    // Function: Fetch Item
    function fetchItem(uint _sku) public view returns (string memory name, uint sku, uint price, string memory stateIs, address seller, address buyer){
        uint state;
        name = items[_sku].name;
        sku = _sku;
        price = items[_sku].price;
        state = uint(items[_sku].state);
        if (state == 0) {
            stateIs = "For Sale";
        }
        if (state == 1) {
            stateIs = "Sold";
        }
        if (state == 2) {
            stateIs = "Shipped";
        }
        
        seller = items[_sku].seller;
        buyer = items[_sku].buyer;
    }
    
    function shipItem(uint _sku)  sold(_sku) verifyCaller(items[_sku].seller) public {
//      Call modifier to check if the item is Sold
//      Call modifier to the invoker is the seller
        
//      Update State
        items[_sku].state = State.Shipped;
        emit Shipped(_sku);
    }
}