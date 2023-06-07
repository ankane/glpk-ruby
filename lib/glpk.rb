# stdlib
require "fiddle/import"

# modules
require_relative "glpk/problem"
require_relative "glpk/version"

module Glpk
  class Error < StandardError; end

  class << self
    attr_accessor :ffi_lib
  end
  lib_name =
    if Gem.win_platform?
      # TODO test
      ["glpk.dll"]
    elsif RbConfig::CONFIG["host_os"] =~ /darwin/i
      if RbConfig::CONFIG["host_cpu"] =~ /arm|aarch64/i
        ["libglpk.dylib", "/opt/homebrew/lib/libglpk.dylib"]
      else
        ["libglpk.dylib"]
      end
    else
      ["libglpk.so", "libglpk.so.40"]
    end
  self.ffi_lib = lib_name

  # friendlier error message
  autoload :FFI, "glpk/ffi"

  def self.lib_version
    FFI.glp_version.to_s
  end

  def self.read_lp(filename)
    problem = Problem.new
    problem.read_lp(filename)
    problem
  end

  def self.read_mps(filename)
    problem = Problem.new
    problem.read_mps(filename)
    problem
  end

  def self.load_problem(**options)
    problem = Problem.new
    problem.load_problem(**options)
    problem
  end
end
