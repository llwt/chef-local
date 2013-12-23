#
# Cookbook Name:: devtrw-lan
# Recipe:: default
#
# Copyright 2013, Steven Nance <steven@devtrw.com>
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
include_recipe 'pacman'

package 'net-tools' # needed for virtualbox networking
package 'virtualbox'
template '/etc/modules-load.d/virtualbox.conf'

package 'nfs-utils'
service 'nfsd' do
    action [ :enable, :start ]
    provider Chef::Provider::Service::Systemd
end

aur_packages = %w[ rubymine vagrant ]
aur_packages.each do |pkg_name|
    pacman_aur pkg_name do
        action [ :build, :install ]
    end
end

template '/etc/profile.d/jre.sh'
template '/etc/profile.d/jre.csh' do source 'jre.sh.erb' end
