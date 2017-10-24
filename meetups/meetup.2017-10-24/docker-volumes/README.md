# Docker meetup October 24th

## Persistent data - Volumes

### Dockerfile VOLUME command

[Example of a VOLUME in a real Dockerfile](https://github.com/docker-library/postgres/blob/f7dc5727b1d6b6a636350e11648845ae33477579/10/Dockerfile#L126)

* It creates a new volume location and assign it to this location within the container
* It tells the container - I care about this data
* These files will outlive the container and will persist as long as the volume stays on the host
* Volumes need manual deletion (insurance policy)

For example, lets spin up a database image and see where it puts its data!

````
docker container run -d --name postgres postgres
docker container inspect postgres
docker volume ls
docker volume inspect ...
docker container run -d --name postgres-1 -v psql-data:/var/lib/postgresql/data postgres
````

### Lets do the same tihng but add a named volume

````
docker container run -d --name postgres-1 -v postgres-1-data:/var/lib/postgresql/data postgres
docker container inspect postgres-1
docker volume ls
docker volume inspect postgres-1-data

````


## Bind Mounting

* Bind mounting maps a host file or directory to a container file or directory
* Can only be used at runtime
* Host files overwrite any files in a container

```Docker run -v $(pwd):/path/to/container```

### Examples
````
make build 
make run
````
What do I need to do to make changes? Can I make them on the fly?

```make count```

