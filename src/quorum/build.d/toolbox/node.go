package main

import (
	"fmt"
	"strconv"
	"strings"
)


// ----------------------------------------------------------------------------


type Node struct {
	path string
	nodes *StaticNodes
	genesis *Genesis
}

func NewNode(path string) (*Node, error) {
	return newNode(path)
}

func (this *Node) Configure(addrs []string) error {
	return this.configure(addrs)
}



// ----------------------------------------------------------------------------


func newNode(path string) (*Node, error) {
	var this Node
	var err error

	this.path = path

	this.nodes, err = ReadStaticNodes(this.staticNodesPath())
	if err != nil {
		return nil, err
	}

	this.genesis, err = ReadGenesis(this.genesisPath())
	if err != nil {
		return nil, err
	}

	return &this, nil
}

func (this *Node) configure(addrs []string) error {
	var addr, host string
	var index, port int
	var parts []string
	var err error

	if len(addrs) != len(this.nodes.Nodes) {
		return fmt.Errorf("invalid number of addr: get %, expect %d",
			len(addrs), len(this.nodes.Nodes))
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

		this.nodes.Nodes[index].Ip = host
		this.nodes.Nodes[index].Port = port
	}

	return this.nodes.Write(this.staticNodesPath())
}

func (this *Node) staticNodesPath() string {
	return this.path + "/static-nodes.json"
}

func (this *Node) genesisPath() string {
	return this.path + "/genesis.json"
}

func (this *Node) nodekeyPath() string {
	return this.path + "/nodekey"
}
