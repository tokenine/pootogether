import "./Interfaces.sol";
import "./UniformRandomNumber.sol";

contract Distributor {
	Uni public constant uniswap = Uni(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
	yVaultInterface public constant vault = yVaultInterface(0x5dbcF33D8c2E976c6b560249878e6F1491Bca25c);
	address public constant WETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
	
	function shitcoinMenu(uint entropy) public pure returns (address) { 
		uint idx = UniformRandomNumber.uniform(
			entropy,
			11 /* WARNING: ADJUST BASED ON TOKEN COUNT!! */
		);
		if (idx == 0) return address(0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984); // UNI 
		if (idx == 1) return address(0x62359Ed7505Efc61FF1D56fEF82158CcaffA23D7); // CORE
		if (idx == 2) return address(0x1494CA1F11D487c2bBe4543E90080AeBa4BA3C2b); // DPI
		if (idx == 3) return address(0x429881672B9AE42b8EbA0E26cD9C73711b891Ca5); // PICKLE
		if (idx == 4) return address(0xa0246c9032bC3A600820415aE600c6388619A14D); // FARM
		if (idx == 5) return address(0x514910771AF9Ca656af840dff83E8264EcF986CA); // LINK
		if (idx == 6) return address(0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9); // AAVE
		if (idx == 7) return address(0x1cEB5cB57C4D4E2b2433641b95Dd330A33185A44); // KP3R
		if (idx == 8) return address(0xBBbbCA6A901c926F240b89EacB641d8Aec7AEafD); // LRC
		if (idx == 9) return address(0x584bC13c7D411c00c01A62e8019472dE68768430); // HEGIC
		if (idx == 10) return address(0x69692D3345010a207b759a7D1af6fc7F38b35c5E); // CHADS
		// @TODO POO - 2x chance to get that
		return address(0);
	}
	
	function distribute(uint entropy, address winner) external {
		address[] memory path = new address[](3);
		path[0] = address(vault);
		path[1] = WETH;
		path[2] = shitcoinMenu(entropy);
		uniswap.swapExactTokensForTokens(vault.balanceOf(address(this)), uint(0), path, winner, block.timestamp);
	}
}
