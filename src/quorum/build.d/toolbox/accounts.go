package main


import (
	"io"
	"os"
	"strings"
)


// ----------------------------------------------------------------------------


type Accounts struct {
	PrivateKeys []string
}


func ReadAccounts(path string) (*Accounts, error) {
	return readAccounts(path)
}

func (this *Accounts) Write(path string) error {
	return this.write(path)
}


// ----------------------------------------------------------------------------


func readAccounts(path string) (*Accounts, error) {
	var file *os.File
	var this Accounts
	var skey string
	var bs []byte
	var err error

	file, err = os.Open(path)
	if err != nil {
		if os.IsNotExist(err) {
			return &this, nil
		} else {
			return nil, err
		}
	}

	bs, err = io.ReadAll(file)
	if err != nil {
		return nil, err
	}

	file.Close()

	for _, skey = range strings.Split(string(bs), "\n") {
		if skey == "" {
			continue
		}

		this.PrivateKeys = append(this.PrivateKeys, skey)
	}

	return &this, nil
}

func (this *Accounts) write(path string) error {
	var file *os.File
	var skey string
	var err error

	file, err = os.Create(path)
	if err != nil {
		return err
	}

	for _, skey = range this.PrivateKeys {
		_, err = io.WriteString(file, skey + "\n")
		if err != nil {
			return err
		}
	}

	file.Close()

	return nil
}
