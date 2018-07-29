# Why Integator?

  Integrator is a tool to enable hobby developers to leverage all of the
benefits of a modern CD process, without having to manage any servers.
Integrator runs on your local laptop, reaches out to your source control
provider, then tests, builds and deploys your app while you work.  Because
Integrator is open source, and not a hosted service, it is free for public and
private repos.

# Running

You have to set a few environment variables to get this working.  To support Bitbucket, configure your username and password using:

```
BITBUCKET_USERNAME
BITBUCKET_PASSWORD
```

To post messages to slack use:
```
SLACK_HOOK_URL
```

launch using

```ruby integrator.rb```

Integrator will run until it sees a change in one of your repos.  If you want to
force the build of one of your repo's. use:

```ruby integrator.rb --force <repo_name>```

# Configuring

Create an integrator.yml file in the root of your application.  For the syntax
of integrator.yml see:

[Integrator.yml docs](docs/integrator.yml.md)

# Test/Build your application

Integrator supports the following Languages:

* [Ruby](https://www.ruby-lang.org/)
* [Golang](https://golang.org/)
* [Node](https://nodejs.org/)

And the following Source Control Sites

* [Bitbucket](http://www.bitbucket.org)
* [Github](http://www.github.com)
* [Gitlab](http://www.gitlab.com)

# Deploy your Application

Integrator supports the following deploy destinations:

* [Hashicorp Nomad](https://www.nomadproject.io/)
* [Amazon ECS](https://aws.amazon.com/ecs)
