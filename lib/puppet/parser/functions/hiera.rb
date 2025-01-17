# frozen_string_literal: true
require 'hiera_puppet'

module Puppet::Parser::Functions
  newfunction(
    :hiera,
    :type => :rvalue,
    :arity => -2,
    :doc => <<DOC
Performs a standard priority lookup of the hierarchy and returns the most specific value
for a given key. The returned value can be any type of data.

The function takes up to three arguments, in this order:

1. A string key that Hiera searches for in the hierarchy. **Required**.
2. An optional default value to return if Hiera doesn't find anything matching the key.
    * If this argument isn't provided and this function results in a lookup failure, Puppet
    fails with a compilation error.
3. The optional name of an arbitrary
[hierarchy level](https://puppet.com/docs/hiera/latest/hierarchy.html) to insert at the
top of the hierarchy. This lets you temporarily modify the hierarchy for a single lookup.
    * If Hiera doesn't find a matching key in the overriding hierarchy level, it continues
    searching the rest of the hierarchy.

The `hiera` function does **not** find all matches throughout a hierarchy, instead
returining the first specific value starting at the top of the hierarchy. To search
throughout a hierarchy, use the `hiera_array` or `hiera_hash` functions.

**Example**: Using `hiera`

~~~ yaml
# Assuming hiera.yaml
# :hierarchy:
#   - web01.example.com
#   - common

# Assuming web01.example.com.yaml:
# users:
#   - "Amy Barry"
#   - "Carrie Douglas"

# Assuming common.yaml:
users:
  admins:
    - "Edith Franklin"
    - "Ginny Hamilton"
  regular:
    - "Iris Jackson"
    - "Kelly Lambert"
~~~

~~~ puppet
# Assuming we are not web01.example.com:

$users = hiera('users', undef)

# $users contains {admins  => ["Edith Franklin", "Ginny Hamilton"],
#                  regular => ["Iris Jackson", "Kelly Lambert"]}
~~~

You can optionally generate the default value with a
[lambda](https://puppet.com/docs/puppet/latest/lang_lambdas.html) that
takes one parameter.

**Example**: Using `hiera` with a lambda

~~~ puppet
# Assuming the same Hiera data as the previous example:

$users = hiera('users') | $key | { "Key \'${key}\' not found" }

# $users contains {admins  => ["Edith Franklin", "Ginny Hamilton"],
#                  regular => ["Iris Jackson", "Kelly Lambert"]}
# If hiera couldn't match its key, it would return the lambda result,
# "Key 'users' not found".
~~~

The returned value's data type depends on the types of the results. In the example
above, Hiera matches the 'users' key and returns it as a hash.

The `hiera` function is deprecated in favor of using `lookup` and will be removed in 6.0.0.
See https://puppet.com/docs/puppet/#{Puppet.minor_version}/deprecated_language.html.
Replace the calls as follows:

| from  | to |
| ----  | ---|
| hiera($key) | lookup($key) |
| hiera($key, $default) | lookup($key, { 'default_value' => $default }) |
| hiera($key, $default, $level) | override level not supported |

Note that calls using the 'override level' option are not directly supported by 'lookup' and the produced
result must be post processed to get exactly the same result, for example using simple hash/array `+` or
with calls to stdlib's `deep_merge` function depending on kind of hiera call and setting of merge in hiera.yaml.

See
[the documentation](https://puppet.com/docs/hiera/latest/puppet.html#hiera-lookup-functions)
for more information about Hiera lookup functions.

- Since 4.0.0
DOC
  ) do |*_args|
    Error.is4x('hiera')
  end
end
