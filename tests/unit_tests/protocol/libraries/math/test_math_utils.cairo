%lang starknet
from starkware.starknet.common.syscalls import get_block_timestamp
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from contracts.protocol.libraries.math.wad_ray_math import RAY
from contracts.protocol.libraries.math.math_utils import MathUtils

const rate_in_ray = 34 * RAY

@external
func test_calculate_linear_interest{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    alloc_locals

    const last_timestamp = 300
    const current_timestamp = 301
    %{ stop_warp = warp(ids.current_timestamp) %}
    let (res : Uint256) = MathUtils.calculate_linear_interest(
        Uint256(rate_in_ray, 0), last_timestamp
    )
    %{ stop_warp() %}
    # expected result (tested against  Solidity code with same values)
    assert res.low = 1000001078132927447995941146
    return ()
end

@external
func test_calculate_compounded_interest{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    alloc_locals

    const last_timestamp = 300
    const current_timestamp = 305

    %{ stop_warp = warp(ids.current_timestamp) %}
    let (res_1 : Uint256) = MathUtils.calculate_compounded_interest(
        Uint256(rate_in_ray, 0), last_timestamp
    )

    # expected result (tested against Solidity code with same values)
    assert res_1.low = 1000005390676260958604081853
    %{ stop_warp() %}

    # test when exp=0
    %{ stop_warp = warp(ids.current_timestamp-5) %}
    let (res_2 : Uint256) = MathUtils.calculate_compounded_interest(
        Uint256(rate_in_ray, 0), last_timestamp
    )

    # should return one RAY
    assert res_2.low = RAY
    %{ stop_warp() %}

    # test when exp<2 (exp_minus_two term should be set to zero)

    %{ stop_warp = warp(ids.current_timestamp-4) %}
    let (res_3 : Uint256) = MathUtils.calculate_compounded_interest(
        Uint256(rate_in_ray, 0), last_timestamp
    )

    # expected result (tested against  Solidity code with same values)
    assert res_3.low = 1000001078132927447995941146

    %{ stop_warp() %}
    return ()
end
