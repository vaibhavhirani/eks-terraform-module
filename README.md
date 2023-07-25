# particle41-challenge
A  minimalistic Golang server returns timestamp &amp; IP. Terraform modules to deploy VPC &amp; EKS.


## Go App Server
### Brief
- App Server written in Golang, serves at port 8080. You can find the code at app/main.go.
- Currently it serves only one endpoint - "/", when endpoint is hit with a http request then it responds with current timestamp and IP address of the client.
- By default listens at port 8080 and will return response for any path matching "/" as prefix.

### How to Build & Run
1. Install go for your os from here - https://go.dev/doc/install. Current code is written with regards to go1.20.6 (recommended).
2. Go to app directory (`cd app/`), you have two ways to start the app server
    1. do `go build main.go`, it will create an executable. Depending on your OS, you'll have to run binary accordingly
        - MAC - `chmod +x ./main` then `./main`
        - Linux - `chmod +x ./main` then `./main`
        - Windows - `./main.exe`
    2. just run the go code using this command `go run main.go`.
3. And Voila, App server should be running at http://127.0.0.1:8080/ or localhost:8080/

4. Try it out - Paste either of these - http://127.0.0.1:8080/ or localhost:8080/ in the urlbox of your browser  and it wil return output similar to following
    ```
    {
    "ip": "192.168.65.4:57308",
    "timestamp": "2023-07-25 21:54:07.566179008 +0530 IST m=+11.019026926"
    }
    ```

## Docker Image
### Brief
- Dockerfile is at app/Dockerfile.
- Dockerfile is divided into two stages.
    - First stage build the code with golang:1.20.6-alpine3.18 as BASE IMAGE, this stage generates binary executable.
    - Second stage is alpine based, copies binary from earlier stage and runs it as non-root user.

### How to run docker image
1. Make sure your docker daemon is running.
2. Pull the docker image - `docker pull vabsdocker/simple_time_service:1.0.0`
3. Run it with this command - `docker run -p 8080:8080 vabsdocker/simple_time_service:1.0.0`
4. Try it out - Paste either of these - http://127.0.0.1:8080/ or localhost:8080/ in the urlbox of your browser  and it wil return output similar to following
    ```
    {
    "ip": "192.168.65.4:57308",
    "timestamp": "2023-07-25 21:54:07.566179008 +0530 IST m=+11.019026926"
    }
    ```

## Kubernetes Deployment (Uses Docker Desktop Enabled Kubernetes Cluster)
### Brief
- Kubernetes deployment file is at app/microservice.
- File contains 
    - A Deployment of `vabsdocker/simple_time_service:1.0.0` into kubernetes cluster
    - and A Node Port service, which exposes the deployment on port no 30000 on your host machine.
### How to apply kubernetes yaml
1. Make sure your kubernetes cluster is up and running. Enable your kubernetes cluster from docker desktop - Open Docker Desktop > Settings > Kubernetes > Check the `Enable Kubernetes` Button > Apply & Restart  
2. Go to app/ folder (`cd app/`), apply the yaml file to your cluster using this command `kubectl apply -f microservice.yaml`
