%lang starknet

from starkware.cairo.common.bool import FALSE
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
)
from openzeppelin.access.accesscontrol import AccessControl, AccessControl_role_admin
from openzeppelin.utils.constants import DEFAULT_ADMIN_ROLE

const PRANK_PROVIDER = 111
const PRANK_ADMIN_ADDRESS = 222
const PRANK_ROLE_1 = 11
const PRANK_ROLE_2 = 22
const PRANK_ADMIN_ROLE = 99
const PRANK_USER_1 = 1
const PRANK_USER_2 = 2

@view
func test_initializer{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    %{ stop_mock_provider = mock_call(ids.PRANK_PROVIDER, "get_ACL_admin", [ids.PRANK_ADMIN_ADDRESS]) %}
    ACLManager.initializer(PRANK_PROVIDER)
    let (has_role) = AccessControl.has_role(DEFAULT_ADMIN_ROLE, PRANK_ADMIN_ADDRESS)
    %{ stop_mock_provider() %}
    assert has_role = 1
    return ()
end

@view
func test_set_role_admin{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    %{ stop_mock_provider = mock_call(ids.PRANK_PROVIDER, "get_ACL_admin", [ids.PRANK_ADMIN_ADDRESS]) %}
    ACLManager.initializer(PRANK_PROVIDER)
    %{ stop_prank = start_prank(ids.PRANK_ADMIN_ADDRESS) %}
    ACLManager.set_role_admin(PRANK_ROLE_1, PRANK_ADMIN_ROLE)
    let (admin_role) = AccessControl_role_admin.read(PRANK_ROLE_1)
    assert admin_role = PRANK_ADMIN_ROLE
    %{ stop_prank() %}
    %{ stop_mock_provider() %}
    return ()
end

@view
func test_emergency_admin_mgt{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    %{ stop_mock_provider = mock_call(ids.PRANK_PROVIDER, "get_ACL_admin", [ids.PRANK_ADMIN_ADDRESS]) %}
    ACLManager.initializer(PRANK_PROVIDER)
    %{ stop_prank = start_prank(ids.PRANK_ADMIN_ADDRESS) %}
    # address of caller
    ACLManager.set_role_admin(EMERGENCY_ADMIN_ROLE, DEFAULT_ADMIN_ROLE)
    # AccessControl.grant_role(PRANK_ADMIN_ROLE, PRANK_ADMIN_ADDRESS)
    let (admin_role) = AccessControl_role_admin.read(EMERGENCY_ADMIN_ROLE)
    assert admin_role = DEFAULT_ADMIN_ROLE

    let (emergency_admin) = AccessControl.get_role_admin(EMERGENCY_ADMIN_ROLE)
    %{ print("POOL_ADMIN_ROLE : " + str(ids.emergency_admin) ) %}

    ACLManager.add_emergency_admin(PRANK_USER_1)
    let (user_1_emergency_role) = AccessControl.has_role(EMERGENCY_ADMIN_ROLE, PRANK_USER_1)
    assert user_1_emergency_role = 1
    let (has_user_1_role) = ACLManager.is_emergency_admin(PRANK_USER_1)
    assert has_user_1_role = 1

    ACLManager.remove_emergency_admin(PRANK_USER_1)
    let (user_1_emergency_role_after_revoke) = ACLManager.is_emergency_admin(PRANK_USER_1)
    %{ expect_revert() %}
    assert user_1_emergency_role_after_revoke = 1

    %{ stop_prank() %}
    %{ stop_mock_provider() %}
    return ()
end

@view
func test_pool_admin_mgt{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    %{ stop_mock_provider = mock_call(ids.PRANK_PROVIDER, "get_ACL_admin", [ids.PRANK_ADMIN_ADDRESS]) %}
    ACLManager.initializer(PRANK_PROVIDER)
    %{ stop_prank = start_prank(ids.PRANK_ADMIN_ADDRESS) %}
    # address of caller
    ACLManager.set_role_admin(POOL_ADMIN_ROLE, DEFAULT_ADMIN_ROLE)
    # AccessControl.grant_role(PRANK_ADMIN_ROLE, PRANK_ADMIN_ADDRESS)
    let (admin_role) = AccessControl_role_admin.read(POOL_ADMIN_ROLE)
    assert admin_role = DEFAULT_ADMIN_ROLE

    let (pool_admin) = AccessControl.get_role_admin(POOL_ADMIN_ROLE)
    %{ print("POOL_ADMIN_ROLE : " + str(ids.pool_admin) ) %}

    ACLManager.add_pool_admin(PRANK_USER_1)
    let (user_1_pool_role) = AccessControl.has_role(POOL_ADMIN_ROLE, PRANK_USER_1)
    assert user_1_pool_role = 1
    let (has_user_1_role) = ACLManager.is_pool_admin(PRANK_USER_1)
    assert has_user_1_role = 1

    ACLManager.remove_pool_admin(PRANK_USER_1)
    let (user_1_pool_role_after_revoke) = ACLManager.is_pool_admin(PRANK_USER_1)
    assert user_1_pool_role_after_revoke = 0

    %{ stop_prank() %}
    %{ stop_mock_provider() %}
    return ()
end
