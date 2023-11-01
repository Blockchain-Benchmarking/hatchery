export GOPATH := $(CURDIR)/.go/

toolbox: $(wildcard *.go) go.mod go.sum
	go get -v
	go build -o $@ $(wildcard *.go)

.PHONY: clean
clean:
	-chmod -R 700 $(GOPATH)
	-rm -rf toolbox $(GOPATH)
