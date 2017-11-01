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

```

### Language

takes a string with options:

`ruby`
`go`

### test

#### command

Accepts a command to perform testing, such as:

```
test:
  command: <command>
```

ruby defaults to: `rake test`

golang defaults to: `go test ./...`

### deploy

#### method

Accepts "ecs" or "nomad"
