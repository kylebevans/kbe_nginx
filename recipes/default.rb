#
# Author:: Kyle Evans (<kylebe@gmail.com)
# Cookbook Name:: kbe_nginx
# Recipe:: default
# Copyright Holder:: Kyle Evans
# Copyright Holder Email:: kylebe@gmail.com
#
# Copyright:: 2018, The Authors, All Rights Reserved.

package 'nginx'

# create a secure diffie hellman parameter file
execute 'make-dh-file' do
  command 'openssl dhparam 4096 -dsaparam -out /etc/ssl/certs/dhparam.pem'
  not_if { File.exist?("/etc/ssl/certs/dhparam.pem") }
end

# set the nginx.service file for systemd
# needed to set privatetmp to false and restart settings
template '/lib/systemd/system/nginx.service' do
  source 'nginx.service.erb'
  owner 'root'
  group 'root'
  mode 0644
  notifies :restart, 'service[nginx]'
  notifies :run, 'execute[systemctl daemon-reload]', :immediately
end

execute 'systemctl daemon-reload' do
  action :nothing
end

# create the main nginx config file
template '/etc/nginx/nginx.conf' do
  source 'nginx.conf.erb'
  owner 'root'
  group 'root'
  mode 0644
  notifies :reload, 'service[nginx]'
end

# create the default site that forwards http to https
template '/etc/nginx/conf.d/default.conf' do
  source 'default.conf.erb'
  owner 'root'
  group 'root'
  mode 0644
  notifies :reload, 'service[nginx]'
end

# set up the service
service 'nginx' do
  ignore_failure true
  action [:enable, :start]
end