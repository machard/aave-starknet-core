from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_eq,
    uint256_sub,
    uint256_le,
    uint256_lt,
    uint256_unsigned_div_rem,
    uint256_mul,
    uint256_add,
)
from starkware.cairo.common.bool import FALSE, TRUE

const RANGE_CHECK_BOUND = 2 ** 128 - 1

# @title PercentageMath library
# @author Aave
# @notice Provides functions to perform percentage calculations
# @dev Percentages are defined by default with 2 decimals of precision (100.00). The precision is indicated by PERCENTAGE_FACTOR
# @dev Operations are rounded. If a value is >=.5, will be rounded up, otherwise rounded down.
namespace PercentageMath:
    # Maximum percentage factor (100.00%)
    const PERCENTAGE_FACTOR = 1 * 10 ** 4  # 1e4

    # Half percentage factor (50.00%)
    const HALF_PERCENTAGE_FACTOR = 5 * 10 ** 3  # 0.5e4

    # @notice Executes a percentage multiplication
    # @param value The value of which the percentage needs to be calculated
    # @param percentage The percentage of the value to be calculated
    # @return result value percentmul percentage
    func percent_mul{range_check_ptr}(value : Uint256, percentage : Uint256) -> (result : Uint256):
        # to avoid overflow, value <= (type(uint256).max - HALF_PERCENTAGE_FACTOR) / percentage
        let (is_percentage_zero) = uint256_eq(percentage, Uint256(0, 0))
        with_attr error_message("percentage cannot be zero"):
            assert is_percentage_zero = FALSE
        end

        tempvar max_uint_256 = Uint256(RANGE_CHECK_BOUND, RANGE_CHECK_BOUND)
        let (overflow_numerator) = uint256_sub(max_uint_256, Uint256(HALF_PERCENTAGE_FACTOR, 0))
        let (overflow_limit, _) = uint256_unsigned_div_rem(overflow_numerator, percentage)
        let (is_value_not_overflowing) = uint256_le(value, overflow_limit)
        with_attr error_message("value overflow"):
            assert is_value_not_overflowing = TRUE
        end

        let (value_mul_percentage, _) = uint256_mul(value, percentage)
        let (intermediate_res_1, _) = uint256_add(
            value_mul_percentage, Uint256(HALF_PERCENTAGE_FACTOR, 0)
        )
        let (result, _) = uint256_unsigned_div_rem(
            intermediate_res_1, Uint256(PERCENTAGE_FACTOR, 0)
        )

        return (result)
    end

    # @notice Executes a percentage division
    # @param value The value of which the percentage needs to be calculated
    # @param percentage The percentage of the value to be calculated
    # @return result value percentdiv percentage
    func percent_div{range_check_ptr}(value : Uint256, percentage : Uint256) -> (result : Uint256):
        alloc_locals
        # to avoid overflow, value <= (type(uint256).max - half_percentage) / PERCENTAGE_FACTOR
        let (is_percentage_zero) = uint256_eq(percentage, Uint256(0, 0))
        with_attr error_message("percentage cannot be zero"):
            assert is_percentage_zero = FALSE
        end

        let (half_percentage, _) = uint256_unsigned_div_rem(percentage, Uint256(2, 0))
        tempvar max_uint_256 = Uint256(RANGE_CHECK_BOUND, RANGE_CHECK_BOUND)
        let (overflow_numerator) = uint256_sub(max_uint_256, half_percentage)
        let (overflow_limit, _) = uint256_unsigned_div_rem(
            overflow_numerator, Uint256(PERCENTAGE_FACTOR, 0)
        )
        let (is_value_not_overflowing) = uint256_le(value, overflow_limit)
        with_attr error_message("value overflow"):
            assert is_value_not_overflowing = TRUE
        end

        let (value_mul_percentage_factor, _) = uint256_mul(value, Uint256(PERCENTAGE_FACTOR, 0))
        let (intermediate_res_1, _) = uint256_add(value_mul_percentage_factor, half_percentage)
        let (result, _) = uint256_unsigned_div_rem(intermediate_res_1, percentage)

        return (result)
    end
end
