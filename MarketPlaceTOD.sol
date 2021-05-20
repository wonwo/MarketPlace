pragma solidity ^0.5.14;
contract MarketPlaceTOD{
    address payable owner;
    uint public price;
    uint public stockQuantity;
    uint public total;
    
    address public buyer; //買家
    bool public qualify; //獲取訂購資格
    uint public orderStartTime;//訂購開始時間
    uint public orderEndTime;//訂購結束時間
    uint public totalOrd;//訂購總金額花費
    uint quantityOrd;//訂購數
    
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }
    
    event UpdatePrice(uint _price);
    event UpdateStock(uint _quantity);
    event Buy(uint _price, uint _quantity, uint _value);
    
    constructor(uint setPrice, uint setStockQuantity) public{
        owner = msg.sender;
        price = setPrice;
        stockQuantity = setStockQuantity;
    }
    
    //賣家更新價格
    function updatePrice(uint newPrice) public onlyOwner{
        price = newPrice;
        emit UpdatePrice(price);
    }
    
    //賣家更新庫存
    function updateQuantity(uint newQuantity) public onlyOwner{
        stockQuantity = newQuantity;
        emit UpdateStock(stockQuantity);
    }
    
    //確認商品價格
    function checkPrice() public view returns(uint){
        return price;
    }
    
    //確認商品庫存
    function checkQuantity() public view returns(uint){
        return stockQuantity;
    }
    //獲取訂購資格
    function orderQualify(uint buyQuantity,uint time) public payable{
        require (!qualify);
        require(stockQuantity > buyQuantity);
        
        buyer = msg.sender;
        orderStartTime = now;
        orderEndTime = orderStartTime + time; //結束時間為合約調用時間加上訂購者自訂時間
        quantityOrd = buyQuantity;
        stockQuantity -= quantityOrd;
        totalOrd = price * quantityOrd;
        qualify = true;
        
        owner.transfer(totalOrd/2); //一半的錢作為押金
    }
    //付清訂購金額
    function orderBuy() public payable{
        require(qualify);
        require(msg.sender == buyer);
        require(msg.value > totalOrd/2);
        require(now < orderStartTime);
        
        owner.transfer(totalOrd/2); //付清押金
        
        qualify = true;
        
    }
    //終止訂購
    function stopOrder() public payable{
        require(qualify);
        require(msg.sender == buyer);
        
        stockQuantity += quantityOrd; //商品數回到訂購之前
        
        msg.sender.transfer(totalOrd/2); //歸還押金
        
        qualify = true;
    }
    
    function buy(uint buyQuantity) public payable{
        require(msg.value > buyQuantity * price);
        require(stockQuantity > buyQuantity);
        
        total = price * buyQuantity;
        
        stockQuantity -= buyQuantity;
        
        emit Buy(price , buyQuantity , total);
        
        owner.transfer(total);
        
    }
}