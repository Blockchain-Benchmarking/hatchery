package main

import (
	"encoding/hex"
	"encoding/json"
	"fmt"
	"math/big"
	"strings"
)


// ----------------------------------------------------------------------------


type BigInt struct {
	*big.Int
}

type HexString struct {
	Data []byte
}


// ----------------------------------------------------------------------------


func (this *BigInt) MarshalJSON() ([]byte, error) {
	return json.Marshal("0x" + this.Text(16))

}

func (this *BigInt) UnmarshalJSON(data []byte) error {
	var str, parsed string
	var valid bool
	var err error

	err = json.Unmarshal(data, &str)
	if err != nil {
		return err
	}

	var defaultErr = fmt.Errorf("invalid int value '%s'", str)

	if strings.HasPrefix(str, "0x") {
		parsed = strings.TrimPrefix(str, "0x")
	} else {
		return defaultErr
	}

	this.Int = big.NewInt(0)

	_, valid = this.SetString(parsed, 16)
	if valid == false {
		return defaultErr
	}

	return nil
}

//  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

func (this *HexString) MarshalJSON() ([]byte, error) {
	return json.Marshal("0x" + hex.EncodeToString(this.Data))

}

func (this *HexString) UnmarshalJSON(data []byte) error {
	var str, parsed string
	var err error

	err = json.Unmarshal(data, &str)
	if err != nil {
		return err
	}

	var defaultErr = fmt.Errorf("invalid hex value '%s'", str)

	if strings.HasPrefix(str, "0x") {
		parsed = strings.TrimPrefix(str, "0x")
	} else {
		return defaultErr
	}

	this.Data, err = hex.DecodeString(parsed)

	return err
}
