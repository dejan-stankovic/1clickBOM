fs    = require("fs")
path  = require("path")
child_process = require("child_process")

join = (p1,p2) ->
    path.join(p1, "/" + p2)

EXTENSION_NAME = "1clickBOM"

COFFEE_DIR    = "src/coffee"
HTML_DIR      = "src/html"
DATA_DIR      = "src/data"
LIBS_DIR      = "libs"
TEST_LIBS_DIR = "test_libs"
IMAGES_DIR    = "images"
CHROME_DIR    = "chrome"
FIREFOX_DIR   = "firefox"
JS_DIR        = "js"
JS_TESTS_DIR  = "js/tests"
EXAMPLES_DIR  = "examples"

CHROME_MANIFEST  = "src/manifest.json"
FIREFOX_MANIFEST = "src/package.json"

PACKAGE_DIR = "../"

HTML_CHROME_DEST_DIR      = "html"
DATA_CHROME_DEST_DIR      = "data"
EXAMPLES_CHROME_DEST_DIR  = "examples"
LIBS_CHROME_DEST_DIR      = "libs"
TEST_LIBS_CHROME_DEST_DIR = "libs"
IMAGES_CHROME_DEST_DIR    = "images"
JS_CHROME_DEST_DIR        = "js"
TEST_LIBS_CHROME_DEST_DIR = "libs"
FIREFOX_MAIN_JS        = "js/firefox_main.js"

HTML_FIREFOX_DEST_DIR      = "data/html"
DATA_FIREFOX_DEST_DIR      = "data/data"
EXAMPLES_FIREFOX_DEST_DIR  = "data/examples"
LIBS_FIREFOX_DEST_DIR      = "data/libs"
TEST_LIBS_FIREFOX_DEST_DIR = "data/libs"
IMAGES_FIREFOX_DEST_DIR    = "data/images"
JS_FIREFOX_DEST_DIR        = "data/js"
FIREFOX_MAIN_DEST_DIR      = "lib"

FIREFOX_PORT = "8888"

ROOT_PATH      = __dirname
COFFEE_PATH    = join(ROOT_PATH, COFFEE_DIR)
HTML_PATH      = join(ROOT_PATH, HTML_DIR)
DATA_PATH      = join(ROOT_PATH, DATA_DIR)
LIBS_PATH      = join(ROOT_PATH, LIBS_DIR)
TEST_LIBS_PATH = join(ROOT_PATH, TEST_LIBS_DIR)
IMAGES_PATH    = join(ROOT_PATH, IMAGES_DIR)
JS_PATH        = join(ROOT_PATH, JS_DIR)
CHROME_PATH    = join(ROOT_PATH, CHROME_DIR)
FIREFOX_PATH   = join(ROOT_PATH, FIREFOX_DIR)
JS_TESTS_PATH  = join(ROOT_PATH, JS_TESTS_DIR)
EXAMPLES_PATH  = join(ROOT_PATH, EXAMPLES_DIR)
CHROME_MANIFEST_PATH  = join(ROOT_PATH, CHROME_MANIFEST)
FIREFOX_MANIFEST_PATH = join(ROOT_PATH, FIREFOX_MANIFEST)
FIREFOX_MAIN_JS_PATH = join(ROOT_PATH, FIREFOX_MAIN_JS)

HTML_CHROME_DEST_PATH      = join(CHROME_PATH, HTML_CHROME_DEST_DIR)
DATA_CHROME_DEST_PATH      = join(CHROME_PATH, DATA_CHROME_DEST_DIR)
LIBS_CHROME_DEST_PATH      = join(CHROME_PATH, LIBS_CHROME_DEST_DIR)
TEST_LIBS_CHROME_DEST_PATH = join(CHROME_PATH, TEST_LIBS_CHROME_DEST_DIR)
IMAGES_CHROME_DEST_PATH    = join(CHROME_PATH, IMAGES_CHROME_DEST_DIR)
JS_CHROME_DEST_PATH        = join(CHROME_PATH, JS_CHROME_DEST_DIR)
EXAMPLES_CHROME_DEST_PATH  = join(CHROME_PATH, EXAMPLES_CHROME_DEST_DIR)
CHROME_MANIFEST_DEST_PATH  = join(CHROME_PATH, "manifest.json")

HTML_FIREFOX_DEST_PATH      = join(FIREFOX_PATH, HTML_FIREFOX_DEST_DIR)
DATA_FIREFOX_DEST_PATH      = join(FIREFOX_PATH, DATA_FIREFOX_DEST_DIR)
LIBS_FIREFOX_DEST_PATH      = join(FIREFOX_PATH, LIBS_FIREFOX_DEST_DIR)
TEST_LIBS_FIREFOX_DEST_PATH = join(FIREFOX_PATH, TEST_LIBS_FIREFOX_DEST_DIR)
IMAGES_FIREFOX_DEST_PATH    = join(FIREFOX_PATH, IMAGES_FIREFOX_DEST_DIR)
JS_FIREFOX_DEST_PATH        = join(FIREFOX_PATH, JS_FIREFOX_DEST_DIR)
EXAMPLES_FIREFOX_DEST_PATH  = join(FIREFOX_PATH, EXAMPLES_FIREFOX_DEST_DIR)
FIREFOX_MANIFEST_DEST_PATH  = join(FIREFOX_PATH, "package.json")
FIREFOX_MAIN_JS_DEST_PATH  = join(FIREFOX_PATH + "/" + FIREFOX_MAIN_DEST_DIR , "main.js")

log = (data)->
  console.log data.toString()

spawn = (cmd, args, exit_callback, update_callback)->
    ps = child_process.spawn(cmd, args)
    ps.stdout.on "data", (data) ->
        if update_callback? then update_callback(data)
        log(data)
    ps.stderr.on("data", log)
    ps.on "exit", (code)->
        if code != 0
            console.log "failed"
        if exit_callback? then exit_callback(code)
    return ps

isOnPath = (exe) ->
    present = false
    process.env.PATH.split(":").forEach (value, index, array)->
        present ||= fs.existsSync(join(value,exe))
    unless present
        console.log("'" + exe + "'" + " can't be found in your $PATH.")
        process.exit(-1)

getVersion = (callback)->
    isOnPath "coffee"
    ps = child_process.spawn "coffee", ["--version"]
    ps.stdout.on "data", (data) ->
        v = []
        for n in data.toString().split(" ")[2].split(".")
            v.push(parseInt(n))
        callback(v)

stat = (p) ->
    #statSync throws ENOENT errors on files that where deleted at symlink
    #source
    try
        stats = fs.statSync(p)
    catch err
        unless err.code == "ENOENT"
            throw(err)
    return stats

rmFilesInDirRecursive = (rm_path) ->
    files = fs.readdirSync(rm_path)
    for file in files
        p = join(rm_path,file)
        stats = stat(p)
        if stats? && stats.isDirectory()
            rmDirRecursive(p)
        else
            fs.unlinkSync(p)

rmDirRecursive = (rm_path) ->
    stats = stat(rm_path)
    if stats? && stats.isDirectory()
        rmFilesInDirRecursive(rm_path)
        fs.rmdirSync(rm_path)

linkRecursive = (src_path, dest_path) ->
    unless fs.existsSync(dest_path)
        fs.mkdirSync(dest_path)
    files = fs.readdirSync(src_path)
    for file in files
        p = join(src_path,file)
        stats = stat(p)
        if stats? && stats.isDirectory()
            linkRecursive(p, join(dest_path, file))
        else unless fs.existsSync(join(dest_path, file))
                fs.symlinkSync(p, join(dest_path, file))

linkRecursiveDist = () ->
    rmDirRecursive(FIREFOX_PATH)
    rmDirRecursive(CHROME_PATH)
    fs.mkdirSync(FIREFOX_PATH)
    fs.mkdirSync(join(FIREFOX_PATH, "data"))
    fs.mkdirSync(join(FIREFOX_PATH, "lib"))
    fs.mkdirSync(CHROME_PATH)
    fs.symlinkSync(CHROME_MANIFEST_PATH, CHROME_MANIFEST_DEST_PATH)
    fs.symlinkSync(FIREFOX_MANIFEST_PATH, FIREFOX_MANIFEST_DEST_PATH)
    fs.symlinkSync(FIREFOX_MAIN_JS_PATH, FIREFOX_MAIN_JS_DEST_PATH)
    linkRecursive(HTML_PATH, HTML_CHROME_DEST_PATH)
    linkRecursive(HTML_PATH, HTML_FIREFOX_DEST_PATH)
    linkRecursive(DATA_PATH, DATA_CHROME_DEST_PATH)
    linkRecursive(DATA_PATH, DATA_FIREFOX_DEST_PATH)
    linkRecursive(LIBS_PATH, LIBS_CHROME_DEST_PATH)
    linkRecursive(LIBS_PATH, LIBS_FIREFOX_DEST_PATH)
    linkRecursive(IMAGES_PATH, IMAGES_CHROME_DEST_PATH)
    linkRecursive(IMAGES_PATH, IMAGES_FIREFOX_DEST_PATH)
    linkRecursive(JS_PATH, JS_CHROME_DEST_PATH)
    linkRecursive(JS_PATH, JS_FIREFOX_DEST_PATH)

linkRecursiveAll = () ->
    linkRecursiveDist()
    linkRecursive(TEST_LIBS_PATH, TEST_LIBS_CHROME_DEST_PATH)
    linkRecursive(TEST_LIBS_PATH, TEST_LIBS_FIREFOX_DEST_PATH)
    linkRecursive(EXAMPLES_PATH, EXAMPLES_CHROME_DEST_PATH)
    linkRecursive(EXAMPLES_PATH, EXAMPLES_FIREFOX_DEST_PATH)

compile = (args, callback) ->
    isOnPath "coffee"
    rmDirRecursive(JS_PATH)
    ps = spawn "coffee", args, () ->
        if callback? then callback()

maybeAddMap = (version, args) ->
    if version > [1,6,1]
        args.unshift("--map")
    else
        console.log("Warning: not generating source maps because
                     CoffeeScript version is < 1.6.1")
    return args

task "build"
    , "Make symlinks and compile coffeescript"
    , ->
        getVersion (version) ->
            args = ["--output", JS_PATH,"--compile", COFFEE_PATH]
            args = maybeAddMap(version, args)
            compile args, () ->
                linkRecursiveAll()

watch = (path, callback) ->
    fs.watchFile(path, { persistent: true, interval: 1000 }, callback)

task "watch"
    , "Make symlinks and re-compile coffeescript automatically, watching for
       changes"
    , ->
        isOnPath "coffee"
        linkRecursiveAll()
        console.log("/Every move you make/")
        watch HTML_PATH, ->
            console.log("/Every html file you write/")
            linkRecursive(HTML_PATH, HTML_FIREFOX_DEST_PATH)
            linkRecursive(HTML_PATH, HTML_CHROME_DEST_PATH)
        watch DATA_PATH, ->
            console.log("/Every data file you change/")
            linkRecursive(DATA_PATH, DATA_FIREFOX_DEST_PATH)
            linkRecursive(DATA_PATH, DATA_CHROME_DEST_PATH)
        watch IMAGES_PATH, ->
            console.log("/Every image you draw/")
            linkRecursive(IMAGES_PATH, IMAGES_FIREFOX_DEST_PATH)
            linkRecursive(IMAGES_PATH, IMAGES_CHROME_DEST_PATH)
        watch LIBS_PATH, ->
            console.log("/Every lib you add/")
            linkRecursive(LIBS_PATH, LIBS_FIREFOX_DEST_PATH)
            linkRecursive(LIBS_PATH, LIBS_CHROME_DEST_PATH)
        watch TEST_LIBS_PATH, ->
            console.log("/Every test lib you add/")
            linkRecursive(TEST_LIBS_PATH, TEST_LIBS_FIREFOX_DEST_PATH)
            linkRecursive(TEST_LIBS_PATH, TEST_LIBS_CHROME_DEST_PATH)
        watch EXAMPLES_PATH, ->
            console.log("/Every example you make/")
            linkRecursive(EXAMPLES_PATH, EXAMPLES_FIREFOX_DEST_PATH)
            linkRecursive(EXAMPLES_PATH, EXAMPLES_CHROME_DEST_PATH)
        getVersion (version) ->
            args = ["--output", JS_PATH,"--compile", COFFEE_PATH]
            args = maybeAddMap(version, args)
            watch COFFEE_PATH, () ->
                console.log("/Every step you take/")
                compile args, (code) ->
                    if code == 0
                        linkRecursive(JS_PATH, JS_FIREFOX_DEST_PATH)
                        linkRecursive(JS_PATH, JS_CHROME_DEST_PATH)
            compile args, (code) ->
                if code == 0
                    linkRecursiveAll()

uglifyRecursive = (callback) ->
    if fs.statSync(JS_PATH).isDirectory()
        files = fs.readdirSync(JS_PATH)
        count = files.length
        for file in files
            p = join(JS_PATH,file)
            stats = fs.statSync(p)
            if stats? && stats.isDirectory()
                uglifyRecursive p, join(dest_path, file), ()->
                    count--
                    if count == 0 && callback? then callback()
            else
                spawn "uglifyjs2", ["--overwrite", p], () ->
                    count--
                    if count == 0 && callback? then callback()

task "package"
    , "Make packages ready for distribution in " + PACKAGE_DIR
    , ->
        isOnPath "coffee"
        isOnPath "zip"
        isOnPath "cfx"
        isOnPath "uglifyjs2"
        args = ["--output", JS_PATH,"--compile", COFFEE_PATH]
        compile args, () ->
            rmDirRecursive(JS_TESTS_PATH)
            uglifyRecursive () ->
                linkRecursiveDist()
                manifest = JSON.parse(fs.readFileSync(join(CHROME_PATH, "manifest.json")))
                chrome_name = EXTENSION_NAME + "-chrome-v" + manifest.version
                chrome_tmp_path = join(ROOT_PATH,chrome_name)
                fs.mkdirSync(chrome_tmp_path)
                chrome_package_path = join(ROOT_PATH + "/" + PACKAGE_DIR, chrome_name + ".zip")
                if fs.existsSync(chrome_package_path)
                    fs.unlinkSync(chrome_package_path)
                linkRecursive(CHROME_PATH, chrome_tmp_path)
                spawn "zip", ["-r" , chrome_package_path, chrome_name], ->
                    rmDirRecursive(chrome_tmp_path)
                fpackage = JSON.parse(fs.readFileSync(join(FIREFOX_PATH, "package.json")))
                firefox_name = EXTENSION_NAME + "-firefox-v" + fpackage.version
                firefox_package_path = join(ROOT_PATH + "/" + PACKAGE_DIR, firefox_name + ".xpi")
                spawn "cfx", ["--pkgdir=" + FIREFOX_PATH
                             , "--output-file=" + firefox_package_path
                             , "xpi"
                             ]

# this sends the extension to the auto-installer extension
# https://addons.mozilla.org/en-US/firefox/addon/autoinstaller/
# the 500 no-content error is normal
task "reload-firefox"
    , "Build a temporary xpi and send to the Firefox auto-installer on port " + FIREFOX_PORT
    , ->
        isOnPath "cfx"
        isOnPath "wget"
        spawn "cfx", ["--pkgdir=" + FIREFOX_PATH, "--output-file=tmp.xpi", "xpi"], ->
                console.log("Sending extension to Firefox on port " + FIREFOX_PORT)
                child_process.spawn "wget", ["--post-file=tmp.xpi", "http://localhost:" + FIREFOX_PORT]