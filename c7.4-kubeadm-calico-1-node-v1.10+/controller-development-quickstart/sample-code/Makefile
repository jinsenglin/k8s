BINARY_PATH=out/pod-monitor

all: clean build

build:
	go build -o $(BINARY_PATH) github.com/cclin81922/k8s-pod-monitor/cmd/pod-monitor

clean:
	rm -f $(BINARY_PATH)
