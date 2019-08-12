[chat]: https://discord.gg/MGyHyJv

# async-std [![Join the chat on Discord](https://img.shields.io/discord/598880689856970762)][chat]

The official `async-std` website. Based on the [rom-rb][rom-rb] website, originally created by [@angeloashmore][angeloashmore].

[rom-rb]: https://rom-rb.org
[angeloashmore]: https://github.com/angeloashmore

## Editing content

Feel free to send content pull requests without building the page, if you don't have Ruby installed. We're going to take it from there.

Changes to the book should directly go to [async-std][async-std].

[async-std]: https://github.com/async-std/async-std

## Build Instructions

1. Install gem dependencies:

   ```shell
   bundle install
    ```

2. Install node dependencies:

   ```shell
   npm install
   ```

   or

   ```shell
   yarn
   ```

3. Serve locally at [http://localhost:4567](http://localhost:4567):

   ```shell
   bundle exec middleman server
   ```

   or build to `/build`:

   ```shell
   bundle exec middleman build
   ```

 ## Windows Instructions
 If you're getting the following error:
 
 ```
 Unable to load the EventMachine C extension; To use the pure-ruby reactor, require 'em/pure_ruby'
 ```
 
 or features such as Live Reload are not working then it's because the
 C extension for eventmachine needs to be installed.
 
 ```
 gem uninstall eventmachine
 ```
 
 take note of the version being used. (At the time of writing '1.2.0.1')
 
 ```
 gem install eventmachine -v '[VERSION]' --platform=ruby
 ```
 
 If you have a proper environment with DevKit installed then eventmachine with its
 C extension will be installed and everything will work fine.