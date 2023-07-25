# particle41-challenge
A  minimalistic Golang server returns timestamp &amp; IP. Terraform modules to deploy VPC &amp; EKS.

## Go Server
- By default listens at port 8080 and will return response for any path matching "/" as prefix.
- Example request : Paste either of these in the urlbox in your browser http://127.0.0.1:8080/ or localhost:8080/ and it wil return output similar to following
    ```
    {
    "ip": "[::1]:50674",
    "timestamp": "2023-07-25 21:54:07.566179008 +0530 IST m=+11.019026926"
    }
    ```