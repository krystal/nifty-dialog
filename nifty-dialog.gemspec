require File.expand_path('../lib/nifty/dialog/version', __FILE__)

Gem::Specification.new do |s|
  s.name          = "nifty-dialog"
  s.description   = %q{A javascript library for working with dialogs}
  s.summary       = s.description
  s.homepage      = "https://github.com/niftyware/dialog"
  s.version       = Nifty::Dialog::VERSION
  s.files         = Dir.glob("{lib}/**/*")
  s.require_paths = ["lib"]
  s.authors       = ["Adam Cooke"]
  s.email         = ["adam@niftyware.io"]
end
