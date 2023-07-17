require "spec_helper"

describe Tx do
  context "#GAS" do
    it "defines gas limits" do
      expect(Tx::DEFAULT_GAS_LIMIT).to eq 21_000
      expect(Tx::DEFAULT_PRIORITY_FEE).to eq 1_010_000_000
      expect(Tx::DEFAULT_GAS_PRICE).to eq 42_690_000_000
      expect(Tx::BLOCK_GAS_LIMIT).to eq 30_000_000
    end

    it "defines gas costs" do
      expect(Tx::COST_NON_ZERO_BYTE).to eq 16
      expect(Tx::COST_ZERO_BYTE).to eq 4
      expect(Tx::COST_STORAGE_KEY).to eq 1_900
      expect(Tx::COST_ADDRESS).to eq 2_400
    end

    it "defines transaction types" do
      expect(Tx::TYPE_LEGACY).to eq 0
      expect(Tx::TYPE_2930).to eq 1
      expect(Tx::TYPE_1559).to eq 2
    end
  end

  subject(:list) {
    [
      [
        "de0b295669a9fd93d5f28d9ec85e40f4cb697bae",
        [
          "0000000000000000000000000000000000000000000000000000000000000003",
          "0000000000000000000000000000000000000000000000000000000000000007",
        ],
      ],
      [
        "bb9bc244d798123fde783fcc1c72d3bb8c189413",
        [],
      ],
    ]
  }

  describe ".estimate_intrinsic_gas" do
    it "can estimate intrinsic gas for empty data and lists" do
      expect(Tx.estimate_intrinsic_gas).to eq 21_000
      expect(Tx.estimate_intrinsic_gas "").to eq 21_000
      expect(Tx.estimate_intrinsic_gas "", []).to eq 21_000
    end

    it "can estimate intrinsic gas for call data" do

      # EIP-2028
      expect(Tx.estimate_intrinsic_gas "Lorem, Ipsum!").to eq 21_210
      expect(Tx.estimate_intrinsic_gas "bf010c80018252088080b8c000000000000000000000000000000000000000000000000000000000000000800000000000000000000000003ea1e26a2119b038eaf9b27e65cdb401502ae7a43d8bfb1368aee2693eb325af9f81244b19304b087b4941a1e892da50bd48dfe1f6d17aad7aff1c87e8481f30395a1595a07b483032affed044e698bf7c43a6fe000000000000000000000000000000000000000000000000000000000000000d4c6f72656d2c20497073756d210000000000000000000000000000000000000026a0e06be7a71c58beebfae09372083865f49fbacb6dfd93f10329f2ca925057fba3a0036c90afd27ea5d2383e319f7091aa23d3e77b09114d7e1d610d04dce8e8169f", []).to eq 24_238
    end

    it "can estimate intrinsic gas for access lists" do

      # EIP-2930
      expect(Tx.estimate_intrinsic_gas "", list).to eq 29_600
      expect(Tx.estimate_intrinsic_gas "bf010c80018252088080b8c000000000000000000000000000000000000000000000000000000000000000800000000000000000000000003ea1e26a2119b038eaf9b27e65cdb401502ae7a43d8bfb1368aee2693eb325af9f81244b19304b087b4941a1e892da50bd48dfe1f6d17aad7aff1c87e8481f30395a1595a07b483032affed044e698bf7c43a6fe000000000000000000000000000000000000000000000000000000000000000d4c6f72656d2c20497073756d210000000000000000000000000000000000000026a0e06be7a71c58beebfae09372083865f49fbacb6dfd93f10329f2ca925057fba3a0036c90afd27ea5d2383e319f7091aa23d3e77b09114d7e1d610d04dce8e8169f", list).to eq 32_838
    end

    it "can estimate intrinsic gas for initcode" do

      # EIP-3860
      expect(Tx.estimate_intrinsic_gas "5f").to eq 21_018
      expect(Tx.estimate_intrinsic_gas "60406080815234610104575f5b601f8110610022575051610be090816101098239f35b6020808210156100c0576021820154835182810182905280850191909152838152606080820191906001600160401b038311828410176100f05782865281515f5b8181106100de5750918493915f8094830191820152039060025afa156100d4575f5190600183018084116100ac5710156100c05760228201555f1981146100ac5760010161000c565b634e487b7160e01b5f52601160045260245ffd5b634e487b7160e01b5f52603260045260245ffd5b82513d5f823e3d90fd5b83810180870151908401528501610063565b634e487b7160e01b5f52604160045260245ffd5b5f80fdfe6080604081815260049182361015610015575f80fd5b5f92833560e01c91826301ffc9a7146102685750816322895118146101ea57508063621fd130146101a95763c5f2892f1461004e575f80fd5b346101a557816003193601126101a557818060209384918483548084905b8682106100f4575050906100c4605861009267ffffffffffffffff6100d4969516610ab1565b876100af85519586938385019889528051938492860191016102f1565b8101878b820152036038810184520182610389565b86519283928392519283916102f1565b8101039060025afa156100e957519051908152f35b9051903d90823e3d90fd5b92509294909360019586808516145f1461016a57610138908554908a51908582019283528b8201528a815261012881610359565b8a519283928392519283916102f1565b8101039060025afa1561016057610154908551945b1c91610337565b8492869188959361006c565b85513d86823e3d90fd5b61018c9085602101548a51908582019283528b8201528a815261012881610359565b8101039060025afa15610160576101549085519461014d565b5080fd5b50346101a557816003193601126101a5576101e6906101d367ffffffffffffffff60205416610ab1565b9051918291602083526020830190610312565b0390f35b839060803660031901126101a55767ffffffffffffffff81358181116102645761021790369084016102bf565b6024929192358281116102605761023190369086016102bf565b909260443590811161025c576102599561024d913691016102bf565b939092606435956103cb565b80f35b8680fd5b8580fd5b8380fd5b8491346102bb5760203660031901126102bb573563ffffffff60e01b81168091036102bb57602092506301ffc9a760e01b81149081156102aa575b5015158152f35b638564090760e01b149050836102a3565b8280fd5b9181601f840112156102ed5782359167ffffffffffffffff83116102ed57602083818601950101116102ed57565b5f80fd5b5f5b8381106103025750505f910152565b81810151838201526020016102f3565b9060209161032b815180928185528580860191016102f1565b601f01601f1916010190565b5f1981146103455760010190565b634e487b7160e01b5f52601160045260245ffd5b6060810190811067ffffffffffffffff82111761037557604052565b634e487b7160e01b5f52604160045260245ffd5b90601f8019910116810190811067ffffffffffffffff82111761037557604052565b908060209392818452848401375f828201840152601f01601f1916010190565b919694929695939560308203610a5d576020978881036109f957606085036109a257670de0b6b3a7640000341061094e57633b9aca008034066108ed5734049767ffffffffffffffff988981116108985790898b96959493921661042e90610ab1565b9186549a8b1661043d90610ab1565b976040988951809160a0825260a08201610458908a8c6103ab565b8281038c84015261046a90868a6103ab565b8281038d84015261047b9088610312565b828103606084015261048e9085886103ab565b828103608084015261049f91610312565b037f649bbc62d0e31342afea4e5cd82d4049e7e1ee912fc0889aa790803be39038c591a188519c868e97828901998a3787015f9e8f98828a8581950152036010810182526030016104f09082610389565b8b51998a9151809b610501926102f1565b8060029a810103908a5afa1561088457855192818a1161025c57888761054c8c8051848101918087843784606083015280825261053d82610359565b519283928392519283916102f1565b810103908b5afa1561088e578661059d8b8b9361058d84519683519287840194603f19830191018537820182601f1991878382015203908101835282610389565b8d519283928392519283916102f1565b810103908a5afa1561088457856105da899282518c51908582019283528d8201528c81526105ca81610359565b8c519283928392519283916102f1565b81010390895afa1561087a57610618879286926101288b8551988382519485928a840197885284840137810187838201520387810184520182610389565b81010390875afa156108705782610675869282519461066560588b5180938861064a81840197888151938492016102f1565b820190888a8301526038820152036038810184520182610389565b89519283928392519283916102f1565b81010390865afa1561086457906106b284928251875190858201928352888201528781526106a281610359565b87519283928392519283916102f1565b81010390845afa1561085a5786519384036107d45763ffffffff861015610787576001958681018091116107735780835587945b83861061070157634e487b7160e01b89526004889052602489fd5b8780831614610767578861073c85928854908851908582019283528982015288815261072c81610359565b88519283928392519283916102f1565b81010390855afa1561075d57610756885191881c95610337565b94906106e6565b83513d89823e3d90fd5b96505050505090925055565b634e487b7160e01b88526011600452602488fd5b50608491519062461bcd60e51b82526004820152602160248201527f4465706f736974436f6e74726163743a206d65726b6c6520747265652066756c6044820152601b60fa1b6064820152fd5b5060a491519062461bcd60e51b82526004820152605460248201527f4465706f736974436f6e74726163743a207265636f6e7374727563746564204460448201527f65706f7369744461746120646f6573206e6f74206d6174636820737570706c6960648201527319590819195c1bdcda5d17d9185d1857dc9bdbdd60621b6084820152fd5b82513d88823e3d90fd5b508351903d90823e3d90fd5b85513d84823e3d90fd5b87513d86823e3d90fd5b88513d87823e3d90fd5b89513d88823e3d90fd5b60405162461bcd60e51b8152600481018c9052602760248201527f4465706f736974436f6e74726163743a206465706f7369742076616c756520746044820152660dede40d0d2ced60cb1b6064820152608490fd5b60405162461bcd60e51b8152600481018b9052603360248201527f4465706f736974436f6e74726163743a206465706f7369742076616c7565206e6044820152726f74206d756c7469706c65206f66206777656960681b6064820152608490fd5b60405162461bcd60e51b8152600481018a9052602660248201527f4465706f736974436f6e74726163743a206465706f7369742076616c756520746044820152656f6f206c6f7760d01b6064820152608490fd5b60405162461bcd60e51b8152600481018a9052602960248201527f4465706f736974436f6e74726163743a20696e76616c6964207369676e6174756044820152680e4ca40d8cadccee8d60bb1b6064820152608490fd5b60405162461bcd60e51b8152600481018a9052603660248201527f4465706f736974436f6e74726163743a20696e76616c696420776974686472616044820152750eec2d8bec6e4cac8cadce8d2c2d8e640d8cadccee8d60531b6064820152608490fd5b60405162461bcd60e51b815260206004820152602660248201527f4465706f736974436f6e74726163743a20696e76616c6964207075626b6579206044820152650d8cadccee8d60d31b6064820152608490fd5b906040516040810181811067ffffffffffffffff8211176103755760405260088152602081016020368237819367ffffffffffffffff60c01b9060c01b1690825115610b96578160071a9053815160011015610b96578060061a6021830153815160021015610b96578060051a6022830153815160031015610b9657600481811a60238401538251811015610b83578160031a6024840153825160051015610b83578160021a6025840153825160061015610b83578160011a6026840153825160071015610b8357505f1a9060270153565b603290634e487b7160e01b5f525260245ffd5b634e487b7160e01b5f52603260045260245ffdfea26469706673582212200584f7fb382c7d9bfcca41cab149ea1be65871bb543ccee53cc9834690ff28a764736f6c63430008140033").to eq 73_800
    end
  end

  describe ".santize_list" do
    subject(:sane) {
      [
        [
          Util.hex_to_bin("de0b295669a9fd93d5f28d9ec85e40f4cb697bae"),
          [
            Util.hex_to_bin("0000000000000000000000000000000000000000000000000000000000000003"),
            Util.hex_to_bin("0000000000000000000000000000000000000000000000000000000000000007"),
          ],
        ],
        [
          Util.hex_to_bin("bb9bc244d798123fde783fcc1c72d3bb8c189413"),
          [],
        ],
      ]
    }

    it "can convert access lists from hex to bin" do
      expect(Tx.sanitize_list list).to eq sane
    end
  end

  describe ".decode .unsigned_copy" do
    it "does recognize unknown transaction types" do
      raw = "bf010c80018252088080b8c000000000000000000000000000000000000000000000000000000000000000800000000000000000000000003ea1e26a2119b038eaf9b27e65cdb401502ae7a43d8bfb1368aee2693eb325af9f81244b19304b087b4941a1e892da50bd48dfe1f6d17aad7aff1c87e8481f30395a1595a07b483032affed044e698bf7c43a6fe000000000000000000000000000000000000000000000000000000000000000d4c6f72656d2c20497073756d210000000000000000000000000000000000000026a0e06be7a71c58beebfae09372083865f49fbacb6dfd93f10329f2ca925057fba3a0036c90afd27ea5d2383e319f7091aa23d3e77b09114d7e1d610d04dce8e8169f"
      expect { Tx.decode raw }.to raise_error Tx::TransactionTypeError, "Cannot decode unknown transaction type 191!"
    end

    it "can decode transactions with v > 255" do

      # ref https://ethereum.stackexchange.com/questions/38650/field-size-and-value-range-of-chainid-eip-155
      raw = "0xf86e820678850430e2340083015f9094ad322de69695859fc84f32d0f42c3802fe1018438501dcd650008082266ea027caed8171ad1857ff259554614152cda78949adda001e24472f84840bca5cd6a04a5f557baae23ce45c97b71363ea8da6740ac2652bd02b7f94b18cae62d7905a"
      tx = Tx.decode raw
      expect(tx.sender).to eq Util.remove_hex_prefix Address.new("0x90f8bf6a479f320ead074411a4b0e7944ea8c9c1").to_s
      expect(tx.destination).to eq Util.remove_hex_prefix "0xad322de69695859fc84f32d0f42c3802fe101843"
      expect(tx.amount).to eq 8000000000
      expect(tx.hash).to eq Util.remove_hex_prefix "0xa0f67799bca1f633f66567455aaeff0728cb72c78d3fff9af0875d4918356c8c"
      expect(tx.signature_v).to eq "266e"
      expect(tx.chain_id).to eq 4901
    end
  end

  describe ".decode transaction with small s" do
    it "transaction with s with length 62" do
      raw = "0xf86b820e8485012a05f200831e848094ffe811714ab35360b67ee195ace7c10d93f89d8c80844e71d92d8194a07b8f34a8fb85d850b3be4fc0330382e125e4216df5598c6d2c3bc47954684cf99f35ef53ee007c2f705eca91448b5c86e81d10f659ad868409bac8197bba9814"
      tx = Tx.decode raw
      expect(tx.sender).to eq Util.remove_hex_prefix Address.new("f39Fd6e51aad88F6F4ce6aB8827279cffFb92266").to_s
      expect(tx.destination).to eq Util.remove_hex_prefix "0xffe811714ab35360b67ee195ace7c10d93f89d8c"
      expect(tx.amount).to eq 0
      expect(tx.hash).to eq Util.remove_hex_prefix "0x061bff624de0bdd20f557c02b6fbab92ca436871ff31f69ffdd6dc830a8e9709"
      expect(tx.signature_v).to eq "94"
      expect(tx.chain_id).to eq 56
    end
  end

  describe '.decode an unsigned transaction' do
    it "keeps the 'from' field blank" do
      raw = "0x02f0050584b2d05e00851010b872008303841494caedbd63fb25c3126bfe96c1af208e4688e9817e87f6a3d9c63df00080c0"
      tx = Tx.decode raw

      expect(tx.signature_y_parity).to eq nil
      expect(tx.signature_r).to eq 0
      expect(tx.signature_s).to eq 0

      expect(tx.sender).to eq ""
    end
  end
end
