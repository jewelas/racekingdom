/**
 
*/

// SPDX-License-Identifier: No

pragma solidity ^0.8.15;

//--- Context ---//
abstract contract Context {
    constructor() {}

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

//--- Ownable ---//
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IFactoryV2 {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address lpPair,
        uint256
    );

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address lpPair);

    function createPair(address tokenA, address tokenB)
        external
        returns (address lpPair);
}

interface IV2Pair {
    function factory() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function sync() external;
}

interface IRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IRouter02 is IRouter01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

//--- Interface for ERC20 ---//
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


contract BBB is Context, Ownable, IERC20 {
    function totalSupply() external view override returns (uint256) {
        if (_totalSupply == 0) {
            revert();
        }
        return _totalSupply - balanceOf(address(DEAD));
    }

    function decimals() external pure override returns (uint8) {
        if (_totalSupply == 0) {
            revert();
        }
        return _decimals;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function getOwner() external view override returns (address) {
        return owner();
    }

    function allowance(address holder, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[holder][spender];
    }

    function balanceOf(address account) public view override returns (uint256) {
        return balance[account];
    }

    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _exFees;
    mapping(address => bool) private isLpPair;
    mapping(address => uint256) private balance;
    uint8 private constant _decimals = 18;

    uint256 public constant _totalSupply = 1_000_000_000 * 10**_decimals;
    uint256 public constant feeDenominator = 100;
    uint256 public buyfee = 30;
    uint256 public sellfee = 30;
    uint256 public transferfee = 0;
    bool private swapEnabled = false;
    address payable private marketingAddress =
        payable(0x48B35E4E3e2235ba9Ea42A9374B125b96B3EF5a6);
    uint256 private maxWalletLimit = (_totalSupply * 2) / 100;
    uint256 private constant swapThreshold = (_totalSupply * 5) / 1_000_000;
    uint256 private constant maxThreshold = (_totalSupply * 2) / 100;

    IRouter02 public swapRouter;
    string private constant _name = "BBB";
    string private constant _symbol = "BBB";
    address public constant DEAD = 0x0000000000000000000000000000000000000000;
    address public lpPair;
    bool public tradingEnabled = false;
    bool private inSwap;

    modifier isSwapLocked() {
        inSwap = true;
        _;
        inSwap = false;
    }

    event _allowTrading();

    constructor() {
        _exFees[msg.sender] = true;
        _exFees[address(this)] = true;
        _exFees[marketingAddress] = true;

        swapRouter = IRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        balance[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function createPair() external onlyOwner {
        _approve(address(this), address(swapRouter), type(uint256).max);

        lpPair = IFactoryV2(swapRouter.factory()).createPair(
            swapRouter.WETH(),
            address(this)
        );
        isLpPair[lpPair] = true;

        swapRouter.addLiquidityETH{value: address(this).balance}(
            address(this),
            balance[address(this)],
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(lpPair).approve(
            address(swapRouter),
            type(uint256).max
        );
    }

    receive() external payable {}

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount)
        external
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(
        address sender,
        address spender,
        uint256 amount
    ) internal {
        require(sender != address(0), "ERC20: Zero Address");
        require(spender != address(0), "ERC20: Zero Address");

        _allowances[sender][spender] = amount;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] -= amount;
        }

        return _transfer(sender, recipient, amount);
    }

    function isNoFeeWallet(address account) external view returns (bool) {
        return _exFees[account];
    }

    function setNoFeeWallet(address account, bool enabled) public onlyOwner {
        _exFees[account] = enabled;
    }

    function is_buy(address ins, address out) internal view returns (bool) {
        bool _is_buy = !_exFees[out] && isLpPair[ins];
        return _is_buy;
    }

    function is_sell(address ins, address out) internal view returns (bool) {
        bool _is_sell = isLpPair[out] && !_exFees[ins];
        return _is_sell;
    }

    function isSwapAvailable(
        address ins,
        address out,
        uint256 amount
    ) internal view returns (bool) {
        return
            swapEnabled &&
            !_exFees[ins] &&
            !_exFees[out] &&
            amount >= swapThreshold;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        bool takeFee = true;
        require(to != address(0), "invalid receiptient address");
        require(from != address(0), "invalid sender address");
        require(
            amount > 0,
            "Insufficient error. the amount must be above than zero"
        );

        if (!_exFees[from] && !_exFees[to]) {
            require(tradingEnabled, "Trading is not allowed");
        }

        if (
            !_exFees[from] &&
            !_exFees[to] &&
            !isLpPair[to] &&
            to != address(DEAD)
        ) {
            require(
                balance[to] + amount <= maxWalletLimit,
                "Exceeds maximum wallet amount."
            );
        }

        if (!inSwap &&
               isLpPair[to] &&
                tradingEnabled &&
                amount >= swapThreshold) {
            uint256 contractTokenBalance = balanceOf(address(this));
            if (contractTokenBalance >= swapThreshold) {
                if (contractTokenBalance >= maxThreshold)
                    contractTokenBalance = maxThreshold;
                internalSwap(contractTokenBalance);
            }

            marketingAddress.transfer(address(this).balance);
        }

        if ((_exFees[from] || _exFees[to])) {
            takeFee = false;
        }

        uint256 amountAfterFee = takeTax(from, is_buy(from, to), is_sell(from, to), amount);
        balance[to] += amountAfterFee;
        emit Transfer(from, to, amountAfterFee);

        return true;
    }

    function takeTax(
        address from,
        bool isbuy,
        bool issell,
        uint256 amount
    ) internal returns (uint256) {
        uint256 fee = 0;

        if (isbuy) fee = buyfee;
        else if (issell) fee = sellfee;
        else fee = transferfee;
        uint256 feeAmount = (amount * fee) / feeDenominator;
        if (feeAmount > 0) {
            balance[address(this)] += feeAmount;
            emit Transfer(from, address(this), feeAmount);
        }
        balance[from] -= amount;
        return amount - feeAmount;
    }

    function internalSwap(uint256 contractTokenBalance) internal isSwapLocked {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = swapRouter.WETH();

        if (
            _allowances[address(this)][address(swapRouter)] != type(uint256).max
        ) {
            _allowances[address(this)][address(swapRouter)] = type(uint256).max;
        }

        try
            swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
                contractTokenBalance,
                0,
                path,
                address(this),
                block.timestamp
            )
        {} catch {
            return;
        }

        payable(marketingAddress).transfer(address(this).balance);
    }

    function setFees(uint256 _fee) external onlyOwner {
        buyfee = _fee;
        sellfee = _fee;

        require(_fee < 6);
    }

    function removeLimits() external onlyOwner {
        maxWalletLimit = _totalSupply;
    }

    function allowTrading() external onlyOwner {
        require(!tradingEnabled, "Trading is already allowed");
        tradingEnabled = true;
        swapEnabled = true;
    }
}