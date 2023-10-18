package main


import (
	"flag"
	"fmt"
	"io/ioutil"
	"os"
)


func doCreateNetwork(path string, size int) error {
	var tmpdir string
	var net *Network
	var err error

	tmpdir, err = ioutil.TempDir("", "network")
	if err != nil {
		return err
	}

	defer os.RemoveAll(tmpdir)

	net, err = CreateNetwork(tmpdir + "/network", size)
	if err != nil {
		return err
	}

	err = net.IntoAsset(tmpdir + "/asset")
	if err != nil {
		return err
	}

	return os.Rename(tmpdir + "/asset", path)
}

func mainCreateNetwork(args []string) {
	var flags *flag.FlagSet = flag.NewFlagSet("", flag.PanicOnError)
	var size *int = flags.Int("s", 4, "size of the committee")
	var err error

	err = flags.Parse(args)
	if err != nil {
		panic(err)
	}

	args = flags.Args()

	if len(args) < 1 {
		panic("missing destination path operand")
	} else if len(args) > 1 {
		panic(fmt.Sprintf("unexpected operand '%s'", args[1]))
	}

	if *size <= 0 {
		panic(fmt.Sprintf("invalid -s option '%d'", *size))
	}

	err = doCreateNetwork(args[0], *size)
	if err != nil {
		panic(err)
	}
}


func configNode(path string, addrs []string) error {
	var node *Node
	var err error

	node, err = NewNode(path)
	if err != nil {
		return err
	}

	err = node.Configure(addrs)
	if err != nil {
		return err
	}

	return nil
}

func mainConfigNode(args []string) {
	var err error

	if len(args) < 1 {
		panic("missing path operand")
	}

	err = configNode(args[0], args[1:])
	if err != nil {
		panic(err)
	}
}


func main() {
	if len(os.Args) < 2 {
		panic(`missing command operand

Syntax: toolbox create-network [-s <size>] <path>    (1)
        toolbox config-node <path> <addrs...>        (2)

(1) Create a network asset in the given <path> directory.
    By default, create a network of size 4.
    This behavior can be changed with option '-s'.

(2) Configure the network node asset in the given <path> directory to be part
    of a network composed of nodes with the given <addrs...>.
`)
	}

	switch (os.Args[1]) {
	case "create-network":
		mainCreateNetwork(os.Args[2:])
	case "config-node":
		mainConfigNode(os.Args[2:])
	default:
		panic(fmt.Sprintf("unknown command '%s'", os.Args[1]))
	}
}
