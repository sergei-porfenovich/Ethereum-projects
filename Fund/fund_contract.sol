pragma solidity ^0.4.20;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) constant returns (uint256);
    function transfer(address to, uint256 value) returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) constant returns (uint256);
    function transferFrom(address from, address to, uint256 value) returns (bool);
    function approve(address spender, uint256 value) returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal constant returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {

    using SafeMath for uint256;

    mapping(address => uint256) balances;

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) returns (bool) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

    mapping (address => mapping (address => uint256)) allowed;

    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amout of tokens to be transfered
     */
    function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
        var _allowance = allowed[_from][msg.sender];

        // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
        // require (_value <= _allowance);

        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) returns (bool) {

        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender, 0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifing the amount of tokens still available for the spender.
     */
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {

    address public owner;

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) onlyOwner {
        require(newOwner != address(0));
        owner = newOwner;
    }

}

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

contract MintableToken is StandardToken, Ownable {

    event Mint(address indexed to, uint256 amount);

    event MintFinished();

    bool public mintingFinished = false;

    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    /**
     * @dev Function to mint tokens
     * @param _to The address that will recieve the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint256 _amount) onlyOwner canMint returns (bool) {
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Mint(_to, _amount);
        return true;
    }

    /**
     * @dev Function to stop minting new tokens.
     * @return True if the operation was successful.
     */
    function finishMinting() onlyOwner returns (bool) {
        mintingFinished = true;
        MintFinished();
        return true;
    }

}

contract BurnableToken is MintableToken {

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(address _address, uint _value) onlyOwner {
        require(_value > 0);
        address burner = _address;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
    }

    event Burn(address indexed burner, uint indexed value);

}

contract SimpleTokenCoin is BurnableToken {

    string public name;

    string public symbol;

    uint32 public decimals;
    
    uint public coin;
    
    function SimpleTokenCoin(string _name, string _symbol, uint32 _decimals){
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        coin = 10 ** uint256(decimals);
    }

}


contract Crowdsale is Ownable {

    using SafeMath for uint;

    SimpleTokenCoin public token;

    uint public rate;
    
    string public namefund;
    
    uint public start;
    
    uint public minDeposit;
    
    uint256 public maxDeposit;
    
    uint public hardcap;
    
    uint public softcap;
    
    bool collected;

    mapping(address => uint) public balances;
    
    mapping(address => bool) public whiteList;
    
    address [] public investors;
    
    function Crowdsale(
        string _tokenName, 
        string _symbol, 
        uint32 _decimals, 
        string _namefund, 
        uint _rate, 
        uint _start, 
        uint _minDeposit, 
        uint _hardcap, 
        uint _softcap,
        uint _maxDeposit) {
        token = new SimpleTokenCoin(_tokenName, _symbol, _decimals);
        namefund = _namefund;
        rate = _rate;
        start = _start;
        minDeposit = _minDeposit;
        hardcap = _hardcap.mul(1 ether);
        softcap = _softcap.mul(1 ether);
        maxDeposit = _maxDeposit;
        
    }
    
    modifier saleIsOn() {
        require(now > start);
        _;
    }
    
    modifier collectedAmount{
        require(!collected);
        _;
    }
    
    modifier checkInvestor{
        require(getWhiteList(msg.sender));
        _;
    }
    
    modifier checkDeposit{
        require(msg.value >= minDeposit && msg.value <= maxDeposit);
        _;
    }
    
    function getListInvestor(uint _index) view returns(address){
        return investors[_index];
    }
    
    function getlengthListInvestors() view returns(uint){
        return investors.length;
    }
    
    function setWhiteList(address _address, bool _bool) onlyOwner{
        require(_address!=0x0);
        whiteList[_address] = _bool;
    } 
    
    function getWhiteList(address _address) view returns(bool){
        require(_address!=0x0);
        return whiteList[_address];
    }

    function refund(uint _value) {
        require(balances[msg.sender]>=_value);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        uint tokens = _value.mul(token.coin()).div(rate);
        token.burn(msg.sender, tokens);
        msg.sender.transfer(_value);
    }
    
    function finishCrowdsale() onlyOwner{
        if(this.balance>=softcap){
            owner.transfer(this.balance);
            collected = true;
        }
    }
    
    function createTokens() checkInvestor collectedAmount checkDeposit payable {
        uint tokens;
        if(msg.value.add(hardcap) > this.balance){
            uint value = hardcap.sub(this.balance);
            uint rest = msg.value.sub(value);
            tokens = value.mul(token.coin()).div(rate);
            token.mint(msg.sender, tokens);
            balances[msg.sender] = balances[msg.sender].add(value); 
            investors.push(msg.sender);
            msg.sender.transfer(rest);
            owner.transfer(this.balance);
            collected = true;
        } else{
            tokens = msg.value.mul(token.coin()).div(rate);
            token.mint(msg.sender, tokens);
            balances[msg.sender] = balances[msg.sender].add(msg.value); 
            investors.push(msg.sender);
        }
    }

    function() external payable {
        createTokens();
    }

}