FROM golang:1.10.1-alpine3.7 as builder 
COPY . /go/src/github.com/cclin81922/k8s-pod-monitor/
RUN go build -o /app github.com/cclin81922/k8s-pod-monitor/cmd/pod-monitor

FROM alpine:3.7 
CMD ["./app"] 
COPY --from=builder /app .
