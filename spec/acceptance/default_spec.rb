require 'spec_helper_acceptance'

describe 'vision_desktop' do
  context 'with defaults' do
    it 'run idempotently' do
      pp = <<-FILE

        # Mocking Docker, since it wont work in the tests
        class docker () {}

        class { 'vision_desktop': }
      FILE

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
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
    describe file('/local') do
      it { is_expected.to be_directory }
    end
    describe user('root') do
      it { should have_authorized_key 'ssh-ed25519 aHR0cHM6Ly93d3cueW91dHViZS5jb20vd2F0Y2g/dj1kUXc0dzlXZ1hjUQ==' }
    end
    describe file('/etc/ssh/sshd_config') do
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_mode 644 }
      its(:content) { is_expected.to match 'Puppet' }
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
  end

  context 'nfs configuration' do
    describe package('nfs-common') do
      it { is_expected.to be_installed }
    end
    describe file('/itshare') do
      it { is_expected.to be_directory }
    end
    describe file('/home/nfs') do
      it { is_expected.to be_directory }
    end
    describe file('/etc/fstab') do
      it { is_expected.to be_file }
      it { is_expected.to contain 'foo.bar.de:/export/homes /home/nfs nfs4 vers=4,sec=krb5p' }
      it { is_expected.to contain 'foo.bar.de:/export/it /itshare nfs4 vers=4,sec=krb5p' }
      it { is_expected.to contain '_netdev' }
      it { is_expected.to contain 'x-systemd.automount' }
    end
    describe file('/etc/default/nfs-common') do
      it { is_expected.to be_file }
      it { is_expected.to contain 'NEED_IMAPD=yes' }
      it { is_expected.to contain 'NEED_GSSD=yes' }
    end
  end

  context 'idm configuration' do
    describe package('libnss-ldapd') do
      it { is_expected.to be_installed }
    end
    describe package('krb5-user') do
      it { is_expected.to be_installed }
    end
    describe package('krb5-config') do
      it { is_expected.to be_installed }
    end
    describe package('libpam-krb5') do
      it { is_expected.to be_installed }
    end

    describe file('/etc/krb5.conf') do
      it { is_expected.to be_file }
      it { is_expected.to be_mode 644 }
      it { is_expected.to contain 'default_realm = FOOBAR.DE' }
      it { is_expected.to contain 'admin_server = foo.bar.de' }
      it { is_expected.to contain 'kdc = foo.bar.de' }
      it { is_expected.to contain 'kdc = foo.bar.com' }
    end

    describe file('/etc/krb5.keytab') do
      it { is_expected.to be_file }
      it { is_expected.to be_mode 600 }
      it { is_expected.to contain '0xDEADFACECAFE' }
    end

    describe file('/etc/nslcd.conf') do
      it { is_expected.to be_file }
      it { is_expected.to be_mode 640 }
      it { is_expected.to contain 'tls_reqcert never' }
      it { is_expected.to contain 'base dc=foo,dc=bar' }
      it { is_expected.to contain 'uri ldaps://bar.foo.de' }
    end

    describe file('/etc/nsswitch.conf') do
      it { is_expected.to be_file }
      it { is_expected.to contain 'compat ldap' }
    end

    describe file('/etc/idmapd.conf') do
      it { is_expected.to be_file }
      it { is_expected.to contain 'vision' }
    end
    describe service('nslcd') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end
    describe service('nscd') do
      it { is_expected.to be_enabled }
    end
  end
end
