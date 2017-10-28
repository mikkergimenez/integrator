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
  registry: 853691203509.dkr.ecr.us-east-1.amazonaws.com
  image: iyf-api

deploy:
  method: ecs
  job_file: config/ecs.json

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

`
test:
  command: <command>
`

ruby defaults to: ` rake test `

golang defaults to: ` go test ./... `
