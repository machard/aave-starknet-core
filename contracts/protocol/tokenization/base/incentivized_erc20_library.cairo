%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.math import assert_le_felt, assert_not_zero
from starkware.cairo.common.math_cmp import is_not_zero
from starkware.cairo.common.bool import TRUE
from starkware.starknet.common.syscalls import get_caller_address

from openzeppelin.security.safemath.library import SafeUint256

from contracts.protocol.libraries.helpers.constants import UINT128_MAX
from contracts.protocol.libraries.math.helpers import to_felt
from contracts.protocol.libraries.types.data_types import DataTypes
from contracts.interfaces.i_acl_manager import IACLManager
from contracts.interfaces.i_pool_addresses_provider import IPoolAddressesProvider
from contracts.interfaces.i_aave_incentives_controller import IAaveIncentivesController
from contracts.interfaces.i_pool import IPool

#
# Events
#

@event
func Transfer(from_ : felt, to : felt, value : Uint256):
end

@event
func Approval(owner : felt, spender : felt, value : Uint256):
end

#
# Storage
#

@storage_var
func IncentivizedERC20_pool() -> (pool : felt):
end

@storage_var
func IncentivizedERC20_name() -> (name : felt):
end

@storage_var
func IncentivizedERC20_symbol() -> (symbol : felt):
end

@storage_var
func IncentivizedERC20_decimals() -> (decimals : felt):
end

@storage_var
func IncentivizedERC20_user_state(address : felt) -> (state : DataTypes.UserState):
end

@storage_var
func IncentivizedERC20_allowances(delegator : felt, delegatee : felt) -> (allowance : Uint256):
end

@storage_var
func IncentivizedERC20_total_supply() -> (total_supply : Uint256):
end

@storage_var
func IncentivizedERC20_incentives_controller() -> (incentives_controller : felt):
end

@storage_var
func IncentivizedERC20_addresses_provider() -> (addresses_provider : felt):
end

@storage_var
func IncentivizedERC20_owner() -> (owner : felt):
end

#
# Internal
#

#
# @notice Transfers tokens between two users and apply incentives if defined.
# @param sender The source address
# @param recipient The destination address
# @param amount The amount getting transferred
# @dev the amount should be passed as uint128 according to solidity code. TODO: should it?
#
func _transfer{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    sender : felt, recipient : felt, amount : Uint256
) -> ():
    with_attr error_message("IncentivizedERC20: cannot transfer from the zero address"):
        assert_not_zero(sender)
    end

    let (amount_felt) = to_felt(amount)

    let (sender_state) = IncentivizedERC20_user_state.read(sender)
    let old_sender_balance = sender_state.balance
    with_attr error_message("IncentivizedERC20: transfer amount exceeds balance"):
        assert_le_felt(amount_felt, old_sender_balance)
    end

    let new_sender_balance = old_sender_balance - amount_felt

    let new_sender_state = DataTypes.UserState(new_sender_balance, sender_state.additional_data)
    IncentivizedERC20_user_state.write(sender, new_sender_state)

    let (recipient_state) = IncentivizedERC20_user_state.read(recipient)
    let recipient_balance = recipient_state.balance
    let new_recipient_balance = recipient_balance + amount_felt
    let new_recipient_state = DataTypes.UserState(
        new_recipient_balance, recipient_state.additional_data
    )
    IncentivizedERC20_user_state.write(recipient, new_recipient_state)

    Transfer.emit(sender, recipient, amount)

    let (incentives_controller) = IncentivizedERC20_incentives_controller.read()
    let (incentives_controller_not_zero) = is_not_zero(incentives_controller)

    let (total_supply) = IncentivizedERC20_total_supply.read()

    if incentives_controller_not_zero == TRUE:
        IAaveIncentivesController.handle_action(
            contract_address=incentives_controller,
            asset=sender,
            user_balance=total_supply,
            total_supply=old_sender_balance,
        )
        let (sender_not_the_recipient) = is_not_zero(sender - recipient)
        if sender_not_the_recipient == TRUE:
            IAaveIncentivesController.handle_action(
                contract_address=incentives_controller,
                asset=recipient,
                user_balance=total_supply,
                total_supply=recipient_balance,
            )
            return ()
        end
        return ()
    end
    return ()
end

#
# @notice Approve `spender` to use `amount` of `owner`s balance
# @param owner The address owning the tokens
# @param spender The address approved for spending
# @param amount The amount of tokens to approve spending of
#
func _approve{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    owner : felt, spender : felt, amount : Uint256
) -> ():
    IncentivizedERC20_allowances.write(owner, spender, amount)

    Approval.emit(owner, spender, amount)

    return ()
end

namespace IncentivizedERC20:
    #
    # Modifiers
    #

    #
    # @dev Only pool admin can call functions marked by this modifier.
    #
    func assert_only_pool_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        ):
        let (caller) = get_caller_address()
        let (address_provider) = IncentivizedERC20_addresses_provider.read()
        let (acl_manager_address) = IPoolAddressesProvider.get_ACL_manager(
            contract_address=address_provider
        )
        let (is_pool_admin) = IACLManager.is_pool_admin(
            contract_address=acl_manager_address, admin_address=caller
        )
        with_attr error_message("IncentivizedERC20: Caller is not pool admin"):
            assert is_pool_admin = TRUE
        end
        return ()
    end

    #
    # @dev Only pool can call functions marked by this modifier.
    #
    func assert_only_pool{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
        alloc_locals
        let (caller_address) = get_caller_address()
        let (pool) = IncentivizedERC20_pool.read()
        with_attr error_message("IncentivizedERC20: Caller must be pool"):
            assert caller_address = pool
        end
        return ()
    end

    # Getters

    #
    # @notice Returns the address of the Incentives Controller contract
    # @return The address of the Incentives Controller
    #
    func get_incentives_controller{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }() -> (incentives_controller : felt):
        let (incentives_controller) = IncentivizedERC20_incentives_controller.read()
        return (incentives_controller)
    end

    func name{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (name : felt):
        let (name) = IncentivizedERC20_name.read()
        return (name)
    end

    func symbol{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        symbol : felt
    ):
        let (symbol) = IncentivizedERC20_symbol.read()
        return (symbol)
    end

    func total_supply{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        total_supply : Uint256
    ):
        let (total_supply : Uint256) = IncentivizedERC20_total_supply.read()
        return (total_supply)
    end

    func decimals{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        decimals : felt
    ):
        let (decimals) = IncentivizedERC20_decimals.read()
        return (decimals)
    end

    func balance_of{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        account : felt
    ) -> (balance : felt):
        let (state) = IncentivizedERC20_user_state.read(account)
        return (state.balance)
    end

    func allowance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        owner : felt, spender : felt
    ) -> (remaining : Uint256):
        let (remaining) = IncentivizedERC20_allowances.read(owner, spender)
        return (remaining)
    end

    # Setters

    func set_name{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(name : felt):
        IncentivizedERC20_name.write(name)
        return ()
    end

    func set_symbol{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        symbol : felt
    ):
        IncentivizedERC20_symbol.write(symbol)
        return ()
    end

    func set_decimals{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        decimals : felt
    ):
        IncentivizedERC20_decimals.write(decimals)
        return ()
    end

    func set_incentives_controller{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
    }(incentives_controller : felt):
        assert_only_pool_admin()
        IncentivizedERC20_incentives_controller.write(incentives_controller)
        return ()
    end

    #
    # Main functions
    #

    func initializer{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        pool : felt, name : felt, symbol : felt, decimals : felt
    ):
        let (addresses_provider) = IPool.get_addresses_provider(contract_address=pool)
        IncentivizedERC20_addresses_provider.write(addresses_provider)
        IncentivizedERC20_name.write(name)
        IncentivizedERC20_symbol.write(symbol)
        IncentivizedERC20_decimals.write(decimals)
        IncentivizedERC20_pool.write(pool)

        return ()
    end

    func transfer{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        recipient : felt, amount : Uint256
    ) -> (success : felt):
        alloc_locals
        let (local caller_address) = get_caller_address()

        _transfer(caller_address, recipient, amount)

        return (TRUE)
    end

    func transfer_from{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        sender : felt, recipient : felt, amount : Uint256
    ) -> (success : felt):
        alloc_locals
        let (local caller_address) = get_caller_address()
        let (allowance) = IncentivizedERC20_allowances.read(sender, caller_address)

        with_attr error_message("IncentivizedERC20: Caller does not have enough allowance"):
            let (new_allowance) = SafeUint256.sub_le(allowance, amount)
        end

        _approve(sender, caller_address, new_allowance)
        _transfer(sender, recipient, amount)

        return (TRUE)
    end

    #
    # @notice Approve `spender` to use `amount` of `owner`s balance
    # @param spender The address approved for spending
    # @param amount The amount of tokens to approve spending of
    #
    func approve{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        spender : felt, amount : Uint256
    ):
        alloc_locals
        let (local caller_address) = get_caller_address()

        _approve(caller_address, spender, amount)

        return ()
    end

    #
    # @notice Increases the allowance of spender to spend caller tokens
    # @param spender The user allowed to spend on behalf of caller
    # @param added_value The amount being added to the allowance
    # @return TRUE = 1
    #
    func increase_allowance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        spender : felt, added_value : Uint256
    ) -> (success : felt):
        alloc_locals
        let (caller_address) = get_caller_address()
        let (old_allowance) = IncentivizedERC20_allowances.read(caller_address, spender)

        with_attr error_message("IncentivizedERC20: Increased allowance is not in range"):
            let (new_allowance) = SafeUint256.add(old_allowance, added_value)
        end

        _approve(caller_address, spender, new_allowance)

        return (TRUE)
    end

    #
    # @notice Decreases the allowance of spender to spend caller tokens
    # @param spender The user allowed to spend on behalf of caller
    # @param subtracted_value The amount being subtracted to the allowance
    # @return TRUE = 1
    #
    func decrease_allowance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        spender : felt, subtracted_value : Uint256
    ) -> (success : felt):
        alloc_locals
        let (caller_address) = get_caller_address()
        let (old_allowance) = IncentivizedERC20_allowances.read(caller_address, spender)

        with_attr error_message("IncentivizedERC20: Decreased allowance is not in range"):
            let (new_allowance) = SafeUint256.sub_le(old_allowance, subtracted_value)
        end

        _approve(caller_address, spender, new_allowance)

        return (TRUE)
    end
end
