Local vs Docker
===============
Depending on your level of comfort with command line tools & docker, you can download the .Net core sdk and develop locally or you can take advantage of docker and use a docker image for your local development environment.
The following command will offer a command prompt into a pre-defined image that contains a bind mount for easy file access.

```dotnet docker run -p 5000:80 -e "ASPNETCORE_URLS=http://+:80" -v $(pwd):/home/apps -it --rm microsoft/aspnetcore-build```

Prerequisites (if choosing to develop locally)
==============================================
* .net core sdk
* IDE - any text editor will suffice


Step 1 - Build a basic app using dot net core
================================================
Create a mvc project called blog.mvc, run it and check http://localhost:5000 to verify that it has been created successfully.
```
dotnet new mvc -o blog.mvc -au None -f netcoreapp2.0
dotnet run
```

Ctrl-c the running app, cd into the blog.mvc folder and add the following dependencies
```
cd blog.mvc/
dotnet add package Microsoft.EntityFrameworkCore
dotnet add package Microsoft.EntityFrameworkCore.Design
dotnet add package Microsoft.EntityFrameworkCore.SqlServer
dotnet add package Microsoft.VisualStudio.Web.CodeGeneration.Design
```

#### Manually edit blog.mvc.csproj and add the following:
```
<ItemGroup>
    <DotNetCliToolReference Include="Microsoft.EntityFrameworkCore.Tools.DotNet" Version="2.0.1" />
  </ItemGroup>
```

Pull any missing dependencies
```dotnet restore```

Step 2 - Add a database model & SQL Server dependency
=======================================================
Use docker to run a SQL Server instance
```docker run -e 'ACCEPT_EULA=Y' -e 'MSSQL_SA_PASSWORD=Tot@11y5ecr3t' -e 'MSSQL_PID=Developer' -p 1433:1433 --name sqlexpress -d microsoft/mssql-server-linux```

or for docker on windows
```
docker run -d -p 1433:1433 -h sqlexpress -e sa_password=Tot@11y5ecr3t -e ACCEPT_EULA=Y microsoft/mssql-server-windows-express
```

Add the following content to a cs file in the Models directory (e.g. Model.cs)
```
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;

namespace blog.Mvc.Models
{
    public class BloggingContext : DbContext
    {
        private static bool _created = false;

        public BloggingContext()
        {
            if (!_created)
            {
                _created = true;
                Database.EnsureCreated();
            }
        }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            var connection = @"Server=sqlexpress;User Id=sa;Password=Tot@11y5ecr3t;Database=bloggingDB;";
            optionsBuilder.UseSqlServer(connection);
        }

        public DbSet<Blog> Blogs { get; set; }
        public DbSet<Post> Posts { get; set; }
    }

    public class Blog
    {
        public int BlogId { get; set; }
        public string Url { get; set; }
        public virtual List<Post> Posts { get; set; }
    }

    public class Post
    {
        public int PostId { get; set; }
        public string Title { get; set; }
        public string Content { get; set; }
        public int BlogId { get; set; }
        public Blog Blog { get; set; }
    }
}
```

Now Add the db connection string to the project (Startup.cs).
Don't forget the using statements.
```
using Microsoft.EntityFrameworkCore;
using System.Data.SqlClient;
using blog.Mvc.Models;
...
public void ConfigureServices(IServiceCollection services)
        {
            var connection = @"Server=sqlexpress;User Id=sa;Password=Tot@11y5ecr3t;Database=bloggingDB;";

            services.AddMvc();

            services.AddDbContext<BloggingContext>(options => options.UseSqlServer(connection));
        }
```

__Note: The connection string in the example code snippets reference the sql server instance as sqlexpress. This won't work. Any ideas why? [Have a read of this](https://github.com/dockerlimerick/meetups-repo/blob/master/meetups/meetup.2017-10-24/docker-networking/README.md) to figure out why.__

### Create the database migration (code first)
```
dotnet ef migrations add initialCreate --verbose
```

### Build a basic Web UI
Run the following to scaffold out a Blog controller and views
```
dotnet aspnet-codegenerator controller -name BlogsController -m Blog -dc BloggingContext --relativeFolderPath Controllers --useDefaultLayout --referenceScriptLibraries
```

#### Run the app locally
```dotnet run```
check http://localhost:5000/blogs to verify that it works successfully.


Step 3 - Dockerize the app
========================================
Create a .dockerignore file (```touch .dockerignore```) and add the following
```
bin\
obj\
```

Create a Dockerfile (```touch Dockerfile```) and add the following
```
FROM microsoft/aspnetcore-build:2.0 AS build-env

WORKDIR /app

# Copy csproj and restore as distinct layers
COPY *.csproj ./
RUN dotnet restore

# Copy everything else and build
COPY . ./
RUN dotnet publish -c Release -o out

# Build runtime image
FROM microsoft/aspnetcore:2.0
WORKDIR /app
COPY --from=build-env /app/out .
ENTRYPOINT ["dotnet", "blog.mvc.dll"]
```

Build and run the blog.mvc docker image
```
docker build -t blog.mvc:latest .
docker run -p 5000:80 --network blog-network --name blogs -d blog.mvc:latest
```

It should be accessible on http://localhost:5000/blogs

Remove the existing docker processes
```docker rm -f sqlexpress blogs```

Step 4 - Docker Compose to do the heavy lifting
=================================================
Create a ```docker-compose.yaml``` file and add the following
__Note: For windows users, change the image to microsoft/mssql-server-windows-express__

```
version: '2.1'
services:
  sqlexpress:
    image: microsoft/mssql-server-linux
    environment:
      SA_PASSWORD : "Tot@11y5ecr3t"
      ACCEPT_EULA: "Y"
      MSSQL_PID: "Developer"
    ports:
      - "1433:1433"
  webapp:
    build:
      context: .
      dockerfile: Dockerfile
    depends_on:  
      - "sqlexpress"         
    ports:
      - "5000:80"
```

run the following commands to spin up the environment.

```
docker-compose build
docker-compose up
```
The web app should be accessible at http://localhost:5000/blogs


FAQ
===
>Q. How do I see errors through a browser when debugging a .Net core app?
>A. ```export ASPNETCORE_ENVIRONMENT=Development``` prior to ```dotnet run```
>
>Q. How do I see the SQL generated by an EF code migration?
>A. ```dotnet ef migrations script```
>
>Q. How do I remove previous migrations?
>A. ```dotnet ef migrations remove```
>
>Q. The 'addInitial' migration didn't update the database
>A. ```dotnet ef database update initialCreate```
>
>Q. How do I create a network?
>A. ```docker network create blog-network```
>
>Q. How do I add a service to my network?
>A. ```docker network connect <id of blog-network> <id of sqlexpress>```
>
>Q. How can I get the ipaddress of a service?
>A.```docker network inspect bridge``` (assuming it is running on the bridge network)
>
>Q. How do I see running docker-compose processes?
>A. ```docker-compose ps```
