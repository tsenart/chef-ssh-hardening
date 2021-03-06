# encoding: utf-8
#
# Cookbook Name:: ssh-hardening
# Library:: get_ssh_macs
#
# Copyright 2012, Dominik Richter
# Copyright 2014, Christoph Hartmann
# Copyright 2014, Deutsche Telekom AG
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

class Chef
  class Recipe
    class SshMac
      # rubocop:disable AbcSize
      def self.get_macs(node, weak_hmac) # rubocop:disable CyclomaticComplexity, PerceivedComplexity
        weak_macs = weak_hmac ? 'weak' : 'default'

        macs53 = {}
        macs53.default = 'hmac-ripemd160,hmac-sha1'

        macs59 = {}
        macs59.default = 'hmac-sha2-512,hmac-sha2-256,hmac-ripemd160'
        macs59['weak'] = macs59['default'] + ',hmac-sha1'

        macs66 = {}
        macs66.default = 'hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-ripemd160-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,hmac-ripemd160'
        macs66['weak'] = macs66['default'] + ',hmac-sha1'

        # determine the mac for the operating system
        macs = macs59

        # use newer macs on ubuntu 14.04
        if node['platform'] == 'ubuntu' && node['platform_version'].to_f >= 14.04
          Chef::Log.info('Detected Ubuntu 14.04 or newer, use new macs')
          macs = macs66

        elsif node['platform'] == 'debian' && node['platform_version'].to_f >= 8
          Chef::Log.info('Detected Debian 8 or newer, use new macs')
          macs = macs66

        # use newer macs for rhel >= 7
        elsif node['platform_family'] == 'rhel' && node['platform_version'].to_f >= 7
          Chef::Log.info('Detected RedHat Family with version 7 or newer, use new macs')
          macs = macs66

        # stick to 53 for rhel <= 6
        elsif node['platform_family'] == 'rhel' && node['platform_version'].to_f < 7
          Chef::Log.info('Detected RedHat Family, use old macs')
          macs = macs53

        # use older mac for debian <= 6
        elsif node['platform'] == 'debian' && node['platform_version'].to_f <= 6
          Chef::Log.info('Detected Debian 6 or earlier, use old macs')
          macs = macs53
        end

        Chef::Log.info("Choose macs: #{macs[weak_macs]}")
        macs[weak_macs]
      end
    end
  end
end
