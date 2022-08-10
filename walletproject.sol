pragma solidity 0.8.9;

contract WalletProject{
    
    mapping(address => uint) balance;
    mapping(address => mapping(uint => bool)) approvals;
    uint transferId = 0;
    uint approvalLimit;
    
    struct Transfer {
        
        address sender;
        address payable receiver;
        uint amount;
        uint approvals;
        uint id;
    }
    
    Transfer[] transferRequests;
    address[] owners;
    
    constructor() {
        
        owners.push(msg.sender);
        approvalLimit = owners.length - 1;
    }
    
    
    //modifier for admins
    modifier onlyOwner{
        
        bool hasBeenFound = false;
        for (uint i = 0; i < owners.length; i++) {
             
             if(owners[i] == msg.sender) {
                 
                 hasBeenFound = true;
                 break;
             }
        }
        require(hasBeenFound, "not owner");
        _;
    }
    
    //Add an Admin to the owner Array
    function addAdmin(address _owner)public onlyOwner{
        
        for(uint i = 0; i < owners.length; i++) {
            
            if(owners[i] == _owner) {
                
                revert("cannot add duplicate owners");
            } 
        }
        owners.push(_owner);
        approvalLimit = owners.length - 1;
    }
    
   
    //Here are the functions for the regular Enduser.
    function deposit() public payable returns (uint){
        
        require(msg.value != 0, "cannot deposit nothing");
        balance[msg.sender] += msg.value;
        return balance[msg.sender];
    }
   
    function withdraw(uint amount) public returns (uint){
        
        require(balance[msg.sender] >= amount, "Error! Not enough ETH!");
        balance[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
      
        return balance[msg.sender];
    }
    //Transfer request is created.
    function createTransferRequest(address payable _receiver, uint _amount) public onlyOwner{
       
        require(balance[msg.sender] >= _amount, "Balance not sufficient");
        require(msg.sender != _receiver, "Don't transfer money to yourself");
        
        Transfer memory transferInstance = Transfer(msg.sender, _receiver, _amount, 0, transferId);
       
        transferRequests.push(transferInstance);
        transferId ++;
    }
    //Approval of Transfer
    function approveTransfer(uint id) public onlyOwner returns(string memory){
       
        require(approvals[msg.sender][transferId] == false, "Transfer already authorized!");
        approvals[msg.sender][transferId] == true;
        transferRequests[id].approvals ++;
       
       if (transferRequests[id].approvals == approvalLimit){
         
            balance[msg.sender] -= transferRequests[id].amount;
            balance[transferRequests[id].receiver] += transferRequests[id].amount;
            transferRequests[id].receiver.transfer(transferRequests[id].amount);
    
            return("Transaction approved!");
        }
        else{
            return("Not approved!");
        }
    }
    
    function getBalance() public view returns (uint) {
        
        return balance[msg.sender];
    }
    
}
