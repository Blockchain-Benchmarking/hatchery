package main

import (
	"encoding/json"
	"io"
	"os"
)


// ----------------------------------------------------------------------------


type Genesis struct {
	Config     GenesisConfig           `json:"config"`
	Nonce      BigInt                  `json:"nonce"`
	Timestamp  BigInt                  `json:"timestamp"`
	ExtraData  HexString               `json:"extraData"`
	GasLimit   BigInt                  `json:"gasLimit"`
	Difficulty BigInt                  `json:"difficulty"`
	MixHash    HexString               `json:"mixHash"`
	Coinbase   string                  `json:"coinbase"`
	Alloc      map[string]GenesisAlloc `json:"alloc"`
	Number     BigInt                  `json:"number"`
	GasUsed    BigInt                  `json:"gasUsed"`
	ParentHash HexString               `json:"parentHash"`
}

type GenesisConfig struct {
	ChainId             int            `json:"chainId"`
	HomesteadBlock      int            `json:"homesteadBlock"`
	Eip150Block         int            `json:"eip150Block"`
	Eip150Hash          HexString      `json:"eip150Hash"`
	Eip155Block         int            `json:"eip155Block"`
	Eip158Block         int            `json:"eip158Block"`
	ByzantiumBlock      int            `json:"byzantiumBlock"`
	ConstantinopleBlock int            `json:"constantinopleBlock"`
	PetersburgBlock     int            `json:"petersburgBlock"`
	IstanbulBlock       int            `json:"istanbulBlock"`
	Istanbul            IstanbulConfig `json:"istanbul"`
	TxnSizeLimit        int            `json:"txnSizeLimit"`
	MaxCodeSize         int            `json:"maxCodeSize"`
	Qip714Block         int            `json:"qip714Block"`
	IsMPS               bool           `json:"isMPS"`
	IsQuorum            bool           `json:"isQuorum"`
}

type GenesisAlloc struct {
	Balance string `json:"balance"`
}

type IstanbulConfig struct {
	Epoch          int `json:"epoch"`
	Policy         int `json:"policy"`
	Ceil2Nby3Block int `json:"ceil2Nby3Block"`
}


func DecodeGenesis(reader io.Reader) (*Genesis, error) {
	return decodeGenesis(reader)
}

func ReadGenesis(path string) (*Genesis, error) {
	return readGenesis(path)
}


func (this *Genesis) Encode(writer io.Writer) error {
	return this.encode(writer)
}

func (this *Genesis) Write(path string) error {
	return this.write(path)
}



// ----------------------------------------------------------------------------


func decodeGenesis(reader io.Reader) (*Genesis, error) {
	var decoder *json.Decoder
	var this Genesis
	var err error

	decoder = json.NewDecoder(reader)

	err = decoder.Decode(&this)
	if err != nil {
		return nil, err
	}

	return &this, nil
}

func readGenesis(path string) (*Genesis, error) {
	var file *os.File
	var err error

	file, err = os.Open(path)
	if err != nil {
		return nil, err
	}

	defer file.Close()

	return decodeGenesis(file)
}

//  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

func (this *Genesis) encode(writer io.Writer) error {
	var encoder *json.Encoder
	var err error

	encoder = json.NewEncoder(writer)
	encoder.SetIndent("", " ")

	err = encoder.Encode(this)
	if err != nil {
		return err
	}

	return nil
}

func (this *Genesis) write(path string) error {
	var file *os.File
	var err error

	file, err = os.Create(path)
	if err != nil {
		return err
	}

	defer file.Close()

	return this.encode(file)
}
