const { withGradleProperties, withAppBuildGradle } = require("expo/config-plugins");

function withAndroidCppFix(config) {
  config = withGradleProperties(config, (config) => {
    config.modResults.push(
      { type: "empty" },
      { type: "comment", value: "Fix C++ STL linking for native modules" },
      { type: "property", key: "ANDROID_STL", value: "c++_shared" },
      { type: "property", key: "android.useAndroidX", value: "true" },
      { type: "property", key: "android.enableJetifier", value: "true" },
      { type: "property", key: "newArchEnabled", value: "false" },
      { type: "empty" },
      { type: "comment", value: "Build optimization" },
      { type: "property", key: "org.gradle.jvmargs", value: "-Xmx4096m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8" },
      { type: "property", key: "org.gradle.parallel", value: "true" },
      { type: "property", key: "org.gradle.caching", value: "true" }
    );
    return config;
  });

  config = withAppBuildGradle(config, (config) => {
    if (!config.modResults.contents.includes("ANDROID_STL")) {
      const androidBlock = config.modResults.contents.indexOf("android {");
      if (androidBlock !== -1) {
        const insertPos = config.modResults.contents.indexOf("{", androidBlock) + 1;
        const insertion = `
    defaultConfig {
        externalNativeBuild {
            cmake {
                arguments "-DANDROID_STL=c++_shared"
            }
        }
    }`;
        if (!config.modResults.contents.includes("externalNativeBuild")) {
          config.modResults.contents = 
            config.modResults.contents.slice(0, insertPos) + 
            insertion + 
            config.modResults.contents.slice(insertPos);
        }
      }
    }
    return config;
  });

  return config;
}

module.exports = withAndroidCppFix;
