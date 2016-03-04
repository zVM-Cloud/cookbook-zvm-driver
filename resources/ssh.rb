# encoding: UTF-8
#
# Cookbook Name:: openstack-zvm-driver
# Resource:: ssh
#
# Copyright 2014, 2015 IBM Corp.
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

actions :set_dir, :authorize

default_action :set_dir

attribute :nova_user, kind_of: String, required: true
attribute :nova_group, kind_of: String, required: true
attribute :host, kind_of: String, required: false
attribute :mnpass, kind_of: String, required: true
