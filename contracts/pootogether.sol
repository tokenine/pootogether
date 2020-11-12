import "./SortitionSumTreeFactory.sol";
import "./UniformRandomNumber.sol";
import "./SafeMath.sol";
import "./Interfaces.sol";

interface DistribInterface {
	function distribute(uint entropy, address winner) external;
}

contract PooTogether {
	using SafeMath for uint;

	// Terminology
	// base = the base token of the vault (vault.token)
	// share = the share tokeni, i.e. the vault token itself
	// example: base is yCrv, share is yUSD

	uint totalBase;
	mapping (address => uint) perUserBase;
	yVaultInterface vault;
	DistribInterface distributor;

	constructor (yVaultInterface _vault, DistribInterface _distrib) public {
		vault = _vault;
		distributor = _distrib;
	}

	// @TODO you'd have to support depositing yUSD too

	function deposit(uint amountBase) external {
		IERC20(vault.token()).transferFrom(msg.sender, address(this), amountBase);
		vault.deposit(amountBase);
		perUserBase[msg.sender] = perUserBase[msg.sender].add(amountBase);
		totalBase = totalBase.add(amountBase);
		// @TODO emit
	}

	function depositShares(uint amountShares) external {
		vault.transferFrom(msg.sender, address(this), amountShares);
		uint amountBase = toBase(amountShares);
		perUserBase[msg.sender] = perUserBase[msg.sender].add(amountBase);
		totalBase = totalBase.add(amountBase);
	}

	// @TODO explain why we have two deposits and two withdrawals
	function withdraw(uint amountBase) external {
		require(perUserBase[msg.sender] > amountBase, 'insufficient funds');
		// XXX: if there is a rounding error here and we don't receive amountBase?
		vault.withdraw(toShares(amountBase));
		IERC20(vault.token()).transfer(msg.sender, amountBase);
		perUserBase[msg.sender] = perUserBase[msg.sender].sub(amountBase);
		totalBase = totalBase.sub(amountBase);
	}

	function withdrawShares(uint amountShares) external {
		uint amountBase = toBase(amountShares);
		require(perUserBase[msg.sender] > amountBase, 'insufficient funds');
		vault.transfer(msg.sender, amountShares);
		perUserBase[msg.sender] = perUserBase[msg.sender].sub(amountBase);
		totalBase = totalBase.sub(amountBase);
	}

	function skimmableBase() external view returns (uint) {
		uint ourWorthInBase = toBase(vault.balanceOf(address(this)));
		uint skimmable = ourWorthInBase.sub(totalBase);
		return skimmable;
	}

	function draw() external {
		//require(/* no recent draw */)
		uint skimmableShares = toShares(this.skimmableBase());

		// XXX if the distributor wants to receive the base then we withdraw the shares and transfer skimmable
		vault.transfer(address(distributor), skimmableShares);

		address winner = winner(entropy());
		distributor.distribute(entropy(), winner);
		
		// @TODO 
		//poo.mint(winner, pooPerDraw)
	}

	function winner(uint entropy) public view returns (address) {
		// @TODO replace this 
		return address(0x0000000000000000000000000000000000000000);
	}

	function entropy() internal view returns (uint256) {
		// @TODO secret
		return uint256(blockhash(block.number - 1) /*^ secret*/);
	}


	// the share value is vault.getPricePerFullShare() / 1e18
	// multiplying it is .mul(vault.getPricePerFullShare()).div(1e18)
	// and the opposite is .mul(1e18).div(vault.getPricePerFullShare())

	// @TODO check if all base -> shares is dividing by shares and vice versa
	function toShares(uint256 tokens) internal view returns (uint256) {
		return vault.totalSupply().mul(tokens).div(vault.balance());
	}

	function toBase(uint256 shares) internal view returns (uint256) {
		uint256 ts = vault.totalSupply();
		if (ts == 0 || shares == 0) {
			return 0;
		}
		return (vault.balance().mul(shares)).div(ts);
	}
// yvaultinterface https://github.com/pooltogether/pooltogether-pool-contracts/blob/master/contracts/prize-pool/yearn/yVaultPrizePool.sol
// admin only
}
