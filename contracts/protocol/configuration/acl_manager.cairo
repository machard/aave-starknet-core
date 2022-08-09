%lang starknet

from starkware.cairo.common.bool import FALSE
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256

from openzeppelin.access.accesscontrol import AccessControl

from contracts.protocol.configuration.acl_manager_library import ACLManager

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    provider : felt
):
    ACLManager.initializer(provider)
    return ()
end

@external
func has_role{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    role : felt, user : felt
) -> (has_role : felt):
    let (has_role) = AccessControl.has_role(role, user)
    return (has_role)
end

@external
func grant_role{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    role : felt, user : felt
):
    AccessControl.grant_role(role, user)
    return ()
end

@external
func get_role_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    role : felt
) -> (role_admin : felt):
    let (role_admin) = AccessControl.get_role_admin(role)
    return (role_admin)
end

@external
func revoke_role{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    role : felt, user : felt
):
    AccessControl.revoke_role(role, user)
    return ()
end

@external
func set_role_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    role : felt, admin_role : felt
):
    ACLManager.set_role_admin(role, admin_role)
    return ()
end

@external
func add_pool_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    admin_address : felt
):
    ACLManager.add_pool_admin(admin_address)
    return ()
end

@external
func remove_pool_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    admin_address : felt
):
    ACLManager.remove_pool_admin(admin_address)
    return ()
end
@view
func is_pool_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    admin_address : felt
) -> (has_role : felt):
    let (has_role) = ACLManager.is_pool_admin(admin_address)
    return (has_role)
end

@external
func add_emergency_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    admin_address : felt
):
    ACLManager.add_emergency_admin(admin_address)
    return ()
end

@external
func remove_emergency_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    admin_address : felt
):
    ACLManager.remove_emergency_admin(admin_address)
    return ()
end

@view
func is_emergency_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    admin_address : felt
) -> (has_role : felt):
    let (has_role) = ACLManager.is_emergency_admin(admin_address)
    return (has_role)
end

@external
func add_risk_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    admin_address : felt
):
    ACLManager.add_risk_admin(admin_address)
    return ()
end

@external
func remove_risk_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    admin_address : felt
):
    ACLManager.remove_risk_admin(admin_address)
    return ()
end

@view
func is_risk_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    admin_address : felt
) -> (has_role : felt):
    let (has_role) = ACLManager.is_risk_admin(admin_address)
    return (has_role)
end

@external
func add_flash_borrower{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    admin_address : felt
):
    ACLManager.add_flash_borrower(admin_address)
    return ()
end

@external
func remove_flash_borrower{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    admin_address : felt
):
    ACLManager.remove_flash_borrower(admin_address)
    return ()
end

@view
func is_flash_borrower{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    admin_address : felt
) -> (has_role : felt):
    let (has_role) = ACLManager.is_flash_borrower(admin_address)
    return (has_role)
end

@external
func add_bridge{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    admin_address : felt
):
    ACLManager.add_bridge(admin_address)
    return ()
end

@external
func remove_bridge{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    admin_address : felt
):
    ACLManager.remove_bridge(admin_address)
    return ()
end

@view
func is_bridge{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    admin_address : felt
) -> (has_role : felt):
    let (has_role) = ACLManager.is_bridge(admin_address)
    return (has_role)
end

@external
func add_asset_listing_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    admin_address : felt
):
    ACLManager.add_asset_listing_admin(admin_address)
    return ()
end

@external
func remove_asset_listing_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    admin_address : felt
):
    ACLManager.remove_asset_listing_admin(admin_address)
    return ()
end

@view
func is_asset_listing_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    admin_address : felt
) -> (has_role : felt):
    let (has_role) = ACLManager.is_asset_listing_admin(admin_address)
    return (has_role)
end

@view
func get_addresses_provider{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ) -> (provider_address : felt):
    let (provider_address) = ACLManager.get_addresses_provider()
    return (provider_address)
end

@view
func get_pool_admin_role{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    pool_admin_role : felt
):
    let (pool_admin_role) = ACLManager.get_pool_admin_role()
    return (pool_admin_role)
end

@view
func get_emergency_admin_role{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ) -> (emergency_admin_role : felt):
    let (emergency_admin_role) = ACLManager.get_emergency_admin_role()
    return (emergency_admin_role)
end

@view
func get_flash_borrower_role{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ) -> (flash_borrower_role : felt):
    let (flash_borrow_role) = ACLManager.get_flash_borrower_role()
    return (flash_borrow_role)
end

@view
func get_bridge_role{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    bridge_role : felt
):
    let (bridge_role) = ACLManager.get_bridge_role()
    return (bridge_role)
end

@view
func get_asset_listing_admin_role{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}() -> (asset_listing_admin_role : felt):
    let (asset_listing_admin_role) = ACLManager.get_asset_listing_admin_role()
    return (asset_listing_admin_role)
end
