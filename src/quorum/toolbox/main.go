package main


import (
	"flag"
	"fmt"
	"io/ioutil"
	"os"
)


func newArtifact(path string, size int) error {
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

	err = net.IntoArtifact(tmpdir + "/artifact")
	if err != nil {
		return err
	}

	return os.Rename(tmpdir + "/artifact", path)
}

func mainNewArtifact(args []string) {
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

	err = newArtifact(args[0], *size)
	if err != nil {
		panic(err)
	}
}

func main() {
	if len(os.Args) < 2 {
		panic("missing command operand")
	}

	switch (os.Args[1]) {
	case "new-artifact":
		mainNewArtifact(os.Args[2:])
	default:
		panic(fmt.Sprintf("unknown command '%s'", os.Args[1]))
	}
}
