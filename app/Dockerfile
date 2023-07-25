#'binary' stage does the go build and create a binary named "main"
FROM golang:1.20.6-alpine3.18 as binary
WORKDIR /app
COPY ./main.go .
RUN go build main.go

#below stage copies binary from 'binary' stage and runs it
FROM alpine:3.18
COPY --from=binary /app/main main
CMD ["./main"]