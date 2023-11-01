package main


import (
	"fmt"
	"math/big"
	"os"
	"os/exec"
	"strconv"
	"strings"

	"github.com/gochain/web3"
)


// ----------------------------------------------------------------------------


type Asset struct {
	path string
}


func LoadAsset(path string) (*Asset, error) {
	return loadAsset(path)
}

func CreateAsset(path string, n int) (*Asset, error) {
	return createAsset(path, n)
}


func (this *Asset) SetServers(addrs []string) error {
	return this.setServers(addrs)
}


func (this *Asset) AddAccounts(n int, balance *big.Int) error {
	return this.addAccounts(n, balance)
}

func (this *Asset) GetAccounts() ([]Account, error) {
	return this.getAccounts()
}

//  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

type Account struct {
	skey string
	pkey string
}

func (this *Account) PrivateKey() string {
	return this.skey
}

func (this *Account) PublicKey() string {
	return this.pkey
}


// ----------------------------------------------------------------------------


func loadAsset(path string) (*Asset, error) {
	var staticNodes *StaticNodes
	var file *os.File
	var this Asset
	var index int
	var err error

	this.path = path

	staticNodes, err = ReadStaticNodes(this.staticNodesPath())
	if err != nil {
		return nil, err
	}

	for index = range staticNodes.Nodes {
		file, err = os.Open(this.nodekeyPath(index))
		if err != nil {
			return nil, err
		}

		file.Close()
	}

	_, err = ReadGenesis(this.genesisPath())
	if err != nil {
		return nil, err
	}

	_, err = ReadAccounts(this.accountsPath())
	if err != nil {
		return nil, err
	}

	return &this, nil
}

func createAsset(path string, n int) (*Asset, error) {
	var cmd *exec.Cmd
	var this Asset
	var err error

	err = os.Mkdir(path, 0700)
	if err != nil {
		return nil, err
	}

	this.path = path

	err = os.Mkdir(this.serversPath(), 0700)
	if err != nil {
		return nil, err
	}

	err = os.Mkdir(this.clientsPath(), 0700)
	if err != nil {
		return nil, err
	}

	cmd = exec.Command("istanbul", "setup",
		"--num", fmt.Sprintf("%d", n), "--nodes", "--quorum",
		"--save", "--verbose",
	)

	cmd.Dir = path

	err = cmd.Run()
	if err != nil {
		return nil, err
	}

	err = os.Rename(fmt.Sprintf("%s/genesis.json", path),
		this.genesisPath())
	if err != nil {
		return nil, err
	}

	err = os.Rename(fmt.Sprintf("%s/static-nodes.json", path),
		this.staticNodesPath())
	if err != nil {
		return nil, err
	}

	return &this, nil
}

//  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

func (this *Asset) setServers(addrs []string) error {
	var staticNodes *StaticNodes
	var addr, host string
	var index, port int
	var parts []string
	var err error

	staticNodes, err = ReadStaticNodes(this.staticNodesPath())
	if err != nil {
		return err
	}

	if len(addrs) != len(staticNodes.Nodes) {
		return fmt.Errorf("invalid number of addr: get %, expect %d",
			len(addrs), len(staticNodes.Nodes))
	}

	for index, addr = range addrs {
		parts = strings.Split(addr, ":")

		if len(parts) != 2 {
			return fmt.Errorf("invalid addr operand '%s'", addr)
		}

		host = parts[0]

		port, err = strconv.Atoi(parts[1])
		if err != nil {
			return err
		}

		staticNodes.Nodes[index].Ip = host
		staticNodes.Nodes[index].Port = port
	}

	return staticNodes.Write(this.staticNodesPath())
}

//  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

func (this *Asset) addAccounts(n int, balance *big.Int) error {
	var account *web3.Account
	var accounts *Accounts
	var skey, pkey string
	var genesis *Genesis
	var err error
	var i int

	accounts, err = ReadAccounts(this.accountsPath())
	if err != nil {
		return err
	}

	genesis, err = ReadGenesis(this.genesisPath())
	if err != nil {
		return err
	}

	for i = 0; i < n; i++ {
		account, err = web3.CreateAccount()
		if err != nil {
			return nil
		}

		skey = account.PrivateKey()
		skey = strings.TrimPrefix(skey, "0x")
		skey = strings.ToLower(skey)
		accounts.PrivateKeys = append(accounts.PrivateKeys, skey)

		pkey = account.PublicKey()
		pkey = strings.TrimPrefix(pkey, "0x")
		pkey = strings.ToLower(pkey)
		genesis.Alloc[pkey] = GenesisAlloc { 
			Balance: BigInt { balance },
		}
	}

	err = accounts.Write(this.accountsPath())
	if err != nil {
		return err
	}

	err = genesis.Write(this.genesisPath())
	if err != nil {
		return err
	}

	return nil
}

func (this *Asset) getAccounts() ([]Account, error) {
	var account *web3.Account
	var accounts *Accounts
	var skey, pkey string
	var ret []Account
	var err error

	accounts, err = ReadAccounts(this.accountsPath())
	if err != nil {
		return nil, err
	}

	for _, skey = range accounts.PrivateKeys {
		account, err = web3.ParsePrivateKey("0x" + skey)
		if err != nil {
			return nil, err
		}

		pkey = account.PublicKey()
		pkey = strings.TrimPrefix(pkey, "0x")
		pkey = strings.ToLower(pkey)

		ret = append(ret, Account{ skey, pkey })
	}
	
	return ret, nil
}

//  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

func (this *Asset) serversPath() string {
	return fmt.Sprintf("%s/servers", this.path)
}

func (this *Asset) clientsPath() string {
	return fmt.Sprintf("%s/clients", this.path)
}

func (this *Asset) serverPath(index int) string {
	return fmt.Sprintf("%s/%d", this.path, index)
}

func (this *Asset) genesisPath() string {
	return fmt.Sprintf("%s/genesis.json", this.serversPath())
}

func (this *Asset) staticNodesPath() string {
	return fmt.Sprintf("%s/static-nodes.json", this.serversPath())
}

func (this *Asset) nodekeyPath(index int) string {
	return fmt.Sprintf("%s/nodekey", this.serverPath(index))
}

func (this *Asset) accountsPath() string {
	return fmt.Sprintf("%s/accounts.txt", this.clientsPath())
}
