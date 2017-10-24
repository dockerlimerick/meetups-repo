# Docker Networking

````
docker network ls
````

| NETWORK ID    | NAME     | DRIVER  | SCOPE |
| -------------:|:--------:|:-------:|------:|
|552f6ca562ca   | bridge   | bridge  | local |
|0b8782b02bfa   | host     | host    | local |
|50e0194f7d0e   | none     | null    | local |

* bridge - default, own subnet
* host - wires directly into the host network; more performant,less secure
    

````
docker network inspect bridge
docker network create private-test

docker run -d --name nginx-1 nginx
docker network connect <id of private-test> <id of nginx-1>
docker network inspect private-test
docker container inspect nginx-1

````

## Reasons for a custom network

* External ports are closed by default (potentially more secure)


# DNS Naming

````
docker container run -d --network private-test --name postgres-1 postgres
docker network inspect private-test
docker exec -it postgres-1 bash
````

* Can't rely on IP Addresses but containers can find each other through DNS
* Default bridge network doesn't have DNS build in. need to use --link to reference containers