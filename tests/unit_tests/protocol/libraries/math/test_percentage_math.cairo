%lang starknet

from starkware.cairo.common.uint256 import Uint256

from contracts.protocol.libraries.math.percentage_math import PercentageMath

@external
func test_percent_math_mul{range_check_ptr}():
    alloc_locals
    # Test with an unrounded value
    local percentage : Uint256 = Uint256(100, 0)  # 1%
    let (result) = PercentageMath.percent_mul(Uint256(1000, 0), percentage)
    assert result = Uint256(10, 0)

    # Test with a value rounded down
    let (result) = PercentageMath.percent_mul(Uint256(1049, 0), percentage)
    assert result = Uint256(10, 0)

    # Test with a value rounded up
    let (result) = PercentageMath.percent_mul(Uint256(1051, 0), percentage)
    assert result = Uint256(11, 0)

    return ()
end

@external
func test_percent_math_mul_overflow{range_check_ptr}():
    alloc_locals
    # Overflow limit is Uint256(190558125475725539539489780161790198365, 3402823669209384634633746074317682114) (higher than solidity's)
    local percentage : Uint256 = Uint256(100, 0)  # 1%
    local value_not_overflowing : Uint256 = Uint256(190558125475725539539489780161790198365, 3402823669209384634633746074317682114)
    local value_overflowing : Uint256 = Uint256(190558125475725539539489780161790198366, 3402823669209384634633746074317682114)

    # Should not overflow
    let (result) = PercentageMath.percent_mul(value_not_overflowing, percentage)

    # Test with a value overflowing
    %{ expect_revert(error_message="value overflow") %}
    let (result) = PercentageMath.percent_mul(value_overflowing, percentage)
    return ()
end

@external
func test_percent_math_mul_zero{range_check_ptr}():
    alloc_locals
    local percentage : Uint256 = Uint256(0, 0)  # 1%

    # Test with a percentage of 0
    %{ expect_revert(error_message="percentage cannot be zero") %}
    let (result) = PercentageMath.percent_mul(Uint256(100, 0), percentage)
    return ()
end

@external
func test_percent_math_div{range_check_ptr}():
    alloc_locals
    # Test with an unrounded value
    local value : Uint256 = Uint256(1000, 0)
    let (result) = PercentageMath.percent_div(value, Uint256(10000, 0))  # 100%
    assert result = Uint256(1000, 0)

    # Test with a value rounded up
    let (result) = PercentageMath.percent_div(value, Uint256(10005, 0))  # 100.05%
    # real result is ~999.5xx
    assert result = Uint256(1000, 0)

    # Test with a value rounded down
    let (result) = PercentageMath.percent_div(value, Uint256(10006, 0))  # 100.06%
    # real result is ~999.4xx
    assert result = Uint256(999, 0)

    return ()
end

@external
func test_percent_math_div_overflow{range_check_ptr}():
    alloc_locals
    # Overflow limit is Uint256(49545112623688640280267342842065451587, 34028236692093846346337460743176821) (same as solidity)
    local value_not_overflowing : Uint256 = Uint256(49545112623688640280267342842065451587, 34028236692093846346337460743176821)
    local value_overflowing : Uint256 = Uint256(49545112623688640280267342842065451588, 34028236692093846346337460743176821)

    # Should not overflow
    let (result) = PercentageMath.percent_div(value_not_overflowing, Uint256(10 ** 4, 0))

    # Test with a value overflowing
    %{ expect_revert(error_message="value overflow") %}
    let (result) = PercentageMath.percent_div(value_overflowing, Uint256(10 ** 4, 0))
    return ()
end

@external
func test_percent_math_div_zero{range_check_ptr}():
    alloc_locals
    local percentage : Uint256 = Uint256(0, 0)  # 0%

    # Test with a percentage of 0
    %{ expect_revert(error_message="percentage cannot be zero") %}
    let (result) = PercentageMath.percent_div(Uint256(100, 0), percentage)
    return ()
end
