// noinspection JSUnresolvedReference,JSCheckFunctionSignatures

'use strict';

// Do this as the first thing so that any code reading it knows the right env.
process.env.BABEL_ENV = 'development';
process.env.NODE_ENV = 'development';

// Makes the script crash on unhandled rejections instead of silently
// ignoring them. In the future, promise rejections that are not handled will
// terminate the Node.js process with a non-zero exit code.
process.on('unhandledRejection', err => {
    throw err;
});

// Ensure environment variables are read.
require('../config/env');

const bfj = require('bfj');
const fs = require('node:fs');
const fsEx = require('fs-extra');
const webpack = require('webpack');
const path = require('path');
const chalk = require('react-dev-utils/chalk');
const paths = require('../config/paths');
const configFactory = require('../config/webpack.config');
const checkRequiredFiles = require('react-dev-utils/checkRequiredFiles');
const formatWebpackMessages = require('react-dev-utils/formatWebpackMessages');
const printHostingInstructions = require('react-dev-utils/printHostingInstructions');
const FileSizeReporter = require('react-dev-utils/FileSizeReporter');
const printBuildError = require('react-dev-utils/printBuildError');

const measureFileSizesBeforeBuild = FileSizeReporter.measureFileSizesBeforeBuild;
const printFileSizesAfterBuild = FileSizeReporter.printFileSizesAfterBuild;

// These sizes are pretty large. We'll warn for bundles exceeding them.
const WARN_AFTER_BUNDLE_GZIP_SIZE = 512 * 1024;
const WARN_AFTER_CHUNK_GZIP_SIZE = 1024 * 1024;

const isInteractive = process.stdout.isTTY;
const useYarn = fs.existsSync(paths.yarnLockFile);


const argv = process.argv.slice(2);
const writeStatsJson = argv.indexOf('--stats') !== -1;

const appDirectory = fs.realpathSync(process.cwd());
const resolveApp = relativePath => path.resolve(appDirectory, relativePath);
const packageJson = require(resolveApp('./package.json'));

const campaignEntryList = (entryList) => {
    return entryList.reduce((acc, app) => {
        acc.push({[`${app}`]: resolveApp(`./src/${app}/index.js`)});
        return acc;
    }, []);
};

// Generate configuration
// const config= configFactory('development');
const config = campaignEntryList(packageJson.campaigns).map(item => {
    return configFactory('development', item, Object.keys(item)[0]);
})

// We require that you explicitly set browsers and do not fall back to
// browserslist defaults.
const {checkBrowsers} = require('react-dev-utils/browsersHelper');
checkBrowsers(paths.appPath, isInteractive)
    .then(() => {
        // First, read the current file sizes in build directory.
        // This lets us display how much they changed later.
        return measureFileSizesBeforeBuild(paths.webAppBuild);
    })
    .then(previousFileSizes => {
        // Remove all content but keep the directory so that
        // if you're in it, you don't end up in Trash
        fs.realpathSync(paths.webAppBuild);
        // Merge with the public folder
        copyStaticFolder();
        // Start the webpack build
        return build(previousFileSizes);
    })
    .then(
        ({stats, previousFileSizes, warnings}) => {
            if (warnings.length) {
                console.log(chalk.yellow('Compiled with warnings.\n'));
                console.log(warnings.join('\n\n'));
                console.log(
                    '\nSearch for the ' +
                    chalk.underline(chalk.yellow('keywords')) +
                    ' to learn more about each warning.'
                );
                console.log(
                    'To ignore, add ' +
                    chalk.cyan('// eslint-disable-next-line') +
                    ' to the line before.\n'
                );
            } else {
                console.log(chalk.green('Compiled successfully.\n'));
            }

            console.log(chalk.green('File sizes after gzip:\n'));
            printFileSizesAfterBuild(
                stats,
                previousFileSizes,
                paths.appBuild,
                WARN_AFTER_BUNDLE_GZIP_SIZE,
                WARN_AFTER_CHUNK_GZIP_SIZE
            );

            console.log();

            const appPackage = require(paths.appPackageJson);
            const publicUrl = paths.publicUrlOrPath;
            const publicPath = paths.publicUrlOrPath;
            const buildFolder = path.relative(process.cwd(), paths.webAppBuild);
            printHostingInstructions(
                appPackage,
                publicUrl,
                publicPath,
                buildFolder,
                useYarn
            );
        },
        err => {
            const tscCompileOnError = process.env.TSC_COMPILE_ON_ERROR === 'true';
            if (tscCompileOnError) {
                console.log(
                    chalk.yellow(
                        'Compiled with the following type errors (you may want to check these before deploying your app):\n'
                    )
                );
                printBuildError(err);
            } else {
                console.log(chalk.red('Failed to compile.\n'));
                printBuildError(err);
                process.exit(1);
            }
        }
    )
    .catch(err => {
        if (err && err.message) {
            console.log(err.message);
        }
        process.exit(1);
    });

// Create the development build and print the deployment instructions.
function build(previousFileSizes) {

    console.log(chalk.cyan('Creating an optimized development build...\n'));

    const compiler = webpack(config);

    return new Promise((resolve, reject) => {
        compiler.watch({
            //watchOptions:
            aggregateTimeout: 500,
            ignored: '**/node_modules',
            poll: 1000, // 每秒检查一次变动
            stdin: true,

        }, (err, stats) => {
            let messages;
            if (err) {
                if (!err.message) {
                    return reject(err);
                }

                let errMessage = err.message;

                // Add additional information for postcss errors
                if (Object.prototype.hasOwnProperty.call(err, 'postcssNode')) {
                    errMessage +=
                        '\nCompileError: Begins at CSS selector ' +
                        err['postcssNode'].selector;
                }

                messages = formatWebpackMessages({
                    errors: [errMessage],
                    warnings: []
                });
            } else {
                messages = formatWebpackMessages(
                    stats.toJson({all: false, warnings: true, errors: true})
                );
            }
            if (messages.errors.length) {
                // Only keep the first error. Others are often indicative
                // of the same problem, but confuse the reader with noise.
                if (messages.errors.length > 1) {
                    messages.errors.length = 1;
                }
                return reject(new Error(messages.errors.join('\n\n')));
            }
            if (
                process.env.CI &&
                (typeof process.env.CI !== 'string' ||
                    process.env.CI.toLowerCase() !== 'false') &&
                messages.warnings.length
            ) {
                // Ignore sourcemap warnings in CI builds. See #8227 for more info.
                const filteredWarnings = messages.warnings.filter(
                    w => !/Failed to parse source map/.test(w)
                );
                if (filteredWarnings.length) {
                    console.log(
                        chalk.yellow(
                            '\nTreating warnings as errors because process.env.CI = true.\n' +
                            'Most CI servers set it automatically.\n'
                        )
                    );
                    return reject(new Error(filteredWarnings.join('\n\n')));
                }
            }

            const resolveArgs = {
                stats,
                previousFileSizes,
                warnings: messages.warnings
            };

            console.log(chalk.magenta('watching stats =>', process.stdout.write(stats.toString({
                chunks: false, // 使构建过程更静默无输出
                colors: true,  // 在控制台展示颜色
            }) + '\n')));

            if (writeStatsJson) {
                return bfj
                    .write(paths.appBuild + '/bundle-stats.json', stats.toJson())
                    .then(() => resolve(resolveArgs))
                    .catch(error => reject(new Error(error)));
            }

            return resolve(resolveArgs);
        });

    });
}

function copyStaticFolder() {
    fsEx.copySync(paths.appStatic, paths.webAppBuild, {dereference: true});
}
