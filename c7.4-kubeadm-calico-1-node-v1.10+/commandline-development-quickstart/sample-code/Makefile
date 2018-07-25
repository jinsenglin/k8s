BINARY_PATH=out/image-changer

all: clean build

build:
	go build -o $(BINARY_PATH) github.com/cclin81922/k8s-image-changer/cmd/image-changer

clean:
	rm -f $(BINARY_PATH)
