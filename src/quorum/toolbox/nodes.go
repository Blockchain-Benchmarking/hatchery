package main


import (
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"os"
	"strconv"
	"strings"
)


// ----------------------------------------------------------------------------


type StaticNode struct {
	Uid []byte
	Ip string
	Port int
	Discport int
}

type StaticNodes struct {
	Nodes []StaticNode
}


func DecodeStaticNodes(reader io.Reader) (*StaticNodes, error) {
	return decodeStaticNodes(reader)
}

func ReadStaticNodes(path string) (*StaticNodes, error) {
	return readStaticNodes(path)
}


func (this *StaticNodes) Encode(writer io.Writer) error {
	return this.encode(writer)
}

func (this *StaticNodes) Write(path string) error {
	return this.write(path)
}


// ----------------------------------------------------------------------------


func decodeStaticNodes(reader io.Reader) (*StaticNodes, error) {
	var decoder *json.Decoder
	var this StaticNodes
	var err error
	
	decoder = json.NewDecoder(reader)

	err = decoder.Decode(&this.Nodes)
	if err != nil {
		return nil, err
	}

	return &this, nil
}

func readStaticNodes(path string) (*StaticNodes, error) {
	var file *os.File
	var err error

	file, err = os.Open(path)
	if err != nil {
		return nil, err
	}

	defer file.Close()

	return decodeStaticNodes(file)
}

//  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

func (this *StaticNodes) encode(writer io.Writer) error {
	var encoder *json.Encoder
	var err error

	encoder = json.NewEncoder(writer)
	encoder.SetIndent("", " ")

	err = encoder.Encode(this.Nodes)
	if err != nil {
		return err
	}

	return nil
}

func (this *StaticNodes) write(path string) error {
	var file *os.File
	var err error

	file, err = os.Create(path)
	if err != nil {
		return err
	}

	defer file.Close()

	return this.encode(file)
}


// ----------------------------------------------------------------------------


func (this *StaticNode) MarshalJSON() ([]byte, error) {
	var str string

	str = fmt.Sprintf("enode://%s@%s@%d?discport=%d",
		hex.EncodeToString(this.Uid),
		this.Ip,
		this.Port,
		this.Discport,
	)

	return json.Marshal(str)
}

func (this *StaticNode) UnmarshalJSON(data []byte) error {
	var str, parsed string
	var parts []string
	var err error

	err = json.Unmarshal(data, &str)
	if err != nil {
		return err
	}

	var defaultErr = fmt.Errorf("invalid static node data '%s'", str)

	if strings.HasPrefix(str, "enode://") {
		parsed = strings.TrimPrefix(str, "enode://")
	} else {
		return defaultErr
	}

	parts = strings.FieldsFunc(parsed, func (c rune) bool {
		return (c == '@') || (c == ':') || (c == '?')
	})

	if len(parts) != 4 {
		return defaultErr
	}

	this.Uid, err = hex.DecodeString(parts[0])
	if err != nil {
		return err
	}

	this.Ip = parts[1]

	this.Port, err = strconv.Atoi(parts[2])
	if err != nil {
		return err
	}

	if strings.HasPrefix(parts[3], "discport=") {
		parts[3] = strings.TrimPrefix(parts[3], "discport=")
		this.Discport, err = strconv.Atoi(parts[3])
		if err != nil {
			return err
		}
	} else {
		return defaultErr
	}

	return nil
}
