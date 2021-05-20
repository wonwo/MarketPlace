UpdatePrice: event({_value: uint256})
UpdateStock: event({_value: uint256})
Buy: event({_price: uint256, _quantity: uint256,_value: uint256})

owner: public(address)#賣家
price: public(uint256)#商品價錢
stockQuantity: public(uint256)#商品庫存
total: public(uint256)#總金額花費

qualify: public(bool) #獲取訂購資格
buyer: public (address)#買家
orderStartTime:public (timestamp)#訂購開始時間
orderEndTime:public (timestamp)#訂購結束時間
totalOrd: public(uint256)#訂購總金額花費
quantityOrd: public(uint256)#訂購數


@public
@payable
def __init__(setPrice: uint256 , setStockQuantity: uint256):
    self.owner = msg.sender
    self.price = setPrice
    self.stockQuantity = setStockQuantity

@public
def updatePrice(newPrice: uint256):
    assert msg.sender == self.owner #能呼叫此函數的只有賣家
    self.price = newPrice #新價錢賦值給舊價錢
    
    log.UpdatePrice(self.price)
   
@public
def updateQuantity(newQuantity: uint256):
    assert msg.sender == self.owner #能呼叫此函數的只有賣家
    self.stockQuantity = newQuantity #新庫存量賦值給舊庫存量  
    
    log.UpdateStock(self.stockQuantity)
   
@public
@constant
def checkPrice() -> uint256:
    return self.price
    
@public
@constant
def checkQuantity() -> uint256:
    return self.stockQuantity
    
    
@public
@payable
def orderQualify(buyQuantity:uint256,Time:timedelta):
    assert not self.qualify #訂購資格還未被獲取
    assert buyQuantity < self.stockQuantity #想購買的數量必須小於庫存數量
    
    self.buyer = msg.sender
    self.orderStartTime = block.timestamp #訂購者與合約開始互動時間
    self.orderEndTime = self.orderStartTime + Time #Time為分期者輸入時間
    self.quantityOrd = buyQuantity #訂購數量
    self.stockQuantity -= self.quantityOrd #庫存數減去賣出的商品數
    self.totalOrd= self.price * self.quantityOrd
    self.qualify = True #訂購資格已被獲取
    
    send(self.owner,self.totalOrd/2) #需先付一半的錢當押金
    
@public
@payable
def orderBuy():
    assert self.qualify
    assert msg.sender == self.buyer #確認為獲取資格的買家
    assert msg.value > self.totalOrd/2
    assert block.timestamp < self.orderEndTime #訂購時間尚未結束
    
    send(self.owner, self.totalOrd/2) #付清另一半
    
    self.qualify = False #結束訂購資格
    
@public
def stopOrder():
    assert self.qualify
    assert msg.sender == self.buyer
    
    self.stockQuantity += self.quantityOrd #如果取消訂購庫存商品數量將還原
    
    send(self.buyer,self.totalOrd/2) #歸還買家押金
    
    self.qualify = False #結束訂購資格
    
    
@public
@payable
def buy(buyQuantity:uint256):
    assert buyQuantity < self.stockQuantity #想購買的數量必須小於庫存數量
    assert msg.value > self.price * buyQuantity #買家錢必須夠支付
    self.stockQuantity -= buyQuantity #庫存數減去賣出的商品數
    
    self.total = self.price * buyQuantity
    
    log.Buy(self.price, buyQuantity ,self.total)
    
    send(self.owner , self.total)
    
    