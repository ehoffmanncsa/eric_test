# QA Regression Repository


Hey! Welcome to your very own Repository, QA team! In this repo, we will store notes, library, test suite scripts, tools and what not to help with the regression process of the team's testing efforts in general. We might need more than one repo but let's start with this one for now and we will go from there.

It might be helpful if your computer is setup right so that you can execute any test anytime, anywhere. Hence, checkout these Setup steps below and get yourself geared up!

----------

### Get Xcode (from Appstore)
a. Find Xcode app from Appstore and install it.

b. After installing, enable Command Line Tools in Preferences (or my favorite terminal at the time is iTerm). Check if the full Xcode package is already installed:

    $ xcode-select -p

If you see:

    /Applications/Xcode.app/Contents/Developer

the full Xcode package is already installed. Otherwise:

    $ xcode-select --install

You should see the pop up below on your screen. Click Install when it appears.

Once the software is installed, click Done

c. To verify that it installed properly and has the right version:

    $ gcc --version

This is what i see:

    Configured with: --prefix=/Applications/Xcode.app/Contents/Developer/usr --with-gxx-include-dir=/usr/include/c++/4.2.1
    Apple LLVM version 9.0.0 (clang-900.0.37)
    Target: x86_64-apple-darwin16.7.0
    Thread model: posix
    InstalledDir: /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin

### Install Homebrew
(Homebrew is needed for installing RVM)

a. Type in Console:

    $ /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

b. To cleanup intall, run:

    $ brew doctor

 _See also [https://rvm.io/rvm/autolibs](https://rvm.io/rvm/autolibs) for brew questions etc (optional)._
 
c. Install geckodriver (for firefox, so you will need to have firefox installed in your machine as well, I use Firefox 52.3.0esr.dmg installer)

    $ brew install geckodriver

d. Install chromedriver

    $ brew install chromedriver

  
### Install RVM and Ruby
a. Install RVM:

    $ curl -sSL https://get.rvm.io | bash
  
b. Exit terminal and restart.
c. Install version of Ruby we use:

    $ rvm install <version> (Right now I'm using 2.4.0)
    
Eric was running into an error while installing ruby, installing openssl seems to help with the problem. To install openssl, do:
    
    $ brew install openssl
  
d. Last step:
  
    $ rvm get stable --auto-dotfiles 

**Note:** Follow the steps in the warning it generates - add the following line to '~/.bash_profile': source ~/.profile, you can do this with this command: 

    $ echo source ~/.profile >> ~/.bash_profile

e. If you have multiple ruby binaries, you can use this command to set the default to the version installed in step 3b:
  
    $ rvm --default ruby-<version> (Right now I'm using 2.4.0)

f. You can verify it now works correctly with the command in a new terminal:
  
    $ which ruby

### Install Git
**Note:** If you have Xcode 4, you already have Git, or skip this step if you have already installed Git in some other occasions
  
a. Install Git:
  
    $ brew install git

b. Run:
  
    $ brew doctor

c. Confirm path with:
  
    $ which git
    (should be /usr/local/bin/git) 

    If not, use below command
    $ echo 'export PATH="/usr/local/bin:/usr/local/sbin:~/bin:$PATH"' >> ~/.bash_profile

d. Setup configs:
  
    $ git config --global user.name "Mona Lisa"
    $ git config user.name
    > Mona Lisa
    
    $ git config --global user.email "email@example.com"
    $ git config --global user.email
    > email@example.com


e. For more info on git settings/configs, click [here](https://help.github.com/articles/setting-your-username-in-git/)

f. To learn how to generate SSH key and add the key to your github, click [here](https://help.github.com/articles/connecting-to-github-with-ssh/)

### Clone & Run
Last but not least, clone this repo (make sure your current directory is where you want to clone this to, if not, go to the desired directory)

    $ git clone https://github.com/NCSAAthleticRecruiting/qa_regression.git
    
There is a Gemfile with a collection of gems I have added on the go (of course we can always add more gems as we need in here for future use)

    $ cd qa_regression
    $ rvm gemset create qa (or whichever name you like it to be)
    $ rvm --default use ruby-2.4.0@qa 
    $ gem install bundler
    $ bundle install
    
There is a simple Rake task to run all test scripts that ends with "_test.rb" in this repo, all you have to do is run

    $ rake test

`rake test` is the default rake task. You can run this task by running: 

    $ rake default
    $ rake test
    OR
    $ rake test['<tests directory>'] ... e.g. rake test['daily_monitor']
    
Running rake test only will execute tests in all directories within the test/ directory. Providing a directory name will only execute tests within that directory. The work flow is: execute tests once, produce result, run all failed test one more time and give final result.

If you wanna know what rake tasks are available in this repo, run:

    $ rake -T
    
If you only want to run a single test, go into the directory of this repo on your local machine

    $ cd qa_regression
    $ ruby test/<dir_name>/<test_name_test.rb>
    
If you wanna run only 1 test method of a test script, do this

    $ ruby test/<dir_name>/<test_name_test.rb> -n test_method_name

**Important:** Always remember to do "git pull" to run the latest code!

## Ready - Set - Go!
