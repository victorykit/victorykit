#
# This file contains all of the common
# environment variables used by various
# VK scripts and applications.
#

# Needed by Unicorn/Monit.
HOME="/home/admin"; export HOME

LANG="en_US.UTF-8"; export LANG
LC_ALL="en_US.UTF-8"; export LC_ALL


RUBY=`which ruby`; export RUBY

RAILS_ENV=production
RACK_ENV=production
export RAILS_ENV RACK_ENV

# Settings for Ruby-2.0+
RUBY_HEAP_MIN_SLOTS=2000000
RUBY_GC_MALLOC_LIMIT=90000000
RUBY_FREE_MIN=100000
RUBY_HEAP_SLOTS_GROWTH_FACTOR=1
export RUBY_HEAP_MIN_SLOTS RUBY_GC_MALLOC_LIMIT RUBY_FREE_MIN RUBY_HEAP_SLOTS_GROWTH_FACTOR

keys_and_settings="${shared_path}/config/keys_and_settings.sh"
if [ -f "$keys_and_settings" ] ; then
	. "$keys_and_settings"
fi
