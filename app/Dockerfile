#'binary' stage does the go build and create a binary named "main"
FROM golang:1.20.6-alpine3.18 as binary
WORKDIR /app
COPY /app/main.go .
RUN go build main.go

#below stage copies binary from 'binary' stage and runs it, here it uses 'gopher' user.
FROM alpine:3.18
RUN adduser -D gopher 
USER gopher
COPY --from=binary /app/main main
CMD ["./main"]