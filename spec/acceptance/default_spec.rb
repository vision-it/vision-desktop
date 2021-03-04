# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'vision_desktop' do
  context 'with defaults' do
    it 'run idempotently' do
      pp = <<-FILE

        # Mocking docker group
        group {'docker':
         ensure => present,
        }
        # Mocking Docker, since it wont work in the tests
        class docker () {}

        class { 'vision_desktop': }
      FILE

      # Systemd not available
      apply_manifest(pp, catch_failures: false)
    end
  end

  context 'init configuration' do
    describe package('openssh-client') do
      it { is_expected.to be_installed }
    end
    # from packages variable
    describe package('tmux') do
      it { is_expected.to be_installed }
    end
    describe file('/etc/ssh/sshd_config') do
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_mode 644 }
      its(:content) { is_expected.to match 'Puppet' }
    end
    describe file('/etc/apt/apt.conf.d/50unattended-upgrades') do
      it { is_expected.to be_file }
      its(:content) { is_expected.to match 'managed by Puppet' }
      its(:content) { is_expected.to match 'foobar@foobar.net' }
    end
    describe file('/etc/profile.d/vision_defaults.sh') do
      it { is_expected.to be_file }
      its(:content) { is_expected.to match 'alias' }
    end
  end

  context 'Users provisioned' do
    describe user('rick') do
      it { is_expected.to exist }
      it { is_expected.to have_home_directory '/home/rick' }
      it { is_expected.to have_authorized_key 'ssh-ed25519 aHR0cHM6Ly93d3cueW91dHViZS5jb20vd2F0Y2g/dj1kUXc0dzlXZ1hjUQ==' }
    end
  end

  context 'xrandr.sh provisioned' do
    describe file('/usr/local/bin/xrandr.sh') do
      its(:content) { is_expected.to match 'managed by Puppet' }
      its(:content) { is_expected.to match 'mypc' }
      its(:content) { is_expected.to match 'VGA-1' }
      it { is_expected.to be_file }
      it { is_expected.to be_mode 775 }
      it { is_expected.to be_owned_by 'root' }
    end
  end

  context 'Puppet installed' do
    describe package('puppet-agent') do
      it { is_expected.to be_installed }
    end
    describe file('/etc/puppetlabs/puppet/hiera.yaml') do
      it { is_expected.to exist }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_mode 644 }
      its(:content) { is_expected.to match 'Puppet' }
      its(:content) { is_expected.to match '_key.pem' }
    end
    describe file('/etc/puppetlabs/puppet/puppet.conf') do
      it { is_expected.to exist }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_mode 644 }
      its(:content) { is_expected.to match 'Puppet' }
      its(:content) { is_expected.to match 'production' }
    end
    describe file('/etc/puppetlabs/puppet/site.pp') do
      it { is_expected.to exist }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_mode 644 }
      its(:content) { is_expected.to match 'Puppet' }
      its(:content) { is_expected.to match 'role' }
    end
    describe file('/etc/g10k/g10k.yaml') do
      it { is_expected.to exist }
      its(:content) { is_expected.to match 'Puppet' }
    end
    describe file('/etc/systemd/system/apply.service') do
      it { is_expected.to exist }
      its(:content) { is_expected.to match 'Puppet' }
    end
    describe file('/etc/systemd/system/apply.timer') do
      it { is_expected.to exist }
      its(:content) { is_expected.to match 'Puppet' }
    end
  end

  context 'idm configuration' do
    describe package('ldap-utils') do
      it { is_expected.to be_installed }
    end
    describe package('nscd') do
      it { is_expected.to be_installed }
    end
    describe file('/etc/pam_ldap.conf') do
      it { is_expected.to contain 'Puppet' }
      it { is_expected.to be_file }
    end
    describe file('/etc/libnss-ldap.conf') do
      it { is_expected.to contain 'Puppet' }
      it { is_expected.to be_file }
    end
    describe file('/etc/ldap/ldap.conf') do
      it { is_expected.to be_file }
      it { is_expected.to be_mode 644 }
      it { is_expected.to contain 'Puppet' }
      it { is_expected.to contain 'bar.foo.de' }
    end
    describe file('/etc/nsswitch.conf') do
      it { is_expected.to be_file }
      it { is_expected.to contain 'Puppet' }
      it { is_expected.to contain 'ldap compat' }
    end
    describe service('nscd') do
      it { is_expected.to be_enabled }
    end
  end
  context 'manage sudoers' do
    describe package('sudo') do
      it { is_expected.to be_installed }
    end
    describe file('/etc/sudoers.d/80_sudoers') do
      its(:content) { is_expected.to match 'Puppet' }
      its(:content) { is_expected.to match 'NOPASSWD' }
      it { is_expected.to be_mode 440 }
    end
    describe command('visudo -c') do
      its(:exit_status) { is_expected.to eq 0 }
    end
  end
end
