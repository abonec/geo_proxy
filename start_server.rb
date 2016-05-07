$:.unshift File.dirname(__FILE__)
require 'bundler'

Bundler.require
require 'lib/server'

Server.run

