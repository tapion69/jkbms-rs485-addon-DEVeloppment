module.exports = {
    uiPort: process.env.PORT || 1894,

    mqttReconnectTime: 15000,
    serialReconnectTime: 15000,

    flowFile: "flows.json",
    flowFilePretty: true,

    userDir: "/data",
    nodesDir: "/data/nodes",

    diagnostics: {
        enabled: true,
        ui: true
    },

    logging: {
        console: {
            level: "info",
            metrics: false,
            audit: false
        }
    },

    contextStorage: {
        default: {
            module: "memory"
        }
    },

    exportGlobalContextKeys: false,

    functionExternalModules: true,

    functionGlobalContext: {
        crypto: require("crypto"),
        fs: require("fs"),
        path: require("path")
    },

    editorTheme: {
        projects: {
            enabled: false
        }
    }
};
