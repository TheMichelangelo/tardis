const { getDefaultConfig } = require('expo/metro-config');

const config = getDefaultConfig(__dirname);

// Exclude expo-sqlite from web builds
config.resolver.alias = {
  'expo-sqlite': false,
};

module.exports = config;
