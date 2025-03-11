'use strict';

const fs = require('node:fs');
const path = require('path');
const getPublicUrlOrPath = require('react-dev-utils/getPublicUrlOrPath');

// Make sure any symlinks in the project folder are resolved:
// https://github.com/facebook/create-react-app/issues/637
const appDirectory = fs.realpathSync(process.cwd());
const resolveApp = relativePath => path.resolve(appDirectory, relativePath);

// We use `PUBLIC_URL` environment variable or "homepage" field to infer
// "public path" at which the app is served.
// webpack needs to know it to put the right <script> hrefs into HTML even in
// single-page apps that may serve index.html for nested URLs like /todos/42.
// We can't use a relative path in HTML because we don't want to load something
// like /todos/42/static/js/bundle.7289d.js. We have to know the root.
const publicUrlOrPath = getPublicUrlOrPath(
    process.env.NODE_ENV === 'development',
    require(resolveApp('package.json')).homepage,
    process.env.PUBLIC_URL
);

// console.log( 'process.env.PUBLIC_URL =>',  process.env.PUBLIC_URL)
const buildPath = process.env.BUILD_PATH || '../dist';
const webBuildPath = process.env.BUILD_PATH || '../dist';

const moduleFileExtensions = ['web.mjs', 'mjs', 'web.js', 'js', 'web.ts', 'ts', 'web.tsx', 'tsx', 'json', 'web.jsx', 'jsx', 'vue'];

// Resolve file paths in the same order as webpack
const resolveModule = (resolveFn, filePath) => {
    const extension = moduleFileExtensions.find(extension =>
        fs.existsSync(resolveFn(`${filePath}.${extension}`))
    );

    if (extension) {
        return resolveFn(`${filePath}.${extension}`);
    }

    return resolveFn(`${filePath}.js`);
};

const packageJson = require(resolveApp('./package.json'));

// const campaignEntryList = (entryList) => {
//     return entryList.reduce((acc, app) => {
//         acc[`${app}`] = resolveApp(`./src/${app}/index.js`);
//         return acc;
//     }, {});
// };

// config after eject: we're in ./config/
module.exports = {
    dotenv: resolveApp('.env'),
    appPath: resolveApp('.'),
    appBuild: resolveApp(buildPath),
    webAppBuild: resolveApp(webBuildPath),
    webAppStaticImages: resolveApp('static/images'),
    webAppStaticMedia: resolveApp('static/media'),
    appPublic: resolveApp('public'),
    appStatic: resolveApp('static'),
    appPackageJson: resolveApp('package.json'),
    appSrc: resolveApp('src'),
    appTsConfig: resolveApp('tsconfig.json'),
    appJsConfig: resolveApp('jsconfig.json'),
    yarnLockFile: resolveApp('yarn.lock'),
    testsSetup: resolveModule(resolveApp, 'src/setupTests'),
    proxySetup: resolveApp('src/setupProxy.js'),
    appNodeModules: resolveApp('node_modules'),
    appWebpackCache: resolveApp('node_modules/.cache'),
    appTsBuildInfoFile: resolveApp('node_modules/.cache/tsconfig.tsbuildinfo'),
    swSrc: resolveModule(resolveApp, 'src/service-worker'),
    // campaignEntryList: campaignEntryList(packageJson.campaigns),
    campaignsViewportWidth: packageJson.campaignsViewportWidth,
    publicUrlOrPath
};


module.exports.moduleFileExtensions = moduleFileExtensions;
