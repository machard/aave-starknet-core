%lang starknet

@contract_interface
namespace IACLManager:
    # added compared to original contract in solidity
    func has_role(role : felt, user : felt) -> (has_role : felt):
    end

    # added compared to original contract in solidity
    func grant_role(role : felt, user : felt):
    end

    # added compared to original contract in solidity
    func get_role_admin(role : felt) -> (admin : felt):
    end

    # added compared to original contract in solidity
    func revoke_role(role : felt, user : felt):
    end

    func get_addresses_provider() -> (provider_address : felt):
    end

    func get_pool_admin_role() -> (pool_admin_role : felt):
    end

    func get_emergency_admin_role() -> (emergency_admin_role : felt):
    end

    func get_flash_borrower_role() -> (flash_borrower_role : felt):
    end

    func get_bridge_role() -> (bridge_role : felt):
    end

    func get_asset_listing_admin_role() -> (asset_listing_admin_role : felt):
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
