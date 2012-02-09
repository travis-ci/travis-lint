# encoding: binary
require "pathname"

require 'bundler'
Bundler.setup(:default, :test)

require 'rspec'


$: << File.expand_path('../../lib', __FILE__)
require "travis/lint"
