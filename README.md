# QA Regression Repository


Hey! Welcome to your very own Repository, QA team! In this repo, we will store notes, library, test suite scripts, tools and what not to help with the regression process of the team's testing efforts in general. We might need more than one repo but let's start with this one for now and we will go from there.

It might be helpful if your computer is setup right so that you can execute any test anytime, anywhere. Hence, checkout these Setup steps below and get yourself geared up!

----------

### Get Xcode (from Appstore)
a. Find Xcode app from Appstore and install it.

b. After installing, enable Command Line Tools in Preferences (or my favorite terminal at the time is iTerm).

c. To verify that it installed properly:

  $ gcc --version

### Install Homebrew
(Homebrew is needed for installing RVM)

a. Type in Console:

  $ ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go/install)"

b. To cleanup intall, run:

  $ brew doctor

 _See also [https://rvm.io/rvm/autolibs](https://rvm.io/rvm/autolibs) for brew questions etc (optional)._

  
### Install RVM and Ruby
a. Install RVM:

  $ curl -sSL https://get.rvm.io | bash
  
b. Exit terminal and restart.
c. Install version of Ruby we use:

  $ rvm install <version> (Right now I'm using 2.4.0)
  
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


e. For more info on git settings/configs, click [here](https://help.github.com/articles/setting-your-username-in-git/)

f. To learn how to generate SSH key and add the key to your github, click [here](https://help.github.com/articles/connecting-to-github-with-ssh/)

Last but not least, clone this repo. There is a Gemfile with a collection of gems I have added on the go (of course we can always add more gems as we need in here for future use). cd into the repo and do:

  $ rvm gemset create qa (or whichever name you like it to be)
    $ rvm --default use ruby-2.4.0@qa 
  $ gem install bundler
    $ bundle install

### Ready - Set - Go!
