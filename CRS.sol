//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;



library SafeMath { 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }
    
    function multiply(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a * b;
      assert(c >= a);
      return c;
    }
}

contract DeCarentralized {

    string public constant name = "DeCarentralized";
    string public constant symbol = "CRS";
    uint8 public constant decimals = 3;  


    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    event Transfer(address indexed from, address indexed to, uint tokens);


    mapping(address => uint256) balances;

    mapping(address => mapping (address => uint256)) allowed;
    
    uint256 totalSupply_;

    using SafeMath for uint256;


   constructor(uint256 total) public payable {  
	    totalSupply_ = total;
	    balances[msg.sender] = totalSupply_;
	    chairPerson=msg.sender;
        membership[chairPerson] = 1;
        chairPerson_balance = msg.value;
    }  

    function totalSupply() public view returns (uint256) {
	    return totalSupply_;
    }
    
    function balanceOf(address tokenOwner) public view returns (uint) {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint numTokens) public returns (bool) {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint numTokens) public returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) public view returns (uint) {
        return allowed[owner][delegate];
    }

    function transferFrom(address owner, address buyer, uint numTokens) public returns (bool) {
        require(numTokens <= balances[owner]);    
        require(numTokens <= allowed[owner][msg.sender]);
    
        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(owner, buyer, numTokens);
        return true;
    }
    
    address chairPerson;
    uint chairPerson_balance;
    modifier onlyChairPerson {
        require(msg.sender == chairPerson);
        _;
    }
    
    mapping(address=>uint) membership;
    

    
    modifier onlyMember {
        require(membership[msg.sender] == 1);
        _;
    }
    

    struct carOwner {
        uint ownerWallet;
        uint carStatus;
        uint zipCode;
        string carType;
        uint carCost;
        uint numberofDays;
        string carCondition;
        
        
    }
    
    struct carBorrower {
        uint walletBalance;
        uint bookings; //# of bookings
        uint reqZipcode;
        uint reqDays;
    }
    
    
    mapping(address => carOwner) ownerDetails;
    mapping(address => carBorrower) borrowerDetails;
    
    function registerCarOwner(string memory _carType, uint _zipCode, uint _days, uint _carCost) payable public {
        
        address _carOwner=msg.sender;
        uint _ownerWallet=0;
        // uint _carCost=msg.value;
        membership[_carOwner]=1;
        ownerDetails[_carOwner].ownerWallet=_ownerWallet;
        ownerDetails[_carOwner].carStatus = 1;
        ownerDetails[_carOwner].carType = _carType;
        ownerDetails[_carOwner].carCost = _carCost; //pass 10^18 value
        ownerDetails[_carOwner].zipCode = _zipCode;
        ownerDetails[_carOwner].numberofDays = _days;
    }
     
     
    function registerUser(uint _reqZipcode, uint no_of_tokens) payable public {
        
        address _carBorrower=msg.sender;
        uint _walletBalance=no_of_tokens; //pass into 10^18
        membership[_carBorrower]=1;
        borrowerDetails[_carBorrower].walletBalance=_walletBalance;
        borrowerDetails[_carBorrower].bookings = 0;
        borrowerDetails[_carBorrower].reqZipcode = _reqZipcode;
        
    }
    
    function getRenterDetails(address payable _owner) onlyMember public view returns (uint,uint,string memory,uint,uint) {
        
        address _carOwner=_owner;
        // uint _carCost = msg.value;
        // membership[_carOwner]=1;
        uint car_cost = ownerDetails[_carOwner].carCost;
        uint car_status = ownerDetails[_carOwner].carStatus;
        string memory car_type = ownerDetails[_carOwner].carType;
        uint zip_code = ownerDetails[_carOwner].zipCode;
        uint number_of_days = ownerDetails[_carOwner].numberofDays;
        
        return (car_cost,car_status,car_type,zip_code,number_of_days);
    }
    
    function getBorrowerDetails(uint _reqDays) public {
        
        address _carBorrower=msg.sender;
        borrowerDetails[_carBorrower].reqDays=_reqDays;
        
    }
    
    function rentCar(address payable _owner, address payable _borrower) payable public returns(uint) {
        if (ownerDetails[_owner].carStatus==1 && borrowerDetails[_borrower].walletBalance > ownerDetails[_owner].carCost && borrowerDetails[_borrower].reqZipcode == ownerDetails[_owner].zipCode) {
            borrowerDetails[_borrower].bookings=borrowerDetails[_borrower].bookings+1;
            borrowerDetails[_borrower].walletBalance=borrowerDetails[_borrower].walletBalance-ownerDetails[_owner].carCost;
            ownerDetails[_owner].ownerWallet=ownerDetails[_owner].ownerWallet+ownerDetails[_owner].carCost;
            ownerDetails[_owner].carStatus=0;
            // _owner.transfer(ownerDetails[_owner].carCost);
            transfer(_owner,ownerDetails[_owner].carCost);
            return 1;
        }
        else{
            return 0;
        }
        
        
    }
    
    function settleDeposit(address payable _borrower, uint depositamt) payable public {

            address _owner = msg.sender;
            borrowerDetails[_borrower].walletBalance = borrowerDetails[_borrower].walletBalance + depositamt;
            ownerDetails[_owner].ownerWallet = ownerDetails[_owner].ownerWallet - depositamt;
            ownerDetails[_owner].carStatus = 1;
            transfer(_borrower, depositamt);
    }
    
    function giveBonus(address payable customer) public onlyChairPerson payable {
        
        uint number_of_bookings= borrowerDetails[customer].bookings;
        uint reward_amt = 1000;
        if(number_of_bookings > 3) {
            chairPerson_balance = chairPerson_balance - reward_amt;
            borrowerDetails[customer].walletBalance = borrowerDetails[customer].walletBalance + reward_amt;
            transfer(customer, reward_amt);
        }
    }
    
    function unregister(address payable user) public onlyChairPerson payable {
        if(membership[user] != 1){
            revert();
        }
        
        if(borrowerDetails[user].walletBalance >= 0) {
            chairPerson_balance = chairPerson_balance + borrowerDetails[user].walletBalance;
            borrowerDetails[user].walletBalance = 0;
        }
        // chairPerson_balance = chairPerson_balance + borrowerDetails[user].walletBalance;
        chairPerson_balance = chairPerson_balance + ownerDetails[user].ownerWallet;
        
        ownerDetails[user].ownerWallet = 0;
        
    }

}

