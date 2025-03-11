
const fs = require('node:fs');
const webpack = require('webpack');
const resolve = require('resolve');
const path = require('path');
// const CopyPlugin = require("copy-webpack-plugin");
// const TerserPlugin = require('terser-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const CssMinimizerPlugin = require('css-minimizer-webpack-plugin');
const {WebpackManifestPlugin} = require('webpack-manifest-plugin');
const CaseSensitivePathsPlugin = require('case-sensitive-paths-webpack-plugin');
const WorkboxWebpackPlugin = require('workbox-webpack-plugin');

const paths = require('./paths');
const modules = require('./modules');
const ESLintPlugin = require('eslint-webpack-plugin');
const getClientEnvironment = require('./env');
const getCSSModuleLocalIdent = require('react-dev-utils/getCSSModuleLocalIdent');

const ForkTsCheckerWebpackPlugin = process.env.TSC_COMPILE_ON_ERROR === 'true' ? require('react-dev-utils/ForkTsCheckerWarningWebpackPlugin') : require('react-dev-utils/ForkTsCheckerWebpackPlugin');
const createEnvironmentHash = require('./webpack/persistentCache/createEnvironmentHash');
// const ReactRefreshWebpackPlugin = require('@pmmmwh/react-refresh-webpack-plugin');
const {VueLoaderPlugin} = require('vue-loader');

// Source maps are resource heavy and can cause out of memory issue for large source files.
const shouldUseSourceMap = process.env.GENERATE_SOURCEMAP !== 'false';

const emitErrorsAsWarnings = process.env.ESLINT_NO_DEV_ERRORS === 'true';
const disableESLintPlugin = process.env.DISABLE_ESLINT_PLUGIN === 'true';

// Check if TypeScript is set up
const useTypeScript = fs.existsSync(paths.appTsConfig);

// Check if Tailwind config exists
const useTailwind = fs.existsSync(path.join(paths.appPath, 'tailwind.config.js'));

// Get the path to the uncompleted service worker (if it exists).
const swSrc = paths.swSrc;

// style files regexes
const cssRegex = /\.css$/;
const cssModuleRegex = /\.module\.css$/;
const sassRegex = /\.(scss|sass)$/;
const sassModuleRegex = /\.module\.(scss|sass)$/;

const hasJsxRuntime = (() => {
    if (process.env.DISABLE_NEW_JSX_TRANSFORM === 'true') {
        return false;
    }

    try {
        require.resolve('react/jsx-runtime');
        return true;
    } catch (e) {
        return false;
    }
})();


// This is the production and development configuration.
// It is focused on developer experience, fast rebuilds, and a minimal bundle.

module.exports = function (webpackEnv, entryItem, entryName) {
    //console.log('configFactory =>', webpackEnv, entryItem, entryName)
    const isEnvDevelopment = webpackEnv === 'development';
    const isEnvProduction = webpackEnv === 'production';

    // Variable used for enabling profiling in Production
    // passed into alias object. Uses a flag if passed into the build command
    const isEnvProductionProfile = isEnvProduction && process.argv.includes('--profile');

    // We will provide `paths.publicUrlOrPath` to our app
    // as %PUBLIC_URL% in `index.html` and `process.env.PUBLIC_URL` in JavaScript.
    // Omit trailing slash as %PUBLIC_URL%/xyz looks better than %PUBLIC_URL%xyz.
    // Get environment variables to inject into our app.
    const env = getClientEnvironment(paths.publicUrlOrPath.slice(0, -1));
    // const shouldUseReactRefresh = env.raw.FAST_REFRESH;

    // common function to get style loaders
    const getStyleLoaders = (cssOptions, preProcessor) => {
        const loaders = [
            { loader: MiniCssExtractPlugin.loader },
            {
                loader: 'css-loader',
                options: {
                    ...cssOptions,
                    importLoaders: cssOptions.importLoaders || 1,
                    sourceMap: isEnvProduction ? shouldUseSourceMap : isEnvDevelopment,
                },
            },
            {
                loader: 'postcss-loader',
                options: {
                    postcssOptions: {
                        ident: 'postcss',
                        config: true,
                        plugins: !useTailwind
                            ? [
                                'postcss-flexbugs-fixes',
                                ['postcss-preset-env', { autoprefixer: { flexbox: 'no-2009' }, stage: 3 }],
                                'postcss-normalize',
                                ['postcss-px-to-viewport-8-plugin', { /* 你的配置 */ }],
                            ]
                            : ['tailwindcss', 'postcss-flexbugs-fixes', ['postcss-preset-env', { autoprefixer: { flexbox: 'no-2009' }, stage: 3 }]],
                    },
                    sourceMap: isEnvProduction ? shouldUseSourceMap : isEnvDevelopment,
                },
            },
        ];
        if (preProcessor) {
            loaders.push({
                loader: require.resolve(preProcessor),
                options: { sourceMap: true },
            });
        }
        return loaders;
    };

    // noinspection JSUnresolvedReference,JSCheckFunctionSignatures
    return {
        target: ['browserslist'], // Webpack noise constrained to errors and warnings
        stats: 'errors-warnings',
        mode: isEnvProduction ? 'production' : isEnvDevelopment && 'development', // Stop compilation early in production
        bail: isEnvProduction,
        devtool: isEnvProduction ? false : isEnvDevelopment && 'eval-cheap-module-source-map', // These are the "entry points" to our application.
        // This means they will be the "root" imports that are included in JS bundle.
        entry: entryItem,
        output: {
            // The build folder.
            path: paths.webAppBuild,            // Add /* filename */ comments to generated require()s in the output.
            pathinfo: isEnvDevelopment,         // There will be one main bundle, and one file per asynchronous chunk.

            // In development, it does not produce real files.
            // filename: isEnvProduction ? 'javascript/[name].js' : isEnvDevelopment && 'javascript/[name].js',
            filename: 'javascript/[name].js',   // There are also additional JS chunk files if you use code splitting.

            // chunkFilename: isEnvProduction
            //     ? 'static/javascript/[name].[contenthash:8].chunk.js'
            //     : isEnvDevelopment && 'static/javascript/[name].chunk.js',
            // assetModuleFilename: 'media/[name].[hash][ext]',

            // webpack uses `publicPath` to determine where the app is being served from.
            // It requires a trailing slash, or the file assets will get an incorrect path.
            // We inferred the "public path" (such as / or /my-project) from homepage.
            publicPath: paths.publicUrlOrPath, // Point sourcemap entries to original disk location (format as URL on Windows)
            devtoolModuleFilenameTemplate: isEnvProduction ? info => path.relative(paths.appSrc, info['absoluteResourcePath']).replace(/\\/g, '/') : isEnvDevelopment && (info => path.resolve(info['absoluteResourcePath']).replace(/\\/g, '/'))
        },
        cache: {
            profile: true,
            type: 'filesystem',
            name: 'AppBuildCache',
            version: createEnvironmentHash(env.raw),
            cacheDirectory: paths.appWebpackCache,
            store: 'pack',
            buildDependencies: {
                defaultWebpack: ['webpack/lib/'],
                config: [__filename],
                tsconfig: [paths.appTsConfig, paths.appJsConfig].filter(f => fs.existsSync(f))
            }
        },
        infrastructureLogging: {
            colors: true,
            level: 'info'
            // debug: /PackFileCache/
        },
        optimization: {
            minimize: isEnvProduction,
            minimizer: [
                // This is only used in production mode
                // new TerserPlugin({
                //     extractComments: false,
                //     terserOptions: {
                //         parse: {
                //             // We want terser to parse ecma 8 code. However, we don't want it
                //             // to apply any minification steps that turns valid ecma 5 code
                //             // into invalid ecma 5 code. This is why the 'compress' and 'output'
                //             // sections only apply transformations that are ecma 5 safe
                //             // https://github.com/facebook/create-react-app/pull/4234
                //             ecma: 8
                //         },
                //         compress: {
                //             ecma: 5, warnings: false, // Disabled because of an issue with Uglify breaking seemingly valid code:
                //             // https://github.com/facebook/create-react-app/issues/2376
                //             // Pending further investigation:
                //             // https://github.com/mishoo/UglifyJS2/issues/2011
                //             comparisons: false, // Disabled because of an issue with Terser breaking valid code:
                //             // https://github.com/facebook/create-react-app/issues/5250
                //             // Pending further investigation:
                //             // https://github.com/terser-js/terser/issues/120
                //             inline: 2
                //         },
                //         mangle: {
                //             safari10: true
                //         }, // Added for profiling in devtools
                //         keep_classnames: isEnvProductionProfile, keep_fnames: isEnvProductionProfile, output: {
                //             ecma: 5, comments: false, // Turned on because emoji and regex is not minified properly using default
                //             // https://github.com/facebook/create-react-app/issues/2488
                //             ascii_only: true
                //         }
                //     }
                // }),
                // This is only used in production mode
                new CssMinimizerPlugin()
            ]
        },
        resolve: {
            alias: {
                'vue': 'vue/dist/vue.runtime.esm-bundler.js'
            },
            // This allows you to set a fallback for where webpack should look for modules.
            // We placed these paths second because we want `node_modules` to "win"
            // if there are any conflicts. This matches Node resolution mechanism.
            // https://github.com/facebook/create-react-app/issues/253
            modules: ['node_modules', paths.appNodeModules].concat(modules.additionalModulePaths || []), // These are the reasonable defaults supported by the Node ecosystem.
            // We also include JSX as a common component filename extension to support
            // some tools, although we do not recommend using it, see:
            // https://github.com/facebook/create-react-app/issues/290
            // `web` extension prefixes have been added for better support
            // for React Native Web.
            extensions: paths.moduleFileExtensions.map(ext => `.${ext}`).filter(ext => useTypeScript || !ext.includes('ts')),
            plugins: []
        },
        module: {
            rules: [
                shouldUseSourceMap && {
                    enforce: 'pre',
                    exclude: /@babel(?:\/|\\{1,2})runtime/,
                    test: /\.(js|mjs|jsx|ts|tsx|vue|css)$/,
                    loader: require.resolve('source-map-loader')
                },
                {
                    test: /\.vue$/,
                    exclude: /node_modules/,
                    use: {
                        loader: 'vue-loader'
                    }
                },
                {
                    // "oneOf" will traverse all following loaders until one will
                    // match the requirements. When no loader matches it will fall
                    // back to the "file" loader at the end of the loader list.
                    oneOf: [
                        // Process application JS with Babel.
                        // The preset includes JSX, Flow, TypeScript, and some ESnext features.
                        {
                            test: /\.js$/,
                            exclude: /node_modules/,
                            loader: require.resolve('babel-loader'),
                            options: {
                                presets: [[require.resolve('@babel/preset-env'), {'loose': false}]],
                                plugins: [
                                    require.resolve("@babel/plugin-proposal-class-properties"),
                                    require.resolve('@babel/plugin-proposal-private-methods'),
                                    require.resolve('@babel/plugin-proposal-private-property-in-object'),
                                    [
                                        require("@babel/plugin-transform-runtime").default,
                                        {
                                            corejs: false,
                                            helpers: true,
                                            version: require("@babel/runtime/package.json").version,
                                            regenerator: true,
                                            useESModules: true,
                                            absoluteRuntime: path.dirname(require.resolve("@babel/runtime/package.json"))
                                        }
                                    ]
                                ],
                                // This is a feature of `babel-loader` for webpack (not Babel itself).
                                // It enables caching results in ./node_modules/.cache/babel-loader/
                                // directory for faster rebuilds.
                                cacheDirectory: true, // See #6846 for context on why cacheCompression is disabled
                                cacheCompression: false,
                                compact: isEnvProduction
                            }
                        },
                        {
                            test: /\.(mjs|jsx|ts|tsx)$/,
                            include: paths.appSrc,
                            loader: require.resolve('babel-loader'),
                            options: {
                                customize: require.resolve('babel-preset-react-app/webpack-overrides'),
                                presets: [[require.resolve('babel-preset-react-app'), {
                                    runtime: hasJsxRuntime ? 'automatic' : 'classic'
                                }]],

                                // This is a feature of `babel-loader` for webpack (not Babel itself).
                                // It enables caching results in ./node_modules/.cache/babel-loader/
                                // directory for faster rebuilds.
                                cacheDirectory: true, // See #6846 for context on why cacheCompression is disabled
                                cacheCompression: false,
                                compact: isEnvProduction
                            }
                        },
                        // Process any JS outside of the app with Babel.
                        // Unlike the application JS, we only compile the standard ES features.
                        {
                            test: /\.(js|mjs)$/,
                            exclude: /@babel(?:\/|\\{1,2})runtime/,
                            loader: require.resolve('babel-loader'),
                            options: {
                                presets: [[require.resolve('babel-preset-react-app/dependencies'), {helpers: true}]],
                                babelrc: false,
                                compact: false,
                                configFile: false,
                                cacheDirectory: true, // See #6846 for context on why cacheCompression is disabled
                                cacheCompression: false,

                                // Babel sourcemaps are needed for debugging into node_modules
                                // code.  Without the options below, debuggers like VSCode
                                // show incorrect code and set breakpoints on the wrong lines.
                                sourceMaps: shouldUseSourceMap,
                                inputSourceMap: shouldUseSourceMap
                            }
                        },
                        // "postcss" loader applies autoprefixer to our CSS.
                        // "css" loader resolves paths in CSS and adds assets as dependencies.
                        // "style" loader turns CSS into JS modules that inject <style> tags.
                        // In production, we use MiniCSSExtractPlugin to extract that CSS
                        // to a file, but in development "style" loader enables hot editing
                        // of CSS.
                        // By default we support CSS Modules with the extension .module.css
                        {
                            test: sassRegex,
                            exclude: sassModuleRegex,
                            use: getStyleLoaders({
                                importLoaders: 3,
                                sourceMap: isEnvProduction ? shouldUseSourceMap : isEnvDevelopment,
                            }, 'sass-loader'),
                            // Don't consider CSS imports dead code even if the
                            // containing package claims to have no side effects.
                            // Remove this when webpack adds a warning or an error for this.
                            // See https://github.com/webpack/webpack/issues/6571
                            sideEffects: true
                        },
                        {
                            test: sassModuleRegex,
                            use: getStyleLoaders({
                                importLoaders: 3,
                                sourceMap: isEnvProduction ? shouldUseSourceMap : isEnvDevelopment,
                                modules: {
                                    mode: 'local',
                                    getLocalIdent: getCSSModuleLocalIdent
                                }
                            }, 'sass-loader')
                        },
                        {
                            test: cssRegex,
                            exclude: cssModuleRegex,
                            use: getStyleLoaders({
                                importLoaders: 1,
                                sourceMap: isEnvProduction ? shouldUseSourceMap : isEnvDevelopment,
                                modules: {
                                    mode: 'icss'
                                }
                            }), // Don't consider CSS imports dead code even if the
                            // containing package claims to have no side effects.
                            // Remove this when webpack adds a warning or an error for this.
                            // See https://github.com/webpack/webpack/issues/6571
                            sideEffects: true
                        },
                        // Adds support for CSS Modules (https://github.com/css-modules/css-modules)
                        // using the extension .module.css
                        {
                            test: cssModuleRegex,
                            use: getStyleLoaders({
                                importLoaders: 1,
                                sourceMap: isEnvProduction ? shouldUseSourceMap : isEnvDevelopment,
                                modules: {
                                    mode: 'local', getLocalIdent: getCSSModuleLocalIdent
                                }
                            })
                        },
                        {
                            test: /\.less$/, use: [MiniCssExtractPlugin.loader, 'css-loader', {
                                loader: 'less-loader', options: {
                                    implementation: require('less'), javascriptEnabled: true
                                }
                            }]
                        },
                        {
                            test: /\.html$/i,
                            loader: 'html-loader'
                        },
                        {
                            test: /\.(ttf|otf|eot|woff)/, type: 'asset/resource', generator: {
                                filename: ({filename}) => {
                                    // console.log('asset/resource pathData =>', pathData, 'asset/resource assetInfo =>', assetInfo);
                                    let itemFilename = filename.replace('src/', '').split(/\/fonts\//)[0];
                                    return `assets/${itemFilename}/[name][contenthash][ext]`;
                                }
                            }
                        },
                        {
                            test: /\.txt|.glsl$/i,
                            use: 'raw-loader'
                        },
                        {
                            test: /\.(riv|wasm|mp3|wav|mp4|pdf|doc|docx)$/,
                            type: 'asset/resource',
                            generator: {
                                filename: ({filename}) => {
                                    // console.log('asset/resource pathData =>', filename);
                                    let itemFilename
                                    if (filename.includes('static')) {
                                        itemFilename = filename.replace('src/', '').split(/\/static\//)[0];
                                        return `resources/${itemFilename}/[name][ext]`;
                                    }

                                    if (filename.includes('assets')) {
                                        itemFilename = filename.replace('src/', '').split(/\/assets\//)[0];
                                        return `resources/${itemFilename}/[name][contenthash][ext]`;
                                    }
                                }
                            }
                        },
                        {
                            test: /\.(avif|png|jpg|jpeg|gif|bmp|svg|webp)$/,
                            type: 'asset/resource',
                            generator: {
                                filename: ({filename}) => {
                                    // console.log('asset/resource pathData =>', pathData, 'asset/resource assetInfo =>', assetInfo);
                                    let itemFilename = filename.includes('assets') ? filename.replace('src/', '').split(/\/assets\//)[0] : ''
                                    return `assets/${itemFilename}/[name][contenthash][ext]`;
                                }
                            }
                        }]
                }].filter(Boolean)
        },
        plugins: [
            new VueLoaderPlugin(),
            // Otherwise React will be compiled in the very slow development mode.
            new webpack.DefinePlugin({
                ...env.stringified, // Experimental hot reloading for React.
                __VUE_OPTIONS_API__: true,
                __VUE_PROD_DEVTOOLS__: true
            }),

            // Watcher doesn't work well if you mistype casing in a path, so we use
            // a plugin that prints an error when you attempt to do this.
            // See https://github.com/facebook/create-react-app/issues/240
            isEnvDevelopment && new CaseSensitivePathsPlugin(),
            new MiniCssExtractPlugin({
                // Options similar to the same options in webpackOptions.output
                // both options are optional.
                filename: 'styles/[name].css', runtime: false
                // chunkFilename: 'static/css/[name].[contenthash:8].chunk.css'
            }),

            // fs.existsSync(path.resolve(__dirname, `../src/${entryName}/static/`)) && new CopyPlugin({
            //     patterns: [
            //         {
            //             from: path.resolve(__dirname, `../src/${entryName}/static/`),
            //             to: path.resolve(__dirname, `../../apps/lucy_web/priv/static/resources/${entryName}/`)
            //         }
            //     ],
            // }),

            
            // Generate an asset manifest file with the following content:
            // - "files" key: Mapping of all asset filenames to their corresponding
            //   output file so that tools can pick it up without having to parse
            //   `index.html`
            // - "entrypoints" key: Array of files which are included in `index.html`,
            //   can be used to reconstruct the HTML if necessary
            new WebpackManifestPlugin({
                fileName: `${entryName}_asset_manifest.json`,
                publicPath: paths.publicUrlOrPath,
                generate: (seed, files, entrypoints) => {

                    const manifestFiles = files.reduce((manifest, file) => {
                        manifest[file.name] = file.path;
                        return manifest;
                    }, seed);

                    const entrypointFiles = Object.keys(entrypoints).reduce((previousValue, currentValue) => {
                        previousValue[currentValue] = entrypoints[currentValue].filter(fileName => !fileName.endsWith('.map') && fileName.endsWith('.js'))[0];
                        return previousValue;
                    }, {});

                    // console.log('WebpackManifestPlugin', manifestFiles, entrypointFiles);
                    return {
                        files: manifestFiles, entrypoints: entrypointFiles
                    };
                }
            }),

            // Moment.js is an extremely popular library that bundles large locale files
            // by default due to how webpack interprets its code. This is a practical
            // solution that requires the user to opt into importing specific locales.
            // https://github.com/jmblog/how-to-optimize-momentjs-with-webpack
            // You can remove this if you don't use Moment.js:
            new webpack.IgnorePlugin({
                resourceRegExp: /^\.\/locale$/, contextRegExp: /moment$/
            }), // Generate a service worker script that will precache, and keep up to date,
            // the HTML & assets that are part of the webpack build.
            isEnvProduction && fs.existsSync(swSrc) && new WorkboxWebpackPlugin.InjectManifest({
                swSrc,
                dontCacheBustURLsMatching: /\.[0-9a-f]{8}\./,
                exclude: [/\.map$/, /asset-manifest\.json$/, /LICENSE/], // Bump up the default maximum size (2mb) that's precached,
                // to make lazy-loading failure scenarios less likely.
                // See https://github.com/cra-template/pwa/issues/13#issuecomment-722667270
                maximumFileSizeToCacheInBytes: 5 * 1024 * 1024
            }), // TypeScript type checking
            useTypeScript && new ForkTsCheckerWebpackPlugin({
                async: isEnvDevelopment, typescript: {
                    typescriptPath: resolve.sync('typescript', {
                        basedir: paths.appNodeModules
                    }), configOverwrite: {
                        compilerOptions: {
                            sourceMap: isEnvProduction ? shouldUseSourceMap : isEnvDevelopment,
                            skipLibCheck: true,
                            inlineSourceMap: false,
                            declarationMap: false,
                            noEmit: true,
                            incremental: true,
                            tsBuildInfoFile: paths.appTsBuildInfoFile
                        }
                    }, context: paths.appPath, diagnosticOptions: {
                        syntactic: true
                    }, mode: 'write-references'
                    // profile: true,
                },
                issue: {
                    // This one is specifically to match during CI tests,
                    // as micromatch doesn't match
                    // '../cra-template-typescript/template/src/App.tsx'
                    // otherwise.
                    include: [{file: '../**/src/**/*.{ts,tsx}'}, {file: '**/src/**/*.{ts,tsx}'}],
                    exclude: [{file: '**/src/**/__tests__/**'}, {file: '**/src/**/?(*.){spec|test}.*'}, {file: '**/src/setupProxy.*'}, {file: '**/src/setupTests.*'}]
                },
                logger: {
                    infrastructure: 'silent'
                }
            }),
            !disableESLintPlugin && new ESLintPlugin({
                // Plugin options
                extensions: ['js', 'mjs', 'jsx', 'ts', 'tsx'],
                formatter: require.resolve('react-dev-utils/eslintFormatter'),
                eslintPath: require.resolve('eslint'),
                failOnError: !(isEnvDevelopment && emitErrorsAsWarnings),
                context: paths.appSrc,
                cache: true,
                cacheLocation: path.resolve(paths.appNodeModules, '.cache/.eslintcache'), // ESLint class options
                cwd: paths.appPath,
                resolvePluginsRelativeTo: __dirname,
                baseConfig: {
                    extends: [require.resolve('eslint-config-react-app/base')], rules: {
                        ...(!hasJsxRuntime && {
                            'react/react-in-jsx-scope': 'error'
                        })
                    }
                }
            })].filter(Boolean), // Turn off performance processing because we utilize
        // our own hints via the FileSizeReporter
        performance: {
            hints: false
        }
    };
};
