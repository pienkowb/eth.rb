# Copyright (c) 2016-2022 The Ruby-Eth Contributors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Provides the `Eth` module.
module Eth

  # The `Eth::Address` class to handle checksummed Ethereum addresses.
  class Address

    # The prefixed and checksummed Ethereum address.
    attr_reader :address

    # Constructor of the `Eth::Address` class. Creates a new hex
    # prefixed address.
    #
    # @param address [String] hex string representing an ethereum address.
    def initialize address
      @address = Utils.prefix_hex address
    end

    # Check that the address is valid.
    #
    # @return [Bool] true if valid address.
    def valid?
      if !matches_any_format?
        false
      elsif not_checksummed?
        true
      else
        checksum_matches?
      end
    end

    # Generate a checksummed address.
    #
    # @return [String] prefixed hexstring representing an checksummed address.
    def checksummed
      raise "Invalid address: #{address}" unless matches_any_format?

      cased = unprefixed.chars.zip(checksum.chars).map do |char, check|
        check.match(/[0-7]/) ? char.downcase : char.upcase
      end

      Utils.prefix_hex(cased.join)
    end

    # Generate a checksummed address string. Alias for `checksummed`.
    #
    # @return [String] prefixed hexstring representing an checksummed address.
    def to_s
      checksummed
    end

    private

    def checksum_matches?
      address == checksummed
    end

    def not_checksummed?
      all_uppercase? || all_lowercase?
    end

    def all_uppercase?
      address.match(/(?:0[xX])[A-F0-9]{40}/)
    end

    def all_lowercase?
      address.match(/(?:0[xX])[a-f0-9]{40}/)
    end

    def matches_any_format?
      address.match(/\A(?:0[xX])[a-fA-F0-9]{40}\z/)
    end

    def checksum
      Utils.bin_to_hex(Utils.keccak256 unprefixed.downcase)
    end

    def unprefixed
      Utils.remove_hex_prefix address
    end
  end
end