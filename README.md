#Introduction

There are many solutions available in Rails for moving long-running jobs into a background process. Each of these has its own advantages and Sidekiq is no exception. Sidekiq is similar to Resque,its primary difference is that it handles multiple jobs concurrently using threads instead of processes and this can save on memory usage.

#Requirements
Like Resque, Sidekiq uses Redis to manage its job queue so we’ll need to install this first.If you use Debian OS use this command to install

```
sudo apt-get install redis-server
```
If you're running RPM based OS than use this command to install

```
sudo yum install redis-server
```

and if you’re running OS X the easiest way to do this to use Homebrew to install it by running this command:

```
$ brew install redis
```
