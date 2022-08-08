%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from contracts.protocol.pool.pool_storage import PoolStorage
from contracts.protocol.libraries.configuration.user_configuration import UserConfiguration
from contracts.protocol.libraries.configuration.reserve_configuration import ReserveConfiguration
from contracts.protocol.libraries.configuration.reserve_index_operations import (
    BORROWING_TYPE,
    USING_AS_COLLATERAL_TYPE,
)

const TEST_ADDRESS = 4812950810879290
const TEST_ADDRESS_2 = 5832954280734189
const TEST_ADDRESS_3 = 2137213721372137
const TEST_ADDRESS_4 = 7372187518950897

const TEST_RESERVE_INDEX = 1
const TEST_RESERVE_INDEX_2 = 2
const TEST_RESERVE_INDEX_3 = 3

const TEST_ASSET_ADDRESS = 47128935710
const TEST_ASSET_ADDRESS_2 = 30589205810
const TEST_ASSET_ADDRESS_3 = 35892085093

@external
func test_set_borrowing_and_is_borrowing{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    UserConfiguration.set_borrowing(TEST_ADDRESS, TEST_RESERVE_INDEX, TRUE)

    let (bor) = UserConfiguration.is_borrowing(TEST_ADDRESS, TEST_RESERVE_INDEX)
    assert bor = TRUE

    let (bor) = UserConfiguration.is_borrowing(TEST_ADDRESS, TEST_RESERVE_INDEX_2)
    assert bor = FALSE

    let (bor) = UserConfiguration.is_borrowing(TEST_ADDRESS_2, TEST_RESERVE_INDEX)
    assert bor = FALSE

    return ()
end

@external
func test_set_using_as_collateral_and_is_using_as_collateral{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    UserConfiguration.set_using_as_collateral(TEST_ADDRESS, TEST_RESERVE_INDEX, TRUE)

    let (col) = UserConfiguration.is_using_as_collateral(TEST_ADDRESS, TEST_RESERVE_INDEX)
    assert col = TRUE

    let (col) = UserConfiguration.is_using_as_collateral(TEST_ADDRESS, TEST_RESERVE_INDEX_2)
    assert col = FALSE

    let (col) = UserConfiguration.is_using_as_collateral(TEST_ADDRESS_2, TEST_RESERVE_INDEX)
    assert col = FALSE

    return ()
end

@external
func test_is_using_as_collateral_or_borrowing{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    # 1
    UserConfiguration.set_using_as_collateral(TEST_ADDRESS, TEST_RESERVE_INDEX, TRUE)
    UserConfiguration.set_borrowing(TEST_ADDRESS, TEST_RESERVE_INDEX, TRUE)

    let (res) = UserConfiguration.is_using_as_collateral_or_borrowing(
        TEST_ADDRESS, TEST_RESERVE_INDEX
    )
    assert res = TRUE

    # 2
    UserConfiguration.set_using_as_collateral(TEST_ADDRESS_2, TEST_RESERVE_INDEX, TRUE)
    let (res) = UserConfiguration.is_using_as_collateral_or_borrowing(
        TEST_ADDRESS_2, TEST_RESERVE_INDEX
    )
    assert res = TRUE

    # 3
    UserConfiguration.set_borrowing(TEST_ADDRESS_3, TEST_RESERVE_INDEX, TRUE)
    let (res) = UserConfiguration.is_using_as_collateral_or_borrowing(
        TEST_ADDRESS_3, TEST_RESERVE_INDEX
    )
    assert res = TRUE

    # 4
    let (res) = UserConfiguration.is_using_as_collateral_or_borrowing(
        TEST_ADDRESS_4, TEST_RESERVE_INDEX
    )
    assert res = FALSE

    return ()
end

@external
func test_is_using_as_collateral_one{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    # 1
    UserConfiguration.set_using_as_collateral(TEST_ADDRESS, TEST_RESERVE_INDEX, TRUE)

    let (col) = UserConfiguration.is_using_as_collateral_one(TEST_ADDRESS)
    assert col = TRUE

    # 2
    UserConfiguration.set_using_as_collateral(TEST_ADDRESS_2, TEST_RESERVE_INDEX, TRUE)
    UserConfiguration.set_using_as_collateral(TEST_ADDRESS_2, TEST_RESERVE_INDEX_2, TRUE)

    let (col) = UserConfiguration.is_using_as_collateral_one(TEST_ADDRESS_2)
    assert col = FALSE

    # 3
    let (col) = UserConfiguration.is_using_as_collateral_one(TEST_ADDRESS_3)
    assert col = FALSE

    return ()
end

@external
func test_is_using_as_collateral_any{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    # 1
    UserConfiguration.set_using_as_collateral(TEST_ADDRESS, TEST_RESERVE_INDEX, TRUE)

    let (col) = UserConfiguration.is_using_as_collateral_any(TEST_ADDRESS)
    assert col = TRUE

    # 2
    UserConfiguration.set_using_as_collateral(TEST_ADDRESS_2, TEST_RESERVE_INDEX, TRUE)
    UserConfiguration.set_using_as_collateral(TEST_ADDRESS_2, TEST_RESERVE_INDEX_2, TRUE)

    let (col) = UserConfiguration.is_using_as_collateral_any(TEST_ADDRESS_2)
    assert col = TRUE

    # 3
    let (col) = UserConfiguration.is_using_as_collateral_any(TEST_ADDRESS_3)
    assert col = FALSE

    return ()
end

@external
func test_is_borrowing_one{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    # 1
    UserConfiguration.set_borrowing(TEST_ADDRESS, TEST_RESERVE_INDEX, TRUE)

    let (bor) = UserConfiguration.is_borrowing_one(TEST_ADDRESS)
    assert bor = TRUE

    # 2
    UserConfiguration.set_borrowing(TEST_ADDRESS_2, TEST_RESERVE_INDEX, TRUE)
    UserConfiguration.set_borrowing(TEST_ADDRESS_2, TEST_RESERVE_INDEX_2, TRUE)

    let (bor) = UserConfiguration.is_borrowing_one(TEST_ADDRESS_2)
    assert bor = FALSE

    # 3
    let (bor) = UserConfiguration.is_borrowing_one(TEST_ADDRESS_3)
    assert bor = FALSE

    return ()
end

@external
func test_is_borrowing_any{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    # 1
    UserConfiguration.set_borrowing(TEST_ADDRESS, TEST_RESERVE_INDEX, TRUE)

    let (col) = UserConfiguration.is_borrowing_any(TEST_ADDRESS)
    assert col = TRUE

    # 2
    UserConfiguration.set_borrowing(TEST_ADDRESS_2, TEST_RESERVE_INDEX, TRUE)
    UserConfiguration.set_borrowing(TEST_ADDRESS_2, TEST_RESERVE_INDEX_2, TRUE)

    let (col) = UserConfiguration.is_borrowing_any(TEST_ADDRESS_2)
    assert col = TRUE

    # 3
    let (col) = UserConfiguration.is_borrowing_any(TEST_ADDRESS_3)
    assert col = FALSE

    return ()
end

@external
func test_is_empty{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    # 1
    let (col) = UserConfiguration.is_empty(TEST_ADDRESS)
    assert col = TRUE

    # 2
    UserConfiguration.set_borrowing(TEST_ADDRESS, TEST_RESERVE_INDEX, TRUE)

    let (col) = UserConfiguration.is_empty(TEST_ADDRESS)
    assert col = FALSE

    return ()
end

@external
func test_get_first_asset_by_type{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    # Adding and removing asset, checking if elements in list are properly orderd
    # 1
    UserConfiguration.set_borrowing(TEST_ADDRESS, TEST_RESERVE_INDEX, TRUE)
    UserConfiguration.set_borrowing(TEST_ADDRESS, TEST_RESERVE_INDEX_2, TRUE)

    let (ast) = UserConfiguration.get_first_asset_by_type(TEST_ADDRESS, BORROWING_TYPE)

    assert ast = TEST_RESERVE_INDEX

    # 2
    UserConfiguration.set_borrowing(TEST_ADDRESS_2, TEST_RESERVE_INDEX, TRUE)
    UserConfiguration.set_borrowing(TEST_ADDRESS_2, TEST_RESERVE_INDEX_2, TRUE)
    UserConfiguration.set_borrowing(TEST_ADDRESS_2, TEST_RESERVE_INDEX_3, TRUE)
    UserConfiguration.set_borrowing(TEST_ADDRESS_2, TEST_RESERVE_INDEX, FALSE)

    let (ast) = UserConfiguration.get_first_asset_by_type(TEST_ADDRESS_2, BORROWING_TYPE)

    assert ast = TEST_RESERVE_INDEX_2

    # 3
    UserConfiguration.set_using_as_collateral(TEST_ADDRESS_3, TEST_RESERVE_INDEX, TRUE)
    UserConfiguration.set_using_as_collateral(TEST_ADDRESS_3, TEST_RESERVE_INDEX_2, TRUE)
    UserConfiguration.set_using_as_collateral(TEST_ADDRESS_3, TEST_RESERVE_INDEX_3, TRUE)
    UserConfiguration.set_using_as_collateral(TEST_ADDRESS_3, TEST_RESERVE_INDEX, FALSE)
    UserConfiguration.set_using_as_collateral(TEST_ADDRESS_3, TEST_RESERVE_INDEX_2, FALSE)
    UserConfiguration.set_using_as_collateral(TEST_ADDRESS_3, TEST_RESERVE_INDEX, TRUE)

    let (ast) = UserConfiguration.get_first_asset_by_type(TEST_ADDRESS_3, USING_AS_COLLATERAL_TYPE)

    assert ast = TEST_RESERVE_INDEX

    return ()
end

@external
func test_get_isolation_mode_state{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    alloc_locals
    PoolStorage.reserves_list_write(TEST_RESERVE_INDEX, TEST_ASSET_ADDRESS)
    PoolStorage.reserves_list_write(TEST_RESERVE_INDEX_2, TEST_ASSET_ADDRESS_2)

    # 1 User using one asset as collateral with ceiling
    ReserveConfiguration.set_debt_ceiling(TEST_ASSET_ADDRESS, 1000)

    UserConfiguration.set_using_as_collateral(TEST_ADDRESS, TEST_RESERVE_INDEX, TRUE)

    let (res_bool, res_asset, res_ceiling) = UserConfiguration.get_isolation_mode_state(
        TEST_ADDRESS
    )

    assert res_bool = TRUE
    assert res_asset = TEST_ASSET_ADDRESS
    assert res_ceiling = 1000

    # 2 Another user using the same asset as collateral
    UserConfiguration.set_using_as_collateral(TEST_ADDRESS_2, TEST_RESERVE_INDEX, TRUE)

    let (res_bool, res_asset, res_ceiling) = UserConfiguration.get_isolation_mode_state(
        TEST_ADDRESS_2
    )

    assert res_bool = TRUE
    assert res_asset = TEST_ASSET_ADDRESS
    assert res_ceiling = 1000

    # 3 User is using second asset as collateral
    UserConfiguration.set_using_as_collateral(TEST_ADDRESS, TEST_RESERVE_INDEX_2, TRUE)

    let (res_bool, res_asset, res_ceiling) = UserConfiguration.get_isolation_mode_state(
        TEST_ADDRESS
    )

    assert res_bool = FALSE
    assert res_asset = 0
    assert res_ceiling = 0

    # 4 User doesn't use any asset as collateral
    let (res_bool, res_asset, res_ceiling) = UserConfiguration.get_isolation_mode_state(
        TEST_ADDRESS_3
    )

    assert res_bool = FALSE
    assert res_asset = 0
    assert res_ceiling = 0

    # 5 Using one asset as collateral without ceiling
    UserConfiguration.set_using_as_collateral(TEST_ADDRESS_3, TEST_RESERVE_INDEX_2, TRUE)

    let (res_bool, res_asset, res_ceiling) = UserConfiguration.get_isolation_mode_state(
        TEST_ADDRESS_3
    )

    assert res_bool = FALSE
    assert res_asset = 0
    assert res_ceiling = 0

    # 6 User uses asset as collateral and as borrowing
    UserConfiguration.set_borrowing(TEST_ADDRESS_2, TEST_RESERVE_INDEX, TRUE)

    let (res_bool, res_asset, res_ceiling) = UserConfiguration.get_isolation_mode_state(
        TEST_ADDRESS_2
    )

    assert res_bool = TRUE
    assert res_asset = TEST_ASSET_ADDRESS
    assert res_ceiling = 1000

    return ()
end

@external
func test_get_siloed_borrowing_state{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    alloc_locals
    PoolStorage.reserves_list_write(TEST_RESERVE_INDEX, TEST_ASSET_ADDRESS)
    PoolStorage.reserves_list_write(TEST_RESERVE_INDEX_2, TEST_ASSET_ADDRESS_2)

    # 1 User borrowing one asset with siloed enabled
    ReserveConfiguration.set_siloed_borrowing(TEST_ASSET_ADDRESS, TRUE)

    UserConfiguration.set_borrowing(TEST_ADDRESS, TEST_RESERVE_INDEX, TRUE)

    let (res_bool, res_asset) = UserConfiguration.get_siloed_borrowing_state(TEST_ADDRESS)

    assert res_bool = TRUE
    assert res_asset = TEST_ASSET_ADDRESS

    # 2 Another user uses the same asset
    UserConfiguration.set_borrowing(TEST_ADDRESS_2, TEST_RESERVE_INDEX, TRUE)

    let (res_bool, res_asset) = UserConfiguration.get_siloed_borrowing_state(TEST_ADDRESS_2)

    assert res_bool = TRUE
    assert res_asset = TEST_ASSET_ADDRESS

    # 3 User is borrowing another asset
    UserConfiguration.set_borrowing(TEST_ADDRESS, TEST_RESERVE_INDEX_2, TRUE)

    let (res_bool, res_asset) = UserConfiguration.get_siloed_borrowing_state(TEST_ADDRESS)

    assert res_bool = FALSE
    assert res_asset = 0

    # 4 User is not borrowing any asset
    let (res_bool, res_asset) = UserConfiguration.get_siloed_borrowing_state(TEST_ADDRESS_3)

    assert res_bool = FALSE
    assert res_asset = 0

    # 5 User is borrowing asset without siloed enabled
    UserConfiguration.set_borrowing(TEST_ADDRESS_3, TEST_RESERVE_INDEX_2, TRUE)
    let (res_bool, res_asset) = UserConfiguration.get_siloed_borrowing_state(TEST_ADDRESS_3)

    assert res_bool = FALSE
    assert res_asset = 0

    # 6 User is using asset also as collateral
    UserConfiguration.set_using_as_collateral(TEST_ADDRESS_2, TEST_RESERVE_INDEX, TRUE)

    let (res_bool, res_asset) = UserConfiguration.get_siloed_borrowing_state(TEST_ADDRESS_2)

    assert res_bool = TRUE
    assert res_asset = TEST_ASSET_ADDRESS

    return ()
end
