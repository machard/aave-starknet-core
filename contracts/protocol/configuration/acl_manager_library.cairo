%lang starknet

from openzeppelin.access.accesscontrol import AccessControl, AccessControl_role_admin
from starkware.cairo.common.cairo_builtins import HashBuiltin

from contracts.interfaces.i_pool_addresses_provider import IPoolAddressesProvider
from contracts.protocol.configuration.pool_addresses_provider_library import PoolAddressesProvider

from contracts.interfaces.i_acl_manager import IACLManager

from starkware.cairo.common.keccak import unsafe_keccak
from starkware.cairo.common.math_cmp import is_not_zero
from openzeppelin.utils.constants import DEFAULT_ADMIN_ROLE

const POOL_ADMIN_ROLE = 1111  # unsafe_keccak('POOL_ADMIN', 256)
const EMERGENCY_ADMIN_ROLE = 2222  # unsafe_keccak('EMERGENCY_ADMIN', 256)
const RISK_ADMIN_ROLE = 3333  # unsafe_keccak('RISK_ADMIN', 256)
const FLASH_BORROWER_ROLE = 4444  # unsafe_keccak('FLASH_BORROWER', 256)
const BRIDGE_ROLE = 5555  # unsafe_keccak('BRIDGE', 256)
const ASSET_LISTING_ADMIN_ROLE = 6666  # unsafe_keccak('ASSET_LISTING_ADMIN',256)

# IPoolAddressesProvider public immutable ADDRESSES_PROVIDER;
@storage_var
func i_pool_addresses_provider() -> (provider_address : felt):
end

namespace ACLManager:
    func initializer{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        provider : felt
    ):
        i_pool_addresses_provider.write(provider)
        let (local_provider) = i_pool_addresses_provider.read()
        let (acl_admin) = IPoolAddressesProvider.get_ACL_admin(local_provider)
        let (check_address) = is_not_zero(acl_admin)
        assert check_address = 1
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
        admin_address : felt
    ):
        AccessControl.grant_role(POOL_ADMIN_ROLE, admin_address)
        return ()
    end

    func remove_pool_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        admin_address : felt
    ):
        AccessControl.revoke_role(POOL_ADMIN_ROLE, admin_address)
        return ()
    end

    func is_pool_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        admin_address : felt
    ) -> (has_role : felt):
        let (has_role) = AccessControl.has_role(POOL_ADMIN_ROLE, admin_address)
        return (has_role=has_role)
    end

    func add_emergency_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        admin_address : felt
    ):
        AccessControl.grant_role(EMERGENCY_ADMIN_ROLE, admin_address)
        return ()
    end

    func remove_emergency_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        admin_address : felt
    ):
        AccessControl.revoke_role(EMERGENCY_ADMIN_ROLE, admin_address)
        return ()
    end

    func is_emergency_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        admin_address : felt
    ) -> (has_role : felt):
        let (has_role) = AccessControl.has_role(EMERGENCY_ADMIN_ROLE, admin_address)
        return (has_role=has_role)
    end

    func add_risk_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        admin_address : felt
    ):
        AccessControl.grant_role(RISK_ADMIN_ROLE, admin_address)
        return ()
    end

    func remove_risk_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        admin_address : felt
    ):
        AccessControl.revoke_role(RISK_ADMIN_ROLE, admin_address)
        return ()
    end

    func is_risk_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        admin_address : felt
    ) -> (has_role : felt):
        let (has_role) = AccessControl.has_role(RISK_ADMIN_ROLE, admin_address)
        return (has_role=has_role)
    end

    func add_flash_borrower{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        admin_address : felt
    ):
        AccessControl.grant_role(FLASH_BORROWER_ROLE, admin_address)
        return ()
    end

    func remove_flash_borrower{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        admin_address : felt
    ):
        AccessControl.revoke_role(FLASH_BORROWER_ROLE, admin_address)
        return ()
    end

    func is_flash_borrower{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        admin_address : felt
    ) -> (has_role : felt):
        let (has_role) = AccessControl.has_role(FLASH_BORROWER_ROLE, admin_address)
        return (has_role=has_role)
    end

    func add_bridge{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        admin_address : felt
    ):
        AccessControl.grant_role(BRIDGE_ROLE, admin_address)
        return ()
    end

    func remove_bridge{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        admin_address : felt
    ):
        AccessControl.revoke_role(BRIDGE_ROLE, admin_address)
        return ()
    end

    func is_bridge{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        admin_address : felt
    ) -> (has_role : felt):
        let (has_role) = AccessControl.has_role(BRIDGE_ROLE, admin_address)
        return (has_role=has_role)
    end

    func add_asset_listing_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        admin_address : felt
    ):
        AccessControl.grant_role(ASSET_LISTING_ADMIN_ROLE, admin_address)
        return ()
    end

    func remove_asset_listing_admin{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(admin_address : felt):
        AccessControl.revoke_role(ASSET_LISTING_ADMIN_ROLE, admin_address)
        return ()
    end

    func is_asset_listing_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        admin_address : felt
    ) -> (has_role : felt):
        let (has_role) = AccessControl.has_role(ASSET_LISTING_ADMIN_ROLE, admin_address)
        return (has_role=has_role)
    end
end
