
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

c. Install geckodriver (for firefox, so you will need to have firefox installed in your machine as well)

    $ brew install geckodriver

d. Install chromedriver

    $ brew tap homebrew/cask
    $ brew cask install chromedriver


### Install RVM and Ruby
a. Install RVM:

    $ curl -sSL https://get.rvm.io | bash

b. Exit terminal and restart.
c. Install version of Ruby we use:

    $ rvm install <version> (Right now I'm using 2.5.0)

Eric was running into an error while installing ruby, installing openssl seems to help with the problem. To install openssl, do:

    $ brew install openssl

d. Last step:

    $ rvm get stable --auto-dotfiles

**Note:** Follow the steps in the warning it generates - add the following line to '~/.bash_profile': source ~/.profile, you can do this with this command:

    $ echo source ~/.profile >> ~/.bash_profile

e. If you have multiple ruby binaries, you can use this command to set the default to the version installed in step 3b:

    $ rvm --default ruby-<version> (Right now I'm using 2.5.0)

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

### About Database connections
- In this project, we have the capability of connectings to SQL and POSTGRES DBs to retrieve necessary data for testing. We use 2 gems pg and tiny_tds (they are provided in your Gemfile), but in order for these gems to be installed successfully, you will need to have the DB native apps installed first, to do do, use the below brew commands.

    ```
    $ brew install postgresql
    $ brew install freetds
    ```

- Also checkout/run `test/small_sample/coachlive-be-access-code.rb` and `test/small_sample/fasttrack-client-info-retrieve.rb` to see how the connection classes are used.

- *VERY IMPOSTANT:* all DB credentials are/should be saved in yaml files, you will see there are example files of `postgres_databases.example.yml` and  `sql_databases.example.yml` within the config/ directory. These files are templates to give you ideas of the correct format. Some Developers like Jeremy Peterson or Eric Hoffman and myself will have correct files saved locally. You can ask any of us to provide you these files, but if not, you can always find and copy them from Jenkins server under `/var/lib/jenkins/deploy_files/qa_regression` - If you don't know how to get there, ask Devops or other Developers for instructions, I cannot/should not provide guidance here. *REMEMBER* ... DO NOT commit changes made to these files to git repo for security purposes. If you do need to make changes (like add new credentials or update old ones) PLEASE do so locally, AND update the files in Jenkins server by yourself. DO communicate with other Developers or Devops so everyone is aware. After all, anything DB related should be treated with care and considerations.


### Clone
Last but not least, clone this repo (make sure your current directory is where you want to clone this to, if not, go to the desired directory)

    $ git clone https://github.com/NCSAAthleticRecruiting/qa_regression.git

There is a Gemfile with a collection of gems I have added on the go (of course we can always add more gems as we need in here for future use)

    $ cd qa_regression
    $ rvm gemset create qa (or whichever name you like it to be)
    $ rvm --default use ruby-2.5.0@qa
    $ gem install bundler -v "2.0.2"
    $ bundle _2.0.2_

### Set Environment
There are yml files designed to hold environment specific information (e.g.: staging.yml, dev.yml). Add these lines to your bash_profile

    # Environment configs
    alias dev="export CONFIG_FILE='~/qa_regression/config/dev.yml'"
    alias staging="export CONFIG_FILE='~/qa_regression/config/staging.yml'"
    alias prod="export CONFIG_FILE='~/qa_regression/config/prod.yml'"

    if ["$CONFIG_FILE" == ""]
	then
		export CONFIG_FILE='~/qa_regression/config/staging.yml'
    else
	    export CONFIG_FILE
    fi

That means tests are default to use staging configs, if you wish to run tests against a different environment, simply call for that environment alias.

### Choose where to launch browser
In ui.rb, I have specified 3 different platform where you can choose to launch your browser in: local (your machine), docker, or browserstack. It is default to 'docker' for most tests so that Jenkins can run tests in a docker container. Simply switch out 'docker' to 'local' in commmon.rb in order for tests to launch browser in your machine. If you choose to launch browser in docker container. Use this command to launch the container.

    docker run -d -it --name elgalu -p 4444:24444 -v /dev/shm:/dev/shm -v ~/qa_regression:/home/seluser --privileged elgalu/selenium

### To run tests
There is a simple Rake task to run all test scripts that ends with "_test.rb" in this repo, all you have to do is run

    $ rake test

`rake test` is the default rake task. You can run this task by running:

    $ rake default
    $ rake test
    OR
    $ rake test <tests directory>  ... e.g. rake test daily_monitor

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
