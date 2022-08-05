%lang starknet

from starkware.cairo.common.bool import FALSE, TRUE
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256

from contracts.interfaces.i_a_token import IAToken
from contracts.interfaces.i_pool_addresses_provider import IPoolAddressesProvider
from contracts.protocol.configuration.pool_addresses_provider_library import PoolAddressesProvider
from contracts.interfaces.i_acl_manager import IACLManager

from contracts.protocol.libraries.math.wad_ray_math import RAY
from contracts.protocol.configuration.acl_manager_library import (
    ACLManager,
    POOL_ADMIN_ROLE,
    EMERGENCY_ADMIN_ROLE,
    FLASH_BORROWER_ROLE,
    RISK_ADMIN_ROLE,
    BRIDGE_ROLE,
    ASSET_LISTING_ADMIN_ROLE,
)
from openzeppelin.utils.constants import DEFAULT_ADMIN_ROLE
from openzeppelin.access.accesscontrol import AccessControl

const FLASH_BORROW_ADMIN_ADDRESS = 1111
const FLASH_BORROWER_ADDRESS = 4444
const POOL_ADMIN_ADDRESS = 5555
const PRANK_ADMIN_ADDRESS = 2222
const EMERGENCY_ADMIN_ADDRESS = 6666
const PRANK_USER_1 = 3333
const RISK_ADMIN_ADDRESS = 7777
const BRIDGE_ADDRESS = 8888
const ASSET_LISTING_ADMIN_ADDRESS = 9999

const FLASH_BORROW_ADMIN_ROLE = 11
# const FLASH_BORROWER_ROLE = 33
const PRANK_ROLE_2 = 22
const PRANK_ADMIN_ROLE = 99

namespace TestACLManager:
    func test_default_admin_role{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        ):
        alloc_locals
        local acl
        local pool_addresses_provider
        %{
            ids.acl = context.acl
            ids.pool_addresses_provider = context.pool_addresses_provider
        %}
        %{ print("acl  = " + str(ids.acl)) %}
        %{ print("pool_addresses_provider  = " + str(ids.pool_addresses_provider)) %}

        let (has_role_deployer) = IACLManager.acl_has_role(
            acl, DEFAULT_ADMIN_ROLE, PRANK_ADMIN_ADDRESS
        )
        assert has_role_deployer = 1

        let (has_role_user_1) = AccessControl.has_role(DEFAULT_ADMIN_ROLE, PRANK_USER_1)
        assert has_role_user_1 = FALSE
        return ()
    end

    func test_grant_flash_borrow_admin_role{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        alloc_locals
        local acl
        local pool_addresses_provider
        %{
            ids.acl = context.acl
            ids.pool_addresses_provider = context.pool_addresses_provider
        %}

        let (has_flash_borrow_admin_role) = IACLManager.acl_has_role(
            acl, FLASH_BORROW_ADMIN_ROLE, FLASH_BORROW_ADMIN_ADDRESS
        )
        assert has_flash_borrow_admin_role = FALSE
        %{ stop_prank = start_prank(ids.PRANK_ADMIN_ADDRESS, target_contract_address = ids.acl) %}
        IACLManager.acl_grant_role(acl, FLASH_BORROW_ADMIN_ROLE, FLASH_BORROW_ADMIN_ADDRESS)
        %{ stop_prank() %}
        let (has_flash_borrow_admin_role_after) = IACLManager.acl_has_role(
            acl, FLASH_BORROW_ADMIN_ROLE, FLASH_BORROW_ADMIN_ADDRESS
        )
        assert has_flash_borrow_admin_role_after = TRUE

        return ()
    end

    func test_grant_flash_borrow_admin_role_2{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        alloc_locals
        local acl
        local pool_addresses_provider
        %{
            ids.acl = context.acl
            ids.pool_addresses_provider = context.pool_addresses_provider
        %}

        %{ stop_prank = start_prank(ids.PRANK_ADMIN_ADDRESS, target_contract_address = ids.acl) %}
        IACLManager.acl_grant_role(acl, FLASH_BORROW_ADMIN_ROLE, FLASH_BORROW_ADMIN_ADDRESS)
        %{ stop_prank() %}

        let (role) = IACLManager.is_flash_borrower(acl, FLASH_BORROWER_ADDRESS)
        assert role = FALSE

        let (role_admin) = IACLManager.acl_has_role(
            acl, FLASH_BORROW_ADMIN_ROLE, FLASH_BORROW_ADMIN_ADDRESS
        )
        assert role_admin = TRUE

        %{ expect_revert(error_message="AccessControl: caller is missing role "+str(ids.DEFAULT_ADMIN_ROLE)) %}
        %{ stop_prank_call_borrower = start_prank(ids.FLASH_BORROW_ADMIN_ADDRESS, target_contract_address = ids.acl) %}
        IACLManager.add_flash_borrower(acl, FLASH_BORROWER_ADDRESS)
        %{ stop_prank_call_borrower() %}

        let (role_after) = IACLManager.is_flash_borrower(acl, FLASH_BORROWER_ADDRESS)
        assert role_after = FALSE

        let (role_admin_after) = IACLManager.acl_has_role(
            acl, FLASH_BORROW_ADMIN_ROLE, FLASH_BORROW_ADMIN_ADDRESS
        )
        assert role_admin_after = TRUE
        return ()
    end

    func test_grant_flash_borrow_admin_role_3{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        alloc_locals
        # ## init ###
        local acl
        local pool_addresses_provider
        %{
            ids.acl = context.acl
            ids.pool_addresses_provider = context.pool_addresses_provider
        %}
        %{ stop_prank = start_prank(ids.PRANK_ADMIN_ADDRESS, target_contract_address = ids.acl) %}
        IACLManager.acl_grant_role(acl, FLASH_BORROW_ADMIN_ROLE, FLASH_BORROW_ADMIN_ADDRESS)
        # ## end of init ###

        # check who's the admin role for flash_borrow_role
        let (admin_role_fbr) = IACLManager.get_role_admin(acl, FLASH_BORROWER_ROLE)
        %{ expect_revert() %}
        assert admin_role_fbr = FLASH_BORROW_ADMIN_ROLE

        # set FLASH_BORROW_ADMIN_ROLE as admin for FLASH_BORROWER_ROLE. To do that, we need to prank call with admin_address
        IACLManager.set_role_admin(acl, FLASH_BORROWER_ROLE, FLASH_BORROW_ADMIN_ROLE)
        let (admin_role_fbr_after) = IACLManager.get_role_admin(acl, FLASH_BORROWER_ROLE)
        assert admin_role_fbr_after = FLASH_BORROW_ADMIN_ROLE

        %{ stop_prank() %}

        return ()
    end

    func test_grant_flash_borrow_admin_role_4{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        alloc_locals
        # ## init ###
        local acl
        local pool_addresses_provider
        %{
            ids.acl = context.acl
            ids.pool_addresses_provider = context.pool_addresses_provider
        %}
        %{ stop_prank = start_prank(ids.PRANK_ADMIN_ADDRESS, target_contract_address = ids.acl) %}
        IACLManager.acl_grant_role(acl, FLASH_BORROW_ADMIN_ROLE, FLASH_BORROW_ADMIN_ADDRESS)

        # ## end of init ###
        # set FLASH_BORROW_ADMIN_ROLE as admin for FLASH_BORROWER_ROLE.
        IACLManager.set_role_admin(acl, FLASH_BORROWER_ROLE, FLASH_BORROW_ADMIN_ROLE)
        %{ stop_prank() %}

        let (is_flash_borrower_before) = IACLManager.is_flash_borrower(acl, FLASH_BORROWER_ADDRESS)
        assert is_flash_borrower_before = FALSE
        %{ stop_prank_1 = start_prank(ids.FLASH_BORROW_ADMIN_ADDRESS, target_contract_address = ids.acl) %}
        IACLManager.add_flash_borrower(acl, FLASH_BORROWER_ADDRESS)
        %{ stop_prank_1() %}
        let (is_flash_borrower_after) = IACLManager.is_flash_borrower(acl, FLASH_BORROWER_ADDRESS)
        assert is_flash_borrower_after = TRUE

        return ()
    end

    func test_grant_flash_borrow_admin_role_5{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        alloc_locals
        # ## init ###
        local acl
        local pool_addresses_provider
        %{
            ids.acl = context.acl
            ids.pool_addresses_provider = context.pool_addresses_provider
        %}
        %{ stop_prank = start_prank(ids.PRANK_ADMIN_ADDRESS, target_contract_address = ids.acl) %}
        IACLManager.acl_grant_role(acl, FLASH_BORROW_ADMIN_ROLE, FLASH_BORROW_ADMIN_ADDRESS)
        # ## end of init ###
        # set FLASH_BORROW_ADMIN_ROLE as admin for FLASH_BORROWER_ROLE.
        IACLManager.set_role_admin(acl, FLASH_BORROWER_ROLE, FLASH_BORROW_ADMIN_ROLE)
        %{ stop_prank() %}
        %{ stop_prank_1 = start_prank(ids.FLASH_BORROW_ADMIN_ADDRESS, target_contract_address = ids.acl) %}
        IACLManager.add_flash_borrower(acl, FLASH_BORROWER_ADDRESS)
        %{ stop_prank_1() %}

        let (role_admin) = IACLManager.acl_has_role(
            acl, FLASH_BORROW_ADMIN_ROLE, FLASH_BORROW_ADMIN_ADDRESS
        )
        assert role_admin = TRUE
        let (is_flash_borrower_before) = IACLManager.is_flash_borrower(acl, FLASH_BORROWER_ADDRESS)
        assert is_flash_borrower_before = TRUE

        %{ stop_prank = start_prank(ids.PRANK_ADMIN_ADDRESS, target_contract_address = ids.acl) %}
        %{ expect_revert() %}
        IACLManager.remove_flash_borrower(acl, FLASH_BORROWER_ADDRESS)
        %{ stop_prank() %}

        let (is_flash_borrower_after) = IACLManager.is_flash_borrower(acl, FLASH_BORROWER_ADDRESS)
        assert is_flash_borrower_after = TRUE

        return ()
    end

    func test_grant_pool_admin_role{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        alloc_locals
        # ## init ###
        local acl
        local pool_addresses_provider
        %{
            ids.acl = context.acl
            ids.pool_addresses_provider = context.pool_addresses_provider
        %}
        %{ stop_prank = start_prank(ids.PRANK_ADMIN_ADDRESS, target_contract_address = ids.acl) %}
        let (pool_admin_before) = IACLManager.is_pool_admin(acl, POOL_ADMIN_ADDRESS)
        assert pool_admin_before = FALSE
        IACLManager.add_pool_admin(acl, POOL_ADMIN_ADDRESS)
        let (pool_admin_after) = IACLManager.is_pool_admin(acl, POOL_ADMIN_ADDRESS)
        assert pool_admin_after = TRUE
        %{ stop_prank() %}
        return ()
    end

    func test_grant_emergency_admin_role{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        alloc_locals
        # ## init ###
        local acl
        local pool_addresses_provider
        %{
            ids.acl = context.acl
            ids.pool_addresses_provider = context.pool_addresses_provider
        %}
        %{ stop_prank = start_prank(ids.PRANK_ADMIN_ADDRESS, target_contract_address = ids.acl) %}
        let (pool_admin_before) = IACLManager.is_emergency_admin(acl, EMERGENCY_ADMIN_ADDRESS)
        assert pool_admin_before = FALSE
        IACLManager.add_emergency_admin(acl, EMERGENCY_ADMIN_ADDRESS)
        let (pool_admin_after) = IACLManager.is_emergency_admin(acl, EMERGENCY_ADMIN_ADDRESS)
        assert pool_admin_after = TRUE
        %{ stop_prank() %}
        return ()
    end

    func test_grant_risk_admin_role{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        alloc_locals
        # ## init ###
        local acl
        local pool_addresses_provider
        %{
            ids.acl = context.acl
            ids.pool_addresses_provider = context.pool_addresses_provider
        %}
        %{ stop_prank = start_prank(ids.PRANK_ADMIN_ADDRESS, target_contract_address = ids.acl) %}
        let (risk_admin_before) = IACLManager.is_risk_admin(acl, RISK_ADMIN_ADDRESS)
        assert risk_admin_before = FALSE
        IACLManager.add_risk_admin(acl, RISK_ADMIN_ADDRESS)
        let (risk_admin_after) = IACLManager.is_risk_admin(acl, RISK_ADMIN_ADDRESS)
        assert risk_admin_after = TRUE
        %{ stop_prank() %}
        return ()
    end

    func test_grant_bridge_role{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        ):
        alloc_locals
        # ## init ###
        local acl
        local pool_addresses_provider
        %{
            ids.acl = context.acl
            ids.pool_addresses_provider = context.pool_addresses_provider
        %}
        %{ stop_prank = start_prank(ids.PRANK_ADMIN_ADDRESS, target_contract_address = ids.acl) %}
        let (bridge_before) = IACLManager.is_bridge(acl, BRIDGE_ADDRESS)
        assert bridge_before = FALSE
        IACLManager.add_bridge(acl, BRIDGE_ADDRESS)
        let (bridge_after) = IACLManager.is_bridge(acl, BRIDGE_ADDRESS)
        assert bridge_after = TRUE
        %{ stop_prank() %}
        return ()
    end

    func test_grant_asset_listing_admin_role{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        alloc_locals
        # ## init ###
        local acl
        local pool_addresses_provider
        %{
            ids.acl = context.acl
            ids.pool_addresses_provider = context.pool_addresses_provider
        %}
        %{ stop_prank = start_prank(ids.PRANK_ADMIN_ADDRESS, target_contract_address = ids.acl) %}
        let (asset_listing_admin_before) = IACLManager.is_asset_listing_admin(
            acl, ASSET_LISTING_ADMIN_ADDRESS
        )
        assert asset_listing_admin_before = FALSE
        IACLManager.add_asset_listing_admin(acl, ASSET_LISTING_ADMIN_ADDRESS)
        let (asset_listing_admin_after) = IACLManager.is_asset_listing_admin(
            acl, ASSET_LISTING_ADMIN_ADDRESS
        )
        assert asset_listing_admin_after = TRUE
        %{ stop_prank() %}
        return ()
    end

    func test_revoke_flash_borrower{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        alloc_locals
        # ## init ###
        local acl
        local pool_addresses_provider
        %{
            ids.acl = context.acl
            ids.pool_addresses_provider = context.pool_addresses_provider
        %}
        %{ stop_prank = start_prank(ids.PRANK_ADMIN_ADDRESS, target_contract_address = ids.acl) %}
        IACLManager.acl_grant_role(acl, FLASH_BORROW_ADMIN_ROLE, FLASH_BORROW_ADMIN_ADDRESS)
        # ## end of init ###
        # set FLASH_BORROW_ADMIN_ROLE as admin for FLASH_BORROWER_ROLE.
        IACLManager.set_role_admin(acl, FLASH_BORROWER_ROLE, FLASH_BORROW_ADMIN_ROLE)
        %{ stop_prank() %}
        %{ stop_prank_1 = start_prank(ids.FLASH_BORROW_ADMIN_ADDRESS, target_contract_address = ids.acl) %}
        IACLManager.add_flash_borrower(acl, FLASH_BORROWER_ADDRESS)
        # Init

        let (role_admin) = IACLManager.acl_has_role(
            acl, FLASH_BORROW_ADMIN_ROLE, FLASH_BORROW_ADMIN_ADDRESS
        )
        assert role_admin = TRUE
        let (is_flash_borrower_before) = IACLManager.is_flash_borrower(acl, FLASH_BORROWER_ADDRESS)
        assert is_flash_borrower_before = TRUE
        IACLManager.remove_flash_borrower(acl, FLASH_BORROWER_ADDRESS)
        %{ stop_prank_1() %}

        let (is_flash_borrower_after) = IACLManager.is_flash_borrower(acl, FLASH_BORROWER_ADDRESS)
        assert is_flash_borrower_after = FALSE
        return ()
    end

    func test_revoke_flash_borrow_admin{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        alloc_locals
        # ## init ###
        local acl
        local pool_addresses_provider
        %{
            ids.acl = context.acl
            ids.pool_addresses_provider = context.pool_addresses_provider
        %}
        %{ stop_prank = start_prank(ids.PRANK_ADMIN_ADDRESS, target_contract_address = ids.acl) %}
        IACLManager.acl_grant_role(acl, FLASH_BORROW_ADMIN_ROLE, FLASH_BORROW_ADMIN_ADDRESS)
        # ## end of init ###
        # set FLASH_BORROW_ADMIN_ROLE as admin for FLASH_BORROWER_ROLE.
        IACLManager.set_role_admin(acl, FLASH_BORROWER_ROLE, FLASH_BORROW_ADMIN_ROLE)

        let (role_admin) = IACLManager.acl_has_role(
            acl, FLASH_BORROW_ADMIN_ROLE, FLASH_BORROW_ADMIN_ADDRESS
        )
        assert role_admin = TRUE

        IACLManager.acl_revoke_role(acl, FLASH_BORROW_ADMIN_ROLE, FLASH_BORROW_ADMIN_ADDRESS)
        %{ stop_prank() %}

        let (role_admin_after) = IACLManager.acl_has_role(
            acl, FLASH_BORROW_ADMIN_ROLE, FLASH_BORROW_ADMIN_ADDRESS
        )
        assert role_admin_after = FALSE
        return ()
    end

    func test_revoke_pool_admin_role{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        alloc_locals
        # ## init ###
        local acl
        local pool_addresses_provider
        %{
            ids.acl = context.acl
            ids.pool_addresses_provider = context.pool_addresses_provider
        %}
        %{ stop_prank = start_prank(ids.PRANK_ADMIN_ADDRESS, target_contract_address = ids.acl) %}
        let (pool_admin_before) = IACLManager.is_pool_admin(acl, POOL_ADMIN_ADDRESS)
        assert pool_admin_before = FALSE
        IACLManager.add_pool_admin(acl, POOL_ADMIN_ADDRESS)
        let (pool_admin_after) = IACLManager.is_pool_admin(acl, POOL_ADMIN_ADDRESS)
        assert pool_admin_after = TRUE
        IACLManager.remove_pool_admin(acl, POOL_ADMIN_ADDRESS)
        let (pool_admin_final) = IACLManager.is_pool_admin(acl, POOL_ADMIN_ADDRESS)
        assert pool_admin_final = FALSE

        %{ stop_prank() %}
        return ()
    end

    func test_revoke_emergency_admin_role{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        alloc_locals
        # ## init ###
        local acl
        local pool_addresses_provider
        %{
            ids.acl = context.acl
            ids.pool_addresses_provider = context.pool_addresses_provider
        %}
        %{ stop_prank = start_prank(ids.PRANK_ADMIN_ADDRESS, target_contract_address = ids.acl) %}
        let (pool_admin_before) = IACLManager.is_emergency_admin(acl, EMERGENCY_ADMIN_ADDRESS)
        assert pool_admin_before = FALSE
        IACLManager.add_emergency_admin(acl, EMERGENCY_ADMIN_ADDRESS)
        let (pool_admin_after) = IACLManager.is_emergency_admin(acl, EMERGENCY_ADMIN_ADDRESS)
        assert pool_admin_after = TRUE

        IACLManager.remove_emergency_admin(acl, EMERGENCY_ADMIN_ADDRESS)
        let (pool_admin_final) = IACLManager.is_emergency_admin(acl, EMERGENCY_ADMIN_ADDRESS)
        assert pool_admin_final = FALSE
        %{ stop_prank() %}
        return ()
    end

    func test_revoke_risk_admin_role{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        alloc_locals
        # ## init ###
        local acl
        local pool_addresses_provider
        %{
            ids.acl = context.acl
            ids.pool_addresses_provider = context.pool_addresses_provider
        %}
        %{ stop_prank = start_prank(ids.PRANK_ADMIN_ADDRESS, target_contract_address = ids.acl) %}
        let (risk_admin_before) = IACLManager.is_risk_admin(acl, RISK_ADMIN_ADDRESS)
        assert risk_admin_before = FALSE
        IACLManager.add_risk_admin(acl, RISK_ADMIN_ADDRESS)
        let (risk_admin_after) = IACLManager.is_risk_admin(acl, RISK_ADMIN_ADDRESS)
        assert risk_admin_after = TRUE

        IACLManager.remove_risk_admin(acl, RISK_ADMIN_ADDRESS)
        let (risk_admin_final) = IACLManager.is_risk_admin(acl, RISK_ADMIN_ADDRESS)
        assert risk_admin_final = FALSE
        %{ stop_prank() %}
        return ()
    end

    func test_revoke_bridge_role{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        ):
        alloc_locals
        # ## init ###
        local acl
        local pool_addresses_provider
        %{
            ids.acl = context.acl
            ids.pool_addresses_provider = context.pool_addresses_provider
        %}
        %{ stop_prank = start_prank(ids.PRANK_ADMIN_ADDRESS, target_contract_address = ids.acl) %}
        let (bridge_before) = IACLManager.is_bridge(acl, BRIDGE_ADDRESS)
        assert bridge_before = FALSE
        IACLManager.add_bridge(acl, BRIDGE_ADDRESS)
        let (bridge_after) = IACLManager.is_bridge(acl, BRIDGE_ADDRESS)
        assert bridge_after = TRUE
        IACLManager.remove_bridge(acl, BRIDGE_ADDRESS)
        let (bridge_final) = IACLManager.is_bridge(acl, BRIDGE_ADDRESS)
        assert bridge_final = FALSE
        %{ stop_prank() %}
        return ()
    end

    func test_revoke_asset_listing_admin_role{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }():
        alloc_locals
        # ## init ###
        local acl
        local pool_addresses_provider
        %{
            ids.acl = context.acl
            ids.pool_addresses_provider = context.pool_addresses_provider
        %}
        %{ stop_prank = start_prank(ids.PRANK_ADMIN_ADDRESS, target_contract_address = ids.acl) %}
        let (asset_listing_admin_before) = IACLManager.is_asset_listing_admin(
            acl, ASSET_LISTING_ADMIN_ADDRESS
        )
        assert asset_listing_admin_before = FALSE
        IACLManager.add_asset_listing_admin(acl, ASSET_LISTING_ADMIN_ADDRESS)
        let (asset_listing_admin_after) = IACLManager.is_asset_listing_admin(
            acl, ASSET_LISTING_ADMIN_ADDRESS
        )
        assert asset_listing_admin_after = TRUE
        IACLManager.remove_asset_listing_admin(acl, ASSET_LISTING_ADMIN_ADDRESS)
        let (asset_listing_admin_final) = IACLManager.is_asset_listing_admin(
            acl, ASSET_LISTING_ADMIN_ADDRESS
        )
        assert asset_listing_admin_final = FALSE
        %{ stop_prank() %}
        return ()
    end
end
