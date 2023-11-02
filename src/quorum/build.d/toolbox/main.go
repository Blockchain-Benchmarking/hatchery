package main


import (
	"bufio"
	"flag"
	"fmt"
	"io/ioutil"
	"math/big"
	"os"
	"strings"
)


//  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

func doNew(path string, size int) error {
	var tmpdir string
	var err error

	tmpdir, err = ioutil.TempDir("", "asset")
	if err != nil {
		return err
	}

	defer os.RemoveAll(tmpdir)

	_, err = CreateAsset(tmpdir + "/asset", size)
	if err != nil {
		return err
	}

	return os.Rename(tmpdir + "/asset", path)
	
	return nil
}

func mainNew(args []string) {
	var flags *flag.FlagSet = flag.NewFlagSet("", flag.PanicOnError)
	var size *int = flags.Int("s", 4, "size of the committee")
	var err error

	err = flags.Parse(args)
	if err != nil {
		panic(err)
	}

	args = flags.Args()

	if len(args) < 1 {
		panic("missing 'asset' operand")
	} else if len(args) > 1 {
		panic(fmt.Sprintf("unexpected operand '%s'", args[1]))
	}

	if *size <= 0 {
		panic(fmt.Sprintf("invalid -s option '%d'", *size))
	}

	err = doNew(args[0], *size)
	if err != nil {
		panic(err)
	}
}

//  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

func doSetServers(path string) error {
	var scanner *bufio.Scanner
	var addrs []string
	var asset *Asset
	var addr string
	var err error

	asset, err = LoadAsset(path)
	if err != nil {
		return err
	}

	scanner = bufio.NewScanner(os.Stdin)

	for scanner.Scan() {
		addr = scanner.Text()
		addrs = append(addrs, addr)
	}

	err = asset.SetServers(addrs)
	if err != nil {
		return err
	}

	return nil
}

func mainSetServers(args []string) {
	var err error

	if len(args) < 1 {
		panic("missing 'asset' operand")
	} else if len(args) > 1 {
		panic(fmt.Sprintf("unexpected operand '%s'", args[1]))
	}

	err = doSetServers(args[0])
	if err != nil {
		panic(err)
	}
}

//  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

func doAddAccounts(path string, accounts int, balance *big.Int) error {
	var asset *Asset
	var err error

	asset, err = LoadAsset(path)
	if err != nil {
		return err
	}

	err = asset.AddAccounts(accounts, balance)
	if err != nil {
		return err
	}
	
	return nil
}

func mainAddAccounts(args []string) {
	var flags *flag.FlagSet = flag.NewFlagSet("", flag.PanicOnError)
	var accounts *int = flags.Int("a", 1, "number of accounts")
	var strbalance *string = flags.String("b",
		"0x446c3b15f9926687d2c40534fdb564000000000000",
		"balance of accounts")
	var balance *big.Int
	var valid bool
	var err error

	err = flags.Parse(args)
	if err != nil {
		panic(err)
	}

	args = flags.Args()

	if len(args) < 1 {
		panic("missing 'asset' operand")
	} else if len(args) > 1 {
		panic(fmt.Sprintf("unexpected operand '%s'", args[1]))
	}

	if *accounts < 0 {
		panic(fmt.Sprintf("invalid -a option '%d'", *accounts))
	}

	if strings.HasPrefix(*strbalance, "0x") {
		*strbalance = strings.TrimPrefix(*strbalance, "0x")
		balance = big.NewInt(0)
		_, valid = balance.SetString(*strbalance, 16)
		if valid == false {
			panic(fmt.Sprintf("invalid -b option '0x%s'",
				*strbalance))
		}
	} else {
		balance = big.NewInt(0)
		_, valid = balance.SetString(*strbalance, 10)
		if valid == false {
			panic(fmt.Sprintf("invalid -b option '%s'",
				*strbalance))
		}
	}

	err = doAddAccounts(args[0], *accounts, balance)
	if err != nil {
		panic(err)
	}
}

//  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

func doGetAccounts(path string) error {
	var accounts []Account
	var account Account
	var asset *Asset
	var err error

	asset, err = LoadAsset(path)
	if err != nil {
		return err
	}

	accounts, err = asset.GetAccounts()
	if err != nil {
		return err
	}

	for _, account = range accounts {
		fmt.Printf("- address: %s\n  private: %s\n",
			account.PublicKey(), account.PrivateKey())
	}

	return nil
}

func mainGetAccounts(args []string) {
	var err error

	if len(args) < 1 {
		panic("missing 'asset' operand")
	} else if len(args) > 1 {
		panic(fmt.Sprintf("unexpected operand '%s'", args[1]))
	}

	err = doGetAccounts(args[0])
	if err != nil {
		panic(err)
	}
}

//  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

func main() {
	if len(os.Args) < 2 {
		panic(`missing command operand

Syntax: toolbox new [-s <server>] <asset>                                   (1)
        toolbox set-servers <asset>                                         (2)
        toolbox add-accounts [-a <account>] [-b <balance>] <asset>          (3)
        toolbox get-accounts <asset>                                        (4)

`)
	}

	switch (os.Args[1]) {
	case "new":
		mainNew(os.Args[2:])
	case "set-servers":
		mainSetServers(os.Args[2:])
	case "add-accounts":
		mainAddAccounts(os.Args[2:])
	case "get-accounts":
		mainGetAccounts(os.Args[2:])
	default:
		panic(fmt.Sprintf("unknown command '%s'", os.Args[1]))
	}
}



// Network asset structure
//
//     /
//     |- servers/
//     |- clients/
//     |- 0/
//     |- ...
//     `- 3/
