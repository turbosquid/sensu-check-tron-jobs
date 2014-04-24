sensu-check-tron-jobs
=====================

Simple [Sensu](https://github.com/sensu/sensu) pluin to monitor the status of [Tron](https://github.com/Yelp/Tron) jobs.

Uses the Tron API to check on all jobs, or just a monitored subset. This plugin should work with both Sensu and Nagios -- but you'll need the sensu-plugin gem installed if you use this with Nagios. Other than the sensu plugin gem, there
are no gem requirements.

See the code for exact parameters and defaults, but some examples:


    ./check-tron-jobs # Check all jobs. Use server localhost, port 8089
    ./check-tron-jobs --server tron.example.co:8089 --jobs MASTER.foo,MASTER.test # Use remote server, check two jobs
    
At some point we'll work up a PR into the sensu-community-plugin repo
