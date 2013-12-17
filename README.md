#Introduction

There are many solutions available in Rails for moving long-running jobs into a background process. Each of these has its own advantages and Sidekiq is no exception. Sidekiq is similar to Resque,its primary difference is that it handles multiple jobs concurrently using threads instead of processes and this can save on memory usage.
