module.exports = function(grunt) {
  var browsers = [

    // linux
    {
      browserName: 'firefox',
      version: '33',
      platform: 'Linux'
    },
    {
      browserName: 'chrome',
      version: '38',
      platform: 'Linux'
    },

    // ios
    {
      browserName: 'ipad',
      version: '8.1',
      'device-orientation': 'portrait',
      platform: 'OS X 10.9'
    },
    {
      browserName: 'ipad',
      version: '6.1',
      'device-orientation': 'portrait',
      platform: 'OS X 10.10'
    },

    // android
    {
        browserName: 'android',
        version: '4.4',
        deviceName: 'Android',
        'device-orientation': 'portrait',
        platform: 'Linux'
    },
    {
        browserName: 'android',
        version: '4.3',
        deviceName: 'Android',
        'device-orientation': 'portrait',
        platform: 'Linux'
    },
    {
        browserName: 'android',
        version: '4.2',
        deviceName: 'Android',
        'device-orientation': 'portrait',
        platform: 'Linux'
    },
    {
        browserName: 'android',
        version: '4.1',
        deviceName: 'Android',
        'device-orientation': 'portrait',
        platform: 'Linux'
    },
    {
        browserName: 'android',
        version: '4.0',
        deviceName: 'Android',
        'device-orientation': 'portrait',
        platform: 'Linux'
    },

    // windows
    {
      browserName: 'internet explorer',
      version: '11',
      platform: 'Windows 8.1'
    },
    {
      browserName: 'internet explorer',
      version: '10',
      platform: 'Windows 8'
    },
    {
      browserName: 'internet explorer',
      version: '9',
      platform: 'Windows 7'
    },
    {
      browserName: 'internet explorer',
      version: '8',
      platform: 'Windows 7'
    },
    {
      browserName: 'internet explorer',
      version: '7',
      platform: 'XP'
    },
    {
      browserName: 'chrome',
      version: '38',
      platform: 'Windows 8.1'
    },
    {
      browserName: 'firefox',
      version: '33',
      platform: 'Windows 8.1'
    },

    // mac
    {
        browserName: 'safari',
        version: '5',
        platform: 'OS X 10.6'
    },
    {
        browserName: 'safari',
        version: '6',
        platform: 'OS X 10.8'
    },
    {
        browserName: 'safari',
        version: '7',
        platform: 'OS X 10.9'
    },
    {
        browserName: 'safari',
        version: '8',
        platform: 'OS X 10.10'
    }

  ];

  grunt.initConfig({
    connect: {
      server: {
        options: {
          hostname: "127.0.0.1",
          port: 9999,
          base: ""
        }
      }
    },
    'saucelabs-mocha': {
      all: {
        options: {
          urls: ["http://127.0.0.1:9999/test/host.html"],
          tunnelTimeout: 5,
          build: process.env.TRAVIS_JOB_ID,
          concurrency: 3,
          browsers: browsers,
          testname: "fnuc tests",
          tags: ["master"]
        }
      }
    },
    watch: {}
  });

  // Loading dependencies
  for (var key in grunt.file.readJSON("package.json").devDependencies) {
    if (key !== "grunt" && key.indexOf("grunt") === 0) grunt.loadNpmTasks(key);
  }

  grunt.registerTask("dev", ["connect", "watch"]);
  grunt.registerTask("default", ["connect", "saucelabs-mocha"]);
};
