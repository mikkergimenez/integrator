# integrator.yml guide

```

language: string (required)

test:
  command: go test ./...

pre_build:
  command: build.sh

build:
  method: docker

docker:
  registry: string
  image: string

deploy:
  method: string

ecs:
  cluster: "Production"
  name: "iyf-api"
  container_instances: 2 # defaults to 2
  memory: 2048
  memory_reservation: 1024
```

### Language

takes a string with options:

`ruby`
Installs dependencies, then runs tests against an application written in Ruby.

`node`
Installs dependencies, then runs tests against an application written in Node.js.


`go`
Compiles an application written in go.

`docker`
Only builds/deploys a docker container, does not try to test/build code.

### test

#### command

Accepts a command to perform testing, such as:

```
test:
  command: <command>
```

ruby defaults to: `rake test`

golang defaults to: `go test ./...`

*Important* For all commands run on a script in your repo, remember to include './'

### deploy

#### method

Accepts "ecs" or "nomad"

### ecs

#### cluster
#### name
#### container_instances
Number of Container Instances to launch

#### memory
Memory hard limit (default to 2048)

#### memory_reservation
Memory soft limit (default to 1024)
