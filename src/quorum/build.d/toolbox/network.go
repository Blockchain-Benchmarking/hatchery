package main

import (
	"fmt"
	"os"
	"os/exec"
)


// ----------------------------------------------------------------------------


type Network struct {
	path string
	size int
}


func CreateNetwork(path string, size int) (*Network, error) {
	return createNetwork(path, size)
}

func (this *Network) IntoAsset(path string) error {
	return this.intoAsset(path)
}


// ----------------------------------------------------------------------------


func createNetwork(path string, size int) (*Network, error) {
	var cmd *exec.Cmd
	var this Network
	var err error

	err = os.Mkdir(path, 0700)
	if err != nil {
		return nil, err
	}

	cmd = exec.Command(
		"istanbul", "setup", "--num", fmt.Sprintf("%d", size),
		"--nodes", "--quorum", "--save", "--verbose",
	)

	cmd.Dir = path

	err = cmd.Run()
	if err != nil {
		return nil, err
	}

	this.path = path
	this.size = size

	_, err = ReadStaticNodes(this.staticNodesPath())
	if err != nil {
		return nil, err
	}

	_, err = ReadGenesis(this.genesisPath())
	if err != nil {
		return nil, err
	}


	return &this, nil
}

func (this *Network) intoAsset(path string) error {
	var asset *asset
	var err error

	asset, err = createAsset(path, this.size)
	if err != nil {
		return err
	}

	err = os.Rename(this.staticNodesPath(), asset.staticNodesPath())
	if err != nil {
		return err
	}

	err = os.Rename(this.genesisPath(), asset.genesisPath())
	if err != nil {
		return err
	}

	for i := 0; i < this.size; i++ {
		err = os.Rename(this.nodekeyPath(i), asset.nodekeyPath(i))
		if err != nil {
			return err
		}
	}

	err = os.RemoveAll(this.path)
	if err != nil {
		return err
	}

	return nil
}

func (this *Network) staticNodesPath() string {
	return this.path + "/static-nodes.json"
}

func (this *Network) genesisPath() string {
	return this.path + "/genesis.json"
}

func (this *Network) nodekeyPath(index int) string {
	return fmt.Sprintf("%s/%d/nodekey", this.path, index)
}

//  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

type asset struct {
	path string
	size int
}

func createAsset(path string, size int) (*asset, error) {
	var this asset
	var err error

	err = os.Mkdir(path, 0700)
	if err != nil {
		return nil, err
	}

	err = os.Mkdir(path + "/all", 0700)
	if err != nil {
		return nil, err
	}

	for i := 0; i < size; i++ {
		err = os.Mkdir(fmt.Sprintf("%s/%d", path, i), 0700)
		if err != nil {
			return nil, err
		}
	}

	this.path = path
	this.size = size

	return &this, nil
}

func (this *asset) staticNodesPath() string {
	return this.path + "/all/static-nodes.json"
}

func (this *asset) genesisPath() string {
	return this.path + "/all/genesis.json"
}

func (this *asset) nodekeyPath(index int) string {
	return fmt.Sprintf("%s/%d/nodekey", this.path, index)
}
