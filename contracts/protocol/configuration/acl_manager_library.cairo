%lang starknet

from starkware.cairo.common.bool import FALSE, TRUE
from starkware.cairo.common.keccak import unsafe_keccak
from starkware.cairo.common.math import assert_not_zero
from starkware.cairo.common.cairo_builtins import HashBuiltin

from openzeppelin.access.accesscontrol import AccessControl
from openzeppelin.utils.constants import DEFAULT_ADMIN_ROLE

from contracts.interfaces.i_pool_addresses_provider import IPoolAddressesProvider
from contracts.protocol.configuration.pool_addresses_provider_library import PoolAddressesProvider
from contracts.interfaces.i_acl_manager import IACLManager

# TODO replace with unsafe_keccak
const POOL_ADMIN_ROLE = 1111  # unsafe_keccak('POOL_ADMIN', 256)
const EMERGENCY_ADMIN_ROLE = 2222  # unsafe_keccak('EMERGENCY_ADMIN', 256)
const RISK_ADMIN_ROLE = 3333  # unsafe_keccak('RISK_ADMIN', 256)
const FLASH_BORROWER_ROLE = 4444  # unsafe_keccak('FLASH_BORROWER', 256)
const BRIDGE_ROLE = 5555  # unsafe_keccak('BRIDGE', 256)
const ASSET_LISTING_ADMIN_ROLE = 6666  # unsafe_keccak('ASSET_LISTING_ADMIN',256)

# IPoolAddressesProvider public immutable ADDRESSES_PROVIDER;
@storage_var
func i_pool_addresses_provider() -> (addresses_provider : felt):
end

namespace ACLManager:
    func initializer{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        provider : felt
    ):
        i_pool_addresses_provider.write(provider)
        let (local_provider) = i_pool_addresses_provider.read()
        let (acl_admin) = IPoolAddressesProvider.get_ACL_admin(local_provider)
        assert_not_zero(acl_admin)
        AccessControl._grant_role(DEFAULT_ADMIN_ROLE, acl_admin)
        return ()
    end

    func set_role_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        role : felt, admin_role : felt
    ):
        AccessControl.assert_only_role(DEFAULT_ADMIN_ROLE)
        AccessControl._set_role_admin(role, admin_role)
        return ()
    end

    func add_pool_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        pool_admin_address : felt
    ):
        AccessControl.grant_role(POOL_ADMIN_ROLE, pool_admin_address)
        return ()
    end

    func remove_pool_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        pool_admin_address : felt
    ):
        AccessControl.revoke_role(POOL_ADMIN_ROLE, pool_admin_address)
        return ()
    end

    func is_pool_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        pool_admin_address : felt
    ) -> (has_role : felt):
        let (has_role) = AccessControl.has_role(POOL_ADMIN_ROLE, pool_admin_address)
        return (has_role=has_role)
    end

    func add_emergency_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        emergency_admin_address : felt
    ):
        AccessControl.grant_role(EMERGENCY_ADMIN_ROLE, emergency_admin_address)
        return ()
    end

    func remove_emergency_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        emergency_admin_address : felt
    ):
        AccessControl.revoke_role(EMERGENCY_ADMIN_ROLE, emergency_admin_address)
        return ()
    end

    func is_emergency_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        emergency_admin_address : felt
    ) -> (has_role : felt):
        let (has_role) = AccessControl.has_role(EMERGENCY_ADMIN_ROLE, emergency_admin_address)
        return (has_role=has_role)
    end

    func add_risk_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        risk_admin_address : felt
    ):
        AccessControl.grant_role(RISK_ADMIN_ROLE, risk_admin_address)
        return ()
    end

    func remove_risk_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        risk_admin_address : felt
    ):
        AccessControl.revoke_role(RISK_ADMIN_ROLE, risk_admin_address)
        return ()
    end

    func is_risk_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        risk_admin_address : felt
    ) -> (has_role : felt):
        let (has_role) = AccessControl.has_role(RISK_ADMIN_ROLE, risk_admin_address)
        return (has_role=has_role)
    end

    func add_flash_borrower{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        flash_borrower_address : felt
    ):
        AccessControl.grant_role(FLASH_BORROWER_ROLE, flash_borrower_address)
        return ()
    end

    func remove_flash_borrower{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        flash_borrower_address : felt
    ):
        AccessControl.revoke_role(FLASH_BORROWER_ROLE, flash_borrower_address)
        return ()
    end

    func is_flash_borrower{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        flash_borrower_address : felt
    ) -> (has_role : felt):
        let (has_role) = AccessControl.has_role(FLASH_BORROWER_ROLE, flash_borrower_address)
        return (has_role=has_role)
    end

    func add_bridge{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        bridge_address : felt
    ):
        AccessControl.grant_role(BRIDGE_ROLE, bridge_address)
        return ()
    end

    func remove_bridge{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        bridge_address : felt
    ):
        AccessControl.revoke_role(BRIDGE_ROLE, bridge_address)
        return ()
    end

    func is_bridge{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        bridge_address : felt
    ) -> (has_role : felt):
        let (has_role) = AccessControl.has_role(BRIDGE_ROLE, bridge_address)
        return (has_role=has_role)
    end

    func add_asset_listing_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        asset_listing_admin_address : felt
    ):
        AccessControl.grant_role(ASSET_LISTING_ADMIN_ROLE, asset_listing_admin_address)
        return ()
    end

    func remove_asset_listing_admin{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(asset_listing_admin_address : felt):
        AccessControl.revoke_role(ASSET_LISTING_ADMIN_ROLE, asset_listing_admin_address)
        return ()
    end

    func is_asset_listing_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        asset_listing_admin_address : felt
    ) -> (has_role : felt):
        let (has_role) = AccessControl.has_role(
            ASSET_LISTING_ADMIN_ROLE, asset_listing_admin_address
        )
        return (has_role=has_role)
    end

    func get_addresses_provider{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        ) -> (provider_address : felt):
        let (provider_address) = i_pool_addresses_provider.read()
        return (provider_address)
    end

    func get_pool_admin_role{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        ) -> (pool_admin_role : felt):
        return (POOL_ADMIN_ROLE)
    end

    func get_emergency_admin_role{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }() -> (emergency_admin_role : felt):
        return (EMERGENCY_ADMIN_ROLE)
    end

    func get_flash_borrower_role{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        ) -> (flash_borrower_role : felt):
        return (FLASH_BORROWER_ROLE)
    end

    func get_bridge_role{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        bridge_role : felt
    ):
        return (BRIDGE_ROLE)
    end

    func get_asset_listing_admin_role{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }() -> (asset_listing_admin_role : felt):
        return (ASSET_LISTING_ADMIN_ROLE)
    end
end
