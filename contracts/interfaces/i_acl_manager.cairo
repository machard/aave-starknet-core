%lang starknet

from starkware.cairo.common.uint256 import Uint256

from contracts.protocol.libraries.types.data_types import DataTypes

@contract_interface
namespace IACLManager:
    # added compared to original contract in solidity
    func acl_has_role(role : felt, user : felt) -> (has_role : felt):
    end

    # added compared to original contract in solidity
    func acl_grant_role(role : felt, user : felt):
    end

    # added compared to original contract in solidity
    func get_role_admin(role : felt) -> (admin_role : felt):
    end

    # added compared to original contract in solidity
    func acl_revoke_role(role : felt, user : felt):
    end

    func addresses_provider() -> (IPoolAddressesProvider : felt):
    end

    func pool_admin_role() -> (pool_admin_role : felt):
    end

    func emergency_admin_role() -> (emergency_admin_role : felt):
    end

    func flash_borrower_role() -> (flash_borrower_role : felt):
    end

    func bridge_role() -> (bridge_role : felt):
    end

    func asset_listing_admin_role() -> (asset_listing_admin_role : felt):
    end

    func set_role_admin(role : felt, admin_role : felt):
    end

    func add_pool_admin(admin_address : felt):
    end

    func remove_pool_admin(admin_address : felt):
    end

    func is_pool_admin(admin_address : felt) -> (bool : felt):
    end

    func add_emergency_admin(admin_address : felt):
    end

    func remove_emergency_admin(admin_address : felt):
    end

    func is_emergency_admin(admin_address : felt) -> (bool : felt):
    end

    func add_risk_admin(admin_address : felt):
    end

    func remove_risk_admin(admin_address : felt):
    end

    func is_risk_admin(admin_address : felt) -> (bool : felt):
    end

    func add_flash_borrower(borrower_address : felt):
    end

    func remove_flash_borrower(borrower_address : felt):
    end

    func is_flash_borrower(borrower_address : felt) -> (bool : felt):
    end

    func add_bridge(bridge_address : felt):
    end

    func remove_bridge(bridge_address : felt):
    end

    func is_bridge(bridge_address : felt) -> (bool : felt):
    end

    func add_asset_listing_admin(asset_Listing_admin_address : felt):
    end

    func remove_asset_listing_admin(asset_Listing_admin_address : felt):
    end

    func is_asset_listing_admin(asset_Listing_admin_address : felt) -> (bool : felt):
    end
end
