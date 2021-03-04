# This file is managed by Puppet
# Contains some shared shell defaults

# Aliases
alias _='sudo'
alias gst='git status'
alias gco='git checkout'
alias la='ls -lAh'
alias ll='ls -lh'
alias puppet-deploy='g10k -maxworker 2 -config /etc/g10k/g10k.yaml'
alias puppet-apply='puppet apply /etc/puppetlabs/puppet/site.pp'
alias apt-upgrade='apt-get update && apt-get upgrade && apt-get autoremove && apt-get clean'
