# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'
require './lib/fiat_lux'

begin
  require 'bundler'
  require 'motion/project/template/gem/gem_tasks'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'fiat_lux'

  app.frameworks << 'OpenGLES'
  app.frameworks << 'QuartzCore'
  app.frameworks << 'CoreGraphics'

  app.resources_dirs << './spec/resources/' if app.spec_mode
end