package gasm.assets;
import haxe.Http;
import haxe.crypto.Base64;
import haxe.ds.IntMap;
import haxe.ds.StringMap;
import haxe.io.Bytes;

using Lambda;
using StringTools;

class Loader {
    var _imageFolder = 'image';
    var _soundFolder = 'sound';
    var _fontFolder = 'font';
    var _localizedFolder = 'localized';
    var _defaultLocale = 'en';
    var _commonFolder = 'common';

    var _content:FileEntry;
    var _commonContent:FileEntry;
    var _platformContent:FileEntry;
    var _platform:String;
    var _locale:String;
    var _extensionHandlers:IntMap<HandlerItem -> Void>;
    var _loadingQueue:Array<QueueItem>;
    var _formats:Array<FormatType>;

    var _loadedBytes:StringMap<Int>;
    var _totalBytes:Int;

    /**
	 * Create asset loader. 
	 * 
	 * Can handle scenarios where you have a skin/branding, multiple platform packs (for example mobile/desktop), localized assets and multiple file types.
	 * 
	 * @param	descriptorPath - Path to asset folder descriptor created with npm directory-tree
	 * @param 	config	- Loader configuration object
	 */
    public function new(descriptorPath:String, ?config:AssetConfig) {
        config = config != null ? config : {};
        _platform = config.platform;
        _locale = config.locale;
        _formats = config.formats;
        _imageFolder = config.imageFolder != null ? config.imageFolder : _imageFolder;
        _soundFolder = config.soundFolder != null ? config.soundFolder : _soundFolder;
        _fontFolder = config.fontFolder != null ? config.fontFolder : _fontFolder;
        _defaultLocale = config.defaultLocale != null ? config.defaultLocale : _defaultLocale;
        _commonFolder = config.commonFolder != null ? config.commonFolder : _commonFolder;
        _localizedFolder = config.localizedFolder != null ? config.localizedFolder : _localizedFolder;
        _extensionHandlers = new IntMap<HandlerItem -> Void>();
        _loadingQueue = [];
        _loadedBytes = new StringMap<Int>();
        var http = new Http(descriptorPath);
        http.onData = function(data) {
            var parsedData = haxe.Json.parse(data);
            if (config.pack != null) {
                _content = cast parsedData.children.find(function(item) { return item.name == config.pack; });
            } else {
                _content = cast parsedData;
            }
            if (config.platform != null) {
                _commonContent = _content.children.find(function(item) { return item.name == _commonFolder; });
                _platformContent = _content.children.find(function(item) { return item.name == config.platform; });
            } else {
                _commonContent = _content;
            }
            onReady();
        };
        http.onError = function(error) {
            trace('error: $error');
        };
        http.request();
    }

    public function load() {
        _totalBytes = _loadingQueue.fold(function(curr:QueueItem, last:Int) {
            var size = curr.extra != null ? curr.extra.size + curr.size : curr.size;
            return (size + last);
        }, 0);
        for (item in _loadingQueue) {
            loadItem(item, _extensionHandlers.get(item.type.getIndex()));
            if (item.extra != null) {
                loadItem(item.extra, _extensionHandlers.get(item.extra.type.getIndex()));
            }
        }
    }

    public function addHandler(type:AssetType, handler:HandlerItem -> Void) {
        _extensionHandlers.set(type.getIndex(), handler);
    }

    public function queueItem(id:String, type:AssetType) {
        var entry = getEntry(id, type);
        _loadingQueue.push({
            type: type,
            name: entry.name,
            path: entry.path,
            size: entry.size,
            extension: entry.extension,
            extra: entry.extra == null ? null : {
                type: AssetType.BitmapFontImage,
                name:entry.extra.name,
                path:entry.extra.path,
                size:entry.extra.size,
                extension:entry.extra.extension,
            }
        });
    }

    dynamic public function onReady() {

    }

    dynamic public function onComplete() {

    }

    dynamic public function onProgress(percentDone:Int) {

    }

    dynamic public function onError(error:String) {

    }

    function loadItem(item:QueueItem, ?handler:HandlerItem -> Void) {
        #if js
		var request = new js.html.XMLHttpRequest();
		request.open('GET', item.path, true);
		request.responseType = js.html.XMLHttpRequestResponseType.ARRAYBUFFER;
		request.onload = function (event) {
			if (request.status != 200) {
				onError(request.statusText);
				return;
			}
			var bytes = haxe.io.Bytes.ofData(request.response);
			switch (item.type) {
				case AssetType.Font:
					var fontResourceName = 'R_font_' + item.name;
					untyped  {
						var s = js.Browser.document.createStyleElement();
						s.type = "text/css";
						s.innerHTML = "@font-face{ font-family: " + fontResourceName + "; src: url('data:font/ttf;base64," + Base64.encode(bytes) + "') format('truetype'); }";
						js.Browser.document.getElementsByTagName('head')[0].appendChild(s);
						// create a div in the page to force font loading
						var div = js.Browser.document.createDivElement();
						div.style.fontFamily = fontResourceName;
						div.style.opacity = 0;
						div.style.width = "1px";
						div.style.height = "1px";
						div.style.position = "fixed";
						div.style.bottom = "0px";
						div.style.right = "0px";
						div.innerHTML = ".";
						div.className = "hx__loadFont";
						js.Browser.document.body.appendChild(div);
					};	
				default: null;
			}
			if(handler != null) {
				handler({id:item.name, data:bytes, path:item.path});
			}
		};    
		request.onprogress = function(event:js.html.ProgressEvent) {
			handleProgress(Std.int(event.loaded), item.path, Std.int(event.total));
		}
		request.send(null);
		#else
        throw 'NOT IMPLEMENTED';
        #end
    }

    function getEntry(name:String, type:AssetType):FileEntry {
        var typeFolder = switch(type) {
            case AssetType.Image: _imageFolder;
            case AssetType.Sound: _soundFolder;
            case AssetType.Font | AssetType.BitmapFont: _fontFolder;
            default: null;
        }
        var platformFolder:FileEntry = null;
        if (_platformContent != null) {
            platformFolder = _platformContent.children.find(function(item) { return item.name == typeFolder; });
        }
        var commonFolder:FileEntry = _commonContent.children.find(function(item) { return item.name == typeFolder; });
        function getFilesFromFolder(folder:FileEntry, locale:String):Array<FileEntry> {
            if(folder == null) {
                return null;
            }
            var matches:Array<FileEntry>;
            var localized = folder.children.find(function(item) { return item.name == _localizedFolder; });
            if (localized != null) {
                var localeDir = localized.children.find(function(item) { return item.name == locale && item.type == 'directory'; });
                if (localeDir == null) {
                    trace('locale $_locale not found, reverting to en');
                    localeDir = localized.children.find(function(item) { return item.name == _defaultLocale && item.type == 'directory'; });
                    if (localeDir == null) {
                        onError('Locale $_locale configured, but no locale resources found.');
                        return null;
                    }
                }
                matches = findFilesByName(localeDir, name);
            }
            if (matches == null || matches.length < 1) {
                matches = findFilesByName(folder, name);
            }
            return matches;
        }
        var files = getFilesFromFolder(platformFolder, _locale);
        if(files == null || !(files.length > 0)) {
            files = getFilesFromFolder(commonFolder, name);
        }

        var entry:FileEntry;
        if (files.length > 1) {
            switch(type) {
                case AssetType.BitmapFont:
                    entry = files.find(function(val) { return val.extension == '.xml' || val.extension == '.fnt'; });
                    entry.extra = files.find(function(val) { return val.extension == '.png'; });
                    entry.extra.type = 'file';
                    entry.extra.path = entry.extra.path.replace('\\', '/');
                    entry.extra.name = entry.extra.name.substr(0, entry.extra.name.lastIndexOf('.'));
                    entry.extra.size = cast(entry.extra.size, Null<Int>) != null ? Std.int(entry.extra.size) : 0;
                default:
                    var preferedExtension = getPreferedExtension(type);
                    if (preferedExtension == null) {
                        trace('Multiple files with same name found, but no prefered extension configured.');
                        trace('When constructing Loader add format param defining if you prefer to use ' + [for (match in files) match.extension].join(' or ') + ' for type ' + type.getName);
                    }
                    entry = files.find(function(val) { return val.extension == preferedExtension; });
            }
        } else {
            entry = files[0];
        }
        if (entry == null) {
            onError('Unable to load \'$type\' \'$name\'');
            return null;
        }
        entry.path = entry.path.replace('\\', '/');
        entry.name = entry.name.substr(0, entry.name.lastIndexOf('.'));
        entry.size = cast(entry.size, Null<Int>) != null ? Std.int(entry.size) : 0;
        return entry;
    }

    inline function findFilesByName(dir:FileEntry, name:String):Array<FileEntry> {
        return dir.children.filter(function(item) { return item.name.substr(0, item.name.lastIndexOf('.')) == name && item.type == 'file'; });
    }

    function handleProgress(position:Int, id:String, total:Int) {
        _loadedBytes.set(id, position);
        var loadedTotal = _loadedBytes.fold(function(curr:Int, last:Int) { return (curr + last); }, 0);
        onProgress(Std.int((loadedTotal / _totalBytes) * 100));
        if (loadedTotal == _totalBytes) {
            haxe.Timer.delay(onComplete, 100);
        }
    }

    function getPreferedExtension(type:AssetType) {
        for (format in _formats) {
            switch(format.type) {
                case type: return format.extension;
            }
        }
        return null;
    }
}

typedef QueueItem = {
name:String,
type:AssetType,
path:String,
size:Int,
extension:String,
?extra:QueueItem,
}

typedef FormatType = {
type:AssetType,
extension:String,
}

enum AssetType {
    Image;
    Sound;
    Font;
    BitmapFont;
    BitmapFontImage;
    Json;
}

typedef HandlerItem = {
id:String,
data:haxe.io.Bytes,
?path:String,
}

typedef AssetConfig = {
/**
 * If specified, resources will resolved from this sub directory
 */
?pack:String,
/**
 * platform - If specified, resources will load from this platform folder
 */
?platform:String,
/**
 * If specfied, will look for a locale sub folder and prioritize assets in that folder
 */
?locale:String,
/**
 * Array with FormatTypes to define what extension to use if multiple files with same name is found. For example [{type:FormatTypes.Sound, '.mp3'}] will ensure you only load mp3 audio
 */
?formats:Array<FormatType>,
/**
 * Name of folders containing images, defaults to 'image'
 */
?imageFolder:String,
/**
 * Name of folders containing sounds, defaults to 'sound'
 */
?soundFolder:String,
/**
 * Name of folders containing fonts, defaults to 'font'
 */
?fontFolder:String,
/**
 * If locale has been set, this is the name of locale sub folder in which to look for localized assets. Defaults to 'localized'
 */
?localizedFolder:String,
/**
 * If locale for a resource is not found, this is the locale to fall back to. Dfeaults to 'en'
 */
?defaultLocale:String,
/**
* Folder for non-platform specific assets
**/
?commonFolder:String,
}